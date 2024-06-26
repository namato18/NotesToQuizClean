library(shiny)
library(shinycssloaders)
library(shinythemes)
library(shinybusy)
library(shinyjs)
library(purrr)
library(shiny.router)
library(uuid)
library(shinyalert)
library(DT)
library(aws.s3)


apiKey = readRDS("apiKey.rds")
access_key = readRDS('access_key.rds')
secret_key = readRDS("secret_key.rds")

Sys.setenv(
  "AWS_ACCESS_KEY_ID" = access_key,
  "AWS_SECRET_ACCESS_KEY" = secret_key,
  "AWS_DEFAULT_REGION" = "us-east-1"
)
# Sys.getenv()



possibly_s3readRDS = possibly(s3readRDS, otherwise = "ERROR")
possibly_s3read_using = possibly(s3read_using, otherwise = 'ERROR')
possibly_readRDS = possibly(readRDS, otherwise = "ERROR")
credentials = possibly_readRDS("credentials.rds")
tracker = readRDS("tracker.rds")
if(length(credentials) == 1){
  x = data.frame(
    username = character(),
    password = character()
  )
  
  saveRDS(x, "credentials.rds")
  credentials = possibly_readRDS("credentials.rds")
}
print(credentials)
print(tracker)

main_app <- div( id = "mainDiv",
                 
                 useShinyjs(),
                 
                 # theme = shinytheme("darkly"),
                 add_busy_spinner(spin = "fading-circle", color = "white", height = "80px", width = "80px", position = "bottom-right"),
                 
                 
                 tags$head(
                   includeScript('funcs.js'),
                   includeCSS('styles.css'),
                   tags$link(rel = "icon", type = "image/png", href = "logo.png")
                 ),
                 
                 column(width = 12,
                        div(class = "title-bar",
                            style = "display: flex; justify-content: space-between; align-items: center;",
                            div(
                              style = "margin: 0 auto;",
                              "AI Notes to Quiz Generator",
                              actionButton(inputId = "logoutButton", "Logout"),
                              actionButton(inputId = "feedback", "Feedback")
                            ),
                            div(
                              img(src = "logo.png", height = 75, width = 75)
                            )
                        )
                 ),
                 
                 
                 
                 sidebarLayout(
                   sidebarPanel(
                     # actionButton("answer-toggle", "Click Me"),
                     textOutput("userID"),
                     strong("Intro:"),
                     paste0("This application utilizes AI to digest your pdf input and generate a quiz based on it's contents! ",
                            "To generate a quiz, drag and drop or select your pdf from the picker. Next, select how many questions you'd like to generate. ",
                            "And that's it! Now all you have to do is click the 'Generate Quiz' button and wait a couple seconds."),
                     br(),
                     br(),
                     strong("Submit Quiz:"),
                     paste0("Once you've finished uploading/generating your quiz, complete the quiz and hit the submit button at the bottom to check your results",
                            " If you score above an 80%, a recommendation will appear below suggesting that you either increase the number of questions, ",
                            "or increase the difficulty of the questions (increase difficulty can be found next to the submit answers button)"),
                     br(),
                     br(),
                     strong("Score Tracking:"),
                     paste0("Your session score will appear above the generated quiz, this score simply tracks how many questions you've gotten correct vs ",
                            "how many questions you've attempted!"),
                     br(),
                     br(),
                     fileInput("pdfInput", label = "Drop Your PDF Here:"),
                     selectInput("selectType", label = "Select Type of Generation", choices = list("Quiz" = "Quiz", "Anki Cards" = "Anki")),
                     sliderInput("numQuestions", label = "How Many Questions Would You Like to Generate?", min = 1, max = 25, value = 5),
                     # selectInput("difficulty", label = "Select a Difficulty", choices = c("Easy","Medium","Hard")),
                     actionButton("submit1", label = "Generate!", class = 'btn-primary'),
                     br(),
                     br(),
                     textOutput("scoreSuggestion")
                   ),
                   
                   mainPanel(
                     
                     # For ANKI
                     downloadButton("downloadData", "Download CSV", class = 'btn-primary'),
                     br(),
                     br(),
                     dataTableOutput("ankiTable"),
                     
                     # For Quiz
                     textOutput("sessionCounter"),
                     htmlOutput("response"),
                     div(class = "button-container",
                         actionButton(inputId = "submitAnswers", label = "Submit Answers", class = "btn-primary"),
                         actionButton("reset", label = "Reset Quiz", class = "btn-primary"),
                         actionButton("filteredReset", label = "Reset & Remove Questions You Got Right", class = "btn-primary"),
                         actionButton("fresh", label = "Fresh Set of Questions (Same Difficulty)", class = "btn-primary"),
                         actionButton("harder", label = "Make Harder", class = 'btn-primary'),
                     )
                     
                     
                     
                     
                   )
                 )
)

