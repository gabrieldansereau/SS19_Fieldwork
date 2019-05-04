library(dataone)
library(XML)
library(tidyverse)


# Getting the ID of the articles
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
qy_1 <- dataone::query(cn, list(
  rows = "5000", 
  q    = "keywords:Disturbance +OR+ keywords:Fire + OR+  keywords:Forest +
  OR+  keywords:Vegetation + OR+  keywords:Canopy + OR+  keywords:Structure +
  OR+  keywords:Demography + OR+  keywords:Fire + OR+   keywords:Management + OR+
  keywords:Dynamic + OR+  keywords:Growth+ OR+  keywords:Ecology + OR+
  keywords:Inventories+ OR + keywords:Gis+
  OR + keywords:niche +OR + keywords:habitat +OR + keywords:community +
  OR + keywords:ecosystem +OR + keywords:capacity +OR + keywords:biosphere +
  OR + keywords:symbiosis +OR + keywords:mutualism +OR + keywords:consumers +
  OR + keywords:organism +OR + keywords:food +OR + keywords:prey +
  OR + keywords:density +OR + keywords:chlorophyll +OR + keywords:decomposers", #keyword
  fq   = "", #filter keyword
  fl   = "id, checksum, dataUrl, title, keywords, author, site"), 
  as = "data.frame")
View(qy_1)

my_data <- qy_1 %>% distinct(title, .keep_all = TRUE)
View(my_data)


id <- my_data[,'id']
dataUrl <- my_data[,'dataUrl']
checksum <- my_data[,"checksum"]


# download all the files at once! 
walk2(dataUrl, checksum, ~ curl::curl_fetch_disk(.x, paste0("xml_2/", .y, ".xml")))

eml_take_two <- qy_1 %>% 
  as_tibble %>% 
  mutate(metadata = map(id, ~ getObject(mn, .x)))

parsed_eml <- eml_take_two %>% 
  select(id, metadata) %>% 
  mutate(doc = map(metadata, ~ .x %>%
                     rawToChar %>%
                     xmlTreeParse(asText=TRUE, trim = TRUE, ignoreBlanks = TRUE) %>% 
                     xmlRoot %>% 
                     xmlToList))

parsed_data <- parsed_eml %>% 
  mutate(from_contact = map(doc, pluck, "dataset", "contact", "address"),
         from_creator = map(doc, pluck, "dataset", "creator", "address")) %>%
  mutate(df_contact = map(from_contact, safely(flatten_df)))


### GetObject version
# qy_1 <- slice(qy, grep("^https", id, invert = TRUE)) #if we need to eliminate some id who doesn't work
# qy_1 <- slice(qy_1, grep("^knb", id, invert = TRUE)) #if we need to eliminate some id who doesn't work
# qy_1 <- slice(qy_1, grep("^Global", id, invert = TRUE)) #if we need to eliminate some id who doesn't work
# qy_1 <- arrange(qy_1, desc(id), desc(dateModified)) # to have the most recent ones
id <- qy_1[,'id']
length(id)

eml_take_two <- qy_1 %>% 
  as_tibble %>% 
  mutate(metadata = map(id, ~ getObject(mn, .x)))

parsed_eml <- eml_take_two %>% 
  select(id, metadata) %>% 
  mutate(doc = map(metadata, ~ .x %>%
                     rawToChar %>%
                     xmlTreeParse(asText=TRUE, trim = TRUE, ignoreBlanks = TRUE) %>% 
                     xmlRoot %>% 
                     xmlToList))

# parsed_eml$doc[[1]] %>% pluck("dataset", "creator", "address") %>% flatten_df
# parsed_eml$doc %>% map(~ pluck(.x, "dataset", "creator", "address")) 
# parsed_eml$doc %>% map(c("dataset", "contact", "address")) %>% flatten_df

parsed_data <- parsed_eml %>% 
  mutate(from_contact = map(doc, pluck, "dataset", "contact", "address"),
         from_creator = map(doc, pluck, "dataset", "creator", "address")) %>%
  mutate(df_contact = map(from_contact, safely(flatten_df)))

# Version 1
city <- c()
for (i in 1:length(id)) {
  metadata <- rawToChar(getObject(mn, id[i]))
  doc <- xmlRoot(xmlTreeParse(metadata, asText=TRUE, trim = TRUE, ignoreBlanks = TRUE))
  parsed_doc <- xmlToList(doc)
  city[i] <- parsed_doc$dataset$creator$address$city
  parsed_doc$dataset$contact$address$city
  ## Structure sometimes different
  # code with if?
}

# Version 2
for (i in 1:length(id)) {
  dataRaw <- getObject(mn, id[i])
  dataChar <- rawToChar(dataRaw)
  theData <- textConnection(dataChar)
  df <- c()
  df <- read.csv(theData, stringsAsFactors = FALSE)
  class(df)
  grep("<city>*<city>",as.list(df))
  df[1,]
}

