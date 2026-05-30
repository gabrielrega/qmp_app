# =============================================================================
# PROTÓTIPO STANDALONE — script exploratório original (NÃO é a app Shiny).
# Roda um exemplo hardcoded e gera os gráficos em patchwork direto no console.
# A engine `simulate_qpm()` foi portada e evoluída em `global.R` (com choques
# corrigidos e métricas g_qoq/g_yoy). Mantido apenas como referência histórica.
# Para usar o simulador interativo: shiny::runApp('.') na raiz do projeto.
# =============================================================================
# QPM discreto (correção do erro 'pi_lead' usando simulação iterativa)
# Requer: install.packages(c("dplyr","ggplot2","tidyr"))

library(dplyr)
library(ggplot2)
library(tidyr)

# ---------------------------
# 1) Parâmetros (calibragem)
# ---------------------------
params <- list(
  beta = 0.7,     # forward weight na Phillips (usado em forma híbrida)
  kappa = 0.3,    # sensibilidade da inflação ao hiato
  phi = 0.5,      # sensibilidade da demanda à taxa real (positivo)
  gamma = 0.3,    # inércia/inércia na demanda (peso sobre o hiato atual)
  rho = 0.7,      # inércia na taxa de juros (regra de Taylor)
  alpha_pi = 1.5, # resposta da política à inflação
  alpha_y = 0.5,  # resposta da política ao hiato
  r_star = 1.0,   # taxa neutra (real) %
  pi_star = 3.0,  # meta de inflação %
  psi = 0.25,     # sensibilidade câmbio real ao diferencial de juros
  theta = 0.6     # persistência câmbio real
)

# ---------------------------
# 2) Estado inicial
# ---------------------------
state0 <- c(y = 0.0,   # hiato inicial (%)
            pi = 3.0,  # inflação inicial (%)
            i = 4.5,   # taxa nominal inicial (%)
            q = 0.0)   # câmbio real (desvio)

# ---------------------------
# 3) Simulador discreto
# ---------------------------
simulate_qpm <- function(params, state0, T = 40,
                         expectation = c("adaptive","naive","hybrid"),
                         lambda = 0.7,  # peso da parte adaptativa no modo híbrido
                         i_star_ts = NULL,
                         r_star_ts = NULL,
                         shocks = list(),
                         PIB_pot_ts = NULL,
                         PIB_base = 1000,
                         q_base   = 100) {
  
  expectation <- match.arg(expectation)
  
  if (is.null(i_star_ts)) i_star_ts <- rep(params$r_star, T+1)
  if (is.null(r_star_ts)) r_star_ts <- rep(params$r_star, T+1)
  if (is.null(PIB_pot_ts)) PIB_pot_ts <- rep(PIB_base, T+1)
  
  y <- numeric(T+1); pi <- numeric(T+1); i <- numeric(T+1); q <- numeric(T+1)
  y[1] <- state0["y"]; pi[1] <- state0["pi"]; i[1] <- state0["i"]; q[1] <- state0["q"]
  
  eps_y <- numeric(T+1); eps_pi <- numeric(T+1); eps_i <- numeric(T+1); eps_q <- numeric(T+1)
  if (!is.null(shocks$y)) eps_y[shocks$y["time"]] <- shocks$y["value"]
  if (!is.null(shocks$pi)) eps_pi[shocks$pi["time"]] <- shocks$pi["value"]
  if (!is.null(shocks$i)) eps_i[shocks$i["time"]] <- shocks$i["value"]
  if (!is.null(shocks$q)) eps_q[shocks$q["time"]] <- shocks$q["value"]
  
  for (t in 1:T) {
    # Formação de expectativas
    if (expectation == "adaptive") {
      exp_pi <- pi[t]
      exp_y  <- y[t]
    } else if (expectation == "naive") {
      exp_pi <- pi[t]
      exp_y  <- y[t]
    } else if (expectation == "hybrid") {
      # híbrido: parte adaptativa + parte ancorada na meta
      exp_pi <- lambda * pi[t] + (1 - lambda) * params$pi_star
      exp_y  <- y[t] # mantemos hiato adaptativo por simplicidade
    }
    
    # 1) IS
    y[t+1]  <- params$gamma * y[t] - params$phi * ( i[t] - exp_pi - r_star_ts[t] ) + eps_y[t+1]
    # 2) Phillips
    pi[t+1] <- params$beta * exp_pi + (1 - params$beta) * pi[t] + params$kappa * y[t+1] + eps_pi[t+1]
    # 3) Taylor
    i[t+1]  <- params$rho * i[t] + (1 - params$rho) * (
      r_star_ts[t+1] + params$pi_star +
        params$alpha_pi * (pi[t+1] - params$pi_star) +
        params$alpha_y * y[t+1]
    ) + eps_i[t+1]
    # 4) Câmbio real
    q[t+1]  <- params$theta * q[t] + params$psi * ( i[t+1] - i_star_ts[t+1] ) + eps_q[t+1]
  }
  
  PIB_abs <- PIB_pot_ts * (1 + y/100)
  q_abs   <- q_base * (1 + q/100)
  
  tibble(
    period     = 0:T,
    y          = y,
    PIB_pot    = PIB_pot_ts,
    PIB_abs    = PIB_abs,
    pi         = pi,
    i          = i,
    q          = q,
    q_abs      = q_abs
  )
}

