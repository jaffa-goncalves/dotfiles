# Declarative Computing Infrastructure

## 1. Overview

This repository defines a modular, reproducible personal computing infrastructure using Nix, nix-darwin, and Home Manager.

The architecture separates machine configuration, operating system infrastructure, user identity, software selection, and program implementation into independently maintainable components.

The long-term objective is to support multiple users, machines, operating systems, and computing environments from a unified configuration repository without unnecessarily duplicating configuration.

## 2. Architectural Principles

### 2.1 Declarative configuration

The repository is the source of truth for the intended computing environment. Software installation, configuration, services, shell integration, and system preferences should be expressed declaratively wherever practical.

### 2.2 Separation of concerns

Each architectural layer has a distinct responsibility. User preferences should not be embedded in operating system infrastructure, and software implementation details should not be embedded in user profiles.

### 2.3 Program encapsulation

Each program owns its installation mechanism, configuration, dependencies, aliases, shell integration, and associated services.

Related configuration should be colocated within the program's directory.

### 2.4 Platform abstraction

Users select capabilities and programs without needing to explicitly select operating system-specific implementations.

The composition layer resolves the appropriate implementation for the target platform.

### 2.5 Reproducibility

External dependencies are pinned through the flake lockfile. Changes to the computing environment should be version-controlled, reviewable, and recoverable.

### 2.6 Nix-first package management

Nix is the preferred software distribution mechanism.

Alternative package managers, including Homebrew, are supported when Nix does not provide a sufficiently suitable implementation.

### 2.7 Explicit failure

Unsupported platforms, invalid program declarations, and missing dependencies should produce actionable errors rather than silently omitting requested functionality.

## 3. Repository Structure

```text
nix/
├── flake.nix
├── flake.lock
├── README.md
│
├── hosts/
│   └── macbook/
│       └── default.nix
│
├── systems/
│   └── darwin/
│       ├── default.nix
│       ├── homebrew.nix
│       └── nixpkgs.nix
│
├── homes/
│   ├── jaffa/
│   │   ├── default.nix
│   │   ├── identity.nix
│   │   ├── environment.nix
│   │   ├── profiles.nix
│   │   ├── settings.nix
│   │   └── darwin/
│   │       └── system.nix
│   └── muse/
│
├── profiles/
│   ├── ai.nix
│   ├── browsing.nix
│   ├── communication.nix
│   ├── desktop.nix
│   ├── development.nix
│   ├── documents.nix
│   ├── gaming.nix
│   ├── languages.nix
│   ├── media.nix
│   ├── networking.nix
│   ├── nix.nix
│   ├── terminal.nix
│   ├── virtualization.nix
│   └── darwin/
│
├── programs/
│   └── <program>/
│       ├── default.nix
│       └── ...
│
└── lib/
    ├── mk-host.nix
    ├── resolve-home.nix
    └── resolve-programs.nix
```

## 4. Architectural Layers

| Layer | Responsibility |
|---|---|
| Flake | Dependency management and deployment entry points |
| Hosts | Machine identity and deployment targets |
| Systems | Reusable operating system infrastructure |
| Homes | User identity, preferences, and capability selection |
| Profiles | Logical collections of programs |
| Programs | Individual software implementations |
| Library | Configuration resolution and composition |

### 4.1 Flake

The flake defines external dependencies and exposes deployable system configurations.

Its responsibilities include:

- Declaring external inputs.
- Maintaining reproducible dependency revisions through `flake.lock`.
- Exposing named host configurations.
- Invoking the host composition library.

The flake should remain a thin entry point rather than accumulating machine-specific or application-specific configuration.

### 4.2 Hosts

A host represents a deployable computing environment.

Host manifests declare:

- Hostname.
- Target platform.
- Associated users.
- Primary user.
- System state version.
- Additional host-specific modules.

Example:

