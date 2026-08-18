library(shiny)

quiz_data_by_lang <- list(
  en = list(
    list(
      id = "chromosome_count",
      question = "Which livestock species has the lowest diploid chromosome count (2n = 38)?",
      options = c(pig = "Pig (Sus scrofa)", goat = "Goat (Capra hircus)", cattle = "Cattle (Bos taurus)", sheep = "Sheep (Ovis aries)"),
      answer = "pig",
      explanation = "Pigs have 38 diploid chromosomes, which is fewer than cattle, sheep, or goats despite having a similar genome size."
    ),
    list(
      id = "taxonomy_order",
      question = "To which biological order do cattle, sheep, goats, and pigs all belong?",
      options = c(perissodactyla = "Perissodactyla", artiodactyla = "Artiodactyla", carnivora = "Carnivora", lagomorpha = "Lagomorpha"),
      answer = "artiodactyla",
      explanation = "Artiodactyla is the order of even-toed ungulates and includes all four farm animal groups featured in the app."
    ),
    list(
      id = "true_stomach",
      question = "Which stomach compartment in ruminants is considered the true stomach homologous to the human stomach?",
      options = c(rumen = "Rumen", reticulum = "Reticulum", omasum = "Omasum", abomasum = "Abomasum"),
      answer = "abomasum",
      explanation = "The abomasum secretes digestive enzymes and hydrochloric acid, making it the glandular stomach most comparable to our own."
    )
  ),
  es = list(
    list(
      id = "chromosome_count",
      question = "Que especie ganadera tiene el menor numero diploide de cromosomas (2n = 38)?",
      options = c(pig = "Cerdo (Sus scrofa)", goat = "Cabra (Capra hircus)", cattle = "Bovino (Bos taurus)", sheep = "Oveja (Ovis aries)"),
      answer = "pig",
      explanation = "Los cerdos tienen 38 cromosomas diploides, menos que bovinos, ovejas o cabras, aunque el tamano del genoma es parecido."
    ),
    list(
      id = "taxonomy_order",
      question = "A que orden biologico pertenecen bovinos, ovejas, cabras y cerdos?",
      options = c(perissodactyla = "Perissodactyla", artiodactyla = "Artiodactyla", carnivora = "Carnivora", lagomorpha = "Lagomorpha"),
      answer = "artiodactyla",
      explanation = "Artiodactyla es el orden de los ungulados de dedos pares e incluye a los cuatro grupos de animales de granja del aplicativo."
    ),
    list(
      id = "true_stomach",
      question = "Que compartimento del estomago de los rumiantes se considera el estomago verdadero homologable al humano?",
      options = c(rumen = "Rumen", reticulum = "Reticulo", omasum = "Omaso", abomasum = "Abomaso"),
      answer = "abomasum",
      explanation = "El abomaso secreta enzimas digestivas y acido clorhidrico, por lo que es el estomago glandular mas comparable al humano."
    )
  ),
  pt = list(
    list(
      id = "chromosome_count",
      question = "Qual especie de producao tem o menor numero diploide de cromossomos (2n = 38)?",
      options = c(pig = "Porco (Sus scrofa)", goat = "Cabra (Capra hircus)", cattle = "Bovino (Bos taurus)", sheep = "Ovelha (Ovis aries)"),
      answer = "pig",
      explanation = "Os porcos tem 38 cromossomos diploides, menos do que bovinos, ovelhas ou cabras, mesmo com um genoma de tamanho parecido."
    ),
    list(
      id = "taxonomy_order",
      question = "A que ordem biologica pertencem bovinos, ovelhas, cabras e porcos?",
      options = c(perissodactyla = "Perissodactyla", artiodactyla = "Artiodactyla", carnivora = "Carnivora", lagomorpha = "Lagomorpha"),
      answer = "artiodactyla",
      explanation = "Artiodactyla e a ordem dos ungulados de dedos pares e inclui os quatro grupos de animais explorados no aplicativo."
    ),
    list(
      id = "true_stomach",
      question = "Qual compartimento do estomago dos ruminantes e considerado o estomago verdadeiro, homologo ao humano?",
      options = c(rumen = "Rumen", reticulum = "Reticulo", omasum = "Omaso", abomasum = "Abomaso"),
      answer = "abomasum",
      explanation = "O abomaso secreta enzimas digestivas e acido cloridrico, por isso e o estomago glandular mais comparavel ao nosso."
    )
  )
)

