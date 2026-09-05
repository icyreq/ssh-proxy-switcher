# AGENTS.md

## Mission

`ssh-proxy-switcher` lets one remote Unix account consume a manually selected proxy supplied by any number of computers over SSH reverse tunnels. This repository is the complete, portable source for both roles.

The user calls the roles:

- **server**: a local computer that provides its local HTTP-compatible proxy.
- **client**: a remote computer that consumes a selected server, such as a GPU server.

These names describe the proxy relationship, not the direction of the SSH connection. Internally, `provider` means server and `consumer` means client.

Before changing code or deployment state, explain the intended change and confirm alignment with the user. Never introduce automatic selection, fallback, timing guesses, source-IP detection, or other heuristics.

## Instructions for a fresh AI

When the user says this machine is a server or client:

1. Read this file and the matching role's `AGENTS.md` completely.
2. Inspect the operating system, existing proxy listener or desired client port, SSH alias, and existing services before changing anything.
3. Ask only for values that cannot be discovered safely. Never read or display credentials merely to discover configuration.
4. Run `./deploy server ...` or `./deploy client ...` with the discovered values.
5. Complete service installation, startup, role-specific verification, reconnect verification, and a real proxy CONNECT test.
6. Report success only when the service is active and the end-to-end test passes.

Do not commit or retain hostnames, IP addresses, usernames, SSH keys, proxy credentials, tokens, provider identities, generated service files, logs, sockets, or runtime state. Machine configuration belongs under the user's standard config directory and is intentionally outside Git.

## Repository contract

- `deploy`: stable role dispatcher used after cloning.
- `server/`: complete proxy-server implementation. Currently supports macOS with launchd.
- `client/`: complete proxy-client implementation. Currently supports Linux with user systemd and `systemd-socket-proxyd`.
- `docs/ARCHITECTURE.md`: protocol, data plane, control plane, and invariants.
- `docs/TESTING.md`: required static and integration verification.
- `tests/static.sh`: repository-level syntax and structure checks.
- `GO`: extremely short human command sheet. Do not add explanations or architecture to it.

Unsupported operating systems must be reported clearly. Do not pretend a deployment succeeded and do not silently substitute a different architecture.

## System invariants

- Every server has a unique human-selected name matching `[A-Za-z0-9][A-Za-z0-9._-]{0,47}`.
- Each server owns a private Unix socket on the client. No fixed port allocation or port competition is used for provider tunnels.
- Any number of servers may remain online simultaneously.
- Only `ssh-proxy use NAME` changes the active server.
- Registration, reconnect, wake, service restart, age, latency, and health status never change selection.
- Selection is an atomic symlink replacement. New connections use the new server; existing connections drain through the old one.
- There is no automatic fallback. If the selected server is unavailable, the client fails visibly until it returns or the user selects another.
- Registration may delete only an unreachable stale Unix socket for the same server name. It never replaces a live same-name socket.
- The client TCP proxy endpoint binds only to loopback by default.

## Portability model

The repository may be cloned anywhere. `deploy` copies executable runtime files into standard per-user locations and generates machine-specific configuration outside the repository:

- Configuration: `~/.config/ssh-proxy-switcher/`
- Executables: `~/.local/bin/` and `~/.local/libexec/ssh-proxy-switcher/`
- Client state: `~/.local/state/ssh-proxy-switcher/`
- macOS logs: `~/Library/Logs/ssh-proxy-switcher/`
- macOS launch agent: `~/Library/LaunchAgents/io.ssh-proxy-switcher.server.plist`
- Linux user units: `~/.config/systemd/user/ssh-proxy-switcher.{socket,service}`

Rerun `deploy` after pulling source updates. Installers are idempotent and preserve an existing machine configuration unless explicit options replace it.

## Current protocol

The server asks the client CLI to register its name. Registration returns the absolute provider socket path. The server then runs a dedicated `ssh -NT -R remote_socket:local_proxy_host:local_proxy_port` process with SSH keepalives. The client has a stable loopback TCP socket forwarded by `systemd-socket-proxyd` to `active.sock`. See `docs/ARCHITECTURE.md` before changing this protocol.
