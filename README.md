# oereb-kataster-prototyp

## OEREB-Kataster
Starten der Anwendung(en) mit `docker-compose`:

```
docker-compose up
```
Falls nicht vorhanden, wird eine Datenbank angelegt (Pfad von `pgdata` siehe `docker-compose.yml`). Der oereb-web-service, Geoserver (als WMS) und Caddy (als Proxy) werden ebenfalls gestartet. Es werden _keine_ Daten importiert, d.h. die Datenbank ist gegebenenfalls leer. Es wird für jede Anwendung das `latest`-Image von Dockerhub verwendet. Möchte man die Images verändern und/oder neu erstellen, müssen dazu die jeweiligen `docker-compose.[appname].dev.yml` verwendet werden.

Beispiele:

```
docker-compose -f docker-compose.yml -f docker-compose.geoserver.dev.yml build
```
Erstellt das Geoserver-Image neu.

```
docker-compose -f docker-compose.yml -f docker-compose.geoserver.dev.yml up
```
Started sämtliche Container und verwendet für Geoserver die Parameter und Optionen aus dem zusätzlichen `yml`-File.

```
docker-compose -f docker-compose.yml -f docker-compose.caddy.dev.yml up
```
Dito für Caddy.


## Applikationen
### oereb-web-service
Der Quellcode des ÖREB Web service wird in [Github](https://github.com/claeis/oereb-web-service) verwaltet. Die resultierende Jar-Datei wird in [Bintray](https://dl.bintray.com/claeis/oereb-web-service/ch/ehi/oereb/oereb-web-service/) publiziert. Es handelt sich dabei nicht um eine "Fatjar"-Datei. Der Server (das Fatjar) wird erst beim Erstellen des Docker-Images erzeugt (siehe `build.gradle`). Um das Image auf Dockerhub zu pushen, müssen entsprechende Umgebungsvariablen gesetzt sein (siehe `.travis.yml`).

Für den Betrieb müssen die Umgebungsvariablen `DBURL`, `DBUSR`, `DBPWD` und `DBSCHEMA` gesetzt sein. TODO: Weitere Informationen... Link auf "sub"-README.md oder docs von oereb-web-service.

Testrequests:
```
http://localhost:8080/versions/xml
http://localhost:8080/capabilities/xml
```

### Datenbank (PostgreSQL)
foo bar
TODO:
- Tabellen/View-Definitionen hinzufügen. Tabellen müssten beim Importprozess nachgeführt werden (resp. materialized views).

### WMS (QGIS-Server)
foo bar

### WMS (GeoServer)
foo bar

### Proxy (Caddy)
foo bar
TODO:
- yml für dev etc.

## Datenimport

```
./gradlew av_import:replaceCadastralSurveyingData plz_import:dbImport bundesgesetze_import:dbImport bundesdaten_import:replaceFederalData kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData npl_import:refreshMaterializedViews
```

Der "Fullimport" der amtlichen Vermessung dauert circa 2 bis 3 Stunden. Aus diesem Grund werden nur einige Gemeinden importiert (wo ÖREB-Daten vorhanden sind).

## "User data" für Digitalocean etc.
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
- Env-Variablen für DB-Credentials
- GRETL-Jobs auch in einem Dockercontainer ausführen.
- Terraform
- Docker Swarm