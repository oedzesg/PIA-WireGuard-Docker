# PIA WireGuard Config Generator (Docker)

Een simpele, productieklare Dockercontainer voor het genereren van Private Internet Access (PIA) WireGuard configuraties – ideaal voor Unifi, routers, of elke andere WireGuard-client.  
**Gebaseerd op het pia-wg script.**  
Automatische output naar een gemounte map, géén permissieproblemen, géén poespas.

---

## Features

- Draait als root, altijd schrijfrechten
- Automatische output naar `/output` (mount op je host)
- Interactief (regio & login invullen)
- Géén afhankelijkheden nodig op je host

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

# Maak een vaste output map aan
RUN mkdir -p /output

USER root

# Wrapper-script: kopieer na afloop alle PIA-*.conf naar /output
RUN echo '#!/bin/bash\npython generate-config.py\ncp PIA-*.conf /output/ 2>/dev/null || true' > /run.sh && chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
```

---

## Installatie

1. **Build de image:**
    ```bash
    docker build -t pia-wg-generator .
    ```

2. **Maak een outputmap aan op je NAS/server:**
    ```bash
    mkdir -p /mnt/system/docker-stacks/pia-wg/data
    ```

---

## Gebruik

Start de container:
```bash
docker run -it --rm -v /mnt/system/docker-stacks/pia-wg/data:/output pia-wg-generator
```

Volg de instructies in de container om je gewenste regio en PIA-inlog in te voeren.

De `.conf` file(s) verschijnen daarna direct in de outputmap op je host:
```
/mnt/system/docker-stacks/pia-wg/data
```

---

## Handmatige stap: Address `/32` toevoegen

> **Let op:**  
> Soms ontbreekt in het gegenereerde `.conf` bestand het benodigde `/32` CIDR in de `Address`-regel, of het adresveld is leeg.  
> Dit is vereist voor o.a. Unifi.

**Controleer en pas zo nodig aan:**

```ini
[Interface]
Address = 10.123.45.67/32   # <-- Voeg handmatig /32 toe indien nodig
PrivateKey = <jouw-private-key>
DNS = 10.0.0.243,10.0.0.242
```

**Wat moet je doen?**
- Open het `.conf` bestand dat je net hebt gegenereerd (te vinden in je output-map).
- Zoek de regel die begint met `Address =`.
- Heeft deze géén `/32` of is het IP leeg?  
  → Vul het juiste IP-adres in (meestal staat deze in de config), en zet er `/32` achter, zoals hierboven.

**Voorbeeld vóór correctie:**
```ini
Address = 10.123.45.67
```
**Moet worden:**
```ini
Address = 10.123.45.67/32
```

**Let op:** Zonder het `/32` accepteert Unifi (en sommige andere clients) het bestand niet!

---

## Veelgestelde vragen

**Het .conf bestand heeft geen geldig IP-adres in Address?**  
- Dit is een bekend probleem. Herstart de container, probeer een andere regio, of vul het adres handmatig aan (zie hierboven).

**Kan ik deze configs met Unifi gebruiken?**  
- Ja, na het toevoegen van `/32` werkt de config direct met Unifi als WireGuard-client.

**Kan ik meerdere configs genereren?**  
- Start de container opnieuw voor elke gewenste regio.

---

## Credits

- [pia-wg](https://github.com/hsand/pia-wg) community project
- [Private Internet Access](https://www.privateinternetaccess.com/)
- Dockerfile wrapper: [Jouw naam/github]

---

## Disclaimer

Niet officieel gelieerd aan Private Internet Access. Gebruik op eigen risico.




