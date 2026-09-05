# Architecture

This document is for maintainers and AI agents. Human-facing commands belong only in the root `GO` file.

## Roles

A server owns a local HTTP-compatible proxy and opens an outbound SSH connection to a client. A client receives multiple reverse-forwarded Unix sockets, manually selects one, and exposes one stable loopback TCP proxy endpoint to applications.

## Data plane

Each server registers a unique name with `ssh-proxy register NAME`. The client returns an absolute Unix socket path. The server forwards that socket to its local proxy using OpenSSH remote forwarding. Socket permissions and parent directories are private to the client Unix account.

The client user-systemd socket listens on a configurable loopback TCP endpoint. `systemd-socket-proxyd` connects each accepted TCP connection through `run/active.sock`. That stable path is a symbolic link to one provider socket.

## Control plane

`ssh-proxy use NAME` first sends a real HTTP CONNECT request through the named Unix socket. Only a successful response permits selection. Selection creates a temporary relative symlink and atomically replaces `active.sock` with `os.replace`.

The kernel resolves the active symlink for each new Unix-socket connection. Existing connections already hold their original sockets and therefore drain without interruption.

Registration updates metadata and may remove an unreachable stale socket of the same name. A live same-name socket is left untouched, causing a duplicate tunnel to fail instead of stealing identity.

## Failure semantics

There is no election and no fallback. Server availability and active selection are independent state. Reconnect restores availability only. If the active server disappears, new proxy connections fail. If it reconnects under the same name, the selected route becomes usable again. Selecting another server is always a deliberate human command.

## Security boundary

All provider and selector sockets are mode-protected inside the client's home state directory. The application-facing TCP endpoint is loopback-only. On a multi-user client, other local users may still reach a loopback TCP port; deployments requiring per-UID isolation need an explicitly designed OS access-control layer and must not broaden the bind address as a workaround.
