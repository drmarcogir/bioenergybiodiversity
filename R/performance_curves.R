library(tidyverse);library(raster)
library(marcoUtils)


system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP1_full/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP1_full/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP1_full/tmp",header=F,sep="") %>%
  as_tibble() %>%
  dplyr::select(V1,V8,V9) %>%
  rename(landscape_removed = V1,biodiv = V8, bioen = V9) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = rev(bioen)) %>%
  mutate(scenario = "SSP1")->dat



system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP2_full/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP2_full/tmp")  


read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP2_full/tmp",header=F,sep="") %>%
  as_tibble() %>%
  dplyr::select(V1,V8,V9) %>%
  rename(landscape_removed = V1,biodiv = V8, bioen = V9) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = rev(bioen)) %>%
  mutate(scenario = "SSP2")->dat1


system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP5_full/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP5_full/tmp")  


read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP5_full/tmp",header=F,sep="") %>%
  as_tibble() %>%
  dplyr::select(V1,V8,V9) %>%
  rename(landscape_removed = V1,biodiv = V8, bioen = V9) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = rev(bioen)) %>%
  mutate(scenario = "SSP5")->dat2


dat %>%
  mutate(landscape_removed1 = rev(landscape_removed)) %>%
  bind_rows(dat1 %>%
              mutate(landscape_removed1 = rev(landscape_removed))) %>%
  bind_rows(dat2  %>%
              mutate(landscape_removed1 = rev(landscape_removed))) %>%
  ggplot(data=.)+geom_line(aes(x=landscape_removed,y=biodiv1,colour=scenario),size=1.2)+
  theme_dark()+xlab("% landscape allocated  to bioenergy")+ylab("proportion of distributions lost")+theme(axis.text = element_text(size = 17,colour = "black"),
                                                                                   axis.title = element_text(size=20,colour = "black"),
                                                                                   legend.text = element_text(size=12),
                                                                                   legend.title = element_text(size=15))->myplot
  
  

ggsave(myplot,filename = "./figures/curves1.png",dpi=400,width = 8,height = 8)


dat %>%
  mutate(landscape_removed = rev(landscape_removed)) %>%
  dplyr::select(c(landscape_removed,biodiv,bioen,scenario)) %>%
  pivot_longer(names_to = "var",values_to ="values",cols=-c(landscape_removed,scenario)) %>%
  ggplot(data=.)+geom_line(aes(x=landscape_removed,y=values,colour=var),size=1.2)+
  theme_dark()+xlab('"% of landscape protected"')+ylab("species (mean) range loss")+theme(axis.text = element_text(size = 17,colour = "black"),
                                                                                             axis.title = element_text(size=20,colour = "black"),
                                                                                             legend.text = element_text(size=12),
                                                                                             legend.title = element_text(size=15))
  


dat %>%
  bind_rows(dat1) %>%
  bind_rows(dat2) %>%
  ggplot(data=.)+geom_line(aes(x=bioen,y=biodiv1,colour=scenario),size=1.2)+
  theme_dark()+xlab("% land allocated to bioenergy")+ylab("species (mean) range loss")+theme(axis.text = element_text(size = 17,colour = "black"),
                                                                                             axis.title = element_text(size=20,colour = "black"),
                                                                                             legend.text = element_text(size=12),
                                                                                             legend.title = element_text(size=15))->myplot
biodiv0_SSP1_species


### Version for all species


system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "SSP1")->dat

system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP2_species_1/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP2_species_1/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP2_species_1/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "SSP2")->dat1

system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP5_species/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP5_species/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP5_species/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "SSP5")->dat2

dat %>%
  bind_rows(dat1) %>%
  bind_rows(dat2) %>%
  ggplot(data=.)+geom_line(aes(x=landscape_removed,y=biodiv1,colour=scenario),size=1.2)+
  theme_bw()+xlab("% land allocated to bioenergy")+ylab("species (mean) range loss")+theme(axis.text = element_text(size = 17,colour = "black"),
                                                                                             axis.title = element_text(size=20,colour = "black"),
                                                                                             legend.text = element_text(size=12),
                                                                                             legend.title = element_text(size=15))->myplot



ggsave(myplot,filename = "./figures/curves_sameextent_species.png",dpi=400,width = 8,height = 8)



# SSP1 --- comparison of scenario

system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP1_species_1/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "b) SSP1 -area covering all scenarios")->dat


system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP1_species/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP1_species/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP1_species/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "a) SSP1 -only area covering SSP1")->dat1


system("sed '1,3d' /mnt/data1tb/bioenergy/biodiv0_SSP1_species_allspecies_check/output.curves.txt > /mnt/data1tb/bioenergy/biodiv0_SSP1_species_allspecies_check/tmp")  

read.delim("/mnt/data1tb/bioenergy/biodiv0_SSP1_species_allspecies_check/tmp",header=F,sep="") %>%
  as_tibble() %>%
  rename(landscape_removed = V1,bioen=dim(.)[2]) %>%
  mutate(biodiv = rowMeans(.[,8:(dim(.)[2]-1)])) %>%
  dplyr::select(landscape_removed,bioen,biodiv) %>%
  mutate(biodiv1 = 1-biodiv) %>%
  mutate(bioen1 = 1-bioen) %>%
  mutate(scenario = "c) SSP1 -global")->dat2

dat %>%
  bind_rows(dat1) %>%
  bind_rows(dat2) %>%
  ggplot(data=.)+geom_line(aes(x=landscape_removed,y=biodiv1,colour=scenario),size=1.2)+
  theme_bw()+xlab("% land allocated to bioenergy")+ylab("species (mean) range loss")+theme(axis.text = element_text(size = 17,colour = "black"),
                                                                                           axis.title = element_text(size=20,colour = "black"),
                                                                                           legend.text = element_text(size=12),
                                                                                           legend.title = element_text(size=15))->myplot


ggsave(myplot,filename = "./figures/curves_SSP1comparison.png",dpi=400,width = 8,height = 8)


