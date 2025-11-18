# Proposta de Integração de Presets de Países no QPM

## 📋 Visão Geral

Esta proposta detalha como integrar configurações pré-calibradas de países no simulador QPM, permitindo aos usuários iniciar análises com parâmetros academicamente fundamentados para diferentes economias.

---

## 🎯 Objetivos

1. **Facilitar o uso**: Usuários podem começar com parâmetros realistas sem necessidade de calibração manual
2. **Benchmarking**: Comparar diferentes economias e suas dinâmicas de política monetária
3. **Educacional**: Demonstrar como diferentes estruturas econômicas afetam a transmissão da política monetária
4. **Profissional**: Fornecer ponto de partida sólido para análises mais refinadas

---

## 🏗️ Arquitetura Proposta

### Opção 1: Seletor de País Simples (Recomendado)

**Interface**: Adicionar um `selectInput` no painel lateral que carrega todos os parâmetros de uma vez.

```r
# No sidebarPanel, ANTES dos parâmetros principais:
wellPanel(
  style = "background-color: #f8f9fa; border: 2px solid #007bff;",
  h4("🌍 Calibrações de Países", style = "color: #007bff;"),
  selectInput("preset_country", 
              "Selecione um país (sobrescreve parâmetros):",
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
)
```

**Vantagens**:
- ✅ Simples e direto
- ✅ Não requer mudança de estrutura
- ✅ Usuário vê imediatamente os parâmetros carregados

**Implementação Server**:
```r
# Carregar dados de países
countries_params <- read_csv("presets/countries_parameters.csv")

# Observer para carregar preset
observeEvent(input$load_preset, {
  req(input$preset_country != "custom")
  
  country_data <- countries_params %>% 
    filter(country == input$preset_country)
  
  if(nrow(country_data) > 0) {
    # Atualizar todos os inputs
    updateNumericInput(session, "beta", value = country_data$beta)
    updateNumericInput(session, "kappa", value = country_data$kappa)
    updateNumericInput(session, "phi", value = country_data$phi)
    updateNumericInput(session, "gamma", value = country_data$gamma)
    updateNumericInput(session, "rho", value = country_data$rho)
    updateNumericInput(session, "alpha_pi", value = country_data$alpha_pi)
    updateNumericInput(session, "alpha_y", value = country_data$alpha_y)
    updateNumericInput(session, "r_star", value = country_data$r_star)
    updateNumericInput(session, "pi_star", value = country_data$pi_star)
    updateNumericInput(session, "psi", value = country_data$psi)
    updateNumericInput(session, "theta", value = country_data$theta)
    
    # Feedback visual
    showNotification(
      paste0("✅ Parâmetros de ", input$preset_country, " carregados!"),
      type = "message",
      duration = 3
    )
  }
})
```

---

### Opção 2: Aba Dedicada de Comparações

**Interface**: Nova aba "Comparação de Países" que permite rodar simulações lado a lado.

```r
tabPanel("Comparação de Países",
  h3("📊 Comparação de Respostas de Política Monetária"),
  
  fluidRow(
    column(4,
      selectInput("compare_country1", "País 1:", 
                  choices = c("Brasil", "Chile", "Peru", "Colombia", "Mexico", "EUA")),
      actionButton("run_compare1", "Simular País 1", class = "btn-primary btn-block")
    ),
    column(4,
      selectInput("compare_country2", "País 2:", 
                  choices = c("Brasil", "Chile", "Peru", "Colombia", "Mexico", "EUA"),
                  selected = "Chile"),
      actionButton("run_compare2", "Simular País 2", class = "btn-primary btn-block")
    ),
    column(4,
      wellPanel(
        h5("Choque Comum:"),
        numericInput("compare_shock_type", "Tipo (1=hiato, 2=inflação)", 2, 1, 2),
        numericInput("compare_shock_time", "Período", 5, 1, 40),
        numericInput("compare_shock_value", "Valor (pp)", 2, -10, 10)
      )
    )
  ),
  
  hr(),
  
  fluidRow(
    column(6, 
      h4("Resposta - País 1"),
      plotOutput("compare_plot1", height = "600px")
    ),
    column(6,
      h4("Resposta - País 2"),
      plotOutput("compare_plot2", height = "600px")
    )
  )
)
```

**Vantagens**:
- ✅ Análise comparativa poderosa
- ✅ Educacional (mostra diferenças estruturais)
- ✅ Útil para policy makers

**Desvantagens**:
- ❌ Mais complexo de implementar
- ❌ Requer UX cuidadoso

---

### Opção 3: Biblioteca de Cenários

**Interface**: Cenários pré-configurados (país + choque + condições iniciais).

```r
# Exemplos de cenários:
scenarios <- tibble(
  id = 1:4,
  name = c(
    "Brasil - Choque de Commodities 2022",  
    "Chile - Ajuste Pós-Pandemia",
    "Peru - Dolarização e Taxa Cambial",
    "México - Integração USMCA"
  ),
  country = c("Brasil", "Chile", "Peru", "Mexico"),
  # ... condições iniciais e choques específicos
)
```

