# Simulador QPM - Quarterly Projection Model

## 📊 Project Overview
This project is an interactive **R Shiny application** designed for simulating and analyzing **Quarterly Projection Models (QPM)**. These models are standard tools used by central banks for monetary policy analysis and macroeconomic scenario building.

The simulator includes:
- **Core Economic Equations:** IS Curve (Aggregate Demand), Phillips Curve (Inflation Dynamics), Taylor Rule (Monetary Policy), and Real Exchange Rate (Modified UIP).
- **Country Presets:** Pre-calibrated parameters for Brazil, Chile, Peru, Colombia, Mexico, and the USA.
- **Interactive Dashboard:** Modern UI with metric cards, detailed projection charts (Inflation, Interest Rates, Output Gap, GDP, Exchange Rate), and data tables.
- **Scenario Analysis:** Support for point shocks, exogenous series uploads (PIB Potential, r*, i*), and different expectation formation modes (Adaptive, Naive, Hybrid).

## 🛠️ Main Technologies
- **Language:** R
- **Framework:** Shiny
- **Data Manipulation:** `dplyr`, `tidyr`, `readr`
- **Visualization:** `ggplot2`, `patchwork`
- **Dependency Management:** `renv`
- **Styling:** Custom CSS (`www/petrobras.css`)

## 🚀 Building and Running
### Prerequisites
Ensure you have R installed (v4.4.1 recommended). The project uses `renv` for isolated package management.

### Installation
Restore the environment dependencies:
```r
renv::restore()
```

### Running the App
Execute the following command in your terminal:
```powershell
Rscript.exe -e "shiny::runApp('qpm.R')"
```
*Note: The app is configured to run locally on http://127.0.0.1:4481 by default (as per README).*

## 📁 Key Files and Directories
- `qpm.R`: The main application file containing both UI and Server logic.
- `presets/`:
    - `countries_parameters.csv`: Calibrated parameters for supported countries.
    - `PARAMETERS_GUIDE.md`: Technical documentation on parameters and equations.
    - `INTEGRATION_PROPOSAL.md`: Planned features and roadmap.
- `www/petrobras.css`: Custom theme and styling.
- `INSTRUCOES_REESTRUTURACAO.md`: Manual instructions for UI/Server code blocks (useful for refactoring).
- `renv.lock`: Locked versions of all R package dependencies.

## ⚖️ Development Conventions
- **Style:** Follow the **Tidyverse Style Guide** (https://style.tidyverse.org/).
- **Equations:** The model uses discrete-time equations for the 4 core pillars (IS, Phillips, Taylor, Exchange).
- **Documentation:** Maintain technical details in `presets/PARAMETERS_GUIDE.md` when updating model parameters.
- **Testing:** New country calibrations should be validated against academic literature before being added to `countries_parameters.csv`.

## 🔄 Recent Updates
- **v2.0 (Stable):** Re-structured dashboard with metric cards, individual charts, and integrated country presets.
- **Presets Integration:** Added automatic loading of calibrated parameters for major economies.
