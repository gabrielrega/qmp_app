# Simulador QPM - Quarterly Projection Model

## 📊 Visão Geral

Aplicação Shiny interativa para simulação de modelos QPM (Quarterly Projection Model), amplamente utilizados por bancos centrais para análise de política monetária e construção de cenários macroeconômicos.

**Servidor ativo**: http://127.0.0.1:4481

---

## ✨ Principais Recursos

### 1. **Dashboard Profissional de Projeções**
- 📈 Métricas-chave em cards (inflação final, taxa de juros, hiato médio, câmbio)
- 📊 Visualizações individuais e detalhadas
- 🎨 Design moderno com tema customizado
- 📋 Tabela de projeções formatada

### 2. **Presets de Países** 🌍 ⭐ NOVO
Parâmetros calibrados baseados em literatura acadêmica para:
- 🇧🇷 **Brasil** - Economia emergente com histórico inflacionário
- 🇨🇱 **Chile** - Pioneiro IT na América Latina
- 🇵🇪 **Peru** - Economia parcialmente dolarizada  
- 🇨🇴 **Colômbia** - IT forte, commodity-dependente
- 🇲🇽 **México** - Integração com EUA (USMCA)
- 🇺🇸 **EUA** - Economia avançada (referência)

### 3. **Modelo Econômico Completo**
- Curva IS (demanda agregada)
- Curva de Phillips (dinâmica inflacionária)
- Regra de Taylor (política monetária)
- Câmbio real (UIP modificada)
- Expectativas híbridas (adaptativas/forward-looking)

### 4. **Análise de Cenários**
- Choques pontuais em qualquer variável
- Upload de séries exógenas (PIB potencial, r*, i*)
- Diferentes modos de formação de expectativas
- Horizonte de simulação configurável

### 5. **Comparação entre Países** 🆚
- Aba dedicada que sobrepõe as trajetórias de dois países sob um **choque comum**
- Cada economia parte do seu próprio estado estacionário (isola diferenças estruturais)
- Gráficos sobrepostos de inflação, juros, hiato e câmbio
- Tabela de diferenças de resposta + download em CSV

### 6. **Funções de Resposta a Impulso (IRFs)** 📉
- Aba dedicada à resposta dinâmica de cada variável a um choque único
- Medida como desvio do estado estacionário, por país preset ou parâmetros customizados
- Download dos dados da IRF em CSV

### 7. **Export de Gráficos em Alta Resolução** 📥
- Botões de download de PNG/PDF nas abas Simulação, Comparação e IRFs
- Largura, altura e DPI configuráveis; opção de exportar o painel completo

---

## 🚀 Como Usar

### Início Rápido

1. **Execute o app** (a partir da raiz do projeto):
```powershell
& "C:\Program Files\R\R-4.4.1\bin\Rscript.exe" -e "shiny::runApp('.')"
```
> O Shiny carrega automaticamente `global.R`, `ui.R` e `server.R`; `app.R` é só o ponto de entrada.

2. **Carregue um preset de país**:
   - Selecione um país no dropdown "🌍 Calibrações de Países"
   - Clique em "Carregar Preset"
   - Todos os parâmetros serão atualizados automaticamente

3. **Rode a simulação**:
   - Configure condições iniciais (hiato, inflação, juros, câmbio)
   - Defina choques (opcional)
   - Clique em "Rodar simulação"

4. **Analise os resultados**:
   - Veja métricas-chave nos cards coloridos
   - Examine os gráficos de projeção
   - Baixe os dados em CSV

### Workflow Típico

```
1. Escolher país preset → Carregar
2. Ajustar estado inicial → (hiato, inflação, etc.)
3. Adicionar choque → (ex: t=10, +2pp inflação)
4. Rodar simulação → Analisar trajetórias
5. Baixar CSV → Análises externas
```

---

## 📁 Estrutura do Projeto