# ---------------------------
# 4) Exemplo de execução
# ---------------------------
T <- 40          # 40 períodos (ex.: trimestres)
# inserir um choque monetário contracionista de +1 pp em i no período 6
shocks <- list(i = c(time = 3, value = 0.0))

# Exemplo: PIB potencial crescendo 2% ao ano (~0,5% ao trimestre)
PIB_pot_ts <- 1000 * (1.005)^(0:T)

sim <- simulate_qpm(params = params, state0 = state0, T = T,
                    expectation = "hybrid", lambda = 0.6,
                    shocks = shocks,
                    PIB_pot_ts = PIB_pot_ts)

# ---------------------------
# 5) Visualizar principais variáveis (níveis absolutos e desvios)
# ---------------------------

# Seleciona variáveis-chave
sim_main <- sim %>%
  select(period, PIB_abs, pi, i, q_abs) %>%
  pivot_longer(-period, names_to = "var", values_to = "value")

# Cria gráfico com linhas de referência para inflação e juros
ggplot(sim_main, aes(x = period, y = value, color = var)) +
  geom_line(size = 1.2) +
  facet_wrap(~var, scales = "free_y", ncol = 1,
             labeller = as_labeller(c(
               PIB_abs = "PIB Absoluto (bilhões)",
               pi      = "Inflação (%)",
               i       = "Taxa de Juros Nominal (%)",
               q_abs   = "Câmbio Real Absoluto (índice)"
             ))) +
  # Linhas de referência
  geom_hline(data = data.frame(var = "pi", yint = params$pi_star),
             aes(yintercept = yint), linetype = "dashed", color = "black") +
  geom_hline(data = data.frame(var = "i", yint = params$r_star + params$pi_star),
             aes(yintercept = yint), linetype = "dashed", color = "black") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Projeções das Principais Variáveis Econômicas",
    subtitle = "Simulação QPM discreto (níveis absolutos e metas)",
    x = "Período",
    y = "Valor"
  ) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "none"
  )

library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)

# Painel 1: PIB potencial vs PIB absoluto
p1 <- ggplot(sim, aes(x = period)) +
  geom_line(aes(y = PIB_pot, color = "PIB Potencial"), size = 1.2) +
  geom_line(aes(y = PIB_abs, color = "PIB Absoluto"), size = 1.2) +
  scale_color_manual(values = c("PIB Potencial" = "blue", "PIB Absoluto" = "red")) +
  labs(title = "PIB Potencial vs PIB Absoluto",
       x = "Período", y = "Valor (bilhões)", color = "") +
  theme_minimal(base_size = 14)

# Painel 2: Hiato do produto
p2 <- ggplot(sim, aes(x = period, y = y)) +
  geom_line(color = "darkgreen", size = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
  labs(title = "Hiato do Produto",
       x = "Período", y = "Desvio (%)") +
  theme_minimal(base_size = 14)

# Painel 3: Inflação
p3 <- ggplot(sim, aes(x = period, y = pi)) +
  geom_line(color = "firebrick", size = 1.2) +
  geom_hline(yintercept = params$pi_star, linetype = "dashed", color = "black") +
  labs(title = "Inflação (%)",
       x = "Período", y = "Valor") +
  theme_minimal(base_size = 14)

# Painel 4: Taxa de juros nominal
p4 <- ggplot(sim, aes(x = period, y = i)) +
  geom_line(color = "purple", size = 1.2) +
  geom_hline(yintercept = params$r_star + params$pi_star,
             linetype = "dashed", color = "black") +
  labs(title = "Taxa de Juros Nominal (%)",
       x = "Período", y = "Valor") +
  theme_minimal(base_size = 14)

# Painel 5: Câmbio real absoluto
p5 <- ggplot(sim, aes(x = period, y = q_abs)) +
  geom_line(color = "orange", size = 1.2) +
  labs(title = "Câmbio Real Absoluto (índice)",
       x = "Período", y = "Valor") +
  theme_minimal(base_size = 14)

# Combina todos os painéis
(p1 / p2) / (p3 / p4 / p5)
