library(tidyverse)
library(xgboost)
library(caret)

set.seed(123)

train <- read.csv("train.csv")
test  <- read.csv("test.csv")

##### Removing IDs
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL

##### Extracting TARGET
train.y <- train$TARGET
train$TARGET <- NULL

##### 0 count per line
count0 <- function(x) {
  return(sum(x == 0))
}
train$n0 <- apply(train, 1, FUN = count0)
test$n0 <- apply(test, 1, FUN = count0)

##### Removing constant features
cat("\n## Removing the constants features.\n")
for (f in names(train)) {
  if (length(unique(train[[f]])) == 1) {
    # cat(f, "is constant in train. We delete it.\n")
    train[[f]] <- NULL
    test[[f]] <- NULL
  }
}

##### Removing identical features
features_pair <- combn(names(train), 2, simplify = F)
toRemove <- c()
for (pair in features_pair) {
  f1 <- pair[1]
  f2 <- pair[2]
  
  if (!(f1 %in% toRemove) & !(f2 %in% toRemove)) {
    if (all(train[[f1]] == train[[f2]])) {
      # cat(f1, "and", f2, "are equals.\n")
      toRemove <- c(toRemove, f2)
    }
  }
}

feature.names <- setdiff(names(train), toRemove)

train <- train[, feature.names]
test <- test[, feature.names]


# Create additional features
# var38mc == 1 when var38 has the most common value and 0 otherwise
# logvar38 is log transformed feature when var38mc is 0, zero otherwise

train <- train %>%
  # This column mark the most common value
  mutate(var38mc = ifelse(near(var38, 117310.979016494), 1, 0),) %>%
  
  # This column will be normal distributed
  mutate (logvar38 = ifelse(var38mc == 0, log(var38), 0))

test <- test %>%
  # This column mark the most common value
  mutate(var38mc = ifelse(near(var38, 117310.979016494), 1, 0),) %>%
  
  # This column will be normal distributed
  mutate (logvar38 = ifelse(var38mc == 0, log(var38), 0))


# add log_saldo_var30
train$log_saldo_var30 <- train$saldo_var30

smallest_positive_value <-
  min(train$log_saldo_var30[train$log_saldo_var30 > 0], na.rm = TRUE)

# remove negitive values
train$log_saldo_var30[train$log_saldo_var30 < smallest_positive_value] <-
  smallest_positive_value

train <- train %>%
  mutate(log_saldo_var30 = ifelse(
    log_saldo_var30 > smallest_positive_value,
    log(log_saldo_var30),
    0
  ))


test$log_saldo_var30 <- test$saldo_var30

smallest_positive_value <-
  min(test$log_saldo_var30[test$log_saldo_var30 > 0], na.rm = TRUE)

# remove negitive values
test$log_saldo_var30[test$log_saldo_var30 < smallest_positive_value] <-
  smallest_positive_value

test <- test %>%
  mutate(log_saldo_var30 = ifelse(
    log_saldo_var30 > smallest_positive_value,
    log(log_saldo_var30),
    0
  ))

##### limit vars in test based on min and max vals of train (Remove Outlier)
print('Setting min-max lims on test data')
for (f in colnames(train)) {
  lim <- min(train[, f])
  test[test[, f] < lim, f] <- lim
  
  lim <- max(train[, f])
  test[test[, f] > lim, f] <- lim
}


##### Model Tuning
train$TARGET <- train.y
train <- train %>% 
  mutate(
    TARGET = as.factor(ifelse(TARGET == 1, "y", "n")),
  )

trctrl <- trainControl(
  method = "cv", 
  number = 5,
  search = "grid",
  classProbs = TRUE,
)

tune_grid <- expand.grid(
  nrounds = 200,
  max_depth = 5,
  eta = 0.05,
  gamma = 0.01,
  colsample_bytree = 0.75,
  min_child_weight = 0,
  subsample = 0.5
)

fit <- caret::train(
  TARGET ~ .,
  data = train,
  method = "xgbTree",
  trControl = trctrl,
  tuneGrid = tune_grid,
)

preds <- predict(fit, test, type = "prob")
preds <- preds[, 2]

############################# Post processing
tc <- test
nv = tc['num_var33']+tc['saldo_medio_var33_ult3']+tc['saldo_medio_var44_hace2']+tc['saldo_medio_var44_hace3']+
  tc['saldo_medio_var33_ult1']+tc['saldo_medio_var44_ult1']

preds[nv > 0] = 0
preds[tc['var15'] < 23] = 0
preds[tc['saldo_medio_var5_hace2'] > 160000] = 0
preds[tc['saldo_var33'] > 0] = 0
preds[tc['var38'] > 3988596] = 0
preds[tc['var21'] > 7500] = 0
preds[tc['num_var30'] > 9] = 0
preds[tc['num_var13_0'] > 6] = 0
preds[tc['num_var33_0'] > 0] = 0
preds[tc['imp_ent_var16_ult1'] > 51003] = 0
preds[tc['imp_op_var39_comer_ult3'] > 13184] = 0
preds[tc['saldo_medio_var5_ult3'] > 108251] = 0
preds[tc['num_var37_0'] > 45] = 0
preds[tc['saldo_var5'] > 137615] = 0
preds[tc['saldo_var8'] > 60099] = 0
preds[(tc['var15']+tc['num_var45_hace3']+tc['num_var45_ult3']+tc['var36']) <= 24] = 0
preds[tc['saldo_var14'] > 19053.78] = 0
preds[tc['saldo_var17'] > 288188.97] = 0
preds[tc['saldo_var26'] > 10381.29] = 0
preds[tc['num_var13_largo_0'] > 3] = 0
preds[tc['imp_op_var40_comer_ult1'] > 3639.87] = 0
preds[tc['num_var5_0'] > 6] = 0
preds[tc['saldo_medio_var13_largo_ult1'] > 0] = 0
preds[tc['num_meses_var13_largo_ult3'] > 0] = 0
preds[tc['num_var20_0'] > 0] = 0  
preds[tc['saldo_var13_largo'] > 150000] = 0
preds[tc['num_var17_0'] > 21] = 0
preds[tc['num_var24_0'] > 3] = 0
preds[tc['num_var26_0'] > 12] = 0
preds[tc['num_op_var40_hace2'] > 12] = 0

#############################

predict_df <- data_frame(Id = test.id, TARGET = preds)

write.csv(
  predict_df,
  file = 'submission.csv',
  quote = FALSE,
  row.names = FALSE
)
