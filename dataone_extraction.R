library(dataone)
library(XML)
library(tidyverse)


# Getting the ID of the articles
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
(qy <- dataone::query(cn, list(
  rows = "40", 
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
