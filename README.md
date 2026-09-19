<div align="center">
  
![GitHub last commit](https://img.shields.io/github/last-commit/caiocsx/nixos?style=for-the-badge&)
![GitHub Repo stars](https://img.shields.io/github/stars/caiocsx/nixos?style=for-the-badge&)
![GitHub repo size](https://img.shields.io/github/repo-size/caiocsx/nixos?style=for-the-badge&)

</div>

# nixos

My personal NixOS configuration, built with [flakes](https://nixos.wiki/wiki/Flakes), [home-manager](https://github.com/nix-community/home-manager), and the [Den](https://den.denful.dev) framework, based on the [default](https://den.denful.dev/tutorials/default/) template.

The primary goal of this repository is **reproducibility, extensibility, and long-term maintainability** across multiple personal hosts. It is **not intended to be a generic public template**, although its structure makes it easy for anyone to fork and adapt to their own needs.

## Table of contents

- [nixos](#nixos)
  - [Table of contents](#table-of-contents)
  - [Hosts](#hosts)
  - [Installation](#installation)
    - [Before you start](#before-you-start)
    - [Option A — Clean install](#option-a--clean-install)
    - [Option B — Adding this config to an existing NixOS install](#option-b--adding-this-config-to-an-existing-nixos-install)
    - [Post-installation notes](#post-installation-notes)
  - [Default keybinds](#default-keybinds)
  - [Project structure](#project-structure)
  - [Den concepts](#den-concepts)
  - [Common workflows](#common-workflows)
    - [Applying changes](#applying-changes)
    - [Adding a new user](#adding-a-new-user)
    - [Adding a new host](#adding-a-new-host)
    - [Adding a new aspect](#adding-a-new-aspect)
    - [Swapping a default program](#swapping-a-default-program)
    - [Adding a new flake input](#adding-a-new-flake-input)
    - [Testing in a VM before applying on real hardware](#testing-in-a-vm-before-applying-on-real-hardware)
  - [References](#references)

## Hosts

| Host      | Machine | GPU          |
| --------- | ------- | ------------ |
| `pad`     | Laptop  | AMD (amdgpu) |
| `station` | Desktop | NVIDIA       |

Primary user on both hosts: `caiocsx`.

## Installation

There are two ways to install this configuration, depending on whether you're starting from a blank disk or already have NixOS running. Both share the same first step.

### Before you start

Every host — and, if needed, every user — needs to already exist in the repository, declared and committed, **before** you can build or install it.

1. **Host.** Pick a name for your host (e.g. `pad`, `station`, or something new) and prepare it by copying an existing host directory as a starting point:
   ```bash
   cp -r modules/hosts/pad modules/hosts/<host>
   rm modules/hosts/<host>/_hardware-configuration.nix   # this gets generated later, not copied
   ```
   Adjust `modules/hosts/<host>/default.nix` for your machine (GPU driver, keyboard layout, etc). See [Adding a new host](#adding-a-new-host) for details.

2. **User.** If you're reusing the existing `caiocsx` user, skip this step. If you need a new user, create it first — see [Adding a new user](#adding-a-new-user).

3. **Declare both together** in `hosts.nix`:
   ```nix
   den.hosts.x86_64-linux.<host> = {
     compositor = "hyprland";
     displayManager = "noctalia-greeter";
     users.<user>.desktopShell = "noctalia";
   };
   ```

Once this is done, follow whichever installation option applies to you below.

### Option A — Clean install

Follow the full step-by-step script in this Gist:

**[NixOS Installation Guide](https://gist.github.com/caiocsx/709e1a028f9c390b4aa24b45f2125f74)**

It walks through, in order:

0. Connecting to the internet (skip if using Ethernet).
1. Partitioning the disk, reusing the existing EFI partition if dual-booting alongside another OS.
2. Formatting the root partition — Btrfs (with a `@`/`@home`/`@nix`/`@log` subvolume layout) or plain ext4, your choice.
3. Mounting everything.
4. *(Optional)* Cleaning up leftover boot files from a previous NixOS install sharing the same EFI partition.
5. Cloning this repository into `/mnt/etc/nixos` and generating the hardware configuration with `nixos-generate-config --root /mnt`, which gets placed into `modules/hosts/<host>/_hardware-configuration.nix` — the file you already made room for in [Before you start](#before-you-start).
6. Running `nixos-install --root /mnt --flake .#<host>`, setting the primary user's password with `passwd <user>` inside `nixos-enter`, then rebooting.

> [!WARNING]
> The disk partitioning and formatting commands in the guide are destructive. Double-check device names with `lsblk` before running any `mkfs`/`cfdisk` command.

After the first reboot, log in and move the repository into your home directory — the aliases and examples throughout this README assume the config lives at `~/nixos`:

```bash
sudo mv /etc/nixos ~/nixos
sudo chown -R "$(whoami)":users ~/nixos
```

(If you'd rather keep it at `/etc/nixos`, just adjust the paths used by the aliases in `shell/zsh.nix` accordingly.)

### Option B — Adding this config to an existing NixOS install

If you already have NixOS running (installed some other way) and want to switch to this flake without reinstalling:

```bash
git clone https://github.com/caiocsx/nixos.git ~/nixos
cd ~/nixos
```

Generate the hardware configuration for the machine you're already booted into (no `--root` needed, since you're not installing from a live ISO):

```bash
sudo nixos-generate-config --show-hardware-config > modules/hosts/<host>/_hardware-configuration.nix
```

Then build and activate:

```bash
git add -A
nix run .#<host> -- switch
```

Replace `<host>` with the host name you prepared in [Before you start](#before-you-start) (for example, `pad` or `station`).

> [!NOTE]
> Nothing needs to be installed beforehand besides Nix/NixOS itself. `nix run` builds the activation application directly from the flake.

### Post-installation notes

A few things that are easy to be caught off guard by right after a fresh install:

**Dual-boot may boot straight into the other OS**. Installing GRUB doesn't always reorder the motherboard's existing UEFI boot entries. If Windows (or another OS) was already first in the boot order, the firmware may keep booting it directly, skipping GRUB entirely, even though NixOS installed correctly. **To fix this**, move the **NixOS/GRUB** boot entry to the top of the boot order in your BIOS/UEFI settings.

**Some apps need a first manual launch to fully apply their settings.** VSCodium and Zen Browser, in particular, may not reflect all declared personalization (extensions, settings) until you open them at least once after activation. This is expected — just launch them once after logging in for the first time.

**Wallpaper starts empty.** The first login has no wallpaper set. Set one with `SUPER + W` (see [Default keybinds](#default-keybinds)) — the images bundled in `assets/wallpapers/` are available immediately.

## Default keybinds

| Keybind                         | Action                       |
| ------------------------------- | ---------------------------- |
| `SUPER + Return`                | Open terminal                |
| `SUPER + B`                     | Open browser                 |
| `SUPER + E`                     | Open editor                  |
| `SUPER + F`                     | Open file manager            |
| `SUPER + Q`                     | Close active window          |
| `SUPER + R`                     | Open application launcher    |
| `SUPER + ALT + L`               | Lock session                 |
| `SUPER + ESCAPE`                | Open power menu              |
| `SUPER + A`                     | Toggle control center        |
| `SUPER + SHIFT + B`             | Toggle status bar            |
| `SUPER + W`                     | Open wallpaper picker        |
| `SUPER + ALT + [` / `]`         | Previous/next wallpaper      |
| `SUPER + V`                     | Open clipboard history       |
| `SUPER + SHIFT + V`             | Clear clipboard history      |
| `SUPER + 1`–`9`                 | Focus workspace              |
| `SUPER + SHIFT + 1`–`9`         | Move window to workspace     |
| `SUPER + H` / `J` / `K` / `L`  | Focus adjacent window        |
| `SUPER + Print`                 | Capture active window        |
| `SUPER + SHIFT + Print`         | Capture selected region      |
| `SUPER + CTRL + Print`          | Capture current output       |

`SUPER + Return` / `B` / `E` / `F` open whatever is currently set as `$TERMINAL` / `$BROWSER` / `$EDITOR` / `$FILE_MANAGER` — see [Swapping a default program](#swapping-a-default-program) to change them.

## Project structure

```
.
├── assets/
│   ├── nixos.png                  # Nix logo used by Fastfetch
│   ├── nixos-white.png            # Nix logo used by Noctalia
│   └── wallpapers/                # images used by the wallpaper integrations
├── modules/
│   ├── aspects/
│   │   ├── core/                  # system fundamentals, active on every host
│   │   ├── desktop/               # graphical environment
│   │   │   ├── compositors/hypr/  # Hyprland and shell integrations
│   │   │   ├── shared/            # shell-independent desktop configuration
│   │   │   └── shell/             # selectable modular and Noctalia shells
│   │   ├── gaming/
│   │   ├── programs/              # one aspect per program
│   │   ├── services/              # optional daemons and system capabilities
│   │   └── shell/                 # interactive shell and CLI tools
│   │
│   ├── hosts/                     # host-specific configuration
│   │   ├── pad/
│   │   │   ├── _hardware-configuration.nix   # generated by nixos-generate-config
│   │   │   └── default.nix
│   │   └── station/
│   │       ├── _hardware-configuration.nix
│   │       └── default.nix
│   │
│   ├── users/
│   │   └── caiocsx.nix            # defines the user and which aspects it includes
│   │
│   ├── defaults.nix               # stateVersion, class schema, global includes
│   ├── dendritic.nix              # Den/flake-file input wiring
│   ├── hosts.nix                  # declaration of which hosts/users exist
│   ├── nh.nix                     # generates the `nix run .#<host> -- switch` apps
│   └── vm.nix                     # generates the `nix run .#vm-<host>` apps
│
├── flake.nix                      # AUTO-GENERATED — do not edit by hand
├── flake.lock
└── README.md
```

Any `.nix` file inside `modules/` is loaded automatically by `import-tree`, regardless of folder depth — there's no manual import list. Files that are **not** Den modules (e.g. hardware-configuration generated by a tool) are prefixed with `_` so this mechanism ignores them, and are imported manually wherever needed.

## Den concepts

This repository follows the **Dendritic** pattern, implemented by [Den](https://den.denful.dev): configuration is organized by **feature** (aspect), not by host. Each aspect is a function that can generate configuration for multiple Nix "classes" at once — typically `nixos` and `homeManager` — avoiding duplicating the same idea across separate files.

```nix
den.aspects.example = {
  nixos = { pkgs, ... }: { /* system config */ };
  homeManager = { pkgs, ... }: { /* user config */ };
};
```

Main concepts used in this repo:

- **Aspect** — a feature, spanning multiple classes (e.g. `den.aspects.hyprland`).
- **`includes`** — how a host or user "turns on" an aspect (`den.aspects.pad.includes = [ den.aspects.gaming ];`).
- **`provides.to-users` / `provides.to-hosts`** — how a host and a user exchange configuration without direct coupling (e.g. the `pad` host provides monitor-specific config to the user via `provides.to-users.homeManager`).
- **`den.batteries.*`** — ready-made utilities from Den itself (`define-user`, `primary-user`, `user-shell`, etc).

## Common workflows

### Applying changes

```bash
git add -A                        # flakes only see files tracked by git!
nix flake check                   # validate before applying
nix run .#<host> -- switch        # apply on the current host
```

Every workflow below ends with this same sequence. Once the config is installed, a handful of shell aliases (defined in `shell/zsh.nix`) shorten this for daily use:

| Alias         | Real command                               | What it does                                               |
| ------------- | ------------------------------------------ | ---------------------------------------------------------- |
| `nix-check`   | `nix flake check`                          | Validates the whole config without applying it             |
| `nix-rebuild` | `nh os switch ~/nixos`                     | Builds and applies the configuration to the current host   |
| `nix-update`  | `nix flake update --flake ~/nixos`         | Updates all flake inputs                                   |
| `nix-upgrade` | `nix flake update ... && nh os switch ...` | Updates inputs and applies right after                     |
| `nix-clean`   | `nh clean all`                             | Cleans up old generations and runs garbage collection      |
| `nix-write`   | `nix run .#write-flake`                    | Regenerates `flake.nix` from `flake-file.inputs`           |

### Adding a new user

1. Create `users/<user>.nix` with `den.aspects.<user>`.
2. Add `includes` with the desired aspects.
3. Add **`user`** for user account settings (password, groups, etc), and **`homeManager`** for home-manager configuration (packages, user programs, etc).
4. Don't forget to declare your user and host in `modules/hosts`, then [apply the changes](#applying-changes).

### Adding a new host

1. Create `hosts/<host>/default.nix` with `den.aspects.<host>.nixos = { ... };`.
2. Generate the hardware configuration: `nixos-generate-config --root /mnt`, copy the result into `hosts/<host>/_hardware-configuration.nix`.
3. Declare its compositor, display manager, desktop shell, and users in `hosts.nix`.
4. Test with `nix run .#vm-<host>` if the change involves anything risky (GPU driver, bootloader), then [apply the changes](#applying-changes).

### Adding a new aspect

1. Create the `.nix` file in the corresponding directory (`programs/`, `services/`, `desktop/`, etc).
2. Define `den.aspects.<name> = { nixos = ...; homeManager = ...; };`.
3. Include the aspect wherever it makes sense — in `users/<user>.nix` (personal use) or in `hosts/<host>/default.nix` (host-specific).
4. [Apply the changes](#applying-changes).

### Swapping a default program

Switching to a different browser, editor, file manager, or similar is just adding a new aspect and retiring the old one — but a few things are easy to forget along the way:

1. Create the new aspect (e.g. `programs/firefox.nix`, `programs/zed.nix`) following the pattern of an existing one in `programs/`.
2. Update `xdg.mimeApps.defaultApplications` — both adding the new program's entries and removing the old program's, wherever they were declared.
3. Update any relevant `home.sessionVariables` (`BROWSER`, `EDITOR`, `FILE_MANAGER`, `TERMINAL`, etc.) to point at the new program.
4. If the old program left behind unwanted `.desktop` entries you no longer want showing up in the launcher, remove them or override them with `NoDisplay=true` via `xdg.dataFile`.
5. Swap the aspect in `users/<user>.nix` — remove the old one from `includes`, add the new one.
6. [Apply the changes](#applying-changes).

### Adding a new flake input

`flake.nix` is **generated automatically**, do not edit manually:

```bash
# 1. edit flake-file.inputs in modules/dendritic.nix
nix run .#write-flake                           # regenerate flake.nix
nix flake lock --update-input <input-name>      # resolve and pin the revision
git add flake.nix flake.lock modules/
nix flake check
```

### Testing in a VM before applying on real hardware

```bash
nix run .#vm-<host>
```

Recommended for high-risk changes (drivers, bootloader, Hyprland). For small, safe changes, `nix flake check` followed directly by [applying the changes](#applying-changes) is enough.

## References

- [Den — official documentation](https://den.denful.dev)
- [search.nixos.org](https://search.nixos.org) — package and option search (NixOS + home-manager)
