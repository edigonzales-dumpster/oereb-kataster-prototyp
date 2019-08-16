# ÖREB-Kataster-Prototyp
Dieses Projekt zeigt das Zusammenspiel der im Rahmen der Einführung des ÖREB-Katasters im Kanton Solothurn entwickelten Komponenten. Es dient insbesondere dem Testen und dem Präsentieren des jeweiligen Realisierungsstandes der Komponenten und der Sicherstellung, dass das gesamte System reibungslos zusammenspielt. Es ist aber mehr als ein blosser Prototyp oder Showcase, sondern (nach allenfalls notwendigen Anpassungen an den Konfigurationen) auch produktionstauglich. Bereits bei der Konzeption des ÖREB-Katasters im Kanton Solothurn wurde darauf geachtet, dass einfaches Deployment des Gesamtsystems (sowohl Code wie auch Daten) möglich ist. D.h. möglichst ohne Einwirkungen auf die restliche GDI. Eine Ausnahme bildet der ÖREB Web GIS Client, der als zusätzliches Werkzeug des bestehenden Web GIS Client entwickelt wurde und daher nicht ohne diesen in Betrieb genommen und getestet werden kann. Aus diesem Grund ist der ÖREB Web GIS Client nicht Bestandteil dieses Projektes. 

Um sowohl die einzelnen Komponenten wie auch die Prozesse und Schnittstellen möglichst einfach, schlank und transparent zu halten, wird konsequent mit INTERLIS und entsprechenden Schnittstellenwerkzeugen (ili2pg, ilivalidator, GRETL) gearbeitet. Das bedeutet z.B., dass die Daten in der Transferstruktur (des ÖREB-Rahmenmodells) ausgetauscht werden müssen und die Tabellen in der ÖREB-Datenbank mit ili2pg angelegt werden müssen ("opinionated").

## Komponenten
### ÖREB-Webservice
Webservice gemäss [Weisung V+D](https://www.cadastre.ch/content/cadastre-internet/de/manual-oereb/publication/instruction.download/cadastre-internet/de/documents/oereb-weisungen/OEREB-XML-Aufruf_de.pdf). [Code](https://github.com/claeis/oereb-web-service) und [Dockerimage](https://github.com/sogis/oereb-web-service-docker) werden in getrennten Github-Repositories entwickelt. 

### ÖREB-Datenbank
Datenbank zur Speicherung der ÖREB-Daten und weiterer notwendiger Daten. Dazu gehört er amtlichen Vermessung und den PLZ/Ortschaften ein sogenanntes Annex-Modell. Das Annex-Modell beinhaltet Informationen, die für den statischen Auszug notwendig sind (Gemeindelogos, Informationen über vorhandene Daten, ...). Dockerfile und Shellskripts zur Generierung der DDL-Befehle etc. werden in einem [Github-Repository](https://github.com/sogis/oereb-db) gepflegt.

Siehe insbesondere das Setzen der korrekten Permissions des Datenverzeichnisses.

### QGIS-Server
Dient als WMS-Server für die ÖREB-Daten. Bedient sich von Views (oder materialisierten Views) aus der ÖREB-Datenbank. Dockerfile und Konfigurationsdateien (QGS-, QML-Dateien) sind [hier](https://github.com/sogis/oereb-wms) zu finden.

### Proxyserver (Caddy)
Keine offizielle Komponente des ÖREB-Katasters des Kanton Solothurn. 

Als Proxyserver wird [Caddy](https://caddyserver.com/) verwendet. Während der Entwicklung des ÖREB-Katasters (also der `docker-compose.yml`-Datei) ist es zwingend notwendig die Parameter des Proxyservers überschreiben zu können (z.B. Domainname). Dies erfolgt mit einer separaten `Caddyfile.dev`-Datei und einer `docker-compose.caddy.dev.yml`-Datei. Der `docker-compose`-Befehl lautet wie folgt:

```
docker-compose -f docker-compose.yml -f docker-compose.caddy.dev.yml up
```

## Starten des Katasters
Starten der Anwendung(en) mit `docker-compose up`. Falls nicht vorhanden, wird eine Datenbank angelegt (Pfad von `pgdata` siehe `docker-compose.yml`). Der ÖREB Web Service, QGIS Server (als WMS) und Caddy (als Proxy) werden ebenfalls gestartet. Es werden _keine_ Daten importiert, d.h. die Datenbank ist gegebenenfalls leer. 

Test-Requests:
- http://localhost:8181/ws/capabilities/xml
- http://localhost:8181/ws/versions/xml

- http://localhost:8181/ws/getegrid/xml/?XY=2634186,1248332 
- http://localhost:8181/ws/getegrid/xml/?XY=2600645,1215449 
- http://localhost:8181/ws/extract/reduced/xml/geometry/CH368132060914
- http://localhost:8181/ws/extract/reduced/xml/geometry/CH310601327458
- http://localhost:8181/ws/extract/reduced/xml/geometry/CH789332067505

* CH368132060914 (Wisen)  
* CH310601327458 (Messen) 2600645 1215449

## Datenimport

```
./gradlew av_import:replaceCadastralSurveyingData plz_import:dbImport gb_kreise_import:dbImport bundescodeliste_import:dbImport bundesgesetze_import:dbImport bundesdaten_import:replaceFederalData kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData annex_import:replaceAnnexData npl_import:refreshMaterializedViews
```

tmp:
```
./gradlew bundesgesetze_import:dbImport kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData npl_import:refreshMaterializedViews
```

Der "Fullimport" der amtlichen Vermessung dauert circa 2 bis 3 Stunden. Aus diesem Grund werden nur einige Gemeinden importiert (wo ÖREB-Daten vorhanden sind).

## Deployment
TODO


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
 #- docker swarm init --advertise-addr 67.207.73.98
 #- curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
 #- docker stack deploy --compose-file=portainer-agent-stack.yml portainer 
```

## TODO
- Gretl-Jobs in eigenes Repo!
- Env-Variablen für DB-Credentials
- GRETL-Jobs auch in einem Dockercontainer ausführen.
- Doku oereb-web-service: Beispiele für Spring-Konfiguration (Debug-Logging, context path...)