"""
generate_status.sage — Generate STATUS.md from Brouwer's table (ground truth).

Source: https://aeb.win.tue.nl/graphs/srg/srgtab.html
        https://aeb.win.tue.nl/graphs/srg/srgtab51-100.html

Symbol key from Brouwer's table:
  N! = N graphs found, completely classified (green)
  !  = completely classified, count=1 (unique) unless noted
  +  = at least one known, classification incomplete (green, partial)
  -  = proved nonexistent (red)
  blank complement row = same status/count as primary row above it

Only PRIMITIVE SRGs listed: 0 < mu < k.

Run with: sage core/generate_status.sage
"""

from sage.all import *
import os, sys

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))

# ---------------------------------------------------------------------------
# BROUWER dict — ground truth for v=5..64, primitive SRGs only.
# Complement pairs listed together; complements inherit status and count.
#
# Format: (v,k,lam,mu): (status, count, notes)
# ---------------------------------------------------------------------------

BROUWER = {

    # --- v=5 (self-complementary) ---
    (5,  2,  0,  1):  ('COMPLETE', 1,      'Unique: C5 (conference, self-complementary)'),

    # --- v=9 ---
    (9,  4,  1,  2):  ('COMPLETE', 1,      'Unique: Paley(9) = L2(3)'),

    # --- v=10 ---
    (10, 3,  0,  1):  ('COMPLETE', 1,      'Unique: Petersen graph'),
    (10, 6,  3,  4):  ('COMPLETE', 1,      'Unique: complement of Petersen'),

    # --- v=13 ---
    (13, 6,  2,  3):  ('COMPLETE', 1,      'Unique: Paley(13) (conference)'),

    # --- v=15 ---
    (15, 6,  1,  3):  ('COMPLETE', 1,      'Unique: Triangular T(6)'),
    (15, 8,  4,  4):  ('COMPLETE', 1,      'Unique: complement of T(6)'),

    # --- v=16 ---
    (16, 5,  0,  2):  ('COMPLETE', 1,      'Unique: Clebsch graph'),
    (16, 10, 6,  6):  ('COMPLETE', 1,      'Unique: complement of Clebsch'),
    (16, 6,  2,  2):  ('COMPLETE', 2,      'L2(4) and Shrikhande graph'),
    (16, 9,  4,  6):  ('COMPLETE', 2,      'Complements of srg(16,6,2,2)'),

    # --- v=17 ---
    (17, 8,  3,  4):  ('COMPLETE', 1,      'Unique: Paley(17) (conference)'),

    # --- v=21 ---
    (21, 10, 3,  6):  ('COMPLETE', 1,      'Unique: Triangular T(7)'),
    (21, 10, 5,  4):  ('COMPLETE', 1,      'Unique: complement of T(7)'),
    (21, 10, 4,  5):  ('NONE',     0,      'Proved nonexistent (self-complementary case)'),

    # --- v=25 ---
    (25, 8,  3,  2):  ('COMPLETE', 15,     'Mathon 1975'),
    (25, 16, 9,  12): ('COMPLETE', 15,     'Complements of srg(25,8,3,2); OA(5,4)'),
    (25, 12, 5,  6):  ('COMPLETE', 15,     'Includes Paley(25); vanLint-Schrijver'),

    # --- v=26 ---
    (26, 10, 3,  4):  ('COMPLETE', 10,     'Paulus 1973'),
    (26, 15, 8,  9):  ('COMPLETE', 10,     'Complements of srg(26,10,3,4)'),

    # --- v=27 ---
    (27, 10, 1,  5):  ('COMPLETE', 1,      'Unique: Schläfli graph'),
    (27, 16, 10, 8):  ('COMPLETE', 1,      'Unique: complement of Schläfli'),

    # --- v=28 ---
    (28, 9,  0,  4):  ('NONE',     0,      'Proved nonexistent'),
    (28, 18, 12, 10): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (28, 12, 6,  4):  ('COMPLETE', 4,      'T(8) + 3 Chang graphs'),
    (28, 15, 6,  10): ('COMPLETE', 4,      'Complements of srg(28,12,6,4)'),

    # --- v=29 ---
    (29, 14, 6,  7):  ('COMPLETE', 41,     'Spence 1995 (conference)'),

    # --- v=33 ---
    (33, 16, 7,  8):  ('NONE',     0,      'Proved nonexistent (conference)'),

    # --- v=35 ---
    (35, 16, 6,  8):  ('COMPLETE', 3854,   'Completely classified (Spence et al.)'),
    (35, 18, 9,  9):  ('COMPLETE', 3854,   'Complements of srg(35,16,6,8)'),

    # --- v=36 ---
    (36, 10, 4,  2):  ('COMPLETE', 1,      'Unique: GQ(2,4) point graph'),
    (36, 25, 16, 20): ('COMPLETE', 1,      'Unique: complement of srg(36,10,4,2)'),
    (36, 14, 4,  6):  ('COMPLETE', 180,    'Completely classified'),
    (36, 21, 12, 12): ('COMPLETE', 180,    'Complements of srg(36,14,4,6)'),
    (36, 14, 7,  4):  ('COMPLETE', 1,      'Unique: Triangular T(9)'),
    (36, 21, 10, 15): ('COMPLETE', 1,      'Unique: complement of T(9)'),
    (36, 15, 6,  6):  ('COMPLETE', 32548,  'McKay-Spence 2001'),
    (36, 20, 10, 12): ('COMPLETE', 32548,  'Complements of srg(36,15,6,6)'),

    # --- v=37 ---
    (37, 18, 8,  9):  ('PARTIAL',  '?',    'Some known (conference); classification open'),

    # --- v=40 ---
    (40, 12, 2,  4):  ('COMPLETE', 28,     'Spence 2000'),
    (40, 27, 18, 18): ('COMPLETE', 28,     'Complements of srg(40,12,2,4)'),

    # --- v=41 ---
    (41, 20, 9,  10): ('PARTIAL',  '?',    'Some known (conference); classification open'),

    # --- v=45 ---
    (45, 12, 3,  3):  ('COMPLETE', 78,     'Coolsaet-Degraer-Moorhouse 2006'),
    (45, 32, 22, 24): ('COMPLETE', 78,     'Complements of srg(45,12,3,3)'),
    (45, 16, 8,  4):  ('COMPLETE', 1,      'Unique: Triangular T(10)'),
    (45, 28, 15, 21): ('COMPLETE', 1,      'Unique: complement of T(10)'),
    (45, 22, 10, 11): ('PARTIAL',  '?',    'Some known (conference); classification open'),

    # --- v=49 ---
    (49, 12, 5,  2):  ('COMPLETE', '?',    'Completely classified; count uncertain'),
    (49, 36, 25, 30): ('COMPLETE', '?',    'Complements of srg(49,12,5,2)'),
    (49, 16, 3,  6):  ('NONE',     0,      'Proved nonexistent'),
    (49, 32, 21, 20): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (49, 18, 7,  6):  ('PARTIAL',  '?',    'Some known; classification open'),
    (49, 30, 17, 20): ('PARTIAL',  '?',    'Some known; complement of srg(49,18,7,6)'),
    (49, 24, 11, 12): ('PARTIAL',  '?',    'Some known (conference, self-complementary)'),

    # --- v=50 ---
    (50, 7,  0,  1):  ('COMPLETE', 1,      'Unique: Hoffman-Singleton graph'),
    (50, 42, 35, 36): ('COMPLETE', 1,      'Unique: complement of Hoffman-Singleton'),
    (50, 21, 4,  12): ('NONE',     0,      'Proved nonexistent'),
    (50, 28, 18, 12): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (50, 21, 8,  9):  ('PARTIAL',  '?',    'Some known (conference); classification open'),
    (50, 28, 15, 16): ('PARTIAL',  '?',    'Some known; complement of srg(50,21,8,9)'),

    # --- v=53 ---
    (53, 26, 12, 13): ('PARTIAL',  '?',    'Some known (Paley(53), conference); classification open'),

    # --- v=55 ---
    (55, 18, 9,  4):  ('COMPLETE', 1,      'Unique: Triangular T(11)'),
    (55, 36, 21, 28): ('COMPLETE', 1,      'Unique: complement of T(11)'),

    # --- v=56 ---
    (56, 10, 0,  2):  ('COMPLETE', 1,      'Unique: Gewirtz graph'),
    (56, 45, 36, 36): ('COMPLETE', 1,      'Unique: complement of Gewirtz'),
    (56, 22, 3,  12): ('NONE',     0,      'Proved nonexistent'),
    (56, 33, 22, 15): ('NONE',     0,      'Proved nonexistent (complement of above)'),

    # --- v=57 ---
    (57, 14, 1,  4):  ('NONE',     0,      'Proved nonexistent'),
    (57, 42, 31, 30): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (57, 24, 11, 9):  ('PARTIAL',  '?',    'Some known; classification open'),
    (57, 32, 16, 20): ('PARTIAL',  '?',    'Some known; complement of srg(57,24,11,9)'),
    (57, 28, 13, 14): ('NONE',     0,      'Proved nonexistent (conference)'),

    # --- v=61 ---
    (61, 30, 14, 15): ('PARTIAL',  '?',    'Some known (Paley(61), conference); classification open'),

    # --- v=63 ---
    (63, 22, 1,  11): ('NONE',     0,      'Proved nonexistent'),
    (63, 40, 28, 20): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (63, 30, 13, 15): ('PARTIAL',  '?',    'Some known; classification open'),
    (63, 32, 16, 16): ('PARTIAL',  '?',    'Some known; complement of srg(63,30,13,15)'),

    # --- v=64 ---
    (64, 14, 6,  2):  ('COMPLETE', 1,      'Unique'),
    (64, 49, 36, 42): ('COMPLETE', 1,      'Unique: complement of srg(64,14,6,2)'),
    (64, 18, 2,  6):  ('COMPLETE', 167,    'Completely classified'),
    (64, 45, 32, 30): ('COMPLETE', 167,    'Complements of srg(64,18,2,6)'),
    (64, 21, 0,  10): ('NONE',     0,      'Proved nonexistent'),
    (64, 42, 30, 22): ('NONE',     0,      'Proved nonexistent (complement of above)'),
    (64, 21, 8,  6):  ('PARTIAL',  '?',    'Some known; classification open'),
    (64, 42, 26, 30): ('PARTIAL',  '?',    'Some known; complement of srg(64,21,8,6)'),
    (64, 27, 10, 12): ('PARTIAL',  '?',    'Some known; classification open'),
    (64, 36, 20, 20): ('PARTIAL',  '?',    'Some known; complement of srg(64,27,10,12)'),
    (64, 28, 12, 12): ('PARTIAL',  '?',    'Some known; classification open'),
    (64, 35, 18, 20): ('PARTIAL',  '?',    'Some known; complement of srg(64,28,12,12)'),
    (64, 30, 18, 10): ('NONE',     0,      'Proved nonexistent'),
    (64, 33, 12, 22): ('NONE',     0,      'Proved nonexistent (complement of above)'),
}


