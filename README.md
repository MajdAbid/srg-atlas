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

## Research Session: 2026-03-10 (Experiments 004–005)

Target: srg(37,18,8,9) — smallest PARTIAL parameter set.

**EXP_20260310_004** (Literature Survey):
- Confirmed: ≥6,802 non-isomorphic srg(37,18,8,9) known
- Source: ≥194 regular two-graphs on 38 vertices (McKay-Spence 2001, extended 2022–23)
- 2 self-complementary examples (including Paley(37))
- No srg(37,18,8,9) with S₃ automorphism group (Maksimović 2018)
- STATUS.md updated accordingly

**EXP_20260310_005** (Two-graph descent + SA):
- Paley(37) verified as srg(37,18,8,9) with correct parameters
- Eigenvalues: k=18, r≈2.54, s≈-3.54 (irrational — confirmed conference graph)
- Paley(37) is self-complementary (complement isomorphic to itself)
- Diameter = 2 (distance-2 partition: 1 | 18 | 18)
- **Key finding**: All 37 two-graph descent pivots give graphs isomorphic to Paley(37).
  Paley(37) occupies a SINGLETON switching class (vertex-transitivity forces this).
- SA local search (8 runs × 250k steps): energy reduced ~75% (1500→370) but
  did NOT converge to E=0. Finding new srg(37,18,8,9) requires SageMath/nauty
  or the McKay-Spence enumeration algorithm.
- 7 visualizations generated (see experiments/EXP_20260310_005.../outputs/plots/)

**Next target**: srg(41,20,9,10) — next smallest PARTIAL, also a conference graph.
