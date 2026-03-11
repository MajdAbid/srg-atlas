"""
research_loop.sage — Main research session runner.

Run with:
    sage core/research_loop.sage

Each run:
  1. Arms a 10-minute timer
  2. Reads STATUS.md to pick the next OPEN/PARTIAL target
  3. Runs the full research loop (Steps 1-7 from program.md)
  4. Stops gracefully when time_is_up(), saving notes for the next run
"""

from sage.all import *
from sage.graphs.strongly_regular_db import strongly_regular_graph
import os
import sys
import time
import json
import re

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)

load(os.path.join(_CORE_DIR, 'timer.sage'))
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))
load(os.path.join(_CORE_DIR, 'feasibility.sage'))
load(os.path.join(_CORE_DIR, 'verify.sage'))
load(os.path.join(_CORE_DIR, 'methods', 'algebraic.sage'))
load(os.path.join(_CORE_DIR, 'methods', 'switching.sage'))
load(os.path.join(_CORE_DIR, 'methods', 'spectral.sage'))
load(os.path.join(_CORE_DIR, 'methods', 'exhaustive.sage'))


# ---------------------------------------------------------------------------
# STATUS.md helpers
# ---------------------------------------------------------------------------

def read_status(status_file='STATUS.md'):
    """
    Parse STATUS.md and return list of parameter sets with their status.

    Returns list of dicts: {v, k, lam, mu, status, count, notes}
    sorted by (v, k).
    """
    rows = []
    with open(status_file, 'r') as f:
        for line in f:
            m = re.match(
                r'\|\s*\((\d+),(\d+),(\d+),(\d+)\)\s*\|\s*(\w+)\s*\|\s*([^|]*)\|([^|]*)\|([^|]*)\|',
                line
            )
            if m:
                v, k, lam, mu = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
                status = m.group(5).strip()
                count = m.group(6).strip()
                notes = m.group(8).strip()
                rows.append({'v': v, 'k': k, 'lam': lam, 'mu': mu,
                             'status': status, 'count': count, 'notes': notes})
    return sorted(rows, key=lambda r: (r['v'], r['k']))


def pick_target(rows):
    """Return the first OPEN or PARTIAL parameter set (smallest v, then k).
    Skips COMPLETE and NONE entries."""
    for row in rows:
        if row['status'] in ('OPEN', 'PARTIAL'):
            return row
    return None


def update_status(v, k, lam, mu, new_status, count, notes, status_file='STATUS.md'):
    """Update a single row in STATUS.md."""
    with open(status_file, 'r') as f:
        content = f.read()

    pattern = rf'(\|\s*\({v},{k},{lam},{mu}\)\s*\|)[^\n]*'
    replacement = f'| ({v},{k},{lam},{mu}) | {new_status} | {count} | — | {notes} |'
    content = re.sub(pattern, replacement, content)

    with open(status_file, 'w') as f:
        f.write(content)
    print(f"  STATUS.md updated: srg({v},{k},{lam},{mu}) => {new_status}")


# ---------------------------------------------------------------------------
# Experiment directory management
# ---------------------------------------------------------------------------

def next_experiment_id():
    """Return next EXP number by scanning existing experiments/."""
    exp_dir = 'experiments'
    existing = [d for d in os.listdir(exp_dir)
                if os.path.isdir(os.path.join(exp_dir, d)) and d.startswith('EXP_')]
    if not existing:
        return 1
    nums = []
    for d in existing:
        m = re.match(r'EXP_\d{8}_(\d{3})', d)
        if m:
            nums.append(int(m.group(1)))
    return max(nums) + 1 if nums else 1


def make_experiment_dir(v, k, lam, mu):
    """Create experiment directory and return its path."""
    date = time.strftime('%Y%m%d')
    num = next_experiment_id()
    name = f"EXP_{date}_{num:03d}_srg{v}_{k}_{lam}_{mu}"
    path = os.path.join('experiments', name)
    os.makedirs(os.path.join(path, 'outputs', 'graphs'), exist_ok=True)
    os.makedirs(os.path.join(path, 'outputs', 'plots'), exist_ok=True)
    os.makedirs(os.path.join(path, 'outputs', 'matrices'), exist_ok=True)
    return path, name, num


# ---------------------------------------------------------------------------
# Step 3: Construction phase
# ---------------------------------------------------------------------------

