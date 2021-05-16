library(raster);library(tidyverse)

raster("/mnt/data1tb/bioenergy/twofiles/output.wrscr.compressed.tif")->sp
raster("/mnt/data1tb/bioenergy/twofiles/RCP19_SSP1_2050_bio.tif")->bioen

rastertodf(bioen) %>%
  filter(value > 0) %>%
  mutate(value = 1) %>%
  rasterFromXYZ() %>%
  writeRaster(.,"/home/marco/Desktop/mask.tif")
  

as_tibble(rastertodf(sp)) %>%
  rename(biodiv = value) %>%
  inner_join(rastertodf(bioen) %>%
               rename(bioen = value)) %>%
  as.data.frame()->df

  
spdf <- SpatialPointsDataFrame(df[, 1:2], df)
localstats1 <- gwss(spdf, vars = c("biodiv", "bioen"), bw = 300000)

as_tibble(data.frame(localstats1$SDF)) %>%
  dplyr::select(x,y,Spearman_rho_biodiv.bioen) %>%
  rasterFromXYZ()->dd








%>%
  mutate(res = residuals(lm(biodiv~bioen,data=.))) %>%
  dplyr::select(x,y,res) %>%
  filter(res > 0) %>%
  rasterFromXYZ() %>%
  writeRaster(.,"/home/marco/Desktop/res.tif",overwrite=TRUE)