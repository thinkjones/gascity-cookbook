#!/usr/bin/env bash
#
# clear-human-mail.sh — delete (close) all mail currently in a recipient's
# inbox. Defaults to the "human" recipient; pass a name to target another.
#
# Deletes in chunks (a single giant batch can fail as one unit). This flushes
# what is present now — it does NOT stop the source. Patrol orders such as
# mol-dog-doctor re-send advisories every few minutes, so if the inbox refills,
# the fix is to resolve the underlying condition or quiet the emitting order,
# not to re-run this.

set -euo pipefail

recipient="${1:-human}"

ids="$(gc mail inbox "$recipient" --json 2>/dev/null | jq -r '.messages[].id')"
if [ -z "$ids" ]; then
  echo "no mail for $recipient"
  exit 0
fi

n="$(printf '%s\n' "$ids" | grep -c .)"
printf '%s\n' "$ids" | xargs -n 20 gc mail delete >/dev/null 2>&1 || true
echo "requested delete of $n message(s) from $recipient inbox"
gc mail count "$recipient" 2>/dev/null || true
