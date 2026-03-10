# STATUS.md — SRG Research Master Table

Ground truth: Brouwer's table https://aeb.win.tue.nl/graphs/srg/srgtab.html
Spence's classifications: https://www.maths.gla.ac.uk/~es/srgraphs.php

Only **primitive** SRGs listed (0 < μ < k).
Non-primitive (disjoint cliques μ=0, complete multipartite μ=k) excluded.

**Status legend:**
- `COMPLETE` — fully classified; count is exact
- `OPEN`     — feasible but not fully classified
- `PARTIAL`  — some graphs found, completeness unknown
- `NONE`     — proved nonexistent

| (v,k,λ,μ) | Status | Count | Methods used | Notes |
|-----------|--------|-------|--------------|-------|
| (5,2,0,1) | COMPLETE | 1 | — | Unique: C5 (Paley(5), conference) |
| (9,4,1,2) | COMPLETE | 1 | — | Unique: Paley(9) = L2(3) |
| (10,3,0,1) | COMPLETE | 1 | — | Unique: Petersen graph |
| (10,6,3,4) | COMPLETE | 1 | — | Unique: complement of Petersen |
| (13,6,2,3) | COMPLETE | 1 | — | Unique: Paley(13) (conference) |
| (15,6,1,3) | COMPLETE | 1 | — | Unique: Triangular T(6) |
| (15,8,4,4) | COMPLETE | 1 | — | Unique: complement of T(6) |
| (16,5,0,2) | COMPLETE | 2 | — | Clebsch graph + 1 other |
| (16,6,2,2) | COMPLETE | 2 | — | L2(4) + 1 other |
| (16,9,4,6) | COMPLETE | 2 | — | Complements of srg(16,6,2,2) |
| (16,10,6,6) | COMPLETE | 2 | — | Complements of srg(16,5,0,2) |
| (17,8,3,4) | COMPLETE | 1 | — | Unique: Paley(17) (conference) |
| (21,10,3,6) | COMPLETE | 1 | — | Unique: Triangular T(7) |
| (21,10,5,4) | OPEN | ? | — | Existence unknown |
| (21,10,4,5) | NONE | 0 | — | Proved nonexistent (Deza-Frankl 1986) |
| (25,8,3,2) | COMPLETE | 15 | — | Mathon 1975; includes Paley(25) |
| (25,12,5,6) | COMPLETE | 15 | — | Complements of srg(25,8,3,2) |
| (25,16,9,12) | OPEN | ? | — | Existence unknown |
| (26,10,3,4) | COMPLETE | 10 | — | Paulus 1973 |
| (26,15,8,9) | COMPLETE | 10 | — | Complements of srg(26,10,3,4) |
| (27,10,1,5) | COMPLETE | 1 | — | Unique: Schläfli graph |
| (27,15,8,9) | OPEN | ? | — | Existence unknown |
| (27,16,10,8) | COMPLETE | 1 | — | Unique: complement of Schläfli |
| (28,9,0,4) | NONE | 0 | — | Proved nonexistent |
| (28,12,6,4) | COMPLETE | 4 | — | T(8) + 3 Chang graphs |
| (28,15,6,10) | OPEN | ? | — | Existence unknown |
| (28,18,12,10) | OPEN | ? | — | Existence unknown |
| (29,14,6,7) | COMPLETE | 41 | — | Spence 1995 (conference) |
| (33,16,7,8) | NONE | 0 | — | Proved nonexistent (conference) |
| (35,16,6,8) | OPEN | ? | — | No example known; existence open |
| (35,18,9,9) | PARTIAL | 3854+ | — | At least 3854 known; incomplete |
| (36,10,4,2) | COMPLETE | 1 | — | Unique: GQ(2,4) point graph |
| (36,14,7,4) | COMPLETE | 1 | — | Unique: Triangular T(9) |
| (36,14,4,6) | COMPLETE | 180 | — | Classified |
| (36,15,6,6) | COMPLETE | 32548 | — | McKay-Spence 2001 |
| (36,20,10,12) | OPEN | ? | — | Complement of srg(36,15,6,6); unclassified |
| (36,21,10,15) | OPEN | ? | — | Existence unknown |
| (36,21,12,12) | COMPLETE | 180 | — | Complements of srg(36,14,4,6) |
| (36,25,16,20) | OPEN | ? | — | Existence unknown |
| (37,18,8,9) | OPEN | ? | — | Many known; completeness open (conference) |
| (40,12,2,4) | COMPLETE | 28 | — | Spence 2000 |
| (40,27,18,18) | OPEN | ? | — | Existence unknown |
| (41,20,9,10) | OPEN | ? | — | Many known; completeness open (conference) |
| (45,12,3,3) | COMPLETE | 78 | — | Coolsaet-Degraer-Moorhouse 2006 |
| (45,16,8,4) | COMPLETE | 1 | — | Unique: Triangular T(10) |
| (45,22,10,11) | OPEN | ? | — | Existence unknown (conference) |
| (45,28,15,21) | OPEN | ? | — | Existence unknown |
| (45,32,22,24) | COMPLETE | 78 | — | Complements of srg(45,12,3,3) |
| (49,12,5,2) | COMPLETE | ? | — | Several known; completeness open |
| (49,16,3,6) | NONE | 0 | — | Proved nonexistent |
| (49,18,7,6) | OPEN | ? | — | Several known; completeness open |
| (49,24,11,12) | OPEN | ? | — | Several known; completeness open (conference) |
| (49,30,17,20) | OPEN | ? | — | Existence unknown |
| (49,32,21,20) | OPEN | ? | — | Existence unknown |
| (49,36,25,30) | OPEN | ? | — | Existence unknown |
| (50,7,0,1) | COMPLETE | 1 | — | Unique: Hoffman-Singleton graph |
| (50,21,4,12) | NONE | 0 | — | Proved nonexistent |
| (50,21,8,9) | OPEN | ? | — | Existence unknown (conference) |
| (50,28,15,16) | OPEN | ? | — | Existence unknown |
| (50,28,18,12) | OPEN | ? | — | Existence unknown |
| (50,42,35,36) | OPEN | ? | — | Existence unknown |
| (53,26,12,13) | COMPLETE | 1 | — | Unique: Paley(53) (conference) |
| (55,18,9,4) | COMPLETE | 1 | — | Unique: Triangular T(11) |
| (55,36,21,28) | OPEN | ? | — | Existence unknown |
| (56,10,0,2) | COMPLETE | 1 | — | Unique: Gewirtz graph |
| (56,22,3,12) | NONE | 0 | — | Proved nonexistent |
| (56,33,22,15) | OPEN | ? | — | Existence unknown |
| (56,45,36,36) | OPEN | ? | — | Existence unknown |
| (57,14,1,4) | NONE | 0 | — | Proved nonexistent |
| (57,24,11,9) | COMPLETE | 1 | — | Unique (conference?) |
| (57,28,13,14) | NONE | 0 | — | Proved nonexistent (conference) |
| (57,32,16,20) | OPEN | ? | — | Existence unknown |
| (57,42,31,30) | OPEN | ? | — | Existence unknown |
| (61,30,14,15) | COMPLETE | 1 | — | Unique: Paley(61) (conference) |
| (63,22,1,11) | NONE | 0 | — | Proved nonexistent |
| (63,30,13,15) | OPEN | ? | — | Many known; completeness open |
| (63,32,16,16) | OPEN | ? | — | Many known; completeness open |
| (63,40,28,20) | OPEN | ? | — | Existence unknown |
| (64,14,6,2) | COMPLETE | 1 | — | Unique: halved 7-cube related |
| (64,18,2,6) | PARTIAL | 167+ | — | At least 167 known; completeness open |
| (64,21,0,10) | NONE | 0 | — | Proved nonexistent |
| (64,21,8,6) | COMPLETE | 1 | — | Unique (known from database) |
| (64,27,10,12) | COMPLETE | 1 | — | Unique (known from database) |
| (64,28,12,12) | OPEN | ? | — | Several known; completeness open |
| (64,30,18,10) | NONE | 0 | — | Proved nonexistent |
| (64,35,18,20) | OPEN | ? | — | Existence unknown |
| (64,36,20,20) | OPEN | ? | — | Several known; completeness open |
| (64,42,26,30) | OPEN | ? | — | Existence unknown |
| (64,45,32,30) | OPEN | ? | — | Existence unknown |
| (64,49,36,42) | OPEN | ? | — | Existence unknown |
