args <- commandArgs(trailingOnly = TRUE)
fn <- args[1]
read.csv(fn, header= T) -> csv
csv[,2] -> a
csv[,3] -> b

a1 <- round(a) -1
a2 <- round(a) +1 
b1 <- round(b) -1
b2 <- round(b)+1
a<- c(round(a), a1, a2)
b <- c(round(b), b1, b2)
unique(a) -> a
unique(b) -> b
v1 <- ifelse(a < 0, paste0("S0", as.character(abs(round(a)))),
             paste0("N0", as.character((round(a)))))
v1[nchar(v1) > 3] -> vb
substring(vb,2,2) <- " "
gsub(" ", "", vb, fixed = TRUE) -> vb
v1[nchar(v1) < 4] -> v1
c(v1, vb) -> v1
v2 <- ifelse(b < 0, paste0("W00", as.character(abs(round(b)))),
             paste0("E00", as.character((round(b)))))
v2[nchar(v2) == 5] -> vb
v2[nchar(v2)==4] -> va
v2[nchar(v2) == 6] -> vc
substring(vb,2,2) <- " "
gsub(" ", "", vb, fixed = TRUE) -> vb
substring(vc,2,2) <- " "
substring(vc,3,3) <- " "
gsub(" ", "", vc, fixed = TRUE) -> vc
v2 <- c(va,vb,vc)
expand.grid (v1,v2) -> l
l2 <- paste0(l$Var1, l$Var2, ".SRTMGL1.hgt.zip")
url <- "http://e4ftl01.cr.usgs.gov/MEASURES/SRTMGL1.003/2000.02.11/"
urls <- paste0(url, l2)
urls[order(urls)] -> urls
write.table(urls, "urls.txt", row.names = F, col.names = F, quote = F)
##end of R-script イラ　##
