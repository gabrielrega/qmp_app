# CLAUDE.md — qmp_app

Guia para o Claude Code neste repositório. As convenções gerais da pasta `projetos` valem aqui; detalhes do projeto no `README.md`.

## Ficha

- **Pergunta**: Como um banco central responde a choques num QPM (IS, Phillips, Taylor, UIP), por país?
- **Status**: v2.3.0, ativo e online em shinyapps.io.
- **Entradas**: Parâmetros calibrados por país (presets no app).
- **Saídas**: App Shiny com projeções e cenários; deploy em https://gabrielrega.shinyapps.io/qmp_app/.
- **Rodar**: `Rscript -e "shiny::runApp()"`; deploy só pelo PowerShell.
- **Pronto quando**: App roda local sem erro em todos os presets e o deploy responde.
