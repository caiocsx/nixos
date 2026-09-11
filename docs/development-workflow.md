# Development workflow

This document defines how an agent should approach, implement, validate, and report changes in this repository.

## 1. Understand the task before editing

Before modifying files:

1. Identify the behavior being requested.
2. Locate the current implementation.
3. Search for similar implementations elsewhere in the repository.
4. Identify the established project pattern.
5. Read the relevant architecture or Den documentation when the task touches those areas.

Do not begin by inventing a new abstraction.

## 2. Keep the change scoped

Prefer the smallest change that fully solves the requested problem.

Do not combine unrelated cleanup, broad renaming, architectural rewrites, or style sweeps with a focused task.

Small adjacent cleanup is acceptable when it is necessary for correctness or when the touched code would otherwise violate a documented convention, but it should remain obviously related to the task.

## 3. Stage files explicitly

Before Nix evaluation, stage new or changed files explicitly by path:

```bash
git add <specific-file> [<specific-file> ...]
```

Then verify:

```bash
git status
```

Only intended files should be staged.

Never use `git add .` or `git add -A`; both can include unrelated work already present in the worktree.

This step matters because flake evaluation does not see untracked files.

## 4. Format changed Nix files

Run `nixfmt` on changed Nix code before considering the implementation complete.

Prefer formatting only files relevant to the task rather than creating unrelated formatting churn.

## 5. Run evaluation checks

For ordinary configuration changes:

```bash
nix flake check
```

If the check fails:

1. read the actual error;
2. consult `troubleshooting.md` for known signatures;
3. diagnose the cause before reverting or layering on workarounds;
4. apply the smallest precise correction;
5. rerun the failed validation.

## 6. Apply or switch when appropriate

For a normal host application after checks pass:

```bash
nix run .#<host> -- switch
```

Do not assume the app name is the username. Repository apps are named by hostname; use `nix flake show` when uncertain.

## 7. Test risky system changes in a VM first

For changes involving high-risk system components, prefer:

```bash
nix run .#vm-<host>
```

Use VM testing for changes such as:

- drivers;
- bootloader configuration;
- display manager configuration;
- compositor-level changes with meaningful session risk;
- other changes that could make the host difficult to boot or use.

A small alias, application preference, or similarly low-risk user configuration does not need VM testing merely for ceremony.

## 8. Inspect the final diff

Before reporting completion, inspect what actually changed.

Useful commands include:

```bash
git diff
git diff --cached
git status
```

Confirm that:

- no unintended file was changed;
- no debug artifact was staged;
- no unrelated refactor slipped into the patch;
- generated files were updated only when required;
- the final structure still follows repository conventions.

## 9. Report validation truthfully

Never say that a command passed unless it was actually run and completed successfully.

Distinguish clearly between:

- **verified:** the command was run successfully;
- **not run:** the environment or task did not permit it;
- **expected:** reasoning suggests it should work, but it remains unverified.

If validation remains incomplete, state exactly what was not run.

## Adding a new aspect

Before creating an aspect, confirm that the capability has standalone identity. Pure implementation details should normally be `_`-prefixed files imported by their owner instead.

When an aspect is appropriate:

1. Create the `.nix` file in the correct aspect directory for its responsibility.
2. Define `den.aspects.<name>`.
3. Add only the `nixos` and/or `homeManager` classes actually required.
4. Include it from the relevant user or host.
5. Do not include it from both scopes unless the relationship genuinely requires that.
6. Stage the new file before flake evaluation.
7. Format and validate.

Example shape:

```nix
{ ... }:
{
  den.aspects.example = {
    homeManager =
      { ... }:
      {
        # ...
      };
  };
}
```

## Adding a flake input

Do not edit `flake.nix` by hand.

Workflow:

```bash
# 1. Edit flake-file.inputs in modules/dendritic.nix

# 2. Regenerate flake.nix
nix run .#write-flake

# 3. Update the relevant lock entry
nix flake lock --update-input <name>

# 4. Stage only the intended files
git add modules/dendritic.nix flake.nix flake.lock

# 5. Validate
nix flake check
```

If the exact generated file set differs, verify with `git status` rather than staging broadly.

## When to restructure instead of patching

If the same workaround appears three or more times in one area, stop adding another copy and reconsider the local structure.

Possible signals include:

- repeated conditional fragments;
- duplicated wrapper logic;
- the same value manually synchronized across several files;
- repeated exceptions to the same ownership rule.

A restructure should still be scoped to the problem at hand and should preserve established repository semantics.

## Suggested completion summary

When finishing a task, report:

1. what changed;
2. why that location or mechanism matches the repository architecture;
3. which validation commands were run and their result;
4. anything that remains unverified.

Do not report a commit unless the user explicitly requested one.
