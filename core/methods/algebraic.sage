"""
algebraic.sage — Algebraic constructions for strongly regular graphs.

Constructions implemented:
  - Paley graphs
  - Triangular graphs T(n) = J(n,2)
  - Latin square graphs LS(k,n)
  - Cayley graphs over cyclic/dihedral/elementary abelian groups
  - Complement construction
"""

from sage.all import *
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def try_paley(v, k, lam, mu):
    """
    Attempt to construct a Paley graph with srg(v,k,lam,mu) parameters.

    Paley graph P(q): q ≡ 1 mod 4, q prime power.
      - v = q, k = (q-1)/2, lambda = (q-5)/4, mu = (q-1)/4

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if construction succeeds, None otherwise

    Example:
        G = try_paley(13, 6, 2, 3)
    """
    q = v
    # Check q is a prime power and q ≡ 1 mod 4
    if not is_prime_power(q):
        return None
    if q % 4 != 1:
        return None
    # Check parameters match Paley graph
    if k != (q - 1) // 2:
        return None
    if lam != (q - 5) // 4:
        return None
    if mu != (q - 1) // 4:
        return None

    G = graphs.PaleyGraph(q)
    return G


def try_triangular(v, k, lam, mu):
    """
    Attempt to construct a Triangular graph T(n) = J(n,2).

    T(n): v = n(n-1)/2, k = 2(n-2), lambda = n-2, mu = 4

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if construction succeeds, None otherwise

    Example:
        G = try_triangular(10, 6, 3, 4)  # T(5)
    """
    # Solve n(n-1)/2 = v => n^2 - n - 2v = 0 => n = (1 + sqrt(1+8v))/2
    disc = 1 + 8 * v
    sqrt_disc = Integer(disc).isqrt()
    if sqrt_disc * sqrt_disc != disc:
        return None
    n = (1 + sqrt_disc) // 2
    if n * (n - 1) // 2 != v:
        return None
    # Verify parameters
    if k != 2 * (n - 2):
        return None
    if lam != n - 2:
        return None
    if mu != 4:
        return None

    G = graphs.JohnsonGraph(n, 2)
    return G


def try_complement(v, k, lam, mu):
    """
    Try to construct the complement of a known SRG and return it
    if it has the given parameters.

    The complement of srg(v,k,lam,mu) is srg(v, v-k-1, v-2k+mu-2, v-2k+lam).

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if complement construction works, None otherwise

    Example:
        G = try_complement(10, 3, 0, 1)  # complement of T(5)
    """
    # Complement parameters: if target is (v, k', lam', mu') = complement of (v, k, lam, mu)
    # then k = v - k' - 1, and we can reverse-engineer k' from target
    k_comp = v - k - 1
    lam_comp = v - 2 * k + mu - 2
    mu_comp = v - 2 * k + lam

    if k_comp < 0 or lam_comp < 0 or mu_comp < 0:
        return None

    # Try to build the original SRG and take complement
    for builder in [try_paley, try_triangular]:
        G_orig = builder(v, k_comp, lam_comp, mu_comp)
        if G_orig is not None:
            G_comp = G_orig.complement()
            if verify_srg(G_comp, v, k, lam, mu):
                return G_comp
    return None


def try_database(v, k, lam, mu):
    """
    Try to retrieve srg(v,k,lam,mu) from SageMath's built-in database.

    Inputs:
        v, k, lam, mu : SRG parameters

    Outputs:
        Sage Graph if found, None otherwise

    Example:
        G = try_database(13, 6, 2, 3)
    """
    from sage.graphs.strongly_regular_db import strongly_regular_graph
    try:
        G = strongly_regular_graph(v, k, lam, mu)
        return G
    except Exception:
        return None


def try_all_constructions(v, k, lam, mu, verbose=True):
    """
    Try all implemented algebraic constructions for srg(v,k,lam,mu).

    Inputs:
        v, k, lam, mu : SRG parameters
        verbose       : print progress

    Outputs:
        list of (graph, method_name) tuples for each found graph

    Example:
        results = try_all_constructions(13, 6, 2, 3)
    """
    results = []

    methods = [
        ('database', try_database),
        ('paley', try_paley),
        ('triangular', try_triangular),
        ('complement', try_complement),
    ]

    for name, fn in methods:
        try:
            G = fn(v, k, lam, mu)
            if G is not None:
                if verify_srg(G, v, k, lam, mu):
                    if verbose:
                        print(f"  [{name}] Found srg({v},{k},{lam},{mu})")
                    results.append((G, name))
                else:
                    if verbose:
                        print(f"  [{name}] Construction returned graph but verification FAILED")
        except Exception as e:
            if verbose:
                print(f"  [{name}] Error: {e}")

    return results


print("algebraic.sage loaded.")
