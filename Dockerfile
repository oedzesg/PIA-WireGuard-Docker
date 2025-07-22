FROM python:3.12-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y git wireguard-tools && \
    rm -rf /var/lib/apt/lists/*

# Clone pia-wg repository
RUN git clone https://github.com/hsand/pia-wg.git /app

WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

# Maak een vaste output map aan
RUN mkdir -p /output

USER root

# Wrapper-script: kopieer na afloop alle PIA-*.conf naar /output
RUN echo '#!/bin/bash\npython generate-config.py\ncp PIA-*.conf /output/ 2>/dev/null || true' > /run.sh && chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
