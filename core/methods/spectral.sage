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


print("spectral.sage loaded.")
