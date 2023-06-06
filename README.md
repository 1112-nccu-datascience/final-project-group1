# [Group1] your projrct title
The goals of this project.

## Contributors
|組員|系級|學號|工作分配|
|-|-|-|-|
|顧以恩|統計三|109304033||
|張翊鞍|統計四|108304004||
|程至榮|資碩一|111753151||
|高語謙|資碩一|111753130||
|吳家瑋|資碩一|111753141||


## Quick start
You might provide an example commend or few commends to reproduce your analysis, i.e., the following R script
```R
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
* Output
  * `submission.csv`
    * (row) 75818 customers x (column) 2 features, 130 MB

### code
* data preprocessing
  * remove all zero features
  * remove identical features
  * remove constant features
* create additional features
  * var38mc、logvar38、log_saldo_var30 
* remove outliers
* model tuning
* Analysis steps
* Which method or package do you use? 
  * original packages in the paper
  * additional packages you found

### results
* What is a null model for comparison?
* How do your perform evaluation?
  * Cross-validation, or extra separated data

## References
* Packages you use
* Related publications
