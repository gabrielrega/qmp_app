# Guia de Parâmetros por País - QPM

## Fonte dos Parâmetros

Os parâmetros foram calibrados com base em literatura acadêmica sobre modelos QPM (Quarterly Projection Models) e DSGE Novo-Keynesianos para economias da América Latina e economias avançadas.

### Principais Fontes:
- FMI Working Papers sobre QPMs para economias emergentes
- Banco Central do Chile (CBOC) - Modelos XMAS e MEP
- Estudos sobre persistência inflacionária na América Latina
- Literatura sobre modelos DSGE calibrados para Brasil, Chile, Peru, Colômbia e México

---

## Descrição dos Parâmetros por País

### 🇧🇷 **Brasil**
- **β (beta) = 0.65**: Inflação com componente backward-looking significativo devido ao histórico de alta inflação
- **κ (kappa) = 0.35**: Alta sensibilidade da inflação ao hiato (pressões de demanda)
- **φ (phi) = 0.55**: Sensibilidade moderada do hiato à taxa de juros
- **γ (gamma) = 0.35**: Inércia moderada-alta do hiato
- **ρ (rho) = 0.75**: Alta suavização de juros pelo BC
- **απ (alpha_pi) = 1.8**: Resposta forte à inflação (Princípio de Taylor)
- **αy (alpha_y) = 0.6**: Peso moderado no hiato
- **r* = 2.5%**: Taxa neutra real historicamente elevada
- **π* = 3.0%**: Meta de inflação oficial
- **ψ (psi) = 0.30**: Pass-through cambial moderado
- **θ (theta) = 0.65**: Persistência cambial alta

**Características**: Economia com histórico de alta inflação, meta de 3% com banda de tolerância, BC independente desde 1999, forte suavização de juros.

---

### 🇨🇱 **Chile**
- **β (beta) = 0.70**: Maior peso forward-looking nas expectativas
- **κ (kappa) = 0.28**: Sensibilidade moderada da inflação ao hiato
- **φ (phi) = 0.60**: Alta eficácia da política monetária
- **γ (gamma) = 0.30**: Inércia do hiato moderada
- **ρ (rho) = 0.70**: Suavização de juros moderada
- **απ (alpha_pi) = 1.6**: Resposta à inflação moderada-forte
- **αy (alpha_y) = 0.7**: Peso significativo no hiato (mandato dual)
- **r* = 1.5%**: Taxa neutra real mais baixa
- **π* = 3.0%**: Meta de inflação
- **ψ (psi) = 0.25**: Pass-through cambial baixo
- **θ (theta) = 0.60**: Persistência cambial moderada

**Características**: Pioneiro em IT na América Latina (1990), economia mais estável, forte credibilidade do BC, mandato dual mais explícito.

---

### 🇵🇪 **Peru**
- **β (beta) = 0.68**: Expectativas com componente adaptativo relevante
- **κ (kappa) = 0.32**: Sensibilidade moderada-alta ao hiato
- **φ (phi) = 0.50**: Eficácia da política monetária moderada
- **γ (gamma) = 0.32**: Inércia moderada
- **ρ (rho) = 0.72**: Alta suavização
- **απ (alpha_pi) = 1.7**: Resposta forte à inflação
- **αy (alpha_y) = 0.55**: Peso moderado no hiato
- **r* = 2.0%**: Taxa neutra moderada
- **π* = 2.0%**: Meta de inflação mais baixa
- **ψ (psi) = 0.28**: Pass-through moderado (economia parcialmente dolarizada)
- **θ (theta) = 0.62**: Persistência cambial moderada-alta

**Características**: Economia parcialmente dolarizada, meta de 2% com banda de ±1pp, IT desde 2002, estrutura adaptada para dolarização.

---

### 🇨🇴 **Colômbia**
- **β (beta) = 0.66**: Componente backward-looking relevante
- **κ (kappa) = 0.33**: Sensibilidade moderada-alta
- **φ (phi) = 0.52**: Eficácia moderada da política
- **γ (gamma) = 0.33**: Inércia moderada
- **ρ (rho) = 0.74**: Alta suavização
- **απ (alpha_pi) = 1.75**: Resposta forte à inflação (IT estrito)
- **αy (alpha_y) = 0.50**: Peso moderado-baixo no hiato
- **r* = 3.0%**: Taxa neutra elevada
- **π* = 3.0%**: Meta de inflação
- **ψ (psi) = 0.27**: Pass-through moderado
- **θ (theta) = 0.63**: Persistência cambial moderada-alta

