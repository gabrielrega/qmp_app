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
