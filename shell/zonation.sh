
cd /mnt/data1tb/bioenergy/




# Scenario 1: all species (no bioenergy)
wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/bioenergy/allfiles2/nogov.dat /mnt/data1tb/bioenergy/allfiles2/biodiversity_only.spp biodiversity_only/output.txt 0.0 0 1.0 1


# Scenario 2: positive bioenergy (conflicts)
wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/bioenergy/allfiles2/nogov.dat /mnt/data1tb/bioenergy/allfiles2/bioenergy_SSP1_conflicts.spp bioenergy_SSP1_conflicts/output.txt 0.0 0 1.0 1

wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/bioenergy/allfiles2/nogov.dat /mnt/data1tb/bioenergy/allfiles2/bioenergy_SSP1_only.spp bioenergy_SSP1_only/output.txt 0.0 0 1.0 1

wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/bioenergy/twofiles/nogov.dat /mnt/data1tb/bioenergy/twofiles/biod_bioen_positive.spp community_level_positive/output.txt 0.0 0 1.0 1


wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/bioenergy/allfiles3/nogov.dat /mnt/data1tb/bioenergy/allfiles3/bioenergy_SSP1_conflicts.spp bioenergy_biodiv_positive_cropped_rescaled/output.txt 0.0 0 1.0 1



# Scenario 2: all other birds
#wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/noadmu.dat /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/otherbirds_2.spp raptors/output.txt 0.0 0 1.0 1

# Scenario 3: herbivores
#wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/noadmu.dat /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/herbivores_3.spp herbivores/output.txt 0.0 0 1.0 1

# Scenario 4: invertivores
#wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/noadmu.dat /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles/invertivores_4.spp invertivores/output.txt 0.0 0 1.0 1


# Run without antartica
#cd /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/

#wine '/home/marco/.wine/drive_c/Program Files/zonation 4.0.0rc1_compact/bin/zig4.exe' -r /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles1/noadmu.dat /mnt/data1tb/Dropbox/Andrea/surrogacy/rasters_surrogacy/allfiles1/raptors_1.spp raptors_noant/output.txt 0.0 0 1.0 1

