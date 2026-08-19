library(shiny)

# Shared global leaderboard (persists in memory while app session is active)
global_leaderboard <- reactiveVal(
  data.frame(
    Name = character(0),
    Score = character(0),
    Percentage = character(0),
    Language = character(0),
    Timestamp = character(0),
    stringsAsFactors = FALSE
  )
)

quiz_data_by_lang <- list(
  en = list(
    list(
      id = "sheep_terminology",
      question = "Do you know the biological relationship between a lamb, a ewe, and a ram?",
      options = c(yes = "Yes", no = "No"),
      answer = "yes",
      explanation = "🐑 Lamb = young sheep | ♀️ Ewe = adult female sheep | ♂️ Ram = adult male sheep"
    ),
    list(
      id = "goat_terminology",
      question = "Do you know the biological relationship between a kid, a doe, and a buck?",
      options = c(yes = "Yes", no = "No"),
      answer = "yes",
      explanation = "🐐 Kid = young goat | ♀️ Doe = adult female goat | ♂️ Buck = adult male goat"
    ),
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
    ),
    list(
      id = "rumen_fermentation",
      question = "Which compartment is the main site of microbial fermentation in ruminants?",
      options = c(abomasum = "Abomasum", rumen = "Rumen", omasum = "Omasum", small_intestine = "Small intestine"),
      answer = "rumen",
      explanation = "The rumen houses billions of symbiotic microbes that break down complex plant carbohydrates like cellulose through fermentation."
    ),
    list(
      id = "pig_digestion",
      question = "Which statement best distinguishes the pig digestive system from the ruminant digestive system?",
      options = c(
        four_stomachs = "Pigs have four specialized stomach compartments.",
        rumen_fiber = "Pigs rely primarily on rumen microorganisms to digest fiber.",
        monogastric = "Pigs have a single-chambered stomach and rely largely on enzymatic digestion.",
        large_intestine = "Pigs absorb most nutrients in the large intestine."
      ),
      answer = "monogastric",
      explanation = "As monogastric non-ruminants, pigs digest food using gastric acid and digestive enzymes in a single-chambered stomach."
    ),
    list(
      id = "abomasum_function",
      question = "What is the main function of the abomasum?",
      options = c(
        fermentation = "Microbial fermentation of plant fiber",
        water_abs = "Absorption of water and minerals",
        enzyme_sec = "Secretion of gastric acid and enzymes for protein digestion",
        regurgitation = "Regurgitation of feed back to the mouth"
      ),
      answer = "enzyme_sec",
      explanation = "The abomasum functions as the glandular stomach where acid and pepsin break down proteins and microbes passed from upstream."
    ),
    list(
      id = "pig_biomedical",
      question = "Which feature makes pigs particularly useful for xenotransplantation research?",
      options = c(
        similar_organs = "Their organs have anatomical and physiological similarities to human organs.",
        human_abs = "They naturally produce fully human antibodies.",
        four_chamber = "Their four-chambered stomach resembles the human digestive system.",
        small_brain = "Their brain is considerably smaller than that of other laboratory animals."
      ),
      answer = "similar_organs",
      explanation = "Porcine organs (such as hearts and kidneys) closely match human organs in size, structure, and physiological function."
    ),
    list(
      id = "sheep_biomedical",
      question = "Why are sheep useful models for prenatal and maternal medicine?",
      options = c(
        short_gestation = "They have an unusually short gestation period.",
        fetal_phys = "Their fetal development and physiology allow studies of pregnancy and premature-infant interventions.",
        monogastric_model = "They are monogastric and therefore closely resemble human digestion.",
        polyclonal_abs = "They produce large quantities of polyclonal antibodies."
      ),
      answer = "fetal_phys",
      explanation = "Fetal sheep physiology allows researchers to perform safe in utero surgical procedures and model human respiratory development."
    ),
    list(
      id = "goat_biomedical",
      question = "Which characteristic makes goats particularly useful for biopharming?",
      options = c(
        rumen_proteins = "Their rumen produces therapeutic proteins during fermentation.",
        milk_proteins = "Their milk can be used to produce recombinant therapeutic proteins.",
        brain_anatomy = "Their brain anatomy closely resembles the human brain.",
        gi_antibodies = "Their gastrointestinal tract allows direct production of human antibodies."
      ),
      answer = "milk_proteins",
      explanation = "Transgenic goats can secrete human therapeutic proteins (such as antithrombin) directly into their milk at high yields."
    )
  ),
  es = list(
    list(
      id = "sheep_terminology",
      question = "¿Conoces la relacion biologica entre un cordero, una oveja y un carnero?",
      options = c(yes = "Si", no = "No"),
      answer = "yes",
      explanation = "🐑 Cordero = oveja joven | ♀️ Oveja = hembra adulta | ♂️ Carnero = macho adulto"
    ),
    list(
      id = "goat_terminology",
      question = "¿Conoces la relacion biologica entre un cabrito, una cabra y un macho cabrio?",
      options = c(yes = "Si", no = "No"),
      answer = "yes",
      explanation = "🐐 Cabrito = cabra joven | ♀️ Cabra = hembra adulta | ♂️ Macho cabrio = macho adulto"
    ),
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
    ),
    list(
      id = "rumen_fermentation",
      question = "Cual compartimento es el sitio principal de fermentacion microbiana en rumiantes?",
      options = c(abomasum = "Abomaso", rumen = "Rumen", omasum = "Omaso", small_intestine = "Intestino delgado"),
      answer = "rumen",
      explanation = "El rumen alberga miles de millones de microbios simbioticos que descomponen carbohidratos complejos como la celulosa mediante fermentacion."
    ),
    list(
      id = "pig_digestion",
      question = "Que afirmacion distingue mejor el sistema digestivo del cerdo del sistema digestivo rumiante?",
      options = c(
        four_stomachs = "Los cerdos tienen cuatro compartimentos estomacales especializados.",
        rumen_fiber = "Los cerdos dependen principalmente de los microorganismos del rumen para digerir fibra.",
        monogastric = "Los cerdos tienen un estomago de una sola camara y dependen principalmente de la digestion enzimatica.",
        large_intestine = "Los cerdos absorben la mayoria de los nutrientes en el intestino grueso."
      ),
      answer = "monogastric",
      explanation = "Como monogastricos no rumiantes, los cerdos digieren los alimentos usando acido gastrico y enzimas digestivas en un estomago simple."
    ),
    list(
      id = "abomasum_function",
      question = "Cual es la funcion principal del abomaso?",
      options = c(
        fermentation = "Fermentacion microbiana de la fibra vegetal",
        water_abs = "Absorcion de agua y minerales",
        enzyme_sec = "Secrecion de acido gastrico y enzimas para la digestion de proteinas",
        regurgitation = "Regurgitacion del alimento de vuelta a la boca"
      ),
      answer = "enzyme_sec",
      explanation = "El abomaso funciona como el estomago glandular donde el acido y la pepsina descomponen proteinas y microbios provenientes del rumen."
    ),
    list(
      id = "pig_biomedical",
      question = "Que caracteristica hace que los cerdos sean particularmente utiles en investigaciones de xenotrasplantes?",
      options = c(
        similar_organs = "Sus organos tienen similitudes anatomicas y fisiologicas con los organos humanos.",
        human_abs = "Producen de forma natural anticuerpos completamente humanos.",
        four_chamber = "Su estomago de cuatro camaras se asemeja al sistema digestivo humano.",
        small_brain = "Su cerebro es considerablemente mas pequeno que el de otros animales de laboratorio."
      ),
      answer = "similar_organs",
      explanation = "Los organos porcinos (como corazones y rinones) coinciden estrechamente con los humanos en tamano, estructura y funcion fisiologica."
    ),
    list(
      id = "sheep_biomedical",
      question = "Por que las ovejas son modelos utiles para la medicina prenatal y materna?",
      options = c(
        short_gestation = "Tienen un periodo de gestacion inusualmente corto.",
        fetal_phys = "Su desarrollo y fisiologia fetal permiten estudiar el embarazo e intervenciones en ninos prematuros.",
        monogastric_model = "Son monogastricas y por lo tanto se asemejan estrechamente a la digestion humana.",
        polyclonal_abs = "Producen grandes cantidades de anticuerpos policlonales."
      ),
      answer = "fetal_phys",
      explanation = "La fisiologia fetal ovina permite procedimientos quirurgicos in utero y modelar el desarrollo respiratorio humano."
    ),
    list(
      id = "goat_biomedical",
      question = "Que caracteristica hace que las cabras sean particularmente utiles para la biofarmacia (biopharming)?",
      options = c(
        rumen_proteins = "Su rumen produce proteinas terapeuticas durante la fermentacion.",
        milk_proteins = "Su leche se puede utilizar para producir proteinas terapeuticas recombinantes.",
        brain_anatomy = "La anatomia de su cerebro se asemeja estrechamente al cerebro humano.",
        gi_antibodies = "Su tubo digestivo permite la produccion directa de anticuerpos humanos."
      ),
      answer = "milk_proteins",
      explanation = "Las cabras transgenicas pueden secretar proteinas terapeuticas humanas (como la antitrombina) directamente en su leche con altos rendimientos."
    )
  ),
  pt = list(
    list(
      id = "sheep_terminology",
      question = "Voce conhece a relacao biologica entre um cordeiro, uma ovelha e um carneiro?",
      options = c(yes = "Sim", no = "Nao"),
      answer = "yes",
      explanation = "🐑 Cordeiro = ovelha jovem | ♀️ Ovelha = fêmea adulta | ♂️ Carneiro = macho adulto"
    ),
    list(
      id = "goat_terminology",
      question = "Voce conhece a relacao biologica entre um cabrito, uma cabra e um bode?",
      options = c(yes = "Sim", no = "Nao"),
      answer = "yes",
      explanation = "🐐 Cabrito = cabra jovem | ♀️ Cabra = fêmea adulta | ♂️ Bode = macho adulto"
    ),
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
    ),
    list(
      id = "rumen_fermentation",
      question = "Qual compartimento e o principal local de fermentacao microbiana nos ruminantes?",
      options = c(abomasum = "Abomaso", rumen = "Rumen", omasum = "Omaso", small_intestine = "Intestino delgado"),
      answer = "rumen",
      explanation = "O rumen abriga bilhoes de microbios simbioticos que descompõem carboidratos complexos de plantas como a celulose por fermentacao."
    ),
    list(
      id = "pig_digestion",
      question = "Qual afirmacao melhor distingue o sistema digestivo do porco do sistema digestivo dos ruminantes?",
      options = c(
        four_stomachs = "Os porcos possuem quatro compartimentos estomacais especializados.",
        rumen_fiber = "Os porcos dependem principalmente de microorganismos do rumen para digerir fibra.",
        monogastric = "Os porcos possuem um estomago simples de uma camara e dependem da digestao enzimatica.",
        large_intestine = "Os porcos absorvem a maioria dos nutrientes no intestino grosso."
      ),
      answer = "monogastric",
      explanation = "Como monogastricos nao ruminantes, os porcos digerem alimentos usando acido gastrico e enzimas digestivas em um estomago simples."
    ),
    list(
      id = "abomasum_function",
      question = "Qual e a principal funcao do abomaso?",
      options = c(
        fermentation = "Fermentacao microbiana da fibra vegetal",
        water_abs = "Absorcao de agua e minerais",
        enzyme_sec = "Secrecao de acido gastrico e enzimas para digestao de proteinas",
        regurgitation = "Regurgitacao do alimento de volta a boca"
      ),
      answer = "enzyme_sec",
      explanation = "O abomaso funciona como o estomago glandular onde acido e pepsina descompõem proteinas e microbios vindos do rumen."
    ),
    list(
      id = "pig_biomedical",
      question = "Qual caracteristica torna os porcos particularmente uteis em pesquisas de xenotransplante?",
      options = c(
        similar_organs = "Seus orgaos possuem similaridades anatomicas e fisiologicas com os orgaos humanos.",
        human_abs = "Eles produzem naturalmente anticorpos totalmente humanos.",
        four_chamber = "Seu estomago de quatro camaras se assemelha ao sistema digestivo humano.",
        small_brain = "Seu cerebro e consideravelmente menor do que o de outros animais de laboratorio."
      ),
      answer = "similar_organs",
      explanation = "Os orgaos suinos (como coracao e rins) correspondem de perto aos orgaos humanos em tamanho, estrutura e funcao fisiologica."
    ),
    list(
      id = "sheep_biomedical",
      question = "Por que as ovelhas sao modelos uteis para a medicina prenatal e materna?",
      options = c(
        short_gestation = "Elas tem um periodo de gestacao incomumente curto.",
        fetal_phys = "Seu desenvolvimento e fisiologia fetal permitem estudos de gravidez e intervencoes em recem-nascidos prematuros.",
        monogastric_model = "Elas sao monogastricas e, portanto, se assemelham a digestao humana.",
        polyclonal_abs = "Elas produzem grandes quantidades de anticorpos policlonais."
      ),
      answer = "fetal_phys",
      explanation = "A fisiologia fetal ovina permite procedimentos cirurgicos in utero e modelagem do desenvolvimento respiratorio humano."
    ),
    list(
      id = "goat_biomedical",
      question = "Qual caracteristica torna as cabras particularmente uteis para a biofarmacia (biopharming)?",
      options = c(
        rumen_proteins = "Seu rumen produz proteinas terapeuticas durante a fermentacao.",
        milk_proteins = "Seu leite pode ser usado para produzir proteinas terapeuticas recombinantes.",
        brain_anatomy = "A anatomia do seu cerebro se assemelha de perto ao cerebro humano.",
        gi_antibodies = "Seu trato gastrointestinal permite a producao direta de anticorpos humanos."
      ),
      answer = "milk_proteins",
      explanation = "Cabras transgenicas podem secretar proteinas terapeuticas humanas (como a antitrombina) diretamente no leite com altos rendimentos."
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
    finished = "You have reached the end of the quiz! Save your score below:",
    name_prompt = "Enter your name or student ID:",
    save_score = "Save Score to Leaderboard",
    leaderboard_title = "Class Leaderboard & Quiz Results",
    score_saved = "Your score has been registered!"
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
    finished = "¡Llegaste al final del cuestionario! Registra tu puntaje abajo:",
    name_prompt = "Ingresa tu nombre o ID de estudiante:",
    save_score = "Guardar Puntaje en la Tabla",
    leaderboard_title = "Tabla de Posiciones y Resultados",
    score_saved = "¡Tu puntaje ha sido registrado!"
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
    finished = "Voce chegou ao fim do quiz! Registre sua pontuacao abaixo:",
    name_prompt = "Digite seu nome ou ID de estudante:",
    save_score = "Salvar Pontuacao no Ranking",
    leaderboard_title = "Classificacao e Resultados do Quiz",
    score_saved = "Sua pontuacao foi registrada!"
  )
)

