The data set contains transactions made by credit cards in September 2013 by
European cardholders.
This data set presents transactions that occurred in two days, where we have
492 frauds out of 284,807 transactions. The data set is highly unbalanced, the
positive class (frauds) account for 0.172% of all transactions.
It contains only numerical input variables which are the result of a PCA
transformation. Unfortunately, due to confidentiality issues, we cannot provide
the original features and more background information about the data.
Features V1, V2, . . . V28 are the principal components obtained with PCA,
the only features which have not been transformed with PCA are ’Time’ and
’Amount’. Feature ’Time’ contains the seconds elapsed between each transaction
and the first transaction in the data set. The feature ’Amount’ is the transaction
Amount, this feature can be used for example-dependent cost-sensitive learning.
Feature ’Class’ is the response variable and it takes value 1 in case of fraud and
0 otherwise.
We mainly fit the data with logistic regression and calculate the AUC score and draw the ROC
Curve to see how much area the fitted line is taken under it.
