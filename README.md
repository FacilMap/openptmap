# Openptmap

This is a modified version of [openstreetmap-tile-server](https://github.com/Overv/openstreetmap-tile-server) that is a hacky attempt to run [Openptmap](https://wiki.openstreetmap.org/wiki/Openptmap).

Right now it relies on the [original Openptmap files](https://github.com/giggls/openptmap) and filters the provided OSM file by hand as explained in the [Openptmap instructions](https://wiki.openstreetmap.org/wiki/Openptmap/Installation#Fill_the_Database). A rewrite of the style using CartoCSS and osm2pgsql Flex Output is [in development](https://github.com/FacilMap/tiles/tree/main/pt) and will allow running the map with a modern software stack and live updates through replication.

## Usage

This is an example docker-compose file:
```yaml
services:
    openptmap:
        image: facilmap/openptmap
        environment:
            DOWNLOAD_PBF: https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf
            DOWNLOAD_POLY: https://download.geofabrik.de/europe/germany/berlin.poly
        volumes:
            - ./osm-data:/data/database
        command: run
```

Specify a PBF file for the region that you want to render and its corresponding polygon as `DOWNLOAD_PBF` and `DOWNLOAD_POLY`. Get a specific region from [Geofabrik](https://download.geofabrik.de/) or the whole planet from [Planet.osm](https://wiki.openstreetmap.org/wiki/Planet.osm) (in that case, `DOWNLOAD_POLY` can be omitted).

Alternatively, mount an O5M file as `/data/region.o5m` and a `/data/region.poly`. To convert a PBF file to O5M, you can use something like `wget -O- https://download.geofabrik.de/europe/germany/berlin-latest.osm.pbf | docker run -i --rm --entrypoint= facilmap/openptmap osmconvert - --out-o5m > berlin-latest.o5m`.

Before starting the container for the first time, initialize the database by running:
```bash
docker-compose run --rm openptmap import
```

This will initialize a Postgres database with PostGIS and import the region into it. The PBF/Poly files are only used during the import, they are not needed anymore later when the service is run. If you want to import the region again, you need to empty the volume and run the import again.

The docker container will expose a webserver under port `80` and the Postgres server (with PostGIS) on port `5432`.