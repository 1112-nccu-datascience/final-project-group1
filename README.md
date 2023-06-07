# [Group1] Review Santander Customer Satisfaction Contest with R
Our goals of this project:
Customer satisfaction is a key measure of success. Unhappy customers don't stick around. What's more, unhappy customers rarely voice their dissatisfaction before leaving.
In this competition, we want to predict if a customer is satisfied or dissatisfied with their banking experience.And this competition also enhances our ability to deal with hundreds of anonymized features.We would do lots of data prepocessings to select、create or remove the variables,so we can better predict and increace the accuracy.
Our goals of this project:
Customer satisfaction is a key measure of success. Unhappy customers don't stick around. What's more, unhappy customers rarely voice their dissatisfaction before leaving.
In this competition, we want to predict if a customer is satisfied or dissatisfied with their banking experience.And this competition also enhances our ability to deal with hundreds of anonymized features.We would do lots of data prepocessings to select、create or remove the variables,so we can better predict and increace the accuracy.
## Contributors
|組員|系級|學號|工作分配|
|-|-|-|-|
|顧以恩|統計三|109304033|實驗、視覺化、簡報|
|張翊鞍|統計四|108304004|實驗、readme|
|程至榮|資碩一|111753151|實驗、視覺化、簡報|
|高語謙|資碩一|111753130|實驗、視覺化、簡報|
|吳家瑋|資碩一|111753141|實驗、poster|

## Quick start
The following R script shows how to execute the best xgboost model we have experimented and output the result to your designate directory. We have put the source code in `/code/Final` directory, including the main.R (Best model) and other experiment source code (like PCA, data exploration, etc.). Feel free to checkit
```R
Rscript code/Final/main.R --train data/Input/train.csv --test data/Input/test.csv --predict data/Output/submission.csv
Rscript code/Final/main.R --train data/Input/train.csv --test data/Input/test.csv --predict data/Output/submission.csv
```

## Folder organization and its related description
idea by Noble WS (2009) [A Quick Guide to Organizing Computational Biology Projects.](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1000424) PLoS Comput Biol 5(7): e1000424.

### docs
* Your presentation, 1112_DS-FP_groupID.ppt/pptx/pdf (i.e.,1112_DS-FP_group1.ppt), by **06.08**
* Any related document for the project
  * i.e., software user guide

### data
* Input
  * Source : kaggle [Santander Customer Satisfaction](https://www.kaggle.com/c/santander-customer-satisfaction)
  * `train.csv`
    * (row) 76020 customers x (column) 371 features, 59.36 MB
  * `test.csv`
    * (row) 75818 customers x (column) 370 features, 59.05 MB
  * Source : kaggle [Santander Customer Satisfaction](https://www.kaggle.com/c/santander-customer-satisfaction)
  * `train.csv`
    * (row) 76020 customers x (column) 371 features, 59.36 MB
  * `test.csv`
    * (row) 75818 customers x (column) 370 features, 59.05 MB
    * 
* Internal
  * `Undeesampling50.csv`
    *  (row) 6016 customers x (column) 370 features, 4.04 MB
  * `Undeesampling20.csv`
    *  (row) 15040 customers x (column) 370 features, 10.14 MB
* Output
  * `submission.csv`
    * (row) 75818 customers x (column) 2 features, 0.6 MB
  * `submission.csv`
    * (row) 75818 customers x (column) 2 features, 0.6 MB

### code
* Analysis steps
  * data preprocessing
    * remove all zero features
    * remove identical features
    * remove constant features
  * create additional features
    * var38mc、logvar38、log_saldo_var30 
  * remove outliers
  * model tuning

  * data preprocessing
    * remove all zero features
    * remove identical features
    * remove constant features
  * create additional features
    * var38mc、logvar38、log_saldo_var30 
  * remove outliers
  * model tuning

* Which method or package do you use? 
  * original packages in the paper
  * additional packages you found
    * tidyverse、xgboost、caret
    * tidyverse、xgboost、caret

### results
* What is a null model for comparison?
  * Using xgboost without any modification as null model with 0.81 accuracy
  * Using xgboost without any modification as null model with 0.81 accuracy
* How do your perform evaluation?
  * Cross-validation : 10 fold in xgboost parameter
  * or extra separated data
  * Cross-validation : 10 fold in xgboost parameter
  * or extra separated data

## References
* Packages you use
  * tidyverse: https://www.tidyverse.org/
  * xgboost: https://xgboost.readthedocs.io/en/stable/
  * caret: https://cran.r-project.org/web/packages/caret/index.html
* Related publications 
  * Feature Explore: https://www.kaggle.com/code/cast42/exploring-features
  * Xgboost example https://www.kaggle.com/code/zfturbo/to-the-top-v3

