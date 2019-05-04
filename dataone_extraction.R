library(dataone)
library(XML)
library(tidyverse)


# Getting the ID of the articles
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
(qy <- dataone::query(cn, list(
  rows = "10000", 
  q    = "title:forest", #keyword
  fq   = "wildlife", #filter keyword
  fl   = ""), 
  as = "data.frame"))
View(qy)

id <- qy[,'id']
dataUrl <- qy[,'dataUrl']
checksum <- qy[,"checksum"]

# httr::GET(url = dataUrl[33])

# eml_URL <- qy %>% 
#   as_tibble %>% 
#   mutate(metadata = map(dataUrl, safely(httr::GET)))
# 
# # testing a file download
# curl::curl_download(dataUrl[33], destfile = 'test_33.xml')
# eml_URL$metadata[[33]][["result"]] %>% View

# download all the files at once! 
walk2(dataUrl, checksum, ~ curl::curl_download(url = .x, destfile = paste0("xml/", .y, ".xml")))


# for (i in 1:length(dir(path = "xml/", full.names = TRUE))) {
#   dir(path = "xml/", full.names = TRUE)[i] %>% 
#     set_names(., basename(.)) %>% 
#           read_file_raw() %>% 
#           rawToChar %>%
#           xmlTreeParse(asText=TRUE, trim = TRUE, ignoreBlanks = TRUE) %>% 
#           xmlRoot %>% 
#           xmlToList
# }
# file.remove(dir(path = "xml/", full.names = TRUE)[i])
parsed_files <- dir(path = "xml/", full.names = TRUE) %>% 
  set_names(., basename(.)) %>% 
  map(~.x %>% 
        read_file_raw() %>% 
        rawToChar %>%
        xmlTreeParse(asText=TRUE, trim = TRUE, ignoreBlanks = TRUE) %>% 
        xmlRoot %>% 
        xmlToList)

parsed_files <- parsed_files %>% tibble::enframe()


mc <- partial(map_chr, .default = NA_character_)

parsed_data <- parsed_files %>% 
  mutate(city_contact = mc(value, pluck, "dataset", "contact", "address", "city"),
         country_contact = mc(value, pluck, "dataset", "contact", "address", "country"),
         city_creator = mc(value, pluck, "dataset", "creator", "address", "city"),
         country_creator = mc(value, pluck, "dataset", "creator", "address", "country"),
         deliveryPoint_creator = mc(value, pluck, "dataset", "creator", "address", "deliveryPoint"),
         # keyword = mc(value, pluck, "dataset", "keywordSet", "keyword"),
         west = mc(value, pluck, "dataset", "coverage", "geographicCoverage", "boundingCoordinates", "westBoundingCoordinate"),
         east = mc(value, pluck, "dataset", "coverage", "geographicCoverage", "boundingCoordinates", "eastBoundingCoordinate"),
         north = mc(value, pluck, "dataset", "coverage", "geographicCoverage", "boundingCoordinates", "northBoundingCoordinate"),
         south = mc(value, pluck, "dataset", "coverage", "geographicCoverage", "boundingCoordinates", "southBoundingCoordinate")) 
  # unnest(city_contact, country_contact, city_creator, country_creator, deliveryPoint_creator,
         # west, east, north, south) %>% 
  # select(name, city_contact, country_contact, city_creator, country_creator, deliveryPoint_creator,
         # keyword, west, east, north, south)
  # mutate(df_contact = map(from_contact, safely(flatten_df))) %>% 
  # mutate(df_creator = map(from_creator, safely(flatten_df)))

parsed_data %>% 
  select(-value) %>% 
  write_csv("data/data1.csv")

data <- parsed_data %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  mutate(df_result = map(df_contact, "result")) %>% 
  filter(!map_lgl(df_result, is_null)) %>% 
  select(name, df_result) %>% 
  unnest(df_result) %>% 
  select(name, city, country)

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
