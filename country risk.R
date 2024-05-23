#### load libraries and functions ####
library(dplyr)
library(xlsx)
source("functions/prep.google.R")
source("functions/load.ind.R")
source("functions/analyze.R")

###### load google trends ######
#### money laundering ####
## topic (72 countries too few search volume)
google <- prep.google(read.csv("Google/Money Laundering topic 28Apr19.csv", skip = 2, na.strings = "", stringsAsFactors=F))
## search term (149 countries too few search volume)
google <- prep.google(read.csv("Google/Money Laundering search term 28Apr19.csv", skip = 2, na.strings = "", stringsAsFactors=F))

#### corruption ####
## topic (51 countries too few search volume)
google <- prep.google(read.csv("Google/Corruption topic 28Apr19.csv", skip = 2, na.strings = "", stringsAsFactors=F))
## search term (103 countries too few search volume)
google <- prep.google(read.csv("Google/Corruption search term 28Apr19.csv", skip = 2, na.strings = "", stringsAsFactors=F))

#### Top 10 ####
ord <- order(google[,2], decreasing = T)
barplot(google[ord[1:10],2], names = google[ord[1:10],1], horiz=F, cex.names = 0.75,
        main = "Google Search Volume related to 'Money Laundering'")
cat("Top 10:\n"); print(google[ord[1:10],])
writeClipboard(google[ord[1:10],1])
writeClipboard(as.character(google[ord[1:10],2]))
#_______________________________________________________________________________________

#### load Money Laundering indicators ####
indicators <- load.ML.ind(google)

#### merge with Google trend for Money Laundering
dat <- full_join(indicators, google, by="Country")

## remove rows with too few Google searches
ana <- filter(dat, google != -Inf)
message("removed ", nrow(dat) - nrow(ana), " / ", nrow(dat)," countries due to too low Google search volume")

#### Correlation test for all columns separately
## Pearson
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("r\t\testimate\tconfidence interval\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t(",paste(round(corr$conf.int,4),collapse=", \t"),")\t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}
## Kendall
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("tau\t\testimate\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater", method = "kendall")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}
## Spearman
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("rho\t\testimate\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater", method = "spearman")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}

## Basel AML Index
analyze(ana, "Basel.score", "2018 Basel AML Index")

## FATF list
bin.analyze(ana, "FATF", "on FATF list")

## Not Egmont Group member
bin.analyze(ana, "Egmont", "Egmont Group member")

## EU Blacklist
bin.analyze(ana, "EU", "on EU Blacklist")

## FSF IMF 2000 list
analyze(ana, "FSF.IMF00", "FSF IMF 2000 list")

## IMF 2007 list
bin.analyze(ana, "IMF07", "on IMF 2007 list")

## IMF 2018 list
bin.analyze(ana, "IMF18", "on IMF 2018 list")

## FSI 2018 Secrecy Score
analyze(ana, "FSI", "FSI 2018 Secrecy Score")

## total: Basel + FATF + EU + FSF.IMF00 + IMF07 + IMF18 + FSI + Egmont
## compute sum normalized to number of non-NA indicators = mean of non-NA indicators
ML.OFC <- ana[!(is.na(ana$Basel.score) & is.na(ana$FATF) & is.na(ana$EU) & is.na(ana$FSF.IMF00) & is.na(ana$IMF07) & is.na(ana$IMF18) & is.na(ana$FSI) & is.na(ana$Egmont)),]
ML.OFC$mean <- apply(ML.OFC[,c("Basel.score","FATF","EU","FSF.IMF00","IMF07","IMF18","FSI","Egmont")],MAR=1,FUN=mean,na.rm=T)
#cat("could not find countries in this indicator:\n", paste(ana$Country[which(!ana$Country %in% ML.OFC$Country)],collapse="\n"))
analyze(ML.OFC, "mean", "ML & OFC indicators mean", spar = 0.85,
        cex=apply(ML.OFC[,c("Basel.score","FATF","EU","FSF.IMF00","IMF07","IMF18","FSI","Egmont")],MAR=1,FUN=function(x){sum(!is.na(x))}) / 6)
#analyze(ML.OFC, "mean", "ML & OFC indicators mean", spar = 0.85,
#        cex=apply(ML.OFC[,c("Basel.score","FATF","EU","FSF.IMF00","IMF07","IMF18","FSI","Egmont")],MAR=1,FUN=function(x){sum(!is.na(x))}) / 6,
#        lab.ind = c(137,139,136,124,133,72,102,67,83,60,28, 134,151,149,122,70,41,55,163,142,147,145,143, 34,112,92))  ## with labels

