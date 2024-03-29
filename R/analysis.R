# Author: Marco Girardello
# Version: 1.0
# Date: 2023-09-07

# Load required libraries
library(terra)
library(tidyverse)
library(sf)
library(biscale)
library(pals)
library(cowplot)
library(grid)

# Baseline maps
worldr <- st_read("./data/backgroundmap/countries.gpkg") %>%
  st_transform(
    "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
  ) %>%
  dplyr::select(FORMAL_EN)

# Raster parameters for reprojection
targetr <- rast(
  extent = ext(
    -16250715.8345027, 
    16927051.0766566, 
    -5930924.18797298, 
    8342353.11623403
  ), 
  res = 50000,
  crs = "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
)



# Bivariate maps --------------------------------------------------------------------

source("./R/functions/create_scenario_map.R")

# Create a list of scenarios
scenariol <- c("SSP1", "SSP2", "SSP5")

# Use purrr::map to create maps for each scenario
map(scenariol, create_scenario_map)

# Range loss curves (plots + datasets) --------------------------------------------------------------------

source("./R/functions/range_loss.R")

# unzip csv file containing species data
unzip("./data/csv/speciesdat.zip")

# read in data
read_csv("./data/csv/speciesdat.csv")->dat

# calculate cumulative proportion of range loss
scenariol <- c("SSP1", "SSP2", "SSP5")
results <- map_dfr(scenariol, ~ process_raster_data(paste0("./data/rasters/RCP19_", .x, "_2050_bio.tif"), .x, dat))

results %>%
  # group by scenario
  group_by(scenario) %>%
  # rescale information
  mutate(bioen = scales::rescale(bioen,to=c(0,1))) %>%
  mutate(biodiv_cumsum = scales::rescale(biodiv_cumsum,to=c(0,1))) %>%
  ggplot(.,aes(x=bioen,y=biodiv_cumsum,colour=scenario))+geom_line()+theme_minimal()+
  theme(axis.title = element_text(size=15))+
  xlab("Bioenergy expansion (rescaled- was in Mha)")+ylab("Cumulative range loss (rescaled - was in number of pixels)")->p1

ggsave(p1,filename = "./figures/curves/range_lost.png",
       width = 8,
       height = 8,
       dpi = 400,
       bg = 'white')

# Proportion of species affected -----------------------------------------------------------------------

source("./R/functions/prop_rich.R")

# read in binary species matrix (all vertebrates)
dat <- read_csv("./data/csv/speciesdat.csv")

# SSP1
rast("./data/rasters/RCP19_SSP1_2050_bio.tif") %>%
  as.data.frame(xy = TRUE) %>%
  as_tibble() %>%
  rename(bioen = tmp) %>%
  # join with species data
  inner_join(dat) %>%
  # get rid of coordinates 
  dplyr::select(-c(x,y)) %>%
  # arrange data by bioenergy values in descending order
  arrange(desc(bioen)) %>%
  # calculate proportion of species lost
  prop_rich() %>%
  # insert scenario info
  mutate(scenario = 'SSP1')->SSP1_res

# SSP2
rast("./data/rasters/RCP19_SSP2_2050_bio.tif") %>%
  as.data.frame(xy = TRUE) %>%
  as_tibble() %>%
  rename(bioen = tmp) %>%
  # join with species data
  inner_join(dat) %>%
  # get rid of coordinates 
  dplyr::select(-c(x,y)) %>%
  # arrange data by bioenergy values in descending order
  arrange(desc(bioen)) %>%
  # calculate proportion of species lost
  prop_rich() %>%
  # insert scenario info
  mutate(scenario = 'SSP2')->SSP2_res


# SSP5
rast("./data/rasters/RCP19_SSP5_2050_bio.tif") %>%
  as.data.frame(xy = TRUE) %>%
  as_tibble() %>%
  rename(bioen = tmp) %>%
  # join with species data
  inner_join(dat) %>%
  # get rid of coordinates 
  dplyr::select(-c(x,y)) %>%
  # arrange data by bioenergy values in descending order
  arrange(desc(bioen)) %>%
  # calculate proportion of species lost
  prop_rich() %>%
  # insert scenario info
  mutate(scenario = 'SSP5')->SSP5_res


# final plot

SSP1_res %>%
  bind_rows(SSP2_res) %>%
  bind_rows(SSP5_res) %>%
  dplyr::select(bioen,richcum,scenario) %>%
  group_by(scenario) %>%
  mutate(bioen = scales::rescale(bioen,to=c(0,1))) %>%
  ggplot(.,aes(x=bioen,y=richcum,colour=scenario))+geom_line(size=1)+theme_minimal()+
  theme(axis.title = element_text(size=15))+
  xlab("Bioenergy expansion (Mha) rescaled")+ylab("Proportion of species affected")->p2

ggsave(p2,filename = "./figures/curves/prop_species_lost.png",
       height = 8,
       width = 8,
       dpi = 400,
       bg = 'white')