```nix
{
  hostname = "Jaffa-Saahs-MacBook-Pro";
  platform = "aarch64-darwin";

  users = [
    ../../homes/jaffa
  ];

  primaryUser = "jaffa";
  stateVersion = 6;

  modules = [];
}
```

Hosts should describe deployment-specific requirements rather than individual software implementations.

### 4.3 Systems

The systems layer defines reusable operating system infrastructure.

Examples include:

- Package management backends.
- Nix configuration.
- Operating system-wide policies.
- Package licensing policies.
- System infrastructure shared across hosts.

The Darwin implementation currently provides Homebrew integration and Nixpkgs configuration.

Homebrew infrastructure belongs in the systems layer, but individual Homebrew applications belong in their respective program modules.

### 4.4 Homes

A home represents a user's declarative computing environment independently of a particular machine.

A home defines:

- User identity.
- Selected capability profiles.
- Environment variables.
- User-level settings.
- Platform-specific preferences.
- Personal system preferences where supported.

Example home manifest:

```nix
{
  identity = import ./identity.nix;

  profiles = import ./profiles.nix;

  home = [
    ./environment.nix
    ./settings.nix
  ];

  darwin = {
    system = [
      ./darwin/system.nix
    ];
  };
}
```

The composition library derives the default home directory from the target platform unless explicitly overridden.

User-specific system preferences are applied through the primary user to prevent multiple users from independently imposing conflicting machine-wide settings.

### 4.5 Profiles

Profiles represent logical capabilities rather than individual applications.

For example, a development profile may include Git, GitHub CLI, Helix, Visual Studio Code, and other development utilities.

```nix
{
  programs = [
    ../programs/git
    ../programs/gh
    ../programs/lazygit
    ../programs/helix
    ../programs/code
    ../programs/just
    ../programs/wrangler
  ];
}
```

Profiles must not contain application implementation details.

#### Platform extensions

Profiles may have corresponding platform-specific extensions.

```text
profiles/
├── terminal.nix
└── darwin/
    └── terminal.nix
```

When a user selects the terminal profile, the resolver automatically includes the Darwin extension when targeting macOS.

The shared profile and platform extension are additive.

This allows platform-specific software to be introduced without requiring users to maintain separate profile selections for each operating system.

### 4.6 Programs

A program is the smallest independently selectable software configuration unit.

Each program is represented by a directory containing a manifest and one or more implementation modules.

```text
programs/
└── example/
    ├── default.nix
    ├── home.nix
    ├── darwin.nix
    ├── nixos.nix
    ├── macos.nix
    └── linux.nix
```

Only files required by the program need to exist.

Programs may additionally contain configuration files, package overrides, scripts, extension declarations, or other implementation resources.

### 4.7 Library

The library contains the reusable composition logic responsible for translating declarative manifests into native operating system and Home Manager modules.

The library should remain independent of individual program identities and user preferences.

## 5. Program Manifest Contract

A program's `default.nix` is a custom architectural manifest, not necessarily a native Nix module.

Supported manifest attributes are:

| Attribute | Purpose |
|---|---|
| `home` | Shared Home Manager module |
| `darwin` | nix-darwin system module |
| `nixos` | NixOS system module |
| `macos.home` | macOS-specific Home Manager module |
| `linux.home` | Linux-specific Home Manager module |

Example:

```nix
{
  home = ./home.nix;
  macos.home = ./macos.nix;
  linux.home = ./linux.nix;
  darwin = ./darwin.nix;
  nixos = ./nixos.nix;
}
```

All attributes are optional individually. However, a selected program must provide at least one applicable implementation for the target platform.

Shared and platform-specific Home Manager modules are additive.

System modules are selected according to the target operating system.

### 5.1 Shared Nix program

```nix
# default.nix
{
  home = ./home.nix;
}
```

```nix
# home.nix
{ pkgs, ... }:

{
  home.packages = [
    pkgs.ripgrep
  ];
}
```

### 5.2 Homebrew application

