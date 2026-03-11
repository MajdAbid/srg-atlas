# Experiment: EXP_20260310_002_srg37_18_8_9 — srg(37,18,8,9)

**Date**: 2026-03-10

## Objective
Classify all non-isomorphic srg(37,18,8,9).

## Methods attempted
- database
- seidel_switching (partial — timer expired mid-search)

## Results
- Graphs found: 1 (Paley(37), from Sage database)
- Non-isomorphic classes: at least 1
- Time taken: 10m 0s (timer expired)

## Failures and what was learned
- Seidel switching used exhaustive subset enumeration for v=37, which is infeasible
  (C(37,1)+…+C(37,8) ≈ 51M combinations). The SIGALRM fired but switching kept running
  through ~12M iterations before the process terminated.
- **Fix applied**: switching.sage now uses random sampling for v>20, and checks
  `time_is_up()` at every iteration.

## Visualizations generated
_(none — session did not reach Step 6)_

## Open questions raised
- How many non-isomorphic srg(37,18,8,9) exist? Brouwer lists `+` (some known, open).
- The Paley graph Paley(37) is a conference graph (v=37 prime ≡ 1 mod 4).
- Seidel switching from Paley(37) with random sampling needs a dedicated session.

## Next suggested experiment
Re-run srg(37,18,8,9) with improved switching (random sampling, timer-aware).
