<p align="center">
  <img src="../assets/readme/strip-recipe-2.svg" width="100%" alt="Gas City Cookbook: recipe 2 of 3">
</p>

# Recipe: the mayor (a single always-on coordinator)

**Goal:** one always-on session per city that plans, triages, dispatches to the right tier,
and monitors — instead of you hand-driving every task.

## The pieces

Configured in `packs/core-city/agents/mayor/` plus a named session in `pack.toml`.

`agents/mayor/agent.toml`:

```toml
name = "mayor"
provider = "deep-thinker"                            # the coordinator runs on the strong tier
append_fragments = [
  "mayor-operating-rhythm",                          # idle-when-empty + periodic status/convoy checks
  "efficient-routing-rules",                         # how to route work to fast/solid/deep tiers
  "sdlc-mayor-coding-rules",                          # triage: do-it / manual-sling / run build-basic
]
idle_timeout = "1h"                                  # idle instead of busy-looping
wake_mode = "fresh"                                  # re-prime clean each wake — no context pile-up
max_active_sessions = 1
```

Declared always-on in `pack.toml`:

```toml
[[named_session]]
template = "mayor"
mode = "always"
scope = "city"
```

- **`prompt.template.md`** gives it a *coordinator* prompt (plan / dispatch / monitor).
  Without a prompt it falls back to a generic worker loop and busy-polls.
- Because `provider = "deep-thinker"`, the coordinator runs on Opus / Gemini Pro-High
  automatically per city (see the [tiers recipe](multi-provider-tiers.md)).

## The behavior comes from three fragments

Fragments are reusable prompt chunks under `template-fragments/*.template.md`, referenced by
their bare `define` name.

| Fragment | What it does |
|---|---|
| `efficient-routing-rules` | Route work by reasoning load — stamp `gc.routed_to=<rig>/<tier>` (fast/solid/deep). |
| `mayor-operating-rhythm` | **Idle when empty.** Don't wander when there's no work; do periodic status sweeps + hourly convoy check-ins. |
| `sdlc-mayor-coding-rules` | **Triage feature requests** — see below. |

## The triage rule (the important one)

When handed a coding task, the mayor decides *how* to do it rather than acting on the
literal wording:

1. **Trivial** (one file, mechanical) → do it directly, or sling one bead to a tier.
2. **Non-trivial feature** → run the `build-basic` workflow: create a **root bead**, then
   `gc sling gc.run-operator <bead-id> --on build-basic --var artifact_root=…`.
   *Never* sling a raw file path at the formula — a pointed-at file is the *brief*, not the
   workflow input.
3. **Unsure** → ask one clarifying question, or default to build-basic.

> Two rules that bite everyone with fragments: reference them by the **bare define-name**
> (`efficient-routing-rules`), and the file **must end in `.template.md`** — a plain `.md`
> fragment is silently ignored ("template not found").

## Verify

```bash
gc prime mayor --strict | head          # should render "# Mayor …", not a generic worker prompt
gc session peek cc.mayor                 # the live session's context should show the prompt + fragments
```

## Applying changes to a running mayor

```bash
gc reload                                # controller picks up config changes
gc session reset cc.mayor                # fresh session re-primes on the new prompt/fragments
```

`reset` preserves the session's identity, mail, and queued work — it just swaps in a fresh
conversation (which re-primes). Restart order matters: **reload before reset** so the fresh
session launches on the new provider/config.

---

[← Multi-provider tiers](multi-provider-tiers.md) · [README](../README.md) · Next: [Per-role model tiers →](per-role-model-tiers.md)
