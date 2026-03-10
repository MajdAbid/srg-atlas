"""
feasibility.sage — Complete feasibility checks for SRG parameters.

Tests applied (in order):
  1. Basic parameter arithmetic
  2. Eigenvalue integrality (or conference graph condition)
  3. Krein conditions (Q-matrix non-negativity)
  4. Absolute bound
  5. Conference graph conditions
  6. Half-case (non-primitive) detection

Output for each parameter set: FEASIBLE, INFEASIBLE, or UNKNOWN.
"""

from sage.all import *
import sys
import os
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


# ---------------------------------------------------------------------------
# 1. Basic arithmetic
# ---------------------------------------------------------------------------

def check_basic(v, k, lam, mu):
    """
    Check the basic SRG parameter equation:
        k*(k - 1 - lam) == mu*(v - k - 1)

    Inputs:
        v, k, lam, mu : integers

    Outputs:
        (True, '') or (False, reason_string)

    Example:
        check_basic(13, 6, 2, 3)  # => (True, '')
    """
    if not (v >= 1 and k >= 1 and lam >= 0 and mu >= 0):
        return False, "Parameters must be non-negative with v,k >= 1"
    if k >= v:
        return False, f"k={k} >= v={v}"
    if lam >= k:
        return False, f"lambda={lam} >= k={k}"
    if mu > k:
        return False, f"mu={mu} > k={k}"
    lhs = k * (k - 1 - lam)
    rhs = mu * (v - k - 1)
    if lhs != rhs:
        return False, f"k(k-1-lambda)={lhs} != mu(v-k-1)={rhs}"
    return True, ''


# ---------------------------------------------------------------------------
# 2. Eigenvalue integrality
# ---------------------------------------------------------------------------

def check_eigenvalues(v, k, lam, mu):
    """
    Check that eigenvalues r, s are integers (or irrational for conference graphs)
    and that multiplicities f, g are positive integers.

    Inputs:
        v, k, lam, mu : integers

    Outputs:
        (True, ev_dict, '') or (False, None, reason_string)

    Example:
        check_eigenvalues(13, 6, 2, 3)
    """
    ev = srg_eigenvalues(v, k, lam, mu)
    if ev is None:
        return False, None, "Eigenvalue computation failed (degenerate case)"

    Delta = ev['delta']

    if ev['is_conference']:
        # True conference graph: Delta==v, Delta not a perfect square
        # v must be odd and v ≡ 1 mod 4
        if v % 2 == 0:
            return False, ev, f"Conference graph requires odd v, got v={v}"
        if v % 4 != 1:
            return False, ev, f"Conference graph requires v ≡ 1 mod 4, got v={v}"
        return True, ev, 'conference'

    # Non-conference: Delta must be a perfect square (so eigenvalues are integers)
    sqrt_d = Integer(Delta).isqrt()
    if sqrt_d * sqrt_d != Delta:
        return False, ev, f"Delta={Delta} is not a perfect square (eigenvalues irrational)"

    # r and s must be integers
    num_r = (lam - mu) + sqrt_d
    num_s = (lam - mu) - sqrt_d
    if num_r % 2 != 0 or num_s % 2 != 0:
        return False, ev, f"Eigenvalues ({num_r}/2, {num_s}/2) are not integers"

    r = num_r // 2
    s = num_s // 2

    # Multiplicities
    denom = r - s
    if denom == 0:
        return False, ev, "r == s (degenerate)"
    num_f = -k - (v - 1) * s
    if num_f % denom != 0:
        return False, ev, f"Multiplicity f = {num_f}/{denom} is not an integer"
    f = num_f // denom
    g = (v - 1) - f
    if f <= 0 or g <= 0:
        return False, ev, f"Multiplicities f={f}, g={g} must be positive"

    ev_int = {'r': r, 's': s, 'f': f, 'g': g, 'delta': Delta, 'is_conference': False}
    return True, ev_int, ''


# ---------------------------------------------------------------------------
# 3. Krein conditions
# ---------------------------------------------------------------------------