login_page <- 
  tags$div(class = "login-page",
           tags$div(class = "stars"),
           tags$div(class = "login-box",
                    h2("AI Notes to Quiz Login"),
                    tags$form(
                      textInput(inputId = "username",label = NULL, placeholder = "Username..."),
                      textInput(inputId = "password",label = NULL, placeholder = "Password..."),
                      # tags$input(type = "text", placeholder = "Username", required = "required"),
                      # tags$input(type = "password", placeholder = "Password", required = "required"),
                      # tags$button(type = "submit", id = "loginButton", "Login"),
                      actionButton(inputId = "loginButton", "Login", class = "btn-login")
                    ),
                    actionButton(inputId = "createAccount", "Create Account", class = "create-account-btn"),
                    # actionButton(inputId = "createAccountPaid", "Create Account Paid", class = "create-account-btn"),
                    div(id = "statusDiv",
                        class = "status-text",
                        textOutput("status")
                        
                    )
           )
           
           
           
  )




# success_page <- tags$div(class = "success-page",
#                          tags$div(class = "success-box",
#                                   h2("Set Username & Password"),
#                                   tags$form(
#                                     textInput(inputId = "usernamePaid",label = NULL, placeholder = "Username..."),
#                                     textInput(inputId = "passwordPaid",label = NULL, placeholder = "Password..."),
#                                     actionButton(inputId = "toApp", "Take Me Into The App!", class = "btn-login")
#                                   ),
#                                   
#                                   
#                                   div(id = "statusDivPaid",
#                                       class = "status-text",
#                                       textOutput("statusPaid")
#                                   )
#                                   
#                          )
# )


source("Funcs.R")
# answer_letters = readRDS("answer_letters.rds")
# test_text = readRDS("test_text.rds")

# Define UI for application that draws a histogram
ui <- fluidPage(
  router_ui(
    route("/", login_page),
    route("main", main_app)
    # route("success", success_page)
  )
  
)

