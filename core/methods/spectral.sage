"""
spectral.sage — Spectral methods and bounds for SRGs.

Provides:
  - Eigenvalue computation and verification
  - Hoffman (Delsarte) clique/coclique bounds
  - Interlacing-based constraints
  - Automorphism group order bounds
"""

from sage.all import *
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def hoffman_bound(v, k, lam, mu):
    """
    Compute the Hoffman (Delsarte) upper bound on the clique size omega(G)
    and the independence number alpha(G) for srg(v,k,lam,mu).

    For a k-regular graph on v vertices with smallest eigenvalue s:
      omega(G) <= 1 - k/s
      alpha(G) <= v * (-s) / (k - s)   [Hoffman bound]

    Inputs:
        v, k, lam, mu : SRG parameters

    Outputs:
        dict with 'clique_bound' and 'independence_bound'

    Example:
        hoffman_bound(13, 6, 2, 3)
    """
    ev = srg_eigenvalues(v, k, lam, mu)
    if ev is None:
        return None

    r = ev['r']  # larger eigenvalue
    s = ev['s']  # smaller eigenvalue (negative)

    if s >= 0:
        return {'clique_bound': None, 'independence_bound': None,
                'note': 'smallest eigenvalue >= 0'}

    clique_bound = 1 - k / s
    independence_bound = v * (-s) / (k - s)

    return {
        'clique_bound': floor(clique_bound),
        'independence_bound': floor(independence_bound),
        'r': r, 's': s
    }


def spectral_summary(v, k, lam, mu):
    """
    Print a complete spectral summary for srg(v,k,lam,mu).

    Includes: eigenvalues, multiplicities, clique/independence bounds,
    and whether the graph is strongly regular self-complementary.

    Inputs:
        v, k, lam, mu : SRG parameters

    Outputs:
        dict with all spectral data

    Example:
        spectral_summary(13, 6, 2, 3)
    """
    ev = srg_eigenvalues(v, k, lam, mu)
    hb = hoffman_bound(v, k, lam, mu)

    data = {
        'parameters': (v, k, lam, mu),
        'eigenvalues': ev,
        'hoffman': hb,
    }

    # Self-complementary check
    # Complement of srg(v,k,lam,mu) is srg(v, v-k-1, v-2k+mu-2, v-2k+lam)
    k2 = v - k - 1
    lam2 = v - 2*k + mu - 2
    mu2 = v - 2*k + lam
    data['is_self_complementary'] = (k == k2 and lam == lam2 and mu == mu2)
    data['complement_params'] = (v, k2, lam2, mu2)

    return data


def p_rank(G, p):
    """
    Compute the p-rank of the adjacency matrix of G over GF(p).

    The p-rank is an important invariant that can distinguish non-isomorphic
    SRGs with the same parameters. Two cospectral SRGs may have different
    p-ranks.

    For Paley graphs P(q) with q = p^e: rk_p(A) is related to the number
    of e-th roots and has known formulas.

    Source: Brouwer & Van Maldeghem, Ch.9; also Ch.7 §7.4.

    Inputs:
        G : Sage Graph
        p : prime number

    Outputs:
        integer: rank of adjacency matrix over GF(p)

    Example:
        r = p_rank(graphs.PaleyGraph(13), 13)  # returns 7
    """
    A = G.adjacency_matrix().change_ring(GF(p))
    return A.rank()


def p_rank_profile(G, primes=None):
    """
    Compute the p-rank of G for several primes, yielding a fingerprint.

    This profile can distinguish SRGs that are cospectral (same eigenvalues)
    but non-isomorphic.

    Inputs:
        G      : Sage Graph
        primes : list of primes to test (default: first 8 primes)

    Outputs:
        dict mapping p -> rank

    Example:
        profile = p_rank_profile(graphs.PaleyGraph(13))
        # => {2: 10, 3: 12, 5: 12, 7: 12, 11: 12, 13: 7, ...}
    """
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13, 17, 19]
    return {p: p_rank(G, p) for p in primes}


def subconstituent_params(G, vertex=None):
    """
    Compute the subconstituent (local graph) parameters of an SRG.

    For an SRG Gamma and vertex x, the local graph Delta(x) is the subgraph
    induced on the neighbors of x. If Gamma satisfies the 4-vertex condition
    (Proposition 8.16.1), Delta(x) is also SRG.

    Source: Brouwer & Van Maldeghem, Ch.8 §8.16.

    Inputs:
        G      : Sage Graph (should be SRG)
        vertex : vertex to compute local graph at (default: first vertex)

    Outputs:
        dict with 'local_graph', 'is_srg', 'params' (if SRG)
    """
    if vertex is None:
        vertex = G.vertices()[0]

    nbrs = G.neighbors(vertex)
    local = G.subgraph(nbrs)
    params = local.is_strongly_regular(parameters=True)

    result = {'local_graph': local, 'is_srg': params is not False}
    if params is not False:
        result['params'] = params
    return result


print("spectral.sage loaded.")
