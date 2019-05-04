library(dataone)
library(XML)
library(tidyverse)


# Getting the ID of the articles
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
qy_1 <- dataone::query(cn, list(
  rows = "5000", 
  q    = "keywords:Disturbance +OR+ keywords:Fire + OR+  keywords:Forest + OR+  keywords:Vegetation + OR+  keywords:Canopy + OR+  keywords:Structure + OR+  keywords:Demography + OR+  keywords:Fire + OR+   keywords:Management + OR+  keywords:Dynamic + OR+  keywords:Growth+ OR+  keywords:Ecology + OR+  keywords:Inventories+ OR + keywords:Gis", #keyword
  fq   = "", #filter keyword
  fl   = "id, checksum, dataUrl, title, keywords, author, site"), 
  as = "data.frame")
View(qy_1)

my_data <- qy_1 %>% distinct(title, .keep_all = TRUE)
View(my_data)
