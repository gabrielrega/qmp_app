# ui.R - User Interface for QPM Simulator
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "petrobras.css")
  ),
  
  titlePanel("QPM discreto – Projeções e cenários (Shiny)"),
  sidebarLayout(
    sidebarPanel(
      wellPanel(
        style = "background-color: #f8f9fa; border: 2px solid #007bff;",
        h4("🌍 Calibrações de Países", style = "color: #007bff; margin-top: 0;"),
        selectInput("preset_country", 
                    "Selecione um país:",
                    choices = c(
                      "Personalizado" = "custom",
                      "Brasil 🇧🇷" = "Brasil",
                      "Chile 🇨🇱" = "Chile",
                      "Peru 🇵🇪" = "Peru",
                      "Colômbia 🇨🇴" = "Colombia",
                      "México 🇲🇽" = "Mexico",
                      "EUA 🇺🇸" = "EUA"
                    ),
                    selected = "custom"),
        actionButton("load_preset", "Carregar Preset", 
                     class = "btn-info btn-block"),
        tags$small("Carrega parâmetros calibrados da literatura acadêmica")
      ),
      
      hr(),
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
      numericInput("PIB_growth", "Crescimento do PIB potencial (% por período)", 0.5, -5, 10, step = 0.1),
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
          
          tags$h5("Base e Horizonte"),
          tags$ul(
            tags$li(strong("PIB Base:"), " Nível inicial do PIB (t=0)."),
            tags$li(strong("Crescimento do PIB Potencial:"), " Taxa de crescimento do produto potencial por período. Define a inclinação da trajetória de longo prazo."),
            tags$li(strong("Índice de Câmbio Base:"), " Valor inicial para o índice de câmbio real (ex: 100).")
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
