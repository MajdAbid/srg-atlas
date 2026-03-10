# SRG AutoResearch

An autonomous mathematical research system for classifying strongly regular graphs (SRGs).

## What is a Strongly Regular Graph?

A strongly regular graph **srg(v, k, λ, μ)** is a regular graph on `v` vertices where:
- every vertex has exactly `k` neighbors
- every adjacent pair shares exactly `λ` common neighbors
- every non-adjacent pair shares exactly `μ` common neighbors

The central open problem: **for a given `v`, find ALL non-isomorphic SRGs, or prove none exist.**

## Directory Structure

```
srg_research/
├── program.md                  ← research mission (do not modify)
├── README.md                   ← this file
├── STATUS.md                   ← master list of all (v,k,λ,μ) and their status
│
├── core/
│   ├── srg_utils.sage          ← shared utilities (isomorphism, I/O, eigenvalues)
│   ├── feasibility.sage        ← feasibility checks (Krein, absolute bound, etc.)
│   ├── verify.sage             ← two-method independent verification
│   ├── generate_status.sage    ← generates STATUS.md
│   ├── generate_visualizations.sage ← generates feasibility landscape plot
│   └── methods/
│       ├── exhaustive.sage     ← backtracking exhaustive search
│       ├── algebraic.sage      ← algebraic constructions (Paley, triangular, etc.)
│       ├── switching.sage      ← Seidel switching and two-graph descent
│       ├── spectral.sage       ← spectral methods and Hoffman bounds
│       └── ai_pattern.sage     ← AI-assisted pattern detection
│
├── experiments/
│   └── EXP_{YYYYMMDD}_{NNN}_{description}/
│       ├── notebook.ipynb
│       ├── run.sage
│       ├── outputs/
│       └── EXPERIMENT.md
│
├── results/
│   ├── confirmed/              ← graphs verified by ≥2 independent methods
│   ├── candidates/             ← found but not yet fully verified
│   └── isomorphism_classes/    ← deduplicated canonical forms
│
├── visualizations/
│   ├── parameter_space/        ← feasibility_landscape.png
│   ├── gallery/                ← rendered graph images
│   └── progress/               ← discovery timeline
│
└── tests/
    ├── test_utils.sage
    ├── test_feasibility.sage
    └── test_known_cases.sage
```

## Ground Truth References

- **Brouwer's table**: https://aeb.win.tue.nl/graphs/srg/srgtab.html
- **Spence's classifications** (v ≤ 64): https://www.maths.gla.ac.uk/~es/srgraphs.php
- **SageMath SRG database**: `sage.graphs.strongly_regular_db`

## Running the Tests

All commands are run from the project root (`srg_research/`):

```bash
# Regression test: 10 known SRGs from Brouwer's table
sage tests/test_known_cases.sage

# Unit tests for core utilities
sage tests/test_utils.sage

# Unit tests for feasibility checks
sage tests/test_feasibility.sage
```

All three must pass with zero failures before any experiment runs.

## Regenerating STATUS.md

```bash
sage core/generate_status.sage
```

This computes feasibility for all parameter sets v=5..64 and writes STATUS.md.

## Regenerating Visualizations

```bash
sage core/generate_visualizations.sage
```

Saves `visualizations/parameter_space/feasibility_landscape.png`.

## Reading STATUS.md

STATUS.md contains a table of all 136 feasible SRG parameter sets for v=5..64:

| Status    | Meaning                                         |
|-----------|-------------------------------------------------|
| COMPLETE  | Fully classified; count is exact                |
| OPEN      | Feasible but not fully classified               |
| PARTIAL   | Some graphs found; completeness unknown         |
| NONE      | Proved nonexistent                              |

The research goal is to drive the fraction of OPEN sets to zero for v ≤ 64.

## Research Loop

Each experiment follows the loop in `program.md`:
1. Select smallest OPEN/PARTIAL target from STATUS.md
2. Feasibility check
3. Construction (database → algebraic → Seidel switching → spectral → exhaustive)
4. Verification (2 independent methods)
5. Document in `EXPERIMENT.md` + `summary.json`
6. Visualize
7. Update STATUS.md and commit

## Key Mathematical Facts

**Eigenvalues**: For srg(v,k,λ,μ), the non-trivial eigenvalues are:
```
r, s = ((λ-μ) ± √Δ) / 2    where Δ = (λ-μ)² + 4(k-μ)
```
- If Δ = v and v is not a perfect square: conference graph (irrational eigenvalues)
- Otherwise: r, s must be integers; their multiplicities f, g must be positive integers

**Feasibility conditions** (necessary, not sufficient):
1. k(k-1-λ) = μ(v-k-1)  (basic counting)
2. Eigenvalue integrality (or conference graph conditions)
3. Krein conditions: (r+1)(k+r+2rs) ≤ (k+r)(s+1)²  and symmetrically
4. Absolute bound: v ≤ f(f+3)/2 and v ≤ g(g+3)/2

## Design Phase Status

Completed: 2026-03-10

- [x] Full directory structure created
- [x] `core/srg_utils.sage` with 10 utility functions
- [x] `core/feasibility.sage` with 5 feasibility checks
- [x] `tests/test_known_cases.sage` passing (10/10 known SRGs verified)
- [x] `STATUS.md` populated with 136 feasible parameter sets (v=5..64)
- [x] `visualizations/parameter_space/feasibility_landscape.png` generated
- [x] All 3 test files pass with zero failures
