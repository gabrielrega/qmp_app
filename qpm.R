# app.R
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(readr)

# ---------------------------
# Simulador QPM com expectativas híbridas e séries exógenas
# ---------------------------
simulate_qpm <- function(params, state0, T = 40,
                         expectation = c("adaptive","naive","hybrid"),
                         lambda = 0.7,
                         i_star_ts = NULL,
                         r_star_ts = NULL,
                         shocks = list(),
                         PIB_pot_ts = NULL,
                         PIB_base = 1000,
                         q_base   = 100) {
  
  expectation <- match.arg(expectation)
  
  if (is.null(i_star_ts)) i_star_ts <- rep(params$r_star, T+1)
  if (is.null(r_star_ts)) r_star_ts <- rep(params$r_star, T+1)
  if (is.null(PIB_pot_ts)) PIB_pot_ts <- rep(PIB_base, T+1)
  
  y <- numeric(T+1); pi <- numeric(T+1); i <- numeric(T+1); q <- numeric(T+1)
  y[1] <- state0["y"]; pi[1] <- state0["pi"]; i[1] <- state0["i"]; q[1] <- state0["q"]
  
  eps_y <- numeric(T+1); eps_pi <- numeric(T+1); eps_i <- numeric(T+1); eps_q <- numeric(T+1)
  if (!is.null(shocks$y))  eps_y[shocks$y["time"]]   <- shocks$y["value"]
  if (!is.null(shocks$pi)) eps_pi[shocks$pi["time"]] <- shocks$pi["value"]
  if (!is.null(shocks$i))  eps_i[shocks$i["time"]]   <- shocks$i["value"]
  if (!is.null(shocks$q))  eps_q[shocks$q["time"]]   <- shocks$q["value"]
  
  for (t in 1:T) {
    # Expectativas
    if (expectation == "adaptive" || expectation == "naive") {
      exp_pi <- pi[t]; exp_y <- y[t]
    } else if (expectation == "hybrid") {
      exp_pi <- lambda * pi[t] + (1 - lambda) * params$pi_star
      exp_y  <- y[t]
    }
    
    # 1) IS
    y[t+1]  <- params$gamma * y[t] - params$phi * ( i[t] - exp_pi - r_star_ts[t] ) + eps_y[t+1]
    # 2) Phillips
    pi[t+1] <- params$beta * exp_pi + (1 - params$beta) * pi[t] + params$kappa * y[t+1] + eps_pi[t+1]
    # 3) Taylor
    i[t+1]  <- params$rho * i[t] + (1 - params$rho) * (
      r_star_ts[t+1] + params$pi_star +
        params$alpha_pi * (pi[t+1] - params$pi_star) +
        params$alpha_y * y[t+1]
    ) + eps_i[t+1]
    # 4) Câmbio real
    q[t+1]  <- params$theta * q[t] + params$psi * ( i[t+1] - i_star_ts[t+1] ) + eps_q[t+1]
  }
  
  PIB_abs <- PIB_pot_ts * (1 + y/100)
  q_abs   <- q_base * (1 + q/100)
  
  tibble(
    period     = 0:T,
    y          = y,
    PIB_pot    = PIB_pot_ts,
    PIB_abs    = PIB_abs,
    pi         = pi,
    i          = i,
    q          = q,
    q_abs      = q_abs
  )
}

