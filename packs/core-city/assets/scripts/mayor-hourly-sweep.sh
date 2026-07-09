#!/usr/bin/env bash
#
# mayor-hourly-sweep.sh — wake the mayor for its hourly status + convoy check.
#
# Pure plumbing: find the active mayor session and nudge it. All judgment
# (which convoys are stalled, what to nudge or unblock) stays with the mayor,
# driven by its prompt (the "mayor-operating-rhythm" fragment). This script
# never reads beads and never decides anything.
#
# The template match tolerates any import binding (mayor, cc.mayor, …).

set -euo pipefail

mapfile -t session_ids < <(
  gc session list --json \
    | jq -r '.sessions[] | select(((.template // "") | test("(^|\\.)mayor$")) and .state == "active") | .id'
)

if [[ ${#session_ids[@]} -eq 0 ]]; then
  echo "no active mayor session"
  exit 0
fi

msg="Hourly check: run your status sweep (gc status, gc mail check, gc bd ready), then verify running convoys in each rig are still processing (gc convoy list, and gc bd list for their beads). Nudge or unblock anything stalled, then idle."

nudged=0
for sid in "${session_ids[@]}"; do
  if gc session nudge "$sid" "$msg" --delivery queue >/dev/null 2>&1; then
    nudged=$((nudged + 1))
  else
    echo "nudge failed for $sid" >&2
  fi
done

echo "nudged $nudged mayor session(s)"
