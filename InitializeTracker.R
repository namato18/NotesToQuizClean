tracker = data.frame(
  username = character(),
  correct = numeric(),
  attempted = numeric()
)

saveRDS(tracker, "NotesToQuiz/tracker.rds")
