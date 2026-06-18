# Changelog

Todas as mudanças notáveis deste projeto são documentadas aqui.
Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/);
versionamento conforme [SemVer](https://semver.org/lang/pt-BR/).

## [Não lançado]

## [2.2.0] - 2026-06-18
### Adicionado
- Aba "Comparação de Países": sobrepõe as trajetórias de dois países num choque
  comum (inflação, juros, hiato e câmbio), com tabela de diferenças de resposta e
  download em CSV. Cada economia parte do seu próprio estado estacionário, isolando
  as diferenças estruturais.
- Helper `run_country_sim()` na engine para simular um país a partir dos seus
  parâmetros calibrados e estado estacionário.
- Aba "IRFs": funções de resposta a impulso que mostram a resposta dinâmica de
  cada variável (como desvio do estado estacionário) a um choque único, por país
  preset ou parâmetros personalizados; com download em CSV.
- Export de gráficos em alta resolução (PNG/PDF, com largura/altura/DPI
  configuráveis) nas abas Simulação, Comparação e IRFs, incluindo painel completo.

## [2.1.0] - 2026-05-29
### Modificado
- App refatorada do `qpm.R` monolítico para a estrutura Shiny padrão (`app.R` / `global.R` / `ui.R` / `server.R`).
- Tabela de projeções migrada para `DT` (interativa, com paginação e scroll).

### Adicionado
- Métricas de crescimento do PIB trimestral (QoQ) e anual (YoY) na engine.
- Protótipo standalone original movido para `prototype/`.
- Snapshot de `DT` e dependências no `renv.lock`.

## [2.0.0] - 2025-11-18
### Adicionado
- Dashboard reestruturado com cards de métricas-chave.
- Gráficos individuais maiores e mais detalhados.
- Tema visual customizado (`theme_qpm`).
- Integração de presets de países (Brasil, Chile, Peru, Colômbia, México, EUA).
- Seletor de país com botão de carregamento e notificações visuais de sucesso.
- Documentação técnica dos parâmetros em `presets/PARAMETERS_GUIDE.md`.

### Modificado
- README abrangente com documentação da v2.0.

## [1.0.0] - 2025-11-18
### Adicionado
- Versão inicial do simulador QPM em Shiny com ambiente `renv`.
- Interface com parâmetros manuais (β, κ, φ, γ, ρ, απ, αy, r*, π*, ψ, θ).
- Modelo de 4 equações: Curva IS, Curva de Phillips, Regra de Taylor e câmbio real (UIP modificada).
- Gráficos em painel único (patchwork).
- Aba de instruções com explicação dos parâmetros e guia de uso.
