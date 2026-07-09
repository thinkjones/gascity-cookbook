{{ define "efficient-routing-rules" }}
## Task Routing Rules

When you create a bead, route it to a worker tier by stamping `gc.routed_to`
metadata. Pick the tier by task complexity, and prefix it with the **target
rig** so a rig-scoped worker (with the project checked out) claims it:

    gc.routed_to=<rig>/<tier>

Tiers:
- Simple code change → `fast-worker`
- Architectural / design work → `deep-thinker`
- Everything else → `solid-worker`

Use the concrete rig name for the work (run `gc rig` or `gc status` to list
rigs). For example, a simple change in the `fs-book-agentic-engineering` rig:

    bd update <id> --set-metadata gc.routed_to=fs-book-agentic-engineering/fast-worker

Only drop the `<rig>/` prefix for city-level work that has no project checkout.
{{ end }}

{{ define "sdlc-mayor-coding-rules" }}
## SDLC Mayor Coding Rules

When performing coding work you should do the work in a worktree and branched off the default branch (main).

* Mayor In Session Work -> You can manage that yourself.
* Mayor direct delegation work -> You can tell the agents you delegate to use a new/existing worktree which on initiation should be branched off main.
* Any formula from gas-city e.g. `build-basic` -> Use variable parameters `push` and `open_pr`, set to `true` which indicate that the work is done off main and pushed remotely. Every build entrypoint accepts these args.

{{ end }}