def generate_status_md(outfile='STATUS.md'):
    """Write STATUS.md from BROUWER dict, sorted by (v, k)."""
    entries = sorted(BROUWER.items(), key=lambda x: (x[0][0], x[0][1]))

    lines = [
        "# STATUS.md — SRG Research Master Table",
        "",
        "Ground truth: Brouwer's table https://aeb.win.tue.nl/graphs/srg/srgtab.html",
        "              https://aeb.win.tue.nl/graphs/srg/srgtab51-100.html",
        "",
        "Only **primitive** SRGs listed (0 < μ < k).",
        "Non-primitive cases (μ=0 or μ=k) are excluded.",
        "",
        "**Status legend:**",
        "- `COMPLETE` — fully classified; count is exact",
        "- `PARTIAL`  — some graphs found, classification incomplete",
        "- `NONE`     — proved nonexistent",
        "",
        "| (v,k,λ,μ) | Status | Count | Methods used | Notes |",
        "|-----------|--------|-------|--------------|-------|",
    ]

    for (v, k, lam, mu), (status, count, notes) in entries:
        lines.append(f"| ({v},{k},{lam},{mu}) | {status} | {count} | — | {notes} |")

    with open(outfile, 'w') as f:
        f.write('\n'.join(lines) + '\n')

    total    = len(entries)
    complete = sum(1 for _, (s,_,_) in entries if s == 'COMPLETE')
    partial  = sum(1 for _, (s,_,_) in entries if s == 'PARTIAL')
    none_    = sum(1 for _, (s,_,_) in entries if s == 'NONE')

    print(f"Wrote {total} entries to {outfile}")
    print(f"  COMPLETE: {complete}  PARTIAL: {partial}  NONE: {none_}")
    return entries


if __name__ == '__main__':
    generate_status_md()