# ---------------------------
# UI
# ---------------------------
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "petrobras.css")
  ),
  
  titlePanel("QPM discreto – Projeções e cenários (Shiny)"),
  sidebarLayout(
    sidebarPanel(
      h4("Parâmetros principais"),
      numericInput("beta",     "β (peso forward na Phillips)", 0.7, 0, 1),
      numericInput("kappa",    "κ (sensibilidade da inflação ao hiato)", 0.3, 0, 5),
      numericInput("phi",      "φ (sensibilidade do hiato à taxa real)", 0.5, 0, 5),
      numericInput("gamma",    "γ (inércia do hiato)", 0.3, 0, 1),
      numericInput("rho",      "ρ (inércia da taxa de juros)", 0.7, 0, 1),
      numericInput("alpha_pi", "απ (resposta à inflação)", 1.5, 0, 5),
      numericInput("alpha_y",  "αy (resposta ao hiato)", 0.5, 0, 5),
      numericInput("r_star",   "r* (taxa neutra real, %)", 1.0, -10, 20),
      numericInput("pi_star",  "π* (meta de inflação, %)", 3.0, -10, 50),
      numericInput("psi",      "ψ (sensibilidade câmbio ao diferencial de juros)", 0.25, 0, 5),
      numericInput("theta",    "θ (persistência do câmbio real)", 0.6, 0, 1),
      
      hr(),
      h4("Expectativas"),
      selectInput("expectation", "Modo de expectativas",
                  choices = c("adaptive","hybrid","naive"), selected = "hybrid"),
      sliderInput("lambda", "λ (peso adaptativo no modo híbrido)", min = 0, max = 1, value = 0.6, step = 0.05),
      
      hr(),
      h4("Estado inicial"),
      numericInput("y0", "Hiato inicial (%)", 0.0, -20, 20),
      numericInput("pi0","Inflação inicial (%)", 3.0, -50, 200),
      numericInput("i0", "Taxa nominal inicial (%)", 4.5, -50, 200),
      numericInput("q0", "Câmbio real inicial (desvio %)", 0.0, -200, 200),
      
      hr(),
      h4("Horizonte e base"),
      numericInput("T", "Horizonte (períodos)", 40, 1, 240, step = 1),
      numericInput("PIB_base", "PIB base (se sem série potencial)", 1000, 0, 1e9),
      numericInput("q_base",   "Índice base do câmbio real", 100, 0, 1e6),
      
      hr(),
      h4("Exógenas (upload CSV opcional)"),
      helpText("Cada CSV deve ter uma coluna única chamada 'value' com T+1 observações (períodos 0..T)."),
      fileInput("PIB_pot_file", "PIB potencial (optional)", accept = c(".csv")),
      fileInput("r_star_file",  "r* série (optional)", accept = c(".csv")),
      fileInput("i_star_file",  "i* série (optional)", accept = c(".csv")),
      checkboxInput("use_examples", "Usar exemplos de séries se não enviar CSV", TRUE),
      
      hr(),
      h4("Choques pontuais"),
      helpText("Defina tempo (1..T) e valor do choque para cada variável (opcional)."),
      numericInput("shock_y_t",  "t (hiato)", NA),
      numericInput("shock_y_v",  "valor (pp) hiato", NA),
      numericInput("shock_pi_t", "t (inflação)", NA),
      numericInput("shock_pi_v", "valor (pp) inflação", NA),
      numericInput("shock_i_t",  "t (juros)", NA),
      numericInput("shock_i_v",  "valor (pp) juros", NA),
      numericInput("shock_q_t",  "t (câmbio)", NA),
      numericInput("shock_q_v",  "valor (%) câmbio", NA),
      
      hr(),
      actionButton("run", "Rodar simulação", class = "btn-primary"),
      downloadButton("download", "Baixar resultados CSV")
    ),
    mainPanel(
      h3("Painéis de projeção"),
      plotOutput("plots", height = "900px"),
      h4("Tabela resumida (início)"),
      tableOutput("table_head")
    )
  )
)

