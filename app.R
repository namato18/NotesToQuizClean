library(shiny)
library(shinycssloaders)
library(shinythemes)
library(shinybusy)
library(shinyjs)
library(purrr)
library(shiny.router)


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
                 add_busy_spinner(spin = "fading-circle", color = "white", height = "60px", width = "60px"),
                 
                 
                 tags$head(
                   tags$script(
                     '
      $(document).ready(function() {
        console.log("loaded");
        $(document).on("click", ".answer-toggle", function() {
          console.log("hello");
          $(this).closest(".answer-box").find(".answer").toggle();
        });
        
        $("#submitAnswers").click(function() {
          $(".answer").show();
          var selectedValues = [];
          $("input[type=radio]:checked").each(function() {
            selectedValues.push($(this).val());
          });
          Shiny.setInputValue("selectedValues", selectedValues);
          console.log("hi");
        });
        
        Shiny.addCustomMessageHandler("showCheckmark", function(ind) {
          $("#checkmark" + ind).show();
          $("#x" + ind).hide();
        });
        
        Shiny.addCustomMessageHandler("showX", function(ind) {
          $("#x" + ind).show();
          $("#checkmark" + ind).hide();
        });
        
        function resetRadioButtons() {
          $(\'input[type="radio"]\').prop(\'checked\', false);
        }
        
        function resetAnswers() {
          $(".answer").hide();
          $(".checkmark").hide();
          $(".x").hide();
        }
        
        function filteredReset(ind) {
          console.log(ind);
          console.log(`.q_container${ind}`);
          $(`.q_container${ind}`).hide();

        }
        
        Shiny.addCustomMessageHandler("Reset", function(ind) {
          console.log("reset pressed");
          resetRadioButtons();
          resetAnswers();
        });
        
        Shiny.addCustomMessageHandler("filteredReset", function(ind) {
          if(Array.isArray(ind)){
              ind.forEach(function(index) {
              console.log(index);
              filteredReset(index);
            });
          } else {
            filteredReset(ind);
          }

          resetRadioButtons();
          resetAnswers();
          
        });
        
Shiny.addCustomMessageHandler("Test", function(ind) {
    console.log("pressed");
    const request_url = "https://n2q.nick-amato.com/create-checkout-session";
    console.log(request_url);
    fetch(request_url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            items: [
                {id: 1, quantity: 1},
            ]
        })
    }).then(function(res) {
        if (res.ok) return res.json();
        return res.json().then(function(json) {
            return Promise.reject(json);
        });
    }).then(function({ url }) {
        console.log(url)
        window.location = url
    }).catch(function(e) {
        console.error(e.error);
    });
});


        
        
        
      });

      '
                   ),
                   
                   tags$style(HTML("
    
/* Reset default margin and padding */
body, h1, h2, h3, p, ul, li {
  margin: 0;
  padding: 0;
}



/* Global styles */
body {
  background-color: #070a1c; /* Dark background */
  font-family: Arial, sans-serif;
  color: #fff; /* White text color */
  height: 100vh;
}

.container {
  max-width: 800px; /* Limit content width for better readability */
  margin: 0 auto; /* Center content horizontally */
  padding: 20px;
}

/* Well container */
.well {
  background: linear-gradient(to bottom left, #1f2640, #070a1c); /* Dark gradient */
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.5); /* Dark shadow */
}

/* Login page */
.login-page {
  background-color: #070a1c; /* Dark background */
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

/* Button style */
.answer-toggle {
  background: #FF6F61;
  color: white;
  font-size: 15px;
  border: none;
  border-radius: 5px;
  padding: 10px 20px;
  cursor: pointer;
  transition: background-color 0.3s, color 0.3s;
}
.answer-toggle:hover {
  background: #ff4136;
}

/* Question style */
.question {
  font-size: 20px;
  color: white; /* White text color */
  border-radius: 5px;
  background: linear-gradient(to right, #1f2640, #070a1c); /* Dark gradient */
  padding: 15px;
  border: 1px solid #333; /* Dark border */
}

/* Separator style */
.separator {
  width: 100%;
  border-top: 1px solid #333; /* Dark border */
  margin: 20px 0;
}

/* Answer box and components */
.answer-box {
  display: flex;
  align-items: center;
}
.answer,
.checkmark,
.x {
  margin-right: 10px;
}
.checkmark,
.x {
  color: #2ECC40; /* Vibrant green */
}
.x {
  color: #FF851B; /* Vibrant orange */
}

/* Title bar */
.title-bar {
  background: linear-gradient(to bottom, #1f2640, #070a1c); /* Dark gradient */
  color: white; /* White text color */
  padding: 10px;
  font-size: 24px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 20px;
  border-radius: 5px;
  box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.5); /* Dark shadow */
}

/* Shiny text output */
.shiny-text-output {
  font-size: 16px;
  line-height: 1.5;
  margin-bottom: 10px;
}

  
  
          .login-box {
            background-image: url('background.jpg');
            background-size: 100% 100%;
            background-color: black;
            color: white;
            border-radius: 8px;
            box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.1);
            padding: 50px;
            width: 300px;
            height: 400px;
            text-align: center;
            margin: 0 auto;
        }

        .login-box h2 {
            margin-top: 0;
            margin-bottom: 20px;
        }

        .login-box input[type='text'],
        .login-box input[type='password'] {
            width: 100%;
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }

        .login-box button {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .login-box button:hover {
            background-color: #0056b3;
        }

        .create-account-btn {
            margin-top: 10px;
            color: #007bff;
            text-decoration: none;
        }

        .create-account-btn:hover {
            text-decoration: underline;
        }
        
        #status.shiny-text-output {
          color: red;
          font-size: 13px;

        }
        
        #statusPaid.shiny-text-output {
          color: red;
          font-size: 13px;

        }
        
        #sessionCounter.shiny-text-output {
          color: white;
        }
        
        .options {
          color: white;
        }
        
        #logoutButton {
          background-color: #070a1c;
          color: white;
          padding: 10px 20px;
          margin-right: 10px;
        }
        
        .success-page {
  background-color: #070a1c; /* Dark background */
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}

