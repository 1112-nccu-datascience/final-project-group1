library(tidyverse)

train <- read.csv("./data/train.csv")
test  <- read.csv("./data/test.csv")

train_clean <- train %>% mutate(
    ID = NULL,
    TARGET = NULL
)
test_clean <- test %>% mutate(ID = NULL)


