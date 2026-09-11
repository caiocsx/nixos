# AGENTS.md

Guidance for AI coding agents working on this repository.

This file contains the rules that should always be in context. More detailed knowledge lives under `docs/` and should be read when relevant to the task.

## Repository

This is a multi-host NixOS configuration using flakes, home-manager, and the [Den](https://den.denful.dev) framework following the Dendritic pattern and Den's default-template conventions.

Project priorities, in order:

1. Reproducibility.
2. Extensibility.
3. Long-term maintainability.

## Core principles

1. **Standardize equivalent solutions.** If the repository already has a pattern for the same class of problem, reuse it. Do not invent a second mechanism without a documented reason.
2. **Keep responsibilities obvious.** Code, files, naming, and directory placement should reflect what owns the behavior.
3. **Centralize shared values, decentralize feature ownership.** Cross-cutting values belong in one shared source of truth; feature-specific implementation belongs to the aspect that provides that feature.
4. **Prefer small, well-ordered files.** Reconsider a file once it grows large enough to mix concerns or become difficult to scan. Use manually imported `_`-prefixed parts when appropriate.
5. **Code quality is part of correctness.** Avoid unclear names, oversized functions, dead code, misleading ordering, and unnecessary abstractions.
6. **Make minimal, targeted changes.** Solve the requested problem without unrelated refactors.

For architectural decisions, read [`docs/architecture.md`](docs/architecture.md).

## Before implementing

Before introducing a new pattern:

1. Search the repository for an existing implementation of the same or a similar problem.
2. Identify the closest established pattern.
3. Prefer adapting that pattern over creating a new abstraction.
4. If the existing pattern does not fit, explain why before introducing another mechanism.

Do not assume the first plausible implementation is the repository's preferred implementation.

## Non-negotiable rules

These rules exist because violating them has caused repeated real failures.

### Git and flake evaluation

- New or untracked files are invisible to flake evaluation until staged.

### Nix function scope

- Capture `inputs` and similar closure values only at the outermost function when the file needs them.
- Do not redeclare those values as arguments of nested `nixos` or `homeManager` functions.
- Redeclaring them can cause `infinite recursion encountered`, especially inside submodules.

### `import-tree`

- Files and directories that are not standalone Den aspects must be `_`-prefixed.
- Helpers, generated fragments, hardware configuration, theme fragments, and manually imported implementation files should therefore use names such as `_settings.nix` or `_hardware-configuration.nix`.

### Den aspect shape

- A single-class aspect may use the abbreviated `den.aspects.<name>.<class>` assignment.
- When an aspect has multiple classes, define them together under one `den.aspects.<name>` attribute set.
- Never repeat the same aspect in separate assignments to add another class; convert the existing definition to the multi-class form.

### nixpkgs configuration

- `nixpkgs.config` and overlays are owned by `modules/aspects/core/nixpkgs.nix`.
- `home-manager.useGlobalPkgs = true` means home-manager uses the system `pkgs` instance.
- Do not duplicate `allowUnfree`, `permittedInsecurePackages`, or overlays between NixOS and home-manager configuration.

### Generated flake

- `flake.nix` is generated. Never edit it by hand.
- Add inputs through `flake-file.inputs` in `modules/dendritic.nix`.
- Regenerate with `nix run .#write-flake` and then update the relevant lock entry.

For Den-specific mechanisms and conventions, read [`docs/den-conventions.md`](docs/den-conventions.md).

## Shared appearance

Cross-cutting visual values have a single source of truth in `modules/aspects/desktop/theme/_ui.nix`, exposed to home-manager aspects through `_module.args.ui` from the `theme` aspect.

Use `ui` for shared values such as colors, border radius, and typography. Do not duplicate an existing shared visual value inside an individual aspect.

This rule applies to shared **values**, not feature-specific implementation. See [`docs/architecture.md`](docs/architecture.md).

## Code style

- Avoid `with`; prefer `inherit` or qualified names such as `pkgs.foo`.
- Prefer `lib.optional`, `lib.optionals`, and `lib.optionalAttrs` for basic conditional composition.
- Use `inherit` instead of repeating `x = x;`-style assignments where appropriate.
- Comments should explain **why**, not restate **what** the code already says.
- Format Nix code with `nixfmt` before considering a change complete.
- Diagnose before reverting. Prefer one precise fix over broad rollback.
- If the same workaround appears three or more times in one area, treat that as a signal to reconsider the structure rather than adding another copy.

## Validation

For ordinary changes, follow [`docs/development-workflow.md`](docs/development-workflow.md).

At minimum:

1. Stage only the intended files.
2. Confirm the staged set with `git status`.
3. Run `nixfmt` on changed Nix files.
4. Run `nix flake check` when applicable.
5. Inspect the final diff.

Never claim that a command passed unless it was actually run successfully. If validation cannot be performed, explicitly state what remains unverified.

## Troubleshooting

Before inventing a workaround for an evaluation, activation, or build failure, consult [`docs/troubleshooting.md`](docs/troubleshooting.md).

Known failure signatures in that document represent issues already encountered in this repository and should be checked first.

## What not to do

- Do not centralize a program's `xdg.mimeApps`, systemd service, package ownership, or other feature implementation into a generic parent aspect merely for convenience.
- Do not add `den.schema` for a value that is purely local to one aspect.
- Do not assume Stylix and a manually written theme option can safely own the same property at the same time.
- Do not introduce a second mechanism for a problem the repository already solves consistently.
- Do not leave a large multi-concern file unsplit once it becomes difficult to read or maintain.
