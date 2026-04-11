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
echo "==> Waiting for Tor and API..."
while true; do
  SOCKS_OK=$(curl -s --socks5 127.0.0.1:${SOCKS_PORT:-9050} --max-time 5 https://check.torproject.org/api/ip 2>/dev/null | grep -c '"IsTor":true')
  API_OK=$(curl -s --max-time 3 http://127.0.0.1:${API_PORT:-5000}/health 2>/dev/null | grep -c 'ok\|healthy\|true' || curl -s --max-time 3 -o /dev/null -w "%{http_code}" http://127.0.0.1:${API_PORT:-5000}/ | grep -c '^[23]')
  [ "$SOCKS_OK" -ge 1 ] && [ "$API_OK" -ge 1 ] && break
  echo "==> Waiting... SOCKS:${SOCKS_OK} API:${API_OK}"
  sleep 5
done
echo "==> Tor and API are ready!"

# Run from cloned repo — all sessions append to one shared log
mkdir -p /logs
cd "$REPO_DIR"
while true; do
  python3 -u thor_main.py -T 2>&1 | while IFS= read -r line; do
    echo "[${SOCKS_PORT}] $line" >> /logs/sessions.log
  done
  sleep 5
done