```nix
# default.nix
{
  darwin = ./darwin.nix;
}
```

```nix
# darwin.nix
{
  homebrew.casks = [
    "discord"
  ];
}
```

### 5.3 Cross-platform application

```nix
{
  darwin = ./darwin.nix;
  linux.home = ./linux.nix;
}
```

This permits a program to use Homebrew on macOS and Nix on Linux while maintaining a consistent program identity.

### 5.4 Program with platform-specific services

```nix
{
  home = ./home.nix;
  macos.home = ./macos.nix;
}
```

The shared module may install the program, while the macOS-specific module manages its launchd agent.

A future Linux implementation may introduce a corresponding systemd user service.

## 6. Configuration Composition

Configuration composition proceeds through the following logical stages:

```text
Flake
  │
  ▼
Host manifest
  │
  ▼
Host composition
  ├── System infrastructure
  ├── User resolution
  │     ├── Identity
  │     ├── User preferences
  │     └── Profile resolution
  │           ├── Shared profiles
  │           ├── Platform extensions
  │           └── Program resolution
  │                 ├── Shared home modules
  │                 ├── Platform home modules
  │                 └── System modules
  │
  ▼
Operating system configuration
  ├── System modules
  └── Home Manager configurations
  │
  ▼
System derivation
  │
  ▼
Build and activation
```

### 6.1 Host composition

`lib/mk-host.nix`

Responsible for:

- Determining the target operating system.
- Resolving declared users.
- Validating user uniqueness.
- Validating the primary user.
- Aggregating program system modules.
- Constructing Home Manager configurations.
- Applying operating system infrastructure.
- Applying primary-user system preferences.
- Invoking the native system configuration constructor.

Darwin host composition is currently implemented.

NixOS host composition is an intended extension of the architecture.

### 6.2 Home resolution

`lib/resolve-home.nix`

Responsible for:

- Loading the home manifest.
- Resolving user identity.
- Determining the home directory.
- Selecting platform-specific home settings.
- Resolving selected profiles.
- Aggregating Home Manager modules.
- Returning applicable system modules and user-specific system preferences.

### 6.3 Program resolution

`lib/resolve-programs.nix`

Responsible for:

- Determining the target platform.
- Loading selected shared profiles.
- Discovering corresponding platform profile extensions.
- Aggregating program paths.
- Deduplicating selected programs.
- Loading program manifests.
- Selecting applicable implementations.
- Rejecting programs without applicable implementations.
- Returning deduplicated home and system module collections.

## 7. Ownership and Configuration Boundaries

| Configuration | Owner |
|---|---|
| Hostname | Host |
| Hardware-specific configuration | Host |
| Operating system infrastructure | System |
| Package manager infrastructure | System |
| Unfree package policy | System |
| Username and identity | Home |
| General environment preferences | Home |
| Personal desktop preferences | Home |
| Capability selection | Home |
| Program collections | Profile |
| Application installation | Program |
| Application configuration | Program |
| Application-specific aliases | Program |
| Application-specific environment variables | Program |
| Application-specific services | Program |
| Platform resolution | Library |
| External dependency revisions | Flake |

Configuration should be placed in the narrowest appropriate ownership boundary.

For example, Git aliases belong in the Git program module rather than in a global shell configuration.

## 8. Package Management Strategy

### 8.1 Nix

Nix is the preferred mechanism for installing and configuring software.

Benefits include:

- Dependency isolation.
- Version-controlled configuration.
- Reproducible package selection.
- Generation-based system management.
- Integration with Home Manager.

### 8.2 Homebrew

Homebrew is a secondary package management backend for macOS applications that are unavailable or unsuitable through Nix.

Applications are declared through individual program modules.

Homebrew installations remain machine-wide even when their selection originates from a particular user's profiles.

Automatic updates, upgrades, and destructive cleanup are currently disabled during activation.

### 8.3 Custom packages

