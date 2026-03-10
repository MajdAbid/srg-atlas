"""
test_utils.sage — Unit tests for core/srg_utils.sage
"""

from sage.all import *
import os
import sys
import tempfile

# Load utilities
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))

failures = 0

def test(name, cond, msg=''):
    global failures
    if cond:
        print(f"  PASS: {name}")
    else:
        print(f"  FAIL: {name}" + (f" — {msg}" if msg else ''))
        failures += 1

print("=== test_utils.sage ===")

# --- srg_eigenvalues ---
# srg(13,6,2,3): Delta=13=v, 13 not a perfect square => conference graph
# eigenvalues r=(-1+sqrt(13))/2, s=(-1-sqrt(13))/2 (irrational)
ev = srg_eigenvalues(13, 6, 2, 3)
test("Paley13 is_conference", ev['is_conference'])
test("Paley13 multiplicity f", ev['f'] == 6)
test("Paley13 multiplicity g", ev['g'] == 6)
test("Paley13 eigenvalue r approx", abs(float(ev['r']) - float((-1+sqrt(SR(13)))/2)) < 0.001)

ev5 = srg_eigenvalues(5, 2, 0, 1)
test("C5 eigenvalues exist", ev5 is not None)

# srg(9,4,1,2): Delta=9=v, but sqrt(9)=3 is integer => NOT conference, integral eigenvalues
ev9 = srg_eigenvalues(9, 4, 1, 2)
test("srg(9,4,1,2) r=1", ev9['r'] == 1)
test("srg(9,4,1,2) s=-2", ev9['s'] == -2)
test("srg(9,4,1,2) not_conference", ev9['is_conference'] == False)

# srg(5,2,0,1): Delta=5=v, 5 not a perfect square => conference graph (C5)
ev5c = srg_eigenvalues(5, 2, 0, 1)
test("srg(5,2,0,1) is_conference", ev5c['is_conference'] == True)

# srg(37,18,8,9): another conference graph? Delta=(8-9)^2+4*(18-9)=1+36=37=v, 37 not square
ev37 = srg_eigenvalues(37, 18, 8, 9)
test("srg(37,18,8,9) is_conference", ev37['is_conference'] == True)

# --- eigenvalues_are_integral ---
test("srg(13,6,2,3) integral", eigenvalues_are_integral(13, 6, 2, 3))
test("srg(5,2,0,1) integral", eigenvalues_are_integral(5, 2, 0, 1))

# --- are_isomorphic ---
G1 = graphs.PaleyGraph(13)
G2 = graphs.PaleyGraph(13)
test("Paley13 isomorphic to itself", are_isomorphic(G1, G2))

G3 = graphs.PetersenGraph()
G4 = graphs.CycleGraph(5)
test("Petersen != C5", not are_isomorphic(G3, G4))

# --- deduplicate_graphs ---
G_a = graphs.PaleyGraph(13)
G_b = graphs.PaleyGraph(13)
unique = deduplicate_graphs([G_a, G_b])
test("Dedup same graph => 1 copy", len(unique) == 1)

unique2 = deduplicate_graphs([G3, G4])  # Petersen and C5
test("Dedup different graphs => 2 copies", len(unique2) == 2)

# --- verify_srg ---
G = graphs.PaleyGraph(13)
test("verify_srg Paley13", verify_srg(G, 13, 6, 2, 3))
test("verify_srg wrong params", not verify_srg(G, 13, 6, 2, 4))

# --- graph6 I/O ---
with tempfile.NamedTemporaryFile(suffix='.g6', delete=False, mode='w') as f:
    fname = f.name

save_graph6(G, fname)
loaded = load_graph6(fname)
os.unlink(fname)
test("Graph6 roundtrip single", len(loaded) == 1 and are_isomorphic(G, loaded[0]))

glist = [graphs.CycleGraph(5), graphs.PaleyGraph(13)]
with tempfile.NamedTemporaryFile(suffix='.g6', delete=False, mode='w') as f:
    fname2 = f.name
save_graph6_list(glist, fname2)
loaded2 = load_graph6(fname2)
os.unlink(fname2)
test("Graph6 roundtrip list", len(loaded2) == 2)

print(f"\n{'OK' if failures == 0 else 'FAILED'}: {failures} failure(s)")
if failures > 0:
    sys.exit(1)