**Características**: IT desde 1999, economia dependente de commodities (petróleo, café), política de IT estrita.

---

### 🇲🇽 **México**
- **β (beta) = 0.72**: Expectativas mais forward-looking (integração com EUA)
- **κ (kappa) = 0.30**: Sensibilidade moderada
- **φ (phi) = 0.58**: Boa eficácia da política monetária
- **γ (gamma) = 0.28**: Inércia relativamente baixa
- **ρ (rho) = 0.68**: Suavização moderada
- **απ (alpha_pi) = 1.5**: Resposta moderada (princípio de Taylor)
- **αy (alpha_y) = 0.75**: Peso alto no hiato (mandato dual implícito)
- **r* = 2.5%**: Taxa neutra moderada
- **π* = 3.0%**: Meta de inflação
- **ψ (psi) = 0.22**: Pass-through relativamente baixo
- **θ (theta) = 0.58**: Persistência cambial moderada

**Características**: Economia integrada com EUA (USMCA), IT desde 2001, maior peso na estabilização do produto.

---

### 🇺🇸 **EUA (Referência)**
- **β (beta) = 0.75**: Expectativas fortemente forward-looking
- **κ (kappa) = 0.25**: Baixa sensibilidade ao hiato (rigidez de preços)
- **φ (phi) = 0.65**: Alta eficácia da política monetária
- **γ (gamma) = 0.25**: Baixa inércia
- **ρ (rho) = 0.80**: Suavização alta (gradualism)
- **απ (alpha_pi) = 1.5**: Resposta padrão de Taylor
- **αy (alpha_y) = 0.80**: Peso alto no hiato (mandato dual explícito)
- **r* = 1.0%**: Taxa neutra real baixa
- **π* = 2.0%**: Meta de inflação do Fed
- **ψ (psi) = 0.15**: Pass-through muito baixo (economia fechada)
- **θ (theta) = 0.50**: Persistência cambial baixa

**Características**: Economia avançada, mandato dual do Fed, expectativas bem ancoradas, mercados financeiros profundos.

---

## Notas Metodológicas

### Calibração dos Parâmetros

1. **β (beta) - Peso Forward-Looking**: 
   - Economias emergentes: 0.65-0.72 (maior componente adaptativo)
   - Economias avançadas: 0.75+ (expectativas racionais dominantes)

2. **κ (kappa) - Sensibilidade da Inflação ao Hiato**:
   - Valores típicos: 0.25-0.35
   - Maior em economias com rigidez de preços menor (emergentes)

3. **φ (phi) - Sensibilidade do Hiato à Taxa Real**:
   - 0.50-0.65 (eficácia da transmissão monetária)
   - Maior em economias com mercados financeiros profundos

4. **γ (gamma) - Inércia do Hiato**:
   - 0.25-0.35 (persistência dos desvios do produto)

5. **ρ (rho) - Suavização de Juros**:
   - 0.65-0.80 (BCs ajustam juros gradualmente)
   - Maior em economias desenvolvidas

6. **απ (alpha_pi) - Resposta à Inflação**:
   - Deve ser > 1 (Princípio de Taylor)
   - IT estritos: 1.7-1.8
   - IT flexíveis: 1.5-1.6

7. **αy (alpha_y) - Resposta ao Hiato**:
   - Mandato dual explícito: 0.7-0.8
   - IT estrito: 0.5-0.6

8. **r* - Taxa Neutra Real**:
   - Varia com nível de desenvolvimento, demografia, produtividade
   - Emergentes: 2-3%
   - Avançados: 0.5-1.5%

9. **ψ (psi) - Pass-through Cambial**:
   - Economias abertas emergentes: 0.25-0.30
   - Economias avançadas/fechadas: 0.10-0.20

10. **θ (theta) - Persistência Cambial**:
    - 0.50-0.65 (velocidade de ajuste do câmbio real)

---

## Referências

- Berg, A., Karam, P., & Laxton, D. (2006). A Practical Model-Based Approach to Monetary Policy Analysis - Overview. IMF Working Paper.
- Medina, J. P., & Soto, C. (2007). The Chilean Business Cycles Through the Lens of a Stochastic General Equilibrium Model. Central Bank of Chile Working Papers.
- Salas, J. (2010). A QPM for Peru. Universidad de Munich.
- Alves, S. A. L. (2014). Lack of Divine Coincidence in New Keynesian Models. Journal of Monetary Economics.
- Banco Central do Chile - Modelos de Política Monetária (XMAS e MEP) [Documentation].
