Source: https://gitlab.com/osm-c-tools/osmctools

Downloaded using:
```
wget http://m.m.i24.cc/osmconvert.c
wget http://m.m.i24.cc/osmfilter.c
wget http://m.m.i24.cc/osmupdate.c
```

Compile using:
```
cc -x c osmconvert.c -lz -O3 -o osmconvert
cc -x c osmfilter.c -O3 -o osmfilter
cc -x c osmupdate.c -o osmupdate
```

Documentation:
* https://wiki.openstreetmap.org/wiki/Osmconvert
* https://wiki.openstreetmap.org/wiki/Osmfilter
* https://wiki.openstreetmap.org/wiki/Osmupdate