quiz_label <- function(lang, key) {
  lang_values <- quiz_labels[[lang]]
  if (is.null(lang_values) || is.null(lang_values[[key]])) return(quiz_labels$en[[key]])
  lang_values[[key]]
}

quiz_questions <- function(lang) {
  lang_questions <- quiz_data_by_lang[[lang]]
  if (is.null(lang_questions)) return(quiz_data_by_lang$en)
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
    
    # Registration Box when Quiz is Completed
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
    ),
    
    tags$hr(),
    
    # Live Leaderboard Table Display
    div(
      class = "quiz-leaderboard-section",
      tags$h3(textOutput(ns("leaderboard_title"))),
      tableOutput(ns("leaderboard_table"))
    )
  )
}

quizServer <- function(id, language = reactive("en")) {
  moduleServer(id, function(input, output, session) {
    current_q <- reactiveVal(1)
    user_answers <- reactiveValues()
    submitted <- reactiveValues()
    score_submitted <- reactiveVal(FALSE)

    question_set <- reactive({ quiz_questions(language()) })
    question_count <- reactive({ length(question_set()) })

    observe({
      if (question_count() == 0) {
        current_q(1)
      } else if (current_q() > question_count()) {
        current_q(question_count())
      }
    })

    current_question <- reactive({
      questions <- question_set()
      if (length(questions) == 0) return(NULL)
      questions[[current_q()]]
    })

    quiz_score <- reactive({
      questions <- question_set()
      if (length(questions) == 0) return(list(correct = 0L, total = 0L))

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

    output$badge_text <- renderText({ quiz_label(language(), "badge") })
    output$score_text <- renderText({
      score <- quiz_score()
      sprintf(quiz_label(language(), "score"), score$correct, score$total)
    })
    output$progress_text <- renderText({
      sprintf(quiz_label(language(), "progress"), current_q(), max(question_count(), 1))
    })
    output$question_label <- renderText({ quiz_label(language(), "question_label") })
    output$hint_text <- renderText({ quiz_label(language(), "hint") })
    output$leaderboard_title <- renderText({ quiz_label(language(), "leaderboard_title") })

    output$progress_bar <- renderUI({
      progress_width <- if (question_count() == 0) 0 else round(current_q() / question_count() * 100)
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

      if (!isTRUE(submitted[[key]])) return(NULL)

      selected_value <- user_answers[[key]]
      if (is.null(selected_value) || !nzchar(selected_value)) {
        return(div(class = "quiz-feedback quiz-feedback-warning", tags$strong(quiz_label(language(), "choose_first"))))
      }

      if (identical(selected_value, question$answer)) {
        return(div(class = "quiz-feedback quiz-feedback-success", tags$h4(quiz_label(language(), "correct")), tags$p(question$explanation)))
      }

      correct_label <- unname(question$options[[question$answer]])
      div(
        class = "quiz-feedback quiz-feedback-error",
        tags$h4(quiz_label(language(), "incorrect")),
        tags$p(tags$strong(paste0(quiz_label(language(), "correct_answer"), ": ")), correct_label),
        tags$p(question$explanation)
      )
    })

    # Registration Form UI rendered at end of quiz
    output$completion_note <- renderUI({
      if (current_q() < question_count()) return(NULL)

      if (isTRUE(score_submitted())) {
        return(div(class = "quiz-feedback quiz-feedback-success", tags$strong(quiz_label(language(), "score_saved"))))
      }

      div(
        class = "quiz-completion-box",
        tags$p(quiz_label(language(), "finished")),
        textInput(session$ns("student_name"), label = quiz_label(language(), "name_prompt"), placeholder = "e.g., Alex Smith"),
        actionButton(session$ns("save_score_btn"), label = quiz_label(language(), "save_score"), class = "btn btn-success")
      )
    })

    # Register score to global leaderboard
    observeEvent(input$save_score_btn, {
      req(input$student_name)
      if (!nzchar(trimws(input$student_name))) return(NULL)

      score <- quiz_score()
      pct <- sprintf("%.0f%%", (score$correct / max(score$total, 1)) * 100)

      new_entry <- data.frame(
        Name = trimws(input$student_name),
        Score = sprintf("%s/%s", score$correct, score$total),
        Percentage = pct,
        Language = toupper(language()),
        Timestamp = format(Sys.time(), "%Y-%m-%d %H:%M"),
        stringsAsFactors = FALSE
      )

      current_board <- global_leaderboard()
      updated_board <- rbind(new_entry, current_board)
      global_leaderboard(updated_board)

      score_submitted(TRUE)
    })

    # Render Leaderboard Table
    output$leaderboard_table <- renderTable({
      global_leaderboard()
    }, striped = TRUE, hover = TRUE, spacing = "s")

    observeEvent(input$next_btn, {
      if (current_q() < question_count()) current_q(current_q() + 1L)
    }, ignoreInit = TRUE)

    observeEvent(input$prev_btn, {
      if (current_q() > 1L) current_q(current_q() - 1L)
    }, ignoreInit = TRUE)

    observeEvent(input$restart_btn, {
      questions <- question_set()
      for (question in questions) {
        key <- paste0("q_", question$id)
        user_answers[[key]] <- NULL
        submitted[[key]] <- NULL
      }
      score_submitted(FALSE)
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