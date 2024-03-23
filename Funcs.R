# Load required libraries
library(pdftools)
library(stringr)
library(httr)
library(jsonlite)

# apiKey = readRDS("apiKey.rds")



# Set the path to your PDF file
# pdf_filepath <- "D:/Downloads/lecture.pdf"
# numQuestions <- 5

chatHistory = c()


#################################################################
#################################################################
#################################################################
#################################################################
#################################################################

GenerateQuiz <- function(pdf_filepath, numQuestions){


# Read text from the PDF
pdf_text <- pdf_text(pdf_filepath)

# Combine pages into a single character vector
pdf_text_combined <- paste(pdf_text, collapse = "\n")

# Clean the text (remove extra whitespaces, special characters, etc.)
clean_text <- str_trim(pdf_text_combined) # Remove leading and trailing whitespaces
clean_text <- str_squish(clean_text) # Remove extra whitespaces
clean_text <- str_replace_all(clean_text, "[^[:graph:]]", " ") # Remove non-printable characters
clean_text <- str_replace_all(clean_text, "\\s+", " ") # Remove extra whitespaces

# Print the cleaned text
# cat(clean_text)

prompt <- paste0("Give me ",numQuestions," quiz questions (multiple choice with 5 options) for the following lecture information.",
                 " Please do not return quetsions of the form 'which of these is not'. Also please include the answers after each questions choices: ", clean_text)


chatHistory <<- append(chatHistory, list(list(role = "user", content = prompt)))
response <- POST(
  url = "https://api.openai.com/v1/chat/completions",
  add_headers(Authorization = paste("Bearer", apiKey)),
  content_type_json(),
  encode = "json",
  body = list(
    model = "gpt-3.5-turbo",
    temperature = 1,
    messages = chatHistory
  )
)

print(response)

x = FormatResponseMC(response)
return(x)
}

#################################################################
#################################################################
#################################################################
#################################################################
#################################################################


MakeHarder <- function(){
  prompt = "Now make the quiz harder. Return the questions in the same format"
  
  chatHistory = append(chatHistory, list(list(role = "user", content = prompt)))
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      temperature = 1,
      messages = chatHistory
    )
  )
  
x = FormatResponseMC(response)

return(x)
}

#################################################################
#################################################################
#################################################################
#################################################################
#################################################################

