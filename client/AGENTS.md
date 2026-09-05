# Client role

The client is a remote Linux account that consumes one manually selected server proxy. It maintains the server registry, a private Unix socket per server, an atomic active symlink, and one stable loopback TCP proxy endpoint.

## Required discovery

Before deployment, determine:

- that Linux user systemd is running;
- the installed path of `systemd-socket-proxyd`;
- the desired loopback listen host and free TCP port;
- whether older proxy environment blocks or socket units need migration.

The default is `127.0.0.1:17900`. Do not bind a public address unless the user explicitly requests it and an authentication/access-control design has been agreed.

## Deployment

From the repository root:

```sh
./deploy client --listen-host 127.0.0.1 --listen-port 17900
```

On later runs, `./deploy client` reuses `~/.config/ssh-proxy-switcher/client.env`.

Deployment installs `ssh-proxy`, generates and enables the user systemd socket/service, writes the stable proxy environment, and adds one idempotent source block to existing Bash and Zsh startup files.

## Commands and selection

- `ssh-proxy list`: registered servers and tunnel state.
- `ssh-proxy use NAME`: full HTTP CONNECT probe, then atomic selection.
- `ssh-proxy status`: current selection and tunnel state.
- `ssh-proxy test [NAME]`: explicit end-to-end CONNECT probe.
- `ssh-proxy forget NAME`: remove an inactive, offline registration.

Registration and reconnect never select a server. There is no automatic fallback. Verify the stable TCP endpoint with a real request after selecting a server.
