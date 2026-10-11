<p align="center">
  <img src="./assets/readme/strip-contributing.svg" width="100%" alt="Gas City Cookbook: contributing">
</p>

# Contributing

This cookbook is a set of config patterns, so most contributions are a recipe, a provider family, or a fix to an example city. Small, focused pull requests are easiest to review.

## What fits here

- **A recipe**: a pattern you run in a real city, written up under `recipes/` with the config that makes it work and a way to verify it.
- **A provider family**: fast, solid and deep concretes for another coding-agent CLI in `packs/core-city/pack.toml`.
- **A fix**: a correction to a doc, an example city, a command or a prompt fragment.

Changes to Gas City itself belong in [gastownhall/gascity](https://github.com/gastownhall/gascity), and changes to the shared roles and formulas belong in [gastownhall/gascity-packs](https://github.com/gastownhall/gascity-packs).

## Before you open a pull request

1. Run `gc lint .` in each city your change touches.
2. If you changed `packs/core-city/model-tiers.base.toml`, regenerate every city's fragment and commit the result:

   ```bash
   cd cities/<city> && gc cc gen-model-tiers > model-tiers.toml
   ```

3. If you changed a provider or tier, confirm what it resolves to with `gc config explain --json --provider <tier>`.
4. Check that no runtime state is staged. `.gc/`, `.beads/`, `.agents/` and logs are ignored and should stay that way.
5. Keep secrets, machine-specific absolute paths and private rig names out of examples. Use `example-service` and bare command names.

## Writing a recipe

Follow the shape of the existing three:

1. **Goal**: one or two sentences on what the pattern gets you.
2. **The pieces**: the real config, with the file each snippet lives in.
3. **Gotchas**: anything that fails silently or surprised you.
4. **Verify**: a command whose output shows the pattern is working.

Add the recipe to the table in [README.md](README.md#recipes).

## Conventions

- Fragment files must end in `.template.md` and are referenced by their bare `define` name.
- Provider `command` values are bare names on PATH, never `$VAR` or an absolute path.
- Agents, formulas and fragments reference tiers (`fast-worker`, `solid-worker`, `deep-thinker`), never a concrete model.
- Don't hard-wrap prose in Markdown. Write each paragraph as a single line.

## License

By contributing you agree that your contribution is shared under the [MIT License](LICENSE).
