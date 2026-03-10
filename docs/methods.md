---
layout: page
title: Methods
permalink: /methods/
---

# Methods

This research system applies methods in order of computational cost.

## A — Database Lookup
Query SageMath's built-in SRG database, backed by Brouwer's table.

## B — Algebraic Constructions
Paley graphs, Latin square graphs, triangular graphs, polar graphs,
Cayley graphs, Steiner system block graphs.

## C — Seidel Switching
Generate non-isomorphic mates from known graphs via two-graph descent.
This is how all 41 srg(29,14,6,7) were found.

## D — Spectral Constraints
Prune search space using eigenvalue integrality, Krein conditions,
and the absolute bound before attempting exhaustive search.

## E — Exhaustive Backtracking
Vertex-by-vertex adjacency matrix completion with canonical augmentation
via nauty/bliss to avoid isomorphic duplicates.

## F — AI Pattern Detection
Lightweight ML classifiers trained on known adjacency matrices to
detect structural patterns and guide construction heuristics.