.success-box {
    background-image: url('background.jpg');
    background-size: 100% 100%;
    background-color: black;
    color: white;
    padding:30px;
    border-radius: 8px;
    box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.1);
    padding: 50px;
    width: 300px;
    height: 325px;
    text-align: center;
    margin: 0 auto;
}

.success-box h2 {
  margin-top: 0;
  margin-bottom: 20px;
}

.success-box button {
  width: 100%;
  padding: 10px;
  background-color: #007bff;
  color: #fff;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.success-box button:hover {
  background-color: #0056b3;
}
        

        



  /* Additional CSS for specific elements can be added here */
"))
                   
                   
                   
                 ),
                 
                 column(width = 12,
                        div(class = "title-bar",
                            "AI Notes to Quiz Generator",
                            actionButton(inputId = "logoutButton","Logout"))),
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
                     sliderInput("numQuestions", label = "How Many Questions Would You Like to Generate?", min = 1, max = 25, value = 5),
                     actionButton("submit1", label = "Generate Quiz!", class = 'btn-primary'),
                     br(),
                     br(),
                     textOutput("scoreSuggestion")
                   ),
                   
                   mainPanel(
                     
                     textOutput("sessionCounter"),
                     htmlOutput("response"),
                     actionButton(inputId = "submitAnswers", label = "Submit Answers", class = "btn-primary"),
                     actionButton("reset", label = "Reset Quiz", class = "btn-primary"),
                     actionButton("filteredReset", label = "Reset Quiz & Remove Questions You Got Right", class = "btn-primary"),
                     actionButton("fresh", label = "Fresh Set of Questions (Same Difficulty)", class = "btn-primary"),
                     actionButton("harder", label = "Make Quiz Harder", class = 'btn-primary'),
                     
                     
                     
                   )
                 )
)

login_page <- tags$div(class = "login-page",
                       tags$div(
                         class = "login-box",
                         h2("AI Notes to Quiz Login"),
                         tags$form(
                           textInput(inputId = "username",label = NULL, placeholder = "Username..."),
                           textInput(inputId = "password",label = NULL, placeholder = "Password..."),
                           # tags$input(type = "text", placeholder = "Username", required = "required"),
                           # tags$input(type = "password", placeholder = "Password", required = "required"),
                           # tags$button(type = "submit", id = "loginButton", "Login"),
                           actionButton(inputId = "loginButton", "Login", class = "btn-login")
                         ),
                         # actionButton(inputId = "createAccount", "Create Account", class = "create-account-btn"),
                         actionButton(inputId = "createAccountPaid", "Create Account Paid", class = "create-account-btn"),
                         div(id = "statusDiv",
                             class = "status-text",
                             textOutput("status")
                             
                         )
                       ),
)

success_page <- tags$div(class = "success-page",
                         tags$div(class = "success-box",
                                  h2("Set Username & Password"),
                                  tags$form(
                                    textInput(inputId = "usernamePaid",label = NULL, placeholder = "Username..."),
                                    textInput(inputId = "passwordPaid",label = NULL, placeholder = "Password..."),
                                    actionButton(inputId = "toApp", "Take Me Into The App!", class = "btn-login")
                                  ),
                                  
                                  
                                  div(id = "statusDivPaid",
                                      class = "status-text",
                                      textOutput("statusPaid")
                                  )
                                  
                         )
)


source("Funcs.R")
# answer_letters = readRDS("answer_letters.rds")
# test_text = readRDS("test_text.rds")

# Define UI for application that draws a histogram
ui <- fluidPage(
  router_ui(
    route("/", login_page),
    route("main", main_app),
    route("success", success_page)
  )
  
)

# ui <- secure_app(ui, enable_admin = TRUE)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  router_server()
  
  
  
  shinyjs::hide('submitAnswers')
  shinyjs::hide('reset')
  shinyjs::hide('harder')
  shinyjs::hide('fresh')
  shinyjs::hide('filteredReset')
  
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
                      running_total = 0)
  
  
  observeEvent(input$submit1, {
    
    print(rv$username)
    
    shinyjs::show('submitAnswers')
    shinyjs::show('reset')
    
    
    
    pdf_filepath = input$pdfInput$datapath
    numQuestions = input$numQuestions
    output$response = renderUI({
      print(pdf_filepath)
      print(numQuestions)
      response = GenerateQuiz(pdf_filepath, numQuestions)
      rv$answer_letters = response$answer_letters
      rv$original_answers = response$answer_letters
      rv$answer_index = c(1:length(rv$original_answers))
      HTML(response$formatted_text)
      
      
      
      # rv$answer_letters = answer_letters
      # rv$original_answers = answer_letters
      # rv$answer_index = c(1:length(rv$original_answers))
      # HTML(test_text)
    })
  })
  
  observeEvent(input$harder, {
    shinyjs::hide('harder')
    shinyjs::hide('fresh')
    shinyjs::hide('filteredReset')
    
    output$response = renderUI({
      response = MakeHarder()
      rv$answer_letters = response$answer_letters
      HTML(response$formatted_text)
    })
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
  
  observeEvent(input$createAccountPaid, {
    username = input$username
    password = input$password
    
    
    session$sendCustomMessage("Test", list("hi"))
    
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
    rv$username
  })
  
  observeEvent(input$pdfInput, {
    if(rv$username == ""){
      stop("USER NOT FOUND")
    }
  })
  
  
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)
