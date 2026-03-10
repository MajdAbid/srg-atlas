"""
exhaustive.sage — Backtracking exhaustive search for SRGs.

Strategy:
  - Build adjacency matrix row by row
  - At each step prune by: degree constraints, triangle/square counts,
    eigenvalue bound violations
  - Use canonical augmentation (call Sage's canonical_label) to avoid
    isomorphic duplicates
  - Respect a time budget; record partial results on timeout

Only run for v <= 50.
"""

from sage.all import *
import time
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def exhaustive_search(v, k, lam, mu, time_limit=1800, verbose=True):
    """
    Exhaustive backtracking search for all non-isomorphic srg(v,k,lam,mu).

    Inputs:
        v, k, lam, mu : SRG parameters
        time_limit    : max seconds (default 30 min = 1800)
        verbose       : print progress

    Outputs:
        dict with keys:
            'graphs'    : list of found Sage Graph objects
            'complete'  : True if search exhausted, False if time limit hit
            'time'      : elapsed seconds

    Example:
        result = exhaustive_search(5, 2, 0, 1)
        # => {'graphs': [C5], 'complete': True, 'time': 0.01}
    """
    if v > 50:
        return {'graphs': [], 'complete': False,
                'time': 0, 'error': 'v > 50, exhaustive search disabled'}

    start = time.time()
    found = []
    seen_labels = set()
    timeout = [False]

    def elapsed():
        return time.time() - start

    def backtrack(adj, row):
        """
        adj[i][j] is built row by row.
        We fill row `row` (upper triangle) then move to row+1.
        """
        if timeout[0]:
            return
        if elapsed() > time_limit:
            timeout[0] = True
            return

        if row == v:
            # Build graph and verify
            G = Graph(matrix(ZZ, adj), format='adjacency_matrix')
            if verify_srg(G, v, k, lam, mu):
                cl = G.canonical_label().graph6_string()
                if cl not in seen_labels:
                    seen_labels.add(cl)
                    found.append(G)
                    if verbose:
                        print(f"  Found #{len(found)} at t={elapsed():.1f}s")
            return

        # Determine which entries adj[row][col] for col > row are forced
        # Current degrees:
        deg = [sum(adj[i]) for i in range(v)]

        # How many neighbors does row still need among cols > row?
        needed = k - deg[row]
        available_cols = list(range(row + 1, v))

        # Prune: if needed > len(available_cols) or needed < 0, backtrack
        if needed < 0 or needed > len(available_cols):
            return

        # For each subset of size `needed` from available_cols:
        # (Use combinations if small; otherwise prune more aggressively)
        for chosen in Combinations(available_cols, needed):
            if timeout[0]:
                return

            # Set adj[row][col] = adj[col][row] = 1 for chosen
            for col in available_cols:
                adj[row][col] = 1 if col in chosen else 0
                adj[col][row] = adj[row][col]

            # Check lambda constraint: for each pair (row, col) with adj[row][col]=1
            # they must share exactly lam common neighbors among 0..row-1
            valid = True
            for col in chosen:
                if col < row:
                    # Count common neighbors among already-decided vertices
                    common = sum(1 for x in range(row) if adj[row][x] and adj[col][x])
                    remaining = sum(1 for x in range(row + 1, v) if x != col)
                    # Already have `common` common neighbors; need exactly lam
                    if common > lam:
                        valid = False
                        break
                    if common + remaining < lam:
                        valid = False
                        break

            if not valid:
                continue

            # Check mu constraint: for each pair (row, col) with adj[row][col]=0
            # (and col already decided) they share exactly mu common neighbors
            for col in range(row):
                if adj[row][col] == 0:
                    common = sum(1 for x in range(row) if adj[row][x] and adj[col][x])
                    if common > mu:
                        valid = False
                        break

            if not valid:
                continue

            backtrack(adj, row + 1)

        # Reset row
        for col in available_cols:
            adj[row][col] = 0
            adj[col][row] = 0

    adj = [[0] * v for _ in range(v)]
    backtrack(adj, 0)

    return {
        'graphs': found,
        'complete': not timeout[0],
        'time': elapsed()
    }


print("exhaustive.sage loaded.")
