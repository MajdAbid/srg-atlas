"""
verify.sage — Canonical isomorphism check and parameter verification.

Double-checks every found graph using two independent methods:
  1. SageMath's is_strongly_regular()
  2. Manual eigenvalue check via adjacency matrix
"""

from sage.all import *
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def verify_via_eigenvalues(G, v, k, lam, mu):
    """
    Verify that G is srg(v,k,lam,mu) by computing the actual eigenvalues
    of its adjacency matrix and checking them against theory.

    Inputs:
        G         : Sage Graph
        v,k,lam,mu : expected SRG parameters

    Outputs:
        (True, notes) or (False, reason)

    Example:
        verify_via_eigenvalues(G, 13, 6, 2, 3)
    """
    if G.order() != v:
        return False, f"Order {G.order()} != {v}"

    # Use RDF (floating point) to handle both rational and irrational eigenvalues
    A_rdf = G.adjacency_matrix().change_ring(RDF)
    eigs_rdf = sorted(A_rdf.eigenvalues())

    # Cluster into distinct eigenvalues (tolerance 1e-6)
    distinct = []
    for e in eigs_rdf:
        if not distinct or abs(e - distinct[-1]) > 1e-6:
            distinct.append(e)

    if len(distinct) not in (2, 3):
        return False, f"Expected 2-3 distinct eigenvalues, got {len(distinct)}: {distinct}"

    # k must appear as an eigenvalue
    if not any(abs(e - k) < 1e-6 for e in distinct):
        return False, f"Degree {k} not in eigenvalues {[float(e) for e in distinct]}"

    # Expected r, s from theory
    ev = srg_eigenvalues(v, k, lam, mu)
    if ev is None:
        return False, "Could not compute expected eigenvalues"

    expected_r = float(ev['r'])
    expected_s = float(ev['s'])

    nontrivial = [e for e in distinct if abs(e - k) > 1e-6]
    if len(nontrivial) != 2:
        return False, f"Expected 2 nontrivial eigenvalues, got {nontrivial}"

    actual_r = max(nontrivial)
    actual_s = min(nontrivial)

    tol = 1e-4
    if abs(actual_r - expected_r) > tol or abs(actual_s - expected_s) > tol:
        return False, (f"Eigenvalue mismatch: expected ({expected_r:.4f},{expected_s:.4f}), "
                       f"got ({actual_r:.4f},{actual_s:.4f})")

    return True, f"Eigenvalues {k},{actual_r:.4f},{actual_s:.4f} match theory"


def full_verify(G, v, k, lam, mu):
    """
    Full verification of G as srg(v,k,lam,mu) using two independent methods.

    Method 1: SageMath's is_strongly_regular()
    Method 2: Eigenvalue check via adjacency matrix

    Inputs:
        G         : Sage Graph
        v,k,lam,mu : expected SRG parameters

    Outputs:
        dict with 'passed' (bool), 'methods' (list), 'notes' (str)

    Example:
        result = full_verify(G, 13, 6, 2, 3)
        assert result['passed']
    """
    results = {'passed': False, 'methods': [], 'notes': ''}

    # Method 1: Sage's built-in check
    params = G.is_strongly_regular(parameters=True)
    m1_ok = (params == (v, k, lam, mu))
    results['methods'].append({
        'name': 'sage_is_strongly_regular',
        'passed': m1_ok,
        'detail': str(params)
    })

    # Method 2: Eigenvalue check
    m2_ok, m2_note = verify_via_eigenvalues(G, v, k, lam, mu)
    results['methods'].append({
        'name': 'eigenvalue_check',
        'passed': m2_ok,
        'detail': m2_note
    })

    results['passed'] = m1_ok and m2_ok
    results['notes'] = '; '.join(m['detail'] for m in results['methods'])
    return results


print("verify.sage loaded.")
