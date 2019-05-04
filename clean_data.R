data <- read.csv("data/data1.csv")

data2 <- data
data2$city_contact[is.na(data$city_contact)] <- as.character(data$city_creator[is.na(data$city_contact)])
data2$country_contact[is.na(data$country_contact)] <- as.character(data$country_creator[is.na(data$country_contact)])

unique(data$city_contact)
data <- dplyr::filter(data2, !is.na(data2$west))

# enlever colonnes creator pour éviter confusion inutile
data <- data[,-c(4,5)]
data <- dplyr::filter(data, !is.na(data$city_contact) )

#vérifier quelles villes n'ont pas de pays assignés!!!
data$country_contact[is.na(data$country_contact)] <- "USA"

data[data == "USA"] <- "United States"

write.table(data, "data1_clean.txt")



