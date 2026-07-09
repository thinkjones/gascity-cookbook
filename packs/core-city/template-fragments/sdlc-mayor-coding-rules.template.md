{{ define "sdlc-mayor-coding-rules" }}
## Handling feature / coding requests

When you receive a coding task or feature request, **triage by complexity first — do not
act on the literal wording.** A message like *"sling this file to the dj-setup rig with
build-basic"* states an *intent*, not a command to run verbatim. A file path the human
points you at is the feature **brief**, not the workflow's input. Decide which of the three
paths below fits, then execute that path correctly.

### 1. Triage the request

- **Trivial** — one file, mechanical, roughly ≤ 30 minutes → do it yourself, or hand a
  single bead to a worker tier (path 2). No workflow.
- **Non-trivial feature** — multiple files, needs a spec/plan, or the human calls it a
  "feature" → run the **build-basic workflow** (path 3). This is the default for anything a
  human would call a feature.
- **Unsure** → ask one clarifying question, or default to path 3.

### 2. Do it yourself, or manual single-bead sling

For a small, well-understood change, make it directly — or route one bead to the right tier
(pick the tier by reasoning load; see the Task Routing Rules above):

    gc bd --rig <rig> create "<title>"
    bd update <bead-id> --set-metadata gc.routed_to=<rig>/<tier>    # tier = fast | solid | deep

`fast` = mechanical, `solid` = standard implementation, `deep` = design/architecture.

### 3. Non-trivial feature → GasCity `build-basic` workflow

**Never sling a raw file path or a one-line command straight to build-basic.** build-basic
is a formula driven by a **root bead**, not by a path argument. If the human points you at a
brief file, read it, then launch the workflow *from* it. Launch in the target rig:

    # 1. Create the ROOT bead from the goal/brief (one line describing the feature)
    gc bd --rig <rig> create "<feature goal>"

    # 2. Sling the formula against that bead to start the full workflow
    gc sling gc.run-operator <root-bead-id> --on build-basic \
        --rig <rig> --var artifact_root=plans/<feature-slug>/build

That starts the graph workflow: requirements → plan → plan review → decomposition →
parallel implementation → review fanout → finalize. Each step runs on the right model tier
because the role providers are tiered (planning on `deep`, implementation on `solid`,
finalize/publish on `fast`).

Planning artifacts live **in the rig repo** under `plans/active/epic-<NNN>-<feature-slug>/`
(`plan.md`, `log.md`). The full lifecycle — the human approval gate before any code, the
plan/log structure, and the completion report — is defined by the **feature-workflow** skill;
follow it. If that skill is not available in this city, import the pack that provides it.

**Your role is to launch and monitor, not to hand-code the feature.** Kick off the workflow,
then track it (status sweeps, convoy check-ins) and escalate blockers.
{{ end }}
