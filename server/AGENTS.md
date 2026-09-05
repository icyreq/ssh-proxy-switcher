# Server role

The server is a computer that provides a local HTTP-compatible proxy to a remote client through a persistent SSH reverse Unix-socket tunnel. The current implementation supports macOS launchd.

## Required discovery

Before deployment, determine:

- a unique server name;
- the local proxy host and TCP port, verified with a real HTTP CONNECT request;
- the SSH alias or target that reaches the already-deployed client;
- whether an older `ssh-proxy-switcher` launch agent exists.

Never read or commit proxy credentials or SSH secrets. If the proxy requires authentication, stop and extend the explicit configuration model before deploying.

## Deployment

From the repository root:

```sh
./deploy server --name NAME --target SSH_TARGET --proxy-host 127.0.0.1 --proxy-port PORT
```

On later runs, `./deploy server` reuses `~/.config/ssh-proxy-switcher/server.env`.

Deployment copies the agent and controller outside the repository, generates one launchd plist, and starts it. The agent registers the server name but never selects it. `ssh-proxy-server status` shows launchd state and the client's current selection.

## Verification

Verify the local proxy port first, then confirm the server appears online in `ssh-proxy list` on the client. Restart the launch agent and confirm the active selection is unchanged. If the same-name remote socket is stale, client registration removes it; a live same-name tunnel is never replaced.
