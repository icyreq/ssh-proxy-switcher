# Testing contract

Run `tests/static.sh` before deployment. A complete integration test must verify:

1. The local server proxy accepts TCP and an HTTP CONNECT request.
2. Server deployment creates a running launchd agent.
3. Client deployment creates an active user-systemd socket.
4. Registration shows the server online without selecting it.
5. Explicit selection passes its CONNECT probe and changes the active symlink.
6. The fixed client proxy endpoint reaches an external HTTPS target.
7. Restarting an active or inactive server tunnel does not alter selection.
8. A stale same-name socket is removed on registration; a live duplicate is rejected.
9. With multiple servers online, only `ssh-proxy use NAME` changes the active server.
10. No machine configuration, runtime state, logs, secrets, or generated units appear in Git.
