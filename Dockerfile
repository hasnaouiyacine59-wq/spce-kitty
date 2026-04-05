ARG PLAYWRIGHT_TAG=v1.44.0-jammy
ARG PLAYWRIGHT_VERSION=1.44.0
FROM mcr.microsoft.com/playwright/python:${PLAYWRIGHT_TAG}

WORKDIR /app

# Chrome version per Playwright release
# v1.44 → Chrome 124, v1.43 → 123, v1.42 → 122, v1.41 → 121, v1.40 → 120, v1.39 → 119
ARG CHROME_VERSION=124

RUN apt-get update && apt-get install -y xvfb netcat-openbsd git wget gnupg --no-install-recommends \
    && wget -q -O /tmp/chrome.deb \
       "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}.0.6367.60-1_amd64.deb" \
    && apt-get install -y /tmp/chrome.deb \
    && rm /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt start.sh ./
ARG PLAYWRIGHT_VERSION
RUN pip install -r requirements.txt playwright==${PLAYWRIGHT_VERSION} && chmod +x start.sh

ENV SOCKS_PORT=9050
ENV CONTROL_PORT=9051
ENV API_PORT=5000

CMD ["./start.sh"]
