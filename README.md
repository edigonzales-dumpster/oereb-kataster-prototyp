# ÖREB-Kataster-Prototyp
Dieses Projekt zeigt das Zusammenspiel der im Rahmen der Einführung des ÖREB-Katasters im Kanton Solothurn entwickelten Komponenten. Es dient insbesondere dem Testen und dem Präsentieren des jeweiligen Realisierungsstandes der Komponenten und der Sicherstellung, dass das gesamte System reibungslos zusammenspielt. Es ist aber mehr als ein blosser Prototyp oder Showcase, sondern es ist (nach allenfalls notwendigen Anpassungen an den Konfigurationen) auch produktionstauglich. Bereits bei der Konzeption des ÖREB-Katasters im Kanton Solothurn wurde darauf geachtet, dass einfaches Deployment des Gesamtsystems (sowohl Code wie auch Daten) möglich ist. D.h. möglichst ohne Einwirkungen auf die restliche GDI. Eine Ausnahme bildet der ÖREB Web GIS Client, der als zusätzliches Werkzeug des bestehenden Web GIS Client entwickelt wurde und daher nicht ohne diesen in Betrieb genommen und getestet werden kann. Aus diesem Grund ist der ÖREB Web GIS Client nicht Bestandteil dieses Projektes. 

Um sowohl die einzelnen Komponenten wie auch die Prozesse und Schnittstellen möglichst einfach, schlank und transparent zu halten, wird konsequent mit INTERLIS und entsprechenden Schnittstellenwerkzeugen (ili2pg, ilivalidator, GRETL) gearbeitet. Das bedeutet z.B., dass die Daten in der Transferstruktur (des ÖREB-Rahmenmodells) ausgetauscht werden müssen und die Tabellen in der ÖREB-Datenbank mit ili2pg angelegt werden müssen ("opinionated").

## Komponenten
### ÖREB-Webservice
Webservice gemäss [Weisung V+D](https://www.cadastre.ch/content/cadastre-internet/de/manual-oereb/publication/instruction.download/cadastre-internet/de/documents/oereb-weisungen/OEREB-XML-Aufruf_de.pdf). [Code](https://github.com/claeis/oereb-web-service) und [Dockerimage](https://github.com/sogis/oereb-web-service-docker) werden in getrennten Github-Repositories entwickelt. 

### ÖREB-Datenbank
Datenbank zur Speicherung der ÖREB-Daten und weiterer notwendiger Daten. Dazu gehört er amtlichen Vermessung und den PLZ/Ortschaften ein sogenanntes Annex-Modell. Das Annex-Modell beinhaltet Informationen, die für den statischen Auszug notwendig sind (Gemeindelogos, Informationen über vorhandene Daten, ...). Dockerfile und Shellskripts zur Generierung der DDL-Befehle etc. werden in einem [Github-Repository](https://github.com/sogis/oereb-db) gepflegt.

Um das Testen noch einfacher zu machen, wurde auf Basis des `oereb-db`-Images ein weiteres [Datenbankimage](https://cloud.docker.com/u/sogis/repository/docker/sogis/oereb-db-data) erstellt, das bereits sämtliche Daten im Image selber beinhaltet, d.h. es müssen keine Importe gemacht werden.

### QGIS-Server
Dient als WMS-Server für die ÖREB-Daten. Bedient sich von Views (oder materialisierten Views) aus der ÖREB-Datenbank. Dockerfile und Konfigurationsdateien (QGS-, QML-Dateien) sind [hier](https://github.com/sogis/oereb-wms) zu finden.

### ÖREB-Client
Standalone ÖREB-Web-Client: [https://github.com/edigonzales/oereb-client-gwt](https://github.com/edigonzales/oereb-client-gwt). 

### Proxyserver (Caddy)
Proxyserver.

## Development
Während der Entwicklung des ÖREB-Katasters ist es zwingend notwendig die Parameter verschiedener Komponenten überschreiben zu können (z.B. Domainname, URL von Services). Dies erfolgt mit einer separaten `docker-compose.dev.yml`-Datei. Der `docker-compose`-Befehl lautet wie folgt:

```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
docker-compose -f docker-compose.yml -f docker-compose.dev.yml stop
```

## Testrequests FIXME

Test-Requests:
- http://localhost:8181/capabilities/xml
- http://localhost:8181/versions/xml

- http://localhost:8181/getegrid/xml/?XY=2634186,1248332 
- http://localhost:8181/getegrid/xml/?XY=2600645,1215449 
- http://localhost:8181/extract/reduced/xml/geometry/CH368132060914
- http://localhost:8181/extract/reduced/xml/geometry/CH310601327458
- http://localhost:8181/extract/reduced/xml/geometry/CH789332067505

* CH368132060914 (Wisen)  
* CH310601327458 (Messen) 2600645 1215449
* CH540632893416 (Wisen)

- http://localhost/ws/extract/reduced/xml/geometry/CH540632893416

- http://localhost:8083/wms/oereb?SERVICE=WMS&REQUEST=GetStyles&LAYERS=ch.SO.NutzungsplanungGrundnutzung
- http://localhost:8083/wms/oereb?SERVICE=WMS&REQUEST=GetCapabilities


## _User data_ für Digitalocean etc. FIXME
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
 #- docker swarm init --advertise-addr 67.207.73.98
 #- curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
 #- docker stack deploy --compose-file=portainer-agent-stack.yml portainer 
```
