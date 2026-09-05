#!/usr/bin/env bash
set -euo pipefail

project_dir=$(cd -- "$(dirname -- "$0")/.." && pwd)
bash -n "$project_dir/deploy" "$project_dir/server/macos/install" "$project_dir/client/linux-systemd/install"
zsh -n "$project_dir/server/macos/bin/tunnel-agent" "$project_dir/server/macos/bin/serverctl"
python3 -m py_compile "$project_dir/client/linux-systemd/bin/ssh-proxy"
python3 -c 'import plistlib, sys; plistlib.load(open(sys.argv[1], "rb"))' "$project_dir/server/macos/launchd/server.plist.template"
test $(wc -l < "$project_dir/GO") -le 6
test ! -e "$project_dir/README.md"
