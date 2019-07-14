# ÖREB-Kataster-Prototyp
Vorliegendes Projekt zeigt das Zusammenspiel der im Rahmen der Einführung des ÖREB-Katasters im Kanton Solothurn entwickelten Komponenten. Es dient insbesondere dem Testen und dem Präsentieren des jeweiligen Realisierungsstandes der Komponenten und der Sicherstellung, dass das gesamte System reibungslos zusammenspielt. Es ist aber mehr als ein blosser Prototyp oder Showcase, sondern (nach allenfalls notwendigen Anpassungen an den Konfigurationen) voll produktionstauglich. Bereits bei der Konzeption des ÖREB-Katasters im Kanton Solothurn wurde darauf geachtet, dass einfaches Deployment des Gesamtsystems (sowohl Code wie auch Daten) möglich ist. D.h. möglichst ohne Einwirkungen auf die restliche GDI. Eine Ausnahme bildet der Web GIS Client, der nicht Bestandteil dieses Projektes ist.

## Komponenten
### 








Einleitung... blablablanig. 
Skizze mit Komponenten und Zusammenspiel.
Verwendete Tools/Software. QGIS-Server aber auch Full-Java-Stack (-> GeoServer, JSON, ...). Konfig teilweise eingebrannt.

## Starten des Katasters
Starten der Anwendung(en) mit `docker-compose up`. Falls nicht vorhanden, wird eine Datenbank angelegt (Pfad von `pgdata` siehe `docker-compose.yml`). Der ÖREB Web Service, Geoserver (als WMS) und Caddy (als Proxy) werden ebenfalls gestartet. Es werden _keine_ Daten importiert, d.h. die Datenbank ist gegebenenfalls leer. 

### Test-Requests
- ÖREB Web Service:
  * http://localhost/ws/versions/xml
  * http://localhost/ws/capabilities/xml
- ÖREB-Datenbank: `jdbc:postgresql://localhost:54321/oereb`
- QGIS-Server:
  * foo
  * bar
- GeoServer:
  * http://localhost/geoserver/web/
  * http://localhost/geoserver/wms?REQUEST=GetCapabilities&SERVICE=WMS


## Organisation und Entwicklung der Anwendungen (Code, Dockerimages und Konfigurationen)
Die Entwicklung der Anwendungen und/oder der Docker-Images findet in separaten Github-Repositories statt:

- ÖREB Web Service: [Code](https://github.com/claeis/oereb-web-service) / [Dockerimage](https://github.com/sogis/oereb-web-service-docker)
- ÖREB-Datenbank: [Dockerimage](https://github.com/sogis/oereb-db)
- QGIS-Server: [Dockerimage](https://github.com/sogis/xxxxxx)
- GeoServer: [Dockerimage](https://github.com/sogis/yyyyyy)

Ausnahme bildet der Proxyserver (Caddy). Das Dockerfile und die Konfigurationsdateien werden in diesem Github-Respositories gespeichert und weiterentwickelt.

Weiterführende Informationen für den Betrieb (insbesondere welche Umgebungsvariablen gesetzt werden müssen) und zu der Entwicklung finden sich in den einzelnen Repositories.

### Proxyserver (Caddy)
Als Proxyserver wird [Caddy](https://caddyserver.com/) verwendet. Während der Entwicklung des ÖREB-Katasters (also der `docker-compose.yml`-Datei) ist es zwingend notwendig die Parameter des Proxyservers überschreiben zu können (z.B. Domainname). Dies erfolgt mit einer separaten `Caddyfile.dev`-Datei und einer `docker-compose.caddy.dev.yml`-Datei. Der `docker-compose`-Befehlt lautet wie folgt:

```
docker-compose -f docker-compose.yml -f docker-compose.caddy.dev.yml up
```

## Datenimport

```
./gradlew av_import:replaceCadastralSurveyingData plz_import:dbImport bundesgesetze_import:dbImport bundesdaten_import:replaceFederalData kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData npl_import:refreshMaterializedViews
```

Der "Fullimport" der amtlichen Vermessung dauert circa 2 bis 3 Stunden. Aus diesem Grund werden nur einige Gemeinden importiert (wo ÖREB-Daten vorhanden sind).

## Deployment
### docker-compose
fubar

### Docker Swarm
fubar

## _User data_ für Digitalocean etc.
```
#cloud-config
users:
  - name: oerebuser
    shell: /bin/bash

package_upgrade: false

runcmd:
 - apt update
 - wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
 - add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
 - apt-get install --yes adoptopenjdk-8-hotspot
 - usermod -aG docker oerebuser 
 - mkdir --mode=0777 -p /home/oerebuser/oereb-pgdata
 - chown -R oerebuser:oerebuser /home/oerebuser/oereb-pgdata
 - git clone https://github.com/edigonzales/oereb-kataster-prototyp.git /home/oerebuser/oereb-kataster-prototyp
 - chown -R oerebuser:oerebuser /home/oerebuser/oereb-kataster-prototyp
```

## TODO
- Gretl-Jobs in eigenes Repo!
- Env-Variablen für DB-Credentials
- GRETL-Jobs auch in einem Dockercontainer ausführen.
- Terraform
- Docker Swarm
- Doku oereb-web-service: Beispiele für Spring-Konfiguration (Debug-Logging, context path...)