def run_constructions(v, k, lam, mu, exp_dir, verbose=True):
    """
    Try all construction methods A–D. Return list of (Graph, method_name).
    """
    found = []
    seen_labels = set()

    def add(G, method):
        cl = G.canonical_label().graph6_string()
        if cl not in seen_labels:
            seen_labels.add(cl)
            found.append((G, method))
            if verbose:
                print(f"    [{method}] New non-isomorphic graph #{len(found)}")

    if time_is_up(): return found

    # Method A: database
    print("  [A] Database lookup...")
    G = try_database(v, k, lam, mu)
    if G is not None and verify_srg(G, v, k, lam, mu):
        add(G, 'database')

    if time_is_up(): return found

    # Method B: algebraic constructions
    print("  [B] Algebraic constructions...")
    for G, method in try_all_constructions(v, k, lam, mu, verbose=False):
        add(G, method)

    if time_is_up(): return found

    # Method C: Seidel switching from each found graph
    if found:
        print(f"  [C] Seidel switching from {len(found)} seed(s)...")
        for G0, _ in list(found):
            if time_is_up(): break
            mates = switching_search(G0, v, k, lam, mu, max_rounds=3, verbose=False)
            for H in mates:
                add(H, 'seidel_switching')

    if time_is_up(): return found

    # Method D: spectral summary (informational, no new graphs)
    print("  [D] Spectral analysis...")
    spec = spectral_summary(v, k, lam, mu)
    if verbose:
        ev = spec['eigenvalues']
        hb = spec['hoffman']
        print(f"    Eigenvalues: r≈{float(ev['r']):.3f}, s≈{float(ev['s']):.3f}, "
              f"f={ev['f']}, g={ev['g']}")
        if hb:
            print(f"    Hoffman bounds: clique≤{hb['clique_bound']}, "
                  f"indep≤{hb['independence_bound']}")

    return found


# ---------------------------------------------------------------------------
# Step 5: Document experiment
# ---------------------------------------------------------------------------

def write_experiment_md(exp_dir, exp_name, v, k, lam, mu,
                        found, methods_tried, elapsed, open_questions=''):
    """Write EXPERIMENT.md for this experiment."""
    path = os.path.join(exp_dir, 'EXPERIMENT.md')
    date = time.strftime('%Y-%m-%d')
    with open(path, 'w') as f:
        f.write(f"# Experiment: {exp_name} — srg({v},{k},{lam},{mu})\n\n")
        f.write(f"**Date**: {date}\n\n")
        f.write("## Objective\n")
        f.write(f"Classify all non-isomorphic srg({v},{k},{lam},{mu}).\n\n")
        f.write("## Methods attempted\n")
        for m in methods_tried:
            f.write(f"- {m}\n")
        f.write("\n## Results\n")
        f.write(f"- Graphs found: {len(found)}\n")
        f.write(f"- Non-isomorphic classes: {len(found)}\n")
        f.write(f"- Time taken: {elapsed}\n")
        for i, (G, method) in enumerate(found):
            f.write(f"- Graph #{i+1}: found via `{method}`\n")
        f.write("\n## Failures and what was learned\n")
        f.write("_(to be filled)_\n\n")
        f.write("## Visualizations generated\n")
        f.write("_(see outputs/plots/)_\n\n")
        f.write("## Open questions raised\n")
        f.write(open_questions if open_questions else "_(none)_\n")
        f.write("\n## Next suggested experiment\n")
        f.write("_(see STATUS.md for next OPEN target)_\n")


def write_summary_json(exp_dir, exp_name, v, k, lam, mu,
                       found, methods_used, elapsed_s):
    """Write summary.json."""
    graph_files = []
    for i, (G, _) in enumerate(found):
        fname = f"srg_{v}_{k}_{lam}_{mu}_{i+1:03d}.g6"
        fpath = os.path.join(exp_dir, 'outputs', 'graphs', fname)
        save_graph6(G, fpath)
        graph_files.append(os.path.join('outputs', 'graphs', fname))

    data = {
        'experiment_id': exp_name,
        'parameters': {'v': v, 'k': k, 'lambda': lam, 'mu': mu},
        'status': 'COMPLETE' if found else 'PARTIAL',
        'graphs_found': len(found),
        'isomorphism_classes': len(found),
        'methods_used': methods_used,
        'time_seconds': int(elapsed_s),
        'graph_files': graph_files,
        'notes': ''
    }
    save_summary(data, os.path.join(exp_dir, 'outputs', 'summary.json'))


# ---------------------------------------------------------------------------
# Main research loop
# ---------------------------------------------------------------------------

