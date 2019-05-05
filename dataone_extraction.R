#### Dataone metadata extraction

library(dataone)
library(XML)
library(tidyverse)

## Getting the ID of the articles
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
qy <- dataone::query(cn, list(
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

# Remove repeated articles
qy <- qy %>% distinct(title, .keep_all = TRUE)

# Remove articles that cause timeout errors
qy <- qy[c(263:264,317:339,624,651,1077:1120,1134:1499),]

# Select id columns
dataUrl <- qy[,'dataUrl']
checksum <- qy[,"checksum"]

## Download all the files at once!
# Option 1: For loop, better to identify articles causing article errors
for (i in 1:length(dataUrl)) {
  curl::curl_fetch_disk(dataUrl[i], paste0("xml2/", checksum[i], ".xml"))
}

# Option 2: use walk2
walk2(dataUrl, checksum, ~ curl::curl_fetch_disk(.x, paste0("xml/", .y, ".xml")))
