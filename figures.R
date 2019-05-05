library(ggplot2)
# figures
tab <- read.table ( "tab_aurelie.txt")
hist(tab$dist_km)

# plot

theme_set(theme_classic())

ggplot(data=tab, aes(tab$dist_km)) + 
geom_histogram()


#par distance unique
tab2<- tab[!duplicated(tab$dist_km),]

theme_set(theme_classic())

ggplot(data=tab2, aes(tab2$dist_km)) + 
  geom_histogram()

min(tab$dist_km)

group = cut(data$wt, c(178, 200, 300, Inf), right=FALSE)
group = cut(tab$dist_km, c(0,1000,2000,3000,4000,5000), labels=FALSE)
tab<- cbind(tab, group)

# palette = 8-class Dark2
library(RColorBrewer)

# fait une palette avec le nombre de couleurs désirées
pal = brewer.pal(n = length(unique(tab$city)), name = "Paired")      # n = nb de niveaux de la palette
pal = colorRampPalette(pal)                   # colorRamp c'est pour interpoler des couleurs dans la palette
pal = pal(length(unique(tab$city))) 



#palette chaud_froid
library(colorRamps)
cbPalette<-colorRamps::matlab.like(length(unique(tab$city))) #froid -> chaud 
cbPalette[6]<- "gold"
cbPalette[5]<- "olivedrab3"
cbPalette[4]<- "lightseagreen"
cbPalette[1]<- "midnightblue"
cbPalette[3]<- "dodgerblue"

library(joey)

ggplot(data=tab, aes(x=tab$group))+
       geom_bar(position = position_dodge(preserve = "single"), aes(fill=factor(city)))+
      scale_fill_manual(values=pal, breaks=c("Albuquerque", "Amherst", "Bangalore", "Bangkok", "Corvallis", "Fairbanks", "Petersham",  "Redding"), name = "Cities")

library(dplyr)
tab %>% 
  mutate(city = forcats::fct_reorder(city, uni_lat)) %>% 
  ggplot(aes(x=uni_lat, y=dist_km, fill=city))  + 
  stat_summary(aes(x = uni_lat - 2), color="darkgrey", fun.y = median, fun.ymax = max, fun.ymin = min) +
# geom_boxplot() + 
  geom_point(pch = 21, size = 3, position = position_jitter(width = 0.5, height = 0)) +
  scale_fill_brewer(palette = "Spectral") + 
  scale_y_sqrt()