```
qmp_app/
├── app.R                           # ⭐ Ponto de entrada — shinyApp(ui, server)
├── global.R                        # Engine simulate_qpm() + carga dos presets
├── ui.R                            # Interface (controles + dashboard)
├── server.R                        # Lógica reativa, gráficos, métricas, download
├── prototype/                      # 🧪 Scripts exploratórios (fora da app)
│   ├── qpm_standalone.R                  # Protótipo original em R puro
│   └── README.md                         # Explicação da pasta
├── presets/                        # 🌍 Configurações de países
│   ├── countries_parameters.csv          # Parâmetros calibrados
│   ├── PARAMETERS_GUIDE.md               # Documentação técnica (7.5KB)
│   ├── INTEGRATION_PROPOSAL.md           # Proposta de features
│   ├── brasil_pib_potencial_exemplo.csv  # Série exemplo
│   └── README.md                         # Guia dos presets
├── www/
│   └── petrobras.css               # Estilo customizado
├── renv/                          # Ambiente R isolado
├── renv.lock                      # Versões fixas de pacotes
└── README.md                      # Este arquivo
```

---

## 🎨 Interface

### Painel de Controle
- **Presets de Países**: Carregue configurações calibradas
- **Parâmetros Principais**: β, κ, φ, γ, ρ, απ, αy, r*, π*, ψ, θ
- **Expectativas**: Adaptativas, híbridas, naive
- **Estado Inicial**: Condições macroeconômicas no t=0
- **Choques**: Eventos pontuais em qualquer variável
- **Séries Exógenas**: Upload de CSVs customizados

### Dashboard de Projeções
- **Cards de Métricas**: 4 indicadores-chave destacados
- **Gráfico de Inflação**: Com banda de convergência (±1.5pp)
- **Gráfico de Juros**: Com linha de taxa neutra
- **Gráfico de Hiato**: Zonas coloridas (aquecimento/desaquecimento)
- **Gráfico de PIB**: Potencial vs Efetivo
- **Gráfico de Câmbio**: Índice de câmbio real
- **Tabela (DT)**: Projeções interativas com PIB, crescimento trimestral (QoQ) e anual (YoY), inflação, juros e hiato

---

## 🔬 Fundamentos Teóricos

### Equações do Modelo

**1. Curva IS (Demanda Agregada)**
```
y[t+1] = γ·y[t] - φ·(i[t] - E[π] - r*[t]) + ε_y
```

**2. Curva de Phillips (Inflação)**
```
π[t+1] = β·E[π] + (1-β)·π[t] + κ·y[t+1] + ε_π
```

**3. Regra de Taylor (Política Monetária)**
```
i[t+1] = ρ·i[t] + (1-ρ)·(r*[t+1] + π* + απ·(π[t+1] - π*) + αy·y[t+1]) + ε_i
```

**4. Câmbio Real (UIP Modificada)**
```
q[t+1] = θ·q[t] + ψ·(i[t+1] - i*[t+1]) + ε_q
```

### Referências Acadêmicas
- Berg, Karam & Laxton (2006) - IMF Working Paper sobre QPMs
- Medina & Soto (2007) - DSGE para Chile
- Salas (2010) - QPM para Peru
- Documentação dos Bancos Centrais (BCB, CBOC, BCRP)

Ver `presets/PARAMETERS_GUIDE.md` para detalhes completos.

---

## 📦 Dependências

### Pacotes R (via renv)
- `shiny` - Framework web
- `dplyr` - Manipulação de dados
- `tidyr` - Transformações tidy
- `ggplot2` - Visualizações
- `patchwork` - Composição de gráficos
- `readr` - Leitura de CSVs
- `DT` - Tabela de projeções interativa

### Instalação
O projeto usa `renv` para gerenciamento de dependências:
```r
# As dependências são carregadas automaticamente
# ao abrir o projeto no RStudio ou rodar o app
renv::restore()  # Se necessário
```

---

## 🎯 Casos de Uso

### 1. Educacional
**Objetivo**: Demonstrar mecanismos de transmissão da política monetária

```
Exemplo: Choque de inflação de +2pp
- Selecione Brasil
- Carregue preset
- Adicione choque: t=5, π=+2pp
- Compare com Chile (repita simulação)
```

### 2. Análise de Política
**Objetivo**: Avaliar impacto de mudanças na regra de Taylor

