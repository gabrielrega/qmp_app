# Instruções para Reestruturação Manual da Aba de Simulação
# Copy this content to replace lines 223-228 and lines 322-375 in qpm.R

## SUBSTITUIR LINHAS 223-228 (UI da aba Simulação):

```r
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
```

## SUBSTITUIR LINHAS 322-375 (Server rendering):

```r
# Tema personalizado para gráficos
theme_qpm <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0),
      plot.subtitle = element_text(color = "# 666666", size = 11),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "#e0e0e0", linewidth = 0.3),
      legend.position = "top",
      legend.title = element_blank(),
      axis.text = element_text(color = "#333333"),
      axis.title = element_text(face = "bold", color = "#333333")
    )
}

# Métricas-chave
output$metric_pi_final <- render Text({
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
```
