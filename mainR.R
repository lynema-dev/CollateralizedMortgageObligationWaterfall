library(areaplot)

cmo.trancheSenior_PrincipalOwed <- 21000000
cmo.trancheSenior_InterestClaim <- 20400000
cmo.trancheMezzanine_PrincipalOwed <- 9000000
cmo.trancheMezzanine_InterestClaim <- 4800000
cmo.trancheJunior_PrincipalOwed <- 0
cmo.trancheJunior_InterestClaim <- 4800000
cmo.total_size <- 30000000
cmo.interest_rate <- 0.0625
cmo.payment_years <- 30
cmo.payments_per_year <- 12

principal <- c(cmo.trancheSenior_PrincipalOwed, cmo.trancheMezzanine_PrincipalOwed, 
              cmo.trancheJunior_PrincipalOwed)
interestClaim <- c(cmo.trancheSenior_InterestClaim, cmo.trancheMezzanine_InterestClaim,
                  cmo.trancheJunior_InterestClaim)

if ((sum(principal) != cmo.total_size) || (sum(interestClaim) != cmo.total_size))
{
  stop("Principal / Interest Claim Tranche allocations do not equate to total size!")
}

#Create Dataframe
colTypesList = c("double","double","double","double","double","double")
colNamesList = c("Senior_principal","Mezzanine_principal","Junior_principal",
             "Senior_interest","Mezzanine_interest","Junior_interest")
dfCashflows = read.table(text = "", col.names = colNamesList, colClasses = colTypesList)

#Initialization of vectors
paymentPeriods <- 1:(cmo.payment_years * cmo.payments_per_year)
principalexJunior <- principal[1:length(principal)-1]
principalPaidSubtotal <- rep(x=0,length(principal))
principalTrancheFull <- rep(x=FALSE,length(principal)-1)
interestClaimExJunior <- interestClaim[1:length(interestClaim)-1]
interestClaimSubTotal <- rep(x=0,length(interestClaim))
interestPaidSubTotal <- rep(x=0,length(interestClaim))
interestTrancheFull <- rep(x=FALSE, length((interestClaim))) 

totalPaymentInPeriod <- sum(principal)*cmo.interest_rate/(cmo.payments_per_year
        *(1-1/(1+r/cmo.payments_per_year)^(cmo.payments_per_year*cmo.payment_years)))

for (m in paymentPeriods)
{
  principalPaymentInPeriod <- totalPaymentInPeriod / 
        (1+r/cmo.payments_per_year)^(cmo.payments_per_year*cmo.payment_years-m+1) 
  interestPaymentInperiod <- totalPaymentInPeriod - principalPaymentInPeriod
  #allocate the principal payments to all tranches sequentially
  #except the Junior when these are not full
  principalCashflowsForPeriod = rep(x=0,length(principal))
  for (i in 1:length(principalexJunior))
  {
    if (principalPaidSubtotal[i] < principal[i])
    {
      principalPaidSubtotal[i] = principalPaidSubtotal[i] + principalPaymentInPeriod
      principalCashflowsForPeriod[i] = principalPaymentInPeriod
      break
    }
    else
    {
      principalTrancheFull[i] = TRUE
    }
  }
  #when full, allocate to the Junior tranche
  TrueList = which(principalTrancheFull == TRUE)
  if (length(TrueList) == length(principalexJunior))
  {
    i = i + 1
    principalPaidSubtotal[i] = principalPaidSubtotal[i] + principalPaymentInPeriod
    principalCashflowsForPeriod[length(principalCashflowsForPeriod)] = principalPaymentInPeriod
  }
  #allocate the interest payments to all tranches sequentially
  #except Junior when these are not full
  interestCashflowsForPeriod = rep(x=0,length(interestClaim))
  for (i in 1:length(interestClaimExJunior))
  {
    if (interestClaimSubTotal[i] < interestClaim[i])
    {
      interestClaimSubTotal[i] = interestClaimSubTotal[i] + principalPaymentInPeriod
      interestPaidSubTotal[i] = interestClaimSubTotal[i] + interestPaymentInperiod
      interestCashflowsForPeriod[i] = interestPaymentInperiod
      break
    }
    else
    {
      interestTrancheFull[i] = TRUE
    }
  }
  #when full, allocate to the Junior tranche
  TrueList = which(interestTrancheFull == TRUE)
  if (length(TrueList) == length(interestClaimExJunior))
  {
    i = i + 1
    interestPaidSubTotal[i] = interestPaidSubTotal[i] + interestPaymentInperiod
    interestCashflowsForPeriod[length(interestCashflowsForPeriod)] = interestPaymentInperiod
  }
  #add the cashflows to the Dataframe
  dfRow <- data.frame(principalCashflowsForPeriod[1],principalCashflowsForPeriod[2],
                      principalCashflowsForPeriod[3],interestCashflowsForPeriod[1],
                      interestCashflowsForPeriod[2],interestCashflowsForPeriod[3])                  
  names(dfRow) <- colNamesList
  dfCashflows <- rbind(dfCashflows, dfRow)
}

areaplot(paymentPeriods, dfCashflows, col=c("navy","royalblue","black","skyblue4","skyblue","paleturquoise"),
         ylim = c(0,totalPaymentInPeriod), border=FALSE, ylab = "", xlab = "Month", legend = FALSE,
         main="Equivilent Chart from mainR.R")


