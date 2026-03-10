"""
ai_pattern.sage — AI-assisted pattern detection for SRGs.

After >= 3 graphs are found for a parameter set, train a lightweight
classifier to:
  - Predict if a candidate adjacency matrix is likely an SRG
  - Detect structural patterns (two-graph structure, clique geometry)

Requires: numpy, sklearn (pip-installable in Sage environment)
"""

from sage.all import *
import os
import sys
_CORE_DIR = os.path.join(os.getcwd(), 'core')
sys.path.insert(0, _CORE_DIR)
load(os.path.join(_CORE_DIR, 'srg_utils.sage'))


def matrix_features(G):
    """
    Extract a fixed-size feature vector from a graph's adjacency matrix.

    Features include:
      - Eigenvalue statistics (min, max, mean, std of spectrum)
      - Triangle count, 4-cycle count
      - Degree sequence statistics
      - Adjacency matrix Frobenius norm

    Inputs:
        G : Sage Graph

    Outputs:
        list of floats (feature vector)

    Example:
        features = matrix_features(G)
    """
    import numpy as np

    A = G.adjacency_matrix().numpy().astype(float)
    v = G.order()

    # Eigenvalues of adjacency matrix
    eigs = sorted(np.linalg.eigvalsh(A))
    eig_features = [
        float(eigs[0]),               # smallest
        float(eigs[-1]),              # largest
        float(np.mean(eigs)),         # mean
        float(np.std(eigs)),          # std
    ]

    # Structural counts
    A3 = np.linalg.matrix_power(A, 3)
    triangle_count = float(np.trace(A3) / 6)

    A2 = np.dot(A, A)
    A4 = np.dot(A2, A2)
    cycle4_count = float((np.trace(A4) - v * (v-1)) / 8) if v > 1 else 0

    # Degree stats
    degrees = [G.degree(u) for u in G.vertices()]
    deg_features = [
        float(min(degrees)),
        float(max(degrees)),
        float(sum(degrees) / v),
        float(np.std(degrees)),
    ]

    features = eig_features + [triangle_count, cycle4_count] + deg_features
    return features


def train_classifier(graphs_pos, graphs_neg=None, verbose=True):
    """
    Train a logistic regression classifier to distinguish SRGs from
    non-SRGs based on adjacency matrix features.

    Inputs:
        graphs_pos : list of Sage Graph objects that ARE SRGs (positive class)
        graphs_neg : list of Sage Graph objects that are NOT SRGs (negative);
                     if None, generates random regular graphs as negatives
        verbose    : print training report

    Outputs:
        trained sklearn classifier (or None if sklearn unavailable)

    Example:
        clf = train_classifier([G1, G2, G3])
    """
    try:
        from sklearn.linear_model import LogisticRegression
        from sklearn.preprocessing import StandardScaler
        from sklearn.pipeline import Pipeline
        import numpy as np
    except ImportError:
        if verbose:
            print("sklearn not available; skipping AI pattern detection")
        return None

    if graphs_neg is None:
        # Generate some random regular graphs as negatives
        graphs_neg = []
        if graphs_pos:
            v = graphs_pos[0].order()
            k = graphs_pos[0].degree()[0]
            for _ in range(max(len(graphs_pos), 5)):
                try:
                    Gneg = graphs.RandomRegular(k, v)
                    if not Gneg.is_strongly_regular():
                        graphs_neg.append(Gneg)
                except Exception:
                    pass

    X_pos = [matrix_features(G) for G in graphs_pos]
    X_neg = [matrix_features(G) for G in graphs_neg]

    if not X_pos or not X_neg:
        if verbose:
            print("Not enough data to train classifier")
        return None

    X = np.array(X_pos + X_neg)
    y = [1] * len(X_pos) + [0] * len(X_neg)

    clf = Pipeline([
        ('scaler', StandardScaler()),
        ('lr', LogisticRegression(max_iter=1000))
    ])
    clf.fit(X, y)

    if verbose:
        acc = clf.score(X, y)
        print(f"Classifier trained on {len(X_pos)} pos + {len(X_neg)} neg. Train acc: {acc:.3f}")

    return clf


def predict_srg(clf, G):
    """
    Predict probability that G is an SRG using trained classifier.

    Inputs:
        clf : trained sklearn classifier
        G   : Sage Graph

    Outputs:
        float in [0,1] (probability of being SRG), or None if clf is None

    Example:
        p = predict_srg(clf, G_candidate)
    """
    if clf is None:
        return None
    import numpy as np
    feats = matrix_features(G)
    prob = clf.predict_proba([feats])[0][1]
    return float(prob)


print("ai_pattern.sage loaded.")
