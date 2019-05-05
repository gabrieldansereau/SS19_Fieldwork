library(ggplot2)
library(dplyr)
# figures
tab <- read.csv ( "data_tout.csv")

usa <-dplyr::filter(tab, country=="United States")
other<- dplyr::filter(tab, country!="United States")


# cities in usa ----

usa %>% 
  mutate(city = forcats::fct_reorder(city, uni_lat)) %>% 
  ggplot(aes(x=city, y=dist_km, fill=city))  +
  # stat_summary(aes(x = uni_lat - 2), color="darkgrey", fun.y = median, fun.ymax = max, fun.ymin = min) +
   # geom_boxplot(aes(alpha=0.25)) + 
   geom_point(pch = 21, size = 3, position = position_jitter(width = 0.3, height = 0)) +
  theme(axis.text.x = element_text(angle=45))+ labs(x = "US Cities (from south to north)", y = "Distance from field work (km)")



#histogram for all data, color by country
tab%>% 
  mutate(country = forcats::fct_reorder(country, uni_lat)) %>% 
ggplot(aes( x=dist_km, fill=country))+
  geom_histogram(col="black") +
  scale_fill_brewer(palette = "Spectral")+
  # geom_histogram(fill="aquamarine4", col="black") +
  labs(x="Distance from field work (km)", y = "Nb of datasets")

# histogram other countries
ggplot(data=other,aes(x=dist_km, fill= country))+
  geom_histogram(col="black") +
  # geom_histogram(fill="aquamarine4", col="black") +
  labs(x="Distance from field work (km)", y = "Nb of datasets")






###########
hist(tab2$dist_km , breaks=100)

# plot
other %>% 
  ggplot(aes(x=uni_lat, y=dist_km, fill=country))  + 
  # stat_summary(aes(x = uni_lat - 2), color="darkgrey", fun.y = median, fun.ymax = max, fun.ymin = min) +
  # geom_boxplot() + 
  geom_point(pch = 21, size = 3, position = position_jitter(width = 0.5, height = 0)) +
  # scale_fill_brewer(palette = "Set1") + 
  scale_y_sqrt()








group = cut(tab$dist_km, c(0,2000,4000,6000, 8000,10000), labels=FALSE)
tab<- cbind(tab, group)
tab$group <- group
ggplot(data=tab, aes(x=group, fill=country)) +
  geom_bar( )+
  scale_fill_brewer(palette="Dark2")
position=position_dodge()
ggplot(data=datn2, aes(x=dose, y=length, fill=supp)) +
  geom_bar(stat="identity", position=position_dodge())

# palette = 8-class Dark2
library(RColorBrewer)

# fait une palette avec le nombre de couleurs désirées
pal = brewer.pal(n = length(unique(tab$country)), name = "Paired")      # n = nb de niveaux de la palette
pal = colorRampPalette(pal)                   # colorRamp c'est pour interpoler des couleurs dans la palette
pal = pal(length(unique(tab$country))) 




library(dplyr)

ggplot(data=usa,aes( x=dist_km))+
  geom_histogram(fill="aquamarine4", col="black") +
  labs(x="Distance from field work (km)", y = "Nb of datasets")



library(gapminder)

head(gapminder)
