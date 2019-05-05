#### Data parsing

library(XML)
library(tidyverse)

## Identify error files
file_names <- dir(path = "xml2/", full.names = TRUE)
file_numbers <- rep(NA,length(file_names))
for (i in 1:length(file_names)) {
  if(file_names[i] %>% read_file_raw() %>% rawToChar  %>% substr(0, 5) == "<?xml"){
    file_numbers[i] <- i
  } 
}
file_numbers
valid_files <- file_names[!is.na(file_numbers)] 
error_files <- file_names[is.na(file_numbers)] 

# Check error files
error_files[666] %>% read_file_raw() %>% rawToChar
# Most seem to be Dryad

# file.remove(dir(path = "xml2/", full.names = TRUE)[i])

## Parse files for metadata

# Parse from xml
parsed_files <- valid_files %>% 
  set_names(., basename(.)) %>% 
  map(~.x %>% 
        read_file_raw() %>% 
        rawToChar %>%
        xmlTreeParse(asText=TRUE, trim = TRUE, ignoreBlanks = TRUE)%>% 
        xmlRoot %>% 
        xmlToList)

# # Tim's tries to remove false xml files
# xml_documents = c()
# done = 0
# for (i in c(1:length(parsed_files))) {
#   print(parsed_files[i]$error)
#   if(is.null(parsed_files[i]$error)) {
#     done = done+1
#     xml_documents[done] = parsed_files[i]$result
#   }
# }
# xml_documents = unique(xml_documents)
# 
# xml_documents %>% map(~.x %>% xmlRoot %>% xmlToList)

parsed_files <- parsed_files %>% tibble::enframe()

# Set map_chr default parameters
mc <- partial(map_chr, .default = NA_character_)

# Organize metadata as columns
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

# Export to csv
parsed_data %>% 
  select(-value) %>% 
  write_csv("data/data3.csv")