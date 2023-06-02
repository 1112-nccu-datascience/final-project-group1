# 跑不出來
# Private: 
# Public: 

library(tidyverse)
library(ROSE)   # For oversampling the minority class
library(caret)  # For Classification And Regression Training

set.seed(123)

train <- read.csv("./data/Input/train.csv")
test  <- read.csv("./data/Input/test.csv")

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

train$TARGET <- train.y
train <- train %>% 
    mutate(
        TARGET = as.factor(ifelse(TARGET == 1, "y", "n")),
    )

# Balancing classes using oversampling
oversampling <- function(origin_data) {
    new_data <- ROSE(TARGET ~ ., data = origin_data)$data
    return(new_data)
}

train <- train %>% oversampling()

##### Model Tuning
trctrl <- trainControl(
    method = "cv",
    number = 5,
    search = "grid",
    classProbs = TRUE,
    summaryFunction = prSummary,
)

tune_grid <- expand.grid(
    usekernel = c(TRUE, FALSE),
    fL = c(0.1), # Laplace smoothing
    adjust = c(0.5)
)

fit <- caret::train(
    TARGET ~ .,
    data = train,
    method = "nb",
    metric = "F",
    tuneGrid = tune_grid,
    trControl = trctrl,
    verbose = TRUE,
)

preds <- predict(fit, test, type = "prob")
pred_prob_y <- preds[, 2]

predict_df <- data_frame(Id = test.id, TARGET = pred_prob_y)

write.csv(
    predict_df,
    file = './data/Output/submission_nb_V1.csv',
    quote = FALSE,
    row.names = FALSE
)