# ---------------------------
# Server
# ---------------------------
server <- function(input, output, session) {
  
  # Helpers para ler séries CSV ou criar exemplos
  read_series_or_example <- function(fileInput, T, default_value, growth = 0, name = "value") {
    if (!is.null(fileInput)) {
      df <- read_csv(fileInput$datapath, show_col_types = FALSE)
      if (!(name %in% names(df))) {
        validate("CSV deve conter coluna chamada 'value'.")
      }
      vec <- df[[name]]
      validate(need(length(vec) >= T+1, "CSV deve ter pelo menos T+1 linhas."))
      as.numeric(vec[1:(T+1)])
    } else {
      # exemplo: crescimento composto simples
      base <- default_value
      (base * (1 + growth)^(0:T))
    }
  }
  
  # Reativo principal: roda a simulação ao clicar em "Rodar"
  sim_data <- eventReactive(input$run, {
    T <- input$T
    
    # Parâmetros
    params <- list(
      beta = input$beta,
      kappa = input$kappa,
      phi = input$phi,
      gamma = input$gamma,
      rho = input$rho,
      alpha_pi = input$alpha_pi,
      alpha_y  = input$alpha_y,
      r_star   = input$r_star,
      pi_star  = input$pi_star,
      psi      = input$psi,
      theta    = input$theta
    )
    
    # Estado inicial
    state0 <- c(y = input$y0, pi = input$pi0, i = input$i0, q = input$q0)
    
    # Séries exógenas
    use_examples <- isTRUE(input$use_examples)
    
    PIB_pot_ts <- read_series_or_example(
      input$PIB_pot_file, T,
      default_value = input$PIB_base,
      growth = if (use_examples) 0.005 else 0.0 # ~0,5% por período como exemplo
    )
    
    r_star_ts <- read_series_or_example(
      input$r_star_file, T,
      default_value = input$r_star,
      growth = 0
    )
    
    i_star_ts <- read_series_or_example(
      input$i_star_file, T,
      default_value = input$r_star + input$pi_star,
      growth = 0
    )
    
    # Choques
    shocks <- list()
    if (!is.na(input$shock_y_t) && !is.na(input$shock_y_v)) shocks$y  <- c(time = input$shock_y_t,  value = input$shock_y_v)
    if (!is.na(input$shock_pi_t) && !is.na(input$shock_pi_v)) shocks$pi <- c(time = input$shock_pi_t, value = input$shock_pi_v)
    if (!is.na(input$shock_i_t) && !is.na(input$shock_i_v)) shocks$i  <- c(time = input$shock_i_t,  value = input$shock_i_v)
    if (!is.na(input$shock_q_t) && !is.na(input$shock_q_v)) shocks$q  <- c(time = input$shock_q_t,  value = input$shock_q_v)
    
    # Rodar simulação
    simulate_qpm(
      params = params,
      state0 = state0,
      T = T,
      expectation = input$expectation,
      lambda = input$lambda,
      i_star_ts = i_star_ts,
      r_star_ts = r_star_ts,
      shocks = shocks,
      PIB_pot_ts = PIB_pot_ts,
      PIB_base = input$PIB_base,
      q_base = input$q_base
    )
  }, ignoreInit = TRUE)
  
  # Plots
  output$plots <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    
    # Painel 1: PIB potencial vs PIB absoluto
    p1 <- ggplot(sim, aes(x = period)) +
      geom_line(aes(y = PIB_pot, color = "PIB Potencial"), size = 1.2) +
      geom_line(aes(y = PIB_abs, color = "PIB Absoluto"), size = 1.2) +
      scale_color_manual(values = c("PIB Potencial" = "blue", "PIB Absoluto" = "red")) +
      labs(title = "PIB Potencial vs PIB Absoluto",
           x = "Período", y = "Valor (nível)", color = "") +
      theme_minimal(base_size = 14)
    
    # Painel 2: Hiato do produto
    p2 <- ggplot(sim, aes(x = period, y = y)) +
      geom_line(color = "darkgreen", size = 1.2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
      labs(title = "Hiato do Produto",
           x = "Período", y = "Desvio (%)") +
      theme_minimal(base_size = 14)
    
    # Painel 3: Inflação
    p3 <- ggplot(sim, aes(x = period, y = pi)) +
      geom_line(color = "firebrick", size = 1.2) +
      geom_hline(yintercept = isolate(input$pi_star), linetype = "dashed", color = "black") +
      labs(title = "Inflação (%)",
           x = "Período", y = "Valor") +
      theme_minimal(base_size = 14)
    
    # Painel 4: Taxa de juros nominal
    p4 <- ggplot(sim, aes(x = period, y = i)) +
      geom_line(color = "purple", size = 1.2) +
      geom_hline(yintercept = isolate(input$r_star + input$pi_star),
                 linetype = "dashed", color = "black") +
      labs(title = "Taxa de Juros Nominal (%)",
           x = "Período", y = "Valor") +
      theme_minimal(base_size = 14)
    
    # Painel 5: Câmbio real absoluto
    p5 <- ggplot(sim, aes(x = period, y = q_abs)) +
      geom_line(color = "orange", size = 1.2) +
      labs(title = "Câmbio Real Absoluto (índice)",
           x = "Período", y = "Valor") +
      theme_minimal(base_size = 14)
    
    (p1 / p2) / (p3 / p4 / p5)
  })
  
  # Tabela resumo
  output$table_head <- renderTable({
    req(sim_data())
    sim_data() %>% slice(1:12)
  })
  
  # Download
  output$download <- downloadHandler(
    filename = function() paste0("qpm_resultados_", Sys.Date(), ".csv"),
    content = function(file) {
      req(sim_data())
      write_csv(sim_data(), file)
    }
  )
}

# ---------------------------
# Run app
# ---------------------------
shinyApp(ui = ui, server = server)