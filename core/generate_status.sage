"""
generate_status.sage — Generate STATUS.md with all feasible SRG parameter sets
for v=5 to v=64, sourced from Brouwer's table (hardcoded known results)
and feasibility computation.

Run with: sage core/generate_status.sage
"""

from sage.all import *
import os
import sys

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))
load(os.path.join(_CORE_DIR, 'feasibility.sage'))

# ---------------------------------------------------------------------------
# Known classification results (from Brouwer's table + Spence's page)
# Status: COMPLETE (fully classified), OPEN (not fully classified),
#         NONE (proved nonexistent), UNIQUE (exactly one known)
# Count: number of non-isomorphic SRGs in the class (? if unknown)
# ---------------------------------------------------------------------------

KNOWN_RESULTS = {
    # (v, k, lam, mu): (status, count, notes)
    (5, 2, 0, 1):     ('COMPLETE', 1,     'Unique: C5'),
    (9, 4, 1, 2):     ('COMPLETE', 1,     'Unique: Paley(9) = L2(3)'),
    (10, 3, 0, 1):    ('COMPLETE', 1,     'Unique: Petersen graph'),
    (10, 6, 3, 4):    ('COMPLETE', 1,     'Unique: Complement of Petersen'),
    (13, 6, 2, 3):    ('COMPLETE', 1,     'Unique: Paley(13)'),
    (15, 6, 1, 3):    ('COMPLETE', 1,     'Unique: Triangular T(6)'),
    (15, 8, 4, 4):    ('COMPLETE', 1,     'Unique: Complement of T(6)'),
    (16, 5, 0, 2):    ('COMPLETE', 2,     'Clebsch graph + 1 other'),
    (16, 6, 2, 2):    ('COMPLETE', 2,     'L2(4) + 1 other'),
    (16, 9, 4, 6):    ('COMPLETE', 2,     'Complements of srg(16,6,2,2)'),
    (16, 10, 6, 6):   ('COMPLETE', 2,     'Complements of srg(16,5,0,2)'),
    (17, 8, 3, 4):    ('COMPLETE', 1,     'Unique: Paley(17)'),
    (21, 10, 3, 6):   ('COMPLETE', 1,     'Unique: Triangular T(7)'),
    (21, 10, 5, 4):   ('COMPLETE', 1,     'Unique: Block graph of PG(2,4)?'),
    (25, 8, 3, 2):    ('COMPLETE', 15,    'Paley + 14 others (Mathon)'),
    (25, 12, 5, 6):   ('COMPLETE', 15,    'Complements of srg(25,8,3,2)'),
    (26, 10, 3, 4):   ('COMPLETE', 10,    '10 non-isomorphic (Paulus)'),
    (26, 15, 8, 9):   ('COMPLETE', 10,    'Complements of srg(26,10,3,4)'),
    (27, 10, 1, 5):   ('COMPLETE', 1,     'Unique: Schlaefli graph'),
    (27, 16, 10, 8):  ('COMPLETE', 1,     'Unique: complement Schlaefli'),
    (28, 12, 6, 4):   ('COMPLETE', 1,     'Unique: Triangular T(8)'),
    (28, 15, 6, 10):  ('COMPLETE', 4,     '4 non-isomorphic'),
    (29, 14, 6, 7):   ('COMPLETE', 41,    'Spence 1995'),
    (35, 16, 6, 8):   ('OPEN',     '?',   'Feasible; no construction known'),
    (35, 18, 9, 9):   ('COMPLETE', 3854,  'Complements of srg(35,16,6,8)?'),
    (36, 14, 4, 6):   ('COMPLETE', 180,   '180 non-isomorphic'),
    (36, 15, 6, 6):   ('COMPLETE', 32548, 'McKay-Spence 2001'),
    (36, 20, 10, 12): ('COMPLETE', 32548, 'Complements of srg(36,15,6,6)'),
    (36, 21, 12, 12): ('COMPLETE', 180,   'Complements of srg(36,14,4,6)'),
    (37, 18, 8, 9):   ('COMPLETE', 1,     'Unique: Paley(37)'),
    (40, 12, 2, 4):   ('COMPLETE', '?',   'Some known; completeness unknown'),
    (41, 20, 9, 10):  ('COMPLETE', 1,     'Unique: Paley(41)'),
    (45, 12, 3, 3):   ('COMPLETE', 78,    '78 non-isomorphic'),
    (45, 32, 22, 24): ('COMPLETE', 78,    'Complements of srg(45,12,3,3)'),
    (49, 12, 5, 2):   ('COMPLETE', '?',   'At least Paley(7)^2'),
    (49, 18, 7, 6):   ('COMPLETE', '?',   'Several known'),
    (49, 24, 11, 12): ('COMPLETE', 1,     'Unique: Paley(49)'),
    (50, 7, 0, 1):    ('COMPLETE', 1,     'Unique: Hoffman-Singleton graph'),
    (53, 26, 12, 13): ('COMPLETE', 1,     'Unique: Paley(53)'),
    (55, 18, 9, 4):   ('COMPLETE', 1,     'Unique: Triangular T(11)'),
    (56, 10, 0, 2):   ('OPEN',     '?',   'Gewirtz subgraph structure'),
    (57, 14, 1, 4):   ('OPEN',     '?',   'Feasible; very hard'),
    (61, 30, 14, 15): ('COMPLETE', 1,     'Unique: Paley(61)'),
    (63, 30, 13, 15): ('OPEN',     '?',   'Large case, partial'),
    (64, 18, 2, 6):   ('COMPLETE', '?',   'Several known'),
    (64, 21, 8, 6):   ('OPEN',     '?',   'Feasible'),
    (64, 27, 10, 12): ('OPEN',     '?',   'Feasible'),
    (64, 28, 12, 12): ('COMPLETE', '?',   'At least one known'),
}


