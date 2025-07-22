# PIA WireGuard Config Generator (Docker)

A simple, production-ready Docker container for generating Private Internet Access (PIA) WireGuard configurations—perfect for Unifi, routers, or any WireGuard client.  
**Based on the pia-wg script.**  
Outputs config files straight to a mounted host directory—no permission issues, no hassle.

---

## Features

- Runs as root (no permission issues)
- Automatic output to `/output` (mountable on your host)
- Interactive (choose region & enter credentials)
- No dependencies needed on your host

---

## Dockerfile

```dockerfile
FROM python:3.12-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y git wireguard-tools && \
    rm -rf /var/lib/apt/lists/*

# Clone pia-wg repository
RUN git clone https://github.com/hsand/pia-wg.git /app

WORKDIR /app

RUN pip install --no-cache-dir -r requirements.txt

# Create a fixed output directory
RUN mkdir -p /output

USER root

# Wrapper script: after running, copy all PIA-*.conf to /output
RUN echo '#!/bin/bash\npython generate-config.py\ncp PIA-*.conf /output/ 2>/dev/null || true' > /run.sh && chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
```

---

## Installation

1. **Build the image:**
    ```bash
    docker build -t pia-wg-generator .
    ```

2. **Create an output directory on your NAS/server:**
    ```bash
    mkdir -p /mnt/system/docker-stacks/pia-wg/data
    ```

---

## Usage

Start the container:
```bash
docker run -it --rm -v /mnt/system/docker-stacks/pia-wg/data:/output pia-wg-generator
```

Follow the prompts in the container to select your region and enter your PIA login.

The `.conf` file(s) will appear directly in the output directory on your host:
```
/mnt/system/docker-stacks/pia-wg/data
```

---

## Manual Step: Add Address `/32` if Needed

> **Note:**  
> Sometimes the generated `.conf` file is missing the required `/32` CIDR in the `Address` line, or the address field is empty.  
> This is required by Unifi and many other clients.

**Check and adjust if needed:**

```ini
[Interface]
Address = 10.123.45.67/32   # <-- Manually add /32 if needed
PrivateKey = <your-private-key>
DNS = 10.0.0.243,10.0.0.242
```

**What should you do?**
- Open the `.conf` file you just generated (find it in your output directory).
- Look for the line starting with `Address =`.
- If it’s missing `/32` or the IP is empty:  
  → Enter the correct IP address (usually provided in the config), and append `/32`, as shown above.

**Example before correction:**
```ini
Address = 10.123.45.67
```
**Should become:**
```ini
Address = 10.123.45.67/32
```

**Important:** Without the `/32`, Unifi (and some other clients) will not accept the config!

---

## FAQ

**The .conf file has no valid IP address in the Address line?**  
- This is a known issue. Restart the container, try a different region, or manually enter the address (see above).

**Can I use these configs with Unifi?**  
- Yes! Once you add `/32`, the config will work with Unifi as a WireGuard client.

**Can I generate multiple configs?**  
- Simply rerun the container for each desired region.

---

## Credits

- [pia-wg](https://github.com/hsand/pia-wg) community project
- [Private Internet Access](https://www.privateinternetaccess.com/)
- Dockerfile wrapper: [Your name or github]

---

## Disclaimer

Not officially affiliated with Private Internet Access. Use at your own risk.

