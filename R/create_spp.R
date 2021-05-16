library(tidyverse)

# bioenergy only scenario SSP1
list.files("/mnt/data1tb/bioenergy/allfiles_SSP1/",pattern=".tif") %>%
  .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
  as_tibble() %>%
  mutate(V1=0,V2=1,V3=1,V4=1,V5=1) %>%
  dplyr::select(V1,V2,V3,V4,V5,value) %>%
  bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles_SSP1/",pattern=".tif") %>%
                        .[str_detect(.,"SSP")]) %>%
              mutate(V1=1,V2=1,V3=1,V4=1,V5=1)) %>%
  mutate(value = paste0("allfiles_SSP1/",value)) %>%
  write.table(.,"/mnt/data1tb/bioenergy/allfiles_SSP1/bioenergy_only.spp",col.names = F,row.names = F,quote = F)


# bioenergy only scenario SSP2
list.files("/mnt/data1tb/bioenergy/allfiles_SSP2/",pattern=".tif") %>%
  .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
  as_tibble() %>%
  mutate(V1=0,V2=1,V3=1,V4=1,V5=1) %>%
  dplyr::select(V1,V2,V3,V4,V5,value) %>%
  bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles_SSP2/",pattern=".tif") %>%
                        .[str_detect(.,"SSP")]) %>%
              mutate(V1=1,V2=1,V3=1,V4=1,V5=1)) %>%
  mutate(value = paste0("allfiles_SSP2/",value)) %>%
  write.table(.,"/mnt/data1tb/bioenergy/allfiles_SSP2/bioenergy_only.spp",col.names = F,row.names = F,quote = F)

# bioenergy only scenario SSP5
list.files("/mnt/data1tb/bioenergy/allfiles_SSP5/",pattern=".tif") %>%
  .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
  as_tibble() %>%
  mutate(V1=0,V2=1,V3=1,V4=1,V5=1) %>%
  dplyr::select(V1,V2,V3,V4,V5,value) %>%
  bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles_SSP5/",pattern=".tif") %>%
                        .[str_detect(.,"SSP")]) %>%
              mutate(V1=1,V2=1,V3=1,V4=1,V5=1)) %>%
  mutate(value = paste0("allfiles_SSP5/",value)) %>%
  write.table(.,"/mnt/data1tb/bioenergy/allfiles_SSP5/bioenergy_only.spp",col.names = F,row.names = F,quote = F)


# # biodiversity only scenario
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/biodiversity_only.spp",col.names = F,row.names = F,quote = F)

# biodiversity + bioenergy SSP1 (positive weight for bioenergy)
#list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#  .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#  as_tibble() %>%
  # mutate(V1=1,V2=1,V3=1,V4=1,V5=1) %>%
  # dplyr::select(V1,V2,V3,V4,V5,value) %>%
  # bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP1")]) %>%
#                          slice(2) %>%
#                         mutate(V1=25620,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP1_conflicts.spp",col.names = F,row.names = F,quote = F)
# 
# 
# # biodiversity + bioenergy SSP2 (positive weight for bioenergy)
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP2")]) %>%
#               mutate(V1=31226,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP2_conflicts.spp",col.names = F,row.names = F,quote = F)
# 
# # biodiversity + bioenergy SSP5 (positive weight for bioenergy)
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP5")]) %>%
#               mutate(V1=31226,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP5_conflicts.spp",col.names = F,row.names = F,quote = F)
# 
# 
# # biodiversity + bioenergy SSP1 (negative weight for biodiversity)
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=-1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP1")]) %>%
#               mutate(V1=25620,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP1_opportunities.spp",col.names = F,row.names = F,quote = F)
# 
# 
# # biodiversity + bioenergy SSP2 (negative weight for bioenergy)
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=-1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP2")]) %>%
#               mutate(V1=31226,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP2_opportunities.spp",col.names = F,row.names = F,quote = F)
# 
# # biodiversity + bioenergy SSP5 (negative weight for bioenergy)
# list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#   .[str_detect(.,"birds|mammals|reptiles|amphibians")] %>%
#   as_tibble() %>%
#   mutate(V1=-1,V2=1,V3=1,V4=1,V5=1) %>%
#   dplyr::select(V1,V2,V3,V4,V5,value) %>%
#   bind_rows(as_tibble(list.files("/mnt/data1tb/bioenergy/allfiles3/",pattern=".tif") %>%
#                         .[str_detect(.,"SSP5")]) %>%
#               mutate(V1=31226,V2=1,V3=1,V4=1,V5=1)) %>%
#   mutate(value = paste0("allfiles3/",value)) %>%
#   write.table(.,"/mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP5_opportunities.spp",col.names = F,row.names = F,quote = F)
# 
