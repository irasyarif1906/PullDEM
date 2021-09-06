#!/bin/sh
Rscript scr_create_url_srtm.R Volcano_Coordinates_SB.csv

sed '9r urls.txt' scr_downl.sh > scr_downl2.sh
chmod +x scr_downl2.sh
./scr_downl2.sh

unzip \*.hgt.zip
rm *.SRTMGL1.hgt.zip
for f in *.hgt; do
    gdal_translate "$f" "${f%.*}.tif"
done
rm *.hgt
