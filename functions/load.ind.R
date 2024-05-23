## prints countries in dat which are not found in google
## inputs: "dat" data frame with column "Country"
##         "google" data frame with column "Country"
warn.country.not.found <- function(dat, google){
  not.found <- dat$Country[!dat$Country %in% google$Country]
  if(length(not.found) > 0){
    warning("Following countries not found in google countries:\n", paste(not.found,collapse = "\n"))
  }
}

## min-max scales a numeric vector such that returned values are from 0 to 100
## input: "x" numeric vector of numbers (NAs allowed)
scale.0.100 <- function(x){
  return(100 * (x - min(x,na.rm=T)) / (max(x,na.rm=T) - min(x,na.rm=T)))
}

#### load Money Laundering indicators ####
## returns data frame of merged indicators
## input: "google" data frame with column "Country"
load.ML.ind <- function(google){
  
  #### load Money Laundering indicators
  ## FATF (excl. low-risk countries)
  FATF <- read.xlsx("Money Laundering Indicators/FATF.xlsx",1,header=F,stringsAsFactors=FALSE)
  FATF$FATF <- 100
  names(FATF) <- c("Country","FATF")
  warn.country.not.found(FATF, google)
  
  ## Basel AML Index
  Basel <- read.csv("Money Laundering Indicators/Basel.csv",stringsAsFactors=FALSE)
  names(Basel) <- ifelse(names(Basel)=="Overall.score","Basel.score",names(Basel))
  Basel$Basel.score <- scale.0.100(Basel$Basel.score) ## scale form 0 to 100
  warn.country.not.found(Basel, google)
  
  ## US State Department - do not use: US perspective, aggregation not clear
  #US.State <- read.csv("Money Laundering Indicators/US State.txt",stringsAsFactors=FALSE,row.names=NULL)
  ## count "Y" (yes) ignoring last, US-specific, column. ("affects US")
  #US.State$US.score <- apply(US.State[,2:14], 1, sum)
  ## normalize s.t. score 0 is lowest, score 100 highest money laundering risk
  #US.State$US.score <- 1 - (US.State$US.score - min(US.State$US.score)) /
  #  (max(US.State$US.score) - min(US.State$US.score))
  #US.State$US.score <- 100*US.State$US.score
  #warn.country.not.found(US.State, google)
  
  ## Countries which are not member of the Egmont Group
  Egmont <- read.xlsx("Money Laundering Indicators/Egmont.xlsx",1,startRow=4,header=T,stringsAsFactors=FALSE)
  Egmont$Egmont <- 100*Egmont$Egmont
  Egmont$Country[which(Egmont$Country == "Democratic Republic of the Congo")] <- "Congo - Kinshasa"
  Egmont$Country[which(Egmont$Country == "Congo")] <- "Congo - Brazzaville"
  Egmont$Country[which(Egmont$Country == "Sao Tome & Principe")] <- "Sao Tome and Principe"
  Egmont$Country[which(Egmont$Country == "Timor Leste")] <- "Timor-Leste"
  Egmont$Country[which(Egmont$Country == "Bosnia & Herzegovina")] <- "Bosnia-Herzegovina"
  Egmont$Country[which(Egmont$Country == "Saint Kitts and Nevis")] <- "St. Kitts and Nevis"
  Egmont$Country[which(Egmont$Country == "Saint Lucia")] <- "St. Lucia"
  Egmont$Country[which(Egmont$Country == "Saint Vincent and the Grenadines")] <- "St. Vincent and the Grenadines"
  Egmont$Country[grepl("^Cura",Egmont$Country)] <- "Curacao"
  warn.country.not.found(Egmont, google)
  
  
  #### load OFC indicators
  ## EU blacklist (excl. low-risk countries)
  EU <- read.xlsx("OFC Indicators/EU blacklist.xlsx",1,header=F,stringsAsFactors=FALSE)
  EU$EU <- 100
  names(EU) <- c("Country","EU")
  warn.country.not.found(EU, google)
  
  ## FSF IMF
  FSF.IMF <- read.xlsx("OFC Indicators/FSF IMF.xlsx",1,header=T,stringsAsFactors=FALSE)
  ## 1. FSF.IMF.2000 (excl. low-risk countries)
  FSF.IMF00 <- data.frame(Country = FSF.IMF$FSF.IMF.2000, FSF.IMF00 = 100 * FSF.IMF$FSF.IMF.2000.Group / 3,stringsAsFactors=FALSE)
  warn.country.not.found(FSF.IMF00, google)
  ## 2. IMF.2007 (excl. low-risk countries)
  IMF07 <- data.frame(Country = FSF.IMF$IMF.2007[!is.na(FSF.IMF$IMF.2007)], IMF07 = 100, stringsAsFactors=FALSE)
  warn.country.not.found(IMF07, google)
  ## 3. IMF.2018 (excl. low-risk countries)
  IMF18 <- data.frame(Country = FSF.IMF$IMF.2018[!is.na(FSF.IMF$IMF.2018)], IMF18 = 100, stringsAsFactors=FALSE)
  warn.country.not.found(IMF18, google)
  ## 4. FSF.2018.shadow.banking (excl. low-risk countries)
  # not used: shadow banking only partially reflects money laundering
  
  ## FSF IMF
  FSI <- read.xlsx("OFC Indicators/FSI-Rankings-2018.xlsx",1,header=T,endRow=113,stringsAsFactors=FALSE)
  FSI <- data.frame(Country = FSI$Jurisdiction, FSI = FSI$Secrecy.Score4,stringsAsFactors=FALSE)
  FSI$FSI <- scale.0.100(FSI$FSI) ## scale form 0 to 100
  FSI$Country <- gsub("[[:digit:]]", "", FSI$Country) # remove footnotes
  FSI$Country[which(FSI$Country == "USA")] <- "United States"
  FSI$Country[which(FSI$Country == "United Arab Emirates (Dubai),")] <- "United Arab Emirates"
  FSI$Country[which(FSI$Country == "Macao")] <- "Macau"
  FSI$Country[which(FSI$Country == "Malaysia (Labuan)")] <- "Malaysia"
  FSI$Country[which(FSI$Country == "Portugal (Madeira)")] <- "Portugal"
  warn.country.not.found(FSI, google)
  
  
  #### merge indicators
  join <- full_join(Basel[,c("Country","ISO.Code","Basel.score")], FATF, by="Country")
  #join <- full_join(join, US.State[,c("Country","US.score")], by="Country")
  join <- full_join(join, Egmont, by="Country")
  join <- full_join(join, EU, by="Country")
  join <- full_join(join, FSF.IMF00, by="Country")
  join <- full_join(join, IMF07, by="Country")
  join <- full_join(join, IMF18, by="Country")
  join <- full_join(join, FSI, by="Country")
  
  ##  add 0 for lists excl. low-risk countries
  join$FATF[is.na(join$FATF)] <- 0
  join$EU[is.na(join$EU)] <- 0
  join$FSF.IMF00[is.na(join$FSF.IMF00)] <- 0
  join$IMF07[is.na(join$IMF07)] <- 0
  join$IMF18[is.na(join$IMF18)] <- 0
  
  return(join)
}

