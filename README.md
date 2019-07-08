# oereb-kataster-prototyp

## OEREB-Kataster
Starten der Anwendung mit `docker-compose`:

```
docker-compose up

docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

Es wird eine Datenbank angelegt und der oereb-web-service wird gestartet. 

Testrequests oereb-web-service:
```
http://localhost:8080/versions/xml
http://localhost:8080/capabilities/xml
```

## Datenimport

```
./gradlew av_import:replaceCadastralSurveyingData plz_import:dbImport bundesgesetze_import:dbImport bundesdaten_import:replaceFederalData kantonale_gesetze_import:dbImport npl_import:replaceLandUsePlanningData
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