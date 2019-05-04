

## dans cette section, j'installe et active les librairies nécessaires
install.packages("ggmap")
install.packages("rjson")
library(dplyr)
library(rjson)
library(geonames)


#ici je me connecte à Geonames (je me suis créé un compte sur geonames.org)
options(geonamesUsername="aureliecl")

#importer table de codes de pays
countries <- read.table("Countries2.txt", sep="\t", dec=".", header = FALSE) # ici je dis où est le document, + par quoi les colonnes sont séparées (sep="\t"), qu'est-ce qui définit les décimales, et si la première ligne est une entête

#garder juste les colonnes nécessaires et les renommer
countries <- countries[,c(1,5)]
countries[,2]<- as.character(countries[,2])
countries[16,2]<- "Aland"
names(countries)<- c("CC", "country")

gdb <- read.table("GDB.txt", sep="\t", dec=".", header = T)
names(gdb) <-c ("country", "GDB")
countries_gdb <- left_join(countries, gdb)

# créer une table test pour les villes avec noms de pays

tab_city <- data.frame(city = c("New York", "Montreal", "Burlington", "London", "Waterloo"), country =c("United States", "Canada", "United States", "United Kingdom", "Belgium"))

# fusionner les deux tables pour faire une table de référence dans laquelle piger les mots de recherche

tab_ref <- left_join(tab_city, countries_gdb)


# Warning message:
#   Column `country` joining factors with different levels, coercing to character vector 
# ^^^^^^ message d'erreur normal ^^^^^^


# boucle pour extraire coordonnée des villes

#création d'un tableau où entreposer les données
coord <- data.frame()
# i=1
#effectuer une recherche pour chaque ligne 
for (i in 1:length(tab_ref$city)){
  latlong <- GNsearch(name = as.character(tab_ref[i,1]), 
                     country = as.character(tab_ref[i,3]))[1, 
                     c("lng", "lat")]
  coord <- rbind(coord, latlong) #ajouter les infos à la fin des autres infos accumulées
}

#ajouter les colonnes de coordonnées aux autres données
tab_coords <- cbind (tab_ref, coord)


#
##
### code ref
df <- GNsearch(name = "New York", country = "US")
coords <- df[1, c("lng", "lat")]



(lanc_df <- GNsearch(name = "Lancaster", country = "UK"))
lanc_coords <- lanc_df[1, c("lng", "lat")]