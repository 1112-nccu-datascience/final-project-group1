library(tidyverse)

train <- read.csv("./data/Input/train.csv")

train_clean <- train %>%
    mutate(ID = NULL, TARGET = NULL)


# Removing constant features
for (f in names(train_clean)) {
    if (length(unique(train_clean[[f]])) == 1) {
        cat(f, "is constant in train. We delete it.\n")
        train_clean[[f]] <- NULL
    }
}

train_clean.pca <- prcomp(train_clean, center = TRUE, scale. = TRUE)

# show variance explained (first 10)
train_clean.summary <- summary(train_clean.pca)
train_clean.summary$importance[2, 1:10]

# At least PC100 for 95% variance explained
sum(train_clean.summary$importance[2, 1:10])
sum(train_clean.summary$importance[2, 1:20])
sum(train_clean.summary$importance[2, 1:30])
sum(train_clean.summary$importance[2, 1:40])
sum(train_clean.summary$importance[2, 1:50])
sum(train_clean.summary$importance[2, 1:60])
sum(train_clean.summary$importance[2, 1:70])
sum(train_clean.summary$importance[2, 1:80])
sum(train_clean.summary$importance[2, 1:90])
sum(train_clean.summary$importance[2, 1:100])