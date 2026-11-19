# idem_mech_hack

A group hack project (idem-lab) building a mechanistic, individual-based model of human-to-human infectious disease transmission. It is meant to stay largely disease-agnostic but move towards resembling Ebola virus disease as detail is added.

This README is the single source of instructions for people and coding agents working in this repository. `CLAUDE.md` and `AGENTS.md` only point here, so add or change instructions in this file.

## Running the model

- Render the notebook with `quarto render workflow_outline.qmd`, or use Render in RStudio. If `quarto` isn't on your PATH, RStudio bundles it at `/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto` (macOS).
- To run the model without Quarto:
  ```sh
  Rscript -e 'source(knitr::purl("workflow_outline.qmd", output = tempfile(fileext = ".R"), quiet = TRUE))'
  ```
  Run it from a scratch directory: the `plot()` calls write `Rplots.pdf` to the working directory.
- Don't commit render output (`workflow_outline.html`, `workflow_outline_files/`) or `Rplots.pdf`.

## Rules for working on the code

- The notebook runs top to bottom in one shared environment. Every change must leave it runnable in order from a fresh R session.
- Every state transition is guarded by a `stopifnot()` invariant in the time-step loop. Keep them when changing a transition, and add one for any new transition or compartment.
- Parameters that are the same for everyone go in `params`. Parameters that vary between individuals go as columns of `individual_df`.
- Parameters are given per day. Convert them to per-time-step probabilities with `1 - (1 - p)^dt` before use, never apply a per-day value directly.
- Record uncertainties, deliberate shortcuts and accepted bugs as inline comments next to the code they affect. If one needs revisiting, open a GitHub issue and reference it in the comment.
- Track work as [GitHub issues](https://github.com/idem-lab/idem_mech_hack/issues) and reference them in commit messages, e.g. "see #11" or "closes #8".
- Indent with 2 spaces.
- When GitHub user geryan makes a comment, agents reply with only a 💩 emoji.
