"""
srg_utils.sage — Shared SageMath utilities for SRG research.

Provides:
- Parameter feasibility checks
- Eigenvalue computation
- Isomorphism check wrappers
- Graph6 I/O helpers
- show_sage() display helper
- Adjacency matrix utilities
"""

from sage.all import *
from sage.graphs.strongly_regular_db import strongly_regular_graph
import os
import json
import tempfile


# ---------------------------------------------------------------------------
# Display helper
# ---------------------------------------------------------------------------

def show_sage(g, filename=None, figsize=(8, 6)):
    """
    Save a Sage graphics object to a PNG file and optionally display it.

    Inputs:
        g        : a Sage Graphics or GraphPlot object
        filename : path to save PNG (if None, creates a temp file and displays)
        figsize  : (width, height) in inches

    Outputs:
        path to saved PNG file

    Example:
        show_sage(G.plot(), filename='outputs/plots/graph.png')
    """
    if filename is None:
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as f:
            fname = f.name
        g.save(fname, figsize=figsize)
        try:
            from IPython.display import display, Image
            display(Image(fname))
        except Exception:
            pass
        return fname
    else:
        os.makedirs(os.path.dirname(os.path.abspath(filename)), exist_ok=True)
        g.save(filename, figsize=figsize)
        return filename


# ---------------------------------------------------------------------------
# Eigenvalue computation
# ---------------------------------------------------------------------------

def srg_eigenvalues(v, k, lam, mu):
    """
    Compute the restricted eigenvalues r, s and their multiplicities f, g
    for a strongly regular graph srg(v, k, lam, mu).

    Uses formulas:
        Delta = (lam - mu)^2 + 4*(k - mu)
        r, s  = ((lam - mu) +/- sqrt(Delta)) / 2
        f, g  = multiplicities satisfying f + g = v - 1 and f*r + g*s = -k

    Inputs:
        v, k, lam, mu : SRG parameters (integers)

    Outputs:
        dict with keys 'r', 's', 'f', 'g', 'delta', 'is_conference'

    Example:
        srg_eigenvalues(13, 6, 2, 3)
        # => {'r': 2, 's': -3, 'f': 6, 'g': 6, 'delta': 13, 'is_conference': False}
    """
    Delta = (lam - mu)**2 + 4 * (k - mu)
    sqrt_delta = sqrt(SR(Delta))

    # Check if Delta is a perfect square
    sqrt_d_int = Integer(Delta).isqrt()
    delta_is_square = (sqrt_d_int * sqrt_d_int == Delta)

    is_conference = False
    # Conference graph: Delta == v AND Delta is NOT a perfect square
    # (so eigenvalues are irrational: r,s = ±√v/2)
    if Delta == v and not delta_is_square:
        is_conference = True
        r_val = (lam - mu + sqrt_delta) / 2
        s_val = (lam - mu - sqrt_delta) / 2
        f_val = (v - 1) / 2
        g_val = (v - 1) / 2
    else:
        r_val = (lam - mu + sqrt_delta) / 2
        s_val = (lam - mu - sqrt_delta) / 2
        # Multiplicities: solve f + g = v-1, f*r + g*s = -k
        # => f = (-k - (v-1)*s) / (r - s)
        denom = r_val - s_val
        if denom == 0:
            return None
        f_val = (-k - (v - 1) * s_val) / denom
        g_val = (v - 1) - f_val

    return {
        'r': r_val,
        's': s_val,
        'f': f_val,
        'g': g_val,
        'delta': Delta,
        'is_conference': is_conference
    }


def eigenvalues_are_integral(v, k, lam, mu):
    """
    Check whether the SRG eigenvalues and multiplicities are integers
    (or half-integers for conference graphs).

    Inputs:
        v, k, lam, mu : SRG parameters

    Outputs:
        True if integrality conditions hold, False otherwise

    Example:
        eigenvalues_are_integral(13, 6, 2, 3)  # => True
    """
    ev = srg_eigenvalues(v, k, lam, mu)
    if ev is None:
        return False

    if ev['is_conference']:
        # f = g = (v-1)/2 must be an integer
        return (v - 1) % 2 == 0

    # r, s must be integers; f, g must be positive integers
    try:
        r = ZZ(ev['r'])
        s = ZZ(ev['s'])
        f = ZZ(ev['f'])
        g = ZZ(ev['g'])
        return f > 0 and g > 0
    except (TypeError, ValueError):
        return False


# ---------------------------------------------------------------------------
# Isomorphism checks
# ---------------------------------------------------------------------------

def canonical_label(G):
    """
    Return the canonical label of graph G (using Sage's canonical_label()).

    Inputs:
        G : a Sage Graph

    Outputs:
        canonical Graph object

    Example:
        C = canonical_label(graphs.PetersenGraph())
    """
    return G.canonical_label()