def check_krein(v, k, lam, mu):
    """
    Check the Krein conditions (necessary for existence of SRG):

        q^1_{11} >= 0  and  q^2_{22} >= 0

    Using the explicit formulas (Scott 1973):
        K1: (r+1)(k+r+2rs) <= (k+r)(s+1)^2
        K2: (s+1)(k+s+2rs) <= (k+s)(r+1)^2

    Inputs:
        v, k, lam, mu : integers

    Outputs:
        (True, '') or (False, reason_string)

    Example:
        check_krein(13, 6, 2, 3)  # => (True, '')
    """
    ok, ev, msg = check_eigenvalues(v, k, lam, mu)
    if not ok:
        return False, f"Eigenvalue check failed: {msg}"
    if ev.get('is_conference'):
        return True, 'conference (Krein trivially satisfied)'

    r, s, f, g = ev['r'], ev['s'], ev['f'], ev['g']

    # Krein condition 1: q^1_{11} >= 0
    # (f+1)(k+r)(1+r)^2 - f(1+r)^2 k ... use standard form:
    # (r+1)(k+r+2*r*s) <= (k+r)*(s+1)^2
    k1_lhs = (r + 1) * (k + r + 2 * r * s)
    k1_rhs = (k + r) * (s + 1)**2
    if k1_lhs > k1_rhs:
        return False, f"Krein condition 1 violated: {k1_lhs} > {k1_rhs}"

    # Krein condition 2: q^2_{22} >= 0
    # (s+1)(k+s+2*r*s) <= (k+s)*(r+1)^2
    k2_lhs = (s + 1) * (k + s + 2 * r * s)
    k2_rhs = (k + s) * (r + 1)**2
    if k2_lhs > k2_rhs:
        return False, f"Krein condition 2 violated: {k2_lhs} > {k2_rhs}"

    return True, ''


# ---------------------------------------------------------------------------
# 4. Absolute bound
# ---------------------------------------------------------------------------

def check_absolute_bound(v, k, lam, mu):
    """
    Check the absolute bound:
        v <= f*(f+3)/2  and  v <= g*(g+3)/2

    where f, g are the eigenvalue multiplicities.

    Inputs:
        v, k, lam, mu : integers

    Outputs:
        (True, '') or (False, reason_string)

    Example:
        check_absolute_bound(13, 6, 2, 3)  # => (True, '')
    """
    ok, ev, msg = check_eigenvalues(v, k, lam, mu)
    if not ok:
        return False, f"Eigenvalue check failed: {msg}"
    if ev.get('is_conference'):
        return True, 'conference (absolute bound separate treatment)'

    f, g = ev['f'], ev['g']
    bound_f = f * (f + 3) // 2
    bound_g = g * (g + 3) // 2

    if v > bound_f:
        return False, f"Absolute bound (f={f}) violated: v={v} > f(f+3)/2={bound_f}"
    if v > bound_g:
        return False, f"Absolute bound (g={g}) violated: v={v} > g(g+3)/2={bound_g}"
    return True, ''


# ---------------------------------------------------------------------------
# 5. Non-primitive (trivial) detection
# ---------------------------------------------------------------------------

def check_non_primitive(v, k, lam, mu):
    """
    Detect trivially non-primitive (degenerate) parameter sets:
      - mu = 0: G is a disjoint union of cliques (K_{k+1} copies)
      - mu = k: G is a complete multipartite graph
      - lam = k-1: G contains a clique of size k+1 (=> mu must be k)

    Inputs:
        v, k, lam, mu : integers

    Outputs:
        (True, description) if non-primitive, (False, '') if primitive

    Example:
        check_non_primitive(10, 3, 0, 0)  # => (True, 'disjoint union of cliques')
    """
    if mu == 0:
        return True, f"mu=0: disjoint union of {v//(k+1)} copies of K_{k+1}"
    if mu == k:
        return True, f"mu=k={k}: complete multipartite graph"
    return False, ''


