# (The Score is already better then To the topV3)
# Private: 0.82568
# Public: 0.83734

start_time <- Sys.time()
options(warn = -1)

library(tidyverse)
library(xgboost)
library(caret)

print("Parsing Arguments......")
args <- commandArgs(trailingOnly = TRUE)
train_path <- NA
test_path <- NA
predict_path <- NA

if (length(args) < 6) {
    stop("Missing argument, check your command format", call. = FALSE)
} else {
    for (args_counter in seq_along(args)) {
        if (args[args_counter] == "--train") {
            if (!file_test("-f", args[args_counter + 1])) {
                print(args[args_counter + 1])
                stop("train_csv is not defined, or not correctly named.")
            } else {
                train_path <- args[args_counter + 1]
            }
        } else if (args[args_counter] == "--test") {
            if (!file_test("-f", args[args_counter + 1])) {
                print(args[args_counter + 1])
                stop("test_csv not defined, or not correctly named.")
            } else {
                test_path <- args[args_counter + 1]
            }
        } else if (args[args_counter] == "--predict") {
            predict_path <- args[args_counter + 1]
        }
    }
}

if (is.na(train_path)) {
    stop("Missing --train argument", call. = FALSE)
} else if (is.na(test_path)) {
    stop("Missing --test argument", call. = FALSE)
} else if (is.na(predict_path)) {
    stop("Missing --predict argument", call. = FALSE)
}

print("loading Data......")
train <- read.csv(train_path)
test <- read.csv(test_path)

set.seed(123)

##### Removing IDs
train$ID <- NULL
test.id <- test$ID
test$ID <- NULL

##### Extracting TARGET
train.y <- train$TARGET
train$TARGET <- NULL

# -999999 means the nationality is unknown, replace it with the most common value 2 in this column
train <- train %>%
    mutate(var3 = ifelse(train$var3 == -999999, 2, train$var3), )

##### 0 count per line
cat("\n## count0.\n")
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
cat("\n## Removing identical features.\n")
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
cat("\n## Create additional features.\n")

train <- train %>%
    # This column mark the most common value
    mutate(var38mc = ifelse(near(var38, 117310.979016494), 1, 0), ) %>%
    # This column will be normal distributed
    mutate(logvar38 = ifelse(var38mc == 0, log(var38), 0))

test <- test %>%
    # This column mark the most common value
    mutate(var38mc = ifelse(near(var38, 117310.979016494), 1, 0), ) %>%
    # This column will be normal distributed
    mutate(logvar38 = ifelse(var38mc == 0, log(var38), 0))


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
print("Setting min-max lims on test data")
for (f in colnames(train)) {
    lim <- min(train[, f])
    test[test[, f] < lim, f] <- lim

    lim <- max(train[, f])
    test[test[, f] > lim, f] <- lim
}

cat("\n## Model Tuning.\n")
##### Model Tuning
train$TARGET <- train.y
train <- train %>%
    mutate(TARGET = as.factor(ifelse(TARGET == 1, "y", "n")), )

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

##### Evaluation:Confusion Matrix for training set
train_evl <- predict(fit,train,type="prob")
train_preds <- as.factor(ifelse(train_evl[, 2] > 0.5, "y", "n"))
confusion_matrix <- confusionMatrix(train_preds, train$TARGET)
print(confusion_matrix)

##### Predicting and Saving Files
preds <- predict(fit, test, type = "prob")
pred_prob_y <- preds[, 2]

predict_df <- data_frame(Id = test.id, TARGET = pred_prob_y)

### create folders
cat("\n## create folders.\n")
folders <- unlist(strsplit(predict_path, "[/]"))
base_path <- folders[1]

if (length(folders) > 1) {
    for (i in 2:length(folders)) { 
        if (!file.exists(base_path)) {
            dir.create(base_path)
        }
        assign("base_path", paste0(base_path, "/", folders[i]))
    }
}

cat("\n## write csv.\n")
write.csv(predict_df,
    file = predict_path,
    quote = FALSE,
    row.names = FALSE
)

print("Success!")
end_time <- Sys.time()
print(end_time - start_time)