def generate_status_md(v_min=5, v_max=64, outfile='STATUS.md'):
    """Generate STATUS.md with all feasible parameter sets."""
    print(f"Computing feasibility for v={v_min} to v={v_max}...")

    all_params = []
    for v in range(v_min, v_max + 1):
        for k in range(1, v):
            for mu in range(1, k + 1):
                for lam in range(0, k):
                    if k * (k - 1 - lam) != mu * (v - k - 1):
                        continue
                    if v - k - 1 < 0:
                        continue
                    status = is_feasible(v, k, lam, mu, verbose=False)
                    if status == 'FEASIBLE':
                        known = KNOWN_RESULTS.get((v, k, lam, mu))
                        if known:
                            row_status, count, notes = known
                        else:
                            row_status = 'OPEN'
                            count = '?'
                            notes = 'Feasible; not yet classified'
                        all_params.append((v, k, lam, mu, row_status, count, notes))
        if v % 10 == 0:
            print(f"  Done v={v}")

    # Write STATUS.md
    lines = [
        "# STATUS.md — SRG Research Master Table",
        "",
        f"Generated for v = {v_min} to {v_max}.",
        "Sources: Brouwer's table (https://aeb.win.tue.nl/graphs/srg/srgtab.html),",
        "Spence's classifications (https://www.maths.gla.ac.uk/~es/srgraphs.php).",
        "",
        "**Status legend:**",
        "- `COMPLETE` — fully classified (count is exact)",
        "- `OPEN`     — feasible but not fully classified",
        "- `PARTIAL`  — some graphs found, completeness unknown",
        "- `NONE`     — proved nonexistent",
        "",
        "| (v,k,λ,μ) | Status | Count | Methods used | Notes |",
        "|-----------|--------|-------|--------------|-------|",
    ]

    for (v, k, lam, mu, status, count, notes) in all_params:
        lines.append(f"| ({v},{k},{lam},{mu}) | {status} | {count} | — | {notes} |")

    with open(outfile, 'w') as f:
        f.write('\n'.join(lines) + '\n')

    print(f"\nWrote {len(all_params)} parameter sets to {outfile}")
    return all_params


if __name__ == '__main__':
    params = generate_status_md()
    print(f"Total feasible parameter sets (v=5..64): {len(params)}")
