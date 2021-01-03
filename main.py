import pandas as pd
import numpy as np
import os
import math
from mortgage import Loan
import matplotlib.pylab as plt
from pandas.plotting import register_matplotlib_converters

def CollateralisedMortgageObligationWaterfall(cmo):
    
    dfCashflows = pd.DataFrame(columns = ['Month','Senior_principal','Mezzanine_principal',
        'Junior_principal','Senior_interest','Mezzanine_interest','Junior_interest'])
    principal = np.array([cmo['trancheSenior_principalowed'], 
        cmo['trancheMezzanine_principalowed'],cmo['trancheJunior_principalowed']])
    interestClaim = np.array([cmo['trancheSenior_interestclaim'],
        cmo['trancheMezzanine_interestclaim'],cmo['trancheJunior_interestclaim']])
    interestRate = cmo['interest_rate']
    paymentYears = cmo['payment_years']

    if sum(principal) != float(cmo['total_size']) or sum(interestClaim) != float(cmo['total_size']):
        print ("Principal / Interest Claim Tranche allocations do not equate to the total size!")
        return

    paymentPeriods = paymentYears * 12
    principalExJunior = np.resize(principal, len(principal) -1)
    principalPaidSubtotal = [0,0,0]
    principalTrancheFull = [False,False]  
    interestClaimExJunior = np.resize(interestClaim, len(interestClaim) -1)  
    interestClaimSubTotal = [0,0,0]
    interestPaidSubTotal = [0,0,0]
    interestTrancheFull = [False,False] 

    loan = Loan(principal=float(sum(principal)), 
        interest=float(interestRate), term=int(paymentYears))
    
    for m in range(paymentPeriods):
        principalInPeriod = float(loan.schedule(m+1).principal)
        interestInPeriod = float(loan.schedule(m+1).interest)
        #allocate the principal payments to all tranches sequentially 
        #except Junior when these are not full
        principalCashflowsForPeriod = np.array([0,0,0])
        for i in range(len(principalExJunior)):
            if principalPaidSubtotal[i] < principal[i]:
                principalPaidSubtotal[i] += principalInPeriod
                principalCashflowsForPeriod[i] = principalInPeriod
                break
            else:
                principalTrancheFull[i] = True
        #when full, allocate to the Junior tranche
        TrueList = [j for j, x in enumerate(principalTrancheFull) if x]
        if len(TrueList) == len(principalExJunior):
            i += 1
            principalPaidSubtotal[i] =+ principalInPeriod
            principalCashflowsForPeriod[len(principalCashflowsForPeriod)-1] = principalInPeriod
        #allocate the interest payments to all tranches sequentially
        #except Junior when these are not full
        interestCashflowsForPeriod = np.array([0,0,0])
        for i in range(len(interestClaimExJunior)):
            if interestClaimSubTotal[i] < interestClaim[i]:
                interestClaimSubTotal[i] += principalInPeriod
                interestPaidSubTotal[i] += interestInPeriod
                interestCashflowsForPeriod[i] = interestInPeriod
                break
            else:
                interestTrancheFull[i] = True
        #when full, allocate to the Junior tranche
        TrueList = [j for j, x in enumerate(interestTrancheFull) if x]
        if len(TrueList) == len(interestClaimExJunior):
            i += 1
            interestPaidSubTotal[i] += interestInPeriod
            interestCashflowsForPeriod[len(interestCashflowsForPeriod)-1] = interestInPeriod
        #add the cashflows to the dataframe
        row = np.append(np.append(m+1,principalCashflowsForPeriod),
            interestCashflowsForPeriod)
        dfCashflows.loc[len(dfCashflows)] = row 

    dfCashflows.plot.area(x = 'Month', y = ['Senior_principal','Mezzanine_principal',
        'Junior_principal','Senior_interest','Mezzanine_interest','Junior_interest'], 
        color = ['navy','royalblue','slategrey','steelblue','cornflowerblue','aqua'])
    plt.title('CMO Cashflows by Tranche Type')
    plt.show()

    print(dfCashflows[['Senior_principal','Mezzanine_principal',
        'Junior_principal','Senior_interest','Mezzanine_interest','Junior_interest']].sum())



if __name__ == '__main__':
    
    cmo = dict()
    cmo['trancheSenior_principalowed'] = 21000000
    cmo['trancheSenior_interestclaim'] = 20400000
    cmo['trancheMezzanine_principalowed'] = 9000000
    cmo['trancheMezzanine_interestclaim'] = 4800000
    cmo['trancheJunior_principalowed'] = 0
    cmo['trancheJunior_interestclaim'] = 4800000
    cmo['total_size'] = 30000000
    cmo['interest_rate'] = 0.0625
    cmo['payment_years'] = 30

    CollateralisedMortgageObligationWaterfall(cmo)
