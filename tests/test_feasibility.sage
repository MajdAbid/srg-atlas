"""
test_feasibility.sage — Unit tests for core/feasibility.sage
"""

from sage.all import *
import os
import sys

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'feasibility.sage'))

failures = 0

def test(name, cond, msg=''):
    global failures
    if cond:
        print(f"  PASS: {name}")
    else:
        print(f"  FAIL: {name}" + (f" — {msg}" if msg else ''))
        failures += 1

print("=== test_feasibility.sage ===")

# Known FEASIBLE cases (from Brouwer's table)
feasible_cases = [
    (5, 2, 0, 1),
    (9, 4, 1, 2),
    (10, 3, 0, 1),
    (13, 6, 2, 3),
    (15, 6, 1, 3),
    (16, 5, 0, 2),
    (16, 6, 2, 2),
    (17, 8, 3, 4),
    (25, 8, 3, 2),
    (25, 12, 5, 6),
    (27, 10, 1, 5),
    (28, 12, 6, 4),
    (29, 14, 6, 7),
    (36, 15, 6, 6),
    (45, 12, 3, 3),
    (50, 7, 0, 1),
]

for params in feasible_cases:
    r = is_feasible(*params, verbose=False)
    test(f"FEASIBLE srg{params}", r == 'FEASIBLE', f"got {r}")

# Known INFEASIBLE cases
infeasible_cases = [
    # Arithmetic fails
    (7, 2, 0, 1),    # k(k-1-lam) = 2*1 = 2, mu(v-k-1) = 1*4 = 4 => fail
    # Eigenvalue integrality fails — delta not perfect square
    (11, 5, 2, 2),   # delta = (2-2)^2 + 4*(5-2) = 12, not square
]

for params in infeasible_cases:
    r = is_feasible(*params, verbose=False)
    test(f"INFEASIBLE srg{params}", r == 'INFEASIBLE', f"got {r}")

# Krein condition check: srg(36,15,6,6) should pass
r = is_feasible(36, 15, 6, 6, verbose=False)
test("Krein pass srg(36,15,6,6)", r == 'FEASIBLE')

# Absolute bound
r = is_feasible(13, 6, 2, 3, verbose=False)
test("Absolute bound srg(13,6,2,3)", r == 'FEASIBLE')

# Conference graph: srg(5,2,0,1) has irrational eigenvalues (C5 / Paley(5))
r = is_feasible(5, 2, 0, 1, verbose=False)
test("Conference graph srg(5,2,0,1)", r == 'FEASIBLE')

# srg(9,4,1,2) has integer eigenvalues despite Delta=v=9
r = is_feasible(9, 4, 1, 2, verbose=False)
test("Integral eigenvalues srg(9,4,1,2)", r == 'FEASIBLE')

print(f"\n{'OK' if failures == 0 else 'FAILED'}: {failures} failure(s)")
if failures > 0:
    sys.exit(1)
