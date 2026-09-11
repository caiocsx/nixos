# Architecture

This document describes how responsibilities should be divided across the repository and how to decide where new configuration belongs.

Read this before making structural changes, moving configuration between aspects, introducing shared state, or adding a new cross-cutting abstraction.

## Architectural priorities

The repository optimizes for:

1. Reproducibility.
2. Extensibility.
3. Long-term maintainability.

These priorities imply two recurring rules:

- equivalent problems should use equivalent solutions;
- ownership should remain visible from the file structure.

## Standardization

Two equivalent problems should not be solved in two different ways without a documented reason.

Before adding a mechanism for something such as:

- per-host overrides;
- hiding unwanted `.desktop` entries;
- adding system tray tools;
- exposing values to scripts;
- adding user or host metadata;

search for an existing implementation and reuse its pattern when possible.

A new abstraction is justified only when the established pattern genuinely cannot represent the requirement cleanly.

## Organization

Organization applies at every level:

- **Code:** clear local structure, no dead code, no unexplained ordering.
- **Files:** a file should live where its responsibility says it belongs.
- **Naming:** use predictable vocabulary and casing across related aspects.
- **Physical proximity:** related configuration should live together; unrelated configuration should not be bundled merely because it is convenient to edit in one place.

## Shared values vs. feature ownership

These are separate concerns and must not be conflated.

### Centralize cross-cutting values

Values consumed by many unrelated aspects should have one source of truth.

Examples include:

- accent and semantic colors;
- border radius;
- blur strength;
- opacity;
- primary font family and size.

Nobody should need to edit several unrelated files to change one global visual property.

### Decentralize feature implementation

Implementation belongs to the aspect that **provides** the feature, not to a generic aspect that merely touches or invokes it.

Examples:

- a browser owns its own `xdg.mimeApps.defaultApplications` entries;
- a tool owns the systemd user service required to run it;
- a domain owns the packages conceptually belonging to that domain even when another component launches them;
- a wallpaper feature owns its wallpaper daemon rather than placing that daemon in a generic compositor module.

Centralizing feature implementation creates hidden coupling and makes future replacement or removal harder.

## Centralized appearance

All cross-cutting visual values live in `modules/aspects/desktop/theme/_ui.nix`.

They are exposed to home-manager aspects through `_module.args.ui`, wired from the `theme` aspect in `modules/aspects/desktop/theme/default.nix`.

`ui` is the single source of truth for shared presentation values such as:

- accent and semantic colors derived from the Stylix base16 palette;
- background and foreground colors;
- border radius;
- shared font family and size;
- other visual values that are genuinely consumed by multiple aspects.

An aspect should read shared values through expressions such as:

```nix
ui.colors.bg
ui.border.radius
ui.font.mono
```

Do not hardcode a value locally when the same semantic value already exists in `ui`.

If a new property becomes cross-cutting, add it to `_ui.nix` instead of duplicating it across consumers.

This does **not** make `_ui.nix` the owner of feature-specific theme implementation. It only owns shared values.

## Aspect or plain `_`-file?

Ask:

> Would someone reasonably want this capability independently of its parent, or is it purely an implementation detail of one feature?

### Use an aspect when

The capability has standalone identity and could reasonably be enabled, disabled, or reused independently.

Examples:

- `power-menu`;
- `hyprsunset`;
- another independently useful service or program integration.

Define it as its own `den.aspects.<name>` and include it through Den's aspect relationships.

### Use a `_`-prefixed implementation file when

The code has no useful standalone identity and exists solely to support one parent feature.

Examples:

- a restore helper used only by one service;
- a `.rasi` theme fragment;
- a helper function imported by one aspect;
- generated or implementation-only configuration.

Import it manually from the owning aspect.

## Feature ownership

The aspect that **provides** a capability owns everything necessary to make that capability useful.

The aspect that merely invokes or displays the capability does not become its owner.

### `xdg.mimeApps`

Program-specific default application entries belong to the program's own aspect.

For example, browser MIME associations belong with the browser. A generic `xdg` aspect should own only generic XDG structure such as user directories or base configuration.

### systemd user services

A service required by a tool belongs to that tool's aspect.

For example, a wallpaper daemon belongs to the wallpaper feature rather than a generic Hyprland aspect.

### Packages

A package belongs to the domain that conceptually owns it, even when another component launches it.

For example, if a panel button opens an audio control application, the audio domain owns that package rather than the panel.

### Generic wrapper contracts

When a launcher-specific script wraps functionality that conceptually belongs elsewhere, prefer a generic contract rather than coupling unrelated aspects to one launcher implementation.

For example, wallpaper or clipboard functionality should not need to know whether the current launcher is Rofi, Wofi, or another frontend unless that dependency is intrinsic.

The goal is to make replacing a launcher a localized change.

## Choosing where a custom value belongs

Use the narrowest mechanism that correctly represents the data.

### Native NixOS or home-manager option

If the value already corresponds to a native option such as `time.timeZone`, `i18n.defaultLocale`, or `boot.kernelPackages`, set the shared default using `lib.mkDefault`.

A host can then override it with a normal assignment without requiring `mkForce`.

### Host or user property without a native option

If a value:

- has no native option;
- is genuinely a property of a host or user entity;
- may be consumed by more than one aspect;

register it through `den.schema.host` or `den.schema.user` as a typed option and consume it through the corresponding `host` or `user` context.

### Derived convenience helper

If a value is computed or derived for convenient reuse rather than raw settable configuration, `_module.args` is appropriate.

`ui` is the canonical example.

Do not use `_module.args` for raw user-settable data when a typed schema option better represents it.

### External shell process

If an external process launched from the shell must read the value, use `home.sessionVariables` when appropriate.

Examples include:

```text
$EDITOR
$TERMINAL
$BROWSER
$FILE_MANAGER
```

Do not use session variables merely to pass values between Nix modules.

### Host-user relationship value

A value that only makes sense for a specific `(host, user)` pair belongs in that relationship declaration:

```nix
den.hosts.<system>.<host>.users.<user> = {
  # relationship-specific values
};
```

Den merges contributions to the same path, so the declaration may be contributed from whichever file naturally owns the information.

## `provides.to-users` vs. `provides.to-hosts`

### `provides.to-users.homeManager`

Use this when a **host** needs to push configuration down to every user associated with that host.

Typical examples are hardware facts that users should not need to know about directly:

- monitor layout;
- GPU environment variables;
- keyboard layout;
- other machine-specific home-manager configuration.

### `provides.to-hosts.nixos`

Use this when a **user** needs to push NixOS configuration up to hosts on which that user is included.

This should be uncommon and reserved for information that is genuinely a property of the person rather than the machine.

Never place host-specific hardware facts directly in a user's shared aspect, because that configuration would follow the user onto other hosts.

## File size and decomposition

There is no hard line-count rule, but roughly 60–80 lines is a useful point to reconsider whether one file is carrying multiple concerns.

When decomposition improves readability, prefer explicitly imported `_`-prefixed parts, for example:

```nix
imports = [
  ./_part-a.nix
  ./_part-b.nix
];
```

Do not split files mechanically. Split them when the resulting boundaries reflect real responsibilities.
