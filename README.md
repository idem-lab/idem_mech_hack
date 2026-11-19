# idem_mech_hack

A group hack project (idem-lab) building a mechanistic, individual-based model of human-to-human infectious disease transmission. It is meant to stay largely disease-agnostic but move towards resembling Ebola virus disease as detail is added.

This README is the single source of instructions for people and coding agents working in this repository. `CLAUDE.md` and `AGENTS.md` only point here, so add or change instructions in this file.

The whole model lives in one Quarto notebook, `workflow_outline.qmd`. There is no package structure, build system or test framework. `R/roster-assignment.R` only assigns the rotating driver/documenter roles for hack sessions and is not part of the model. `data/` is an empty placeholder.

## Commands

- **Render the notebook:** `quarto render workflow_outline.qmd`, or use Render in RStudio. If `quarto` isn't on your PATH, RStudio bundles it at `/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto` (macOS). The output (`workflow_outline.html`, `workflow_outline_files/`) should not be committed.
- **Run the model headless (no Quarto):**
  ```sh
  Rscript -e 'source(knitr::purl("workflow_outline.qmd", output = tempfile(fileext = ".R"), quiet = TRUE))'
  ```
  The base `plot()` calls write `Rplots.pdf` to the working directory, which isn't gitignored. Run it from a scratch directory, or delete the file afterwards.
- **Required packages:** `dplyr`, `ggplot2`, `tidyr` (plus `knitr` for the headless run).

## Model architecture

Chunks run top to bottom in a single shared global environment, so chunk order matters. Function argument defaults read from the global `params` list (for example, `simulate_contact_pairs()` defaults to `params$individual_index`). The seed is set once in the first chunk, so a run is only reproducible when the whole document runs in order.

- **State:** `params` holds global settings and per-day probabilities. `individual_df` holds per-individual state: `compartment` is `"S"`, `"I"` or `"R"`, alongside per-individual parameters such as `p_recovery_per_day` (see [#4](https://github.com/idem-lab/idem_mech_hack/issues/4)). To make a parameter individual-specific, add a column to `individual_df` and index it by `index` inside the transition function, as `recovery_function()` does with `prob_recovery[index]`. `reversion_function()` still takes a scalar.
- **Time step loop:** each step draws a fresh set of random contact pairs (`simulate_contact_pairs()`). It then runs three per-individual passes, R→S (`reversion_function`), S→I (`infection_function`) and I→R (`recovery_function`). All three are evaluated against the same snapshot, `current_compartment`, so updates are synchronous and each individual makes at most one transition per step.
- **Combining transitions:** the passes produce logical vectors that are combined as `previously_*`, then `newly_*`, then `currently_*`. `stopifnot()` invariants guard against impossible transitions (e.g. `newly_infected <= previously_susceptible`), and `dplyr::case_when()` rebuilds `compartment` from the result. Keep these invariants in place when adding compartments or transitions.
- **Probability conversion:** per-day probabilities become per-time-step probabilities with `1 - (1 - p)^dt`, where `dt = params$timestep_size`.
- **Logger:** `logger` is a preallocated data frame with one row per time step. Row 1 is the initial state, and the loop runs `t in 1:(n_time_steps - 1)` and writes row `t + 1`. `inf_prev`, `recovered` and `susceptible` are proportions that should sum to 1 (the stacked plot checks this). `inf_inc` is a count. Initial incidence assumes seeded infections happened at the first step. If seeded individuals are given earlier infection times ([#11](https://github.com/idem-lab/idem_mech_hack/issues/11)), this needs updating.
- **Known, accepted simplifications** (documented in the notebook, intended to be revisited): contact events where an individual is paired with themselves are dropped. Repeated contacts between the same pair in one step are allowed, but `infection_function()` collapses them into a single exposure.

## Testing

"Unit tests" are the `stopifnot()` invariants inside the time-step loop, plus commented-out test loops below each function definition. A failing run therefore stops partway through the loop rather than reporting test results.

## Conventions

- Work is tracked as [GitHub issues](https://github.com/idem-lab/idem_mech_hack/issues). Commit messages reference them, e.g. "see #11" or "closes #8".
- Indentation is 2 spaces (per the `.Rproj`).
- Uncertainties and deliberate shortcuts are recorded as inline comments next to the code they affect. Keep that habit when changing model behaviour.
