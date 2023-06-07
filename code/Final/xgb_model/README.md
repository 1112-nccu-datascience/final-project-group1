* xgb_V2_最高分.R 可以拿到最高分的 leaderboard 分數，可以根據這份檔案算 evaluatoin (f1, AUC 等)

===============================================================
* xgb_caret_挑選超參數.ipynb 內的這三行會印出實驗出的最佳超參數:
```
best_params <- fit$bestTune   # Best parameter settings
best_model <- fit$finalModel  # Best model
print(best_params)
```

* xgb_V5_標記重要參數.R 
可以看出哪些參數對 xgboost 訓練是重要的

* xgb_ROSE_oversampling.R 
實驗結果發現加入 Oversampling 的效果並不好，準確度掉到 0.5 左右

