###################################
# part 1: exclude coastal areas
##################################

cd /mnt/data1tb/bioenergy/allfiles

#---- clip using world vector robinson

for i in $(ls *.tif);do all files

# only missing files
#for i in $(diff -rq /mnt/data1tb/bioenergy/allfiles/ /mnt/data1tb/bioenergy/allfiles1/ | grep Only | awk '{print $4}' | grep .tif);do

gdalwarp -of GTiff -tr 50000.0 -50000.0 -tap -cutline /mnt/data1tb/bioenergy/world_rob.shp -cl world_rob -crop_to_cutline $i /mnt/data1tb/bioenergy/output_file.vrt

gdal_translate -co compress=LZW /mnt/data1tb/bioenergy/output_file.vrt /mnt/data1tb/bioenergy/allfiles1/${i}

rm /mnt/data1tb/bioenergy/output_file.vrt

done

#----  process got interrupted so quick fix

# if file size == 0 print file name
#ls -lh |  awk '$5==0 {print $5,$9}'

# remove crappy files
#for i in $(ls -lh |  awk '$5==0 {print $9}');do
#    rm $i
#done

# list files only (!!) present in allfiles directory
#diff -rq allfiles allfiles1 | grep Only | awk '{print $4}'
# q = brief report flag about differences

#---- copy spp file + dat file
cp biodiversity_only.spp /mnt/data1tb/bioenergy/allfiles1/ 
cp nogov.dat /mnt/data1tb/bioenergy/allfiles1/ 
#---- substitute path in spp file
sed -i 's/allfiles/allfiles1/g' /mnt/data1tb/bioenergy/allfiles1/biodiversity_only.spp


##################################################
# part 2: clip species rasters to to Anna's raster
##################################################

# create mask (for earlier steps refer to R script)
r.in.gdal in=./data/bioen_landarea.tif out=bioen1 --o
r.mapcalc 'bioen2 = int(bioen1)+1' --o 

# bioenergy layers
r.in.gdal in=/mnt/data1tb/bioenergy/allfiles1/Abeillia_abeillei_birds.tif out=area_mask --o
g.region raster=area_mask -p
r.mask raster=bioen2 maskcats=1

