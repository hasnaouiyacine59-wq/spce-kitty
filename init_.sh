#!/bin/bash

set -e

# Wipe all Docker containers and images
echo "Wiping all Docker containers and images..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm -f $(docker ps -aq) 2>/dev/null || true
docker rmi  $(docker images -q) --force   2>/dev/null || true

# Pull images from quay.io
echo "Pulling images from quay.io..."
docker pull quay.io/mylastres0rt05/tor-proxy:latest
docker pull quay.io/mylastres0rt05/thor-session:v1.44
docker pull quay.io/mylastres0rt05/thor-session:v1.43
docker pull quay.io/mylastres0rt05/thor-session:v1.42
docker pull quay.io/mylastres0rt05/thor-session:v1.41
docker pull quay.io/mylastres0rt05/thor-session:v1.40

# Tag for local use
docker tag quay.io/mylastres0rt05/tor-proxy:latest tor-proxy
docker tag quay.io/mylastres0rt05/thor-session:v1.44 thor-session:v1.44
docker tag quay.io/mylastres0rt05/thor-session:v1.43 thor-session:v1.43
docker tag quay.io/mylastres0rt05/thor-session:v1.42 thor-session:v1.42
docker tag quay.io/mylastres0rt05/thor-session:v1.41 thor-session:v1.41
docker tag quay.io/mylastres0rt05/thor-session:v1.40 thor-session:v1.40

# Create shared log file
mkdir -p ~/thor-logs && touch ~/thor-logs/sessions.log

# Deploy 5 tor-proxy containers
echo "Starting tor-proxy containers..."
docker run -d --name tor-9050 -e SOCKS_PORT=9050 -e CONTROL_PORT=9051 -e API_PORT=5000 -p 9050:9050 -p 5000:5000 tor-proxy
docker run -d --name tor-9052 -e SOCKS_PORT=9052 -e CONTROL_PORT=9053 -e API_PORT=5001 -p 9052:9052 -p 5001:5001 tor-proxy
docker run -d --name tor-9054 -e SOCKS_PORT=9054 -e CONTROL_PORT=9055 -e API_PORT=5002 -p 9054:9054 -p 5002:5002 tor-proxy
docker run -d --name tor-9056 -e SOCKS_PORT=9056 -e CONTROL_PORT=9057 -e API_PORT=5003 -p 9056:9056 -p 5003:5003 tor-proxy
docker run -d --name tor-9058 -e SOCKS_PORT=9058 -e CONTROL_PORT=9059 -e API_PORT=5004 -p 9058:9058 -p 5004:5004 tor-proxy

# Deploy 5 thor-session containers
echo "Starting thor-session containers..."
docker run -d --name session-9050 -e SOCKS_PORT=9050 -e API_PORT=5000 --network host -v ~/thor-logs:/logs thor-session:v1.44
docker run -d --name session-9052 -e SOCKS_PORT=9052 -e API_PORT=5001 --network host -v ~/thor-logs:/logs thor-session:v1.43
docker run -d --name session-9054 -e SOCKS_PORT=9054 -e API_PORT=5002 --network host -v ~/thor-logs:/logs thor-session:v1.42
docker run -d --name session-9056 -e SOCKS_PORT=9056 -e API_PORT=5003 --network host -v ~/thor-logs:/logs thor-session:v1.41
docker run -d --name session-9058 -e SOCKS_PORT=9058 -e API_PORT=5004 --network host -v ~/thor-logs:/logs thor-session:v1.40

echo "All containers running. Tailing logs..."
tail -f ~/thor-logs/sessions.log
