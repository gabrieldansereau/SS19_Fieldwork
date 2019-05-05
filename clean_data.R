#### Clean data

# Load data
data <- read.csv("data/data3.csv")
data_repl <- data

# Set values as character
data_repl$city_contact <- as.character(data_repl$city_contact)
data_repl$country_contact <- as.character(data_repl$country_contact)

# Replacing missing values in *_contact by values in *_creator if missing
data_repl$city_contact[is.na(data_repl$city_contact)] <- as.character(data_repl$city_creator[is.na(data_repl$city_contact)])
data_repl$country_contact[is.na(data$country_contact)] <- as.character(data$country_creator[is.na(data$country_contact)])

# Fix some values
data_repl$city_contact[which(data$city_contact=="Tempe 85287-2402")] <- "Tempe"
data_repl$city_contact[which(data$city_contact=="Tempe 85287-5402")] <- "Tempe"
data_repl$city_contact[which(data$city_contact=="TEMPE")] <- "Tempe"
data_repl$city_contact[which(data$city_contact=="3000 NE 151 St")] <- "Miami"
data_repl$city_contact[which(data$city_contact=="DAVIS")] <- "Davis"
data_repl$city_contact[which(data$city_contact=="Canberra,")] <- "Canberra"
data_repl$city_contact[which(data$city_contact=="ANCHORAGE")] <- "Anchorage"

unique(data_repl$city_contact)
data_repl <- dplyr::filter(data_repl, !is.na(data_repl$west))

# Set values back as factors
data_repl$city_contact <- as.factor(data_repl$city_contact)
data_repl$country_contact <- as.factor(data_repl$country_contact)

# enlever colonnes creator pour éviter confusion inutile
data_repl <- data_repl[,-c(4,5)]
data_repl <- dplyr::filter(data_repl, !is.na(data_repl$city_contact) )

# vérifier quelles villes n'ont pas de pays assignés!!!
data_repl$country_contact[which(data_repl$city_contact=="Albuquerque")] <- "United States"
data_repl$country_contact[is.na(data_repl$country_contact)] <- "Australia"

data_repl[data_repl == "USA"] <- "United States"
data_repl[data_repl == "United States of America"] <- "United States"
data_repl[data_repl == "U.S.A."] <- "United States"
data_repl[data_repl == "33181"] <- "United States"
data_repl[data_repl == "SA"] <- "South Africa"

data_repl <- data_repl[data_repl$west!=0,]

write.table(data_repl, "data3_clean.txt")



