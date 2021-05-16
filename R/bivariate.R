# load required libraries
library(raster);library(tidyverse)
library(sf);library(biscale)
library(pals);library(cowplot)
library(grid);library(data.table)
library(marcoUtils);library(classInt)



# Info needed -------------------------------------------------------------


# baseline maps
rob<-"+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
st_read("/mnt/data1tb/bioenergy/shapefiles/world_rob_singleparts.shp")->worldr
st_read("/mnt/data1tb/bioenergy/shapefiles/countries.shp") %>%
   st_transform(rob) %>%
   dplyr::select(FORMAL_EN)->worldr
crs(worldr)->rob




# Maps --------------------------------------------------------------------

scenariol<-c("SSP1","SSP2","SSP5")

# loop through scenarios
for (i in 1:length(scenarios)){
  # read richness raster
  raster(paste0("./rastersoriginaldat/RCP19_",scenariol[i],"_2050_bio_RICHNESS_cropped.tif")) %>%
  projectRaster(.,crs=CRS(rob),res=50000)->rich
  # read bioenergy raster
  raster(paste0("./rastersoriginaldat/RCP19_",scenariol[i],"_2050_bio_cropped.tif")) %>%
    projectRaster(.,crs=CRS(rob),res=50000) ->bioen

  rastertodf(rich) %>%
    rename(rich = value) %>%
    inner_join(rastertodf(bioen) %>%
                 rename(bioen = value)) %>%
    filter(bioen > 0) %>%
    mutate(tmprich = as.numeric(cut(rich,quantile(rich,p=c(0,0.70,0.83,1)),include.lowest=T)),
           tmpbioen = as.numeric(cut(bioen,quantile(bioen,p=c(0,0.33,0.67,1)),include.lowest=T))) %>%
            # Jenks breaks
           #tmpbioen = as.numeric(cut(bioen,classIntervals(bioen,n=3,style="jenks")$brks,include.lowest=T))) %>%
    mutate(bi_class = paste0(tmprich,"-",tmpbioen)) %>%
    as_tibble() %>%
    inner_join(tibble(bi_class=factor(c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"),
                                      levels = c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"))) %>%
                 mutate(fill = c("#cce8d7","#80c39b","#008837","#cedced","#85a8d0","#0a50a1","#fbb4d9","#f668b3","#d60066")) %>%
                 mutate(bi_classf = bi_class)) ->dat2
  # map of synergies and conflicts
dat2 %>% 
  ggplot()+
    theme(legend.position="none",
          plot.background=element_rect(fill = 'black'),
          panel.background = element_rect(fill = 'black',color="black"),
          panel.border = element_rect(colour = "black", fill=NA),
          strip.text = element_text(size = rel(2.5), face = "bold"),
          axis.text = element_blank(),axis.ticks = element_blank(),
          panel.grid.major = element_line(colour = 'transparent'))+
    geom_sf(data=worldr,color='white',fill='grey40',size=0.1)+
    geom_tile(aes(x=x,y=y,fill=bi_classf))+
    scale_fill_manual(values = c("#cce8d7","#80c39b","#008837","#cedced","#85a8d0","#0a50a1","#fbb4d9",
                                 "#f668b3","#d60066"))+xlab("")+ylab("")+
    coord_sf(crs=rob,xlim = c(-12808078,16927051), ylim = c(-5930924,8342353))->map
  # legend
  mypal<-brewer.qualseq(9) 
  mypal1<-c(mypal[1],mypal[4],mypal[7],mypal[2],mypal[5],mypal[8],mypal[3],mypal[6],mypal[9])
  
  tibble(bi_class=factor(c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"),
                         levels = c("1-1","1-2","1-3","2-1","2-2","2-3","3-1","3-2","3-3"))) %>%
    mutate(fill = c("#cce8d7","#80c39b","#008837","#cedced","#85a8d0","#0a50a1","#fbb4d9","#f668b3","#d60066")) %>%
    mutate(bi_class1 = bi_class) %>%
    separate(bi_class, into = c("gini", "mean"), sep = "-") %>%
    mutate(gini = as.integer(gini),mean = as.integer(mean)) %>% 
    ggplot() +geom_tile(mapping = aes(x = gini,y = mean,fill = mypal1))+scale_fill_identity()+labs(x = "Biodiversity ⟶️",y = "Bioenergy ⟶️") +
    theme(panel.background = element_rect(fill = 'black'),panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
          panel.border = element_blank(),axis.text.x = element_blank(),axis.ticks.x = element_blank(),axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),axis.title = element_text(size=10,colour = "white",face = "bold"),plot.background=element_rect(fill = 'black'))+
    coord_fixed()->legend
  
  # combine map + legend
  ggdraw()+draw_plot(map, 0, 0, 1, 1)+draw_plot(legend, 0.01, 0.1, 0.15, 0.3)->finalplot
  
  # save file
  paste0("./outfiles/",str_replace(scenarios[i],".tif","bioen_may21.png"))->fileout
  png(fileout,width = 4000,height=2000,res = 400)
  pushViewport(viewport(layout = grid.layout(1, 1)))
  print(finalplot,vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
  dev.off()
  
}

# bioenergy rasters from proportions to Mha -----------------------------------------------------------------------


raster("./originaldata/TRACY-20201222T173558Z-001/TRACY/grid_cell_land_area.nc")->area

list.files("./originaldata/TRACY-20201222T173558Z-001/TRACY/",pattern = ".nc",full.names = T) %>%
  .[str_detect(.,"SSP1|SSP2|SSP5")]->filel

# loop through dataset
for (i in 1:3){
  print(i)
  raster(filel[i])->tmpr
  tmpr*area->tmpr1
  tmpr1[tmpr1==0]<-NA
  paste0("./rastersoriginaldat/", str_replace(basename(filel[i]),".nc",".tif"))->fout
  writeRaster(tmpr1,fout,overwrite =TRUE)
}



paste0("./rastersoriginaldat/RCP19_",scenarios[i],"_2050_bio.tif")

# crop rasters so that they have the same extent (from GRASS GIS) --------------------------------------------------------------------


# read in binary matrix containing info on species presence
#fread("/mnt/data1tb/bioenergy/species_csv/dat01.csv") %>%
raster("./rastersoriginaldat/richness.tif") %>%
  projectRaster(crs=latlon,res=0.5) %>%
  rastertodf() %>%
  mutate(value = round(value)) %>% {.->>tmp} %>%
  rasterFromXYZ(crs=latlon) %>%
  writeRaster("./rastersoriginaldat/richness_latlon.tif")
  

list.files("/mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat",full.names = T) %>%
  .[str_detect(.,"_bio.tif")] %>%
  .[!str_detect(.,"xml")]->bioenl

# data
for (i in 1:length(bioenl)){
  # read into grass GIS
  system(command = paste0("r.in.gdal in=",bioenl[i]," out=tmp --o"))
  # create mask
  system(command = paste0("r.mapcalc 'tmp1 = int(tmp/tmp)' --o"))
  # use mask
  system("r.mask raster=tmp1 maskcats=1")
  # write out RICHNESS raster
  paste0("/mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat/",str_remove(basename(bioenl[i]),".tif"),"_RICHNESS_cropped.tif")->fout
  system(command = paste0("r.out.gdal in=rich_latlon out=",fout," createopt='COMPRESS=LZW' --o"))
  # write out BIOENERGY RASTER raster
  paste0("/mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat/",str_remove(basename(bioenl[i]),".tif"),"_cropped.tif")->fout
  system(command = paste0("r.out.gdal in=tmp out=",fout," createopt='COMPRESS=LZW'  --o"))
  #system("d.rast rich_latlon")
  # remove temporary raster
  system("g.remove type=raster name=tmp -f")
  system("g.remove type=raster name=tmp1 -f")
  system("r.mask -r")
}
  

# bioenergy rasters for google earth engine -------------------------------


# create bioenergy rasters

scenariol<-c("SSP1","SSP2","SSP5")

totbioen<-NULL

for(i in 1:length(scenariol)){
  print(i)
  # read richness raster
  raster(paste0("./rastersoriginaldat/RCP19_",scenariol[i],"_2050_bio_RICHNESS_cropped.tif"))->rich
  # read bioenergy raster
  raster(paste0("./rastersoriginaldat/RCP19_",scenariol[i],"_2050_bio_cropped.tif"))->bioen
  # calculate surface area for whole landscape
  rastertodf(bioen) %>%
     summarise(area = sum(value),scenario = scenariol[i],perc = "100%")->areares
  bind_rows(areares,totbioen)->totbioen
  # mask richness data
  mask(rich,bioen)->rich1
  # join richess and bioenergy data
  rastertodf(rich1) %>%
    rename(rich = value) %>%
    inner_join(rastertodf(bioen) %>%
                 rename(bioen = value)) %>%
    # top 30% and 17% biodiversity fractions  
    mutate(topf = as.numeric(cut(rich,quantile(rich,p=c(0.70,0.83,1),include.lowest = TRUE)))) %>%
    #arrange(rich) %>%
    #mutate(prop = 1:length(rich),prop=scales::rescale(prop,to=c(0,1))) %>%
    filter(!is.na(topf)) %>%
    dplyr::select(x,y,topf,bioen) %>% {.->>tmp} %>%
    rasterFromXYZ(crs=latlon)->tmpr
  # calculate surface area for different fractions and save them
  tmp %>%
    summarise(area = sum(bioen),scenario = scenariol[i],perc = "30%") %>%
    bind_rows(tmp %>%
                filter(topf==2) %>%
                summarise(area = sum(bioen),scenario = scenariol[i],perc = "17%"))->areares1
  bind_rows(areares1,totbioen)->totbioen
  # write out file
  writeRaster(tmpr,paste0("./rastersoriginaldat/",tolower(scenariol[i]),"_gee.tif"),overwrite =TRUE)
}


# total areas from original files -----------------------------------------

# total areas
raster("./originaldata/TRACY-20201222T173558Z-001/TRACY/grid_cell_land_area.nc")->area

list.files("./originaldata/TRACY-20201222T173558Z-001/TRACY/",pattern = ".nc",full.names = T) %>%
  .[str_detect(.,"SSP1|SSP2|SSP5")]->filel

# original areas
res<-NULL

for (i in 1:3){
  print(i)
  raster(filel[i])->tmpr
  tmpr*area->tmpr1
  tmpr1[tmpr1==0]<-NA
  rastertodf(tmpr1) %>%
    pull(value) %>%
    sum()->tmpres
  tibble(area = tmpres,file = basename(filel[i]))->tmpres1
  bind_rows(tmpres1,res)->res
}



# google earthengine uploads ----------------------------------------------


# upload files to google cloud storage
system("gsutil -m cp /mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat/ssp1_gee.tif gs://marco_g_assets/")
system("gsutil -m cp /mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat/ssp2_gee.tif gs://marco_g_assets/")
system("gsutil -m cp /mnt/data1tb/Dropbox/AnnaRepo/project/rastersoriginaldat/ssp5_gee.tif gs://marco_g_assets/")

# import into google earthengine
system("earthengine upload image --asset_id=users/marcogirardello/annarepo/ssp1 gs://marco_g_assets/ssp1_gee.tif")
system("earthengine upload image --asset_id=users/marcogirardello/annarepo/ssp2 gs://marco_g_assets/ssp2_gee.tif")
system("earthengine upload image --asset_id=users/marcogirardello/annarepo/ssp5 gs://marco_g_assets/ssp5_gee.tif")

