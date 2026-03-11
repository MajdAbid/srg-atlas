"""
algebraic.sage — Algebraic constructions for strongly regular graphs.

Constructions implemented (inspired by Brouwer & Van Maldeghem, CUP 2022):
  - Paley graphs P(q), q prime power, q = 1 mod 4                [Ch.7 §7.4]
  - Triangular graphs T(n) = J(n,2)                              [Ch.1]
  - Latin square graphs LS_m(n) from transversal designs TD(m;n)  [Ch.8 §8.4]
  - Power residue graphs (cyclotomic, generalizes Paley)          [Ch.7 §7.5]
  - Kneser graphs K(n,2) and odd graphs                          [Ch.1]
  - Complement construction                                       [Ch.1]
  - Database lookup via Sage's strongly_regular_graph
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


def try_latin_square(v, k, lam, mu):
    """
    Attempt to construct a Latin square graph LS_m(n).

    LS_m(n): From a transversal design TD(m;n) (or equivalently m-2 MOLS of
    order n). Vertices are n^2 points; two vertices are adjacent iff they
    agree on one of the m groups.

    Parameters: v = n^2, k = m(n-1), lambda = (m-1)(m-2)+n-2, mu = m(m-1)

    Source: Brouwer & Van Maldeghem, Ch.8 §8.4.

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if construction succeeds, None otherwise
    """
    # v must be a perfect square
    n_sq = Integer(v).isqrt()
    if n_sq * n_sq != v:
        return None
    n = n_sq

    if n < 2:
        return None

    # Solve for m from mu = m(m-1)
    # m^2 - m - mu = 0 => m = (1 + sqrt(1+4*mu)) / 2
    disc = 1 + 4 * mu
    sqrt_disc = Integer(disc).isqrt()
    if sqrt_disc * sqrt_disc != disc:
        return None
    if (1 + sqrt_disc) % 2 != 0:
        return None
    m = (1 + sqrt_disc) // 2

    if m < 2 or m > n + 1:
        return None

    # Verify all parameters
    if k != m * (n - 1):
        return None
    if lam != (m - 1) * (m - 2) + n - 2:
        return None

    # Construct: use Sage's LatinSquareGraph if available, else OA-based
    try:
        from sage.graphs.generators.families import SquareGraph
    except ImportError:
        pass

    # Build from orthogonal array OA(m, n)
    try:
        from sage.combinat.designs.orthogonal_arrays import orthogonal_array
        OA = orthogonal_array(m, n)
        # OA is a list of m-tuples; each entry in {0, ..., n-1}
        # Vertices: n^2 points indexed as (group, value) for group 0.
        # Actually, the n^2 points are the rows of OA
        # Two rows are adjacent if they agree in some column.
        rows = [tuple(row) for row in OA]
        G = Graph(len(rows))
        for i in range(len(rows)):
            for j in range(i + 1, len(rows)):
                if any(rows[i][col] == rows[j][col] for col in range(m)):
                    G.add_edge(i, j)
        if verify_srg(G, v, k, lam, mu, verbose=False):
            return G
    except Exception:
        pass

    return None


def try_power_residue(v, k, lam, mu):
    """
    Attempt to construct a power residue (cyclotomic) graph.

    Given a prime power q and an integer e | (q-1) with e >= 2, the e-th
    power residue graph has vertex set GF(q), with x~y iff (x-y) is an
    e-th power in GF(q)*.

    This generalizes Paley graphs (e=2). For e=3 ("cubic residue graphs"):
      v=q, k=(q-1)/3, and the parameters depend on the decomposition
      q = a^2 + 3b^2 in certain cases.

    Source: Brouwer & Van Maldeghem, Ch.7 §7.5, Table 7.5.

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if construction succeeds, None otherwise
    """
    q = v
    if not is_prime_power(q):
        return None

    # Try each divisor e of q-1 with e >= 2
    for e in divisors(q - 1):
        if e < 2 or e > q - 1:
            continue
        if (q - 1) % e != 0:
            continue
        expected_k = (q - 1) // e
        if expected_k != k:
            continue

        # Build the Cayley graph on GF(q) with connection set = e-th powers
        F = GF(q, 'a')
        g = F.multiplicative_generator()
        # e-th powers = {g^(e*i) : i = 0, ..., (q-1)/e - 1}
        powers = set()
        for i in range((q - 1) // e):
            powers.add(g^(e * i))

        # For undirected graph we need D = -D (connection set closed under negation)
        neg_powers = set(-x for x in powers)
        if powers != neg_powers:
            continue

        # Build adjacency
        elems = list(F)
        G = Graph(q)
        elem_to_idx = {x: i for i, x in enumerate(elems)}
        for i, x in enumerate(elems):
            for j in range(i + 1, q):
                y = elems[j]
                if x - y in powers:
                    G.add_edge(i, j)

        if verify_srg(G, v, k, lam, mu, verbose=False):
            return G

    return None


def try_kneser(v, k, lam, mu):
    """
    Attempt to construct a Kneser graph K(n, r) with the given SRG parameters.

    K(n, r): vertices are r-element subsets of {1,...,n}; adjacent when disjoint.
    v = C(n,r), k = C(n-r, r).
    SRG only when r=2: K(n,2) = srg(C(n,2), C(n-2,2), C(n-4,2), C(n-3,2)).

    Source: Brouwer & Van Maldeghem, Ch.1.

    Inputs:
        v, k, lam, mu : target SRG parameters

    Outputs:
        Sage Graph if construction succeeds, None otherwise
    """
    # Try K(n, 2) for small n
    for n in range(5, 100):
        vv = binomial(n, 2)
        if vv > v:
            break
        if vv != v:
            continue
        kk = binomial(n - 2, 2)
        if kk != k:
            continue
        ll = binomial(n - 4, 2) if n >= 4 else 0
        mm = binomial(n - 3, 2) if n >= 3 else 0
        if ll == lam and mm == mu:
            G = graphs.KneserGraph(n, 2)
            if verify_srg(G, v, k, lam, mu, verbose=False):
                return G
    return None


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
    for builder in [try_paley, try_triangular, try_latin_square, try_kneser]:
        G_orig = builder(v, k_comp, lam_comp, mu_comp)
        if G_orig is not None:
            G_comp = G_orig.complement()
            if verify_srg(G_comp, v, k, lam, mu, verbose=False):
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
        ('latin_square', try_latin_square),
        ('power_residue', try_power_residue),
        ('kneser', try_kneser),
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
