# Experiment: EXP_20260310_004 — srg(37,18,8,9) Literature Survey

**Date**: 2026-03-10

## Objective

Conduct a comprehensive literature survey of the classification status of srg(37,18,8,9),
the current frontier target (smallest PARTIAL parameter set in STATUS.md). Determine the
best-known lower bound on the count, understand the theoretical framework (two-graph
descent), and plan subsequent computational experiments.

## Methods attempted

- Literature survey (web search + Brouwer/Spence/McKay-Spence papers)
- Spectral analysis (analytical, from eigenvalue formula)
- Feasibility verification (analytical)

## Feasibility Analysis

**Parameters**: v=37, k=18, λ=8, μ=9

**Basic counting check**:
  k(k-1-λ) = 18·(17-8) = 18·9 = 162
  μ(v-k-1) = 9·(37-18-1) = 9·18 = 162  ✓

**Eigenvalue computation**:
  Δ = (λ-μ)² + 4(k-μ) = (8-9)² + 4(18-9) = 1 + 36 = 37
  √Δ = √37  (irrational — conference graph condition)
  r, s = ((8-9) ± √37) / 2 = (-1 ± √37) / 2

  This is a **conference graph**: v=37 is prime, √37 is irrational,
  and v = (λ-μ)² + 4(k-μ) = 37. The eigenvalues are irrational,
  with multiplicities f = g = (v-1)/2 = 18.

**Conference graph conditions satisfied**:
  - v=37 is prime ≡ 1 mod 4 → Paley(37) exists as a concrete example ✓
  - k = (v-1)/2 = 18 ✓
  - λ = (v-5)/4 = 8 ✓
  - μ = (v-1)/4 = 9 ✓

**Status**: FEASIBLE (conference graph, Paley construction guaranteed)

## Results from Literature

### Known count: ≥ 6,802 non-isomorphic srg(37,18,8,9)

**Key papers and findings**:

1. **McKay & Spence (2001)** — "Classification of regular two-graphs on 36 and 38 vertices"
   - AJC, Vol. 24, pp. 293–300
   - Found 191 non-isomorphic regular two-graphs on 38 vertices
   - Each regular two-graph on 38 vertices "descends" to a set of srg(37,18,8,9) graphs
     (via removal of a vertex from the Seidel matrix)
   - 191 two-graphs yield exactly 6,760 non-isomorphic srg(37,18,8,9) descendants
   - **Classification of two-graphs on 38 vertices was not completed** due to computational cost

2. **Recent work (~2022–2023)** — "New regular two-graphs on 38 and 42 vertices"
   - Found additional regular two-graphs on 38 vertices
   - Updated count: ≥ 194 regular two-graphs on 38 vertices
   - Updated descendant count: ≥ 6,802 non-isomorphic srg(37,18,8,9)
   - **Classification remains open** — true total is believed to be much larger

3. **Mathon** — Self-complementary analysis
   - Exactly **2** self-complementary srg(37,18,8,9) are known
   - Both are contained in the list of 6,760 (from McKay-Spence)

4. **Maksimović (2018)** — MDPI Symmetry paper
   - Studied srg(37,18,8,9) with S₃ as automorphism group
   - Result: **No srg(37,18,8,9) has a non-abelian automorphism group of order 6**
   - Exhausted 176 feasible orbit-length distributions; only 3 yield orbit matrices;
     none of the 3 produce valid graphs

### Known examples

| Graph | Source | Notes |
|-------|--------|-------|
| Paley(37) | Algebraic (Paley construction) | v=37 prime ≡ 1 mod 4; unique up to Paley |
| ≥6,801 others | Seidel switching / two-graph descent | From McKay-Spence + 2022 updates |

### Why classification is hard

- srg(37,18,8,9) is a conference graph → eigenvalues are irrational → algebraic
  constraints are weaker (Krein conditions don't apply in the usual sense)
- The number of non-isomorphic graphs is enormous (likely >> 10⁴ or more)
- Exhaustive backtracking for v=37 is computationally infeasible
- Seidel switching from any one graph generates many but not all

### Connection to regular two-graphs

A **regular two-graph** on n vertices is equivalent to a switching class of
(n-1,k,λ,μ)-SRGs where switching classes all contain a conference graph.
Specifically, regular two-graphs on 38 vertices ↔ switching classes of srg(37,18,8,9).

**Seidel switching** applied to srg(37,18,8,9) can produce both isomorphic and
non-isomorphic mates. Complete enumeration of switching equivalence classes =
complete enumeration of regular two-graphs on 38 vertices.

## Failures and what was learned

- SageMath is not available in the current environment → Sage-based methods cannot run
- Python + numpy ARE available → can implement Paley(37) and switching in Python
- Internet access to Brouwer's table (aeb.win.tue.nl) and Spence's page (maths.gla.ac.uk)
  is blocked by network proxy → used web search instead

## Visualizations generated

None in this experiment (literature survey only).

## Open questions raised

1. What is the true total number of non-isomorphic srg(37,18,8,9)?
   - Current lower bound: ≥ 6,802
   - Upper bound: unknown
   - Likely in the hundreds of thousands or more

2. Are there srg(37,18,8,9) not reachable from Paley(37) by Seidel switching?
   - Yes — different regular two-graphs on 38 vertices correspond to
     genuinely different switching classes

3. Can the full classification be achieved by completing the enumeration of
   regular two-graphs on 38 vertices?
   - Yes in principle, but computationally requires tools beyond current resources

4. What automorphism groups actually occur?
   - Paley(37) has Aut ≅ AΓL(1,37), order 37·36·2 = 2,664
   - Most graphs from switching have trivial automorphism group
   - S₃ (order 6) does NOT occur (Maksimović 2018)

## Next suggested experiment

**EXP_20260310_005**: Python-based Seidel switching from Paley(37)
- Construct Paley(37) adjacency matrix in Python/numpy
- Verify it satisfies srg(37,18,8,9) parameters
- Apply random Seidel switching (sample 2^k subsets for k=1..8 randomly)
- Distinguish non-isomorphic mates using characteristic polynomial of A and A²
- Record how many apparently distinct srg(37,18,8,9) we find
- Save all found graphs in .g6 format

## References

1. McKay, B.D. & Spence, E. (2001). Classification of regular two-graphs on 36 and 38 vertices.
   Australasian J. Combinatorics, 24, 293–300.
2. Maksimović, M. (2018). Enumeration of Strongly Regular Graphs on up to 50 Vertices Having
   S₃ as an Automorphism Group. Symmetry, 10(6), 212. MDPI.
3. Brouwer, A.E. Table of strongly regular graphs. https://aeb.win.tue.nl/graphs/srg/srgtab.html
4. Spence, E. Strongly regular graphs on at most 64 vertices. https://www.maths.gla.ac.uk/~es/srgraphs.php
5. Recent work on new regular two-graphs on 38 and 42 vertices (~2022–2023).