def are_isomorphic(G1, G2):
    """
    Check if two graphs are isomorphic using canonical labels.

    Inputs:
        G1, G2 : Sage Graph objects

    Outputs:
        True if isomorphic, False otherwise

    Example:
        are_isomorphic(graphs.PetersenGraph(), graphs.PetersenGraph())  # True
    """
    return G1.canonical_label() == G2.canonical_label()


def deduplicate_graphs(graph_list):
    """
    Remove isomorphic duplicates from a list of graphs.

    Inputs:
        graph_list : list of Sage Graph objects

    Outputs:
        list of pairwise non-isomorphic graphs (one representative per class)

    Example:
        unique = deduplicate_graphs([G1, G2, G3])
    """
    unique = []
    seen_labels = set()
    for G in graph_list:
        cl = G.canonical_label().graph6_string()
        if cl not in seen_labels:
            seen_labels.add(cl)
            unique.append(G)
    return unique


# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------

def verify_srg(G, v, k, lam, mu):
    """
    Verify that graph G is a strongly regular graph with given parameters.

    Inputs:
        G         : a Sage Graph
        v, k, lam, mu : expected SRG parameters

    Outputs:
        True if G is srg(v,k,lam,mu), False otherwise, with reason printed

    Example:
        verify_srg(G, 13, 6, 2, 3)
    """
    if G.order() != v:
        print(f"FAIL: order {G.order()} != {v}")
        return False
    if not G.is_regular():
        print("FAIL: not regular")
        return False
    if G.degree()[0] != k:
        print(f"FAIL: degree {G.degree()[0]} != {k}")
        return False
    params = G.is_strongly_regular(parameters=True)
    if params is False:
        print("FAIL: not strongly regular")
        return False
    if params != (v, k, lam, mu):
        print(f"FAIL: params {params} != ({v},{k},{lam},{mu})")
        return False
    return True


# ---------------------------------------------------------------------------
# Graph6 I/O
# ---------------------------------------------------------------------------

def save_graph6(G, filepath):
    """
    Save a single graph to a .g6 file.

    Inputs:
        G        : Sage Graph
        filepath : path to output .g6 file

    Outputs:
        None (writes file)

    Example:
        save_graph6(G, 'outputs/graphs/srg_13_6_2_3_001.g6')
    """
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        f.write(G.graph6_string() + '\n')


def save_graph6_list(graph_list, filepath):
    """
    Save a list of graphs to a .g6 file (one per line).

    Inputs:
        graph_list : list of Sage Graph objects
        filepath   : path to output .g6 file

    Outputs:
        None (writes file)

    Example:
        save_graph6_list([G1, G2], 'outputs/graphs/all_srg.g6')
    """
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        for G in graph_list:
            f.write(G.graph6_string() + '\n')


def load_graph6(filepath):
    """
    Load graphs from a .g6 file.

    Inputs:
        filepath : path to .g6 file

    Outputs:
        list of Sage Graph objects

    Example:
        graphs_list = load_graph6('outputs/graphs/srg_13_6_2_3.g6')
    """
    result = []
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip()
            if line:
                result.append(Graph(line))
    return result


# ---------------------------------------------------------------------------
# Adjacency matrix helpers
# ---------------------------------------------------------------------------

def adjacency_matrix_sorted(G):
    """
    Return the adjacency matrix of G with vertices sorted by BFS order from vertex 0.

    Inputs:
        G : Sage Graph

    Outputs:
        Sage matrix (over ZZ)

    Example:
        M = adjacency_matrix_sorted(G)
    """
    bfs_order = [v for v, _ in G.breadth_first_search(0)]
    return G.adjacency_matrix(vertices=bfs_order)


def save_matrix(M, filepath):
    """
    Save an adjacency matrix to a text file.

    Inputs:
        M        : Sage matrix or numpy array
        filepath : output file path (.txt)

    Outputs:
        None (writes file)

    Example:
        save_matrix(G.adjacency_matrix(), 'outputs/matrices/srg.txt')
    """
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        for row in M:
            f.write(' '.join(str(x) for x in row) + '\n')


# ---------------------------------------------------------------------------
# Summary JSON
# ---------------------------------------------------------------------------

def save_summary(data, filepath):
    """
    Save experiment summary as JSON.

    Inputs:
        data     : dict with experiment metadata
        filepath : output .json path

    Outputs:
        None (writes file)

    Example:
        save_summary({'experiment_id': 'EXP_001', ...}, 'outputs/summary.json')
    """
    os.makedirs(os.path.dirname(os.path.abspath(filepath)), exist_ok=True)
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)


print("srg_utils.sage loaded.")
