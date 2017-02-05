# about
## Overview

Root-Server auf vielen Maschinen bereitstellen und diese mit überschaubarem Aufwand verwalten.

## Motivation

- nicht jeder kann Server mitschleppen
  * es gibt Leute eventuell benutzen wollen
  * wir hatten Hardware da, die wir eigentlich gar nicht benutzt habe
  - weniger Nutzen für Teilnehmer
  - Congress-Netzwerk wird weniger gut ausgenutzt (USE MOAR BANDWIDTH!!1)
- Colocation ist nichts für Frickelkram (Schuhkartonbild, better-cases ...)
- Spaß am Gerät
  * Dinge ausprobieren, die man zu Hause nicht ausprobieren kann
    * Anzahl der Maschinen (wie setzt zu Hause man >10 Maschinen realistisch unter Last?)
    * breite Netzwerkanbindung bringt ganz eigene Probleme mit sich
- sich selbst verbessern, Dinge richtig gut machen, weil es geht
- Feedback / Leute treffen

## History

### 31c3

Erste Instanz. VirtualBox auf Hardware, die wir so rumliegen hatten.

Probleme:
- Ein riesiger Haufen USB-Festplatten hinter unserem Rack!
  * Es ist unmöglich Festplatten abzunehmen, ohne die anderen Festplatten, die alle in Betrieb sind, zur Seite zur legen.
  * Leute, die selbstständig ihre Platten abholen wollen, ziehen die falschen Platten ab. Die sind natürlich vorher nicht ge-unmounted.
- Zuordnung von USB-Festplatten an die Maschinen geht nicht gut automatisch. Zumindest einmal muss man jede Platte per Hand zuordnen.

### 32c3

- Upgrade: Schrank mit einzeln abschließbaren Fächern.
- KVM statt virtualbox.
- virt-manager als grafische Oberfläche, aber haupsächlich selbstgebaut Skripte zum konfigurieren/zurücksetzen der virtuellen Maschinen.

Alles deutlich ordentlicher. Jeder kann nur an seine eigenen Geräte, dafür aber jederzeit und ohne Stress.
Zuordnung von USB-Geräten an die Maschinen muss immer noch per Hand erfolgen.

Während des 32c3 leiht sich jemand von uns Tastatur und Bildschirm um einen kleinen schwarzen Nettop neu zu flashen.
Auf Nachfrage erfahren wir, dass jemand von Hackerspace aus Warschau ("der Pole mit der Papstmütze") eine ganze Palette mit den Geräten dabeihat und diese für handliches Geld verkauft.
Wir kaufen alle Geräte, die noch da sind; 10 Stück.

### 33c3

Aufgrund des hohen Betreuungsaufwands bieten wir keine virtuellen Maschinen mehr an.
Dafür haben wir die 10 Nettops an die Rückwand des Schranks geschraubt umd haben entsprechend 10 dedizierte Maschinen im Angebot.
Zum Image-verteilen, Zurücksetzen und Einrichten haben wir in der 33c3-Vorbereitungsphase die erste Version dieser Skriptsammlung gebaut.

Keine statischen IPs, aber DHCP/DNS hat so gut funktioniert, dass das eigentlich egal war.

Probleme / Beobachtungen:
- PXE-Boot geht nur im VLAN wegen DHCP-Gedöns
- PXE-Boot und VLAN erfordert getimetes Aus- und Anschalten. Sehr nervig.
- Image schreiben dauert ca. 8 Minuten. Zu lange.
- Zugangsdaten sind nur auf dem Controlserver verfügbar (im VLAN).
- komplizierte Passwörter
- kein wirklicher Überblick darüber, welche Maschine läuft
- sehr viel Kabelkrams, Kabelbinder ftw
- Probleme mit Netzteilmod (Polarität der Kabel unterschiedlich, Kurzschluss)
- Strom anschließen (Gesamtleistungsaufnahme, Sicherung, 32A-Stecker)

## Current Setup

### Hardware

#### With Chips

- 10 x Nettop (Intel Atom, 2 GB RAM, 16 GB Flash-SSD, USB, GBit-Ethernet)
- 10 x Lenovo ThinkCentre (Core 2 Duo, 2 GB RAM, 80 GB HDD, GBit-Ethernet)

#### Network

- 2 x Managed-Switch, 2x SFP+ 10 Gbit Uplink, 24 x 1Gbit Ethernet Port

#### Without Chips

- 1x 10-Fächer Schrank, einzeln abschließbar (Schlüssel ist dabei), mit je 1x USB2 an Nettops, 1x Schuko-Strom
- 1x 30-Fächer Schrank, einzeln abschließbar (Schlüssel ist dabei), davon 10 Fächer ausgebaut mit USB3 an ThickCentre

### Software

#### Deployment

#### Node System

#### Ctrl Server

 - NFS
 - PXE
 - DHCP
 

### Links
[we at 33C3](https://events.ccc.de/congress/2016/wiki/Assembly:Department_of_Hosting_Service)
