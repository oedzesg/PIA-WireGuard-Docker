# PIA WireGuard Config Generator (Docker)

Eenvoudige Docker-container voor het genereren van Private Internet Access (PIA) WireGuard configuraties op elk platform. De output wordt direct in een gemounte map geplaatst. Ideaal voor gebruik met Unifi, routers, of andere clients!

---

## Features

- Draait als root, geen permissieproblemen
- Automatische output naar `/output` (hostmap)
- Interactief: alleen PIA inlog nodig
- Géén installatie van dependencies op je host vereist

---

## Installatie

1. **Clone deze repo en bouw de Docker-image, of download en plaats deze in de gewenste map::**
    ```bash
    git clone https://github.com/oedzesg/pia-wg-docker.git
    cd pia-wg-docker
    docker build -t pia-wg-generator .
    ```

2. **Maak een outputmap op je NAS/server:**
    ```bash
    mkdir -p /mnt/system/docker-stacks/pia-wg/data
    ```

---

## Gebruik

Start de container:
```bash
docker run -it --rm -v /mnt/system/docker-stacks/pia-wg/data:/output pia-wg-generator


