list.of.packages <- c("raster", "rgdal", "dplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(raster)
library(rgdal)
library(dplyr)

args <- commandArgs(trailingOnly = TRUE)
fn <- args[1]
read.csv(fn, header= T) -> csv
raster("sticth_SRTM.tif") -> dem
const = 60/111
csv[,1:3] -> csv
subset(csv, Latitude < 7) -> csv
subset(csv, Latitude < 0) -> csvS
subset(csv, Latitude>= 0) -> csvN
nameN <- csvN[,1]
nameS <- csvS[,1]
dtN <- split(csvN, seq(nrow(csvN)))
dtS <- split(csvS, seq(nrow(csvS)))
extN <- lapply(dtN, function(x) extent(x[,3] - const, x[,3] + const, x[,2]-const, x[,2] +const))
extS <- lapply(dtS, function(x) extent(x[,3] - const, x[,3] + const, x[,2]-const, x[,2] +const))
pN <- lapply(extN, function(x) as(x, "SpatialPolygons"))
pS <- lapply(extS, function(x) as(x, "SpatialPolygons"))
#lapply(p, function(c) plot(c, add=T))
lapply(pN, function(x) crop(dem, x)) -> crop_vN
lapply(pS, function(x) crop(dem, x)) -> crop_vS

utma <- "+proj=utm +zone="
utmc <- " ellps=WGS84"
utmb <- " +south=T"

read.csv("~/Documents/batch_dl_srtm30/utm_zone.csv") -> utm.df
getZone <- function(x, data) {
  tmp <- data %>%
    filter(long_dw <= x, x <= long_up) %>%
    filter(row_number() == 1)
  return(tmp$zone)
}
ZoneN <- lapply(dtN, function(x) as.character(sapply(x$Longitud, getZone, data=utm.df)))
ZoneS <- lapply(dtS, function(x) as.character(sapply(x$Longitud, getZone, data=utm.df)))
utmN <- lapply(ZoneN, function(x) paste0(utma,  x, utmc))
utmS <- lapply(ZoneS, function(x) paste0(utma,  x, utmb, utmc))

fun_projection <- function(x,y)
   {suppressWarnings(projectRaster(x, crs=y, res=c(30,30)))}
Map(fun_projection, x=crop_vN, y=utmN) -> utm_cropN
Map(fun_projection, x=crop_vS, y=utmS) -> utm_cropS

for (i in seq_along(crop_vN))
{names(crop_vN[[i]]) <- nameN[i]
names(utm_cropN[[i]]) <- nameN[i]
values(utm_cropN[[i]]) <- round(values(utm_cropN[[i]]), 2)}
for (i in seq_along(crop_vS))
{names(crop_vS[[i]]) <- nameS[i]
names(utm_cropS[[i]]) <- nameS[i]
values(utm_cropS[[i]]) <- round(values(utm_cropS[[i]]), 2)}

dir.create("ascii")
for (i in seq_along(utm_cropN)) {
  rgdal::writeGDAL(as(utm_cropN[[i]], "SpatialGridDataFrame"), 
                   paste0("ascii/", names(utm_cropN[[i]]),".asc", sep=""), 
                   drivername = "AAIGrid", mvFlag="-99.99",  options="DECIMAL_PRECISION=2")}
for (i in seq_along(utm_cropS)) {
  rgdal::writeGDAL(as(utm_cropS[[i]], "SpatialGridDataFrame"), 
                   paste0("ascii/", names(utm_cropS[[i]]),".asc", sep=""), 
                   drivername = "AAIGrid", mvFlag="-99.99",  options="DECIMAL_PRECISION=2")}

dir.create("rasterr")
for (i in seq_along(utm_cropN)) {
  rgdal::writeGDAL(as(utm_cropN[[i]], "SpatialGridDataFrame"), paste0("rasterr/", names(utm_cropN[[i]]),".tif", sep=""), drivername = "GTiff", type = "Float32",
                   mvFlag = NA, copy_drivername = "GTiff", setStatistics=FALSE,
                   colorTables = NULL, catNames=NULL, options="TWS=YES")}
for (i in seq_along(utm_cropS)) {
  rgdal::writeGDAL(as(utm_cropS[[i]], "SpatialGridDataFrame"), paste0("rasterr/", names(utm_cropS[[i]]),".tif", sep=""), drivername = "GTiff", type = "Float32",
                   mvFlag = NA, copy_drivername = "GTiff", setStatistics=FALSE,
                   colorTables = NULL, catNames=NULL, options="TWS=YES")}

#end of script_ira_chan_2021#
