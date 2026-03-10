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


def switching_search(G, v, k, lam, mu, max_rounds=5, verbose=True):
    """
    Systematically apply Seidel switching to find non-isomorphic mates
    of graph G with the same SRG parameters.

    Strategy: BFS over switching classes. At each round, try switching
    over all subsets of size up to min(v//4, 10). Record non-isomorphic
    new graphs.

    Inputs:
        G          : starting Sage Graph (srg(v,k,lam,mu))
        v,k,lam,mu : SRG parameters
        max_rounds : BFS depth limit
        verbose    : print progress

    Outputs:
        list of non-isomorphic Sage Graphs (including G) with same parameters

    Example:
        mates = switching_search(G, 29, 14, 6, 7)
    """
    seen_labels = set()
    found = []

    def add_if_new(H):
        if verify_srg(H, v, k, lam, mu):
            cl = H.canonical_label().graph6_string()
            if cl not in seen_labels:
                seen_labels.add(cl)
                found.append(H)
                if verbose:
                    print(f"  New SRG mate #{len(found)}")
                return True
        return False

    add_if_new(G)
    queue = [G]

    for round_num in range(max_rounds):
        if verbose:
            print(f"  Round {round_num+1}: queue={len(queue)}, found={len(found)}")
        next_queue = []
        for H in queue:
            verts = list(H.vertices())
            # Try all subsets of size up to min(v//4, 8)
            max_size = min(len(verts) // 4, 8)
            for size in range(1, max_size + 1):
                for S in itertools.combinations(verts, size):
                    H2 = seidel_switch(H, list(S))
                    if add_if_new(H2):
                        next_queue.append(H2)
        if not next_queue:
            break
        queue = next_queue

    return found


print("switching.sage loaded.")
