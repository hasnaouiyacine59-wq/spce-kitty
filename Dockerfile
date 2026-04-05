ARG PLAYWRIGHT_TAG=v1.44.0-jammy
ARG PLAYWRIGHT_VERSION=1.44.0
FROM mcr.microsoft.com/playwright/python:${PLAYWRIGHT_TAG}

WORKDIR /app

RUN apt-get update && apt-get install -y xvfb netcat-openbsd git wget gnupg --no-install-recommends \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
       > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt start.sh ./
ARG PLAYWRIGHT_VERSION
RUN pip install -r requirements.txt playwright==${PLAYWRIGHT_VERSION} && chmod +x start.sh

ENV SOCKS_PORT=9050
ENV CONTROL_PORT=9051
ENV API_PORT=5000

CMD ["./start.sh"]
