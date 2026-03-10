"""
timer.sage — Research session timer with graceful shutdown.

Usage:
    load('core/timer.sage')
    start_timer(minutes=10)          # arm the timer

    # In your research loop:
    if time_is_up():
        wrap_up(notes="...", partial_results=results)
        sys.exit(0)

When the alarm fires, STOP_FLAG is set and a warning is printed.
Call time_is_up() at every natural checkpoint in the research loop.
Call wrap_up() to save state and exit cleanly.
"""

import signal
import time
import os
import json
import sys

# ---------------------------------------------------------------------------
# Global state
# ---------------------------------------------------------------------------

_SESSION_START = None          # wall-clock time when timer was armed
_SESSION_LIMIT = None          # duration in seconds
_STOP_FLAG = [False]           # mutable so the signal handler can set it
_TIMER_ARMED = [False]


# ---------------------------------------------------------------------------
# Signal handler
# ---------------------------------------------------------------------------

def _alarm_handler(signum, frame):
    """Called by SIGALRM when the session time limit is reached."""
    _STOP_FLAG[0] = True
    elapsed = time.time() - _SESSION_START
    print(f"\n{'='*60}")
    print(f"  TIME LIMIT REACHED ({elapsed/60:.1f} min). Wrapping up...")
    print(f"{'='*60}\n")


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

def start_timer(minutes=10):
    """
    Arm the research session timer.

    Sets a SIGALRM to fire after `minutes` minutes.
    Call this once at the start of each research run.

    Inputs:
        minutes : session length in minutes (default 10)

    Outputs:
        None (side effect: SIGALRM armed, session clock started)

    Example:
        start_timer(10)
    """
    global _SESSION_START, _SESSION_LIMIT
    _SESSION_START = time.time()
    _SESSION_LIMIT = minutes * 60
    _STOP_FLAG[0] = False
    _TIMER_ARMED[0] = True

    signal.signal(signal.SIGALRM, _alarm_handler)
    signal.alarm(int(_SESSION_LIMIT))

    print(f"[timer] Session started. Limit: {minutes} min "
          f"(alarm at {time.strftime('%H:%M:%S', time.localtime(_SESSION_START + _SESSION_LIMIT))})")


def time_is_up():
    """
    Check whether the session time limit has been reached.

    Call this at every checkpoint in the research loop.

    Outputs:
        True if the timer has fired, False otherwise

    Example:
        if time_is_up():
            wrap_up(...)
            sys.exit(0)
    """
    if not _TIMER_ARMED[0]:
        return False
    # Also catch the case where SIGALRM isn't available (Windows)
    if _SESSION_START is not None and _SESSION_LIMIT is not None:
        if time.time() - _SESSION_START >= _SESSION_LIMIT:
            _STOP_FLAG[0] = True
    return _STOP_FLAG[0]


def elapsed_seconds():
    """Return seconds elapsed since start_timer() was called."""
    if _SESSION_START is None:
        return 0.0
    return time.time() - _SESSION_START


def elapsed_str():
    """Return elapsed time as a human-readable string, e.g. '4m 32s'."""
    s = int(elapsed_seconds())
    return f"{s // 60}m {s % 60}s"


def time_remaining_str():
    """Return remaining time as a human-readable string."""
    if _SESSION_START is None or _SESSION_LIMIT is None:
        return "N/A"
    remaining = max(0, _SESSION_LIMIT - elapsed_seconds())
    s = int(remaining)
    return f"{s // 60}m {s % 60}s"


# ---------------------------------------------------------------------------
# Graceful wrap-up
# ---------------------------------------------------------------------------

def wrap_up(notes="", partial_results=None, experiment_dir=None):
    """
    Save session notes and partial results, then cancel the alarm.

    Creates (or appends to) `session_notes.md` in the experiment directory
    (or in the project root if experiment_dir is None).
    If partial_results is provided, saves them as JSON.

    Inputs:
        notes           : string of researcher notes for the next run
        partial_results : dict or list of partial findings (JSON-serializable)
        experiment_dir  : path to the experiment folder (optional)

    Outputs:
        None (writes files)

    Example:
        wrap_up(
            notes="Tried Paley construction; need to check Krein for v=35.",
            partial_results={'graphs_found': 2, 'methods_tried': ['database', 'paley']},
            experiment_dir='experiments/EXP_20260310_001_srg35'
        )
    """
    # Cancel any remaining alarm
    signal.alarm(0)

    base_dir = experiment_dir if experiment_dir else os.getcwd()
    os.makedirs(base_dir, exist_ok=True)

    timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
    elapsed = elapsed_str()

    # Write session notes
    notes_path = os.path.join(base_dir, 'session_notes.md')
    with open(notes_path, 'a') as f:
        f.write(f"\n## Session ended: {timestamp} (elapsed: {elapsed})\n\n")
        if notes:
            f.write(f"### Notes for next run\n{notes}\n\n")
        else:
            f.write("_(no notes recorded)_\n\n")

    print(f"[timer] Notes saved to {notes_path}")

    # Save partial results
    if partial_results is not None:
        pr_path = os.path.join(base_dir, 'partial_results.json')
        payload = {
            'timestamp': timestamp,
            'elapsed_seconds': int(elapsed_seconds()),
            'results': partial_results
        }
        try:
            with open(pr_path, 'w') as f:
                json.dump(payload, f, indent=2, default=str)
            print(f"[timer] Partial results saved to {pr_path}")
        except Exception as e:
            print(f"[timer] Could not save partial results: {e}")

    print(f"[timer] Session wrapped up after {elapsed}. Goodbye.")


print("timer.sage loaded.")