# ui <- secure_app(ui, enable_admin = TRUE)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  router_server()
  
  shinyjs::hide("sessionCounter")
  shinyjs::hide('downloadData')
  shinyjs::hide('submitAnswers')
  shinyjs::hide('reset')
  shinyjs::hide('harder')
  shinyjs::hide('fresh')
  shinyjs::hide('filteredReset')
  shinyjs::hide("response")
  shinyjs::hide("ankiTable")
  
  options(shiny.maxRequestSize=300*1024^2)
  
  rv = reactiveValues(answer_letters = character(),
                      original_answers = character(),
                      answer_index = numeric(),
                      session_correct = 0,
                      session_total = 0,
                      round_correct = 0,
                      round_total = 0,
                      ind_correct = numeric(),
                      credentials = credentials,
                      tracker = tracker,
                      username = character(),
                      running_total = 0,
                      ankiTable = character(),
                      feedback = character())
  
  
  
  observeEvent(input$submit1, {
    shinyjs::show('harder')
    
    Type = input$selectType
    pdf_filepath = input$pdfInput$datapath
    numQuestions = input$numQuestions
    
    if(Type == "Quiz"){
      shinyjs::hide('ankiTable')
      shinyjs::hide("downloadData")
      
      shinyjs::show("response")
      shinyjs::show("sessionCounter")
      shinyjs::show('submitAnswers')
      shinyjs::show('reset')

      
      
      
      
      output$response = renderUI({
        print(pdf_filepath)
        print(numQuestions)
        response = GenerateQuiz(pdf_filepath, numQuestions, apiKey)
        rv$answer_letters = response$answer_letters
        rv$original_answers = response$answer_letters
        rv$answer_index = c(1:length(rv$original_answers))
        HTML(response$formatted_text)
        
        
        
        # rv$answer_letters = answer_letters
        # rv$original_answers = answer_letters
        # rv$answer_index = c(1:length(rv$original_answers))
        # HTML(test_text)
      })
    }else{
      print('ANKI PRESSED')
      shinyjs::hide("sessionCounter")
      shinyjs::hide('submitAnswers')
      shinyjs::hide('reset')
      shinyjs::hide('fresh')
      shinyjs::hide('filteredReset')
      shinyjs::hide("response")
      
      shinyjs::show("ankiTable")
      shinyjs::show("downloadData")
      
      response = GenerateAnki(pdf_filepath, numQuestions, apiKey)
      rv$ankiTable = response
      
      output$ankiTable = renderDataTable(datatable(response, style = "bootstrap"))
      
      
    }
    
    
  })
  
  observeEvent(input$harder, {
    
    if(input$selectType == "Quiz"){
      shinyjs::hide('harder')
      shinyjs::hide('fresh')
      shinyjs::hide('filteredReset')
      
      output$response = renderUI({
        response = MakeHarder(apiKey)
        rv$answer_letters = response$answer_letters
        HTML(response$formatted_text)
      })
    }
    if(input$selectType == "Anki"){
      shinyjs::hide('fresh')
      shinyjs::hide('filteredReset')
      
      
      response = MakeHarderAnki(apiKey)
      rv$ankiTable = response
      
      output$ankiTable = renderDataTable(datatable(response, style = "bootstrap"))
      
      
    }
    
    
  })
  
  rv$round_total = 0
  observeEvent(input$selectedValues, {
    shinyjs::show('harder')
    shinyjs::show('fresh')
    shinyjs::show('filteredReset')
    selectedValues = input$selectedValues
    
    
    
    rv$session_total = rv$session_total + length(selectedValues)
    
    
    rv$round_total = rv$round_total + length(selectedValues)
    rv$ind_correct = numeric()
    
    for(i in 1:length(selectedValues)){
      if(selectedValues[i] == rv$answer_letters[i]){
        session$sendCustomMessage("showCheckmark", rv$answer_index[i])
        rv$session_correct = rv$session_correct + 1
        rv$round_correct = rv$round_correct + 1
        rv$ind_correct = c(rv$ind_correct, i)
      }else{
        session$sendCustomMessage("showX", rv$answer_index[i])
      }
      
    }
    
    score_suggestion =  paste0("You scored: ",rv$round_correct, "/", rv$round_total,".")
    
    if(rv$round_correct / rv$round_total >= 0.8){
      score_suggestion = paste0(score_suggestion, " It looks like you've mastered these concepts and are ready to move on.",
                                " Suggested increase number of questions or increase in difficulty.")
    }else{
      score_suggestion = paste0(score_suggestion, " It looks like you could use a little bit more practice with these topics.",
                                " A good starting point would be to simply hit the reset button at the bottom of the page and try again!!")
    }
    
    output$scoreSuggestion = renderText(score_suggestion)
    
    ## Add some code to keep track of users scores
    if(rv$username %in% rv$tracker$username){
      rv$tracker$correct[rv$tracker$username == rv$username] = rv$tracker$correct[rv$tracker$username == rv$username] + rv$round_correct
      rv$tracker$attempted[rv$tracker$username == rv$username] = rv$tracker$attempted[rv$tracker$username == rv$username] + rv$round_total
      
      saveRDS(rv$tracker, "tracker.rds")
      
    }else{
      tmp.tracker = data.frame(
        username = rv$username,
        correct = rv$round_correct,
        attempted = rv$round_total
      )
      rv$tracker = rbind(rv$tracker, tmp.tracker)
      saveRDS(rv$tracker, "tracker.rds")
    }
    
  })
  
  observeEvent(input$reset, {
    shinyjs::hide('harder')
    shinyjs::hide('fresh')
    shinyjs::hide('filteredReset')
    session$sendCustomMessage("Reset", list("hi"))
    shinyjs::runjs('$("div[class^=\'q_container\']").show();')
    
    rv$round_correct = 0
    rv$round_total = 0
    rv$answer_letters = rv$original_answers
  })
  
  observeEvent(input$fresh, {
    shinyjs::hide('harder')
    shinyjs::hide('fresh')
    shinyjs::hide('filteredReset')
    output$response = renderUI({
      response = NewSetOfQuestions()
      rv$answer_letters = response$answer_letters
      HTML(response$formatted_text)
    })
  })
  
  observeEvent(input$filteredReset, {
    shinyjs::hide('harder')
    shinyjs::hide('fresh')
    shinyjs::hide('filteredReset')
    
    rv$round_correct = 0
    rv$round_total = 0
    
    if(length(rv$ind_correct) > 0){
      print(rv$answer_index)
      print(rv$ind_correct)
      
      session$sendCustomMessage("filteredReset", rv$answer_index[rv$ind_correct])
      
      rv$answer_letters = rv$answer_letters[-rv$ind_correct]
      rv$answer_index = rv$answer_index[-rv$ind_correct]
      
    }else{
      session$sendCustomMessage("Reset", list("hi"))
      shinyjs::runjs('$("div[class^=\'q_container\']").show();')
      
      rv$round_total = 0
      rv$round_correct = 0
      rv$answer_letters = rv$original_answers
    }
    
    
    
    
    
  })
  
  output$sessionCounter = renderText(paste0("Session Score Tracker: ",rv$session_correct,"/",rv$session_total))
  
  observeEvent(input$loginButton, {
    
    # session$sendCustomMessage("Login", "hi")
    username = input$username
    password = input$password
    
    if(username == "" | password == ""){
      output$status = renderText('* Username/Password Required *')
    }else{
      usernames = rv$credentials$username
      passwords = rv$credentials$password
      
      usr_ind = which(usernames == username)
      psw_ind = which(passwords == password)
      
      
      if(length(usr_ind) != 0 & length(psw_ind) != 0){
        if(username %in% usernames & password %in% passwords & usr_ind %in% psw_ind){
          print("user found, logging in.")
          output$status = NULL
          rv$username = username
          change_page("/main")
        }else{
          output$status = renderText('* User not found, please re-enter username/password or create an account! *')
        }
      }else if(length(usr_ind) != 0 & length(psw_ind) == 0){
        output$status = renderText('* Username found, but password is incorrect! *')
      }else{
        output$status = renderText('* User not found, please re-enter username/password or create an account! *')
      }
    }
    
    
  })
  
  observeEvent(input$createAccount, {
    username = input$username
    password = input$password
    
    if(username == "" | password == ""){
      output$status = renderText('* Username/Password Required *')
    }else{
      if(username %in% rv$credentials$username){
        
        output$status = renderText('* Username already taken, please choose a new username or enter the correct password! *')
      }else{
        
        print('new user added')
        output$status = NULL
        
        rv$username = username
        
        cred_tmp = data.frame(
          username = username,
          password = password
        )
        
        rv$credentials = rbind(rv$credentials, cred_tmp)
        saveRDS(rv$credentials, "credentials.rds")
        
        change_page("/main")
      }
    }
    
    
    
    
  })
  
  observeEvent(input$logoutButton ,{
    change_page("/")
  })
  
  observeEvent(input$feedback, {
    shinyalert(html = TRUE, text = tagList(
      textAreaInput(inputId = "feedbackInput", label = "Enter your feedback or suggestion here:", placeholder = "Feedback...")
    ))
  })
  
  observeEvent(input$shinyalert, {
    
    if(input$feedbackInput != ""){
      print(input$feedbackInput)
      
      rv$feedback = s3readRDS(object = "feedback.rds", bucket = "notes2quiz/Feedback")
      # x = s3readRDS(object = "feedback.rds", bucket = "notes2quiz/Feedback")
      
      tmp.df = data.frame(
        "User" = rv$username,
        "Date" = Sys.time(),
        "Feedback" = input$feedbackInput
      )
      
      tmp.df = rbind(rv$feedback, tmp.df)
      
      saveRDS(tmp.df, file = paste0(tempdir(), "/feedback.rds"))
      
      put_object(
        file = file.path(tempdir(), "feedback.rds"),
        object = paste0("feedback.rds"),
        bucket = paste0("notes2quiz/Feedback")
      )
    }
    
  })
  
  observeEvent(input$createAccountPaid, {
    
    shinyalert(
      title = "Enter Your Information",
      html = TRUE,
      text = tags$div(
        textInput("usernamePaid", "Username:", placeholder = "Enter username..."),
        passwordInput("passwordPaid", "Password:", placeholder = "Enter password..."),
        textInput("emailPaid", "Email:", placeholder = "Enter email..."),
        actionButton("submitButtonPaid", "Submit"),
      ),
      showCancelButton = TRUE,
      showConfirmButton = FALSE,
    )
    # session$sendCustomMessage("Test", list("hi"))
    
  })
  
  observeEvent(input$submitButtonPaid,{
    username = input$usernamePaid
    password = input$usernamePaid
    email = input$emailPaid
    
    boneyard = readRDS("boneyard.rds")
    uid = uuid::UUIDgenerate()
    
    tmp_df = data.frame(
      uid = uid,
      username = username,
      password = password,
      email = email
    )
    
    boneyard = rbind(boneyard, tmp_df)
    saveRDS(boneyard, "boneyard.rds")
  })
  
  observeEvent(input$toApp, {
    username = input$usernamePaid
    password = input$passwordPaid
    
    if(username == "" | password == ""){
      output$statusPaid = renderText('* Username/Password Required *')
    }else{
      if(username %in% rv$credentials$username){
        
        output$statusPaid = renderText('* Username already taken, please choose a new username or enter the correct password! *')
      }else{
        
        print('new user added')
        output$statusPaid = NULL
        
        rv$username = username
        
        cred_tmp = data.frame(
          username = username,
          password = password
        )
        
        rv$credentials = rbind(rv$credentials, cred_tmp)
        saveRDS(rv$credentials, "credentials.rds")
        
        change_page("/main")
        
      }
    }
    
    
  })
  
  output$userID = renderText({
    paste0("User: ",rv$username)
  })
  
  observeEvent(input$pdfInput, {
    if(rv$username == ""){
      stop("USER NOT FOUND")
    }
  })
  
  output$downloadData <- downloadHandler(
    filename = function() { 
      paste("dataset-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.table(rv$ankiTable, file, row.names = FALSE, col.names = FALSE, sep = ",")
    })
  
  
  
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)
