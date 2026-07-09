# Recipe: per-role model tiers (generated)

**Goal:** make each workflow step run on the right model — planning on the strong tier,
implementation on the mid tier, mechanical steps on the cheap tier — from one base map,
across every city.

## Why it's needed

A formula like `build-basic` routes each step to a **role** (`requirements-planner`,
`implementation-worker`, `publisher`, …). The model a step runs on is **that role agent's
`provider`**. So "right model per step" = "set each role's provider to a tier".

Roles are **rig-scoped** (one copy per rig), so this would be N roles × M rigs of nearly
identical patches. Instead: keep the data + generator in the shared pack, generate the
expansion per city.

## 1. The base map (data) — `packs/core-city/model-tiers.base.toml`

```toml
[tiers]
requirements-planner  = "deep-thinker"
design-author         = "deep-thinker"
task-decomposer       = "deep-thinker"
implementation-worker = "solid-worker"
implementation-reviewer = "solid-worker"
run-operator          = "fast-worker"
publisher             = "fast-worker"
# ...one line per role
```

| Tier | Roles | Why |
|---|---|---|
| `deep-thinker` | requirements-planner, design-author, task-decomposer, design reviewers | Planning/design decisions everything downstream inherits |
| `solid-worker` | implementation-worker, implementation-reviewer, gap-analyst, review-synthesizer, issue-triager | The high-volume doing: implementation + standard review |
| `fast-worker`  | run-operator, publisher | Deterministic / mechanical |

## 2. The generator (code) — `gc cc gen-model-tiers`

A custom command (`packs/core-city/commands/gen-model-tiers/`) reads the base map,
auto-detects the current city's project rigs, and emits `[[patches.agent]]` blocks:

```bash
cd cities/gemini-city
gc cc gen-model-tiers > model-tiers.toml
```

Produces one block per rig × role:

```toml
# GENERATED — do not edit by hand
[[patches.agent]]
dir  = "example-service"        # the rig
name = "requirements-planner"   # UNQUALIFIED role name (no binding/rig prefix)
provider = "deep-thinker"
```

## 3. Wire it in — `include` (top of `city.toml`, before any table)

```toml
include = ["model-tiers.toml"]
```

Fragments included this way merge into the city and can carry `[[patches.agent]]`.

## How a build then flows

```
formula step  ──gc.run_target──▶  role agent  ──provider──▶  tier  ──resolves to──▶  concrete model
"requirements"                    requirements-planner        deep-thinker            Opus / Gemini Pro-High
"implement"                       implementation-worker       solid-worker            Sonnet / Gemini Pro-Low
"publish"                         publisher                   fast-worker             Haiku / Gemini Flash-Low
```

The formula never names a model — it names a *role*; the role's provider (a tier) is the
model. That's why the same formula runs correctly on any provider family.

## Gotcha — patch targeting

A patch matches the agent's **stored** fields: `name` is the *unqualified* role
(`run-operator`, not `gc.run-operator`) and `dir` is the rig. The `binding.`/`rig/` prefixes
only appear in *display* names (`gc rig list`), never in patches.

## Retune

Edit `model-tiers.base.toml` once, then regenerate each city:

```bash
cd cities/<city> && gc cc gen-model-tiers > model-tiers.toml
```

Add a rig → regenerate; it's picked up automatically.