FormatResponseMC <- function(response){
  # Extract response from API
  x <- fromJSON(rawToChar(response$content))
  x2 <- x$choices
  text.response <- x2$message$content[1]
  
  print(text.response)
  
  
  
  assign("LOOK", text.response, .GlobalEnv)
  
  chatHistory <<- append(chatHistory, list(list(role = "assistant", content = text.response)))
  
  # Debugging code
  # print(text.response)
  # Split text into questions
  questions <- strsplit(text.response, "\\d+\\.")
  
  # Debugging code
  print(length(questions))
  print(head(questions))
  
  
  # Generate formatted HTML with boxes and buttons
  formatted_text <- ""
  answer_letters = c()
  for(i in 1:length(questions[[1]])) {
    if (questions[[1]][i] != "") {
      # Split the question and choices
      print(questions[[1]][i])
      question_and_choices <- strsplit(questions[[1]][i], "\n\nAnswer:")[[1]][1]
      question_and_choices <- paste0(question_and_choices,"\n")
      
      
      # Extract question and choices
      question <- paste0(i-1,": ",trimws(str_match(string = question_and_choices, pattern = "(.*?)\\n.*A"))[2])
      optionA <- paste0("A. ",trimws(str_match(string = paste0(question_and_choices), pattern = "\\n.*A[^a-zA-Z](.*?)\\n")[2]))
      optionB <- paste0("B. ",trimws(str_match(string = paste0(question_and_choices), pattern = "\\n.*B[^a-zA-Z](.*?)\\n")[2]))
      optionC <- paste0("C. ",trimws(str_match(string = paste0(question_and_choices), pattern = "\\n.*C[^a-zA-Z](.*?)\\n")[2]))
      optionD <- paste0("D. ",trimws(str_match(string = paste0(question_and_choices), pattern = "\\n.*D[^a-zA-Z](.*?)\\n")[2]))
      optionE <- paste0("E. ",trimws(str_match(string = paste0(question_and_choices), pattern = "\\n.*E[^a-zA-Z](.*?)\\n")[2]))
      
      # Extract answer from choices
      answer <- str_match(string = questions[[1]][i], "Answer(.*)")[1]
      answer_letter <- str_match(string = questions[[1]][i], "Answer:\\s([A-Z]?)")[2]
      answer_letters = c(answer_letters, answer_letter)
      choices <- paste(optionA, optionB, optionC, optionD, optionE, sep = "\n")
      
      # Contain each question in one whole box
      container_html <- paste0("<div class='q_container",i-1,"'>")
      
      # Create HTML content for the question and choices
      question_html <- paste0("<div class='question'>", question, "</div>")
      # choices_html = paste0("<div class='options' style='padding-left: 20px;'>",choices,"</div>")
      choices_html <- paste0(
        "<div class='options' style='padding-left: 20px;'>",
        "<label><input type='radio' name='question", i-1, "' value='A'> ", optionA, "</label><br>",
        "<label><input type='radio' name='question", i-1, "' value='B'> ", optionB, "</label><br>",
        "<label><input type='radio' name='question", i-1, "' value='C'> ", optionC, "</label><br>",
        "<label><input type='radio' name='question", i-1, "' value='D'> ", optionD, "</label><br>",
        "<label><input type='radio' name='question", i-1, "' value='E'> ", optionE, "</label><br>",
        
        "</div>"
      )
      answer_html <- paste0("<div class='answer-box'>",
                            "<span class='answer' style='display:none'>", answer, "</span>"
                            # "<button class='answer-toggle'>Toggle Answer</button>",
                            )
      # Placeholders for checkmark and X icons
      checkmark_x_html <- paste0(
        "<span id='checkmark", i-1, "' class='checkmark' style='display: none;'><img src='check-nobg.png' width=15 alt='Checkmark'></span>",
        "<span id='x", i-1, "' class='x' style='display: none;'><img src='x.png' width=15 alt='X'></span>",
        "</div>",
        "<div class=separator></div>",
        "</div>"
        
        
      )
      # "<div class='question'>Question 1</div>
      # <div class='options'>A, B, C, D</div>
      # <div class='answer-box'>
      # <div class='answer' style='display:none'>Answer 1</div>
      # <button class='answer-toggle'>Toggle Answer</button>
      # </div>"
      
      # Combine question and choices HTML
      formatted_text <- paste0(formatted_text,container_html, question_html, choices_html,answer_html,checkmark_x_html)
    }
  }
  
  # saveRDS(formatted_text, "NotesToQuiz/test_text.rds")
  # saveRDS(answer_letters, "NotesToQuiz/answer_letters.rds")
  
  formatted_text <- gsub("\n", "<br>", formatted_text)
  
  # Print the formatted HTML for debugging
  # print(formatted_text)
  
  return.object = list(formatted_text = formatted_text,
                       answer_letters = answer_letters)
  
  return(return.object)
}

#################################################################
#################################################################
#################################################################
#################################################################
#################################################################

NewSetOfQuestions <- function() {
  prompt = "Please give me a fresh set of new questions of the same format. Please do not return quetsions of the form 'which of these is not'."
  
  chatHistory = append(chatHistory, list(list(role = "user", content = prompt)))
  
  response <- POST(
    url = "https://api.openai.com/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", apiKey)),
    content_type_json(),
    encode = "json",
    body = list(
      model = "gpt-3.5-turbo",
      temperature = 1,
      messages = chatHistory
    )
  )
  
  x = FormatResponseMC(response)
}
