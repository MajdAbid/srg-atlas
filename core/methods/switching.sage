"""
switching.sage — Seidel switching and two-graph descent for SRGs.

Seidel switching: given a graph G and a subset S of vertices,
  toggle edges between S and V\S.
  If G is srg(v,k,λ,μ), the switched graph may be non-isomorphic
  but have the same parameters.

Two-graph descent: all SRGs srg(v,k,λ,μ) with μ=k/2 correspond to
  switching classes (two-graphs). Systematically explore them.
"""

from sage.all import *
import itertools
import random as _random
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def seidel_switch(G, S):
    """
    Apply Seidel switching to graph G with switching set S.

    For each pair (u,v) with u in S and v not in S:
      - if edge exists: remove it
      - if no edge: add it
    Edges within S and within V\S are unchanged.

    Inputs:
        G : Sage Graph (will not be modified)
        S : list/set of vertex labels (subset of G.vertices())

    Outputs:
        new Sage Graph after switching

    Example:
        G2 = seidel_switch(G, [0, 1, 2])
    """
    H = G.copy()
    S_set = set(S)
    V_minus_S = [v for v in G.vertices() if v not in S_set]

    for u in S:
        for v in V_minus_S:
            if H.has_edge(u, v):
                H.delete_edge(u, v)
            else:
                H.add_edge(u, v)
    return H


# Threshold above which exhaustive enumeration is infeasible
_EXHAUSTIVE_THRESHOLD = 20  # v <= 20: enumerate; else: random sample


def switching_search(G, v, k, lam, mu, max_rounds=3, verbose=True):
    """
    Apply Seidel switching to find non-isomorphic mates of G with
    the same SRG parameters.

    Strategy:
    - For small v (<=20): BFS over switching classes, try all subsets
      of size up to min(v//4, 6).
    - For large v (>20): random sampling — draw random subsets of
      random sizes and check. Much more scalable.

    Inputs:
        G          : starting Sage Graph (srg(v,k,lam,mu))
        v,k,lam,mu : SRG parameters
        max_rounds : BFS depth (small v) or number of random trials (large v)
        verbose    : print progress

    Outputs:
        list of non-isomorphic Sage Graphs found (not including G itself)

    Example:
        mates = switching_search(G, 29, 14, 6, 7)
    """
    seen_labels = set()
    found = []

    # Pre-seed with G's canonical label to avoid re-discovering it
    seen_labels.add(G.canonical_label().graph6_string())

    def add_if_new(H):
        if verify_srg(H, v, k, lam, mu, verbose=False):
            cl = H.canonical_label().graph6_string()
            if cl not in seen_labels:
                seen_labels.add(cl)
                found.append(H)
                if verbose:
                    print(f"    [switching] New SRG mate #{len(found)}")
                return True
        return False

    verts = list(G.vertices())

    # Helper: check if a global time_is_up() function is available (from timer.sage)
    def _time_is_up():
        try:
            return time_is_up()
        except NameError:
            return False

    if v <= _EXHAUSTIVE_THRESHOLD:
        # Exhaustive BFS for small graphs
        queue = [G]
        for round_num in range(max_rounds):
            if _time_is_up():
                break
            if verbose:
                print(f"    [switching] Round {round_num+1}: queue={len(queue)}, found={len(found)}")
            next_queue = []
            for H in queue:
                if _time_is_up():
                    break
                max_size = min(len(verts) // 4, 6)
                for size in range(1, max_size + 1):
                    if _time_is_up():
                        break
                    for S in itertools.combinations(verts, size):
                        if _time_is_up():
                            break
                        H2 = seidel_switch(H, list(S))
                        if add_if_new(H2):
                            next_queue.append(H2)
            if not next_queue:
                break
            queue = next_queue
    else:
        # Random sampling for large graphs
        n_trials = max_rounds * 500
        min_size = 2
        max_size = max(min_size, v // 4)

        if verbose:
            print(f"    [switching] Random sampling: {n_trials} trials, "
                  f"set sizes {min_size}..{max_size}")

        for trial in range(n_trials):
            if _time_is_up():
                break
            size = _random.randint(min_size, max_size)
            S = _random.sample(verts, size)
            H2 = seidel_switch(G, S)
            add_if_new(H2)

        if verbose:
            print(f"    [switching] Done: {len(found)} new mate(s) found")

    return found


print("switching.sage loaded.")
