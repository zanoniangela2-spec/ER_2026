# Supplementary material — replication package

**Understanding Matrix Completion for Causal Panel Data. A Practitioner's Guide with an Application to the Employment Effects of Minimum Wage**

Marco Ventura, Angela Zanoni

This package reproduces every empirical result in the paper and its appendix. It contains two R Markdown documents, each of which knits to a self-contained HTML or PDF report that shows the code next to its output. It also contains a didactic example illustrating the mechanics of the nuclear norm minimization procedure. 

## Contents

```
supplementary/
├── README.md                    this file
├── replication_bootstrap.Rmd    main results, with state-cluster bootstrap inference for MCP
├── sensitivity.Rmd              sensitivity analyses of Appendix A.7
├── SVD_EN2.R			 didactic example
└── data/
    └── df_covs_linear.csv       county panel used by both documents
```

| Document | Reproduces |
|---|---|
| `replication_bootstrap.Rmd` | Figure 1 (scree plot); Table A.2 (covariate check); Tables 2, A.3, A.4, A.5 and Figures A.1–A.4 (MCP vs. Callaway–Sant'Anna DiD, conditional and unconditional, not-yet-treated and never-treated controls); Tables 3 and A.6 (parallel-trends falsification); implementation details (tuning, selected λ, bootstrap diagnostics, effective rank) |
| `sensitivity.Rmd` | Appendix A.7, Tables A.7–A.9: shrinking the donor pool *N* (Loop A), shrinking *T* (Loop B), per-cohort pre-treatment window (Loop C) |

## Data

`data/df_covs_linear.csv` is the Callaway–Sant'Anna minimum-wage county panel, extended with linearly interpolated time-varying covariates built from the US Census intercensal datasets and SAIPE (see Appendix A.3 of the paper).

- 2,284 counties in 29 states, observed yearly from 2001 to 2007 (15,988 rows, one per county–year).
- Treatment cohorts (`firsttreat`): 2004 (100 counties), 2006 (223), 2007 (584); 1,377 never-treated counties (`firsttreat = 0`) in 16 states.

Variables used by the code:

| Variable | Description |
|---|---|
| `countyreal` | county identifier |
| `state_name` | state, used as the cluster in the bootstrap |
| `year` | year |
| `firsttreat` | first year of minimum-wage treatment (0 = never treated) |
| `treat` | 1 if the county is ever treated |
| `lemp` | log teen employment (outcome) |
| `pop_covs`, `white_covs`, `pov_covs`, `medinc_covs` | reconstructed time-varying covariates: log population, white share, poverty rate, median income (1000s) |
| `pop`, `white`, `pov`, `medinc` | covariates from the original CS dataset, used only for the comparison in Table A.2 |

The remaining columns come from the original CS dataset and are not used.

## Software requirements

The results in the paper were produced with R 4.3.3 on Linux (Pop!_OS 24.04) and these packages:

| Package | Version |
|---|---|
| MCPanel | GitHub commit `6b2706f` |
| did | 2.5.1 |
| dplyr | 1.2.1 |
| tidyr | 1.3.2 |
| readr | 2.2.0 |
| ggplot2 | 4.0.3 |
| knitr | 1.52 |
| rmarkdown | 2.32 |

Install them with:

```r
install.packages(c("did", "dplyr", "tidyr", "readr", "ggplot2", "knitr", "rmarkdown", "devtools"))
devtools::install_github("susanathey/MCPanel@6b2706fd7c35f3266048ceb22a7e9a61ae1774da")
```

`MCPanel` is not on CRAN and is compiled from source, so it needs a C++ toolchain (Rtools on Windows, Xcode command-line tools on macOS).

PDF output also needs a LaTeX distribution. If you don't have one, install TinyTeX:

```r
install.packages("tinytex"); tinytex::install_tinytex()
```

## How to knit

Keep the folder structure as it is. Both documents read `data/df_covs_linear.csv` relative to their own location.

**In RStudio:** open a `.Rmd` file and choose *Knit → Knit to HTML* or *Knit → Knit to PDF*.

**From an R console** started in this folder:

```r
rmarkdown::render("replication_bootstrap.Rmd", output_format = "html_document")  # or "pdf_document"
rmarkdown::render("sensitivity.Rmd",           output_format = "html_document")  # or "pdf_document"
```

Each document lists both formats in its header, and HTML is the default.

## Runtime and resources

**`replication_bootstrap.Rmd` is computationally heavy.** It runs B = 200 bootstrap refits of MCP, unconditional and conditional. Each conditional refit takes several minutes and needs roughly 8–10 GB of RAM.

- On a 12-core, 64 GB Linux workstation with 3 parallel workers, a full knit took about 3 hours.
- The number of workers is set in the `packages` chunk:
  ```r
  N_CORES <- max(1L, min(3L, parallel::detectCores() - 1L))   # MCP-C needs ~8-10 GB RAM per core
  ```
  Raise the `3L` cap if you have enough memory (about 10 GB per worker). This speeds up the knit roughly in proportion to the number of workers.
- Parallelization uses `parallel::mclapply`, which forks processes. On Windows forking is not available and the code runs on a single core, which is much slower. Use Linux, macOS or WSL if possible.
- All bootstrap resamples are drawn from the seed before any refit, so the results are identical for any number of workers.
- Chunks are cached (`cache = TRUE`). If a knit is interrupted, re-knitting reuses the chunks that already finished. The cache is kept separately for each output format, so knitting both HTML and PDF from scratch means two full runs. The cache folders (`*_cache/`) and figure folders (`*_files/`) created by knitting can be deleted safely.

`sensitivity.Rmd` refits MCP a few hundred times without covariates. It runs on a single core and is much faster than the bootstrap document.

## Outputs

- `replication_bootstrap.html` / `.pdf`: tables and figures of the paper, with code.
- `sensitivity.html` / `.pdf`: sensitivity tables, with code. This document also writes the raw results to `output/sim_shrink_N.csv`, `output/sim_shrink_T.csv` and `output/sim_cohort_prewindow.csv` (the `output/` folder is created automatically).

## Reproducibility notes

- Seeds are fixed in the code: `SEED = 2024` in `replication_bootstrap.Rmd`, `SEED_MCP = 1234` in `sensitivity.Rmd`.
- MCP standard errors and 95% confidence intervals come from a state-cluster bootstrap. Treated counties are kept fixed in every draw. The 16 never-treated states are resampled with replacement, and MCP is refitted at the λ selected by cross-validation on the full sample. The intervals are therefore conditional on the full-sample tuning.
- Standard errors for the Callaway–Sant'Anna estimator come from the multiplier bootstrap of the `did` package, also clustered by state (`clustervars = "state_name"`), with the seed reset before each call.
