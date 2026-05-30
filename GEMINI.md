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
- **Visualization:** `ggplot2`, `patchwork`, `DT` (interactive projections table)
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
Rscript.exe -e "shiny::runApp('.')"
```
*Note: The app is configured to run locally on http://127.0.0.1:4481 by default (as per README).*

## 📁 Key Files and Directories
- `app.R`: Main entry point that connects UI and Server.
- `ui.R`: User Interface layout and components.
- `server.R`: Server-side logic and reactive computations.
- `global.R`: Simulation engine and global data loading.
- `presets/`:
    - `countries_parameters.csv`: Calibrated parameters for supported countries.
    - `PARAMETERS_GUIDE.md`: Technical documentation on parameters and equations.
    - `INTEGRATION_PROPOSAL.md`: Planned features and roadmap.
- `www/petrobras.css`: Custom theme and styling.
- `prototype/qpm_standalone.R`: Original standalone R script (pre-Shiny). Reference only — engine now lives in `global.R`.
- `qpm_backup.R`: Backup of the previous monolithic app.
- `renv.lock`: Locked versions of all R package dependencies.

## ⚖️ Development Conventions
- **Style:** Follow the **Tidyverse Style Guide** (https://style.tidyverse.org/).
- **Equations:** The model uses discrete-time equations for the 4 core pillars (IS, Phillips, Taylor, Exchange).
- **Documentation:** Maintain technical details in `presets/PARAMETERS_GUIDE.md` when updating model parameters.
- **Testing:** New country calibrations should be validated against academic literature before being added to `countries_parameters.csv`.

## 🔄 Recent Updates
- **v2.1 (Stable):** Split monolithic `qpm.R` into the standard Shiny structure (`app.R` / `global.R` / `ui.R` / `server.R`); added QoQ/YoY GDP growth metrics; moved the projections table to `DT`; moved the original standalone script to `prototype/`.
- **v2.0:** Re-structured dashboard with metric cards, individual charts, and integrated country presets.
- **Presets Integration:** Added automatic loading of calibrated parameters for major economies.