#### load Corruption indicators ####
## returns data frame of merged indicators
## input: "google" data frame with column "Country"
load.C.ind <- function(google){
  
  #### load Corruption indicators
  ## CPI
  CPI <- read.xlsx("Corruption Indicators/01 Corruption Perception Index/2018_CPI_FullDataSet.xlsx",1,startRow=3,colIndex=c(1:9),header=T,stringsAsFactors=FALSE)
  names(CPI) <- ifelse(names(CPI)=="CPI.Score.2018","CPI",names(CPI))
  CPI$CPI <- scale.0.100(-CPI$CPI) ## invert & scale form 0 to 100
  CPI$Country[which(CPI$Country == "United States of America")] <- "United States"
  CPI$Country[which(CPI$Country == "Brunei Darussalam")] <- "Brunei"
  CPI$Country[which(CPI$Country == "Saint Vincent and the Grenadines")] <- "St. Vincent and the Grenadines"
  CPI$Country[which(CPI$Country == "Cabo Verde")] <- "Cape Verde"
  CPI$Country[which(CPI$Country == "Korea, South")] <- "South Korea"
  CPI$Country[which(CPI$Country == "Saint Lucia")] <- "St. Lucia"
  CPI$Country[which(CPI$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  CPI$Country[which(CPI$Country == "Cote d'Ivoire")] <- "Cote D'Ivoire"
  CPI$Country[which(CPI$Country == "Democratic Republic of the Congo")] <- "Congo - Kinshasa"
  CPI$Country[which(CPI$Country == "Congo")] <- "Congo - Brazzaville"
  CPI$Country[which(CPI$Country == "Guinea Bissau")] <- "Guinea-Bissau"
  CPI$Country[which(CPI$Country == "Korea, North")] <- "North Korea"
  warn.country.not.found(CPI, google)
  
  ## Global Corruption Barometer 2013
  ## only Q2: To what extent do you think that corruption is a problem in the public sector in this country?
  GCB13 <- read.xlsx("Corruption Indicators/02 Global Corruption Barometer 2013/GCB2013_Data.xls",3,startRow=6,endRow=112,colIndex=c(1,2,9),header=F,stringsAsFactors=FALSE)
  names(GCB13) <- c("Country","ISO3","GCB13")
  GCB13$GCB13 <- scale.0.100(GCB13$GCB13) ## scale form 0 to 100
  GCB13$Country[which(GCB13$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  GCB13$Country[which(GCB13$Country == "Democratic Republic of the Congo")] <- "Congo - Kinshasa"
  GCB13$Country[which(GCB13$Country == "FYR Macedonia")] <- "Macedonia"
  GCB13$Country[which(GCB13$Country == "Korea (South)")] <- "South Korea"
  warn.country.not.found(GCB13, google)
  
  ## Global Corruption Barometer 2017
  ## only Q3: Total bribery rates by country (TOTAL Bribery Rate, excluding no contact)
  GCB <- read.xlsx("Corruption Indicators/02 Global Corruption Barometer 2017/Global_Corruption_Barometer_2017_Global_Results.xlsx",
                     12,startRow=6,endRow=116,colIndex=c(1,3),header=F,stringsAsFactors=FALSE)
  names(GCB) <- c("Country","GCB")
  GCB <- GCB[!is.na(GCB$GCB),] # remove NAs
  GCB$GCB <- ifelse(GCB$GCB<1, GCB$GCB*100, GCB$GCB) # fix format error in original data
  GCB$Country[which(GCB$Country == "Bosnia and Herz.")] <- "Bosnia-Herzegovina"
  GCB$Country[which(GCB$Country == "FYR Macedonia")] <- "Macedonia"
  GCB$Country[which(GCB$Country == "Korea")] <- "South Korea"
  GCB$Country[which(GCB$Country == "Cote d'Ivoire")] <- "Cote D'Ivoire"
  GCB$Country[which(GCB$Country == "Czech Rep.")] <- "Czech Republic"
  GCB$Country[which(GCB$Country == "Kyrgyz Rep.")] <- "Kyrgyzstan"
  GCB$Country[which(GCB$Country == "Slovak Rep.")] <- "Slovakia"
  warn.country.not.found(GCB, google)
  
  ## World Bank IQ.CPA.TRAN.XQ & IC.FRM.BRIB.ZS
  IQ <- read.csv("Corruption Indicators/03 IQ.CPA.TRAN.XQ/API_IQ.CPA.TRAN.XQ_DS2_en_csv_v2_10475090.csv",skip=4,stringsAsFactors=FALSE)
  IQ <- IQ[,-c(3,4,63,64)]
  IC <- read.csv("Corruption Indicators/04 IC.FRM.BRIB.ZS/API_IC.FRM.BRIB.ZS_DS2_en_csv_v2_10476802.csv",skip=4,stringsAsFactors=FALSE)
  IC <- IC[,-c(3:49,64)]
  # calculate historical mean of available data
  IQ$mean <- apply(IQ[,-c(1,2)], MAR = 1, FUN = mean, na.rm = T)
  IQ <- IQ[,c("Country.Name","Country.Code","mean")]
  names(IQ) <- c("Country","ISO3","IQ")
  IQ$IQ <- scale.0.100(IQ$IQ) ## scale form 0 to 100
  IC$mean <- apply(IC[,-c(1,2)], MAR = 1, FUN = mean, na.rm = T)
  IC <- IC[,c("Country.Code","mean")]
  names(IC) <- c("ISO3","IC")
  IC$IC <- scale.0.100(IC$IC) ## scale form 0 to 100
  # merge the two indicators
  IQ <- merge(IQ, IC, by = "ISO3", all = T)
  # filter out regions of countries
  IQ <- filter(IQ, !Country %in% c("Arab World","Central Europe and the Baltics","East Asia & Pacific (excluding high income)","Early-demographic dividend","East Asia & Pacific",
                                   "Europe & Central Asia (excluding high income)","Europe & Central Asia","Euro area","European Union","Fragile and conflict affected situations",
                                   "High income","Heavily indebted poor countries (HIPC)","IBRD only","IDA & IBRD total","IDA total","IDA blend","IDA only","Not classified",
                                   "Latin America & Caribbean (excluding high income)","Latin America & Caribbean","Least developed countries: UN classification","Low income",
                                   "Lower middle income","Low & middle income","Late-demographic dividend","Middle East & North Africa","Middle income",
                                   "Middle East & North Africa (excluding high income)","North America","OECD members","Other small states","Pre-demographic dividend",
                                   "Pacific island small states","Post-demographic dividend","South Asia","Sub-Saharan Africa (excluding high income)","Sub-Saharan Africa",
                                   "Small states","East Asia & Pacific (IDA & IBRD countries)","Europe & Central Asia (IDA & IBRD countries)","Latin America & the Caribbean (IDA & IBRD countries)",
                                   "Middle East & North Africa (IDA & IBRD countries)","South Asia (IDA & IBRD)","Sub-Saharan Africa (IDA & IBRD countries)","Upper middle income",
                                   "World","Caribbean small states","Channel Islands","West Bank and Gaza","Eswatini"))
  # rename countries
  IQ$Country[which(IQ$Country == "Bahamas, The")] <- "Bahamas"
  IQ$Country[which(IQ$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  IQ$Country[which(IQ$Country == "Brunei Darussalam")] <- "Brunei"
  IQ$Country[which(IQ$Country == "Cote d'Ivoire")] <- "Cote D'Ivoire"
  IQ$Country[which(IQ$Country == "Congo, Dem. Rep.")] <- "Congo - Kinshasa"
  IQ$Country[which(IQ$Country == "Congo, Rep.")] <- "Congo - Brazzaville"
  IQ$Country[which(IQ$Country == "Cabo Verde")] <- "Cape Verde"
  IQ$Country[which(IQ$Country == "Egypt, Arab Rep.")] <- "Egypt"
  IQ$Country[which(IQ$Country == "Micronesia, Fed. Sts.")] <- "Micronesia"
  IQ$Country[which(IQ$Country == "Gambia, The")] <- "Gambia"
  IQ$Country[which(IQ$Country == "Hong Kong SAR, China")] <- "Hong Kong"
  IQ$Country[which(IQ$Country == "Iran, Islamic Rep.")] <- "Iran"
  IQ$Country[which(IQ$Country == "Kyrgyz Republic")] <- "Kyrgyzstan"
  IQ$Country[which(IQ$Country == "Korea, Rep.")] <- "South Korea"
  IQ$Country[which(IQ$Country == "Lao PDR")] <- "Laos"
  IQ$Country[which(IQ$Country == "Macao SAR, China")] <- "Macau"
  IQ$Country[which(IQ$Country == "St. Martin (French part)")] <- "St. Martin"
  IQ$Country[which(IQ$Country == "Macedonia, FYR")] <- "Macedonia"
  IQ$Country[grepl("Korea, Dem. People",IQ$Country)] <- "North Korea"
  IQ$Country[which(IQ$Country == "Russian Federation")] <- "Russia"
  IQ$Country[which(IQ$Country == "Slovak Republic")] <- "Slovakia"
  IQ$Country[which(IQ$Country == "Sint Maarten (Dutch part)")] <- "Sint Maarten"
  IQ$Country[which(IQ$Country == "Syrian Arab Republic")] <- "Syria"
  IQ$Country[which(IQ$Country == "Venezuela, RB")] <- "Venezuela"
  IQ$Country[which(IQ$Country == "Virgin Islands (U.S.)")] <- "US Virgin Islands"
  IQ$Country[which(IQ$Country == "Yemen, Rep.")] <- "Yemen"
  warn.country.not.found(IQ, google)
  
  ## WGI Control of Corruption
  WGI <- read.xlsx("Corruption Indicators/05 WGI Control of Corruption/wgidataset.xlsx",7,
                   startRow=15,endRow=112,colIndex=c(1,2,seq(3,19*6,6)),header=T,stringsAsFactors=FALSE,colClasses=c("character","character",rep("numeric",19)))
  # calculate historical mean of available data
  WGI$mean <- apply(WGI[,-c(1,2)], MAR = 1, FUN = mean, na.rm = T)
  WGI <- WGI[,c("Country.Territory","WBCode","mean")]
  names(WGI) <- c("Country","ISO3","WGI")
  WGI$WGI <- scale.0.100(-WGI$WGI) ## invert & scale form 0 to 100
  # merge with World Bank Indicators
  join <- full_join(IQ, WGI[,c("ISO3","WGI")], by="ISO3")
  # use AND for Andorra, not ADO
  join[which(join$ISO3 == "AND"),"WGI"] <- join[which(join$ISO3 == "ADO"),"WGI"]
  join <- join[-which(join$ISO3 == "ADO"),]
  # add Anguilla
  join[which(join$ISO3 == "AIA"),"Country"] <- "Anguilla"
  # do not add Netherlands Antilles since it is disestablished
  join <- join[-which(join$ISO3 == "ANT"),]
  #join[which(join$ISO3 == "ANT"),"Country"] <- "Netherlands Antilles"
  # add Cook Islands
  join[which(join$ISO3 == "COK"),"Country"] <- "Cook Islands"
  # add French Guiana
  join[which(join$ISO3 == "GUF"),"Country"] <- "French Guiana"
  if(sum(is.na(join$Country))>0){warning(paste(join[is.na(join$Country),"ISO3"],collapse=", ")," not found")}
  warn.country.not.found(join, google)
  
  ## WHR Perception of Corruption
  WHR <- read.xlsx("Corruption Indicators/06 WHR Perception of Corruption/WHR2019Chapter2OnlineData.xls",1,
                   colIndex=c(1,2,9),header=T,stringsAsFactors=FALSE,colClasses=c("character","character","numeric"))
  names(WHR) <- c("Country","year","WHR")
  # calculate historical mean of available data
  WHR <- aggregate(WHR ~ Country, data = WHR, FUN = mean, na.rm = TRUE)
  WHR$WHR <- scale.0.100(WHR$WHR) ## scale form 0 to 100
  WHR$Country[which(WHR$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  WHR$Country[which(WHR$Country == "Congo (Kinshasa)")] <- "Congo - Kinshasa"
  WHR$Country[which(WHR$Country == "Congo (Brazzaville)")] <- "Congo - Brazzaville"
  WHR$Country[which(WHR$Country == "Hong Kong S.A.R. of China")] <- "Hong Kong"
  WHR$Country[which(WHR$Country == "Ivory Coast")] <- "Cote D'Ivoire"
  WHR$Country[which(WHR$Country == "Palestinian Territories")] <- "Palestine"
  WHR$Country[which(WHR$Country == "Taiwan Province of China")] <- "Taiwan"
  # remove North Cyprus & Somaliland region
  WHR <- WHR[-which(WHR$Country %in% c("North Cyprus","Somaliland region")),]
  warn.country.not.found(WHR, google)
  
  ## TRACE Bribery Risk Matrix 2018
  TRACE <- read.xlsx("Corruption Indicators/07 TRACE Bribery Matrix/TRACE.xlsx",1,colIndex=c(2,8),header=T,stringsAsFactors=FALSE)
  names(TRACE) <- c("Country","TRACE")
  TRACE$Country[which(TRACE$Country == "Slovak Republic")] <- "Slovakia"
  TRACE$Country[which(TRACE$Country == "Bosnia and Herzegovina")] <- "Bosnia-Herzegovina"
  TRACE$Country[which(TRACE$Country == "Brunei Darussalam")] <- "Brunei"
  TRACE$Country[which(TRACE$Country == "Russian Federation")] <- "Russia"
  TRACE$Country[which(TRACE$Country == "Kyrgyz Republic")] <- "Kyrgyzstan"
  TRACE$Country[which(TRACE$Country == "Ivory Coast")] <- "Cote D'Ivoire"
  TRACE$Country[which(TRACE$Country == "East Timor")] <- "Timor-Leste"
  TRACE$Country[which(TRACE$Country == "Eswatini (Swaziland)")] <- "Swaziland"
  TRACE$Country[which(TRACE$Country == "Dem. Rep. of the Congo")] <- "Congo - Kinshasa"
  TRACE$Country[which(TRACE$Country == "Republic of the Congo (Brazzaville)")] <- "Congo - Brazzaville"
  warn.country.not.found(TRACE, google)
  
  #### merge indicators
  join <- full_join(join, CPI[,c("Country","CPI")], by="Country")
  join <- full_join(join, GCB13[,c("Country","GCB13")], by="Country")
  join <- full_join(join, GCB[,c("Country","GCB")], by="Country")
  join <- full_join(join, WHR, by="Country")
  join <- full_join(join, TRACE[,c("Country","TRACE")], by="Country")
  
  return(join)
}