## first principal component
ana2 <- ana[,!names(ana)%in%c("ISO.Code","Country","US.score","google")]
noNA <- ana2[rowSums(is.na(ana2)) == 0,]
dim(noNA)
pca <- prcomp(noNA, center = TRUE, scale. = TRUE)
summary(pca) # how much does PC1 explain?
## visualize first two PCs on a biplot
library(devtools)
#install_github("vqv/ggbiplot")
library(ggbiplot)
ggbiplot(pca)
ggbiplot(pca, labels=ana[rowSums(is.na(ana2)) == 0,"Country"])
## analyze
noNA[,c("Country","google")] <- ana[as.numeric(rownames(noNA)),c("Country","google")]
noNA$PC1 <- -pca$x[,1]
analyze(noNA, "PC1", "first Principal Component")


#___________________________________________________________________________________________


#### load Corruption indicators ####
indicators <- load.C.ind(google)

#### merge with Google trend for Money Laundering
dat <- full_join(indicators, google, by="Country")

## remove rows with too few Google searches
ana <- filter(dat, google != -Inf)
message("removed ", nrow(dat) - nrow(ana), " / ", nrow(dat)," countries due to too low Google search volume")

#### Correlation test for all columns separately
## Pearson
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("r\t\testimate\tconfidence interval\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t(",paste(round(corr$conf.int,4),collapse=", \t"),")\t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}
## Kendall
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("tau\t\testimate\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater", method = "kendall")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}
## Spearman
first <- T
for(i in names(indicators)[-2:-1]){
  if(first){cat("rho\t\testimate\tp-value");first<-F}
  corr <- cor.test(ana$google, ana[,i], alternative = "greater", method = "spearman")
  cat("\n",i,if(nchar(i)<6){"   "},"\t",round(corr$estimate,5)," \t",round(corr$p.value,4),if(corr$p.value<0.05){"      \t*"})
}

## IQ - do not use: also covers transparency and accountability, unclear whether high/low score means high/low corruption, includes only few countries
#analyze(ana, "IQ", "IQ.CPA.TRAN.XQ", "Corruption")

## IC
analyze(ana, "IC", "IC.FRM.BRIB.ZS", "Corruption")

## WGI
analyze(ana, "WGI", "WGI Control of Corruption", "Corruption")

## CPI
analyze(ana, "CPI", "Corruption Perception Index", "Corruption")

## GCB 2013 Q2 - do not use: newer version available, Q2 might not be representative
#analyze(ana, "GCB13", "Global Corruption Barometer 2013", "Corruption")

## GCB 2017 Q3
analyze(ana, "GCB", "Global Corruption Barometer 2017", "Corruption")

## WHR
analyze(ana, "WHR", "WHR Perception of Corruption", "Corruption")

## TRACE
analyze(ana, "TRACE", "TRACE Bribery Risk Matrix\uAE 2018", "Corruption")

## total: IC + WGI + CPI + GCB (2017) + WHR + TRACE
## compute sum normalized to number of non-NA indicators = mean of non-NA indicators
Corr <- ana[!(is.na(ana$IC) & is.na(ana$WGI) & is.na(ana$CPI) & is.na(ana$GCB) & is.na(ana$WHR) & is.na(ana$TRACE)),]
Corr$mean <- apply(Corr[,c("IC","WGI","CPI","GCB","WHR","TRACE")],MAR=1,FUN=mean,na.rm=T)
#cat("could not find countries in this indicator:\n", paste(ana$Country[which(!ana$Country %in% Corr$Country)],collapse="\n"))
analyze(Corr, "mean", "Corruption indicators mean", "Corruption", spar = 0.85,
        cex=apply(Corr[,c("IC","WGI","CPI","GCB","WHR","TRACE")],MAR=1,FUN=function(x){sum(!is.na(x))}) / 4)
#analyze(Corr, "mean", "Corruption indicators mean", "Corruption", spar = 0.85,
#        cex=apply(Corr[,c("IC","WGI","CPI","GCB","WHR","TRACE")],MAR=1,FUN=function(x){sum(!is.na(x))}) / 4,
#        lab.ind = c(97,149,13,15,16,100,122,29,30,143,147,73, 161,65,78,50, 160,2,37,151,153,3,164,81,17,180,82)) ## with labels

## first principal component
ana2 <- ana[,!names(ana)%in%c("ISO3","Country","IQ","GCB13","google")]
noNA <- ana2[rowSums(is.na(ana2)) == 0,]
dim(noNA)
pca <- prcomp(noNA, center = TRUE, scale. = TRUE)
summary(pca) # PC1 explains 58.92% of total variance
## visualize first two PCs on a biplot
library(devtools)
#install_github("vqv/ggbiplot")
library(ggbiplot)
#ggbiplot(pca)
ggbiplot(pca, labels=ana[rowSums(is.na(ana2)) == 0,"Country"])
## analyze
noNA[,c("Country","google")] <- ana[as.numeric(rownames(noNA)),c("Country","google")]
noNA$PC1 <- -pca$x[,1]
analyze(noNA, "PC1", "first Principal Component", "Corruption")
