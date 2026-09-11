# Troubleshooting

Check these known failure signatures before inventing a new workaround.

They represent failure modes already encountered in this repository.

## Diagnostic order

When a Nix evaluation, build, or activation fails:

1. Read the complete error and identify the first meaningful failure rather than the last cascade message.
2. Check `git status` and `git diff --cached`.
3. Confirm that new files are staged.
4. Compare the symptom against the table below.
5. Verify that the relevant option or package actually exists using the sources listed in `den-conventions.md`.
6. Make one precise correction and rerun the failing command.
7. Avoid broad rollback unless diagnosis shows the overall approach is wrong.

## Known failure signatures

| Symptom | Likely cause / first check |
| --- | --- |
| `attribute 'x' missing` | A newly created file may not be staged, so flake evaluation cannot see it. Check `git status`. |
| `infinite recursion encountered`, especially mentioning an anonymous `homeManager` function | `inputs` or another closure value may have been redeclared as an inner function argument instead of being captured from the outer function. |
| `Refusing to evaluate package ... unfree license` | Add the required package exception to the centralized nixpkgs configuration in `modules/aspects/core/nixpkgs.nix`; do not create a separate home-manager package set. |
| `Refusing to evaluate package ... marked as insecure` | Add the exact package to `permittedInsecurePackages` in `modules/aspects/core/nixpkgs.nix`. |
| `The option 'X' does not exist` | Check for a misplaced `};`, a block accidentally nested under the wrong option, or an option placed in the wrong class (`nixos` vs. `homeManager`). Verify the option name before rewriting the design. |
| home-manager activation fails with `Existing file '...' would be clobbered` | The target file already exists outside home-manager management. Determine its owner, then move or reconcile it deliberately before activating again. |
| The `homeManager` half of an aspect appears to be ignored | The aspect may have been included only at host scope, leaving no user in scope. Include it from the user or use `provides.to-users` when the host intentionally pushes home-manager configuration to users. |
| `nix run .#<x>` reports that the output does not exist | Apps are named by hostname rather than username. Run `nix flake show` to inspect actual output names. |
| `PATHS` or `DIFF` reports `0 bytes` after a build that should have changed something | The edited file may not be staged or may not be the file actually being evaluated. Inspect `git status` and `git diff --cached`. |

## `attribute 'x' missing`

First check whether the defining file is new and untracked.

Because flakes evaluate the Git tree, a file that exists on disk but is not staged can be absent from evaluation.

Use:

```bash
git status
git add <specific-file>
git status
```

Then rerun the failed Nix command.

Do not start rewriting module imports until the Git state has been ruled out.

## Infinite recursion

When an error points at an anonymous `homeManager` function, inspect nested function arguments.

A common incorrect pattern is redeclaring `inputs` inside a nested function even though it was already captured by the outer file function.

Keep such values in the outer closure instead.

This issue can be especially difficult to spot inside submodule-heavy configuration such as browser profile definitions.

## Missing option

Before assuming the desired behavior is unsupported:

1. verify the exact option name and type;
2. check whether it belongs to NixOS or home-manager;
3. inspect nearby braces and nesting;
4. verify that the option is being set in the correct module class.

A misplaced `};` can cause two otherwise valid blocks to become one invalid path.

## Unfree or insecure package failures

Package policy is centralized.

Do not fix these failures by creating a separate `pkgs` instance or duplicating nixpkgs configuration inside home-manager.

Because the repository uses `home-manager.useGlobalPkgs = true`, update `modules/aspects/core/nixpkgs.nix` so the shared package set has the required policy.

## home-manager file collision

When activation says an existing file would be clobbered, determine whether the file is:

- an old manually managed file;
- a leftover from a previous configuration mechanism;
- intentionally external to home-manager.

Do not blindly force overwrite behavior. Identify which configuration should own the file, preserve any content that is still needed, and then move or reconcile it deliberately.

## Aspect scope mismatch

An aspect containing `homeManager` configuration still requires user context.

If only the host includes that aspect, the home-manager portion may not be applied as expected.

Choose between:

- including the aspect from the user when it is user-owned; or
- using `provides.to-users.homeManager` when the host intentionally supplies host-specific information to its users.

Do not copy host-specific facts into a user's globally shared aspect as a workaround.

## When the symptom is not listed

If no known signature matches:

1. reproduce the smallest failing command;
2. verify repository state and staging;
3. consult upstream option/package/Den documentation;
4. inspect the closest working pattern in the repository;
5. change one variable at a time;
6. document a new failure signature here only after the root cause is understood and likely to recur.