def run_session(minutes=10):
    """
    Run one timed research session.

    Arms a {minutes}-minute timer, picks the next OPEN target from STATUS.md,
    runs Steps 1-7 from program.md, and wraps up gracefully when time expires.
    """
    # Arm timer
    start_timer(minutes=minutes)

    print(f"\n{'='*60}")
    print(f"  SRG Research Session — {minutes} min")
    print(f"{'='*60}\n")

    # Step 1: pick target
    rows = read_status('STATUS.md')
    target = pick_target(rows)
    if target is None:
        print("All parameter sets are COMPLETE or NONE. Nothing to do.")
        wrap_up(notes="All targets resolved.")
        return

    v, k, lam, mu = target['v'], target['k'], target['lam'], target['mu']
    original_status = target['status']
    print(f"Target: srg({v},{k},{lam},{mu})  [status={original_status}]\n")

    if time_is_up():
        wrap_up(notes=f"Timer expired before starting srg({v},{k},{lam},{mu}).")
        return

    # Step 2: feasibility check (already confirmed in STATUS.md, but re-verify)
    print("Step 2: Feasibility check...")
    feas = is_feasible(v, k, lam, mu, verbose=True)
    if feas == 'INFEASIBLE':
        print(f"  => INFEASIBLE. Updating STATUS.md.")
        update_status(v, k, lam, mu, 'NONE', 0, 'Proved infeasible by feasibility checks')
        wrap_up(notes=f"srg({v},{k},{lam},{mu}) proved infeasible.")
        return

    if time_is_up():
        wrap_up(notes=f"Timer expired after feasibility check for srg({v},{k},{lam},{mu}).")
        return

    # Create experiment directory
    exp_dir, exp_name, exp_num = make_experiment_dir(v, k, lam, mu)
    print(f"\nExperiment: {exp_name}")
    print(f"Directory:  {exp_dir}\n")

    # Step 3: constructions
    print("Step 3: Construction phase...")
    found = run_constructions(v, k, lam, mu, exp_dir, verbose=True)

    if time_is_up():
        _finish(v, k, lam, mu, exp_dir, exp_name, found, original_status,
                partial=True, notes=f"Timer expired during construction for srg({v},{k},{lam},{mu}).")
        return

    print(f"\n  Found {len(found)} non-isomorphic graph(s) total.")

    # Step 4: verification (already done per-graph in constructions; log it)
    print("\nStep 4: Verification...")
    verified = []
    for G, method in found:
        result = full_verify(G, v, k, lam, mu)
        if result['passed']:
            verified.append((G, method))
            print(f"  VERIFIED via {method}: {result['notes']}")
        else:
            print(f"  FAILED verification via {method}: {result['notes']}")

    if time_is_up():
        _finish(v, k, lam, mu, exp_dir, exp_name, verified, original_status,
                partial=True, notes=f"Timer expired after verification for srg({v},{k},{lam},{mu}).")
        return

    # Steps 5, 6, 7: document, visualize, update STATUS
    _finish(v, k, lam, mu, exp_dir, exp_name, verified, original_status, partial=False)


def _finish(v, k, lam, mu, exp_dir, exp_name, found, original_status,
            partial=False, notes=''):
    """Steps 5-7: document, update STATUS.md, commit."""
    elapsed = elapsed_str()
    elapsed_s = elapsed_seconds()

    # Determine methods used
    methods_used = sorted(set(m for _, m in found)) if found else []

    # Step 5: document
    print("\nStep 5: Documentation...")
    write_experiment_md(
        exp_dir, exp_name, v, k, lam, mu,
        found, methods_used, elapsed,
        open_questions=notes
    )
    write_summary_json(exp_dir, exp_name, v, k, lam, mu, found, methods_used, elapsed_s)

    # Step 7: update STATUS.md
    # Never auto-promote a PARTIAL entry to COMPLETE — classification is open per Brouwer.
    # Only promote OPEN → COMPLETE if we found graphs (and no timer interrupt).
    print("\nStep 7: Updating STATUS.md...")
    if partial:
        new_status = 'PARTIAL'
    elif original_status == 'PARTIAL':
        new_status = 'PARTIAL'  # Keep PARTIAL; only a proof of completeness can upgrade
    elif found:
        new_status = 'COMPLETE'
    else:
        new_status = 'OPEN'
    count = len(found) if found else '?'
    status_notes = f"{exp_name}; {', '.join(methods_used) or '—'}; {elapsed}"
    update_status(v, k, lam, mu, new_status, count, status_notes)

    # Wrap up timer
    wrap_notes = notes or (
        f"srg({v},{k},{lam},{mu}): {len(found)} graph(s) found "
        f"via {methods_used}. Status: {new_status}."
    )
    wrap_up(
        notes=wrap_notes,
        partial_results={
            'target': f'srg({v},{k},{lam},{mu})',
            'graphs_found': len(found),
            'methods': methods_used,
            'status': new_status
        },
        experiment_dir=exp_dir
    )

    # Print commit hint
    commit_msg = f"EXP_{exp_name.split('_')[2]}: srg({v},{k},{lam},{mu}) -- {new_status} -- {len(found)} graphs found"
    print(f"\n  Suggested commit:")
    print(f"  git add experiments/ STATUS.md")
    print(f"  git commit -m {repr(commit_msg)}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

run_session(minutes=10)