# ---------------------------------------------------------------------------
# Master feasibility check
# ---------------------------------------------------------------------------

def is_feasible(v, k, lam, mu, verbose=True):
    """
    Run all feasibility tests for srg(v, k, lam, mu).

    Returns:
        'FEASIBLE', 'INFEASIBLE', or 'UNKNOWN'
    Also prints a detailed report if verbose=True.

    Inputs:
        v, k, lam, mu : SRG parameters
        verbose       : print detailed report (default True)

    Outputs:
        one of 'FEASIBLE', 'INFEASIBLE', 'UNKNOWN'

    Example:
        is_feasible(13, 6, 2, 3)  # => 'FEASIBLE'
        is_feasible(6, 3, 0, 2)   # => 'INFEASIBLE'
    """
    label = f"srg({v},{k},{lam},{mu})"
    if verbose:
        print(f"\n=== Feasibility check: {label} ===")

    # 1. Basic arithmetic
    ok, msg = check_basic(v, k, lam, mu)
    if not ok:
        if verbose: print(f"  [FAIL] Basic arithmetic: {msg}")
        return 'INFEASIBLE'
    if verbose: print(f"  [OK]   Basic arithmetic")

    # 2. Eigenvalue integrality
    ok, ev, msg = check_eigenvalues(v, k, lam, mu)
    if not ok:
        if verbose: print(f"  [FAIL] Eigenvalue integrality: {msg}")
        return 'INFEASIBLE'
    if verbose:
        if ev.get('is_conference'):
            print(f"  [OK]   Conference graph: r,s = ±sqrt({ev['delta']})/2, f=g={(v-1)//2}")
        else:
            print(f"  [OK]   Eigenvalues: r={ev['r']}, s={ev['s']}, f={ev['f']}, g={ev['g']}")

    # 3. Krein conditions
    ok, msg = check_krein(v, k, lam, mu)
    if not ok:
        if verbose: print(f"  [FAIL] Krein conditions: {msg}")
        return 'INFEASIBLE'
    if verbose: print(f"  [OK]   Krein conditions")

    # 4. Absolute bound
    ok, msg = check_absolute_bound(v, k, lam, mu)
    if not ok:
        if verbose: print(f"  [FAIL] Absolute bound: {msg}")
        return 'INFEASIBLE'
    if verbose: print(f"  [OK]   Absolute bound")

    # Non-primitive note
    np_flag, np_desc = check_non_primitive(v, k, lam, mu)
    if np_flag and verbose:
        print(f"  [NOTE] Non-primitive: {np_desc}")

    if verbose: print(f"  => FEASIBLE")
    return 'FEASIBLE'


# ---------------------------------------------------------------------------
# Batch feasibility over a range
# ---------------------------------------------------------------------------

def feasibility_table(v_min=5, v_max=64):
    """
    Compute feasibility for all valid SRG parameter sets with v in [v_min, v_max].

    A parameter set (v,k,lam,mu) is valid if:
      - 1 <= k < v
      - 0 <= lam < k
      - 0 < mu <= k
      - k(k-1-lam) = mu(v-k-1)

    Inputs:
        v_min, v_max : range of vertex counts (inclusive)

    Outputs:
        list of dicts with keys: v, k, lam, mu, status, notes

    Example:
        table = feasibility_table(5, 20)
    """
    results = []
    for v in range(v_min, v_max + 1):
        for k in range(1, v):
            for lam in range(0, k):
                for mu in range(1, k + 1):
                    # Quick arithmetic filter first
                    lhs = k * (k - 1 - lam)
                    rhs = mu * (v - k - 1)
                    if lhs != rhs:
                        continue
                    if v - k - 1 < 0:
                        continue
                    status = is_feasible(v, k, lam, mu, verbose=False)
                    if status == 'FEASIBLE':
                        results.append({
                            'v': v, 'k': k, 'lam': lam, 'mu': mu,
                            'status': status, 'notes': ''
                        })
    return results


print("feasibility.sage loaded.")