# export bioenergy rasters
for i in $(ls /mnt/data1tb/Dropbox/AnnaRepo/project/data/bioen_tif/*.tif);do
   # import in grass
   r.in.gdal in=$i out=tmp --o
   r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles2/$(basename $i) createopt="COMPRESS=LZW"  --o
   g.remove type=raster name=tmp -f
done

# clip all rasters to same extent and same pixels
for i in $(ls *.tif);do
    r.in.gdal in=$i out=tmp --o
    r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles2/${i} createopt="COMPRESS=LZW" type=Int16 --o
    g.remove type=raster name=tmp -f
done


# clip all rasters to same extent and same pixels
for i in $(ls *.tif);do
    r.in.gdal in=$i out=tmp --o
    r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles3/${i} createopt="COMPRESS=LZW" type=Int16 --o
    g.remove type=raster name=tmp -f
done


# check whether all files contain 1
rm -f /mnt/data1tb/bioenergy/check0s
for i in $(ls *.tif);do
    gdalinfo -mm $i | grep Min/Max | cut -d'=' -f2 | awk -v my_var=$i '{print $0","my_var}' >> /mnt/data1tb/bioenergy/check0s
done
	
# remove rasters that contain only 0s
for i in $(awk -F',' '{print $1+$2","$3}' check0s | awk -F',' '$1==0 {print $2}');do
    echo $i
    rm ./allfiles3/${i}
done


# remove unwanted files
for i in $(ls | grep ecoregion);do
    echo $i
    rm $i
done

for i in $(ls | grep -v 'birds\|mammals\|reptiles\|amphibians\|RCP');do
    echo $i
    rm $i
done

cp ./allfiles1/nogov.dat ./allfiles3/

#########################################
# Crop files to areas where bioenergy > 0
#########################################

cd /mnt/data1tb/bioenergy/allfiles2

# Scenario SSP1

# create mask
r.in.gdal in=/mnt/data1tb/Dropbox/AnnaRepo/project/data/mask.tif
 out=mask_nodata -o
r.mapcalc 'mask_nodata1 = int(mask_nodata)' --o
r.mask raster=mask_nodata1 maskcats=1


for i in $(ls *.tif | grep -v SSP);do
    r.in.gdal in=$i out=tmp --o -o
    r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles_SSP2/$(basename $i) createopt="COMPRESS=LZW" --o type=Int16 --o
    g.remove type=raster name=tmp -f
done

r.mask -r


#---- Scenario SSP2

r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP2_2050_bio.tif out=tmp --o -o
r.null map=tmp setnull=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP2_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1


# create masked files
for i in $(ls *.tif | grep -v SSP);do
    r.in.gdal in=$i out=tmp --o -o
    r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles_SSP2/$(basename $i) createopt="COMPRESS=LZW" --o type=Int16 --o
    g.remove type=raster name=tmp -f
done

# check whether all files contain 1
rm -f /mnt/data1tb/bioenergy/check0s
cd /mnt/data1tb/bioenergy/allfiles_SSP2/

for i in $(ls *.tif);do
    echo $i
    gdalinfo -mm $i | grep Min/Max | cut -d'=' -f2 | awk -v my_var=$i '{print $0","my_var}' >> /mnt/data1tb/bioenergy/check0s
done

## remove files containing 0s
cd ..

cat /mnt/data1tb/bioenergy/check0s

# remove rasters that contain only 0s
for i in $(awk -F',' '{print $1+$2","$3}' check0s | awk -F',' '$1==0 {print $2}');do
    echo $i
    rm ./allfiles_SSP2/${i}
done

cd twofiles_full_cropped/
cp RCP19_SSP2_2050_bio.tif /mnt/data1tb/bioenergy/allfiles_SSP2/
cp nogov.dat /mnt/data1tb/bioenergy/allfiles_SSP2/

r.mask -r

#---- Scenario SSP5

r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif out=tmp --o -o
r.null map=tmp setnull=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1


# create masked files
for i in $(ls *.tif | grep -v SSP);do
    r.in.gdal in=$i out=tmp --o -o
    r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/allfiles_SSP5/$(basename $i) createopt="COMPRESS=LZW" --o type=Int16 --o
    g.remove type=raster name=tmp -f
done

# check whether all files contain 1
rm -f /mnt/data1tb/bioenergy/check0s
cd /mnt/data1tb/bioenergy/allfiles_SSP5/

for i in $(ls *.tif);do
    echo $i
    gdalinfo -mm $i | grep Min/Max | cut -d'=' -f2 | awk -v my_var=$i '{print $0","my_var}' >> /mnt/data1tb/bioenergy/check0s
done

## remove files containing 0s
cd ..

#cat /mnt/data1tb/bioenergy/check0s

# remove rasters that contain only 0s
for i in $(awk -F',' '{print $1+$2","$3}' check0s | awk -F',' '$1==0 {print $2}');do
    echo $i
    rm ./allfiles_SSP5/${i}
done

cd twofiles_full_cropped/
cp RCP19_SSP5_2050_bio.tif /mnt/data1tb/bioenergy/allfiles_SSP5/
cp nogov.dat /mnt/data1tb/bioenergy/allfiles_SSP5/



# convert files
r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP1_2050_bio.tif out=tmp --o -o
r.null map=tmp setnull=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP1_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1
r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/plain_rich.tif out=tmp --o -o
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/rich_SSP1.tif --o


r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP2_2050_bio.tif out=tmp --o -o
r.null map=tmp setnull=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP2_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1
r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/plain_rich.tif out=tmp --o -o
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/rich_SSP2.tif --o
r.mask -r

r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif out=tmp --o -o
r.null map=tmp setnull=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1
r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/plain_rich.tif out=tmp --o -o
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/rich_SSP5.tif --o
r.mask -r


# crop bioenergy files to that one who has the biggest extent (SSP5)

# create mask from SSP5
r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif out=tmp --o -o
#r.null map=tmp setnull=0 
#r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP5_2050_bio.tif --o
r.mapcalc 'mask = int(tmp/tmp)' --o
r.mask raster=mask maskcats=1
#r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/plain_rich.tif out=tmp --o -o
#r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/rich_SSP5.tif --o
#r.mask -r


r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP1_2050_bio.tif out=tmp --o -o
r.null map=tmp null=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/new/RCP19_SSP1_2050_biov.tif --o


r.in.gdal in=/mnt/data1tb/bioenergy/twofiles_full_cropped/RCP19_SSP2_2050_bio.tif out=tmp --o -o
r.null map=tmp null=0 
r.out.gdal in=tmp out=/mnt/data1tb/bioenergy/twofiles_full_cropped/new/RCP19_SSP2_2050_bio.tif --o


# copy files to the right folders
cd twofiles_full_cropped/new
cp RCP29_SSP1_2050_bio.tif ./allfiles_SSP1_1