quiz_labels <- list(
  en = list(
    badge = "Knowledge check",
    progress = "Question %s of %s",
    question_label = "Quiz question",
    score = "Score: %s/%s",
    submit = "Check answer",
    previous = "Previous",
    next_label = "Next",
    restart = "Restart",
    hint = "Use each explanation as a teaching note you can discuss with students after they answer.",
    choose_first = "Please select an answer before checking it.",
    correct = "Correct",
    incorrect = "Incorrect",
    correct_answer = "Correct answer",
    finished = "You have reached the end of the quiz. You can review any question or restart."
  ),
  es = list(
    badge = "Repaso guiado",
    progress = "Pregunta %s de %s",
    question_label = "Pregunta del cuestionario",
    score = "Puntaje: %s/%s",
    submit = "Revisar respuesta",
    previous = "Anterior",
    next_label = "Siguiente",
    restart = "Reiniciar",
    hint = "Usa cada explicacion como una nota didactica para conversar con los estudiantes despues de responder.",
    choose_first = "Selecciona una respuesta antes de revisarla.",
    correct = "Correcto",
    incorrect = "Incorrecto",
    correct_answer = "Respuesta correcta",
    finished = "Llegaste al final del cuestionario. Puedes revisar cualquier pregunta o reiniciarlo."
  ),
  pt = list(
    badge = "Revisao guiada",
    progress = "Pergunta %s de %s",
    question_label = "Pergunta do quiz",
    score = "Pontuacao: %s/%s",
    submit = "Conferir resposta",
    previous = "Anterior",
    next_label = "Proxima",
    restart = "Reiniciar",
    hint = "Use cada explicacao como uma nota didatica para discutir com os estudantes depois da resposta.",
    choose_first = "Selecione uma resposta antes de conferir.",
    correct = "Correto",
    incorrect = "Incorreto",
    correct_answer = "Resposta correta",
    finished = "Voce chegou ao fim do quiz. Pode revisar qualquer pergunta ou reiniciar."
  )
)

quiz_label <- function(lang, key) {
  lang_values <- quiz_labels[[lang]]

  if (is.null(lang_values) || is.null(lang_values[[key]])) {
    return(quiz_labels$en[[key]])
  }

  lang_values[[key]]
}

quiz_questions <- function(lang) {
  lang_questions <- quiz_data_by_lang[[lang]]

  if (is.null(lang_questions)) {
    return(quiz_data_by_lang$en)
  }

  lang_questions
}

quizUI <- function(id) {
  ns <- NS(id)

  div(
    class = "quiz-card",
    div(
      class = "quiz-header",
      div(
        class = "quiz-header-copy",
        div(class = "quiz-badge", textOutput(ns("badge_text"), container = tags$span)),
        div(class = "quiz-score", textOutput(ns("score_text"), container = tags$span))
      ),
      div(class = "quiz-progress-text", textOutput(ns("progress_text"), container = tags$span))
    ),
    uiOutput(ns("progress_bar")),
    div(
      class = "quiz-question-wrap",
      div(class = "quiz-question-label", textOutput(ns("question_label"), container = tags$span)),
      uiOutput(ns("question_ui"))
    ),
    uiOutput(ns("options_ui")),
    uiOutput(ns("feedback_ui")),
    div(class = "quiz-hint", textOutput(ns("hint_text"), container = tags$span)),
    uiOutput(ns("completion_note")),
    div(
      class = "quiz-nav",
      div(
        class = "quiz-nav-group",
        actionButton(ns("prev_btn"), label = NULL, icon = icon("arrow-left"), class = "btn btn-default quiz-btn"),
        actionButton(ns("next_btn"), label = NULL, icon = icon("arrow-right"), class = "btn btn-default quiz-btn")
      ),
      div(
        class = "quiz-nav-group",
        actionButton(ns("restart_btn"), label = NULL, icon = icon("refresh"), class = "btn btn-default quiz-btn quiz-btn-secondary"),
        actionButton(ns("submit_btn"), label = NULL, icon = icon("check"), class = "btn btn-primary quiz-btn quiz-btn-primary")
      )
    )
  )
}

