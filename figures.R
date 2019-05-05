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

ggplot(data=tab, aes(x=tab$group))+
       geom_bar(position = position_dodge(preserve = "single"), aes(fill=factor(city)))+
      scale_fill_manual(values=pal, breaks=c("Albuquerque", "Amherst", "Bangalore", "Bangkok", "Corvallis", "Fairbanks", "Petersham",  "Redding"), name = "Cities")


geom_bar(position = position_dodge(preserve = "single"))
      scale_f
gg <- ggplot(mtcars, aes(x=cyl))
p1 <- gg + geom_bar(position="dodge", aes(fill=factor(vs))) 