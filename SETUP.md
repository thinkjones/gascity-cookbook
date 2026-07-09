# Setup: instantiate a new city

How to stand up a new Gas City deployment from this cookbook — the manual prerequisites,
what goes in each file, and the commands to bring it up.

---

## 1. Prerequisites (install + auth these yourself)

Gas City orchestrates *existing* CLIs; it doesn't bundle them. On each machine you need:

| Tool | Why | Notes |
|---|---|---|
| **`gc`** | The Gas City CLI | Must be on PATH. `gc version` to check. |
| **A provider CLI** | The actual coding agent | `claude` (Claude), `agy` (Antigravity/Gemini), and/or `kimi`. Install and **authenticate** each one you'll use. |
| **`git`, `tmux`, `jq`** | Session + plumbing | `gc doctor` checks for these. |
| **`bd` / Dolt** | The beads work-ledger store | Pulled in via the `bd`/`core` imports; `gc doctor` verifies. Keep the `bd` binary version aligned with the linked beads library, or you'll see `native_store_unavailable` warnings. |

**Portability tip:** in `[providers.*]`, set `command` to a **bare name** (`command = "kimi"`),
never `$VAR` or an absolute path — those fields are not variable-expanded. Gas City broadens
PATH to include `~/.local/bin`, Homebrew, cargo, nvm/asdf, etc., so a bare name resolves on
every machine.

---

## 2. Instantiate — the fast way (copy an example)

```bash
cp -R cities/gemini-city cities/my-city      # or claude-city for a Claude deployment
cd cities/my-city
# edit pack.toml -> [pack].name = "my-city"
gc import install                            # FIRST on any fresh clone — fetches + pins the remote packs
gc rig add /absolute/path/to/your/project    # register a real rig path
gc cc gen-model-tiers > model-tiers.toml      # regenerate tier patches for your rig(s)
gc lint .
gc init . --preserve-existing
gc start
```

> **On a fresh clone, run `gc import install` first.** The cities import remote packs
> (`//gascity`, `//gascity/roles`, the `bd`/`core` bootstrap); `import install` fetches them
> and writes `packs.lock`. Until then, `gc lint` reports "remote import … is not installed".

That's it. Skip to [§6 Verify](#6-verify).

---

## 3. Instantiate — from scratch

A city is two files plus a generated fragment.

### `city.toml` — the deployment

```toml
#:schema https://raw.githubusercontent.com/gastownhall/gascity/main/docs/reference/schema/city-schema.json

include = ["model-tiers.toml"]                 # generated per-role tier patches (§5)

[workspace]
provider = "antigravity"                       # default provider (or "claude", "kimi")
install_agent_hooks = ["antigravity"]          # ONLY needed for antigravity (see §7)

# Bind the generic tiers to a model family (concretes are defined in core-city):
[providers.fast-worker]   { base = "antigravity-fast-worker" }
[providers.solid-worker]  { base = "antigravity-solid-worker" }
[providers.deep-thinker]  { base = "antigravity-deep-thinker" }

[[rigs]]
name = "my-service"
default_branch = "main"

[rigs.imports.gc]                              # the worker roles the formulas route to
source = "https://github.com/gastownhall/gascity-packs.git//gascity/roles"
```

> `include` and any top-level key must come **before** the first `[table]`.

### `pack.toml` — the imports

```toml
#:schema https://raw.githubusercontent.com/gastownhall/gascity/main/docs/reference/schema/pack-schema.json
[pack]
name = "my-city"
schema = 2

[imports]
[imports.bd]   { source = "https://github.com/gastownhall/gascity.git//examples/bd" }
[imports.core] { source = "https://github.com/gastownhall/gascity.git//internal/bootstrap/packs/core" }
[imports.cc]   { source = "../../packs/core-city" }                                   # this cookbook's pack
[imports.gc]   { source = "https://github.com/gastownhall/gascity-packs.git//gascity" } # formulas + gc.mayor skill
```

Adjust the `../../packs/core-city` path to wherever `core-city` lives relative to your city.

---

## 4. Register your rigs

A rig is a project repo. Declare it in `city.toml` (above), then register its real path:

```bash
cd cities/my-city
gc rig add /absolute/path/to/my-service
gc rig list
```

---

## 5. Generate the model tiers

The `include = ["model-tiers.toml"]` line expects a generated fragment. Produce it from the
shared base map (see the [per-role tiers recipe](recipes/per-role-model-tiers.md)):

```bash
gc cc gen-model-tiers > model-tiers.toml       # expands roles × your rigs into [[patches.agent]]
```

Re-run this whenever you add a rig or change `packs/core-city/model-tiers.base.toml`.

---

## 6. Bring it up & verify

```bash
gc lint .                                      # validate config
gc init . --preserve-existing                  # register the city + run startup checks
gc start                                       # start under the supervisor

gc status                                      # city health
gc config explain --json --provider deep-thinker | jq '.resolved.args'   # confirm tier → model
gc session peek cc.mayor                        # the always-on coordinator, primed and idle
```

**Change loop** thereafter: edit → `gc lint` → `gc config explain` (confirm the resolved
value) → `gc reload`.

---

## 7. Provider-specific manual bits

- **Antigravity (`agy`)** — you must (a) authenticate `agy` (Google/Gemini login), and
  (b) list it in `install_agent_hooks` so its managed prime/nudge/mail hooks install. Model
  names use the **display name**, not the model code: `--model "Gemini 3.1 Pro (High)"`.
- **Claude (`claude`)** — auto-installs hooks (no `install_agent_hooks` entry needed). Model
  selection via the provider's `model` option (`haiku`/`sonnet`/`opus`).
- **Kimi (`kimi`)** — auto-installs hooks; single model (no tier differentiation), so its
  fast/solid/deep concretes all point at the same `kimi` base.

---

## What you get once it's running

- An always-on **mayor** that triages requests, dispatches to the right model tier, and
  monitors (see the [mayor recipe](recipes/the-mayor.md)).
- Workflow formulas (e.g. `build-basic`) whose steps run on the right model automatically.
- Custom commands: `gc cc gen-model-tiers`, `gc cc clear-human-mail`.
- A scheduled hourly mayor sweep (an `order`).

Everything is config — nothing here is hardcoded into `gc`.
