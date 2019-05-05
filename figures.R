library(ggplot2)
# figures
tab <- read.csv ( "data_tout.csv")
hist(tab2$dist_km , breaks=100)

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


group = cut(tab$dist_km, c(0,2000,4000,6000, 8000,1000), labels=FALSE)
tab<- cbind(tab, group)

ggplot(data=tab, aes(x=group, fill=country)) +
  geom_bar( position=position_dodge())

ggplot(data=datn2, aes(x=dose, y=length, fill=supp)) +
  geom_bar(stat="identity", position=position_dodge())

# palette = 8-class Dark2
library(RColorBrewer)

# fait une palette avec le nombre de couleurs désirées
pal = brewer.pal(n = length(unique(tab$country)), name = "Paired")      # n = nb de niveaux de la palette
pal = colorRampPalette(pal)                   # colorRamp c'est pour interpoler des couleurs dans la palette
pal = pal(length(unique(tab$country))) 




library(dplyr)
other %>% 
  ggplot(aes(x=uni_lat, y=dist_km, fill=country))  + 
  # stat_summary(aes(x = uni_lat - 2), color="darkgrey", fun.y = median, fun.ymax = max, fun.ymin = min) +
  # geom_boxplot() + 
  geom_point(pch = 21, size = 3, position = position_jitter(width = 0.5, height = 0)) +
  # scale_fill_brewer(palette = "Set1") + 
  scale_y_sqrt()

usa <-dplyr::filter(tab, country=="United States")
other<- dplyr::filter(tab, country!="United States")

library(dplyr)
usa %>% 
   mutate(city = forcats::fct_reorder(city, uni_lat)) %>% 
  ggplot(aes(x=city, y=dist_km, fill=city))  + 
  # stat_summary(aes(x = uni_lat - 2), color="darkgrey", fun.y = median, fun.ymax = max, fun.ymin = min) +
# geom_boxplot() + 
  geom_point(pch = 21, size = 3, position = position_jitter(width = 0.5, height = 0)) 
  # scale_fill_brewer(palette = "Spectral") + 
  # scale_y_sqrt()
