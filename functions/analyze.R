## analyze correlation between Google search volume and a non-binary indicator
## inputs: "indicator" data frame
##         "indname" string specifying column name of indicator in "indicator"
##         "plotname" string specifying name of indicator for plotting
##         "subject" either "Money Laundering" or "Corruption"
##         "spar" smoothing parameter passed to smooth.spline
##         "lab.ind" indices of countries whose labels are plotted or "top10" or "index"
##          ... passed to plot

analyze <- function(indicator, indname, plotname = indname, subject = "Money Laundering", spar = 0.75, lab.ind = NA, ...){
  dev.new()
  ## filter out countries not assessed by indicator
  ind <- indicator[!is.na(indicator[,indname]),]
  
  cat("could not find following countries in ", indname, ":\n",
      paste(indicator$Country[which(!indicator$Country %in% ind$Country)],collapse="\n"),"\n\n")
  
  cat("\n____________________________________________________\n")
  
  #### correlation
  cor <- cor.test(ind$google, ind[,indname], alternative = "greater")
  obsCor <- cor$estimate
  print(cor)
  ## qq-plot to test for normality (pearson test assumes normality)
  qqnorm(ind$google, main="Normal Q-Q Plot for Google Searches")
  qqnorm(ind[,indname], main=paste("Normal Q-Q Plot for",plotname))
  ## Permutation test
  N <- 10000 # repeat shuffling N times
  perCor <- numeric(length = N)
  for(i in 1:N){
    shufdata <- ind[sample(nrow(ind)),]
    perCor[i] <- cor(shufdata$google, ind[,indname])
  }
  ## one-sided p-value based on permutation test
  ## singificant would be e.g. p-value <= 0.05
  cat("\nPermutation test p-value = ", p_value_Cor <- sum(perCor >= obsCor)/length(perCor), "\n")
  #hist(perCor, xlim = range(c(perCor, obsCor)), xlab = "Pearson Correlation Coefficient",
  #     main = paste("Correlation Google search volume v.", plotname),
  #     sub = paste("Permutation Test for Pearson Correlation Coefficient. p-value =",p_value_Cor), 100)
  #abline(v=obsCor, col="red")
  ### sensitivity of correlation: bootstrapping
  ## M bootstrap samples
  M <- 10000
  bootCor <- numeric(length = M)
  for(i in 1:M){
    boot.sample <- sample.int(nrow(ind), replace = T)
    bootCor[i] <- cor(ind[boot.sample, "google"], ind[boot.sample, indname])
  }
  #mean(bootCor)
  #sd(bootCor)
  #hist(bootCor, xlab = "Pearson Correlation Coefficient",
  #     main = paste("Correlation Google search volume v.", plotname),
  #     sub = "Bootstrapped Pearson Correlation Coefficients", 100)
  #abline(v=obsCor, col="red")
  ## plot in same hist as permutation test
  hist(perCor, xlim = range(c(perCor, obsCor, bootCor)), ylim = c(0, 1000),
       col = rgb(0,0,1,0.5),
       xlab = "Pearson Correlation Coefficient",
       main = paste("Correlation Google search volume v.", plotname),
       sub = paste("Permutation Test (blue, p-value =",p_value_Cor,") & Bootstrap (red)"),
       breaks = seq(-1,1,0.02))
  hist(bootCor, breaks = seq(-1,1,0.02),
       add = TRUE, col = rgb(1,0,0,0.5))
  abline(v=obsCor, col="red", lwd=3)
  cat("\n____________________________________________________\n")
  
  ## Kendall correlation test
  cor.tau <- cor.test(ind$google, ind[,indname], alternative = "greater", method = "kendall")
  print(cor.tau)
  cat("\n____________________________________________________\n")
  
  #### linear regression
  fit <- lm(ind[,indname] ~ google, ind)
  print(summary(fit))
  x <- data.frame(google = seq(0,max(ind$google),1))
  
  #### plot
  main = paste("Google Searches for ", subject, " in Countries", sep="'")
  sub = paste("Corr.: r = ", round(cor$estimate,4), " (p-value = ", round(cor$p.value,4),
              "), tau = ", round(cor.tau$estimate,4), " (", round(cor.tau$p.value,4),
              "), Lin. reg.: slope = ", round(fit$coefficients[2],4), " (", round(summary(fit)$coeff["google",4],4),")", sep="")
  jpeg(paste("Plot/",subject,"_",indname,".jpg",sep=""), width = 480, height = 480, quality=100) ## save plot
  plot(ind$google, ind[,indname], xlab = "Google search ratio", ylab = plotname,
       main = main, sub = sub, pch=16, col=rgb(0,0,0,0.4), ...)
  s <- smooth.spline(ind$google, ind[,indname], spar = spar); lines(s, col=3)
  ## plot linear regression with confidence interval
  matplot(x$google, predict(fit, x, interval = "confidence"), col = 2, lwd = 1, lty = c(1,2,2), type = "l", add = T)
  ## label some countries
  if(!is.na(lab.ind[1])){
    if(lab.ind[1] == "index"){
      text(ind$google, ind[,indname], labels = 1:nrow(ind), cex = 0.6, pos=1,offset=0.3) ## determine index
    }else{
      if(lab.ind[1] == "top10"){
        lab.ind <- order(ind$google, decreasing = T)[1:10] ## label top 10 Google search countries
      }
      text(ind$google[lab.ind], ind[lab.ind,indname], labels = ind$Country[lab.ind], cex = 0.77, pos=1,offset=0.3)
    }
  }
  dev.off()
}


## analyze correlation between Google search volume and a binary indicator
## inputs: "indicator" data frame
##         "indname" string specifying column name of indicator in "indicator"
##         "plotname" string specifying name of indicator for plotting
##         "subject" either "Money Laundering" or "Corruption"

bin.analyze <- function(indicator, indname, plotname = indname, subject = "Money Laundering"){
  ## filter out countries not assessed by indicator
  ind <- indicator[!is.na(indicator[,indname]),]
  
  cat("could not find following countries in ", indname, ":\n",
      paste(indicator$Country[which(!indicator$Country %in% ind$Country)],collapse="\n"),"\n\n")
  
  ## Wilcoxon test to test whether means are significantly different
  wil <- wilcox.test(google ~ ind[,indname], ind, alternative = "less")
  
  ## plot
  main = paste("Google Searches for ", subject, " in Countries", sep="'")
  jpeg(paste("Plot/",subject,"_",indname,".jpg",sep=""), width = 480, height = 480, quality=100) ## save plot
  boxplot(google ~ ind[,indname], ind,
          names = c(paste("not ", plotname, " (", sum(ind[,indname]==0,na.rm=T), ")", sep=""),
                    paste(plotname, " (", sum(ind[,indname]!=0,na.rm=T), ")", sep="")),
          ylab="Google search ratio", main = main,
          sub = paste("p-value of one-sided Wilcoxon test =", round(wil$p.value,4)))
  graphics.off()
}


