# app.R - QPM v2 com Dashboard Reestruturado
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
  
  titlePanel("QPM discreto – Projeções e cenários (Shiny v2)"),
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
      numericInput("shock_pi_v", "valor (pp) inflação)", NA),
      numericInput("shock_i_t",  "t (juros)", NA),
      numericInput("shock_i_v",  "valor (pp) juros", NA),
      numericInput("shock_q_t",  "t (câmbio)", NA),
      numericInput("shock_q_v",  "valor (%) câmbio", NA),
      
      hr(),
      actionButton("run", "Rodar simulação", class = "btn-primary"),
      downloadButton("download", "Baixar resultados CSV")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Instruções",
          h3("📘 Guia de Uso do Simulador QPM"),
          
          h4("O que é o QPM?"),
          p("O Quarterly Projection Model (QPM) é um modelo macroeconômico semi-estrutural do tipo Novo-Keynesiano,
            utilizado por bancos centrais para análise de política monetária e construção de cenários de projeção."),
          
          hr(),
          h4("🎯 Como usar este simulador"),
          tags$ol(
            tags$li(strong("Configure os parâmetros"), " na barra lateral esquerda"),
            tags$li(strong("Defina o estado inicial"), " da economia (hiato, inflação, juros, câmbio)"),
            tags$li(strong("Opcionalmente, adicione choques"), " pontuais ou séries exógenas"),
            tags$li(strong("Clique em 'Rodar simulação'"), " para gerar as projeções"),
            tags$li(strong("Analise os gráficos"), " na aba 'Simulação'"),
            tags$li(strong("Baixe os resultados"), " em formato CSV se necessário")
          ),
          
          hr(),
          h4("📊 Parâmetros Estruturais do Modelo"),
          
          tags$h5("Curva de Phillips (Inflação)"),
          tags$ul(
            tags$li(strong("β (beta):"), " Peso das expectativas futuras na formação da inflação. Valores próximos de 1 indicam que a inflação é mais forward-looking."),
            tags$li(strong("κ (kappa):"), " Sensibilidade da inflação ao hiato do produto. Valores maiores significam que pressões de demanda afetam mais a inflação.")
          ),
          
          tags$h5("Curva IS (Demanda Agregada)"),
          tags$ul(
            tags$li(strong("φ (phi):"), " Sensibilidade do hiato do produto à taxa de juros real. Valores maiores indicam que a política monetária é mais eficaz."),
            tags$li(strong("γ (gamma):"), " Inércia do hiato do produto. Captura a persistência de desvios do produto em relação ao potencial.")
          ),
          
          tags$h5("Regra de Taylor (Política Monetária)"),
          tags$ul(
            tags$li(strong("ρ (rho):"), " Suavização da taxa de juros. Bancos centrais ajustam juros gradualmente (valores típicos: 0.6-0.8)."),
            tags$li(strong("απ (alpha_pi):"), " Resposta à inflação. Valores > 1 indicam política ativa (Princípio de Taylor)."),
            tags$li(strong("αy (alpha_y):"), " Resposta ao hiato do produto. Captura o mandato dual do BC."),
            tags$li(strong("r*:"), " Taxa neutra de juros real, compatível com inflação na meta e hiato zero."),
            tags$li(strong("π*:"), " Meta de inflação do banco central.")
          ),
          
          tags$h5("Câmbio Real"),
          tags$ul(
            tags$li(strong("ψ (psi):"), " Sensibilidade do câmbio ao diferencial de juros (paridade descoberta de juros)."),
            tags$li(strong("θ (theta):"), " Persistência do câmbio real. Valores altos indicam ajuste lento ao equilíbrio.")
          ),
          
          hr(),
          h4("🧠 Formação de Expectativas"),
          tags$ul(
            tags$li(strong("Adaptativa:"), " Agentes esperam que a inflação futura seja igual à inflação corrente."),
            tags$li(strong("Naive:"), " Similar à adaptativa (expectativa igual ao valor atual)."),
            tags$li(strong("Híbrida:"), " Combinação ponderada entre expectativa adaptativa (peso λ) e a meta de inflação (peso 1-λ).")
          ),
          
          hr(),
          h4("💥 Choques e Cenários"),
          p("Você pode simular eventos específicos de duas formas:"),
          tags$ul(
            tags$li(strong("Choques pontuais:"), " Adicione um choque único em um período específico (ex: choque de oferta em t=10)."),
            tags$li(strong("Séries exógenas:"), " Faça upload de arquivos CSV com trajetórias completas para PIB potencial, r* ou i*.")
          ),
          
          hr(),
          h4("📈 Interpretação dos Gráficos"),
          tags$ul(
            tags$li(strong("PIB Potencial vs Absoluto:"), " Compara a trajetória potencial com a efetiva."),
            tags$li(strong("Hiato do Produto:"), " Diferença percentual entre PIB efetivo e potencial. Valores positivos indicam economia aquecida."),
            tags$li(strong("Inflação:"), " Trajetória da inflação com linha tracejada na meta."),
            tags$li(strong("Taxa de Juros Nominal:"), " Taxa Selic projetada pelo modelo."),
            tags$li(strong("Câmbio Real:"), " Índice de câmbio real (valores maiores = depreciação).")
          ),
          
          hr(),
          p(em("Nota: Este é um modelo simplificado para fins pedagógicos e de análise de cenários. 
               Para decisões de política monetária real, modelos mais complexos com expectativas racionais são necessários."))
        ),
        
        tabPanel("Simulação",
          h3("📈 Dashboard de Projeções"),
          
          # Métricas-chave
          fluidRow(
            column(3,
              wellPanel(
                style = "background-color: #e8f4f8; border-left: 4px solid #2c3e50;",
                h4("Inflação Final", style = "margin-top: 0;"),
                textOutput("metric_pi_final"),
                tags$small("Convergência para meta")
              )
            ),
            column(3,
              wellPanel(
                style = "background-color: #f0e8f8; border-left: 4px solid #8e44ad;",
                h4("Taxa de Juros Final", style = "margin-top: 0;"),
                textOutput("metric_i_final"),
                tags$small("Valor no período final")
              )
            ),
            column(3,
              wellPanel(
                style = "background-color: #e8f8e8; border-left: 4px solid #27ae60;",
                h4("Hiato Médio", style = "margin-top: 0;"),
                textOutput("metric_y_avg"),
                tags$small("Média últimos 12 períodos")
              )
            ),
            column(3,
              wellPanel(
                style = "background-color: #fff4e6; border-left: 4px solid #e67e22;",
                h4("Câmbio Real Final", style = "margin-top: 0;"),
                textOutput("metric_q_final"),
                tags$small("Índice no período final")
              )
            )
          ),
          
          hr(),
          
          # Gráficos principais
          h4("🎯 Variáveis de Política Monetária"),
          fluidRow(
            column(6, plotOutput("plot_inflation", height = "350px")),
            column(6, plotOutput("plot_interest", height = "350px"))
          ),
          
          br(),
          h4("📊 Atividade Econômica"),
          fluidRow(
            column(6, plotOutput("plot_output_gap", height = "350px")),
            column(6, plotOutput("plot_gdp", height = "350px"))
          ),
          
          br(),
          h4("💱 Câmbio"),
          fluidRow(
            column(12, plotOutput("plot_exchange", height = "350px"))
          ),
          
          hr(),
          
          # Tabela de projeções
          h4("📋 Tabela de Projeções (Primeiros 12 períodos)"),
          tableOutput("table_projections")
        )
      )
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
  
  # Tema personalizado para gráficos
  theme_qpm <- function() {
    theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold", size = 14, hjust = 0),
        plot.subtitle = element_text(color = "#666666", size = 11),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "#e0e0e0", linewidth = 0.3),
        legend.position = "top",
        legend.title = element_blank(),
        axis.text = element_text(color = "#333333"),
        axis.title = element_text(face = "bold", color = "#333333")
      )
  }
  
  # Métricas-chave
  output$metric_pi_final <- renderText({
    req(sim_data())
    sim <- sim_data()
    final_val <- tail(sim$pi, 1)
    target <- isolate(input$pi_star)
    diff <- final_val - target
    sprintf("%.2f%% (meta: %.1f%%, diff: %+.2f pp)", final_val, target, diff)
  })
  
  output$metric_i_final <- renderText({
    req(sim_data())
    sim <- sim_data()
    sprintf("%.2f%%", tail(sim$i, 1))
  })
  
  output$metric_y_avg <- renderText({
    req(sim_data())
    sim <- sim_data()
    last_12 <- tail(sim$y, 12)
    sprintf("%.2f%%", mean(last_12))
  })
  
  output$metric_q_final <- renderText({
    req(sim_data())
    sim <- sim_data()
    sprintf("%.2f", tail(sim$q_abs, 1))
  })
  
  # Gráfico: Inflação
  output$plot_inflation <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    pi_target <- isolate(input$pi_star)
    
    ggplot(sim, aes(x = period, y = pi)) +
      geom_ribbon(aes(ymin = pi_target - 1.5, ymax = pi_target + 1.5), 
                  fill = "#3498db", alpha = 0.15) +
      geom_hline(yintercept = pi_target, linetype = "dashed", 
                 color = "#2c3e50", linewidth = 0.8) +
      geom_line(color = "#e74c3c", linewidth = 1.3) +
      geom_point(data = sim %>% filter(period %in% c(0, max(period))), 
                 color = "#e74c3c", size = 3) +
      labs(title = "Projeção da Inflação",
           subtitle = "Área sombreada: banda de ±1.5pp da meta",
           x = "Período", y = "Inflação (%)") +
      theme_qpm()
  })
  
  # Gráfico: Taxa de Juros
  output$plot_interest <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    neutral_rate <- isolate(input$r_star + input$pi_star)
    
    ggplot(sim, aes(x = period, y = i)) +
      geom_hline(yintercept = neutral_rate, linetype = "dashed", 
                 color = "#95a5a6", linewidth = 0.8) +
      geom_line(color = "#8e44ad", linewidth = 1.3) +
      geom_point(data = sim %>% filter(period %in% c(0, max(period))), 
                 color = "#8e44ad", size = 3) +
      annotate("text", x = max(sim$period) * 0.85, y = neutral_rate, 
               label = paste0("Taxa neutra: ", round(neutral_rate, 2), "%"), 
               vjust = -0.5, color = "#7f8c8d", size = 3.5) +
      labs(title = "Projeção da Taxa de Juros Nominal",
           subtitle = "Linha tracejada: taxa neutra (r* + π*)",
           x = "Período", y = "Taxa de Juros (%)") +
      theme_qpm()
  })
  
  # Gráfico: Hiato do Produto
  output$plot_output_gap <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    
    ggplot(sim, aes(x = period, y = y)) +
      geom_ribbon(aes(ymin = 0, ymax = y, fill = y > 0), alpha = 0.3) +
      geom_hline(yintercept = 0, linetype = "solid", 
                 color = "#2c3e50", linewidth = 0.6) +
      geom_line(color = "#27ae60", linewidth = 1.3) +
      scale_fill_manual(values = c("TRUE" = "#e74c3c", "FALSE" = "#3498db"), 
                        guide = "none") +
      labs(title = "Hiato do Produto",
           subtitle = "Vermelho: economia aquecida | Azul: economia desaquecida",
           x = "Período", y = "Hiato (%)") +
      theme_qpm()
  })
  
  # Gráfico: PIB
  output$plot_gdp <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    
    sim_long <- sim %>%
      select(period, PIB_pot, PIB_abs) %>%
      pivot_longer(cols = c(PIB_pot, PIB_abs), 
                   names_to = "tipo", values_to = "valor")
    
    ggplot(sim_long, aes(x = period, y = valor, color = tipo)) +
      geom_line(linewidth = 1.2) +
      scale_color_manual(
        values = c("PIB_pot" = "#3498db", "PIB_abs" = "#2c3e50"),
        labels = c("PIB Potencial", "PIB Efetivo")
      ) +
      labs(title = "Projeção do PIB",
           subtitle = "Comparação entre PIB efetivo e potencial",
           x = "Período", y = "Nível do PIB") +
      theme_qpm()
  })
  
  # Gráfico: Câmbio
  output$plot_exchange <- renderPlot({
    req(sim_data())
    sim <- sim_data()
    base <- isolate(input$q_base)
    
    ggplot(sim, aes(x = period, y = q_abs)) +
      geom_hline(yintercept = base, linetype = "dashed", 
                 color = "#95a5a6", linewidth = 0.8) +
      geom_line(color = "#e67e22", linewidth = 1.3) +
      geom_point(data = sim %>% filter(period %in% c(0, max(period))), 
                 color = "#e67e22", size = 3) +
      annotate("text", x = max(sim$period) * 0.85, y = base, 
               label = paste0("Base: ", base), 
               vjust = -0.5, color = "#7f8c8d", size = 3.5) +
      labs(title = "Projeção do Câmbio Real",
           subtitle = "Índice do câmbio real (valores maiores = depreciação)",
           x = "Período", y = "Índice de Câmbio Real") +
      theme_qpm()
  })
  
  # Tabela de projeções
  output$table_projections <- renderTable({
    req(sim_data())
    sim_data() %>% 
      slice(1:12) %>%
      select(period, pi, i, y, PIB_abs, q_abs) %>%
      rename(
        Período = period,
        `Inflação (%)` = pi,
        `Juros (%)` = i,
        `Hiato (%)` = y,
        `PIB` = PIB_abs,
        `Câmbio Real` = q_abs
      )
  }, digits = 2, striped = TRUE, hover = TRUE, bordered = TRUE)
  
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
