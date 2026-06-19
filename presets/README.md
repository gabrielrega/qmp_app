# 📊 Presets de Países para o Simulador QPM

## ✅ O que foi criado

### 1. Parâmetros Calibrados (`countries_parameters.csv`)
Arquivo CSV com parâmetros para 6 economias:
- 🇧🇷 **Brasil** - Economia emergente com histórico inflacionário
- 🇨🇱 **Chile** - PIoneiro IT na América Latina
- 🇵🇪 **Peru** - Economia parcialmente dolarizada
- 🇨🇴 **Colômbia** - IT forte, economia commodity-dependente
- 🇲🇽 **México** - Integração com EUA (USMCA)
- 🇺🇸 **EUA** - Economia avançada (referência)

### 2. Documentação Técnica (`PARAMETERS_GUIDE.md`)
- Explicação detalhada de cada parâmetro por país
- Justificativas baseadas em literatura acadêmica
- Referências bibliográficas (IMF, BCs, papers peer-reviewed)
- Notas metodológicas sobre calibração

### 3. Proposta de Integração (`INTEGRATION_PROPOSAL.md`)
Três opções de implementação:
- **Opção 1**: Seletor simples com botão "Carregar Preset" ⭐ **RECOMENDADO**
- **Opção 2**: Aba de comparação lado a lado
- **Opção 3**: Biblioteca de cenários históricos

### 4. Exemplo de Série Temporal (`brasil_pib_potencial_exemplo.csv`)
Série exemplo de PIB potencial crescendo 0.5% por trimestre

---

## 📋 Resumo dos Parâmetros por País

| País | β | κ | φ | γ | ρ | απ | αy | r* | π* |
|------|---|---|---|---|---|-----|----|----|-----|
| Brasil | 0.65 | 0.35 | 0.55 | 0.35 | 0.75 | 1.8 | 0.6 | 2.5% | 3.0% |
| Chile | 0.70 | 0.28 | 0.60 | 0.30 | 0.70 | 1.6 | 0.7 | 1.5% | 3.0% |
| Peru | 0.68 | 0.32 | 0.50 | 0.32 | 0.72 | 1.7 | 0.55 | 2.0% | 2.0% |
| Colômbia | 0.66 | 0.33 | 0.52 | 0.33 | 0.74 | 1.75 | 0.50 | 3.0% | 3.0% |
| México | 0.72 | 0.30 | 0.58 | 0.28 | 0.68 | 1.5 | 0.75 | 2.5% | 3.0% |
| EUA | 0.75 | 0.25 | 0.65 | 0.25 | 0.80 | 1.5 | 0.80 | 1.0% | 2.0% |

**Legenda:**
- **β** = Peso forward-looking (expectativas)
- **κ** = Sensibilidade inflação ao hiato
- **φ** = Sensibilidade hiato à taxa real
- **γ** = Inércia do hiato
- **ρ** = Suavização de juros
- **απ** = Resposta do BC à inflação
- **αy** = Resposta do BC ao hiato
- **r*** = Taxa neutra real
- **π*** = Meta de inflação

---

## 🎯 Principais Diferenças

### Economias Emergentes (BR, CL, PE, CO, MX)
- **Expectativas mais adaptativas** (β = 0.65-0.72)
- **Maior sensibilidade da inflação** (κ = 0.28-0.35)
- **Taxas neutras mais altas** (r* = 1.5-3.0%)
- **Pass-through cambial significativo** (ψ = 0.22-0.30)

### Economia Avançada (EUA)
- **Expectativas racionais dominantes** (β = 0.75)
- **Menor sensibilidade da inflação** (κ = 0.25)
- **Taxa neutra baixa** (r* = 1.0%)
- **Pass-through cambial mínimo** (ψ = 0.15)

---

## 🚀 Como Usar

No app, na barra lateral:
1. Selecione o país no dropdown "🌍 Calibrações de Países"
2. Clique em "Carregar Preset"
3. Todos os parâmetros são preenchidos automaticamente
4. Rode a simulação

> Para usar os valores fora do app, abra `countries_parameters.csv` diretamente.

---

## 📚 Fontes Acadêmicas

### Principais Referências
1. **Berg, Karam & Laxton (2006)** - "A Practical Model-Based Approach to Monetary Policy Analysis", IMF WP/06/80
2. **Medina & Soto (2007)** - "The Chilean Business Cycles Through the Lens of a Stochastic General Equilibrium Model", CBC Working Papers N° 457
3. **Salas (2010)** - "A QPM for Peru: A Model for Monetary Policy Analysis", Ludwig-Maximilians University
4. **Alves (2014)** - "Lack of Divine Coincidence in New Keynesian Models", Journal of Monetary Economics
5. **Banco Central do Chile** - Modelos de Política Monetária (XMAS e MEP)

### Dados Complementares
- OECD Economic Outlook (PIB Potencial)
- IMF World Economic Outlook
- Relatórios de Inflação dos Bancos Centrais

---

## 🔮 Roadmap

A integração dos presets no app está **concluída**: seletor + carregamento
automático + notificações desde a v2.0, e aba de comparação de países + IRFs na
v2.2. O roadmap consolidado e as pendências em aberto vivem no
[`../README.md`](../README.md); o histórico de versões, no
[`../CHANGELOG.md`](../CHANGELOG.md).

---

## 📁 Estrutura de Arquivos

```
presets/
├── countries_parameters.csv              # Parâmetros calibrados
├── PARAMETERS_GUIDE.md                   # Documentação técnica
├── INTEGRATION_PROPOSAL.md               # Proposta de implementação
├── brasil_pib_potencial_exemplo.csv      # Exemplo de série temporal
└── README.md                             # Este arquivo
```

---

## 🤝 Contribuições

Para adicionar novos países ou atualizar parâmetros:

1. **Pesquise a literatura** - Working papers de BCs, artigos peer-reviewed
2. **Documente as fontes** - Adicione referências no PARAMETERS_GUIDE.md
3. **Adicione ao CSV** - Inclua linha nova em countries_parameters.csv
4. **Teste a calibração** - Rode simulações e valide IRFs (Impulse Response Functions)

---

## ⚠️ Avisos Importantes

### Limitações do Modelo
- QPM é um modelo **simplificado** comparado a DSGE completos
- Expectativas são **backward-looking ou híbridas**, não totalmente racionais
- Alguns parâmetros foram **calibrados** (não estimados econometricamente)

### Uso Recomendado
- ✅ Análise educacional e demonstrativa
- ✅ Comparação estrutural entre economias
- ✅ Ponto de partida para calibrações customizadas
- ❌ Não substitui modelos oficiais de BCs para decisões reais

---

## 📞 Suporte

Para dúvidas sobre:
- **Parâmetros específicos**: Ver `PARAMETERS_GUIDE.md`
- **Implementação**: Ver `INTEGRATION_PROPOSAL.md`
- **Literatura acadêmica**: Ver seção "Fontes Acadêmicas" acima

---

**Última Atualização**: 19 de Junho de 2026  
**Status**: Presets integrados no app (v2.0+); roadmap consolidado no README raiz
