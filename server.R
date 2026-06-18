# server.R - Server Logic for QPM Simulator
server <- function(input, output, session) {
  
  # Observer para carregar preset
  observeEvent(input$load_preset, {
    req(input$preset_country != "custom")
    
    country_data <- countries_params %>% 
      filter(country == input$preset_country)
    
    if(nrow(country_data) > 0) {
      # Parâmetros para atualizar
      params_to_update <- c("beta", "kappa", "phi", "gamma", "rho", 
                           "alpha_pi", "alpha_y", "r_star", "pi_star", 
                           "psi", "theta")
      
      # Atualizar todos os inputs via loop
      for (p in params_to_update) {
        updateNumericInput(session, p, value = country_data[[p]])
      }
      
      # Feedback visual
      showNotification(
        paste0("✅ Parâmetros de ", input$preset_country, " carregados com sucesso!"),
        type = "message",
        duration = 3
      )
    }
  })
  
  # Helpers para ler séries CSV ou criar exemplos
  read_series_or_example <- function(fileInput, T, default_value, growth = 0, name = "value") {
    if (!is.null(fileInput)) {
      df <- read_csv(fileInput$datapath, show_col_types = FALSE)
      validate(need(name %in% names(df), "CSV deve conter coluna chamada 'value'."))
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
      growth = if (use_examples) input$PIB_growth / 100 else 0.0
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
    if (!is.na(input$shock_y_t) && !is.na(input$shock_y_v)) {
      validate(need(input$shock_y_t >= 1 && input$shock_y_t <= T, "Tempo do choque (hiato) deve estar entre 1 e T."))
      shocks$y  <- c(time = input$shock_y_t,  value = input$shock_y_v)
    }
    if (!is.na(input$shock_pi_t) && !is.na(input$shock_pi_v)) {
      validate(need(input$shock_pi_t >= 1 && input$shock_pi_t <= T, "Tempo do choque (inflação) deve estar entre 1 e T."))
      shocks$pi <- c(time = input$shock_pi_t, value = input$shock_pi_v)
    }
    if (!is.na(input$shock_i_t) && !is.na(input$shock_i_v)) {
      validate(need(input$shock_i_t >= 1 && input$shock_i_t <= T, "Tempo do choque (juros) deve estar entre 1 e T."))
      shocks$i  <- c(time = input$shock_i_t,  value = input$shock_i_v)
    }
    if (!is.na(input$shock_q_t) && !is.na(input$shock_q_v)) {
      validate(need(input$shock_q_t >= 1 && input$shock_q_t <= T, "Tempo do choque (câmbio) deve estar entre 1 e T."))
      shocks$q  <- c(time = input$shock_q_t,  value = input$shock_q_v)
    }
    
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
  output$table_projections <- DT::renderDT({
    req(sim_data())
    df_table <- sim_data() %>% 
      select(period, PIB_abs, g_qoq, g_yoy, pi, i, y) %>%
      rename(
        Período = period,
        `PIB` = PIB_abs,
        `Cresc. Trim (%)` = g_qoq,
        `Cresc. Anual (%)` = g_yoy,
        `Inflação (%)` = pi,
        `Juros (%)` = i,
        `Hiato (%)` = y
      )
    
    DT::datatable(
      df_table,
      rownames = FALSE,
      options = list(
        pageLength = 16,
        dom = 'tip',
        scrollX = TRUE,
        columnDefs = list(list(className = 'dt-center', targets = "_all"))
      )
    ) %>%
      DT::formatRound(columns = 2:7, digits = 2)
  })
  
  # Download
  output$download <- downloadHandler(
    filename = function() paste0("qpm_resultados_", Sys.Date(), ".csv"),
    content = function(file) {
      req(sim_data())
      write_csv(sim_data(), file)
    }
  )

  # ---------------------------
  # Comparação entre países
  # ---------------------------
  compare_data <- eventReactive(input$compare_run, {
    T  <- input$compare_T
    c1 <- input$compare_country1
    c2 <- input$compare_country2

    cp1 <- countries_params %>% filter(country == c1)
    cp2 <- countries_params %>% filter(country == c2)
    validate(need(nrow(cp1) == 1 && nrow(cp2) == 1,
                  "Selecione dois países válidos."))

    # Choque comum (opcional)
    shock <- list()
    if (!is.na(input$compare_shock_t) && !is.na(input$compare_shock_v)) {
      validate(need(input$compare_shock_t >= 1 && input$compare_shock_t <= T,
                    "Período do choque deve estar entre 1 e T."))
      shock[[input$compare_shock_var]] <- c(time  = input$compare_shock_t,
                                            value = input$compare_shock_v)
    }

    sim1 <- run_country_sim(cp1, T = T, expectation = input$expectation,
                            lambda = input$lambda, shock = shock)
    sim2 <- run_country_sim(cp2, T = T, expectation = input$expectation,
                            lambda = input$lambda, shock = shock)

    # Rótulos únicos mesmo se os dois países forem iguais
    lab1 <- c1
    lab2 <- if (c2 == c1) paste0(c2, " (2)") else c2

    combined <- bind_rows(
      sim1 %>% mutate(country = lab1),
      sim2 %>% mutate(country = lab2)
    ) %>%
      mutate(country = factor(country, levels = c(lab1, lab2)))

    list(df = combined, labels = c(lab1, lab2))
  }, ignoreInit = TRUE)

  compare_palette <- function(labels) {
    setNames(c("#2c3e50", "#e67e22"), labels)
  }

  compare_plot <- function(yvar, title, subtitle, ylab, hline = NULL) {
    cd  <- compare_data()
    pal <- compare_palette(cd$labels)
    p <- ggplot(cd$df, aes(x = period, y = .data[[yvar]], color = country))
    if (!is.null(hline)) {
      p <- p + geom_hline(yintercept = hline, linetype = "dashed",
                          color = "#95a5a6", linewidth = 0.7)
    }
    p +
      geom_line(linewidth = 1.2) +
      scale_color_manual(values = pal) +
      labs(title = title, subtitle = subtitle, x = "Período", y = ylab) +
      theme_qpm()
  }

  output$compare_plot_inflation <- renderPlot({
    req(compare_data())
    compare_plot("pi", "Inflação", "Resposta ao choque comum", "Inflação (%)")
  })

  output$compare_plot_interest <- renderPlot({
    req(compare_data())
    compare_plot("i", "Taxa de Juros Nominal", "Resposta ao choque comum", "Juros (%)")
  })

  output$compare_plot_output_gap <- renderPlot({
    req(compare_data())
    compare_plot("y", "Hiato do Produto", "Resposta ao choque comum",
                 "Hiato (%)", hline = 0)
  })

  output$compare_plot_exchange <- renderPlot({
    req(compare_data())
    compare_plot("q_abs", "Câmbio Real", "Resposta ao choque comum",
                 "Índice de Câmbio Real", hline = 100)
  })

  # Tabela de diferenças de resposta
  output$compare_table <- DT::renderDT({
    req(compare_data())
    cd   <- compare_data()
    labs <- cd$labels

    summ <- cd$df %>%
      group_by(country) %>%
      summarise(
        `Inflação final (%)`    = tail(pi, 1),
        `Juros final (%)`       = tail(i, 1),
        `Hiato médio 12 (%)`    = mean(tail(y, 12)),
        `Câmbio final (índice)` = tail(q_abs, 1),
        `Pico de inflação (%)`  = max(pi),
        .groups = "drop"
      )

    metrics <- setdiff(names(summ), "country")
    v1 <- as.numeric(summ[summ$country == labs[1], metrics])
    v2 <- as.numeric(summ[summ$country == labs[2], metrics])

    tab <- data.frame(metrics, v1, v2, v1 - v2, check.names = FALSE)
    names(tab) <- c("Métrica", labs[1], labs[2], "Diferença (1−2)")

    DT::datatable(
      tab, rownames = FALSE,
      options = list(dom = 't',
                     columnDefs = list(list(className = 'dt-center', targets = "_all")))
    ) %>%
      DT::formatRound(columns = 2:4, digits = 2)
  })

  output$compare_download <- downloadHandler(
    filename = function() paste0("qpm_comparacao_", Sys.Date(), ".csv"),
    content = function(file) {
      req(compare_data())
      write_csv(compare_data()$df, file)
    }
  )
}