quizServer <- function(id, language = reactive("en")) {
  moduleServer(id, function(input, output, session) {
    current_q <- reactiveVal(1)
    user_answers <- reactiveValues()
    submitted <- reactiveValues()

    question_set <- reactive({
      quiz_questions(language())
    })

    question_count <- reactive({
      length(question_set())
    })

    observe({
      if (question_count() == 0) {
        current_q(1)
      } else if (current_q() > question_count()) {
        current_q(question_count())
      }
    })

    current_question <- reactive({
      questions <- question_set()

      if (length(questions) == 0) {
        return(NULL)
      }

      questions[[current_q()]]
    })

    quiz_score <- reactive({
      questions <- question_set()

      if (length(questions) == 0) {
        return(list(correct = 0L, total = 0L))
      }

      total_correct <- 0L

      for (question in questions) {
        key <- paste0("q_", question$id)
        selected <- user_answers[[key]]

        if (!is.null(selected) && identical(selected, question$answer)) {
          total_correct <- total_correct + 1L
        }
      }

      list(correct = total_correct, total = length(questions))
    })

    output$badge_text <- renderText({
      quiz_label(language(), "badge")
    })

    output$score_text <- renderText({
      score <- quiz_score()
      sprintf(quiz_label(language(), "score"), score$correct, score$total)
    })

    output$progress_text <- renderText({
      sprintf(quiz_label(language(), "progress"), current_q(), max(question_count(), 1))
    })

    output$question_label <- renderText({
      quiz_label(language(), "question_label")
    })

    output$hint_text <- renderText({
      quiz_label(language(), "hint")
    })

    output$progress_bar <- renderUI({
      progress_width <- if (question_count() == 0) {
        0
      } else {
        round(current_q() / question_count() * 100)
      }

      div(
        class = "quiz-progress-bar",
        div(class = "quiz-progress-fill", style = sprintf("width:%s%%;", progress_width))
      )
    })

    output$question_ui <- renderUI({
      question <- current_question()
      req(question)

      tags$h3(class = "quiz-question", question$question)
    })

    output$options_ui <- renderUI({
      question <- current_question()
      req(question)

      key <- paste0("q_", question$id)
      selected_value <- user_answers[[key]]

      div(
        class = "quiz-options",
        radioButtons(
          session$ns("user_choice"),
          label = NULL,
          choices = stats::setNames(names(question$options), question$options),
          selected = if (!is.null(selected_value)) selected_value else character(0)
        )
      )
    })

    observeEvent(input$user_choice, {
      question <- current_question()
      req(question)

      key <- paste0("q_", question$id)
      user_answers[[key]] <- input$user_choice
      submitted[[key]] <- FALSE
    }, ignoreInit = TRUE)

    observeEvent(input$submit_btn, {
      question <- current_question()
      req(question)

      key <- paste0("q_", question$id)
      submitted[[key]] <- TRUE
    }, ignoreInit = TRUE)

    output$feedback_ui <- renderUI({
      question <- current_question()
      req(question)

      key <- paste0("q_", question$id)

      if (!isTRUE(submitted[[key]])) {
        return(NULL)
      }

      selected_value <- user_answers[[key]]

      if (is.null(selected_value) || !nzchar(selected_value)) {
        return(
          div(
            class = "quiz-feedback quiz-feedback-warning",
            tags$strong(quiz_label(language(), "choose_first"))
          )
        )
      }

      if (identical(selected_value, question$answer)) {
        return(
          div(
            class = "quiz-feedback quiz-feedback-success",
            tags$h4(quiz_label(language(), "correct")),
            tags$p(question$explanation)
          )
        )
      }

      correct_label <- unname(question$options[[question$answer]])

      div(
        class = "quiz-feedback quiz-feedback-error",
        tags$h4(quiz_label(language(), "incorrect")),
        tags$p(
          tags$strong(paste0(quiz_label(language(), "correct_answer"), ": ")),
          correct_label
        ),
        tags$p(question$explanation)
      )
    })

    output$completion_note <- renderUI({
      if (current_q() < question_count()) {
        return(NULL)
      }

      div(class = "quiz-completion-note", quiz_label(language(), "finished"))
    })

    outputOptions(output, "completion_note", suspendWhenHidden = FALSE)

    observeEvent(input$next_btn, {
      if (current_q() < question_count()) {
        current_q(current_q() + 1L)
      }
    }, ignoreInit = TRUE)

    observeEvent(input$prev_btn, {
      if (current_q() > 1L) {
        current_q(current_q() - 1L)
      }
    }, ignoreInit = TRUE)

    observeEvent(input$restart_btn, {
      questions <- question_set()

      for (question in questions) {
        key <- paste0("q_", question$id)
        user_answers[[key]] <- NULL
        submitted[[key]] <- NULL
      }

      current_q(1L)
    }, ignoreInit = TRUE)

    observe({
      updateActionButton(session, "prev_btn", label = quiz_label(language(), "previous"))
      updateActionButton(session, "next_btn", label = quiz_label(language(), "next_label"))
      updateActionButton(session, "restart_btn", label = quiz_label(language(), "restart"))
      updateActionButton(session, "submit_btn", label = quiz_label(language(), "submit"))
    })
  })
}
