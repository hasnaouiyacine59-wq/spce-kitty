#!/bin/bash
set -e

REPO_URL="https://github.com/hasnaouiyacine59-wq/dev-tech.git"
REPO_DIR="/app/dev-tech"

# Clone or pull latest code
if [ -d "$REPO_DIR/.git" ]; then
  echo "==> Pulling latest code..."
  git -C "$REPO_DIR" pull origin main
else
  echo "==> Cloning repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

# Wait for tor-proxy to be ready
echo "==> Waiting for Tor..."
until nc -z 127.0.0.1 "${SOCKS_PORT:-9050}" && nc -z 127.0.0.1 "${API_PORT:-5000}"; do
  sleep 5
done

# Run from cloned repo
mkdir -p /logs
cd "$REPO_DIR"
while true; do
  python3 -u thor_main.py -T >> /logs/sessions.log 2>&1
  sleep 5
done
