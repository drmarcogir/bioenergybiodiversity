# load required libraries

library(raster);library(tidyverse)
library(marcoUtils);library(data.table)

# convert species info
list.files("/mnt/data1tb/bioenergy/allfiles_SSP2_1",pattern=".tif",full.names = T) %>%
  .[!str_detect(.,"RCP19")]->tifl


res<-vector("list",281)

for (i in 1:281){
  print(i)
  if(i!=281){
    min<-round((28133/281))*(i-1)+1
    max<-round((28133/281))*i
    stack(tifl[min:max])->myr
    as_tibble(rastertodf(myr))->dat
    dat->res[[i]]
  } else {
    min<-round((28133/281))*(i-1)+1
    max<-28133
    stack(tifl[min:max])->myr
    as_tibble(rastertodf(myr))->dat
    dat->res[[i]]
  }
}

# merge list
res %>%
  reduce(inner_join)->dat

dir.create("/mnt/data1tb/bioenergy/species_csv")
#fwrite(dat,"/mnt/data1tb/bioenergy/species_csv/dat01.csv")

fread("/mnt/data1tb/bioenergy/species_csv/dat01.csv")->dat




# solution based on the cumulative sum of range loss

# SSP1
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP1_1/RCP19_SSP1_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2

dat2 %>%  
  mutate(biodiv = cumsum(rowSums(.[2:dim(.)[2]]))) %>%
  mutate(biodiv_sum = rowSums(dat2[2:dim(dat2)[2]])) %>% 
  dplyr::select(value,biodiv,biodiv_sum) %>% 
  mutate(bioen = cumsum(value)) ->SSP1_range

# SSP2
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP2_1/RCP19_SSP2_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2

dat2 %>%  
  mutate(biodiv = cumsum(rowSums(.[2:dim(.)[2]]))) %>%
  mutate(biodiv_sum = rowSums(dat2[2:dim(dat2)[2]])) %>% 
  dplyr::select(value,biodiv,biodiv_sum) %>% 
  mutate(bioen = cumsum(value)) ->SSP2_range


# SSP5
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP5/RCP19_SSP5_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2

dat2 %>%  
  mutate(biodiv = cumsum(rowSums(.[2:dim(.)[2]]))) %>%
  mutate(biodiv_sum = rowSums(dat2[2:dim(dat2)[2]])) %>% 
  dplyr::select(value,biodiv,biodiv_sum) %>% 
  mutate(bioen = cumsum(value)) ->SSP5_range



SSP1_range %>%
  mutate(scenario ="SSP1") %>%
  bind_rows(SSP2_range %>%
              mutate(scenario = "SSP2")) %>%
  bind_rows(SSP5_range %>%
              mutate(scenario = "SSP5")) %>% {.->>rangeloss}  %>%
  group_by(scenario) %>%
  mutate(bioen1 = scales::rescale(bioen,to=c(0,1))) %>%
  ungroup() %>%
  mutate(biodiv1 = scales::rescale(biodiv,to=c(0,1))) %>%
  ggplot(.,aes(x=bioen1,y=biodiv1,colour=scenario))+geom_line()+theme_minimal()+
  theme(axis.title = element_text(size=15))+
  xlab("Bioenergy expansion (rescaled- was in Mha)")+ylab("Cumulative range loss (rescaled - was in number of pixels)")->p1

ggsave(p1,filename = "./outfiles/rangeloss_curve.png",width = 8,height = 8,dpi = 400)

rangeloss %>%
  dplyr::select(biodiv,bioen,scenario) %>%
  rename(biodiversity = biodiv, bioenergy = bioen) %>%
  write_csv("./outfiles/rangelosscurves.csv")

# RICHNESS. PROPORTION OF SPECIES AFFECTED

# SSP1
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP1_1/RCP19_SSP1_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2

for (i in 2:dim(dat2)[2]){
  print(i)
  dat2[,i] %>%
    pull(1)->tmpv 
  tmpv[which(tmpv!=0)[1]]<-NA
  tmpv[!is.na(tmpv)]<-0
  tmpv[is.na(tmpv)]<-1
  tmpv->dat2[,i]
}


dat2 %>%
  mutate(rich = rowSums(dat2[2:dim(dat2)[2]])) %>%
  dplyr::select(value,rich) %>%
  mutate(richcum = cumsum(rich/28133),bioen = cumsum(value))->SSP1_res


# SSP2
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP2_1/RCP19_SSP2_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2


for (i in 2:dim(dat2)[2]){
  print(i)
  dat2[,i] %>%
    pull(1)->tmpv 
  tmpv[which(tmpv!=0)[1]]<-NA
  tmpv[!is.na(tmpv)]<-0
  tmpv[is.na(tmpv)]<-1
  tmpv->dat2[,i]
}


dat2 %>%
  mutate(rich = rowSums(dat2[2:dim(dat2)[2]])) %>%
  dplyr::select(value,rich) %>%
  mutate(richcum = cumsum(rich/28133),bioen = cumsum(value))->SSP2_res


# SSP5
as_tibble(rastertodf(raster("/mnt/data1tb/bioenergy/allfiles_SSP5/RCP19_SSP5_2050_bio.tif"))) %>%
  inner_join(dat) %>%
  dplyr::select(-c(x,y)) %>%
  arrange(desc(value))->dat2


for (i in 2:dim(dat2)[2]){
  print(i)
  dat2[,i] %>%
    pull(1)->tmpv 
  tmpv[which(tmpv!=0)[1]]<-NA
  tmpv[!is.na(tmpv)]<-0
  tmpv[is.na(tmpv)]<-1
  tmpv->dat2[,i]
}


dat2 %>%
  mutate(rich = rowSums(dat2[2:dim(dat2)[2]])) %>%
  dplyr::select(value,rich) %>%
  mutate(richcum = cumsum(rich/28133),bioen = cumsum(value))->SSP5_res



SSP5_res %>%
  mutate(scenario ="SSP5") %>%
  bind_rows(SSP2_res  %>%
              mutate(scenario = "SSP2")) %>%
  bind_rows(SSP1_res  %>%
              mutate(scenario = "SSP1")) %>%
 dplyr::select(bioen,richcum,scenario) %>%
 rename(bioenergy = bioen,richness = richcum) %>%
  write_csv("./outfiles/richness_affectedspecies.csv")
  group_by(scenario) %>%
  mutate(bioen = scales::rescale(bioen,to=c(0,1))) %>%
  ggplot(.,aes(x=bioen,y=richcum,colour=scenario))+geom_line(size=1)+theme_minimal()+
  theme(axis.title = element_text(size=15))+
  xlab("Bioenergy expansion (Mha) rescaled")+ylab("Proportion of species affected")->p2

ggsave(p2,filename = "./outfiles/nospeciesaffected_curve.png",height = 8,width = 8,dpi = 400)
