library('RCurl')
library('RJSONIO')
library('plyr')

queryGremlin <- function(q, param) {
  query_string <- query_builder(q, param)
  query(query_string)
}

query <- function(q) {
  result <- try(query_intern(q))
  if (class(result) == "try-error") {
    return(NULL)
  } else {
    return(result)
  }
}

query_intern <- function(q) {
  h = basicTextGatherer()
  curlPerform(url="http://localhost:7474/db/data/ext/GremlinPlugin/graphdb/execute_script",
              postfields=paste('script',curlEscape(q), sep='='),
              writefunction = h$update,
              verbose = FALSE
              )
  text <- h$value()
  frame <- NULL
  # NOT JSON
  if (length(grep("[", text, fixed=TRUE)) == 0 && length(grep("{", text, fixed=TRUE)) == 0) {
    frame <- as.data.frame(text, stringsAsFactors=FALSE)
    # JSON
  } else {
    complex <- fromJSON(text)
    if (is.atomic(complex)) {
      frame <- as.data.frame(complex, stringsAsFactors=FALSE)
      colnames(frame) <- c('result')
      #} else if (is.list(complex)) {
      # frame <- as.data.frame(complex, stringsAsFactors=FALSE)
      } else {
        list <- lapply(complex, function(x) x$data)
        frame <- as.data.frame(do.call(rbind, list), stringsAsFactors=FALSE)
      }
  }
  return(frame)
}

query_builder <- function(q, param) {
  tt <- q
  for (name in names(param)) {
    tt <- gsub(paste("\\$",name,sep=""), param[name], tt)
  }
  tt
}

queryCypher <- function(querystring) {
  h = basicTextGatherer()
  curlPerform(url="http://localhost:7474/db/data/ext/CypherPlugin/graphdb/execute_query",
              postfields=paste('query',curlEscape(querystring), sep='='),
              writefunction = h$update,
              verbose = FALSE
              )
  
  result <- fromJSON(h$value())
  
  data <- data.frame(t(sapply(result$data, unlist)))
  #names(data) <- result.json$columns
  junk <- c("outgoing_relationships","traverse", "all_typed_relationships","property","self","properties","outgoing_typed_relationships","incoming_relationships","create_relationship","paged_traverse","all_relationships","incoming_typed_relationships")
  data <- data[,!(names(data) %in% junk)] 
  data
}
