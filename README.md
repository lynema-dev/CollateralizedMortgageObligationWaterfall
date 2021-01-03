# CollateralizedMortgageObligationWaterfall

A Collateralized Mortgage Obligation (CMO) is a Structured Product that consists of a pool of mortgages seperated into different tranches according to seniority.  In this example the Senior tranche sits at the top.  This receives the principal and interest payments fom the morgage holders until the point that it becomes 'full' and then these are passed to the Mezzanine tranche which takes the rest of the principal and interest payments until full, and then the Junior tranche recieves the remainder.  The chart belows shows how this 'Waterfall' process looks like over the life of the mortage pool which is this case is 30 years or 360 months.

This example assumes there are no defaults from the mortage holders and no prepayments although these features may be added in a future version.  Typically these are absorbed in reverse, starting with the Junior tranche to protect the the more senior tranches and the price of the Junior tranche relative to the other tranches reflects this risk.

CMOs largely exist in the US but there are similar examples in other countries.
