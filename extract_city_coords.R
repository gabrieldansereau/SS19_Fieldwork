

## dans cette section, j'installe et active les librairies nécessaires
library(dplyr)
library(rjson)
library(geonames)
library(sp)
library(raster)
library(geosphere)

#ici je me connecte à Geonames (je me suis créé un compte sur geonames.org)
options(geonamesUsername=username)
#importer table de codes de pays
countries <- read.table("Countries2.txt", sep="\t", dec=".", header = FALSE) # ici je dis où est le document, + par quoi les colonnes sont séparées (sep="\t"), qu'est-ce qui définit les décimales, et si la première ligne est une entête

#garder juste les colonnes nécessaires et les renommer
countries <- countries[,c(1,5)]
names(countries)<- c("CC", "country")

#importer PIB (GDB)
gdb <- read.table("GDB.txt", dec = ".", sep= "\t", header = T)
# créer une table test pour les villes avec noms de pays

tab_city <- data.frame(city = c("New York", "Montreal", "Burlington", "London", "Waterloo"), country =c("United States", "Canada", "United States", "United Kingdom", "Belgium"))

# fusionner les deux tables pour faire une table de référence dans laquelle piger les mots de recherche

tab_ref <- left_join(tab_city, countries)
# Warning message:
#   Column `country` joining factors with different levels, coercing to character vector 
# ^^^^^^ message d'erreur normal ^^^^^^


# boucle pour extraire coordonnée des villes

#création d'un tableau où entreposer les données

coord <- data.frame()

#effectuer une recherche pour chaque ligne 
for (i in 1:length(tab_ref$city)) {
  latlong <- GNsearch(name = as.character(tab_ref[i,1]), 
                     country = as.character(tab_ref[i,3]))[1, 
                     c("lng", "lat")]
  coord <- rbind(coord, latlong) #ajouter les infos à la fin des autres infos accumulées
}

#ajouter les colonnes de coordonnées aux autres données
tab_coords <- cbind (tab_ref, coord)

#ajouter coordonnées fieldwork
fw_coords <- read.table ("fw_coords.txt", sep = "\t", dec = ".", header = T)

tout <- cbind(tab_coords,fw_coords)

#créer lat long pour les sites d'échantillonnage
#créer colonnes vides
tout$fw_lat <- NA
tout$fw_lng <- NA
#boucle sur chaque ligne
for (i in 1:length(tout$city)){
  
  tout[i,10] <- mean(as.numeric(tout[i,c(8,9)])) #lat
  tout[i,11] <- mean(as.numeric(tout[i,c(6,7)])) #long
  
}

coords_tout <- tout[,c(4,5,10,11)]
coords_tout$lat <- as.numeric(coords_tout$lat)
coords_tout$lng <- as.numeric(coords_tout$lng)
sp_tout <- SpatialPointsDataFrame(coords = coords_tout[ , c("lat", "lng")], data = coords_tout)


#pour avoir une référence de projection : 
ERA <- raster("/Users/aureliechagnon-lafortune/Desktop/ERA-interim/tif/tsl1_20170731.tif")
proj4string(sp_tout) <- proj4string(ERA)

distGeo(p1= c(sp_tout$lng[1], sp_tout$lat[1]), p2= c(sp_tout$fw_lng[1], sp_tout$fw_lng[1]))
