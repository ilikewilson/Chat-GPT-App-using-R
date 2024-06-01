# ChatGPT App: .csv Analysis


######################################################################
# load packages and .env
library(shiny)
library(httr)
library(dotenv)
library(readr)
load_dot_env()
######################################################################

######################################################################
# 1. Load your API key from your .env file.
######################################################################

api_key = Sys.getenv("OPENAI_API_KEY")
  
######################################################################
########################

# Define UI ----
ui = fluidPage(
  # Add a title panel here,
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose CSV File", accept = ".csv"),
    ), 
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel("Ask ChatGPT",
                 textAreaInput("prompt", label = "Chat with your custom data"),
                 actionButton("submit", label = "Send"),
                 h1(" "),
                 # insert output from ChatGPT here
                 textOutput("chatgpt_response")
                 ),
        tabPanel("Your Data",
                 dataTableOutput("uploaded_data")
                 )
      )
    )
  )
)


######################################################################

# Define server logic ----
server = function(input, output) {
  
  input_file = reactive({
    if (is.null(input$file)) {
      return("")
    }
    
    # actually read the file
    read.csv(file = input$file$datapath)
  })
  
  output$uploaded_data = renderDataTable({
    req(input_file())
    input_file()
  }, options = list(pageLength = 10)
  )
  
  # 3b - replace this comment with your description of what df_prompt does.
  df_prompt = reactive({
    req(input_file)
    # note the use of head() keeping only a few rows
    df_to_text = format_delim(head(input_file()), delim = ",")
    paste("You have been provided this data:", df_to_text)
  })
  
  ask_chatgpt = eventReactive(input$submit, {
      POST(
        # fill in the request to ChatGPT here
        url = "https://api.openai.com/v1/chat/completions",
        add_headers(Authorization = paste("Bearer", api_key)),
        content_type_json(),
        encode = "json",
        body = list(
          model = "gpt-3.5-turbo",
          messages = list(list(role = "user", content = df_prompt()),
                          list(role = "user", content = input$prompt))
        )        
      )
  })

  output$chatgpt_response = renderText({
    req(ask_chatgpt())
    c = content(ask_chatgpt())
    c$choices[[1]]$message$content
  })
    
}


######################################################################

# Run the app ----
shinyApp(ui = ui, server = server)

######################################################################
#Do you always get accurate responses?
######################################################################

# Not always. I tried to get it tp run regressions for me and compared the results.
# It is quite good however at helping me summarize and do descriptives on the data.

######################################################################
#   two or more limitations of this app.
######################################################################

# No code, your comments here. 
# It is unable to do complex actions on the data e.g creating predictive models.
# It is also a bit faulty when doing some calculations. It is clearly best to use it
# as a form factor for high level non detailed Exploratory Data Analysis

######################################################################
# ChatGPT into analytics in R.
######################################################################

# With a redesigned UI available I think we can create a drag and drop predictive model creator.
# Open AI can provide automatic inferences and implications as a starting point for the Analyst
# who uses the App. Think of it as Esquisse but for Modelling.
