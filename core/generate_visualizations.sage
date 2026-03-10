"""
generate_visualizations.sage — Generate parameter space visualizations.

Creates:
  - visualizations/parameter_space/feasibility_landscape.png
    A scatter plot of all (v,k) pairs colored by feasibility status.
"""

from sage.all import *
import os
import sys

_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'feasibility.sage'))


def generate_feasibility_landscape(v_min=5, v_max=64,
                                    outfile='visualizations/parameter_space/feasibility_landscape.png'):
    """
    Generate a scatter plot of all (v, k) pairs for feasible SRG parameter sets.

    Color coding:
      - COMPLETE (from known results): green
      - OPEN: orange
      - FEASIBLE (no known result yet): blue

    Inputs:
        v_min, v_max : range of vertex counts
        outfile      : output PNG path

    Outputs:
        None (saves PNG)
    """
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    # Same known results dict as generate_status.sage
    KNOWN_RESULTS = {
        (5, 2, 0, 1): 'COMPLETE',
        (9, 4, 1, 2): 'COMPLETE',
        (10, 3, 0, 1): 'COMPLETE',
        (10, 6, 3, 4): 'COMPLETE',
        (13, 6, 2, 3): 'COMPLETE',
        (15, 6, 1, 3): 'COMPLETE',
        (15, 8, 4, 4): 'COMPLETE',
        (16, 5, 0, 2): 'COMPLETE',
        (16, 6, 2, 2): 'COMPLETE',
        (16, 9, 4, 6): 'COMPLETE',
        (16, 10, 6, 6): 'COMPLETE',
        (17, 8, 3, 4): 'COMPLETE',
        (21, 10, 3, 6): 'COMPLETE',
        (21, 10, 5, 4): 'COMPLETE',
        (25, 8, 3, 2): 'COMPLETE',
        (25, 12, 5, 6): 'COMPLETE',
        (26, 10, 3, 4): 'COMPLETE',
        (26, 15, 8, 9): 'COMPLETE',
        (27, 10, 1, 5): 'COMPLETE',
        (27, 16, 10, 8): 'COMPLETE',
        (28, 12, 6, 4): 'COMPLETE',
        (28, 15, 6, 10): 'COMPLETE',
        (29, 14, 6, 7): 'COMPLETE',
        (35, 16, 6, 8): 'OPEN',
        (36, 14, 4, 6): 'COMPLETE',
        (36, 15, 6, 6): 'COMPLETE',
        (36, 20, 10, 12): 'COMPLETE',
        (36, 21, 12, 12): 'COMPLETE',
        (37, 18, 8, 9): 'COMPLETE',
        (41, 20, 9, 10): 'COMPLETE',
        (45, 12, 3, 3): 'COMPLETE',
        (45, 32, 22, 24): 'COMPLETE',
        (49, 24, 11, 12): 'COMPLETE',
        (50, 7, 0, 1): 'COMPLETE',
        (53, 26, 12, 13): 'COMPLETE',
        (55, 18, 9, 4): 'COMPLETE',
        (56, 10, 0, 2): 'OPEN',
        (57, 14, 1, 4): 'OPEN',
        (61, 30, 14, 15): 'COMPLETE',
        (63, 30, 13, 15): 'OPEN',
        (64, 21, 8, 6): 'OPEN',
        (64, 27, 10, 12): 'OPEN',
    }

    points = {'COMPLETE': ([], []), 'OPEN': ([], []), 'FEASIBLE': ([], [])}

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
                        known_status = KNOWN_RESULTS.get((v, k, lam, mu), 'FEASIBLE')
                        points[known_status][0].append(v)
                        points[known_status][1].append(k)

    fig, ax = plt.subplots(figsize=(14, 10))

    colors = {'COMPLETE': ('green', 'Classified (COMPLETE)', 80),
              'OPEN': ('orange', 'Unclassified (OPEN)', 120),
              'FEASIBLE': ('steelblue', 'Feasible (not in table)', 60)}

    for cat, (color, label, sz) in colors.items():
        xs, ys = points[cat]
        if xs:
            ax.scatter(xs, ys, c=color, label=f"{label} ({len(xs)})",
                      s=sz, alpha=0.8, edgecolors='black', linewidths=0.5)

    ax.set_xlabel('v (number of vertices)', fontsize=13)
    ax.set_ylabel('k (degree)', fontsize=13)
    ax.set_title('SRG Parameter Space: Feasibility Landscape (v = 5–64)', fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Add diagonal k=v/2 reference line
    ax.plot([v_min, v_max], [v_min/2, v_max/2], 'k--', alpha=0.2, label='k=v/2')

    os.makedirs(os.path.dirname(os.path.abspath(outfile)), exist_ok=True)
    plt.tight_layout()
    plt.savefig(outfile, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"Saved: {outfile}")


if __name__ == '__main__':
    generate_feasibility_landscape()