```
Exemplo: BC mais hawkish
- Carregue preset Brasil
- Aumente απ de 1.8 para 2.5
- Rode simulação
- Observe convergência mais rápida da inflação
```

### 3. Comparação Estrutural
**Objetivo**: Entender diferenças entre economias

```
Exemplo: Emergentes vs Avançados
- Rode simulação: Brasil (r*=2.5%, κ=0.35)
- Rode simulação: EUA (r*=1.0%, κ=0.25)
- Compare persistência inflacionária
```

---

## 🔄 Atualizações Recentes

### v2.2 (Jun/2026) - ATUAL
- ✅ Aba de comparação de 2 países (choque comum, trajetórias sobrepostas)
- ✅ Aba de IRFs (funções de resposta a impulso)
- ✅ Export de gráficos em alta resolução (PNG/PDF)

### v2.1 (Mai/2026)
- ✅ App refatorada do `qpm.R` monolítico para a estrutura Shiny padrão (`app.R` / `global.R` / `ui.R` / `server.R`)
- ✅ Métricas de crescimento do PIB trimestral (QoQ) e anual (YoY) na engine
- ✅ Tabela de projeções migrada para `DT` (interativa, com paginação e scroll)
- ✅ Protótipo standalone original movido para `prototype/`

### v2.0 (18/Nov/2025)
- ✅ Dashboard reestruturado com cards de métricas
- ✅ Gráficos individuais maiores e mais detalhados
- ✅ Tema visual customizado (theme_qpm)
- ✅ Integração de presets de países
- ✅ Seletor automático + botão de carregamento
- ✅ Notificações visuais de sucesso

### v1.0 (Inicial)
- Simulador básico QPM
- Interface com parâmetros manuais
- Gráficos em painel único (patchwork)
- Aba de instruções

---

## 🛠️ Desenvolvimento

### Roadmap Futuro

Itens já entregues (aba de comparação de países, export PNG/PDF, aba de IRFs)
estão registrados no [`CHANGELOG.md`](CHANGELOG.md). Pendências em aberto:

**Conteúdo / dados**
- [ ] Séries históricas reais de PIB potencial (CSVs OECD/FMI por país)
- [ ] Biblioteca de cenários históricos pré-configurados (crises)

**UX**
- [ ] Tooltips nos parâmetros e exemplos de preset na aba Instruções
- [ ] Quick-start guide interativo

**Internacionalização**
- [ ] Interface multilíngue (PT/EN/ES)

### Contribuindo

Para adicionar novos países:
1. Pesquise literatura acadêmica (Working Papers de BCs)
2. Adicione linha em `presets/countries_parameters.csv`
3. Documente fontes em `presets/PARAMETERS_GUIDE.md`
4. Teste calibração com simulações

---

## 📞 Suporte e Documentação

### Principais Documentos
- **Este README**: Visão geral e uso básico
- **`presets/README.md`**: Guia completo de presets
- **`presets/PARAMETERS_GUIDE.md`**: Fundamentação técnica
- **`presets/INTEGRATION_PROPOSAL.md`**: Features planejadas

### Contato
Para questões técnicas ou sugestões, consulte a documentação acima ou abra uma issue.

---

## ⚖️ Licença e Avisos

### Uso Acadêmico
Este simulador é uma ferramenta **educacional e demonstrativa**. Não substitui modelos oficiais de bancos centrais para decisões de política monetária real.

### Limitações
- Expectativas são backward-looking/híbridas (não totalmente racionais)
- Parâmetros calibrados (não estimados por máxima verossimilhança)
- Modelo linearizado (sem não-linearidades)
- Economia fechada simplificada

### Citação Sugerida
```
Simulador QPM - Quarterly Projection Model
Baseado em Berg, Karam & Laxton (2006) e literatura subsequente
Versão 2.2 - Junho 2026
```

---

**Desenvolvido com**: R + Shiny + ggplot2 + patchwork + DT + renv  
**Última Atualização**: 19 de Junho de 2026  
**Versão**: 2.2 (Stable)  
**Status**: ✅ Produção
