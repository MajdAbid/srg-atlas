# Experiment: EXP_20260310_005 — srg(37,18,8,9) Two-Graph Descent & Local Search

**Date**: 2026-03-10

## Objective

Apply Methods C (Seidel switching / two-graph descent) and E (local search
approximating exhaustive backtracking) to find non-isomorphic srg(37,18,8,9)
beyond the single known Paley(37). Determine the structure of Paley(37)'s
switching class, and attempt to find graphs from other switching classes.

## Methods attempted

- **Method A** (database): Already completed in EXP_003 — found Paley(37).
- **Method C** (Seidel switching / two-graph descent): Full BFS exploration
  of the two-graph switching class containing Paley(37).
- **Method E** (approximation via simulated annealing local search): 8
  independent runs × 250,000 SA steps each from random 18-regular starting graphs.
- **Method D** (spectral analysis): Full eigenvalue analysis of Paley(37).

## Feasibility (confirmed)

Conference graph conditions:
- v=37 prime ≡ 1 mod 4 → Paley(37) guaranteed ✓
- k = (v-1)/2 = 18 ✓, λ = (v-5)/4 = 8 ✓, μ = (v-1)/4 = 9 ✓
- Eigenvalues: r = (-1+√37)/2 ≈ 2.5414, s = (-1-√37)/2 ≈ -3.5414 (irrational)
- Multiplicities: f = g = (v-1)/2 = 18 each
- Status: FEASIBLE ✓

## Results

### Graphs found: 1 (Paley(37), previously known from EXP_003)

| Graph | Hash | Method | Note |
|-------|------|--------|------|
| Paley(37) | 4e8b50f5fadd307a | algebraic | Unique in its switching class |

### Method C: Two-graph descent BFS

The **correct** Seidel switching procedure for conference SRGs is the
"two-graph descent pivot": given srg G and vertex y, delete y, switch on
N(y) in G-{y}, and add a new vertex adjacent to original N(y). This ALWAYS
produces a valid srg(v,k,λ,μ).

**Key finding**: All 37 pivots from Paley(37) produce graphs isomorphic to
Paley(37) itself.

**Mathematical explanation**: Paley(37) has automorphism group AΓL(1,37)
(order 2,664 = 37 × 36 × 2). This group acts vertex-transitively, meaning
all 37 vertices are equivalent under automorphisms. Therefore, pivoting on
any vertex y gives the same graph up to isomorphism.

**Consequence**: The switching class of Paley(37) (the regular two-graph on
38 vertices it corresponds to) has exactly **1 non-isomorphic descendant**:
Paley(37) itself. All 38 vertices of the two-graph on 38 vertices give
isomorphic descendants.

This is consistent with Paley graphs having the maximal automorphism group
among strongly regular graphs — they are "maximally symmetric" within their
switching class.

**BFS exhausted**: the switching class is finite and fully explored.

### Method E: Simulated annealing from random starts

8 independent runs × 250,000 SA steps each (total: 2,000,000 steps):

| Run | Seed | Start E | Best E | Converged |
|-----|------|---------|--------|-----------|
| 1   | 1000 | 1520    | 374    | ✗ |
| 2   | 1173 | 1382    | 378    | ✗ |
| 3   | 1346 | 1738    | 386    | ✗ |
| 4   | 1519 | 1618    | 374    | ✗ |
| 5   | 1692 | 1542    | 384    | ✗ |
| 6   | 1865 | 1298    | 360    | ✗ |
| 7   | 2038 | 1676    | 376    | ✗ |
| 8   | 2211 | 1732    | 368    | ✗ |

All runs: energy reduced ~75% (from ~1500 to ~370) but did NOT reach E=0.
This is expected: SA with simple 2-swaps in reasonable time cannot find
srg(37,18,8,9). The energy landscape has many deep local minima at E~360-400.

### Method D: Spectral analysis

Computed eigenvalues of Paley(37) numerically (numpy):
- Eigenvalue k=18: multiplicity 1
- Eigenvalue r = (-1+√37)/2 ≈ 2.5414: multiplicity 18
- Eigenvalue s = (-1-√37)/2 ≈ -3.5414: multiplicity 18

**Confirmed**: irrational eigenvalues → conference graph → no Krein condition
violations possible.

Paley(37) is **self-complementary**: complement is isomorphic to Paley(37).
(Verified numerically: complement is also srg(37,18,8,9) with same fingerprint.)

Distance analysis from vertex 0:
- Distance 0: vertex 0 (1 vertex)
- Distance 1: N(0) = 18 neighbors
- Distance 2: all 18 non-neighbors
- **Diameter = 2** (as required by μ=9 > 0)

## Failures and what was learned

### 1. Random Seidel switching does NOT preserve SRG property
The initially implemented naive switching (arbitrary random subsets) produced
non-regular graphs. Fix: use the two-graph descent pivot as the correct
operation.

### 2. Paley(37) switching class is a singleton
All two-graph descendants of Paley(37) are isomorphic to itself. To find other
srg(37,18,8,9), we need a starting graph from a **different** switching class.

### 3. SA does not converge for v=37 in reasonable time
The energy landscape for srg(37,18,8,9) has many local minima at E~360-400.
250k SA steps are insufficient. Literature sources suggest exhaustive search
for v=37 requires specialized tools (nauty/bliss for canonical labeling,
McKay-Spence two-graph enumeration algorithm).

### 4. Without SageMath and nauty, finding new non-isomorphic examples is impractical
All known methods beyond Paley(37) require either:
(a) SageMath + nauty for exhaustive backtracking, or
(b) The McKay-Spence two-graph enumeration algorithm (highly specialized), or
(c) Access to Spence's precomputed database of 6,802+ graphs.

## Visualizations generated (all in outputs/plots/)

1. `adjacency_matrix_heatmap.png` — Paley(37) adj matrix in original & BFS ordering
2. `eigenvalue_spectrum.png` — Bar chart of all 37 eigenvalues; conference structure
3. `complement_plot.png` — Paley(37) vs complement (self-complementarity)
4. `distance_partition.png` — BFS distance layers from v=0; diameter analysis
5. `a2_verification.png` — A² distribution: confirms λ=8 and μ=9 exactly
6. `sa_energy_convergence.png` — SA energy vs steps for all 8 runs
7. `switching_class_analysis.png` — Two-graph structure diagram

## Open questions raised

1. **Why do all 37 pivots of Paley(37) give the same graph?**
   Answered: vertex-transitivity of Paley(37) makes all pivots equivalent.

2. **How do we access other switching classes?**
   Need McKay-Spence two-graph enumeration or Spence's database.

3. **What is the smallest SA step count needed to find an srg(37,18,8,9)?**
   Unknown, but likely >>1M steps, and may require better neighborhood operators.

4. **Are there Cayley graph constructions for srg(37,18,8,9) beyond Paley?**
   No: by classification of PDSs in cyclic prime groups, Paley is the unique
   Cayley srg over Z/37Z with conference parameters.

5. **Can we access the literature database (Spence's page) to import known SRGs?**
   The domain (maths.gla.ac.uk) is blocked by the network proxy. Would
   require direct file transfer of the graph6 database files.

## Next suggested experiment

**EXP_20260310_006**: Feasibility landscape for remaining OPEN/PARTIAL targets.
- Generate a comprehensive feasibility plot for all v=37..64 open cases
- Compute spectral bounds for all PARTIAL parameter sets
- Document what makes each parameter set "hard" vs. "tractable"
- OR: Accept current limitation and move to next parameter set by priority
  (next smallest PARTIAL: v=41, srg(41,20,9,10))