Programs requiring customized package derivations may maintain a dedicated `package.nix`.

Custom package overrides should remain colocated with the program they modify.

Overrides should document:

- The upstream limitation.
- The reason for the override.
- Relevant upstream issues.
- Conditions under which the override can be removed.

### 8.4 External package inputs

External flakes may provide software that is not adequately supported by the primary Nixpkgs package set.

Such inputs must be declared through the flake and pinned through the lockfile.

External forks and temporary upstream workarounds should be reviewed periodically.

### 8.5 Licensing

Unfree software is permitted through an explicit package allowlist rather than unrestricted global permission.

Package licensing exceptions should be deliberate and narrowly scoped.

## 9. Service Management

Application services belong to their respective program modules.

The architecture distinguishes between:

- System services.
- User services.
- Interactive applications.
- On-demand command-line tools.

On macOS, user-level background services are managed through Home Manager's launchd integration where appropriate.

Ollama and Open WebUI are examples of applications with dedicated background service configurations.

User-level services should not require unnecessary root privileges.

Persistent application data should reside outside the immutable Nix store.

Services intended exclusively for local use should bind to loopback interfaces unless remote access is explicitly required.

## 10. State Management

Declarative configuration and mutable application state are separate concerns.

### Declarative state

Managed by this repository:

- Package declarations.
- Configuration files.
- Service definitions.
- Shell configuration.
- User preferences.
- System preferences.
- Dependency revisions.

### Mutable state

Managed outside the repository:

- Application databases.
- AI model weights.
- Virtual environments.
- User documents.
- Authentication credentials.
- Application caches.
- Runtime logs.
- Downloaded toolchains.

Rebuilding the system should not unnecessarily destroy mutable user data.

The architecture supports reproducible environment reconstruction but does not, by itself, constitute a complete backup and disaster recovery solution.

## 11. Security and Trust

The infrastructure should minimize unnecessary trust and privilege.

The following policies guide implementation:

- Prefer trusted upstream software sources.
- Review external dependencies and organizational provenance.
- Prefer software maintained by organizations in the United States or allied jurisdictions where practical.
- Pin external dependencies.
- Avoid committing credentials or secrets.
- Restrict unfree software through explicit exceptions.
- Run user applications with user-level privileges.
- Restrict local services to loopback interfaces by default.
- Review third-party forks and custom package overrides.

Secrets management should be implemented as a separate capability rather than embedding secrets directly in program configuration.

## 12. Development and Deployment Workflow

All commands below assume execution from the `nix/` directory.

### 12.1 Inspect changes

```sh
git status
git diff
git diff --cached
```

### 12.2 Stage configuration

New configuration files must be visible to the Git-backed flake.

```sh
git add -A .
```

### 12.3 Reconcile dependencies

When flake inputs change:

```sh
nix flake lock
```

Dependency upgrades should be performed deliberately rather than as an incidental part of configuration changes.

### 12.4 Evaluate configuration

```sh
nix eval --raw \
  '.#darwinConfigurations.macbook.system.drvPath'
```

Evaluation validates configuration composition and resolves the system derivation without activating it.

### 12.5 Build configuration

```sh
nix build \
  '.#darwinConfigurations.macbook.system' \
  -L
```

Building produces the new system generation without switching the active system.

### 12.6 Activate configuration

```sh
sudo darwin-rebuild switch \
  --flake ~/dotfiles/nix#macbook
```

### 12.7 Reload the shell

```sh
exec zsh -l
```

### 12.8 Verify runtime behavior

Verify affected applications, services, environment variables, configuration files, and system preferences.

Successful evaluation and building do not guarantee successful runtime behavior.

### 12.9 Commit changes

```sh
git add -A .
git commit -m "describe configuration change"
git push
```

## 13. Verification Strategy

Changes should pass progressively stronger verification gates.

