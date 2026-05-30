# prototype/

Scripts exploratórios que **não** fazem parte da aplicação Shiny modular.

- `qpm_standalone.R` — protótipo original do simulador QPM em R puro. Roda um
  cenário hardcoded e plota as variáveis com `patchwork` direto no console.
  Foi o ponto de partida da engine que hoje vive em `../global.R`
  (`simulate_qpm()`), já com choques corrigidos e métricas de crescimento
  QoQ/YoY. Mantido só como referência histórica.

Para o simulador interativo, rode na raiz do projeto:

```r
shiny::runApp('.')
```
