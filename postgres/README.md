# OEREB Database

[![Build Status](https://travis-ci.org/sogis/oereb-db.svg?branch=master)](https://travis-ci.org/sogis/oereb-db)
[![Docker Pulls](https://img.shields.io/docker/pulls/sogis/oereb-db.svg)](https://hub.docker.com/r/sogis/oereb-db)

Docker image providing a PostGIS database with OEREB tables

## Building and testing the image

The image is built and tested automatically by Travis CI and is available from https://hub.docker.com/r/sogis/oereb-db.

Commands for building and testing the image manually:

```
docker build -t sogis/oereb-db:latest .
docker-compose -f docker-compose.test.yml build
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.test.yml run sut
```

## Running the image

Run the command below for running the image. The meaning of the environment variables used is as follows:

- `PG_DATABASE`: The name of the database to create
- `PG_LOCALE`: Locale for the database to create
- `PG_PRIMARY_PORT`: The port PostgreSQL is running on
- `PG_MODE`: If set to primary, PostgreSQL runs as primary instance (as opposed to a standby or replica instance)
- `PG_USER`: This is the database user that owns all database objects in the PG_DATABASE database (except system objects); this user is granted all privileges on the PG_DATABASE database
- `PG_PRIMARY_USER`: The database user that replicates data to a possible standby DB instance (not used currently, but this environment variable is mandatory)
- `PG_ROOT_PASSWORD`: The password of the postgres database user (the built-in database superuser)
- `PG_WRITE_USER`: The database user that has write (and read) privileges for all tables in the database (except system tables); use this user for importing data into the database
- `PG_READ_USER`: The database user that has read privileges for all database tables; use this user for querying data

```
docker run --rm --name oereb-db -p 54321:5432 --hostname primary \
-e PG_DATABASE=oereb -e PG_LOCALE=de_CH.UTF-8 -e PG_PRIMARY_PORT=5432 -e PG_MODE=primary \
-e PG_USER=admin -e PG_PASSWORD=admin \
-e PG_PRIMARY_USER=repl -e PG_PRIMARY_PASSWORD=repl \
-e PG_ROOT_PASSWORD=secret \
-e PG_WRITE_USER=gretl -e PG_WRITE_PASSWORD=gretl \
-e PG_READ_USER=ogc_server -e PG_READ_PASSWORD=ogc_server \
-v /tmp:/pgdata \
sogis/oereb-db:latest
```

This places the PostgreSQL data under /tmp/primary. If you want to keep the data longer than just until you log out, run instead e.g.:
```
mkdir --mode=0777 ~/crunchy-pgdata
docker run --rm --name oereb-db -p 54321:5432 --hostname primary \
-e PG_DATABASE=oereb -e PG_LOCALE=de_CH.UTF-8 -e PG_PRIMARY_PORT=5432 -e PG_MODE=primary \
-e PG_USER=admin -e PG_PASSWORD=admin \
-e PG_PRIMARY_USER=repl -e PG_PRIMARY_PASSWORD=repl \
-e PG_ROOT_PASSWORD=secret \
-e PG_WRITE_USER=gretl -e PG_WRITE_PASSWORD=gretl \
-e PG_READ_USER=ogc_server -e PG_READ_PASSWORD=ogc_server \
-v ~/crunchy-pgdata:/pgdata \
sogis/oereb-db:latest
```

## Logging into the container

```
docker exec -it oereb-db /bin/bash
```

## Connecting to the database (example for querying data)

```
psql -h localhost -p 54321 -d oereb -U ogc_server
```

## Creating or updating the SQL scripts that populate the database

Run `ILI2PG_PATH=/opt/ili2pg-4.1.0/ili2pg-4.1.0.jar ./create_schema_sql_scripts.sh` for generating the SQL scripts that create the DB schemas and tables. (Set `ILI2PG_PATH` according to your installation.) In case only a specific model needs an update, adapt the script to your needs before running it.

ATTENTION: You must manually edit the `*_ili2.sql` scripts and remove the duplicate DDL statements (duplicate to the ili1 script).

After updating the SQL scripts, remember to commit the changes to the repository. And to re-generate the `pgconf/setup.sql` file with the following command:

```
cat sql/setup_original.sql sql/set_role.sql sql/begin_transaction.sql \
sql/stage_*.sql sql/live_*.sql \
sql/commit_transaction.sql > pgconf/setup.sql
```

## Commands for importing data manually (example)

Import into stage area:

```
curl -O https://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/PLZO_INTERLIS_LV95.zip
unzip PLZO_INTERLIS_LV95.zip PLZO_INTERLIS_LV95/PLZO_ITF_LV95.itf
ILI2PG_PATH=/opt/ili2pg-4.1.0/ili2pg-4.1.0.jar && java -jar $ILI2PG_PATH \
--dbhost localhost --dbport 54321 --dbdatabase oereb --dbusr gretl --dbpwd gretl \
--dbschema stage --models PLZOCH1LV95D \
--dataset ch --deleteData --import PLZO_INTERLIS_LV95/PLZO_ITF_LV95.itf
```
