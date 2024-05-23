## preprocess google data
## input: data frame google with search volumes in second column
## output: proprocessed data frame
prep.google <- function(google){
  message("reading:\n", names(google)[2])
  names(google)[2] <- c("google")
  google$google <- ifelse(google$google == "<1", 0, suppressWarnings(as.integer(google$google)))
  google[is.na(google)] <- -Inf ## remove later from analysis since not enough data
  for(i in 1:nrow(google)){google$Country[i] <- sub("\\&","and",google$Country[i])}
  google$Country[grep("Ivoire",google$Country)] <- "Cote D'Ivoire"
  google$Country[which(google$Country == "Myanmar (Burma)")] <- "Myanmar"
  google$Country[which(google$Country == "Macedonia (FYROM)")] <- "Macedonia"
  google$Country[grep("^Cura",google$Country)] <- "Curacao"
  google$Country[grep("^St. Barth",google$Country)] <- "St. Barthelemy"
  google$Country[grep("U.S. Virgin Islands",google$Country)] <- "US Virgin Islands"
  google$Country[which(google$Country == "St. Vincent and Grenadines")] <- "St. Vincent and the Grenadines"
  google$Country[which(google$Country == "Czechia")] <- "Czech Republic"
  google$Country[which(google$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  google$Country[grep("ncipe$",google$Country)] <- "Sao Tome and Principe"
  google$Country[grep("land Islands$",google$Country)] <- "Aland Islands"
  google$Country[grep("union$",google$Country)] <- "Reunion"
  return(google)
}
