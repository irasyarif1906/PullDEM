
#!/bin/sh
echo "gdal_merge.py -o sticth_SRTM.tif" > list1
ls *.tif | tr -d ' \n ' | sed -e 's/.tif/.tif /g' > list2
paste list1 list2 > command.sh
sh command.sh

Rscript scr_utm_crop.R Volcano_Coordinates_SB.csv