| Gate | Objective |
|---|---|
| Structural validation | Verify manifests, directories, and references |
| Syntax validation | Verify valid Nix expressions |
| Dependency validation | Verify pinned inputs and package attributes |
| Evaluation | Verify module composition and configuration consistency |
| Build | Verify package and system derivation construction |
| Activation | Verify successful system deployment |
| Runtime verification | Verify intended operational behavior |

Failures should be isolated to the narrowest applicable architectural layer.

A missing application package should ordinarily be resolved within the program layer rather than by restructuring the entire infrastructure.

## 14. Adding a Program

1. Create a directory under `programs/`.
2. Define the program manifest in `default.nix`.
3. Implement the appropriate home or system modules.
4. Add application-specific configuration and integration.
5. Add the program to the appropriate shared or platform-specific profile.
6. Stage the new files.
7. Evaluate the configuration.
8. Build and activate the configuration.
9. Verify runtime behavior.
10. Commit the changes.

Programs should not be added directly to host manifests merely to bypass profile composition.

## 15. Adding a Profile

1. Create a shared profile under `profiles/`.
2. Declare its constituent programs.
3. Add platform-specific extensions where necessary.
4. Select the shared profile from the relevant home manifest.
5. Evaluate and verify the resulting configuration.

A shared profile may intentionally contain no programs when all currently supported implementations are platform-specific.

## 16. Adding a User

1. Create a directory under `homes/`.
2. Define the user's identity.
3. Define environment preferences and Home Manager settings.
4. Select the required capability profiles.
5. Add platform-specific preferences where necessary.
6. Declare the user in the appropriate host manifest.
7. Evaluate and verify the resulting configuration.

The user should reuse existing profiles and program implementations wherever possible.

## 17. Adding a Host

1. Create a directory under `hosts/`.
2. Define the hostname and target platform.
3. Declare the associated users.
4. Identify the primary user.
5. Declare the appropriate system state version.
6. Add host-specific modules if required.
7. Expose the host through the flake.
8. Evaluate, build, and deploy the configuration.

Adding a host for an unsupported operating system requires implementing the corresponding system infrastructure and native host composition logic.

## 18. Architectural Constraints

The current architecture intentionally accepts several constraints:

- Homebrew applications are installed machine-wide.
- Homebrew declarations do not provide the same reproducibility guarantees as pinned Nix derivations.
- Machine-wide personal preferences are applied through the primary user.
- Program manifests do not currently define a formal inter-program dependency graph.
- Runtime-managed language environments and toolchains may contain mutable state.
- Linux program implementations may exist before complete NixOS host composition is available.
- External applications may maintain state independently of declarative configuration.
- Static configuration validation cannot establish application runtime correctness.

These constraints should be addressed through incremental architectural improvements rather than unnecessary duplication or premature abstraction.

## 19. Future Development

Potential extensions include:

- Complete NixOS host composition.
- Additional physical and virtual hosts.
- Dedicated server and virtualization infrastructure.
- Additional user and agent environments.
- Declarative secrets management.
- Automated configuration validation.
- Continuous integration.
- Formal manifest schemas and validation.
- Explicit inter-program dependency management.
- Bootstrap and disaster recovery procedures.
- Persistent state and backup policies.
- Automated runtime health checks.
- Software provenance and supply chain auditing.

Future extensions should preserve the existing separation of concerns and avoid introducing platform-specific requirements into shared user configurations.

## 20. Architectural Governance

Architectural changes should be evaluated against the following questions:

- Does the change preserve existing ownership boundaries?
- Does it improve reproducibility or maintainability?
- Can the implementation be reused across users and hosts?
- Does it introduce unnecessary platform coupling?
- Does it introduce unnecessary mutable state?
- Are new dependencies justified and trustworthy?
- Can the change be independently evaluated and verified?

The architecture should evolve through deliberate, version-controlled changes.

The repository is the authoritative declaration of the intended computing environment, while its documentation defines the architectural contracts governing how that environment is constructed and maintained.