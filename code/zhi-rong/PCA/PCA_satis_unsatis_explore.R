library(tidyverse)

train <- read.csv("./data/Input/train.csv")


### Not useful, skip
satisfied_df <- train %>%
    filter (train$TARGET == 0)

unsatisfied_df <- train %>%
    filter (train$TARGET == 1)

satisfied_clean <-
    satisfied_df %>%
    mutate(ID = NULL,
           TARGET = NULL)

unsatisfied_clean <-
    unsatisfied_df %>%
    mutate(ID = NULL,
           TARGET = NULL)

# Removing constant features
for (f in names(satisfied_clean)) {
    if (length(unique(satisfied_clean[[f]])) == 1) {
        cat(f, "is constant in train. We delete it.\n")
        satisfied_clean[[f]] <- NULL
    }
}

for (f in names(unsatisfied_clean)) {
    if (length(unique(unsatisfied_clean[[f]])) == 1) {
        cat(f, "is constant in train. We delete it.\n")
        unsatisfied_clean[[f]] <- NULL
    }
}

satisfied_clean.pca <-
    prcomp(satisfied_clean, center = TRUE, scale. = TRUE)
unsatisfied_clean.pca <-
    prcomp(unsatisfied_clean, center = TRUE, scale. = TRUE)

# show variance explained (first 10)
satisfied_clean.summary <- summary(satisfied_clean.pca)
satisfied_clean.summary$importance[2, 1:10]
sum(satisfied_clean.summary$importance[2, 1:10])


unsatisfied_clean.summary <- summary(unsatisfied_clean.pca)
unsatisfied_clean.summary$importance[2,1:10]
sum(unsatisfied_clean.summary$importance[2, 1:10])

sum(unsatisfied_clean.summary$importance[2, 1:50])

### plot
# satisfied_clean.important_components <- satisfied_clean.pca$rotation[, 1:2]
# unsatisfied_clean.important_components <- unsatisfied_clean.pca$rotation[, 1:2]
# 
# satisfied_pca_df <- as.data.frame(satisfied_clean.important_components)
# unsatisfied_pca_df <- as.data.frame(unsatisfied_clean.important_components)
# 
# base_plot <- ggplot()
# base_plot <-
#     base_plot + ggtitle("Only select 2 first principle components")
# base_plot <-
#     base_plot + geom_point(data = satisfied_pca_df, aes(x = PC1, y = PC2), colour = "blue")
# base_plot <-
#     base_plot + geom_point(data = unsatisfied_pca_df, aes(x = PC1, y = PC2), colour = "green")
# 
# base_plot
