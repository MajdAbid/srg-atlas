# Investigation: srg(37, 18, 8, 9)

**Date**: 2026-03-10 | **Experiment**: EXP_20260310_008_srg37_18_8_9 | **Time**: 0m 0s

## 1. Parameter analysis

We consider strongly regular graphs with parameters (v, k, λ, μ) = (37, 18, 8, 9).

**Basic identity.** We verify k(k − λ − 1) = μ(v − k − 1): 18·9 = 162 and 9·18 = 162. ✓ Consistent.

**Discriminant.** Δ = (λ − μ)² + 4(k − μ) = (8 − 9)² + 4·(18 − 9) = 37.

Since Δ = 37 = v and v is not a perfect square, this is a **conference graph** (half-case). The eigenvalues are r, s = (−1 ± √37)/2 ≈ 2.5414, -3.5414, each with multiplicity (v−1)/2 = 18.

**Hoffman bounds.** ω(Γ) ≤ 1 − k/s = 6, α(Γ) ≤ v·(−s)/(k − s) = 6.

**Complement.** The complement has parameters srg(37, 18, 8, 9) — **self-complementary**.

## 2. Known results

According to Brouwer's table, srg(37,18,8,9) is a conference graph. For conference parameters with v = 37, the classification of the associated regular two-graphs on 37+1 = 38 vertices determines the switching class. See STATUS.md for the current classification status.

## 3. Construction and existence

**Result.** At least 1 non-isomorphic srg(37,18,8,9) exist(s).

**Graph 1** — found via *database*. Retrieved from Sage's SRG database.

### Methods attempted

- **database**: Sage strongly_regular_graph database lookup
- **paley**: Paley graph P(37) (requires v prime power, v ≡ 1 mod 4)
- **triangular**: Triangular graph T(n) = J(n,2)
- **latin_square**: Latin square graph LS_m(n) from orthogonal arrays
- **power_residue**: Power residue (cyclotomic) graph on GF(v)
- **kneser**: Kneser graph K(n,2)
- **complement**: Complement of a known SRG
- **seidel_switching**: Seidel switching (random subset sampling)
- **gm_switching**: Godsil-McKay switching (equitable partition search)
- **spectral**: spectral

## 4. Invariant analysis

| Graph | Method | |Aut(Γ)| | 2-rank | 3-rank | 5-rank |
|-------|--------|---------|--------|--------|--------|
| 1 | database | 666 | 36 | 18 | 37 |

Only one graph found. Whether srg(37,18,8,9) is unique requires either an exhaustive search or a theoretical argument.

## 5. Open questions

- Is srg(37,18,8,9) unique, or do non-isomorphic copies exist?
- Can the switching class be fully enumerated?
- What is the full automorphism group?
- What is the structure of the associated regular two-graph on 38 vertices?

## 6. Computational evidence

All computations performed in SageMath. Reproducible script: `run.sage`. Graph files: `outputs/graphs/`. Session time: 0m 0s.
