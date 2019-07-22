# ÖREB-Kataster-Prototyp
Dieses Projekt zeigt das Zusammenspiel der im Rahmen der Einführung des ÖREB-Katasters im Kanton Solothurn entwickelten Komponenten. Es dient insbesondere dem Testen und dem Präsentieren des jeweiligen Realisierungsstandes der Komponenten und der Sicherstellung, dass das gesamte System reibungslos zusammenspielt. Es ist aber mehr als ein blosser Prototyp oder Showcase, sondern (nach allenfalls notwendigen Anpassungen an den Konfigurationen) auch produktionstauglich. Bereits bei der Konzeption des ÖREB-Katasters im Kanton Solothurn wurde darauf geachtet, dass einfaches Deployment des Gesamtsystems (sowohl Code wie auch Daten) möglich ist. D.h. möglichst ohne Einwirkungen auf die restliche GDI. Eine Ausnahme bildet das Web GIS Client Werkzeug, das nicht Bestandteil dieses Projektes ist, sondern im bestehenden Web GIS Client integriert wird. Der ÖREB-Kataster wird konzeptionell als Anwendung betrachtet und weniger als Sammelsurium von Komponenten, die in die bestehende GDI gezwängt werden.

Um sowohl die einzelnen Komponenten wie auch die Prozesse und Schnittstellen möglichst einfach, schlank und transparent zu halten, wird konsequent mit INTERLIS und entsprechenden Schnittstellenwerkzeugen (ili2pg, ilivalidator) gearbeitet. Das bedeutet z.B., dass die Daten in der Transferstruktur (des ÖREB-Rahmenmodells) ausgetauscht werden müssen und die Tabellen in der ÖREB-Datenbank mit ili2pg angelegt werden müssen ("opinionated").

## Komponenten
### ÖREB-Webservice
Webservice gemäss [Weisung V+D](https://www.cadastre.ch/content/cadastre-internet/de/manual-oereb/publication/instruction.download/cadastre-internet/de/documents/oereb-weisungen/OEREB-XML-Aufruf_de.pdf). [Code](https://github.com/claeis/oereb-web-service) und [Dockerimage](https://github.com/sogis/oereb-web-service-docker) werden in getrennten Github-Repositories entwickelt. 

### ÖREB-Datenbank
Datenbank zur Speicherung der ÖREB-Daten und weiterer notwendiger Daten. Dazu gehört er amtlichen Vermessung und den PLZ/Ortschaften ein sogenanntes Annex-Modell. Das Annex-Modell beinhaltet Informationen, die für den statischen Auszug notwendig sind (Gemeindelogos, Informationen über vorhandene Daten, ...). Dockerfile und Shellskripts zur Generierung der DDL-Befehle etc. werden in einem [Github-Repository](https://github.com/sogis/oereb-db) gepflegt.

### QGIS-Server
Dient als WMS-Server für die ÖREB-Daten. Bedient sich von Views (oder materialisierten Views) aus der ÖREB-Datenbank. Dockerfile und Konfigurationsdateien (QGS-, QML-Dateien) sind [hier](https://github.com/sogis/XXXX) zu finden.

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
Als Proxyserver wird [Caddy](https://caddyserver.com/) verwendet. Während der Entwicklung des ÖREB-Katasters (also der `docker-compose.yml`-Datei) ist es zwingend notwendig die Parameter des Proxyservers überschreiben zu können (z.B. Domainname). Dies erfolgt mit einer separaten `Caddyfile.dev`-Datei und einer `docker-compose.caddy.dev.yml`-Datei. Der `docker-compose`-Befehl lautet wie folgt:

```
docker-compose -f docker-compose.yml -f docker-compose.caddy.dev.yml up
```

## Datenimport

```
./gradlew av_import:replaceCadastralSurveyingData plz_import:dbImport bundesgesetze_import:dbImport bundesdaten_import:replaceFederalData kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData (npl_import:refreshMaterializedViews)
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
 - mkdir --mode=0777 -p /private/oereb_db_prod
 #- chown -R oerebuser:oerebuser /private/oereb_db_prod
 - mkdir -p /private/caddy_prod
 - curl -L https://raw.githubusercontent.com/edigonzales/oereb-kataster-prototyp/master/caddy/Caddyfile -o /private/caddy_prod/Caddyfile
 - git clone https://github.com/edigonzales/oereb-kataster-prototyp.git /home/oerebuser/oereb-kataster-prototyp
 - chown -R oerebuser:oerebuser /home/oerebuser/oereb-kataster-prototyp
 #- docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')
 - docker swarm init --advertise-addr 67.207.73.98
 - curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
 - docker stack deploy --compose-file=portainer-agent-stack.yml portainer 
```

## TODO
- Gretl-Jobs in eigenes Repo!
- Env-Variablen für DB-Credentials
- GRETL-Jobs auch in einem Dockercontainer ausführen.
- Terraform
- Docker Swarm
- Doku oereb-web-service: Beispiele für Spring-Konfiguration (Debug-Logging, context path...)