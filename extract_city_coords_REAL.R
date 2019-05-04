

## dans cette section, j'installe et active les librairies nécessaires
library(dplyr)
library(rjson)
library(geonames)
library(sp)
library(raster)
library(geosphere)
library(WriteXLS)
library(rgdal)

#ici je me connecte à Geonames (je me suis créé un compte sur geonames.org)
options(geonamesUsername=username)
#importer table de codes de pays
countries <- read.table("Countries2.txt", sep="\t", dec=".", header = FALSE) # ici je dis où est le document, + par quoi les colonnes sont séparées (sep="\t"), qu'est-ce qui définit les décimales, et si la première ligne est une entête

#garder juste les colonnes nécessaires et les renommer
countries <- countries[,c(1,5)]
names(countries)<- c("CC", "country")

#importer PIB (GDB)
gdb <- read.table("GDB.txt", dec = ".", sep= "\t", header = T)
names(gdb)<- c("country", "GDB")

#ici importer notre vraie table de données
data<- read.table ("data1_clean.txt")
names(data) <-c("name", "city","country", "deliveryPoint_creator", "west","east","north", "south")      
# fusionner les deux tables pour faire une table de référence dans laquelle piger les mots de recherche

tab_ref <- left_join(data, countries)
mini_tab_ref<- unique(tab_ref[c("city", "CC")])

# Warning message:
#   Column `country` joining factors with different levels, coercing to character vector 
# ^^^^^^ message d'erreur normal ^^^^^^


# boucle pour extraire coordonnée des villes

#création d'un tableau où entreposer les données

coord <- data.frame()

#effectuer une recherche pour chaque ligne 
for (i in 1:length(mini_tab_ref$city)) {
  latlong <- GNsearch(name = as.character(mini_tab_ref[i,1]), 
                     country = as.character(mini_tab_ref[i,2]))[1, 
                     c("lng", "lat")]
  coord <- rbind(coord, latlong) #ajouter les infos à la fin des autres infos accumulées
}

#ajouter les colonnes de coordonnées aux autres données
tab_coords <- cbind (mini_tab_ref, coord)

#ajouter nos coordonnées à notre gros dataset
gros_data <- left_join(tab_ref, tab_coords)


#créer points lat long  pour les sites d'échantillonnage
#créer colonnes vides
gros_data$fw_lat <- NA
gros_data$fw_lng <- NA
#boucle sur chaque ligne
for (i in 1:length(gros_data$city)){
  
  gros_data[i,12] <- mean(as.numeric(gros_data[i,c(7,8)])) #lat
  gros_data[i,13] <- mean(as.numeric(gros_data[i,c(5,6)])) #long
  
}

gros_data$lat <- as.numeric(gros_data$lat)
gros_data$lng <- as.numeric(gros_data$lng)
gros_data$id <- 1:length(gros_data$city)
#séparer en objet par type de point
spUNI <- cbind(gros_data$lng, gros_data$lat)
spFW <- cbind(gros_data$fw_lng, gros_data$fw_lat)
dist <- distGeo(p1=spUNI, p2=spFW)
tab_final  <- cbind(gros_data, dist/1000)
tab_final <- tab_final[,c(14,1:13,15)]
names(tab_final)<-c("id","name","city","country","deliveryPoint_creator","west", "east", "north","south","CC","uni_lng","uni_lat","fw_lat","fw_lng","dist_km")

#oups! enlever lignes où lat-long fw = 0
tab_final<- tab_final[-c(55,46,120),]
WriteXLS(tab_final, ExcelFileName = "data1.xls")

### créer table pour figures ----
tab_aurelie <- dplyr::left_join(tab_final, gdb)
write.table(tab_aurelie, "tab_aurelie.txt")
