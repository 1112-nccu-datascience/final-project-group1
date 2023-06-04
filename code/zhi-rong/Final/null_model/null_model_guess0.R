# Since the unsatisfied customer are rare, then well just guess all customer are satisfied (means 0)

test  <- read.csv("./data/test.csv")

predict_df <- data.frame( ID = test$ID, TARGET = rep(0, length(test[, 1])) )

write.csv(
    predict_df,
    file = './output/null_submission.csv',
    quote = FALSE,
    row.names = FALSE
)