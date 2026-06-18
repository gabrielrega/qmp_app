# global.R - Shared functions and data for QPM Simulator
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)
library(readr)

# ---------------------------
# Simulador QPM Engine
# ---------------------------
simulate_qpm <- function(params, state0, T = 40,
                         expectation = c("adaptive","naive","hybrid"),
                         lambda = 0.7,
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
  if (!is.null(shocks$y))  eps_y[shocks$y["time"] + 1]   <- shocks$y["value"]
  if (!is.null(shocks$pi)) eps_pi[shocks$pi["time"] + 1] <- shocks$pi["value"]
  if (!is.null(shocks$i))  eps_i[shocks$i["time"] + 1]   <- shocks$i["value"]
  if (!is.null(shocks$q))  eps_q[shocks$q["time"] + 1]   <- shocks$q["value"]
  
  for (t in 1:T) {
    # Expectativas
    if (expectation == "adaptive" || expectation == "naive") {
      exp_pi <- pi[t]; exp_y <- y[t]
    } else if (expectation == "hybrid") {
      exp_pi <- lambda * pi[t] + (1 - lambda) * params$pi_star
      exp_y  <- y[t]
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
  
  # Calcular crescimentos
  g_qoq <- c(NA, diff(PIB_abs) / PIB_abs[-length(PIB_abs)] * 100)
  
  # YoY: Soma de 4 trimestres vs soma dos 4 anteriores
  # (Acumulado 12 meses vs acumulado 12 meses anterior)
  g_yoy <- rep(NA, T+1)
  if (T >= 7) {
    for (t in 8:(T+1)) {
      sum_last_4 <- sum(PIB_abs[t:(t-3)])
      sum_prev_4 <- sum(PIB_abs[(t-4):(t-7)])
      g_yoy[t] <- (sum_last_4 / sum_prev_4 - 1) * 100
    }
  }
  
  tibble(
    period     = 0:T,
    y          = y,
    PIB_pot    = PIB_pot_ts,
    PIB_abs    = PIB_abs,
    g_qoq      = g_qoq,
    g_yoy      = g_yoy,
    pi         = pi,
    i          = i,
    q          = q,
    q_abs      = q_abs
  )
}

# ---------------------------
# Helper para comparação entre países
# ---------------------------
# Roda uma simulação para um país a partir do seu próprio estado estacionário
# (hiato 0, inflação na meta, juros na taxa neutra, câmbio na base), de modo a
# isolar as diferenças estruturais da resposta a um choque comum.
run_country_sim <- function(cparams, T = 40,
                            expectation = "hybrid", lambda = 0.6,
                            shock = list(),
                            PIB_base = 1000, PIB_growth = 0, q_base = 100) {
  params <- list(
    beta = cparams$beta, kappa = cparams$kappa, phi = cparams$phi,
    gamma = cparams$gamma, rho = cparams$rho, alpha_pi = cparams$alpha_pi,
    alpha_y = cparams$alpha_y, r_star = cparams$r_star,
    pi_star = cparams$pi_star, psi = cparams$psi, theta = cparams$theta
  )

  # Estado inicial = estado estacionário do próprio país
  state0 <- c(
    y  = 0,
    pi = params$pi_star,
    i  = params$r_star + params$pi_star,
    q  = 0
  )

  PIB_pot_ts <- PIB_base * (1 + PIB_growth)^(0:T)

  simulate_qpm(
    params = params, state0 = state0, T = T,
    expectation = expectation, lambda = lambda,
    shocks = shock, PIB_pot_ts = PIB_pot_ts,
    PIB_base = PIB_base, q_base = q_base
  )
}

# ---------------------------
# Global Data Loading
# ---------------------------
preset_path <- "presets/countries_parameters.csv"
if (file.exists(preset_path)) {
  countries_params <- read_csv(preset_path, show_col_types = FALSE)
} else {
  countries_params <- tibble(
    country = character(), beta = numeric(), kappa = numeric(), 
    phi = numeric(), gamma = numeric(), rho = numeric(), 
    alpha_pi = numeric(), alpha_y = numeric(), r_star = numeric(), 
    pi_star = numeric(), psi = numeric(), theta = numeric()
  )
}
