library(tidyverse);library(raster)
library(sf);library(viridis)

d<-expand.grid(x=1:100,y=1:100)

ggplot(d, aes(x,y,fill=atan(y/x),alpha=x+y))+
  geom_tile()+
  scale_fill_viridis()+
  theme(legend.position="none",
        panel.background=element_blank())+
  labs(title="A bivariate color scheme (Viridis)")

d<-expand.grid(x=1:3,y=1:3)
d<-merge(d,data.frame(x=1:3,xlabel=c("X low", "X middle","X high")),by="x")
d<-merge(d,data.frame(y=1:3,ylabel=c("Y low", "Y middle","Y high")),by="y")

g.legend<-
  ggplot(d, aes(x,y,fill=atan(y/x),alpha=x+y,label=paste0(xlabel,"\n",ylabel)))+
  geom_tile()+
  geom_text(alpha=1)+
  scale_fill_viridis()+
  theme_void()+
  theme(legend.position="none",
        panel.background=element_blank(),
        plot.margin=margin(t=10,b=10,l=10))+
  labs(title="A bivariate color scheme (Viridis)",x="X",y="Y")+
  theme(axis.title=element_text(color="black"))+
  # Draw some arrows:
  geom_segment(aes(x=1, xend = 3 , y=0, yend = 0), size=1.5,
               arrow = arrow(length = unit(0.6,"cm"))) +
  geom_segment(aes(x=0, xend = 0 , y=1, yend = 3), size=1.5,
               arrow = arrow(length = unit(0.6,"cm"))) 
g.legend