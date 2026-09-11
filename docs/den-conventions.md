# Den conventions

This document records repository-specific conventions for Den, Dendritic modules, `import-tree`, flake generation, and Nix module composition.

Read it before introducing a new aspect, changing Den relationships, adding schema, modifying flake inputs, or debugging behavior related to module discovery.

## Sources of truth

When unsure whether an option, package, or Den mechanism exists, verify it instead of guessing.

Preferred references:

- [NixOS option search](https://search.nixos.org/options?channel=unstable)
- [NixOS package search](https://search.nixos.org/packages?channel=unstable)
- [MyNixOS](https://mynixos.com)
- [NixOS Wiki](https://wiki.nixos.org)
- the relevant upstream project documentation, such as Hyprland's documentation
- [Den documentation](https://den.denful.dev)
- the [`denful/den`](https://github.com/denful/den) repository

For Den-specific concepts such as aspects, `provides`, `quirks`, `batteries`, and `schema`, prefer Den's own documented mechanism over inventing a parallel abstraction.

## `import-tree` and `_`-prefixed files

`import-tree` discovers ordinary module files automatically.

Anything that is **not** intended to be discovered as a standalone Den aspect must therefore be hidden from automatic discovery using an `_` prefix.

Examples:

```text
_ui.nix
_settings.nix
_hardware-configuration.nix
_theme.rasi
```

Use `_`-prefixed files for:

- helper functions;
- manually imported implementation parts;
- hardware configuration fragments;
- generated fragments;
- theme fragments;
- other files that are not independently meaningful aspects.

Without the prefix, `import-tree` may try to load the file as a standalone module and evaluation may fail because its top-level structure was never meant to be evaluated that way.

## Aspect shape

An aspect is the unit of ownership. Den classes such as `nixos`, `homeManager`, and `darwin` are implementations of that aspect, not separate aspects.

For an aspect with only one class, the abbreviated class-specific assignment is allowed:

```nix
{ ... }:
{
  den.aspects.example.homeManager = { ... };
}
```

When an aspect has multiple classes, define all of them under a single `den.aspects.<name>` attribute set:

```nix
{ ... }:
{
  den.aspects.networking = {
    nixos = { ... };
    homeManager = { ... };
  };
}
```

Never split the same aspect across multiple class-specific assignments:

```nix
den.aspects.networking.nixos = { ... };
den.aspects.networking.homeManager = { ... };
```

When adding a second class to an existing abbreviated aspect, convert the existing assignment to the multi-class form instead of adding another assignment. Do not add empty classes for symmetry.

Include the aspect from the user or host that owns the relationship. Avoid including the same aspect from both unless doing so is intentional and the ownership implications are understood.

See `architecture.md` for the distinction between standalone aspects and `_`-prefixed implementation files.

## Closure values and nested module functions

Values such as `inputs` that are captured by the file's outer function must remain closure values inside nested module functions.

Preferred pattern:

```nix
{ inputs, ... }:
{
  den.aspects.example.homeManager =
    { pkgs, ... }:
    {
      # use inputs here through the outer closure
    };
}
```

Avoid:

```nix
{ inputs, ... }:
{
  den.aspects.example.homeManager =
    { inputs, pkgs, ... }:
    {
      # redeclared inputs can cause recursion problems
    };
}
```

This is particularly important inside submodules such as `attrsOf submodule` definitions.

A recurring failure signature is `infinite recursion encountered` mentioning an anonymous home-manager function.

## nixpkgs ownership

`nixpkgs.config` and overlays are configured once through `modules/aspects/core/nixpkgs.nix`.

The repository uses:

```nix
home-manager.useGlobalPkgs = true;
home-manager.useUserPackages = true;
```

Because home-manager shares the system package set, do not duplicate configuration such as:

- `allowUnfree`;
- `permittedInsecurePackages`;
- overlays.

When a package needs a nixpkgs-level exception, change the central nixpkgs configuration rather than adding a second home-manager-specific mechanism.

## Generated `flake.nix`

`flake.nix` is generated and must not be edited manually.

To add an input:

1. Edit `flake-file.inputs` in `modules/dendritic.nix`.
2. Regenerate the flake:

```bash
nix run .#write-flake
```

3. Update the relevant input in the lock file:

```bash
nix flake lock --update-input <name>
```

4. Stage the generated files and source definition explicitly.
5. Run `nix flake check`.

## Schema vs. other value mechanisms

Do not reach for `den.schema` by default.

Use `den.schema.user` or `den.schema.host` only when the value is genuinely entity-level data with no suitable native option and may be consumed by multiple aspects.

For other cases:

- native NixOS/home-manager value → native option, commonly with `lib.mkDefault` for shared defaults;
- derived reusable helper → `_module.args`;
- local implementation value → keep it local to the owning aspect;
- external shell-facing value → `home.sessionVariables` when appropriate;
- `(host, user)` relationship value → store it on the relationship itself.

See `architecture.md` for the complete decision model.

## `provides`

Use Den's relationship mechanisms rather than copying hardware or user facts into the wrong scope.

### Host to users

```text
provides.to-users.homeManager
```

Use when host-specific information needs to affect the home-manager configuration of users on that host.

### User to hosts

```text
provides.to-hosts.nixos
```

Use only when a user-specific property genuinely needs to contribute NixOS configuration to hosts carrying that user.

This direction should be uncommon.

## Nix style used in this repository

### Avoid `with`

Prefer explicit qualification:

```nix
[
  pkgs.foo
  pkgs.bar
]
```

or `inherit` where appropriate.

Avoid:

```nix
with pkgs; [
  foo
  bar
]
```

Explicit names improve readability and editor tooling.

When touching an existing file for another reason, opportunistically remove nearby `with` usage if the change stays small and focused. Do not perform a disruptive repository-wide sweep merely for style.

### Conditionals

Prefer helpers such as:

```nix
lib.optional
lib.optionals
lib.optionalAttrs
```

over ad-hoc empty-list or empty-attribute fallbacks when the helpers express the intent directly.

### `inherit`

Use `inherit` when bringing existing names into an attribute set instead of repeating `x = x;` assignments.

### Comments

Comments explain decisions, constraints, or non-obvious reasons.

Do not add comments that merely translate the next line of code into English.