**Vantagens**:
- ✅ Muito educacional
- ✅ Mostra uso prático do modelo

**Desvantagens**:
- ❌ Requer curadoria contínua
- ❌ Mais trabalhoso de manter

---

## 🚀 Recomendação de Implementação

### Fase 1: Seletor Simples (Opção 1) - IMEDIATO
1. Adicionar `wellPanel` com seletor de países
2. Implementar `observeEvent` para carregar parâmetros
3. Adicionar notificação visual de confirmação
4. Documentar no guia de instruções

**Esforço**: Baixo (1-2 horas)  
**Impacto**: Alto (facilita muito o uso)

---

### Fase 2: Documentação Expandida - CURTO PRAZO
1. Adicionar seção "Calibrações de Países" na aba Instruções
2. Link para `PARAMETERS_GUIDE.md`
3. Explicar diferenças entre economias

**Esforço**: Baixo (30 min)  
**Impacto**: Médio (contexto educacional)

---

### Fase 3 (Opcional): Comparação de Países - MÉDIO PRAZO
1. Implementar aba de comparação (Opção 2)
2. Gráficos sobrepostos
3. Tabela de diferenças de resposta

**Esforço**: Médio-Alto (4-6 horas)  
**Impacto**: Alto (muito útil para análise)

---

## 📦 Estrutura de Arquivos Proposta

```
qmp_app/
├── qpm_v2.R                    # App principal (será qpm.R)
├── presets/
│   ├── countries_parameters.csv           # ✅ CRIADO
│   ├── PARAMETERS_GUIDE.md                # ✅ CRIADO
│   └── scenarios/                         # Futuro
│       ├── brasil_commodities_2022.csv
│       └── chile_post_pandemic.csv
├── www/
│   └── petrobras.css
└── README.md
```

---

## 🎨 Mockup da Interface (Opção 1)

```
┌─────────────────────────────────────────┐
│ 🌍 Calibrações de Países                │
│ ┌─────────────────────────────────────┐ │
│ │ Selecione um país:                  │ │
│ │ [Dropdown: Brasil 🇧🇷 ▼]             │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Carregar Preset] ← Botão azul         │
│ Carrega parâmetros calibrados da...    │
└─────────────────────────────────────────┘

(Após clicar)
┌──────────────────────────────┐
│ ✅ Parâmetros de Brasil      │
│    carregados!               │
└──────────────────────────────┘

┌─────────────────────────────┐
│ Parâmetros principais       │
│ β (peso forward): [0.65]    │ ← Atualizado
│ κ (sensibilidade): [0.35]   │ ← Atualizado
│ ...                         │
```

---

## 📊 Exemplo de Uso

### Caso de Uso 1: Analista Iniciante
1. Abre o app
2. Seleciona "Brasil 🇧🇷"
3. Clica "Carregar Preset"
4. Vai direto para "Rodar simulação"
5. Analisa trajetórias realistas

### Caso de Uso 2: Comparação Estrutural
1. Roda simulação para Brasil
2. Baixa CSV
3. Seleciona Chile
4. Carrega preset
5. Roda simulação com MESMO choque
6. Compara respostas diferentes devido a estruturas distintas

### Caso de Uso 3: Refinamento
1. Inicia com preset México
2. Ajusta apenas r* e π* (conhecimento específico)
3. Roda análise customizada

---

## 🔬 Validação Científica

Todos os parâmetros foram obtidos de:
- ✅ Artigos peer-reviewed
- ✅ Working papers do FMI
- ✅ Documentação de BCs (Chile, Peru)
- ✅ Literatura DSGE consolidada

Ver `PARAMETERS_GUIDE.md` para referências completas.

---

## 📝 Próximos Passos

1. ✅ **CONCLUÍDO**: Arquivos CSV e documentação criados
2. ⏳ **PENDENTE**: Integrar seletor no qpm_v2.R
3. ⏳ **PENDENTE**: Testar com diferentes presets
4. ⏳ **PENDENTE**: Promover qpm_v2.R como qpm.R oficial
5. ⏳ **PENDENTE**: Commit e documentar no README

---

## 💡 Sugestões Adicionais

### Série Temporal de PIB Potencial
Podemos criar CSVs com dados reais de PIB potencial para cada país (extraídos de OECD, FMI, etc.):

```
presets/timeseries/
├── brasil_pib_potencial.csv
├── chile_pib_potencial.csv
└── ...
```

### Choques Históricos
Recriar eventos históricos:
- Brasil: Crise de 2015-2016
- Chile: Estallido Social 2019
- Peru: Crise política 2020

---

**Recomendação Final**: Implementar **Fase 1 imediatamente** (seletor simples), depois decidir se vale expandir para comparações.
