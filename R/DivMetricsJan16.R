# load required libraries
library(raster)
library(fields)
library(doBy)
library(stringr)
library(maptools)
library(RColorBrewer)
library(xtable)
library(PhyloMeasures)
library(picante)
library(FD)

world<-readShapePoly("/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/feb15/gridgrassex/gridfeb15.shp")
# file needed to create raster grid-ricordarsi di cambiare la directory
grid<-read.table(file="/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/islandsgridall1/gridall1noantarctica")
colnames(grid)<-c("east","north","cat")
dat<-read.csv("/mnt/data1tb/Dropbox/HistFunc/dataforanalyses/fdenv110914.csv")
biomes<-read.csv(file="/mnt/data1tb/Dropbox/HistFunc/envdata/ecoregionsaugust/ecoregionsOct15.csv")


### Calculate FD based on different species pool (realm)

###############################
# Functional diversity mammals
###############################

mamm<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/speciescsvgridall1/mamm.csv")
mamm<-reshape(mamm,idvar=c("cat"),v.names=c("pres"),timevar=c("species"),direction="wide")
mamm[is.na(mamm)] <- 0

names1<-str_split(names(mamm)[-1],"pres.",n=2)
names2<-do.call("rbind",names1)
names3<-str_split_fixed(names2[,2]," ",2)
names4<-paste(names3[,1],names3[,2],sep="_")
colnames(mamm)[2:5264]<-names4

mamm<-merge(mamm,biomes)


traits<-read.csv("/mnt/data1tb/Dropbox/HistFunc/traitdata/wilman14/traitfinalbats.csv")

# create table with lookup names
lookup<-data.frame(species=names(mamm)[-c(1,5265,5266)])
colnames(traits)[1]<-"species"
traits1<-merge(traits,lookup)
row.names(traits1)<-traits1$species
traits1$BodyMass.Value<-log(traits1$BodyMass.Value)

mammlookup<-c("cat",as.character(traits1$species),"biome","realm")
mamm<-mamm[,mammlookup]

#--- create four traits using pcoa
distg<-gowdis(traits1[4:18])

ftree<-hclust(distg,"ave")

ftree1<-as.phylo(ftree)



biomrealm<-unique(mamm[5195:5196])

results<-NULL

for (i in 1:dim(biomrealm)[1]){

print(i)

# realm
realmtmp<-as.character(biomrealm[i,]$realm)
print(realmtmp)

# biome
biomtmp<-as.character(biomrealm[i,]$biome)
print(biomtmp)

# tmp realm
tmp<-subset(mamm,realm==realmtmp[1])

# tmp realm
tmp1<-subset(tmp,biome==biomtmp[1])


# verify how many non-zero cells           
colsums<-colSums(tmp1[2:5194])
coln<-names(colsums[colsums > 0])
tmp2<-tmp1[,coln]

# subset functional tree 
ftreetmp<-prune.sample(samp=as.matrix(tmp2),phylo=ftree1)
# --- calculate functional richness
FRick<-pd.query(tree=ftreetmp,matrix=as.matrix(tmp2),is.standardised=TRUE)
# store results
df<-data.frame(tmp1[1],FRick)
# bind results to data
results.tab<-df
results<-rbind(results,results.tab) 
}

mammFD<-merge(grid,results)
colnames(mammFD)[4]<-"FDm"

