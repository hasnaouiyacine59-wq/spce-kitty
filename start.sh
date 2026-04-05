#!/bin/bash

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
while true; do
  python3 -c "import socket; socket.create_connection(('127.0.0.1', ${SOCKS_PORT:-9050}), 2)" 2>/dev/null && \
  python3 -c "import socket; socket.create_connection(('127.0.0.1', ${API_PORT:-5000}), 2)" 2>/dev/null && break
  echo "==> Waiting for Tor..."
  sleep 5
done

# Run from cloned repo — all sessions append to one shared log
mkdir -p /logs
cd "$REPO_DIR"
while true; do
  python3 -u thor_main.py -T 2>&1 | while IFS= read -r line; do
    echo "[${SOCKS_PORT}] $line" >> /logs/sessions.log
  done
  sleep 5
done
