# get total area for SSP5 using latest version of the files

stack("./outfiles/rasters010521/RCP19_SSP5_2050_biobioen.tif") %>%
  as.data.frame(xy=TRUE,na.rm = TRUE) %>%
  rename(bioen = 3,cat = 4) %>%
  as_tibble() %>%
  pull(bioen) %>%
  sum()

# get original bionenergy data

r<-raster("/mnt/data1tb/Dropbox/AnnaRepo/originaldata/TRACY-20201222T173558Z-001/TRACY/grid_cell_land_area.nc")

raster("/mnt/data1tb/Dropbox/AnnaRepo/originaldata/TRACY-20201222T173558Z-001/TRACY/RCP19_SSP5_2050_bio.nc")->bioen
bioen[bioen==0]<-NA

mask(r,bioen) %>%
  rastertodf() %>%
  pull(value) %>%
  sum()

quantile(bioen, probs = c(0,0.33,0.67,1),names = TRUE)

bioen[bioen < 1.815081e-01]<-NA

rastertodf(bioen) %>%
  pull(value) %>%
  sum()

# total in Mha
2922.469


# result 2100.594

# get richess map
raster("/mnt/data1tb/Dropbox/AnnaRepo/project/outfiles/rasters/richness_map_RAWDATA.tif") %>%
  projectRaster(crs=CRS(latlon),res=0.5) %>%
  resample(x =.,y=bioen)->rich

quantile(rich, probs = c(0,0.70,0.87,1),names = TRUE)

rich[rich < 372.1969]<-NA

mask(bioen,rich) %>%
  rastertodf() %>%
  pull(value) %>%
  sum()

raster("/mnt/data1tb/Dropbox/AnnaRepo/project/outfiles/rasters/SPECIES_RICHNESS_RCP19_SSP5_2050_bio.tif")

