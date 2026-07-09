# Gas City Cookbook

Patterns, a reusable config pack, and copy-me example cities for running
[Gas City](https://github.com/gastownhall/gascity) — a Go toolkit for composing
multi-agent coding workflows where **all role behavior is user-supplied config**.

This repo is the shareable distillation of a working **multi-city, multi-provider**
setup. The centerpiece is a **tier abstraction**: your agents and workflows only ever
reference abstract tiers — `fast-worker`, `solid-worker`, `deep-thinker` — and each city
binds those to a concrete model family. Run one city on Gemini/Antigravity and another on
Claude from the *same* config; only the per-city binding changes.

---

## What's inside

```
gascity-cookbook/
├── packs/
│   └── core-city/                 # the shareable pack — import this into any city
│       ├── pack.toml              # provider family concretes, imports, the mayor named_session
│       ├── model-tiers.base.toml  # role -> tier map (single source of truth)
│       ├── agents/mayor/          # coordinator: prompt.template.md + agent.toml
│       ├── template-fragments/    # reusable prompt chunks (routing, rhythm, coding rules)
│       ├── commands/              # `gc cc <name>` custom CLI commands
│       ├── orders/                # scheduled dispatch (hourly mayor sweep)
│       └── assets/scripts/        # helper scripts
│
├── cities/
│   ├── gemini-city/               # example deployment on Antigravity (Gemini)
│   └── claude-city/               # example deployment on Claude
│       └── {city.toml, pack.toml, model-tiers.toml}
│
├── recipes/                       # the patterns, explained
│   ├── multi-provider-tiers.md
│   ├── the-mayor.md
│   └── per-role-model-tiers.md
│
├── SETUP.md                       # how to instantiate a new city + manual prerequisites
└── LICENSE                        # MIT
```

---

## The mental model (6 pieces)

| Piece | What it is |
|---|---|
| **Pack** | A reusable directory of config (`pack.toml` + definitions). `core-city/` is one. |
| **City** | A deployment: a `city.toml` (workspace provider + rigs) + a `pack.toml` (its imports). The city *is* the root pack. |
| **Rig** | A project/repo attached to a city, where work happens. |
| **Provider** | A coding-agent CLI + model (`claude`, `agy`, `kimi`), declared under `[providers.<name>]`. |
| **Agent / Role** | A worker or coordinator with a prompt. Formulas route work to roles by name. |
| **Formula** | A workflow (e.g. `build-basic`) whose steps route to roles. |

Config is **composed at load time**: a city's imports layer together (core-city + the
remote role/formula packs), then `city.toml` selects the workspace provider and rigs. No
single file holds the final answer — trace it with `gc config explain`.

---

## Quick start

Prerequisites: the `gc` CLI on your PATH, plus the provider CLI you'll use (`claude`, or
`agy` for Antigravity, or `kimi`). See [SETUP.md](SETUP.md) for the full list.

```bash
# 1. Pick a city to copy (gemini-city or claude-city), point a rig at your project:
cd cities/gemini-city
gc rig add /absolute/path/to/your/project     # registers the rig's real path

# 2. Validate, then bring it up
gc lint .
gc init . --preserve-existing                 # register + startup checks
gc start

# 3. Watch it
gc status
gc session peek cc.mayor                       # the always-on coordinator
```

Retune model tiers once in `packs/core-city/model-tiers.base.toml`, then regenerate each
city's fragment: `cd cities/<city> && gc cc gen-model-tiers > model-tiers.toml`.

---

## The one idea to take away

**Tier the interface; bind per city.** Everything downstream references
`fast-worker` / `solid-worker` / `deep-thinker`. `gemini-city` binds those to
Gemini Flash-Low / Pro-Low / Pro-High; `claude-city` binds them to Haiku / Sonnet / Opus.
The same pack, mayor, routing, and formulas run on either provider unchanged.

```toml
# gemini-city/city.toml            # claude-city/city.toml
[providers.deep-thinker]           [providers.deep-thinker]
base = "antigravity-deep-thinker"  base = "claude-deep-thinker"
```

---

## Recipes

- **[Multi-provider tiers](recipes/multi-provider-tiers.md)** — the family-concrete +
  per-city-alias pattern that makes the setup portable.
- **[The mayor](recipes/the-mayor.md)** — a single always-on coordinator that triages
  work, dispatches to tiers, and monitors.
- **[Per-role model tiers](recipes/per-role-model-tiers.md)** — generate the right model
  per workflow step from one base map.

Full instantiation + manual setup: **[SETUP.md](SETUP.md)**.

---

*Built with [Gas City](https://github.com/gastownhall/gascity) and the public
[gascity-packs](https://github.com/gastownhall/gascity-packs). Shared under MIT.*
