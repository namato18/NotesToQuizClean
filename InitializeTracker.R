## Initialize Tracker

tracker = data.frame(
  username = character(),
  correct = numeric(),
  attempted = numeric()
)

saveRDS(tracker, "NotesToQuiz/tracker.rds")


## Initialize Boneyard

boneyard = data.frame(
  uid = character(),
  username = character(),
  password = character(),
  email = character(),
)