write.csv(mammFD,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/mammFDJan16.csv",row.names=F)

FDm<-rasterFromXYZ(mammFD[,c("east","north","FDm")])

#################################
# Functional Diversity birds
##################################

missing<-read.csv("/mnt/data1tb/Dropbox/FDTD/birdsphylotips/missingonlyanna1.csv")
birds<-read.csv("/mnt/data1tb/Dropbox/FDTD/birdsFDfiles/birdswideALL.csv")
traits<-read.csv("/mnt/data1tb/Dropbox/FDTD/birdsFDfiles/traitbirdsALL.csv")
row.names(traits)<-traits$species
traits$BodyMass.Value<-log(traits$BodyMass.Value)
birds<-merge(birds,biomes)


#--- create bird functional tree
distg<-gowdis(traits[4:22])
ftree<-hclust(distg,"ave")
ftree1<-as.phylo(ftree)


biomrealm<-unique(birds[9503:9504])

results<-NULL

for (i in 1:dim(biomrealm)[1]){

print(i)

# realm
realmtmp<-as.character(biomrealm[i,]$realm)
print(realmtmp)

# biome
biomtmp<-as.character(biomrealm[i,]$biome)
print(biomtmp)

# tmp realm
tmp<-subset(birds,realm==realmtmp[1])

# tmp realm
tmp1<-subset(tmp,biome==biomtmp[1])


# verify how many non-zero cells           
colsums<-colSums(tmp1[2:9502])
coln<-names(colsums[colsums > 0])
tmp2<-tmp1[,coln]

# subset functional tree 
ftreetmp<-prune.sample(samp=as.matrix(tmp2),phylo=ftree1)
# --- calculate functional richness
FRick<-pd.query(tree=ftreetmp,matrix=as.matrix(tmp2),is.standardised=TRUE)
# store results
df<-data.frame(tmp1[1],FRick)
# bind results to data
results.tab<-df
results<-rbind(results,results.tab) 
}


birdsFD<-merge(grid,results)
colnames(birdsFD)[4]<-"FDb"
write.csv(birdsFD,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/birdsFDJan16.csv",row.names=F)

FDb<-rasterFromXYZ(birdsFD[,c("east","north","FDb")])

#########################################
# Create raster files for zonation
#########################################

# get taxonomic diversity file
grid<-read.table(file="/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/islandsgridall1/gridall1noantarctica")
colnames(grid)<-c("east","north","cat")

# read in files
FDb<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/birdsFD.csv")
FDm<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/mammFD.csv")
#PDb<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/PDb1000.csv")
#PDm<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Octvalues/PDm.csv")
rescale <- function(x) (x-min(x))/(max(x) - min(x)) * 100
FDb$FDb<-rescale(FDb$FDb)
FDm$FDm<-rescale(FDm$FDm)
#PDm$PDm<-rescale(PDm$PDm)
#PDb$PDm<-rescale(PDm$PDm)

# merge files
FDb1<-merge(FDb,grid,all.y=TRUE)
FDb1$FDb<-replace(FDb1$FDb,is.na(FDb1$FDb),0)
FDm1<-merge(FDm,grid,all.y=TRUE)
FDm1$FDm<-replace(FDm1$FDm,is.na(FDm1$FDm),0)

# rasters
FDbr<-rasterFromXYZ(FDb1[,c("east","north","FDb")])
FDmr<-rasterFromXYZ(FDm1[,c("east","north","FDm")])


# write rasters

writeRaster(FDbr,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/experimentFD/FDb.asc",NAflag=-9999,overwrite=TRUE)
writeRaster(FDmr,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/experimentFD/FDm.asc",NAflag=-9999,overwrite=TRUE)

#writeRaster(rr,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/experimentFD/FDm1.asc",NAflag=-9999,overwrite=TRUE)

#%%%%%%%%%%%% Correlation matrix between ecosystem services and biodiversity facets %%%%%%%%%%

# read in ES data
agr<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/ESold/landcost.asc")
agrdf<-data.frame(coordinates(agr),agr=getValues(agr))
agrdf1<-na.exclude(agrdf)
colnames(agrdf1)<-c("east","north","agr")


livecarb<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/ESold/livecarbon.asc")
livecarbdf<-data.frame(coordinates(livecarb),livecarb=getValues(livecarb))
livecarbdf1<-na.exclude(livecarbdf)
colnames(livecarbdf1)<-c("east","north","livecarb")

waterprov<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/ESold/waterprov.asc")
waterprovdf<-data.frame(coordinates(waterprov),livecarb=getValues(waterprov))
waterprovdf1<-na.exclude(waterprovdf)
colnames(waterprovdf1)<-c("east","north","water")


pollination<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/landcost.asc")
pollinationdf<-data.frame(coordinates(pollination),livecarb=getValues(pollination))
pollinationdf1<-na.exclude(pollinationdf)
colnames(pollinationdf1)<-c("east","north","pollination")


grassland<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/livenew.asc")
grasslanddf<-data.frame(coordinates(grassland),livecarb=getValues(grassland))
grasslanddf1<-na.exclude(grasslanddf)
colnames(grasslanddf1)<-c("east","north","grassland")


## biodiversity metrics
dat<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/paperesults/resultsAug15/matrixcorr.csv")

## merge biodiversity metrics with es service data
dat1<-merge(dat,waterprovdf1)
dat2<-merge(dat1,livecarbdf1)
dat3<-merge(dat2,grasslanddf1)
dat4<-merge(dat3,pollinationdf1)


# correlation matrix
cormat<-cor(dat4[4:13],method="spearman")
cormat<-round(cormat,digits=2)

upper<-cormat
upper[upper.tri(cormat)]<-""
upper<-as.data.frame(upper)

# print table on screen (copy and paste into latex file)
print(xtable(upper), type="latex")


#### Ground water recharge-create layer
# create grid
grid<-read.table(file="/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/islandsgridall1/gridall1noantarctica")
colnames(grid)<-c("east","north","cat")
gridr<-rasterFromXYZ(grid)
writeRaster(gridr,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/grecharge/grid.asc",NAflag=-9999,overwrite=TRUE)

# read into GRASS (resolution 20km)
system("r.in.gdal in=/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/grecharge/grid.asc out=grid -o --o")



# extract stats
system("g.region res=110000 -a")
system("r.mapcalc 'gridint = int(grid)'")
system("r.stats -An in=gridint,groundwater > /mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/grecharge/stats20km")


# re-read into R
grid<-read.table(file="/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/islandsgridall1/gridall1noantarctica")
colnames(grid)<-c("east","north","cat")
gwcharge<-read.table("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/grecharge/stats20km")
colnames(gwcharge)<-c("cat","waterprov")
gwcharge1<-aggregate(waterprov~cat,data=gwcharge,FUN=mean)
gwcharge2<-merge(gwcharge1,grid,all.y=TRUE)
gwcharge2$waterprov<-replace(gwcharge2$waterprov,is.na(gwcharge2$waterprov),0)
gw<-rasterFromXYZ(gwcharge2[,c("east","north","waterprov")])
writeRaster(gw,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/grecharge/gwcharge.asc",NAflag=-9999,overwrite=TRUE)

## Pollination

poll<-raster("/home/marco/Desktop/pollination/total/pollValue_ppp.tif")
ml<-"+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs"
poll1<-projectRaster(poll, crs=ml,over=T,res=10000)
writeRaster(poll1,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/pollination10km.asc",NAflag=-9999,overwrite=TRUE)

# import pollination map
system("g.region res=10000 -a")
system("r.in.gdal in=/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/pollination/pollination10kmmolle.asc out=pollination10km -o --o")

# extract stats for pollination map
system("r.stats -An in=gridint,pollination10km > /mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/pollination/stats10km")

##############################
# Pollination raster layer
##############################
grid<-read.table(file="/mnt/data1tb/Dropbox/carbonconservation/mollweidefiles/grid/islandsgridall1/gridall1noantarctica")
colnames(grid)<-c("east","north","cat")
poll<-read.table("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/pollination/stats10km")
colnames(poll)<-c("cat","pollination")
poll1<-aggregate(pollination~cat,data=poll,FUN=mean)
poll2<-merge(poll1,grid,all.y=TRUE)
poll2$pollination<-replace(poll2$pollination,is.na(poll2$pollination),0)

pollr<-rasterFromXYZ(poll2[,c("east","north","pollination")])
writeRaster(pollr,filename="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/pollination/landcost.asc",NAflag=-9999,overwrite=TRUE)

agr<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/landcost.asc")
agrdf<-data.frame(coordinates(agr),agr=getValues(agr))
agrdf1<-na.exclude(agrdf)


dd<-merge(agrdf1,poll2)

#####################
# Figures 
###################

#%%%%% Zonation ranking


world<-readShapePoly("/mnt/data1tb/Dropbox/carbonconservation/countries/molleiweide/molleiweide.shp")


testo<-c("0.00-0.10","0.10-0.20","0.20-0.30","0.30-0.40","0.40-0.50","0.50-0.60","0.60-0.70","0.70-0.80","0.80-0.90",
"0.90-1.00")
mypal<-rev(brewer.pal(10,"Spectral"))

# map
all<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/allJan16/output.rank.compressed.tif")
es<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/esJan16/output.rank.compressed.tif")
bio<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/bioJan16/output.rank.compressed.tif")
td<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/TDJan16/output.rank.compressed.tif")
fd<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/FDJan16/output.rank.compressed.tif")
pd<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/PDJan16/output.rank.compressed.tif")

alldf<-na.exclude(data.frame(coordinates(all),value=getValues(all)))
alldf$type<-"Biodiversity & Ecosystem Services"
esdf<-na.exclude(data.frame(coordinates(es),value=getValues(es)))
esdf$type<-"Ecosystem services"
tddf<-na.exclude(data.frame(coordinates(td),value=getValues(td)))
tddf$type<-"Taxonomic diversity"
fddf<-na.exclude(data.frame(coordinates(fd),value=getValues(fd)))
fddf$type<-"Functional Diversity"
pddf<-na.exclude(data.frame(coordinates(pd),value=getValues(pd)))
pddf$type<-"Phylogenetic Diversity"
biodf<-na.exclude(data.frame(coordinates(bio),value=getValues(bio)))
biodf$type<-"Biodiversity combined"


allrdf<-rbind(alldf,esdf,tddf,fddf,pddf,biodf)

allrdf$type<-factor(as.factor(allrdf$type),levels(as.factor(allrdf$type))[c(6,4,5,1,3,2)])




d<-ggplot(data = allrdf, aes(x = x, y = y, fill = value)) +geom_tile() + scale_fill_gradientn(colours = mypal, na.value = NA) +coord_fixed(1.1)+labs(x ="",y="")+theme(axis.text.x = element_blank(),axis.text.y=element_blank(),axis.ticks = element_blank())+theme(plot.margin=unit(c(0,0,0,0),"mm"))+theme(legend.title=element_blank())+theme(panel.background = element_rect(fill = 'azure4', colour = NA))+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+facet_wrap(~ type, ncol=2)+theme(strip.text.x = element_text(size=12, face="bold"),strip.background = element_rect(fill="#CCCCFF"))




ggsave(filename="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig1new.eps",plot=d,width=10,height=9,units="in",dpi=7000)



##### Normal solution


setEPS()
postscript(file="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig2.eps",width=8,height=6,pointsize=10)
par(mfrow=c(3,2),bg="gray")
par(mai=c(0,0.25,0,0.1),oma=c(2,4,2,1),xpd=NA)
image(td,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
image(fd,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
image(pd,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
image(bio,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
image(es,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
image(all,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.1)
text(labels="a)",x=-49147990,y=47596576,cex=1.5,xpd=NA)
text(labels="b)",x=-11128361,y=47596576,cex=1.5,xpd=NA)
text(labels="c)",x=-49147990,y=27896576,cex=1.5,xpd=NA)
text(labels="d)",x=-11128361,y=27896576,cex=1.5,xpd=NA)
text(labels="e)",x=-49147990,y=8700711,cex=1.5,xpd=NA)
text(labels="f)",x=-11128361,y=8700711,cex=1.5,xpd=NA)
legend(x=-63656443,y=51959187,legend=testo,fill=mypal,cex=0.9,xpd=NA,bty = "n")
dev.off()

## three maps bio, all, 
setEPS()
postscript(file="/mnt/data1tb/Dropbox/mypapers/drafts/naturecommunications/latex/Fig1.eps",width=6,height=4,pointsize=10)
par(mfrow=c(3,1),mai=c(0,0,0,0),oma=c(0,0,0,0),xpd=NA)
image(bio,col=rev(brewer.pal(6,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.3)
image(es,col=rev(brewer.pal(6,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.3)
image(all,col=rev(brewer.pal(6,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
#plot(world,add=T,lwd=0.3)
text(labels="a)",x=-49147990,y=27105881,cex=1.5,xpd=NA)
text(labels="b)",x=-11128361,y=27105881,cex=1.5,xpd=NA)
text(labels="c)",x=-49147990,y=8285948,cex=1.5,xpd=NA)
legend(x=-66147990,y=30105881,legend=testo,fill=rev(brewer.pal(10,"Spectral")),cex=1,xpd=NA,bty = "n")
dev.off()




setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/figuresJan16")


dd<-all-es
image(dd,col=rev(brewer.pal(10,"Spectral")),axes=FALSE,asp=1,xlab="",ylab="")
plot(dd,col=rev(brewer.pal(10,"Spectral")))


#######################################
# Create files for sensitivity analysis
#######################################
templ<-read.table("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/all.spp",header=FALSE) solution based on TD
# insert 1 only if using SR in the analyses!!!!!
templ$V1<-1
templ$name<-c("carb","wate","poll","gras","PD","PD","FD","FD","SR","SR")
templ$group<-c(1,2,3,4,5,5,6,6,7,7)
templ$nametaxon<-c("carb","wate","poll","gras","PDb","PDm","FDb","FDm","SRm","SRb")


group.l<-unique(templ$group)

w<-c(3,6,12,24)

# store results
info<-NULL
batfile<-NULL

for (i in 1:length(group.l)){

# extract nth row
tmpr<-subset(templ,group==group.l[i])

# take everything apart from nth row
tmpr1<-templ[-as.numeric(row.names(tmpr)),]

    for (x in 1:length(w)){
    
    df.tab<-NULL
    df1.tab<-NULL

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#%%%%%%%%%% if else statement
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#if(group.l[i]==7){

# change weight in nth row
#tmpr$V1<-0

#} else {

# change weight 
tmpr$V1<-w[x]
# set SR to 0
#tmprSR<-tmpr1[tmpr1$nametaxon %in% c("SRb","SRm"), ]
#tmprSR$V1<-0
#tmprSRd<-tmpr1[!tmpr1$nametaxon %in% c("SRb","SRm"), ]
#tmpr1<-rbind(tmprSR,tmprSRd)


#}

# rebind
spp<-rbind(tmpr,tmpr1)
spp1<-spp[1:6]


# spp filename
filen<-paste("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/all_",unique(tmpr$name),"_",w[x],".spp",sep="")

# write out
write.table(spp1,filen,row.names=F,quote=F,col.names=F)

# paste again
batfileinfo<-paste("call zig3.exe -r asciifiles/nogov.dat asciifiles/all_",unique(tmpr$name),"_",w[x],".spp ","all",unique(tmpr$name),"",w[x],"/output.txt 0.0 0 1.0 1",sep="")

path<-paste("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/all",unique(tmpr$name),w[x],"/",sep="")


# attach results
df<-data.frame(code1=paste("all_",unique(tmpr$name),"_",w[x],sep=""),code=paste(unique(tmpr$name),w[x],sep=""),path)

df1<-data.frame(batfileinfo)

df.tab<-df
df1.tab<-df1
info<-rbind(info,df.tab)
batfile<-rbind(batfile,df1.tab)

}
}


#write.csv(info,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/tmpfiles/infonoSR.csv",row.names=F)


write.table(batfile,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/Feb16sens.bat",row.names=F,quote=F,col.names=F)

##############################
# Post-processing top fraction
##############################

#info<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/tmpfiles/infonoSR.csv")

infocode<-as.character(info$path)

for (i in 1:length(infocode)){
setwd(infocode[i])
system("sed '1,3d' output.curves.txt > tmp")
}


results<-NULL

for (i in 1:dim(info)[1]){

final.tab<-NULL

# subset correct row
rowtmp<-info[i,]

# get info on the order
filepath<-paste("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/",rowtmp$code1,".spp",sep="")

tmporder<-read.table(filepath,header=F)
tmporder$ordertmp<-1:10

# match to group info
orderinfo<-merge(tmporder[6:7],templ[6:9])
library(doBy)

# read in tmp file
pathcurves<-paste(rowtmp$path,"tmp",sep="")
curves<-read.delim(pathcurves,header=F,sep="")

# sort out order info
ordercurves<-orderBy(~ordertmp,data=orderinfo)
curves1<-curves[8:17]

colnames(curves1)<-ordercurves$nametaxon

# extract right columns, subset rows and take column and row means
groups.l<-unique(ordercurves$group)
# store results
#-------------------

prop.results<-NULL

for (x in 1:length(groups.l)){

prop.tab<-NULL

# extract group info
groupinfo<-subset(ordercurves,group==groups.l[x])
curves2<-curves1[,groupinfo$nametaxon]
curves2<-as.data.frame(curves2)

# extract top 17% percentage
top17position<-round((dim(curves2)[1]*83)/100)
top17<-as.numeric(curves2[top17position,])
top17<-mean(top17)

# put results together
dfprop<-data.frame(feature=unique(groupinfo$name),proportion=top17)

prop.tab<-dfprop
prop.results<-rbind(prop.results,prop.tab)

}

# add info on weight and save
finaldf<-data.frame(prop.results,weight=rowtmp$code1)
final.tab<-finaldf
results<-rbind(results,final.tab)

}


#write.csv(results,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/tmpfiles/propSRrule2.csv",row.names=F)

results<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/tmpfiles/propSRrule2.csv")


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Create data frame for processing
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

############################### 
# read in files as required!
###############################
# reshape data frame
library(stringr)
weights<-str_split_fixed(results$weight, "_", 3)
weights<-as.data.frame(weights)
write.csv(weights,file="weights.csv",row.names=F)
weights<-read.csv("weights.csv")
system("rm weights.csv")
colnames(weights)[2:3]<-c("feature","weight1")
results1<-data.frame(results,weights[3])


results2<-orderBy(~feature,data=results1)
results2$yaxislab<-paste(results2$feature,results2$weight1,sep="-")
results2$yaxis<-1:dim(results2)[1]
#results3<-results2[,c("yaxis","proportion","feature")]


#results.w<-reshape(results3,idvar=c("yaxis"),v.names=c("proportion"),timevar=c("feature"),direction="wide")

#write.csv(results2,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/topfraction/topfractionJan.csv",row.names=F)


# store results in a different format
z<-matrix(, nrow = 28, ncol = 7)

results2.l<-splitBy(~feature+weight1,data=results2)

for (i in 1:28){

z[i,]<-results2.l[[i]]$proportion

}

# transpose matrix
z1<-t(z)
ylabs<-unique(results2$yaxislab)
colnames(z1)<-ylabs
rownames(z1)<-c("carb","wat","poll","grass","PD","FD","SR")

colnames(z)<-c("carb","wat","poll","grass","PD","FD","SR")
rownames(z)<-ylabs


# melt dataset
library(reshape)
z2<-melt(z1)

# create labels for y axis
X1n<-as.factor(c("Carbon","Water","Pollination","Grassland","PD","FD","SR"))

X1n<-factor(X1n,levels(X1n)[c(6,2,4,1,3,5,7)])
X1df<-data.frame(X1=unique(z2$X1),X1n=c("Carbon","Water","Pollination","Grassland","PD","FD","SR"))
X1df$X1n<-factor(X1df$X1n,levels(X1df$X1n)[c(6,2,4,1,3,5,7)])
z3<-merge(z2,X1df)

# create labels for x axis
X2=unique(z2$X2)
X2n<-c(paste(rep("Carbon (",4),c(3,6,12,24),")",sep=""),paste(rep("FD (",4),c(3,6,12,24),")",sep=""),
paste(rep("Grassland (",4),c(3,6,12,24),")",sep=""),paste(rep("PD (",4),c(3,6,12,24),")",sep=""),
paste(rep("Pollination (",4),c(3,6,12,24),")",sep=""),paste(rep("SR (",4),c(3,6,12,24),")",sep=""),
paste(rep("Water (",4),c(3,6,12,24),")",sep=""))


X2n<-as.factor(X2n)

# re-arrange levels of the factor correctly
arr<-function(v){
tmpr<-c(v[3],v[4],v[1],v[2])
return(tmpr)
}

v<-c(arr(21:24),arr(5:8),arr(13:16),arr(1:4),arr(9:12),arr(17:20),arr(25:28))

X2n<-factor(X2n,levels(X2n)[v])

x2df<-data.frame(X2,X2n)

# final data frame
z4<-merge(x2df,z3)



library(ggplot2)
# this one works!

pg1<- ggplot(z4, aes(X2n,X1n, fill = value))+scale_fill_gradientn(values=c(seq(from=0,to=1,length.out=11)),colours=c(rev(brewer.pal(11, "RdBu"))))+geom_tile() + theme(axis.text.x = element_text(size=7.5,lineheight = 0.9, hjust = 0.8, angle = 45,colour = "black"),axis.text.y=element_text(size=11,colour = "black"),axis.title=element_text(size=16,vjust = 4),axis.ticks = element_blank())+ theme(aspect.ratio = 1)+labs(fill="")+labs(x = "Weight",y="Feature")+theme(panel.background = element_blank(),panel.border=element_blank())

# save plot
ggsave(filename="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig3SR.eps",plot =pg1,width=8,height=8)

##################################
# Top-fraction for basic scenarios
#################################

# delete first three lines
setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/allJan16")
system("sed '1,3d' output.curves.txt > tmp")  

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/esJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/bioonlyJan16")
system("sed '1,3d' output.curves.txt > tmp")


all<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/allJan16/tmp",header=F,sep="")   
es<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/esJan16/tmp",header=F,sep="")   
bio<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/bioonlyJan16/tmp",header=F,sep="")   

list.df<-list(bio,es,all)
names(list.df)<-c("bio","es","all")

library(reshape)

results<-vector("list",3)


for (x in 1:3){

# extract data frame
tmp<-list.df[[x]]

# extract top 17% percentage
top17position<-round((dim(tmp)[1]*83)/100)
top17<-tmp[top17position,]

# data frame with results
df<-data.frame(Carbon=top17[,8],Water=top17[,9],Pollination=top17[,10],Grassland=top17[,11],PD=rowMeans
(top17[,12:13]),FD=rowMeans(top17[,14:15]),TD=rowMeans(top17[,16:17]),label=names(list.df)[x])
#data.frame(Carbon=top17[,8],Water=top17[,9],Pollination=top17[,10],Grassland=top17[,11],PD1=top17##[,12],PD2=top17[,13],FD1=top17[,14],FD2=top17[,15],SR1=top17[,16],SR2=top17[,17])

#df1<-melt(df,id.vars=c("label"))[2:3]
#colnames(df1)[2]<-names(list.df)[x]

df1<-df

results[[x]]<-df1

}

results1<-do.call("rbind",results)

# insert extra row
v<-rep(0.6,8)
names(v)<-names(results1)
vdf<-t(data.frame(v))
v1<-rep(0,8)
names(v1)<-names(results1)
v1df<-t(data.frame(v1))
results2<-rbind(vdf,v1df,results1)


radarfill<-c("dodgerblue4","darkorange2","forestgreen")
text<-c("Biodiversity only","Ecosystem services only","Biodiversity and ecosystem services")
library(fmsb)

setEPS()
postscript(file="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Radar.eps",width=7,height=5,pointsize=10)
par(mar=c(5.1,4.1,4.1,6),mai=c(0,0,0,1.5))
radarchart(results2[1:7], axistype=1, seg=4, plty=1,cglcol="grey",axislabcol="black",cglty=1,plwd=2.5,pty=32,caxislabels=c("0", "0.15", "0.30","0.45","0.60"),centerzero=TRUE,calcex=0.9,cglwd=1.2,pcol=c("dodgerblue4","darkorange2","forestgreen"),vlcex=1.2)
legend(x=0.7069859,y=-0.5350104,legend=text,lwd=3,col=radarfill,cex=1,xpd=NA,bty = "n")
dev.off()



###########################
# Performance curves
##########################
#all<-read.csv("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/alltmp.csv",header=F)
#write.table(all,file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/all.spp",row.names=F,quote=F,col.names=F)


# delete first three lines
setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/allJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/esJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/bioonlyJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/FDJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/PDJan16")
system("sed '1,3d' output.curves.txt > tmp")

setwd("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/TDJan16")
system("sed '1,3d' output.curves.txt > tmp")


all<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/allJan16/tmp",header=F,sep="")   
es<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/esJan16/tmp",header=F,sep="")   
bio<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/bioonlyJan16/tmp",header=F,sep="")   
FD<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/FDJan16/tmp",header=F,sep="")
PD<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/PDJan16/tmp",header=F,sep="")
TD<-read.delim("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/TDJan16/tmp",header=F,sep="")


######################
## all in one figure
######################
#%%%%%%%%%%%%%%%%%bio
plot(rev(bio[,1]),rowMeans(bio[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1.5,cex.lab=1,cex.main=1.2,xlab="",ylab=""
,cex.main=1.2)

lines(rev(bio[,1]),rowMeans(bio[,c(12,13)]),xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=3,type="l",lty=2)

lines(rev(bio[,1]),rowMeans(bio[,c(14,15)]),xlim=c(0,1),ylim=c(0,1),col="black",lwd=3,type="l",lty=2)

lines(rev(bio[,1]),rowMeans(bio[,c(16,17)]),xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=3,type="l",lty=2)

#%%%%%%%%%%%%%%% es
plot(rev(es[,1]),rowMeans(es[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1.5,cex.lab=1,cex.main=1.2,xlab="",ylab=""
,cex.main=1.2)


lines(rev(es[,1]),rowMeans(es[,c(12,13)]),xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=3,type="l",lty=2)

lines(rev(es[,1]),rowMeans(es[,c(14,15)]),xlim=c(0,1),ylim=c(0,1),col="black",lwd=3,type="l",lty=2)

lines(rev(es[,1]),rowMeans(es[,c(16,17)]),xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=3,type="l",lty=2)

#%%%%%%%%%%%%%%%% all
plot(rev(all[,1]),rowMeans(all[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1.5,cex.lab=1,cex.main=1.2,xlab="",ylab=""
,cex.main=1.2)

lines(rev(all[,1]),rowMeans(all[,c(12,13)]),xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=3,type="l",lty=2)

lines(rev(all[,1]),rowMeans(all[,c(14,15)]),xlim=c(0,1),ylim=c(0,1),col="black",lwd=3,type="l",lty=2)

lines(rev(all[,1]),rowMeans(all[,c(16,17)]),xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=3,type="l",lty=2)



par(mfrow=c(1,3))

plot(rev(bio[,1]),rowMeans(bio[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)

lines(rev(bio[,1]),rowMeans(bio[,c(12,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=3)

box(lwd=1,col="grey")

plot(rev(es[,1]),rowMeans(es[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)
box(lwd=1,col="grey")
lines(rev(es[,1]),rowMeans(es[,c(12,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=3)

plot(rev(all[,1]),rowMeans(all[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=3,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)

box(lwd=1,col="grey")
lines(rev(all[,1]),rowMeans(all[,c(12,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=3)
box(lwd=1,col="grey")
##########################
# Ggplot solution
#########################

## get data in the right format
library(reshape)
# TD
allTD<-data.frame(rev(TD[,1]),TD[8:11],PD=rowMeans(TD[,c(12,13)]),FD=rowMeans(TD[,c(14,15)]),TD=rowMeans(TD[,c(16,17)]))
colnames(allTD)[1:5]<-c("lost","carbon","water","pollination","grassland")
# FD
allFD<-data.frame(rev(FD[,1]),FD[8:11],PD=rowMeans(FD[,c(12,13)]),FD=rowMeans(FD[,c(14,15)]),TD=rowMeans(FD[,c(16,17)]))
colnames(allFD)[1:5]<-c("lost","carbon","water","pollination","grassland")
# PD
allPD<-data.frame(rev(PD[,1]),PD[8:11],PD=rowMeans(PD[,c(12,13)]),FD=rowMeans(PD[,c(14,15)]),TD=rowMeans(PD[,c(16,17)]))
colnames(allPD)[1:5]<-c("lost","carbon","water","pollination","grassland")
# ES
alles<-data.frame(rev(es[,1]),es[8:11],PD=rowMeans(es[,c(12,13)]),FD=rowMeans(es[,c(14,15)]),TD=rowMeans(es[,c(16,17)]))
colnames(alles)[1:5]<-c("lost","carbon","water","pollination","grassland")
# ALL
all<-data.frame(rev(all[,1]),all[8:11],PD=rowMeans(all[,c(12,13)]),FD=rowMeans(all[,c(14,15)]),TD=rowMeans(all[,c(16,17)]))
colnames(all)[1:5]<-c("lost","carbon","water","pollination","grassland")
# Bio
bio<-data.frame(rev(bio[,1]),bio[8:11],PD=rowMeans(bio[,c(12,13)]),FD=rowMeans(bio[,c(14,15)]),TD=rowMeans(bio[,c(16,17)]))
colnames(bio)[1:5]<-c("lost","carbon","water","pollination","grassland")



allTDm<-melt(allTD,id.vars=c("lost"))
allTDm$facet<-"Taxonomic diversity"

allFDm<-melt(allFD,id.vars=c("lost"))
allFDm$facet<-"Functional Diversity"

allPDm<-melt(allPD,id.vars=c("lost"))
allPDm$facet<-"Phylogenetic diversity"

allesm<-melt(alles,id.vars=c("lost"))
allesm$facet<-"Ecosystem services"

allm<-melt(all,id.vars=c("lost"))
allm$facet<-"Biodiversity & ecosystem services"

biom<-melt(bio,id.vars=c("lost"))
biom$facet<-"Biodiversity combined"



alldf<-rbind(allTDm,allFDm,allPDm,allesm,allm,biom)

alldf$facet<-factor(as.factor(alldf$facet),levels(as.factor(alldf$facet))[c(6,4,5,1,3,2)])


# change level names
levels(alldf$variable) <- c("Carbon", "Water","Pollination","Grassland","PD","FD","TD")




library(ggplot2)

pc<-ggplot(alldf, aes(x = lost, y =value, col = variable)) +
geom_line(lwd = 0.7) +labs(x = "Proportion of land area protected",y="Proportion of feature protected")+theme(legend.title=element_blank())+facet_wrap(~ facet, ncol=2)+theme(strip.text.x = element_text(size=11,face="bold"),strip.background = element_rect(fill="grey"))


ggsave(filename="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig4SM.eps",plot =pc,width=8,height=10)



##################################
## panel figure new (March 2016!)
##################################

#%%%%%%% Set up panel figure %%%%%%%%%%
par(mfrow=c(2,3))
par(mfrow=c(2,2),mai=c(0,0,0,0.4),oma=c(2,1,2,1),xpd=NA)

image(carb,col=brewer.pal(9,"Greens"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Carbon Biomass (T/ha)")
plot(world,add=T,lwd=0.1)
plot(carb,col=brewer.pal(9,"Greens"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.01))

image(wat,col=brewer.pal(9,"Blues"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Groundwater Recharge (mm/yr)")
plot(world,add=T,lwd=0.1)
plot(wat,col=brewer.pal(9,"Blues"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))


image(log(poll),col=brewer.pal(9,"Oranges"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Pollination benefit (US$/ha) (log scale)")
plot(world,add=T,lwd=0.1)
plot(poll,col=brewer.pal(9,"Oranges"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))

image(log(gras),col=brewer.pal(9,"Purples"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Grassland production of livestock Density/ha (log scale)")
plot(world,add=T,lwd=0.1)
plot(gras,col=brewer.pal(9,"Purples"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))


#%%%%%%% Taxonomic diversity %%%%%%%%%%
#-------- es 

plot(rev(TD[,1]),TD[,8],type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)
lines(rev(TD[,1]),TD[,9],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)
lines(rev(TD[,1]),TD[,10],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)
lines(rev(TD[,1]),TD[,11],type="l",xlim=c(0,1),ylim=c(0,1),col="azure4",lwd=1.5)
#-------- bio
lines(rev(bio[,1]),rowMeans(bio[,c(12,13)]),type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)
lines(rev(bio[,1]),rowMeans(bio[,c(14,15)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)
lines(rev(bio[,1]),rowMeans(bio[,c(16,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)

box(lwd=1,col="black")

#%%%%%%% Functional diversity %%%%%%%%%%

ggplot(mort3, aes(x = year, y = BCmort, col = State, linetype = State)) +
  geom_line(lwd = 1)



###########################################
###########################################

## panel figure old
setEPS()
postscript(file="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig3SM.eps",width=8.5,height=4,pointsize=10)

par(mfrow=c(1,3))

#-------------------------------bioonly

# carbon
plot(rev(bio[,1]),bio[,8],type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)

# axes
box(lwd=1,col="grey")

# water
lines(rev(bio[,1]),bio[,9],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)

# agriculture
lines(rev(bio[,1]),bio[,10],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)

# pastures
lines(rev(bio[,1]),bio[,11],type="l",xlim=c(0,1),ylim=c(0,1),col="azure4",lwd=1.5)




# PD
#lines(rowMeans(bio[,c(12,12)]),bio[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)
#lines(rev(bio[,1]),bio[,12],type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)
#lines(rev(bio[,1]),bio[,13],type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)
lines(rev(bio[,1]),rowMeans(bio[,c(12,13)]),type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)

# FD
#lines(rev(bio[,1]),rowMeans(bio[,c(14,15)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)
#lines(rev(bio[,1]),bio[,14],type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)
#lines(rev(bio[,1]),bio[,15],type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)
lines(rev(bio[,1]),rowMeans(bio[,c(14,15)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)


#TD 
#lines(rev(bio[,1]),rowMeans(bio[,c(16,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)
#lines(rev(bio[,1]),bio[,16],type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)
#lines(rev(bio[,1]),bio[,17],type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)
lines(rev(bio[,1]),rowMeans(bio[,c(16,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)

text(x=0.95,y=0.95,labels="a",cex=1.5)

#-------------------------------es

# carbon
plot(rev(es[,1]),es[,8],type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)

# axes
#axis(side = 1, at = c(0,0.2,0.4,0.6,0.8,1.0),cex.axis=1,lwd=1,col="grey")
#axis(side = 2, at = c(0,0.2,0.4,0.6,0.8,1.0),cex.axis=1,lwd=1,col="grey")
box(lwd=1,col="grey")


# water
#lines(es[,9],es[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)
lines(rev(es[,1]),es[,9],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)

# agriculture
#lines(es[,10],es[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)

lines(rev(es[,1]),es[,10],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)

# pastures
lines(rev(es[,1]),es[,11],type="l",xlim=c(0,1),ylim=c(0,1),col="azure4",lwd=1.5)

#plot(es[,1],rowMeans(es[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
#,cex.main=1.2)


# PD
#lines(rowMeans(es[,c(12,12)]),es[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)

lines(rev(es[,1]),rowMeans(es[,c(12,13)]),type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)

# FD
#lines(rowMeans(es[,c(13,14)]),es[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)

lines(rev(es[,1]),rowMeans(es[,c(14,15)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)

#TD 
#lines(rowMeans(es[,c(15,16)]),es[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)


#TD 
lines(rev(es[,1]),rowMeans(es[,c(16,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)

text(x=0.95,y=0.95,labels="b",cex=1.5)



#-------------------------------all

# carbon
plot(rev(all[,1]),all[,8],type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
,cex.main=1.2)

# axes
#axis(side = 1, at = c(0,0.2,0.4,0.6,0.8,1.0),cex.axis=1,lwd=1,col="grey")
#axis(side = 2, at = c(0,0.2,0.4,0.6,0.8,1.0),cex.axis=1,lwd=1,col="grey")
box(lwd=1,col="grey")


# water
#lines(all[,9],all[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)
lines(rev(all[,1]),all[,9],type="l",xlim=c(0,1),ylim=c(0,1),col="royalblue3",lwd=1.5)

# agriculture
#lines(all[,10],all[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)

lines(rev(all[,1]),all[,10],type="l",xlim=c(0,1),ylim=c(0,1),col="red",lwd=1.5)

# pastures
lines(rev(all[,1]),all[,11],type="l",xlim=c(0,1),ylim=c(0,1),col="azure4",lwd=1.5)

#plot(all[,1],rowMeans(all[,c(8,11)]),type="l",xlim=c(0,1),ylim=c(0,1),col="forestgreen",lwd=1.5,cex.axis=1,cex.lab=1,cex.main=1.2,frame.plot=FALSE,axes=FALSE,xlab="",ylab=""
#,cex.main=1.2)


# PD
#lines(rowMeans(all[,c(12,12)]),all[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)

lines(rev(all[,1]),rowMeans(all[,c(12,13)]),type="l",xlim=c(0,1),ylim=c(0,1),col="goldenrod2",lwd=1.5)


# FD
#lines(rowMeans(all[,c(13,14)]),all[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)

lines(rev(all[,1]),rowMeans(all[,c(14,15)]),type="l",xlim=c(0,1),ylim=c(0,1),col="black",lwd=1.5)

#TD 
#lines(rowMeans(all[,c(15,16)]),all[,1],type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)


#TD 
lines(rev(all[,1]),rowMeans(all[,c(16,17)]),type="l",xlim=c(0,1),ylim=c(0,1),col="blueviolet",lwd=1.5)

text(x=0.95,y=0.95,labels="c",cex=1.5)

mtext('Proportion of land area protected', side = 1, outer = TRUE, line = -3,xpd=NA)

mtext('Proportion of feature remaining', side = 2, outer = TRUE, line = -3,xpd=NA)

dev.off()


##################################
# Supplementary material (figures)
#################################

# Ecosystem services
wat<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/waterprov.asc")
carb<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/livecarbon.asc")
poll<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/landcost.asc")
gras<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/asciifiles/livenew.asc")


setEPS()
postscript(file="/mnt/data1tb/Dropbox/mypapers/drafts/pnas/latex1/Fig1SM.eps",width=6,height=4,pointsize=10)
par(mfrow=c(2,2),mai=c(0,0,0,0.4),oma=c(2,1,2,1),xpd=NA)

image(carb,col=brewer.pal(9,"Greens"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Carbon Biomass (T/ha)")
plot(world,add=T,lwd=0.1)
plot(carb,col=brewer.pal(9,"Greens"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.01))

image(wat,col=brewer.pal(9,"Blues"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Groundwater Recharge (mm/yr)")
plot(world,add=T,lwd=0.1)
plot(wat,col=brewer.pal(9,"Blues"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))


image(log(poll),col=brewer.pal(9,"Oranges"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Pollination benefit (US$/ha) (log scale)")
plot(world,add=T,lwd=0.1)
plot(poll,col=brewer.pal(9,"Oranges"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))

image(log(gras),col=brewer.pal(9,"Purples"),axes=FALSE,asp=1,xlab="",ylab="",cex.main=0.8,main="Grassland production of livestock Density/ha (log scale)")
plot(world,add=T,lwd=0.1)
plot(gras,col=brewer.pal(9,"Purples"),legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))


dev.off()


# Diversity maps
srm<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/SRm.asc")
srb<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/SRb.asc")
fdb<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/FDb.asc")
fdm<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/FDm.asc")
pdb<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/PDb.asc")
pdm<-raster("/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/divfiles/PDm.asc")

fdm[fdm < -6.9]<-NA



mypal<-rev(brewer.pal(10,"Spectral"))

setEPS()
postscript(file="/mnt/data1tb/Dropbox/carbonconservation/FDPDAug15/figuresJan16/Fig2SM.eps",width=8,height=6,pointsize=10)
par(mfrow=c(3,2))
par(mar=c(0,0,0,4),oma=c(2,2,2,1),xpd=NA)
image(srm,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=T,lwd=0.1)
plot(srm,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
image(srb,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.1)
plot(srb,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
image(fdm,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.1)
plot(fdm,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
image(fdb,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.1)
plot(fdb,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
image(pdm,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.1)
plot(pdm,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
image(pdb,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.1)
plot(pdb,col=mypal,legend.only=TRUE,axes=FALSE,axis.args=list(cex.axis=0.6,lwd=0.1))
text(labels="a)",x=-51147990,y=47596576,cex=1.5,xpd=NA)
text(labels="b)",x=-11128361,y=47596576,cex=1.5,xpd=NA)
text(labels="c)",x=-51147990,y=27896576,cex=1.5,xpd=NA)
text(labels="d)",x=-11128361,y=27896576,cex=1.5,xpd=NA)
text(labels="e)",x=-51147990,y=8700711,cex=1.5,xpd=NA)
text(labels="f)",x=-11128361,y=8700711,cex=1.5,xpd=NA)
dev.off()



image(pdm,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.5)
image.plot(legend.only=TRUE, col=mypal,zlim=c(as.numeric(summary(pdm)[,1][1]), as.numeric(summary(pdm)[,1][5]),legend.shrink = 0.001))
image(pdb,col=mypal,axes=FALSE,asp=1,xlab="",ylab="")
plot(world,add=TRUE,lwd=0.5)
image.plot(legend.only=TRUE, col=mypal,zlim=c(as.numeric(summary(pdb)[,1][1]), as.numeric(summary(pdb)[,1][5]),legend.shrink = 0.001))
text(labels="Mammals",x=-39907665,y=52926222,cex=1.5,xpd=NA)
text(labels="Birds",x=-865336.6,y=52926222,cex=1.5,xpd=NA)
text(labels="a)",x=-51863717,y=49172460,cex=1.5,xpd=NA)
text(labels="a)",x=-11022690,y=49172460,cex=1.5,xpd=NA)
text(labels="b)",x=-51863717,y=29150270,cex=1.5,xpd=NA)
text(labels="b)",x=-11022690,y=29150270,cex=1.5,xpd=NA)
text(labels="c)",x=-51863717,y=8705524,cex=1.5,xpd=NA)
text(labels="c)",x=-11022690,y=8705524,cex=1.5,xpd=NA)
dev.off()


