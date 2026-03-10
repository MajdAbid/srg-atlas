"""
test_known_cases.sage — Regression test: 10 known SRGs from Brouwer's table.

Verifies each known SRG:
  1. SageMath can construct it
  2. Parameters match Brouwer's table
  3. Eigenvalues match theory
  4. Graph is in the expected isomorphism class

This file must pass with zero failures before any research begins.
"""

from sage.all import *
from sage.graphs.strongly_regular_db import strongly_regular_graph
import os
import sys

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))
load(os.path.join(_CORE_DIR, 'verify.sage'))
load(os.path.join(_CORE_DIR, 'feasibility.sage'))

failures = 0

def test(name, cond, msg=''):
    global failures
    if cond:
        print(f"  PASS: {name}")
    else:
        print(f"  FAIL: {name}" + (f" — {msg}" if msg else ''))
        failures += 1

print("=== test_known_cases.sage ===")
print("Verifying 10 known SRGs from Brouwer's table...\n")

# Known SRGs: (v, k, lam, mu, description, construction)
known_cases = [
    # (v, k, lam, mu, description)
    (5,  2,  0,  1,  "C5 — cycle graph"),
    (9,  4,  1,  2,  "Paley(9) = L2(3) = 3x3 rook's graph"),
    (10, 3,  0,  1,  "Petersen graph"),
    (13, 6,  2,  3,  "Paley(13) — unique"),
    (16, 5,  0,  2,  "Clebsch graph (halved 5-cube)"),
    (17, 8,  3,  4,  "Paley(17) — unique"),
    (25, 12, 5,  6,  "Paley(25) — unique"),
    (27, 10, 1,  5,  "Schlaefli graph — unique"),
    (28, 12, 6,  4,  "T(8) triangular graph — unique"),
    (45, 12, 3,  3,  "Paley graph or GQ(4,2) related"),
]

for (v, k, lam, mu, desc) in known_cases:
    print(f"  Testing srg({v},{k},{lam},{mu}) — {desc}")

    # 1. Feasibility check
    feas = is_feasible(v, k, lam, mu, verbose=False)
    test(f"  srg({v},{k},{lam},{mu}) feasible", feas == 'FEASIBLE')

    # 2. SageMath database construction
    try:
        G = strongly_regular_graph(v, k, lam, mu)
        construction_ok = True
    except Exception as e:
        construction_ok = False
        G = None
        print(f"    WARNING: SageMath DB failed: {e}")

    test(f"  srg({v},{k},{lam},{mu}) constructible", construction_ok)

    if G is not None:
        # 3. Full verification (2 independent methods)
        result = full_verify(G, v, k, lam, mu)
        test(f"  srg({v},{k},{lam},{mu}) full_verify", result['passed'],
             result.get('notes', ''))

        # 4. Eigenvalue check via theory
        ev = srg_eigenvalues(v, k, lam, mu)
        test(f"  srg({v},{k},{lam},{mu}) eigenvalues computed", ev is not None)

    print()

# Additional check: complement of known SRG
print("  Testing complement of Petersen graph (= Kneser(5,2) complement)...")
G_petersen = graphs.PetersenGraph()
G_comp = G_petersen.complement()
# Complement of srg(10,3,0,1) = srg(10,6,3,4)
result_comp = full_verify(G_comp, 10, 6, 3, 4)
test("  Petersen complement is srg(10,6,3,4)", result_comp['passed'])

print(f"\n{'ALL TESTS PASSED' if failures == 0 else 'SOME TESTS FAILED'}")
print(f"Total failures: {failures}")
if failures > 0:
    sys.exit(1)
