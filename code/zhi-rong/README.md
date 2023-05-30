# Notes

### The only useful reference

Exploring features
https://www.kaggle.com/code/cast42/exploring-features/notebook#var15

To the TOP v3 (0.82451)
https://www.kaggle.com/code/zfturbo/to-the-top-v3


Santander - Starter with PCA
https://www.kaggle.com/code/dmi3kno/santander-starter-with-pca


### Our Target
To improve the performance of "To the TOP v3" 

### How to do it?
* Explore the feature.
* Use the "To the TOP v3" as the base template
* Trying to PCA & Chi2 feature selection
* Trying Other Predicting models
* Ensemble the Predictions

### experiment score record
* To the topV3
Private: 0.82451
Public: 0.84116

* Guess all 0 (null model)
Private: 0.5 
Public: 0.5

* Without any preprocess, use all features to predict. Model use xgboost.
Private: 0.81965
Public: 0.83217

* Without feature selection, Using only PCA to reduce the dimention to 100 + xgboost
Private: 0.79923
Public: 0.81264

* add logvar38, var28mc, log_saldo_var30 and basic data cleaning + xgboost (No PCA)
Private: 0.81994
Public: 0.83188

* add cross validation
Private: 0.82122
Public: 0.83489

