## Dataone R Package Overview
# https://cran.r-project.org/web/packages/dataone/vignettes/dataone-overview.html

# Part 1
library(dataone)
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
mySearchTerms <- list(q="abstract:salmon+AND+keywords:acoustics+AND+keywords:\"Oncorhynchus nerka\"",
                      fl="id,title,dateUploaded,abstract,size",
                      fq="dateUploaded:[2013-01-01T00:00:00.000Z TO 2014-01-01T00:00:00.000Z]",
                      sort="dateUploaded+desc")
result <- query(mn, solrQuery=mySearchTerms, as="data.frame")
result[1,c("id", "title")]

pid <- result[1,'id']

library(XML)
metadata <- rawToChar(getObject(mn, pid))

dataRaw <- getObject(mn, "df35d.443.1")
dataChar <- rawToChar(dataRaw)
theData <- textConnection(dataChar)
df <- read.csv(theData, stringsAsFactors=FALSE)
df[1,]

# Part 2
locations <- resolve(cn, pid)
mnId <- locations$data[2, "nodeIdentifier"]
mn <- getMNode(cn, mnId)

obj <- getObject(mn, pid)

# Query the data holdings on a member node
cn <- CNode("PROD")
mn <- getMNode(cn, "urn:node:KNB")
queryParams <- list(q="abstract:habitat", fl="id,title,abstract") 
result <- query(mn, queryParams, as="data.frame", parse=FALSE)
# Choose the first matchin PID
pid <- result[1,'id']
obj <- getObject(mn, pid)

## Alternate approach
d1c <- D1Client("PROD", "urn:node:KNB")
# Ask for the id, title and abstract
queryParams <- list(q="abstract:\"biogenic hydrocarbon\"", fq="id:doi*", 
                    fq="formatType:METADATA") 
result <- query(d1c@mn, solrQuery=queryParams, as="data.frame", parse=FALSE)
pid <- result[1,'id']
dataObj <- getDataObject(d1c, pid)
bytes <- getData(dataObj)
metadataXML <- rawToChar(bytes)

dataBytes <- getData(dataObj)
