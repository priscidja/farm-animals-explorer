library(shiny)
library(plotly)

source(file.path("R", "data_access.R"), local = TRUE)
source(file.path("scripts", "Interactive_charts_for_App.R"), local = TRUE)
source(file.path("scripts", "Quiz.R"), local = TRUE)

if (dir.exists("figs") && !"figs" %in% names(shiny::resourcePaths())) {
  addResourcePath("figs", normalizePath("figs", winslash = "/"))
}

species_data <- load_species_profiles(file.path("data", "species_profiles.csv"))
genome_data <- load_genome_summary(file.path("data", "genome_summary.csv"))
science_data <- load_science_use(file.path("data", "science_use.csv"))
genome_story_data <- load_genome_stories(file.path("data", "genome_stories.csv"))
domestication_data <- load_domestication_sites(file.path("data", "domestication_sites.csv"))
breed_data <- load_breed_profiles(file.path("data", "breed_profiles.csv"))
anatomy_data <- load_anatomy_explorer(file.path("data", "anatomy_explorer.csv"))
sustainability_data <- load_sustainability_profiles(file.path("data", "sustainability_profiles.csv"))

species_ids <- species_data$species_id
species_palette <- stats::setNames(species_data$color_hex, species_data$species_id)
species_name_map <- stats::setNames(species_data$display_name, species_data$species_id)
species_icon_files <- c(
  cattle = "Cow icon_new.png",
  sheep = "Sheep icon_new.png",
  pig = "Pig icon_new.png",
  goat = "Goat icon_new.png"
)
species_figure_files <- c(
  cattle = "Cow_new.png",
  sheep = "Sheep_new.png",
  pig = "Pig_new.png",
  goat = "Goat_new..png"
)

genome_data$display_name <- coalesce_text(
  genome_data$display_name,
  species_data$display_name[match(genome_data$species_id, species_data$species_id)]
)
genome_data$scientific_name <- coalesce_text(
  genome_data$scientific_name,
  species_data$scientific_name[match(genome_data$species_id, species_data$species_id)]
)

domestication_data$display_name <- coalesce_text(
  species_name_map[domestication_data$species_id],
  domestication_data$species_id
)

breed_data$display_name <- coalesce_text(
  species_name_map[breed_data$species_id],
  breed_data$species_id
)

sustainability_data$display_name <- coalesce_text(
  species_name_map[sustainability_data$species_id],
  sustainability_data$species_id
)

genome_story_output_ids <- c(
  karyotype_paradox = "story_plot_karyotype_paradox",
  chromosome_idiogram = "story_plot_chromosome_idiogram",
  genome_composition = "story_plot_genome_composition",
  phylogeny_tree = "story_plot_phylogeny_tree"
)

app_text <- list(
  en = list(
    eyebrow = "Shiny teaching app",
    hero_title = "Farm Animals Explorer",
    hero_copy = "Explore and compare cattle, sheep, pigs, and goats in one interactive platform! This Shiny app bridges genetics and culture—offering insights into species taxonomy, basic biology, English/Spanish terminology, religion-focused teaching prompts, and direct access to primary genome assemblies.",
    hero_note = "Edit the CSV files in the data folder, then restart the app to reload the teaching content without touching the app logic.",
    language_label = "Language / Idioma",
    hero_selector_label = "Quick species focus",
    hero_selector_note = "Click a species to refresh the selected animal across the explorer.",
    tab_species = "Species",
    tab_genome = "Genomes",
    tab_science = "Science",
    tab_religion = "Religion",
    tab_domestication = "Origins",
    tab_breeds = "Breeds",
    tab_anatomy = "Anatomy",
    tab_sustainability = "Sustainability",
    tab_quiz = "Quiz",
    tab_workflow = "Workflow",
    choose_species = "Choose a species",
    common_names_en = "Common names (English)",
    common_names_es = "Common names (Spanish)",
    taxonomy = "Taxonomy",
    basic_biology = "Basic biology",
    religion_culture = "Religion and culture",
    teaching_angle = "Teaching angle",
    science_kicker = "Animal models in research",
    science_key_advantage = "Key advantage in research",
    science_major_uses = "Major research uses",
    science_placeholder = "Science illustration coming soon for this species.",
    science_summary = "Why it matters in science",
    science_scientific_name = "Scientific name",
    religion_kicker = "Belief, symbolism, and food rules",
    religion_summary = "Religion and culture",
    religion_highlights = "Tradition highlights",
    religion_food_context = "Countries that consume it the most",
    religion_discussion = "Discussion prompt",
    religion_food_fallback = "Varies by region",
    workflow_heading = "Use this project in Positron",
    workflow_step_1 = "Open farm-animals-explorer.Rproj in Positron.",
    workflow_step_2 = "Install shiny if needed then run shiny::runApp() from the project root.",
    workflow_step_3 = "Edit data/species_profiles.csv to change the teaching text or common names.",
    workflow_step_4 = "Drop your large NCBI downloads into data-raw and keep only the small summary table in Git.",
    useful_commands = "Useful commands",
    github_workflow = "GitHub workflow",
    github_step_1 = "Use git init git add . and git commit -m 'Initial Shiny app'.",
    github_step_2 = "Create a remote repo with the GitHub website or gh repo create.",
    github_step_3 = "Push only code CSV summaries and documentation. Keep large FASTA archives outside the repo or in a separate storage service.",
    guide_comment = "# Rebuild the genome summary from your NCBI exports",
    not_available = "Not available",
    species_label = "Species",
    metric_label = "Metric",
    download_filtered_csv = "Download filtered CSV",
    breed_label = "Breed",
    accession_label = "Accession",
    source_database_label = "Source database",
    assembly_level_label = "Assembly level",
    assembly_name_label = "Assembly name",
    assembly_label = "Assembly",
    genome_size_label = "Genome size (Mb)",
    gc_percent_label = "GC percent",
    scaffold_n50_label = "Scaffold N50 (Mb)",
    data_note_label = "Data note:",
    genome_snapshot = "Genome snapshot",
    genome_compare_title = "Compare assembly summaries",
    genome_compare_body = "This tab reads the summary in data/genome_summary.csv. Rebuild it from your NCBI TSV and JSONL files whenever you update the dataset.",
    genome_hide_examples = "Hide non-project rows",
    genome_stories_title = "Interactive genomics stories",
    genome_stories_intro = "These Plotly charts turn genome facts into teaching moments. Hover over each figure to compare species, chromosome organization, and the hidden composition of animal DNA.",
    interactive_genomics_story = "Interactive genomics story",
    educational_hook = "Educational hook:",
    special_highlight = "Special highlight:",
    genome_note_no_rows = "No rows match the current filters. Add your own summary file or show the bundled example rows again.",
    genome_note_examples = "You are viewing bundled example assembly summaries. Replace data/genome_summary.csv when your own table is ready.",
    genome_note_showing = "Showing %s assembly rows across %s species.",
    teaching_prompt_label = "Teaching prompt:",
    genome_focus_title = "Selected species genome profile",
    genome_focus_empty = "No genome summary is available for the currently selected species.",
    genome_focus_selector_title = "Assembly focus",
    genome_focus_selector_label = "Assembly for the selected species",
    genome_focus_selector_note = "Switch between assemblies, breeds, and accessions for the species currently selected in the explorer.",
    genome_focus_available = "%s assemblies are available for %s.",
    genome_gallery_note = "Use the dropdown, the assembly cards, or the plots below to change the genome focus.",
    genome_focus_intro_with_breed = "%s is currently linked to the %s assembly from the %s breed.",
    genome_focus_intro_without_breed = "%s is currently linked to the %s assembly.",
    genome_focus_filter_note = "Add this species to the comparison list to compare it with the others.",
    genome_size_same = "Its genome size is almost identical to the average of the animals currently shown.",
    genome_size_above = "Its genome size is %s Mb above the current group average.",
    genome_size_below = "Its genome size is %s Mb below the current group average.",
    genome_n50_same = "Its scaffold N50 is almost identical to the current group average.",
    genome_n50_above = "Its scaffold N50 is %s Mb above the current group average.",
    genome_n50_below = "Its scaffold N50 is %s Mb below the current group average.",
    genome_plot_title = "Genome summary comparison",
    genome_landscape_title = "Genome landscape: size vs scaffold continuity",
    anatomy_figure_alt = "Ruminants versus pigs digestive anatomy",
    science_coming = "Science content coming soon",
    science_missing = "No science profile has been loaded for the currently selected species.",
    domestication_kicker = "Spatial and temporal history",
    domestication_title = "Domestication map and timeline",
    domestication_body = "Trace how cattle, sheep, goats, and pigs entered human history during the Neolithic revolution. Click a site to connect geography, archaeology, and ancient genomics.",
    domestication_filter_title = "Filter the domestication story",
    domestication_filter_body = "Narrow the species list or time window, then click a site to focus the historical notes.",
    years_before_present = "Years before present",
    domestication_note_empty = "No domestication sites match the current filters.",
    domestication_note_showing = "Showing %s domestication events from %s to %s years before present.",
    domestication_focus_title = "Selected domestication site",
    domestication_focus_empty = "Choose a species or widen the timeline range to see domestication events.",
    domestication_focus_intro = "%s domestication is currently focused on %s in %s.",
    wild_ancestor_label = "Wild ancestor",
    date_label = "Date",
    region_label = "Region",
    domestication_story = "Domestication story",
    archaeology_hook = "Archaeology hook",
    genome_fact = "Genome fact",
    domestication_map_title = "Domestication origins",
    domestication_timeline_title = "Timeline of domestication events",
    no_domestication_sites = "No domestication sites are available for the current filters.",
    breed_kicker = "Human selection in action",
    breed_title = "Breed matcher",
    breed_body = "Filter traditional and modern breeds to see how people shaped livestock for dairying, meat, fiber, labor, and laboratory research across very different environments.",
    breed_filter_title = "Find a breed",
    breed_filter_body = "Mix species, breeding purpose, and climate filters to compare local adaptations and genetic stories.",
    all_species = "All species",
    primary_purpose_label = "Primary purpose",
    any_purpose = "Any purpose",
    climate_adaptability_label = "Climate adaptability",
    any_climate = "Any climate",
    breed_note_empty = "No breeds match the current filters.",
    breed_note_showing = "Showing %s breeds across %s species.",
    no_breed_origins = "No breed origins are available for the current filters.",
    breed_map_title = "Origin map for the filtered breeds",
    no_matching_breeds = "No matching breeds",
    broaden_filters = "Try broadening the filters to bring more breeds back into view.",
    breed_image_placeholder = "Breed image coming soon.",
    purpose_label = "Purpose",
    climate_label = "Climate",
    origin_label = "Origin",
    breed_story = "Breed story",
    historical_usage_label = "Historical usage",
    genetic_hook_label = "Genetic hook",
    anatomy_kicker = "Comparative biology",
    anatomy_title = "Anatomy and digestive system explorer",
    anatomy_body = "Compare the microbial four-chamber engine of ruminants with the single-stomach digestion of pigs, then click each stage to follow feed, pH, and physiology.",
    quiz_kicker = "Learning checkpoint",
    quiz_title = "Interactive livestock quiz",
    quiz_body = "Test what you learned about taxonomy, chromosome counts, and digestive anatomy, then use the explanations as short teaching prompts.",
    anatomy_comparison_title = "At-a-glance comparison",
    anatomy_comparison_body = "Start with the shared overview below, then switch between ruminants and pigs to connect each labeled diagram with the underlying digestive strategy.",
    anatomy_choose_title = "Choose a digestive design",
    anatomy_choose_body = "Switch between ruminants and pigs, then open each chamber or section to follow the path of feed.",
    anatomy_visual_title = "System overview",
    anatomy_chambers_label = "Digestive plan",
    anatomy_fermentation_label = "Main fermentation site",
    anatomy_absorption_label = "Main absorption site",
    anatomy_reference_links = "Reference link",
    anatomy_reference_note = "Use the source link for a fuller labeled diagram and teaching background.",
    anatomy_ruminant_summary = "Ruminants move feed through a microbial foregut before it reaches the true stomach. Fermentation in the rumen-reticulum unlocks energy from cellulose, water is recovered in the omasum, and protein digestion intensifies in the abomasum.",
    anatomy_monogastric_summary = "Pigs use one stomach followed by long intestinal digestion. Acid starts protein digestion in the stomach, then pancreatic enzymes and bile drive most nutrient breakdown and absorption in the small intestine.",
    anatomy_ruminant_plan = "Four-compartment stomach",
    anatomy_monogastric_plan = "Single-chamber stomach",
    anatomy_ruminant_fermentation = "Rumen and reticulum",
    anatomy_monogastric_fermentation = "Cecum and colon only",
    anatomy_ruminant_absorption = "Small intestine after foregut fermentation",
    anatomy_monogastric_absorption = "Small intestine with enzymes and bile",
    digestive_design_label = "Digestive design",
    ruminant_design = "Ruminant (cattle, sheep, goats)",
    monogastric_design = "Monogastric pig",
    ruminant_intro_title = "The ruminant fermentation engine",
    ruminant_intro_body = "Cattle, sheep, and goats use four stomach compartments and a huge microbial workforce to turn cellulose-rich plants into nutrients.",
    monogastric_intro_title = "Pigs and humans: a simpler digestive plan",
    monogastric_intro_body = "Pigs rely on a single stomach and host enzymes, which makes their digestion and metabolism much closer to ours than a cow's rumen-driven system.",
    digestive_section_details = "Digestive section details",
    choose_digestive_system = "Choose a digestive system to start exploring.",
    ph_range_label = "pH range",
    seen_in_label = "Seen in",
    function_label = "Function",
    microbe_focus_label = "Microbe focus",
    feed_flow_label = "Feed flow",
    stage_label = "Stage",
    anatomy_figure_alt_ruminant = "Ruminant digestive tract diagram",
    anatomy_figure_alt_monogastric = "Monogastric pig digestive tract diagram",
    sustainability_kicker = "Ecology and food systems",
    sustainability_title = "The Livestock Paradox simulator",
    sustainability_body = "Model how feed choice and body mass change production, methane, and water use, then compare why ruminants succeed on rough land while pigs excel on concentrated feed.",
    sustainability_set_title = "Set the teaching scenario",
    sustainability_set_body = "Choose feed type and body mass to compare production and footprint tradeoffs across the four species.",
    feed_type_label = "Feed type",
    reference_body_mass_label = "Reference live body mass (kg)",
    simulator_how_to_read = "How to read this simulator",
    simulator_scale_text = "The outputs below scale from a typical reference animal to a %s kg teaching scenario.",
    simulator_note_grass = "Grass-based systems highlight why goats and sheep stay valuable on dry or marginal land where crops struggle.",
    simulator_note_grain = "Grain-based systems highlight how pigs convert concentrated feed efficiently, while ruminants trade higher methane for the ability to use forage.",
    no_sustainability_profiles = "No sustainability profiles are available for the selected feed type.",
    meat_output_label = "Meat output (kg)",
    milk_output_label = "Milk output (L)",
    sustainability_output_title = "Modeled outputs at the selected body mass",
    output_label = "Output",
    sustainability_footprint_title = "Footprint comparison",
    water_use_label = "Water use (L per kg protein)",
    methane_label = "Methane (kg CH4 per kg protein)",
    water_per_kg_protein = "Water per kg protein",
    methane_per_kg_protein = "Methane per kg protein",
    scenario_methane_total = "Scenario methane total",
    scenario_water_total = "Scenario water total",
    meat_output_short = "Meat output",
    milk_output_short = "Milk output",
    protein_label = "Protein",
    methane_total_label = "Methane total",
    water_total_label = "Water total"
  ),
  es = list(
    eyebrow = "Aplicacion didactica en Shiny",
    hero_title = "Explorador de animales de granja",
    hero_copy = "Explora y compara bovinos, ovejas, cerdos y cabras en una única plataforma interactiva. Esta aplicación Shiny conecta genética y cultura, y ofrece información sobre taxonomía, biología básica, terminología en inglés y español, notas didácticas centradas en la religión y acceso directo a ensamblajes genómicos primarios",
    hero_note = "Edita los archivos CSV de la carpeta data y luego reinicia la app para recargar el contenido didactico sin tocar la logica.",
    language_label = "Idioma / Language",
    hero_selector_label = "Enfoque rapido por especie",
    hero_selector_note = "Haz clic en una especie para actualizar el animal seleccionado en todo el explorador.",
    tab_species = "Especies",
    tab_genome = "Genomas",
    tab_science = "Ciencia",
    tab_religion = "Religion",
    tab_domestication = "Origenes",
    tab_breeds = "Razas",
    tab_anatomy = "Anatomia",
    tab_sustainability = "Sostenibilidad",
    tab_quiz = "Quiz",
    tab_workflow = "Flujo de trabajo",
    choose_species = "Elige una especie",
    common_names_en = "Nombres comunes (ingles)",
    common_names_es = "Nombres comunes (espanol)",
    taxonomy = "Taxonomia",
    basic_biology = "Biologia basica",
    religion_culture = "Religion y cultura",
    teaching_angle = "Enfoque didactico",
    science_kicker = "Modelos animales en investigacion",
    science_key_advantage = "Ventaja principal en investigacion",
    science_major_uses = "Usos principales en investigacion",
    science_placeholder = "La ilustracion cientifica para esta especie se agregara mas adelante.",
    science_summary = "Por que importa en la ciencia",
    science_scientific_name = "Nombre cientifico",
    religion_kicker = "Creencias simbolismo y normas alimentarias",
    religion_summary = "Religion y cultura",
    religion_highlights = "Claves por tradicion",
    religion_food_context = "Paises que mas lo consumen",
    religion_discussion = "Pregunta para discutir",
    religion_food_fallback = "Varia segun la region",
    workflow_heading = "Usa este proyecto en Positron",
    workflow_step_1 = "Abre farm-animals-explorer.Rproj en Positron.",
    workflow_step_2 = "Instala shiny si hace falta y luego ejecuta shiny::runApp() desde la carpeta del proyecto.",
    workflow_step_3 = "Edita data/species_profiles.csv para cambiar el texto didactico o los nombres comunes.",
    workflow_step_4 = "Guarda las descargas grandes de NCBI en data-raw y conserva en Git solo las tablas pequenas de resumen.",
    useful_commands = "Comandos utiles",
    github_workflow = "Flujo de trabajo con GitHub",
    github_step_1 = "Usa git init git add . y git commit -m 'Initial Shiny app'.",
    github_step_2 = "Crea un repositorio remoto con la pagina web de GitHub o con gh repo create.",
    github_step_3 = "Sube solo el codigo los resumenes CSV y la documentacion. Guarda los archivos FASTA grandes fuera del repositorio o en otro servicio de almacenamiento.",
    guide_comment = "# Reconstruye el resumen del genoma a partir de tus exportaciones de NCBI",
    download_filtered_csv = "Descargar CSV filtrado",
    genome_focus_selector_title = "Enfoque de ensamblaje",
    genome_focus_selector_label = "Ensamblaje para la especie seleccionada",
    genome_focus_selector_note = "Cambia entre ensamblajes, razas y accesiones para la especie actualmente seleccionada en el explorador.",
    genome_focus_available = "Hay %s ensamblajes disponibles para %s.",
    genome_gallery_note = "Usa el menu desplegable, las tarjetas de ensamblaje o las graficas para cambiar el foco del genoma.",
    genome_landscape_title = "Paisaje del genoma: tamano y continuidad de scaffolds",
    anatomy_kicker = "Biologia comparativa",
    anatomy_title = "Explorador de anatomia y sistema digestivo",
    anatomy_body = "Compara el motor microbiano de cuatro compartimentos de los rumiantes con la digestion de estomago unico de los cerdos y haz clic en cada etapa para seguir el alimento, el pH y la fisiologia.",
    quiz_kicker = "Punto de repaso",
    quiz_title = "Quiz interactivo sobre animales de granja",
    quiz_body = "Pon a prueba lo aprendido sobre taxonomia, recuentos cromosomicos y anatomia digestiva, y usa las explicaciones como pequenos disparadores didacticos.",
    anatomy_comparison_title = "Comparacion general",
    anatomy_comparison_body = "Empieza con la vista compartida de abajo y luego alterna entre rumiantes y cerdos para relacionar cada diagrama rotulado con su estrategia digestiva.",
    anatomy_figure_alt = "Anatomia digestiva de rumiantes y cerdos",
    anatomy_visual_title = "Resumen del sistema",
    anatomy_chambers_label = "Plan digestivo",
    anatomy_fermentation_label = "Sitio principal de fermentacion",
    anatomy_absorption_label = "Sitio principal de absorcion",
    anatomy_reference_links = "Enlace de referencia",
    anatomy_reference_note = "Usa el enlace fuente para ver un diagrama mas completo y material didactico.",
    anatomy_ruminant_summary = "Los rumiantes mueven el alimento a traves de un sistema anterior microbiano antes de llegar al estomago verdadero. La fermentacion en el rumen-reticulo libera energia de la celulosa, el omaso recupera agua y la digestion proteica se intensifica en el abomaso.",
    anatomy_monogastric_summary = "Los cerdos usan un solo estomago seguido por una digestion intestinal prolongada. El acido inicia la digestion de proteinas en el estomago y despues las enzimas pancreaticas y la bilis realizan la mayor parte de la digestion y absorcion en el intestino delgado.",
    anatomy_ruminant_plan = "Estomago de cuatro compartimentos",
    anatomy_monogastric_plan = "Estomago de una sola camara",
    anatomy_ruminant_fermentation = "Rumen y reticulo",
    anatomy_monogastric_fermentation = "Solo ciego y colon",
    anatomy_ruminant_absorption = "Intestino delgado despues de la fermentacion",
    anatomy_monogastric_absorption = "Intestino delgado con enzimas y bilis",
    anatomy_figure_alt_ruminant = "Diagrama del tracto digestivo de un rumiante",
    anatomy_figure_alt_monogastric = "Diagrama del tracto digestivo monogastrico del cerdo"
  ),
  pt = list(
    eyebrow = "Aplicativo didatico em Shiny",
    hero_title = "Explorador de animais de fazenda",
    hero_copy = "Explore e compare bovinos, ovelhas, porcos e cabras em uma plataforma interativa! Este aplicativo Shiny conecta genética e cultura, oferecendo informações sobre taxonomia das espécies, biologia básica, terminologia em inglês e espanhol, prompts didáticos com foco em religião e acesso direto a montagens genômicas primárias",
    hero_note = "Edite os arquivos CSV da pasta data e depois reinicie o aplicativo para recarregar o conteudo didatico sem mexer na logica.",
    language_label = "Idioma / Language",
    hero_selector_label = "Foco rapido por especie",
    hero_selector_note = "Clique em uma especie para atualizar o animal selecionado em todo o explorador.",
    tab_species = "Especies",
    tab_genome = "Genomas",
    tab_science = "Ciencia",
    tab_religion = "Religiao",
    tab_domestication = "Origens",
    tab_breeds = "Racas",
    tab_anatomy = "Anatomia",
    tab_sustainability = "Sustentabilidade",
    tab_quiz = "Quiz",
    tab_workflow = "Fluxo de trabalho",
    choose_species = "Escolha uma especie",
    common_names_en = "Nomes comuns (ingles)",
    common_names_es = "Nomes comuns (espanhol)",
    taxonomy = "Taxonomia",
    basic_biology = "Biologia basica",
    religion_culture = "Religiao e cultura",
    teaching_angle = "Enfoque didatico",
    science_kicker = "Modelos animais em pesquisa",
    science_key_advantage = "Principal vantagem em pesquisa",
    science_major_uses = "Principais usos em pesquisa",
    science_placeholder = "A ilustracao cientifica para esta especie sera adicionada em breve.",
    science_summary = "Por que importa na ciencia",
    science_scientific_name = "Nome cientifico",
    religion_kicker = "Crença simbolismo e regras alimentares",
    religion_summary = "Religiao e cultura",
    religion_highlights = "Pontos por tradicao",
    religion_food_context = "Paises que mais consomem",
    religion_discussion = "Pergunta para discussao",
    religion_food_fallback = "Varia conforme a regiao",
    workflow_heading = "Use este projeto no Positron",
    workflow_step_1 = "Abra farm-animals-explorer.Rproj no Positron.",
    workflow_step_2 = "Instale shiny se necessario e depois execute shiny::runApp() a partir da pasta do projeto.",
    workflow_step_3 = "Edite data/species_profiles.csv para mudar o texto didatico ou os nomes comuns.",
    workflow_step_4 = "Guarde os downloads grandes do NCBI em data-raw e mantenha no Git apenas as tabelas pequenas de resumo.",
    useful_commands = "Comandos uteis",
    github_workflow = "Fluxo de trabalho com GitHub",
    github_step_1 = "Use git init git add . e git commit -m 'Initial Shiny app'.",
    github_step_2 = "Crie um repositorio remoto pelo site do GitHub ou com gh repo create.",
    github_step_3 = "Envie apenas codigo resumos CSV e documentacao. Guarde arquivos FASTA grandes fora do repositorio ou em outro servico de armazenamento.",
    guide_comment = "# Reconstrua o resumo do genoma a partir das exportacoes do NCBI",
    not_available = "Nao disponivel",
    species_label = "Especie",
    metric_label = "Metrica",
    download_filtered_csv = "Baixar CSV filtrado",
    breed_label = "Raca",
    accession_label = "Acesso",
    source_database_label = "Banco de dados de origem",
    assembly_level_label = "Nivel da montagem",
    assembly_name_label = "Nome da montagem",
    assembly_label = "Montagem",
    genome_size_label = "Tamanho do genoma (Mb)",
    gc_percent_label = "Percentual de GC",
    scaffold_n50_label = "Scaffold N50 (Mb)",
    data_note_label = "Nota dos dados:",
    genome_snapshot = "Resumo do genoma",
    genome_compare_title = "Compare resumos de montagens",
    genome_compare_body = "Esta aba le o resumo em data/genome_summary.csv. Reconstrua a tabela a partir dos seus arquivos TSV e JSONL do NCBI sempre que atualizar o conjunto de dados.",
    genome_hide_examples = "Ocultar linhas fora do projeto",
    genome_stories_title = "Historias interativas de genomica",
    genome_stories_intro = "Esses graficos em Plotly transformam fatos genomicos em momentos de ensino. Passe o mouse em cada figura para comparar especies, organizacao cromossomica e a composicao oculta do DNA animal.",
    interactive_genomics_story = "Historia interativa de genomica",
    educational_hook = "Gancho didatico:",
    special_highlight = "Destaque especial:",
    genome_note_no_rows = "Nenhuma linha corresponde aos filtros atuais. Adicione sua propria tabela de resumo ou volte a mostrar as linhas de exemplo.",
    genome_note_examples = "Voce esta visualizando resumos de montagens de exemplo. Substitua data/genome_summary.csv quando sua propria tabela estiver pronta.",
    genome_note_showing = "Mostrando %s linhas de montagem em %s especies.",
    teaching_prompt_label = "Pergunta didatica:",
    genome_focus_title = "Perfil do genoma da especie selecionada",
    genome_focus_empty = "Nao ha resumo de genoma disponivel para a especie selecionada.",
    genome_focus_selector_title = "Foco da montagem",
    genome_focus_selector_label = "Montagem para a especie selecionada",
    genome_focus_selector_note = "Alterne entre montagens, racas e acessos para a especie atualmente selecionada no explorador.",
    genome_focus_available = "Ha %s montagens disponiveis para %s.",
    genome_gallery_note = "Use o menu, os cards de montagem ou os graficos abaixo para mudar o foco do genoma.",
    genome_focus_intro_with_breed = "%s esta atualmente ligada a montagem %s da raca %s.",
    genome_focus_intro_without_breed = "%s esta atualmente ligada a montagem %s.",
    genome_focus_filter_note = "Adicione esta especie a lista de comparacao para compara-la com as outras.",
    genome_size_same = "O tamanho do genoma e quase identico a media dos animais mostrados no momento.",
    genome_size_above = "O tamanho do genoma esta %s Mb acima da media atual do grupo.",
    genome_size_below = "O tamanho do genoma esta %s Mb abaixo da media atual do grupo.",
    genome_n50_same = "O scaffold N50 e quase identico a media atual do grupo.",
    genome_n50_above = "O scaffold N50 esta %s Mb acima da media atual do grupo.",
    genome_n50_below = "O scaffold N50 esta %s Mb abaixo da media atual do grupo.",
    genome_plot_title = "Comparacao do resumo do genoma",
    genome_landscape_title = "Panorama do genoma: tamanho e continuidade de scaffolds",
    anatomy_figure_alt = "Anatomia digestiva de ruminantes e porcos",
    science_coming = "Conteudo cientifico em breve",
    science_missing = "Nenhum perfil cientifico foi carregado para a especie selecionada.",
    domestication_kicker = "Historia espacial e temporal",
    domestication_title = "Mapa e linha do tempo da domesticacao",
    domestication_body = "Acompanhe como bovinos, ovelhas, cabras e porcos entraram na historia humana durante a Revolucao Neolitica. Clique em um local para conectar geografia, arqueologia e genomica antiga.",
    domestication_filter_title = "Filtre a historia da domesticacao",
    domestication_filter_body = "Restrinja a lista de especies ou a janela de tempo, depois clique em um local para focar nas notas historicas.",
    years_before_present = "Anos antes do presente",
    domestication_note_empty = "Nenhum sitio de domesticacao corresponde aos filtros atuais.",
    domestication_note_showing = "Mostrando %s eventos de domesticacao de %s a %s anos antes do presente.",
    domestication_focus_title = "Sitio de domesticacao selecionado",
    domestication_focus_empty = "Escolha uma especie ou amplie o intervalo da linha do tempo para ver eventos de domesticacao.",
    domestication_focus_intro = "A domesticacao de %s esta atualmente focada em %s, em %s.",
    wild_ancestor_label = "Ancestral selvagem",
    date_label = "Data",
    region_label = "Regiao",
    domestication_story = "Historia da domesticacao",
    archaeology_hook = "Gancho arqueologico",
    genome_fact = "Fato genomico",
    domestication_map_title = "Origens da domesticacao",
    domestication_timeline_title = "Linha do tempo dos eventos de domesticacao",
    no_domestication_sites = "Nenhum sitio de domesticacao esta disponivel para os filtros atuais.",
    breed_kicker = "Selecao humana em acao",
    breed_title = "Buscador de racas",
    breed_body = "Filtre racas tradicionais e modernas para ver como as pessoas moldaram os animais domesticos para leite, carne, fibra, trabalho e pesquisa laboratorial em ambientes muito diferentes.",
    breed_filter_title = "Encontre uma raca",
    breed_filter_body = "Combine filtros de especie, finalidade de selecao e clima para comparar adaptacoes locais e historias geneticas.",
    all_species = "Todas as especies",
    primary_purpose_label = "Finalidade principal",
    any_purpose = "Qualquer finalidade",
    climate_adaptability_label = "Adaptacao climatica",
    any_climate = "Qualquer clima",
    breed_note_empty = "Nenhuma raca corresponde aos filtros atuais.",
    breed_note_showing = "Mostrando %s racas em %s especies.",
    no_breed_origins = "Nenhuma origem de raca esta disponivel para os filtros atuais.",
    breed_map_title = "Mapa de origem das racas filtradas",
    no_matching_breeds = "Nenhuma raca correspondente",
    broaden_filters = "Tente ampliar os filtros para trazer mais racas de volta para a visualizacao.",
    breed_image_placeholder = "Imagem da raca em breve.",
    purpose_label = "Finalidade",
    climate_label = "Clima",
    origin_label = "Origem",
    breed_story = "Historia da raca",
    historical_usage_label = "Uso historico",
    genetic_hook_label = "Gancho genetico",
    anatomy_kicker = "Biologia comparativa",
    anatomy_title = "Explorador de anatomia e sistema digestivo",
    anatomy_body = "Compare o motor microbiano de quatro compartimentos dos ruminantes com a digestao de estomago unico dos porcos e clique em cada etapa para acompanhar alimento, pH e fisiologia.",
    quiz_kicker = "Ponto de revisao",
    quiz_title = "Quiz interativo sobre animais de producao",
    quiz_body = "Teste o que foi aprendido sobre taxonomia, contagem cromossomica e anatomia digestiva, e use as explicacoes como pequenos gatilhos didaticos.",
    anatomy_comparison_title = "Comparacao geral",
    anatomy_comparison_body = "Comece pela visao comparativa abaixo e depois alterne entre ruminantes e porcos para ligar cada diagrama rotulado a sua estrategia digestiva.",
    anatomy_choose_title = "Escolha um desenho digestivo",
    anatomy_choose_body = "Alterne entre ruminantes e porcos e depois abra cada camara ou secao para seguir o caminho do alimento.",
    anatomy_visual_title = "Visao geral do sistema",
    anatomy_chambers_label = "Plano digestivo",
    anatomy_fermentation_label = "Principal local de fermentacao",
    anatomy_absorption_label = "Principal local de absorcao",
    anatomy_reference_links = "Link de referencia",
    anatomy_reference_note = "Use o link de referencia para ver um diagrama mais completo e mais contexto didatico.",
    anatomy_ruminant_summary = "Ruminantes movem o alimento por um compartimento anterior microbiano antes de ele chegar ao estomago verdadeiro. A fermentacao no rumem-reticulo libera energia da celulose, o omaso recupera agua e a digestao proteica se intensifica no abomaso.",
    anatomy_monogastric_summary = "Porcos usam um unico estomago seguido por longa digestao intestinal. O acido inicia a digestao de proteinas no estomago e depois enzimas pancreaticas e bile fazem a maior parte da quebra e da absorcao de nutrientes no intestino delgado.",
    anatomy_ruminant_plan = "Estomago de quatro compartimentos",
    anatomy_monogastric_plan = "Estomago de uma camara",
    anatomy_ruminant_fermentation = "Rumen e reticulo",
    anatomy_monogastric_fermentation = "Apenas ceco e colon",
    anatomy_ruminant_absorption = "Intestino delgado apos fermentacao anterior",
    anatomy_monogastric_absorption = "Intestino delgado com enzimas e bile",
    digestive_design_label = "Desenho digestivo",
    ruminant_design = "Ruminante (bovinos, ovelhas, cabras)",
    monogastric_design = "Porco monogastrico",
    ruminant_intro_title = "O motor fermentativo dos ruminantes",
    ruminant_intro_body = "Bovinos, ovelhas e cabras usam quatro compartimentos estomacais e uma enorme comunidade microbiana para transformar plantas ricas em celulose em nutrientes.",
    monogastric_intro_title = "Porcos e humanos: um plano digestivo mais simples",
    monogastric_intro_body = "Porcos dependem de um unico estomago e de enzimas do proprio hospedeiro, o que torna sua digestao e metabolismo muito mais proximos dos nossos do que do sistema ruminal dos bovinos.",
    digestive_section_details = "Detalhes da secao digestiva",
    choose_digestive_system = "Escolha um sistema digestivo para comecar a explorar.",
    ph_range_label = "Faixa de pH",
    seen_in_label = "Visto em",
    function_label = "Funcao",
    microbe_focus_label = "Foco microbiano",
    feed_flow_label = "Fluxo do alimento",
    stage_label = "Etapa",
    anatomy_figure_alt_ruminant = "Diagrama do trato digestivo de ruminante",
    anatomy_figure_alt_monogastric = "Diagrama do trato digestivo monogastrico do porco",
    sustainability_kicker = "Ecologia e sistemas alimentares",
    sustainability_title = "Simulador do paradoxo da pecuaria",
    sustainability_body = "Modele como o tipo de alimento e a massa corporal mudam producao, metano e uso de agua, depois compare por que ruminantes se saem bem em terras mais dificeis enquanto porcos se destacam com alimento concentrado.",
    sustainability_set_title = "Defina o cenario didatico",
    sustainability_set_body = "Escolha o tipo de alimento e a massa corporal para comparar diferencas de producao e pegada entre as quatro especies.",
    feed_type_label = "Tipo de alimento",
    reference_body_mass_label = "Massa corporal viva de referencia (kg)",
    simulator_how_to_read = "Como ler este simulador",
    simulator_scale_text = "Os resultados abaixo escalam de um animal tipico de referencia para um cenario didatico de %s kg.",
    simulator_note_grass = "Sistemas baseados em pasto mostram por que cabras e ovelhas continuam valiosas em areas secas ou marginais onde cultivos tem dificuldade.",
    simulator_note_grain = "Sistemas baseados em graos mostram como os porcos convertem alimento concentrado com eficiencia, enquanto ruminantes trocam mais metano pela capacidade de usar forragem.",
    no_sustainability_profiles = "Nao ha perfis de sustentabilidade disponiveis para o tipo de alimento selecionado.",
    meat_output_label = "Producao de carne (kg)",
    milk_output_label = "Producao de leite (L)",
    sustainability_output_title = "Resultados modelados para a massa corporal selecionada",
    output_label = "Resultado",
    sustainability_footprint_title = "Comparacao de pegada",
    water_use_label = "Uso de agua (L por kg de proteina)",
    methane_label = "Metano (kg CH4 por kg de proteina)",
    water_per_kg_protein = "Agua por kg de proteina",
    methane_per_kg_protein = "Metano por kg de proteina",
    scenario_methane_total = "Metano total do cenario",
    scenario_water_total = "Agua total do cenario",
    meat_output_short = "Producao de carne",
    milk_output_short = "Producao de leite",
    protein_label = "Proteina",
    methane_total_label = "Metano total",
    water_total_label = "Agua total"
  )
)

religion_highlights <- list(
  en = list(
    cattle = c(
      "Hindu traditions" = "Often treated as sacred or symbolically important.",
      "Abrahamic texts" = "Linked with wealth, sacrifice, and agriculture.",
      "Classroom lens" = "Shows how one species can carry very different meanings."
    ),
    sheep = c(
      "Christianity" = "Lamb symbolism is tied to innocence and sacrifice.",
      "Judaism" = "Sheep and lambs appear in ritual and historical memory.",
      "Classroom lens" = "Useful for discussing pastoral care, community, and symbolism."
    ),
    pig = c(
      "Judaism and Islam" = "Pork is generally prohibited in dietary law.",
      "Many Christian traditions" = "Pork is often permitted and widely consumed.",
      "Classroom lens" = "A strong example of food taboo, identity, and belonging."
    ),
    goat = c(
      "Judaism and Islam" = "Goats appear in sacrifice traditions and festival discussions.",
      "Biblical tradition" = "The scapegoat story links goats with exclusion and atonement.",
      "Classroom lens" = "Helpful for comparing purity, sacrifice, and close relatives like sheep."
    )
  ),
  es = list(
    cattle = c(
      "Tradiciones hinduistas" = "A menudo se consideran sagrados o simbolicamente importantes.",
      "Textos abrahamicos" = "Se relacionan con riqueza sacrificio y agricultura.",
      "Enfoque en clase" = "Muestran como una sola especie puede tener significados muy distintos."
    ),
    sheep = c(
      "Cristianismo" = "La imagen del cordero se asocia con inocencia y sacrificio.",
      "Judaismo" = "Las ovejas y los corderos aparecen en rituales y memoria historica.",
      "Enfoque en clase" = "Sirven para hablar de cuidado pastoral comunidad y simbolismo."
    ),
    pig = c(
      "Judaismo e islam" = "La carne de cerdo suele estar prohibida en la ley alimentaria.",
      "Muchas tradiciones cristianas" = "La carne de cerdo suele permitirse y consumirse ampliamente.",
      "Enfoque en clase" = "Es un ejemplo claro de tabu alimentario identidad y pertenencia."
    ),
    goat = c(
      "Judaismo e islam" = "Las cabras aparecen en tradiciones de sacrificio y festividades.",
      "Tradicion biblica" = "El chivo expiatorio vincula a la cabra con exclusion y expiacion.",
      "Enfoque en clase" = "Ayudan a comparar pureza sacrificio y parentesco con las ovejas."
    )
  ),
  pt = list(
    cattle = c(
      "Tradicoes hindus" = "Frequentemente sao tratados como sagrados ou simbolicamente importantes.",
      "Textos abraamicos" = "Relacionam-se com riqueza, sacrificio e agricultura.",
      "Olhar de sala de aula" = "Mostra como uma mesma especie pode carregar significados muito diferentes."
    ),
    sheep = c(
      "Cristianismo" = "O simbolismo do cordeiro esta ligado a inocencia e sacrificio.",
      "Judaismo" = "Ovelhas e cordeiros aparecem em rituais e na memoria historica.",
      "Olhar de sala de aula" = "Uteis para discutir cuidado pastoral, comunidade e simbolismo."
    ),
    pig = c(
      "Judaismo e islam" = "A carne suina geralmente e proibida pelas leis alimentares.",
      "Muitas tradicoes cristas" = "A carne de porco costuma ser permitida e amplamente consumida.",
      "Olhar de sala de aula" = "Um forte exemplo de tabu alimentar, identidade e pertencimento."
    ),
    goat = c(
      "Judaismo e islam" = "Cabras aparecem em tradicoes de sacrificio e discussoes sobre festivais.",
      "Tradicao biblica" = "A historia do bode expiatorio liga cabras a exclusao e expiacao.",
      "Olhar de sala de aula" = "Ajuda a comparar pureza, sacrificio e parentes proximos como as ovelhas."
    )
  )
)

purpose_translations <- list(
  en = c(
    "Dairy" = "Dairy",
    "Meat" = "Meat",
    "Fiber/Wool" = "Fiber/Wool",
    "Draft" = "Draft",
    "Laboratory Model" = "Laboratory Model"
  ),
  pt = c(
    "Dairy" = "Leite",
    "Meat" = "Carne",
    "Fiber/Wool" = "Fibra/La",
    "Draft" = "Tracao",
    "Laboratory Model" = "Modelo laboratorial"
  )
)

climate_translations <- list(
  en = c(
    "Heat tolerant" = "Heat tolerant",
    "Cold hardy" = "Cold hardy"
  ),
  pt = c(
    "Heat tolerant" = "Tolerante ao calor",
    "Cold hardy" = "Resistente ao frio"
  )
)

feed_translations <- list(
  en = c(
    grazing = "Grazing / grass",
    grain = "Grain / concentrate"
  ),
  pt = c(
    grazing = "Pasto / graminea",
    grain = "Grao / concentrado"
  )
)

tr <- function(lang, key) {
  value <- app_text[[lang]][[key]]

  if (is.null(value)) {
    return(app_text$en[[key]])
  }

  value
}

format_text_value <- function(value, fallback = "Not available") {
  if (length(value) == 0) {
    return(fallback)
  }

  text <- as.character(value[[1]])

  if (is.na(text) || !nzchar(trimws(text))) {
    return(fallback)
  }

  text
}

plotly_title_spec <- function(value, fallback = "") {
  list(text = format_text_value(value, fallback = fallback))
}

plotly_axis_title_spec <- function(value, fallback = "") {
  list(text = format_text_value(value, fallback = fallback))
}

build_empty_plotly_message <- function(message, source_id = NULL) {
  p <- plotly::plot_ly(
    x = numeric(0),
    y = numeric(0),
    type = "scatter",
    mode = "markers",
    source = source_id
  ) %>%
    plotly::layout(
      margin = list(l = 20, r = 20, b = 20, t = 20),
      xaxis = list(visible = FALSE, showgrid = FALSE, zeroline = FALSE),
      yaxis = list(visible = FALSE, showgrid = FALSE, zeroline = FALSE),
      annotations = list(
        list(
          x = 0.5,
          y = 0.5,
          xref = "paper",
          yref = "paper",
          text = format_text_value(message, fallback = "No data available"),
          showarrow = FALSE,
          font = list(size = 15, color = "#824C71")
        )
      ),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)"
    )

  if (!is.null(source_id) && nzchar(source_id)) {
    p <- plotly::event_register(p, "plotly_click")
  }

  p %>%
    plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)
}

format_numeric_value <- function(value, digits = 2, suffix = "") {
  if (length(value) == 0) {
    return("Not available")
  }

  number <- suppressWarnings(as.numeric(value[[1]]))

  if (is.na(number)) {
    return("Not available")
  }

  paste0(
    format(round(number, digits), nsmall = digits, trim = TRUE, scientific = FALSE),
    suffix
  )
}

localized_species_label <- function(row, lang = "en") {
  localized_col <- paste0("display_name_", lang)

  if (!identical(lang, "en") && localized_col %in% names(row)) {
    return(format_text_value(row[[localized_col]], fallback = format_text_value(row$display_name)))
  }

  format_text_value(row$display_name)
}

localized_species_text <- function(row, english_col, lang = "en") {
  localized_col <- paste0(english_col, "_", lang)

  if (!identical(lang, "en") && localized_col %in% names(row)) {
    return(format_text_value(row[[localized_col]], fallback = format_text_value(row[[english_col]])))
  }

  format_text_value(row[[english_col]])
}

localized_science_text <- function(row, base_name, lang = "en") {
  target_col <- paste0(base_name, "_", lang)
  english_col <- paste0(base_name, "_en")

  if (target_col %in% names(row)) {
    return(format_text_value(row[[target_col]], fallback = format_text_value(row[[english_col]])))
  }

  format_text_value(row[[english_col]])
}

localized_story_text <- function(row, english_col, lang = "en") {
  localized_col <- paste0(english_col, "_", lang)

  if (!identical(lang, "en") && localized_col %in% names(row)) {
    return(format_text_value(row[[localized_col]], fallback = format_text_value(row[[english_col]])))
  }

  format_text_value(row[[english_col]])
}

localized_species_name_by_id <- function(species_id, lang = "en") {
  row <- species_data[species_data$species_id == species_id, , drop = FALSE]

  if (nrow(row) == 0) {
    return(species_id)
  }

  localized_species_label(row, lang)
}

build_hero_scientific_name <- function(value) {
  text <- format_text_value(value)

  if (identical(text, "Not available")) {
    return(text)
  }

  words <- strsplit(text, "\\s+")[[1]]

  if (length(words) >= 3) {
    return(paste0(substr(words[1], 1, 1), ". ", words[2]))
  }

  paste(words, collapse = " ")
}

translate_choice_value <- function(value, dictionary, lang = "en") {
  if (length(value) > 1) {
    return(vapply(value, translate_choice_value, character(1), dictionary = dictionary, lang = lang))
  }

  lang_map <- dictionary[[lang]]

  if (is.null(lang_map)) {
    lang_map <- dictionary$en
  }

  translated <- unname(lang_map[[value]])

  if (is.null(translated) || is.na(translated) || !nzchar(translated)) {
    return(value)
  }

  translated
}

metric_labels_for <- function(lang = "en") {
  c(
    genome_mb = tr(lang, "genome_size_label"),
    gc_percent = tr(lang, "gc_percent_label"),
    scaffold_n50_mb = tr(lang, "scaffold_n50_label")
  )
}

genome_metric_explanations_by_lang <- list(
  en = list(
    genome_mb = list(
      title = "Genome size (Mb)",
      explanation = paste(
        "Genome size is the total amount of assembled DNA. Bigger values do not automatically",
        "mean a more complex animal but they do show how much sequence was captured in the assembly."
      ),
      teaching_prompt = "Ask students whether body size diet or domestication history seems to predict genome size."
    ),
    gc_percent = list(
      title = "GC percent",
      explanation = paste(
        "GC percent is the share of genome bases that are G or C. It helps describe genome composition",
        "and can influence how DNA behaves during sequencing and assembly."
      ),
      teaching_prompt = "Ask students whether closely related ruminants have noticeably different GC composition."
    ),
    scaffold_n50_mb = list(
      title = "Scaffold N50 (Mb)",
      explanation = paste(
        "Scaffold N50 is a continuity metric. Higher values usually mean the genome was assembled into",
        "longer pieces which often makes genes and chromosomes easier to study."
      ),
      teaching_prompt = "Ask students why assembly quality matters before making biological comparisons."
    )
  ),
  pt = list(
    genome_mb = list(
      title = "Tamanho do genoma (Mb)",
      explanation = paste(
        "O tamanho do genoma e a quantidade total de DNA montado. Valores maiores nao significam",
        "automaticamente um animal mais complexo, mas mostram quanta sequencia foi capturada na montagem."
      ),
      teaching_prompt = "Pergunte aos estudantes se tamanho corporal, dieta ou historia de domesticacao parecem prever o tamanho do genoma."
    ),
    gc_percent = list(
      title = "Percentual de GC",
      explanation = paste(
        "O percentual de GC e a proporcao de bases do genoma que sao G ou C. Ele ajuda a descrever a composicao do genoma",
        "e pode influenciar o comportamento do DNA durante o sequenciamento e a montagem."
      ),
      teaching_prompt = "Pergunte aos estudantes se ruminantes proximamente relacionados apresentam diferencas perceptiveis na composicao de GC."
    ),
    scaffold_n50_mb = list(
      title = "Scaffold N50 (Mb)",
      explanation = paste(
        "Scaffold N50 e uma metrica de continuidade. Valores mais altos geralmente significam que o genoma foi montado em",
        "fragmentos mais longos, o que costuma facilitar o estudo de genes e cromossomos."
      ),
      teaching_prompt = "Pergunte aos estudantes por que a qualidade da montagem importa antes de fazer comparacoes biologicas."
    )
  )
)

metric_help_for <- function(metric, lang = "en") {
  help_text <- genome_metric_explanations_by_lang[[lang]][[metric]]

  if (is.null(help_text)) {
    help_text <- genome_metric_explanations_by_lang$en[[metric]]
  }

  help_text
}

sort_genome_rows <- function(df) {
  if (nrow(df) == 0) {
    return(df)
  }

  level_rank <- c(
    "Complete Genome" = 4,
    "Chromosome" = 3,
    "Scaffold" = 2,
    "Contig" = 1
  )

  df$assembly_level_rank <- unname(level_rank[df$assembly_level])
  df$assembly_level_rank[is.na(df$assembly_level_rank)] <- 0

  ordered <- df[order(
    df$assembly_level_rank,
    df$scaffold_n50_mb,
    df$genome_mb,
    decreasing = TRUE,
    na.last = TRUE
  ), , drop = FALSE]

  ordered$assembly_level_rank <- NULL
  ordered
}

build_genome_choice_label <- function(row) {
  breed <- format_text_value(row$breed, fallback = "")
  source_db <- format_text_value(row$source_db, fallback = "")
  label_parts <- c(format_text_value(row$assembly_name))

  if (nzchar(breed)) {
    label_parts <- c(label_parts, breed)
  }

  if (nzchar(source_db)) {
    label_parts <- c(label_parts, source_db)
  }

  label_parts <- c(label_parts, format_text_value(row$accession))
  paste(label_parts, collapse = " | ")
}

encode_genome_target <- function(species_id, accession) {
  paste(species_id, accession, sep = "||")
}

decode_genome_target <- function(value) {
  if (length(value) == 0 || is.null(value) || is.na(value)) {
    return(NULL)
  }

  parts <- strsplit(as.character(value[[1]]), "\\|\\|")[[1]]

  if (length(parts) < 2) {
    return(NULL)
  }

  list(
    species_id = parts[[1]],
    accession = parts[[2]]
  )
}

build_guide_code <- function(lang = "en") {
  paste(
    "shiny::runApp()",
    "",
    tr(lang, "guide_comment"),
    "source('scripts/build_genome_summary_from_ncbi_table.R')",
    "build_genome_summary('data-raw/assembly_table.tsv')",
    sep = "\n"
  )
}

build_chip <- function(label, value) {
  tags$div(
    class = "info-chip",
    tags$span(class = "chip-label", label),
    tags$span(class = "chip-value", value)
  )
}

build_section <- function(title, ...) {
  tags$section(
    class = "detail-section",
    tags$h3(title),
    ...
  )
}

build_taxonomy_rows <- function(row, lang = "en") {
  labels <- if (identical(lang, "es")) {
    c("Reino", "Filo", "Clase", "Orden", "Familia", "Genero")
  } else if (identical(lang, "pt")) {
    c("Reino", "Filo", "Classe", "Ordem", "Familia", "Genero")
  } else {
    c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus")
  }

  taxonomy <- c(
    row$kingdom,
    row$phylum,
    row$class,
    row$order,
    row$family,
    row$genus
  )

  lapply(seq_along(taxonomy), function(index) {
    tags$tr(
      tags$th(labels[[index]]),
      tags$td(taxonomy[[index]])
    )
  })
}

build_metadata_rows <- function(metadata) {
  lapply(names(metadata), function(label) {
    tags$tr(
      tags$th(label),
      tags$td(metadata[[label]])
    )
  })
}

build_species_card_icon <- function(row, lang = "en") {
  species_id <- format_text_value(row$species_id)
  image_name <- species_icon_files[[species_id]]

  if (is.null(image_name)) {
    return(NULL)
  }

  local_path <- file.path("figs", image_name)

  if (!file.exists(local_path)) {
    return(NULL)
  }

  tags$div(
    class = "species-card-icon-wrap",
    tags$img(
      class = "species-card-icon",
      src = file.path("figs", image_name),
      alt = paste(localized_species_label(row, lang), "icon")
    )
  )
}

build_species_image <- function(row, wrapper_class, image_class, alt_label = NULL) {
  species_id <- format_text_value(row$species_id, fallback = "")
  image_name <- species_figure_files[[species_id]] %||% paste0(format_text_value(row$display_name), ".png")
  local_path <- file.path("figs", image_name)

  if (!file.exists(local_path)) {
    fallback_name <- paste0(format_text_value(row$display_name), ".png")
    fallback_path <- file.path("figs", fallback_name)

    if (!file.exists(fallback_path)) {
      return(NULL)
    }

    image_name <- fallback_name
  }

  tags$div(
    class = wrapper_class,
    tags$img(
      class = image_class,
      src = file.path("figs", image_name),
      alt = paste(format_text_value(alt_label %||% row$display_name), "illustration")
    )
  )
}

build_science_figure <- function(science_row, lang = "en") {
  image_name <- format_text_value(science_row$science_image_file, fallback = "")
  local_path <- if (nzchar(image_name)) file.path("figs", image_name) else ""

  if (!nzchar(image_name) || !file.exists(local_path)) {
    return(
      tags$div(
        class = "science-placeholder",
        tags$p(tr(lang, "science_placeholder"))
      )
    )
  }

  tags$div(
    class = "science-figure-wrap",
    tags$img(
      class = "science-figure",
      src = file.path("figs", image_name),
      alt = localized_science_text(science_row, "title", lang)
    )
  )
}

build_species_card <- function(row, lang = "en", active = FALSE, id_prefix = "pick_species") {
  actionButton(
    inputId = paste0(id_prefix, "_", row$species_id),
    label = tags$div(
      class = "species-card-inner",
      build_species_card_icon(row, lang),
      tags$div(
        class = "species-card-copy",
        tags$span(class = "species-card-name", localized_species_label(row, lang)),
        tags$span(class = "species-card-scientific", row$scientific_name),
        tags$p(class = "species-card-summary", localized_species_text(row, "card_summary", lang))
      )
    ),
    class = paste("species-card", if (active) "active" else ""),
    width = "100%"
  )
}

build_hero_species_button <- function(row, lang = "en", active = FALSE) {
  species_id <- format_text_value(row$species_id, fallback = "")
  accent_color <- species_palette[[species_id]] %||% "#B8B8D1"
  image_name <- species_icon_files[[species_id]]
  image_tag <- NULL

  if (!is.null(image_name) && file.exists(file.path("figs", image_name))) {
    image_tag <- tags$img(
      class = "hero-species-icon",
      src = file.path("figs", image_name),
      alt = paste(localized_species_label(row, lang), "icon")
    )
  }

  actionButton(
    inputId = paste0("hero_species_", species_id),
    label = tags$div(
      class = "hero-species-button-copy",
      tags$div(class = "hero-species-icon-wrap", image_tag),
      tags$div(
        class = "hero-species-text",
        tags$span(class = "hero-species-name", localized_species_label(row, lang)),
        tags$span(
          class = "hero-species-scientific",
          title = format_text_value(row$scientific_name),
          build_hero_scientific_name(row$scientific_name)
        )
      )
    ),
    class = paste("hero-species-button", if (active) "active" else ""),
    style = sprintf("--species-accent:%s;", accent_color)
  )
}

build_genome_story_card <- function(story_row, output_id, lang = "en") {
  story_id <- format_text_value(story_row$story_id[[1]], fallback = "")
  plot_widget <- if (identical(story_id, "phylogeny_tree")) {
    div(
      class = "story-static-image",
      imageOutput(outputId = output_id, width = "100%", height = "auto")
    )
  } else {
    plotlyOutput(outputId = output_id, height = "380px")
  }

  tags$section(
    class = "story-card",
    tags$div(
      class = "story-copy",
      tags$p(class = "story-kicker", tr(lang, "interactive_genomics_story")),
      tags$h3(class = "story-title", localized_story_text(story_row, "title", lang)),
      tags$p(class = "story-text", localized_story_text(story_row, "concept", lang)),
      tags$p(
        class = "story-text",
        tags$strong(tr(lang, "educational_hook")),
        paste(" ", localized_story_text(story_row, "educational_hook", lang))
      ),
      tags$p(
        class = "story-highlight",
        tags$strong(tr(lang, "special_highlight")),
        paste(" ", localized_story_text(story_row, "special_highlight", lang))
      )
    ),
    div(
      class = "story-plot-wrap",
      plot_widget
    )
  )
}

build_religion_highlight_chips <- function(species_id, lang = "en") {
  items <- religion_highlights[[lang]][[species_id]]

  if (is.null(items) || length(items) == 0) {
    return(NULL)
  }

  lapply(seq_along(items), function(index) {
    build_chip(names(items)[[index]], unname(items[[index]]))
  })
}

safe_plotly_click <- function(source_id, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    return(NULL)
  }

  registered_ids <- session$userData$plotlyShinyEventIDs %||% character(0)
  event_id <- paste("plotly_click", source_id, sep = "-")

  if (!event_id %in% registered_ids) {
    return(NULL)
  }

  suppressWarnings(
    plotly::event_data(
      "plotly_click",
      source = source_id,
      priority = "event",
      session = session
    )
  )
}

build_image_by_file <- function(image_name, wrapper_class, image_class, alt_text, fallback = NULL) {
  if (is.null(image_name) || !nzchar(trimws(image_name))) {
    return(fallback)
  }

  local_path <- file.path("figs", image_name)

  if (!file.exists(local_path)) {
    return(fallback)
  }

  tags$div(
    class = wrapper_class,
    tags$img(
      class = image_class,
      src = file.path("figs", image_name),
      alt = alt_text
    )
  )
}

build_breed_card <- function(row, lang = "en") {
  accent_color <- species_palette[[format_text_value(row$species_id, fallback = "")]] %||% "#824C71"
  build_panel_image <- build_image_by_file(
    image_name = format_text_value(row$image_file, fallback = ""),
    wrapper_class = "breed-figure-wrap",
    image_class = "breed-figure",
    alt_text = paste(format_text_value(row$breed_name), "illustration"),
    fallback = tags$div(
      class = "science-placeholder breed-placeholder",
      tags$p(tr(lang, "breed_image_placeholder"))
    )
  )

  tags$article(
    class = "breed-card",
    style = sprintf("--card-accent:%s;", accent_color),
    build_panel_image,
    tags$div(
      class = "breed-copy",
      tags$p(class = "story-kicker", format_text_value(row$display_name)),
      tags$h3(class = "story-title", format_text_value(row$breed_name)),
      div(
        class = "chip-grid breed-chip-grid",
        build_chip(
          tr(lang, "purpose_label"),
          translate_choice_value(format_text_value(row$primary_purpose), purpose_translations, lang)
        ),
        build_chip(
          tr(lang, "climate_label"),
          translate_choice_value(format_text_value(row$climate_adaptability), climate_translations, lang)
        ),
        build_chip(
          tr(lang, "origin_label"),
          paste(
            format_text_value(row$origin_region),
            format_text_value(row$origin_country),
            sep = ", "
          )
        )
      ),
      build_section(tr(lang, "breed_story"), tags$p(format_text_value(row$overview))),
      build_section(tr(lang, "historical_usage_label"), tags$p(format_text_value(row$historical_usage))),
      build_section(tr(lang, "genetic_hook_label"), tags$p(format_text_value(row$genetic_fact)))
    )
  )
}

build_anatomy_section_button <- function(row, lang = "en", active = FALSE) {
  actionButton(
    inputId = paste0("anatomy_", row$section_id),
    label = tags$div(
      class = "anatomy-button-copy",
      tags$span(class = "anatomy-button-step", paste(tr(lang, "stage_label"), format_text_value(row$section_order))),
      tags$span(class = "anatomy-button-name", format_text_value(row$section_name)),
      tags$span(class = "anatomy-button-ph", paste("pH", format_text_value(row$ph_range)))
    ),
    class = paste("anatomy-button", if (active) "active" else ""),
    width = "100%"
  )
}

anatomy_system_profile <- function(system_id, lang = "en") {
  if (identical(system_id, "monogastric")) {
    return(list(
      image_name = "Pig monogastric digestive system.png",
      fallback_name = "monogastric digestive tract.webp",
      alt_text = tr(lang, "anatomy_figure_alt_monogastric"),
      summary = tr(lang, "anatomy_monogastric_summary"),
      digestive_plan = tr(lang, "anatomy_monogastric_plan"),
      fermentation_site = tr(lang, "anatomy_monogastric_fermentation"),
      absorption_site = tr(lang, "anatomy_monogastric_absorption"),
      reference_label = "The Pig Site",
      reference_url = "https://www.thepigsite.com/articles/digestive-system-of-the-pig-anatomy-and-function"
    ))
  }

  list(
    image_name = "ruminant digestive system.png",
    fallback_name = "ruminant digestive.jpeg",
    alt_text = tr(lang, "anatomy_figure_alt_ruminant"),
    summary = tr(lang, "anatomy_ruminant_summary"),
    digestive_plan = tr(lang, "anatomy_ruminant_plan"),
    fermentation_site = tr(lang, "anatomy_ruminant_fermentation"),
    absorption_site = tr(lang, "anatomy_ruminant_absorption"),
    reference_label = "GO Seed",
    reference_url = "https://goseed.com/4-parts-of-a-ruminant-digestive-system/"
  )
}

build_module_hero <- function(kicker, title, body, extra_class = NULL) {
  tags$section(
    class = paste("module-hero", extra_class %||% ""),
    tags$p(class = "module-kicker", kicker),
    tags$h2(class = "module-title", title),
    tags$p(class = "module-copy", body)
  )
}

ui <- fluidPage(
  tags$head(
    tags$title("Farm Animals Explorer"),
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  div(
    class = "page-shell",
    div(
      class = "hero-panel",
      div(
        class = "hero-bar",
        div(
          class = "hero-branding",
          uiOutput("hero_header"),
          uiOutput("hero_copy_block")
        ),
        div(
          class = "hero-side-column",
          div(
            class = "language-switch",
            tags$span(class = "language-switch-label", textOutput("language_label")),
            selectInput(
              inputId = "app_language",
              label = NULL,
              choices = c("English" = "en", "Espanol" = "es", "Portugues" = "pt"),
              selected = "en",
              width = "160px"
            )
          ),
          uiOutput("hero_species_selector")
        )
      )
    )
    ,
    uiOutput("main_tabs")
  )
)

server <- function(input, output, session) {
  current_language <- reactive({
    input$app_language %||% "en"
  })

  quizServer("farm_quiz", language = current_language)

  selected_species <- reactiveVal(species_ids[[1]])
  selected_genome_accession <- reactiveVal(NULL)
  selected_domestication_site <- reactiveVal(domestication_data$site_id[[1]])
  selected_anatomy_section <- reactiveVal("rumen")

  card_prefixes <- c("pick_species", "pick_science", "pick_religion", "hero_species")

  lapply(card_prefixes, function(prefix) {
    lapply(species_ids, function(current_id) {
      observeEvent(input[[paste0(prefix, "_", current_id)]], {
        selected_species(current_id)
      }, ignoreInit = TRUE)
    })
  })

  observeEvent(input$genome_focus_accession, {
    selected_genome_accession(input$genome_focus_accession %||% NULL)
  }, ignoreInit = TRUE)

  current_species <- reactive({
    species_data[species_data$species_id == selected_species(), , drop = FALSE]
  })

  current_genome_rows <- reactive({
    df <- genome_data[genome_data$species_id == selected_species(), , drop = FALSE]

    if (nrow(df) == 0) {
      return(df)
    }

    sort_genome_rows(df)
  })

  current_genome_entry <- reactive({
    df <- current_genome_rows()

    if (nrow(df) == 0) {
      return(df)
    }

    selected_accession <- selected_genome_accession() %||% ""
    match_index <- match(selected_accession, df$accession)

    if (is.na(match_index)) {
      return(df[1, , drop = FALSE])
    }

    df[match_index, , drop = FALSE]
  })

  current_science_entry <- reactive({
    df <- science_data[science_data$species_id == selected_species(), , drop = FALSE]

    if (nrow(df) == 0) {
      return(df)
    }

    df[1, , drop = FALSE]
  })

  filtered_genome_data <- reactive({
    df <- genome_data
    selected_species_ids <- input$genome_species %||% species_ids

    if (isTRUE(input$hide_examples)) {
      df <- df[df$data_status != "example", , drop = FALSE]
    }

    if (length(selected_species_ids) == 0) {
      return(df[0, , drop = FALSE])
    }

    df[df$species_id %in% selected_species_ids, , drop = FALSE]
  })

  observe({
    req(identical(input$main_tabset, "genome"))
    req(!is.null(input$genome_species), nrow(filtered_genome_data()) > 0)
    click_data <- safe_plotly_click("genome_metric_source")
    req(!is.null(click_data), !is.null(click_data$customdata))
    target <- decode_genome_target(click_data$customdata[[1]])
    req(!is.null(target))
    selected_species(target$species_id)
    selected_genome_accession(target$accession)
  })

  observe({
    req(identical(input$main_tabset, "genome"))
    req(!is.null(input$genome_species), nrow(filtered_genome_data()) > 0)
    click_data <- safe_plotly_click("genome_landscape_source")
    req(!is.null(click_data), !is.null(click_data$customdata))
    target <- decode_genome_target(click_data$customdata[[1]])
    req(!is.null(target))
    selected_species(target$species_id)
    selected_genome_accession(target$accession)
  })

  filtered_domestication_data <- reactive({
    df <- domestication_data
    selected_species_ids <- input$domestication_species %||% unique(domestication_data$species_id)
    selected_window <- sort(input$domestication_year_window %||% range(domestication_data$years_bp, na.rm = TRUE))

    if (length(selected_species_ids) == 0) {
      return(df[0, , drop = FALSE])
    }

    df <- df[df$species_id %in% selected_species_ids, , drop = FALSE]
    df <- df[df$years_bp >= selected_window[[1]] & df$years_bp <= selected_window[[2]], , drop = FALSE]
    df[order(df$years_bp, decreasing = TRUE), , drop = FALSE]
  })

  observe({
    available_ids <- filtered_domestication_data()$site_id

    if (length(available_ids) == 0) {
      return()
    }

    if (!selected_domestication_site() %in% available_ids) {
      selected_domestication_site(available_ids[[1]])
    }
  })

  observe({
    req(identical(input$main_tabset, "domestication"))
    click_data <- safe_plotly_click("domestication_map")
    req(!is.null(click_data), !is.null(click_data$customdata))
    selected_domestication_site(as.character(click_data$customdata[[1]]))
  })

  observe({
    req(identical(input$main_tabset, "domestication"))
    click_data <- safe_plotly_click("domestication_timeline")
    req(!is.null(click_data), !is.null(click_data$customdata))
    selected_domestication_site(as.character(click_data$customdata[[1]]))
  })

  current_domestication_site <- reactive({
    df <- filtered_domestication_data()

    if (nrow(df) == 0) {
      return(df)
    }

    match_index <- match(selected_domestication_site(), df$site_id)

    if (is.na(match_index)) {
      return(df[1, , drop = FALSE])
    }

    df[match_index, , drop = FALSE]
  })

  filtered_breed_data <- reactive({
    df <- breed_data
    species_filter <- input$breed_species %||% "all"
    purpose_filter <- input$breed_purpose %||% "all"
    climate_filter <- input$breed_climate %||% "all"

    if (!identical(species_filter, "all")) {
      df <- df[df$species_id == species_filter, , drop = FALSE]
    }

    if (!identical(purpose_filter, "all")) {
      df <- df[df$primary_purpose == purpose_filter, , drop = FALSE]
    }

    if (!identical(climate_filter, "all")) {
      df <- df[df$climate_adaptability == climate_filter, , drop = FALSE]
    }

    df
  })

  current_anatomy_sections <- reactive({
    system_id <- input$anatomy_system %||% "ruminant"
    df <- anatomy_data[anatomy_data$system_id == system_id, , drop = FALSE]
    df[order(df$section_order), , drop = FALSE]
  })

  observeEvent(input$anatomy_system, {
    df <- current_anatomy_sections()

    if (nrow(df) > 0) {
      selected_anatomy_section(df$section_id[[1]])
    }
  }, ignoreInit = FALSE)

  lapply(unique(anatomy_data$section_id), function(section_id) {
    observeEvent(input[[paste0("anatomy_", section_id)]], {
      selected_anatomy_section(section_id)
    }, ignoreInit = TRUE)
  })

  current_anatomy_section <- reactive({
    df <- current_anatomy_sections()

    if (nrow(df) == 0) {
      return(df)
    }

    match_index <- match(selected_anatomy_section(), df$section_id)

    if (is.na(match_index)) {
      return(df[1, , drop = FALSE])
    }

    df[match_index, , drop = FALSE]
  })

  simulated_sustainability <- reactive({
    feed_type <- input$sustainability_feed %||% "grazing"
    body_mass <- input$sustainability_body_mass %||% 120
    df <- sustainability_data[sustainability_data$feed_type == feed_type, , drop = FALSE]

    if (nrow(df) == 0) {
      return(df)
    }

    scale_factor <- body_mass / df$reference_body_mass_kg
    df$scenario_meat_kg <- round(df$meat_output_kg * scale_factor, 1)
    df$scenario_milk_l <- round(df$milk_output_l * scale_factor, 1)
    df$scenario_protein_kg <- round(df$edible_protein_kg * scale_factor, 1)
    df$scenario_methane_total_kg <- round(df$methane_kg_per_kg_protein * df$scenario_protein_kg, 1)
    df$scenario_water_total_l <- round(df$water_l_per_kg_protein * df$scenario_protein_kg, 0)
    df
  })

  output$hero_header <- renderUI({
    lang <- current_language()

    tagList(
      tags$p(class = "eyebrow", tr(lang, "eyebrow")),
      tags$h1(tr(lang, "hero_title"))
    )
  })

  output$hero_copy_block <- renderUI({
    lang <- current_language()

    tagList(
      tags$p(class = "hero-copy", tr(lang, "hero_copy")),
      tags$p(class = "hero-note", tr(lang, "hero_note"))
    )
  })

  output$hero_species_selector <- renderUI({
    lang <- current_language()
    buttons <- lapply(seq_len(nrow(species_data)), function(index) {
      row <- species_data[index, , drop = FALSE]
      build_hero_species_button(
        row = row,
        lang = lang,
        active = identical(row$species_id[[1]], selected_species())
      )
    })

    div(
      class = "hero-species-selector",
      tags$span(class = "hero-selector-label", tr(lang, "hero_selector_label")),
      tags$p(class = "hero-selector-note", tr(lang, "hero_selector_note")),
      div(class = "hero-species-grid", buttons)
    )
  })

  output$language_label <- renderText({
    tr(current_language(), "language_label")
  })

  output$main_tabs <- renderUI({
    lang <- current_language()
    species_choices <- stats::setNames(
      species_ids,
      vapply(
        seq_len(nrow(species_data)),
        function(index) localized_species_label(species_data[index, , drop = FALSE], lang),
        character(1)
      )
    )

    tabsetPanel(
      id = "main_tabset",
      selected = isolate(input$main_tabset %||% "species"),
      type = "tabs",
      tabPanel(
        title = tr(lang, "tab_species"),
        value = "species",
        fluidRow(
          column(
            width = 4,
            class = "selection-column",
            tags$h3(class = "panel-title", tr(lang, "choose_species")),
            uiOutput("species_cards")
          ),
          column(
            width = 8,
            class = "detail-column-stack",
            uiOutput("species_detail")
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_genome"),
        value = "genome",
        tagList(
          fluidRow(
            column(
              width = 4,
              div(
                class = "control-panel",
                tags$h3(class = "panel-title", tr(lang, "genome_compare_title")),
                tags$p(tr(lang, "genome_compare_body")),
                checkboxGroupInput(
                  inputId = "genome_species",
                  label = tr(lang, "species_label"),
                  choices = species_choices,
                  selected = input$genome_species %||% species_ids
                ),
                selectInput(
                  inputId = "metric",
                  label = tr(lang, "metric_label"),
                  choices = c(
                    setNames("genome_mb", tr(lang, "genome_size_label")),
                    setNames("gc_percent", tr(lang, "gc_percent_label")),
                    setNames("scaffold_n50_mb", tr(lang, "scaffold_n50_label"))
                  ),
                  selected = input$metric %||% "genome_mb"
                ),
                checkboxInput(
                  inputId = "hide_examples",
                  label = tr(lang, "genome_hide_examples"),
                  value = isTRUE(input$hide_examples)
                ),
                downloadButton(
                  outputId = "download_genome_csv",
                  label = tr(lang, "download_filtered_csv"),
                  class = "btn btn-default genome-download-button"
                ),
                uiOutput("genome_metric_help"),
                div(class = "helper-note", textOutput("genome_note"))
              )
            ),
            column(
              width = 8,
              div(
                class = "plot-panel",
                uiOutput("genome_focus_selector"),
                uiOutput("genome_focus_card"),
                div(
                  class = "genome-visual-grid",
                  div(
                    class = "genome-chart-card",
                    plotlyOutput("genome_plot", height = "430px")
                  ),
                  div(
                    class = "genome-chart-card",
                    plotlyOutput("genome_landscape_plot", height = "300px")
                  )
                ),
                div(
                  class = "genome-table-wrap",
                  uiOutput("genome_table")
                )
              )
            )
          ),
          fluidRow(
            column(
              width = 12,
              div(
                class = "plot-panel genome-stories-panel",
                tags$h3(class = "panel-title", tr(lang, "genome_stories_title")),
                tags$p(class = "story-intro", tr(lang, "genome_stories_intro")),
                uiOutput("genome_story_cards")
              )
            )
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_science"),
        value = "science",
        fluidRow(
          column(
            width = 4,
            class = "selection-column",
            tags$h3(class = "panel-title", tr(lang, "choose_species")),
            uiOutput("science_species_cards")
          ),
          column(
            width = 8,
            class = "detail-column-stack",
            uiOutput("science_detail")
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_religion"),
        value = "religion",
        fluidRow(
          column(
            width = 4,
            class = "selection-column",
            tags$h3(class = "panel-title", tr(lang, "choose_species")),
            uiOutput("religion_species_cards")
          ),
          column(
            width = 8,
            class = "detail-column-stack",
            uiOutput("religion_detail")
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_domestication"),
        value = "domestication",
        tagList(
          build_module_hero(
            kicker = tr(lang, "domestication_kicker"),
            title = tr(lang, "domestication_title"),
            body = tr(lang, "domestication_body"),
            extra_class = "domestication-hero"
          ),
          fluidRow(
            column(
              width = 4,
              div(
                class = "control-panel module-control domestication-control",
                tags$h3(class = "panel-title", tr(lang, "domestication_filter_title")),
                tags$p(tr(lang, "domestication_filter_body")),
                checkboxGroupInput(
                  inputId = "domestication_species",
                  label = tr(lang, "species_label"),
                  choices = species_choices,
                  selected = input$domestication_species %||% unique(domestication_data$species_id)
                ),
                sliderInput(
                  inputId = "domestication_year_window",
                  label = tr(lang, "years_before_present"),
                  min = min(domestication_data$years_bp, na.rm = TRUE),
                  max = max(domestication_data$years_bp, na.rm = TRUE),
                  value = input$domestication_year_window %||% c(
                    min(domestication_data$years_bp, na.rm = TRUE),
                    max(domestication_data$years_bp, na.rm = TRUE)
                  ),
                  step = 250,
                  sep = ""
                ),
                div(class = "helper-note", textOutput("domestication_note")),
                uiOutput("domestication_focus")
              )
            ),
            column(
              width = 8,
              div(
                class = "plot-panel module-panel domestication-panel",
                plotlyOutput("domestication_map", height = "360px"),
                plotlyOutput("domestication_timeline", height = "280px")
              )
            )
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_breeds"),
        value = "breeds",
        tagList(
          build_module_hero(
            kicker = tr(lang, "breed_kicker"),
            title = tr(lang, "breed_title"),
            body = tr(lang, "breed_body"),
            extra_class = "breed-hero"
          ),
          fluidRow(
            column(
              width = 4,
              div(
                class = "control-panel module-control breed-control",
                tags$h3(class = "panel-title", tr(lang, "breed_filter_title")),
                tags$p(tr(lang, "breed_filter_body")),
                selectInput(
                  inputId = "breed_species",
                  label = tr(lang, "species_label"),
                  choices = c(setNames("all", tr(lang, "all_species")), species_choices),
                  selected = input$breed_species %||% "all"
                ),
                selectInput(
                  inputId = "breed_purpose",
                  label = tr(lang, "primary_purpose_label"),
                  choices = c(
                    setNames("all", tr(lang, "any_purpose")),
                    setNames("Dairy", translate_choice_value("Dairy", purpose_translations, lang)),
                    setNames("Meat", translate_choice_value("Meat", purpose_translations, lang)),
                    setNames("Fiber/Wool", translate_choice_value("Fiber/Wool", purpose_translations, lang)),
                    setNames("Draft", translate_choice_value("Draft", purpose_translations, lang)),
                    setNames("Laboratory Model", translate_choice_value("Laboratory Model", purpose_translations, lang))
                  ),
                  selected = input$breed_purpose %||% "all"
                ),
                selectInput(
                  inputId = "breed_climate",
                  label = tr(lang, "climate_adaptability_label"),
                  choices = c(
                    setNames("all", tr(lang, "any_climate")),
                    setNames("Heat tolerant", translate_choice_value("Heat tolerant", climate_translations, lang)),
                    setNames("Cold hardy", translate_choice_value("Cold hardy", climate_translations, lang))
                  ),
                  selected = input$breed_climate %||% "all"
                ),
                div(class = "helper-note", textOutput("breed_note"))
              )
            ),
            column(
              width = 8,
              div(
                class = "plot-panel module-panel breed-panel",
                plotlyOutput("breed_origin_map", height = "320px"),
                uiOutput("breed_cards")
              )
            )
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_anatomy"),
        value = "anatomy",
        tagList(
          build_module_hero(
            kicker = tr(lang, "anatomy_kicker"),
            title = tr(lang, "anatomy_title"),
            body = tr(lang, "anatomy_body"),
            extra_class = "anatomy-hero"
          ),
          fluidRow(
            column(
              width = 4,
              div(
                class = "control-panel module-control anatomy-control",
                tags$h3(class = "panel-title", tr(lang, "anatomy_choose_title")),
                tags$p(tr(lang, "anatomy_choose_body")),
                radioButtons(
                  inputId = "anatomy_system",
                  label = tr(lang, "digestive_design_label"),
                  choices = c(
                    setNames("ruminant", tr(lang, "ruminant_design")),
                    setNames("monogastric", tr(lang, "monogastric_design"))
                  ),
                  selected = input$anatomy_system %||% "ruminant"
                ),
                uiOutput("anatomy_system_intro")
              )
            ),
            column(
              width = 8,
              div(
                class = "plot-panel module-panel anatomy-panel",
                div(
                  class = "learning-panel anatomy-comparison-card",
                  tags$p(class = "module-kicker anatomy-visual-kicker", tr(lang, "anatomy_comparison_title")),
                  tags$h3(class = "anatomy-comparison-heading", tr(lang, "anatomy_comparison_title")),
                  tags$p(class = "anatomy-comparison-copy", tr(lang, "anatomy_comparison_body")),
                  uiOutput("anatomy_comparison_figure")
                ),
                div(
                  class = "learning-panel anatomy-overview-card",
                  uiOutput("anatomy_overview_figure")
                ),
                uiOutput("anatomy_section_buttons"),
                uiOutput("anatomy_detail")
              )
            )
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_sustainability"),
        value = "sustainability",
        tagList(
          build_module_hero(
            kicker = tr(lang, "sustainability_kicker"),
            title = tr(lang, "sustainability_title"),
            body = tr(lang, "sustainability_body"),
            extra_class = "sustainability-hero"
          ),
          fluidRow(
            column(
              width = 4,
              div(
                class = "control-panel module-control sustainability-control",
                tags$h3(class = "panel-title", tr(lang, "sustainability_set_title")),
                tags$p(tr(lang, "sustainability_set_body")),
                radioButtons(
                  inputId = "sustainability_feed",
                  label = tr(lang, "feed_type_label"),
                  choices = c(
                    setNames("grazing", translate_choice_value("grazing", feed_translations, lang)),
                    setNames("grain", translate_choice_value("grain", feed_translations, lang))
                  ),
                  selected = input$sustainability_feed %||% "grazing"
                ),
                sliderInput(
                  inputId = "sustainability_body_mass",
                  label = tr(lang, "reference_body_mass_label"),
                  min = 40,
                  max = 600,
                  value = input$sustainability_body_mass %||% 120,
                  step = 10
                ),
                uiOutput("sustainability_note")
              )
            ),
            column(
              width = 8,
              div(
                class = "plot-panel module-panel sustainability-panel",
                plotlyOutput("sustainability_production_plot", height = "280px"),
                plotlyOutput("sustainability_footprint_plot", height = "320px"),
                uiOutput("sustainability_cards")
              )
            )
          )
        )
      ),
      tabPanel(
        title = tr(lang, "tab_quiz"),
        value = "quiz",
        tagList(
          build_module_hero(
            kicker = tr(lang, "quiz_kicker"),
            title = tr(lang, "quiz_title"),
            body = tr(lang, "quiz_body"),
            extra_class = "quiz-hero"
          ),
          fluidRow(
            column(
              width = 10,
              offset = 1,
              div(
                class = "plot-panel module-panel quiz-panel",
                quizUI("farm_quiz")
              )
            )
          )
        )
      )
    )
  })

  output$species_cards <- renderUI({
    lang <- current_language()
    cards <- lapply(seq_len(nrow(species_data)), function(index) {
      row <- species_data[index, , drop = FALSE]
      build_species_card(
        row = row,
        lang = lang,
        active = identical(row$species_id[[1]], selected_species()),
        id_prefix = "pick_species"
      )
    })

    div(class = "card-stack", cards)
  })

  output$science_species_cards <- renderUI({
    lang <- current_language()
    cards <- lapply(seq_len(nrow(species_data)), function(index) {
      row <- species_data[index, , drop = FALSE]
      build_species_card(
        row = row,
        lang = lang,
        active = identical(row$species_id[[1]], selected_species()),
        id_prefix = "pick_science"
      )
    })

    div(class = "card-stack", cards)
  })

  output$religion_species_cards <- renderUI({
    lang <- current_language()
    cards <- lapply(seq_len(nrow(species_data)), function(index) {
      row <- species_data[index, , drop = FALSE]
      build_species_card(
        row = row,
        lang = lang,
        active = identical(row$species_id[[1]], selected_species()),
        id_prefix = "pick_religion"
      )
    })

    div(class = "card-stack", cards)
  })

  output$domestication_note <- renderText({
    lang <- current_language()
    df <- filtered_domestication_data()

    if (nrow(df) == 0) {
      return(tr(lang, "domestication_note_empty"))
    }

    sprintf(
      tr(lang, "domestication_note_showing"),
      nrow(df),
      format(min(df$years_bp), big.mark = ",", scientific = FALSE),
      format(max(df$years_bp), big.mark = ",", scientific = FALSE)
    )
  })

  output$domestication_focus <- renderUI({
    lang <- current_language()
    df <- current_domestication_site()

    if (nrow(df) == 0) {
      return(
        div(
          class = "focus-panel",
          tags$h3(tr(lang, "domestication_focus_title")),
          tags$p(tr(lang, "domestication_focus_empty"))
        )
      )
    }

    row <- df[1, , drop = FALSE]
    display_name <- localized_species_name_by_id(row$species_id[[1]], lang)

    div(
      class = "focus-panel domestication-focus-card",
      tags$h3(tr(lang, "domestication_focus_title")),
      tags$p(
        class = "focus-intro",
        sprintf(
          tr(lang, "domestication_focus_intro"),
          display_name,
          format_text_value(row$site_name),
          format_text_value(row$region_label)
        )
      ),
      div(
        class = "chip-grid genome-chip-grid",
        build_chip(tr(lang, "wild_ancestor_label"), format_text_value(row$wild_ancestor)),
        build_chip(tr(lang, "date_label"), format_text_value(row$years_label)),
        build_chip(tr(lang, "region_label"), format_text_value(row$region_label))
      ),
      build_section(tr(lang, "domestication_story"), tags$p(format_text_value(row$domestication_story))),
      build_section(tr(lang, "archaeology_hook"), tags$p(format_text_value(row$artifact_note))),
      build_section(tr(lang, "genome_fact"), tags$p(format_text_value(row$genome_fact)))
    )
  })

  output$domestication_map <- plotly::renderPlotly({
    lang <- current_language()
    df <- filtered_domestication_data()

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "no_domestication_sites"), source_id = "domestication_map"))
    }

    selected_id <- selected_domestication_site()
    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$marker_size <- ifelse(df$site_id == selected_id, 20, 13)
    df$hover_text <- paste0(
      "<b>", df$site_name, "</b><br>",
      df$display_label, "<br>",
      df$years_label, "<br>",
      tr(lang, "wild_ancestor_label"), ": ", df$wild_ancestor
    )

    p <- plotly::plot_ly(
      data = df,
      type = "scattergeo",
      mode = "markers",
      lon = ~lng,
      lat = ~lat,
      text = ~hover_text,
      hovertemplate = "%{text}<extra></extra>",
      customdata = ~site_id,
      source = "domestication_map",
      marker = list(
        size = df$marker_size,
        color = unname(species_palette[df$species_id]),
        opacity = 0.9,
        line = list(color = "white", width = 1.5)
      )
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "domestication_map_title")),
        margin = list(l = 10, r = 10, b = 10, t = 45),
        geo = list(
          scope = "world",
          projection = list(type = "natural earth"),
          showland = TRUE,
          landcolor = "#F7F1F4",
          showcountries = TRUE,
          countrycolor = "#DABFC8",
          coastlinecolor = "#DABFC8"
        ),
        showlegend = FALSE
      ) %>%
      plotly::config(displaylogo = FALSE, responsive = TRUE)

    p <- plotly::event_register(p, "plotly_click")
    p
  })

  output$domestication_timeline <- plotly::renderPlotly({
    lang <- current_language()
    df <- filtered_domestication_data()

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "no_domestication_sites"), source_id = "domestication_timeline"))
    }

    selected_id <- selected_domestication_site()
    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$marker_size <- ifelse(df$site_id == selected_id, 19, 12)
    df$hover_text <- paste0(
      "<b>", df$display_label, "</b><br>",
      df$site_name, "<br>",
      df$years_label
    )

    p <- plotly::plot_ly(
      data = df,
      x = ~years_bp,
      y = ~display_label,
      type = "scatter",
      mode = "markers",
      text = ~hover_text,
      hovertemplate = "%{text}<extra></extra>",
      customdata = ~site_id,
      source = "domestication_timeline",
      marker = list(
        size = df$marker_size,
        color = unname(species_palette[df$species_id]),
        opacity = 0.9,
        line = list(color = "white", width = 1.5)
      )
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "domestication_timeline_title")),
        margin = list(l = 80, r = 10, b = 50, t = 45),
        xaxis = list(title = plotly_axis_title_spec(tr(lang, "years_before_present")), autorange = "reversed"),
        yaxis = list(title = plotly_axis_title_spec(""), automargin = TRUE),
        showlegend = FALSE
      ) %>%
      plotly::config(displaylogo = FALSE, responsive = TRUE)

    p <- plotly::event_register(p, "plotly_click")
    p
  })

  output$breed_note <- renderText({
    lang <- current_language()
    df <- filtered_breed_data()

    if (nrow(df) == 0) {
      return(tr(lang, "breed_note_empty"))
    }

    sprintf(tr(lang, "breed_note_showing"), nrow(df), length(unique(df$species_id)))
  })

  output$breed_origin_map <- plotly::renderPlotly({
    lang <- current_language()
    df <- filtered_breed_data()

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "no_breed_origins")))
    }

    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$hover_text <- paste0(
      "<b>", df$breed_name, "</b><br>",
      df$display_label, "<br>",
      df$origin_region, ", ", df$origin_country, "<br>",
      tr(lang, "purpose_label"), ": ",
      translate_choice_value(df$primary_purpose, purpose_translations, lang)
    )

    plotly::plot_ly(
      data = df,
      type = "scattergeo",
      mode = "markers",
      lon = ~origin_lng,
      lat = ~origin_lat,
      text = ~hover_text,
      hovertemplate = "%{text}<extra></extra>",
      marker = list(
        size = 14,
        color = unname(species_palette[df$species_id]),
        opacity = 0.9,
        line = list(color = "white", width = 1.5)
      )
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "breed_map_title")),
        margin = list(l = 10, r = 10, b = 10, t = 45),
        geo = list(
          scope = "world",
          projection = list(type = "natural earth"),
          showland = TRUE,
          landcolor = "#F7F1F4",
          showcountries = TRUE,
          countrycolor = "#DABFC8",
          coastlinecolor = "#DABFC8"
        ),
        showlegend = FALSE
      ) %>%
      plotly::config(displaylogo = FALSE, responsive = TRUE)
  })

  output$breed_cards <- renderUI({
    df <- filtered_breed_data()
    lang <- current_language()

    if (nrow(df) == 0) {
      return(
        div(
          class = "focus-panel",
          tags$h3(tr(lang, "no_matching_breeds")),
          tags$p(tr(lang, "broaden_filters"))
        )
      )
    }

    cards <- lapply(seq_len(nrow(df)), function(index) {
      row <- df[index, , drop = FALSE]
      species_row <- species_data[species_data$species_id == row$species_id[[1]], , drop = FALSE]
      row$display_name <- localized_species_label(species_row, lang)
      build_breed_card(row, lang)
    })

    div(class = "breed-grid", cards)
  })

  output$anatomy_system_intro <- renderUI({
    lang <- current_language()
    system_id <- input$anatomy_system %||% "ruminant"

    if (identical(system_id, "ruminant")) {
      return(
        div(
          class = "learning-panel anatomy-intro-card",
          tags$h4(tr(lang, "ruminant_intro_title")),
          tags$p(tr(lang, "ruminant_intro_body"))
        )
      )
    }

    div(
      class = "learning-panel anatomy-intro-card",
      tags$h4(tr(lang, "monogastric_intro_title")),
      tags$p(tr(lang, "monogastric_intro_body"))
    )
  })

  output$anatomy_comparison_figure <- renderUI({
    build_image_by_file(
      image_name = "ruminants vs pigs digestive anatomy.png",
      wrapper_class = "anatomy-figure-wrap anatomy-comparison-figure-wrap",
      image_class = "anatomy-figure anatomy-comparison-figure",
      alt_text = tr(current_language(), "anatomy_figure_alt")
    )
  })

  output$anatomy_overview_figure <- renderUI({
    lang <- current_language()
    system_id <- input$anatomy_system %||% "ruminant"
    profile <- anatomy_system_profile(system_id, lang)
    system_title <- if (identical(system_id, "ruminant")) {
      tr(lang, "ruminant_design")
    } else {
      tr(lang, "monogastric_design")
    }

    div(
      class = "anatomy-visual-layout",
      div(
        class = "anatomy-visual-media",
        build_image_by_file(
          image_name = profile$image_name,
          wrapper_class = "anatomy-figure-wrap anatomy-system-figure-wrap",
          image_class = "anatomy-figure anatomy-system-figure",
          alt_text = profile$alt_text,
          fallback = build_image_by_file(
            image_name = profile$fallback_name,
            wrapper_class = "anatomy-figure-wrap anatomy-system-figure-wrap",
            image_class = "anatomy-figure anatomy-system-figure",
            alt_text = profile$alt_text
          )
        )
      ),
      div(
        class = "anatomy-overview-note",
        tags$p(class = "module-kicker anatomy-visual-kicker", tr(lang, "anatomy_visual_title")),
        tags$h3(class = "anatomy-visual-heading", system_title),
        tags$p(class = "anatomy-visual-summary", profile$summary),
        div(
          class = "chip-grid anatomy-chip-grid",
          build_chip(tr(lang, "anatomy_chambers_label"), profile$digestive_plan),
          build_chip(tr(lang, "anatomy_fermentation_label"), profile$fermentation_site),
          build_chip(tr(lang, "anatomy_absorption_label"), profile$absorption_site)
        ),
        div(
          class = "anatomy-reference-card",
          tags$p(class = "learning-prompt", tr(lang, "anatomy_reference_note")),
          tags$p(
            class = "anatomy-reference-link",
            tags$strong(paste0(tr(lang, "anatomy_reference_links"), ": ")),
            tags$a(
              href = profile$reference_url,
              target = "_blank",
              rel = "noopener noreferrer",
              profile$reference_label
            )
          )
        )
      )
    )
  })

  output$anatomy_section_buttons <- renderUI({
    lang <- current_language()
    df <- current_anatomy_sections()

    buttons <- lapply(seq_len(nrow(df)), function(index) {
      row <- df[index, , drop = FALSE]
      build_anatomy_section_button(
        row = row,
        lang = lang,
        active = identical(row$section_id[[1]], selected_anatomy_section())
      )
    })

    div(class = "anatomy-button-row", buttons)
  })

  output$anatomy_detail <- renderUI({
    lang <- current_language()
    row <- current_anatomy_section()

    if (nrow(row) == 0) {
      return(
        div(
          class = "focus-panel",
          tags$h3(tr(lang, "digestive_section_details")),
          tags$p(tr(lang, "choose_digestive_system"))
        )
      )
    }

    species_labels <- vapply(
      split_pipe(row$species_examples[[1]]),
      function(species_id) {
        species_row <- species_data[species_data$species_id == species_id, , drop = FALSE]
        localized_species_label(species_row, lang)
      },
      character(1)
    )

    div(
      class = "focus-panel anatomy-detail-panel",
      tags$h3(format_text_value(row$section_name)),
      tags$p(class = "focus-intro", format_text_value(row$teaching_note)),
      div(
        class = "chip-grid genome-chip-grid",
        build_chip(tr(lang, "ph_range_label"), format_text_value(row$ph_range)),
        build_chip(tr(lang, "seen_in_label"), paste(species_labels, collapse = ", "))
      ),
      build_section(tr(lang, "function_label"), tags$p(format_text_value(row[["function"]]))),
      build_section(tr(lang, "microbe_focus_label"), tags$p(format_text_value(row$microbe_focus))),
      build_section(tr(lang, "feed_flow_label"), tags$p(format_text_value(row$feed_flow)))
    )
  })

  output$sustainability_note <- renderUI({
    lang <- current_language()
    feed_type <- input$sustainability_feed %||% "grazing"
    body_mass <- input$sustainability_body_mass %||% 120
    note_text <- if (identical(feed_type, "grazing")) {
      tr(lang, "simulator_note_grass")
    } else {
      tr(lang, "simulator_note_grain")
    }

    div(
      class = "learning-panel",
      tags$h4(tr(lang, "simulator_how_to_read")),
      tags$p(sprintf(tr(lang, "simulator_scale_text"), body_mass)),
      tags$p(class = "learning-prompt", note_text)
    )
  })

  output$sustainability_production_plot <- plotly::renderPlotly({
    lang <- current_language()
    df <- simulated_sustainability()

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "no_sustainability_profiles")))
    }

    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    production_df <- rbind(
      data.frame(
        display_name = df$display_label,
        metric = tr(lang, "meat_output_label"),
        value = df$scenario_meat_kg,
        stringsAsFactors = FALSE
      ),
      data.frame(
        display_name = df$display_label,
        metric = tr(lang, "milk_output_label"),
        value = df$scenario_milk_l,
        stringsAsFactors = FALSE
      )
    )

    plotly::plot_ly(
      data = production_df,
      x = ~display_name,
      y = ~value,
      color = ~metric,
      colors = stats::setNames(
        c("#824C71", "#B8B8D1"),
        c(tr(lang, "meat_output_label"), tr(lang, "milk_output_label"))
      ),
      type = "bar",
      text = ~paste0(metric, ": ", value),
      hovertemplate = "%{x}<br>%{text}<extra></extra>"
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "sustainability_output_title")),
        barmode = "group",
        margin = list(l = 60, r = 10, b = 45, t = 45),
        xaxis = list(title = plotly_axis_title_spec("")),
        yaxis = list(title = plotly_axis_title_spec(tr(lang, "output_label")))
      ) %>%
      plotly::config(displaylogo = FALSE, responsive = TRUE)
  })

  output$sustainability_footprint_plot <- plotly::renderPlotly({
    lang <- current_language()
    df <- simulated_sustainability()

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "no_sustainability_profiles")))
    }

    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$hover_text <- paste0(
      "<b>", df$display_label, "</b><br>",
      tr(lang, "water_per_kg_protein"), ": ", df$water_l_per_kg_protein, " L<br>",
      tr(lang, "methane_per_kg_protein"), ": ", df$methane_kg_per_kg_protein, " kg CH4<br>",
      tr(lang, "scenario_methane_total"), ": ", df$scenario_methane_total_kg, " kg<br>",
      tr(lang, "scenario_water_total"), ": ", df$scenario_water_total_l, " L"
    )

    plotly::plot_ly(
      data = df,
      x = ~water_l_per_kg_protein,
      y = ~methane_kg_per_kg_protein,
      type = "scatter",
      mode = "markers+text",
      text = ~display_label,
      textposition = "top center",
      hovertext = ~hover_text,
      hovertemplate = "%{hovertext}<extra></extra>",
      marker = list(
        size = pmax(16, df$scenario_protein_kg * 2.2),
        color = unname(species_palette[df$species_id]),
        opacity = 0.85,
        line = list(color = "white", width = 1.5)
      )
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "sustainability_footprint_title")),
        margin = list(l = 70, r = 20, b = 55, t = 45),
        xaxis = list(title = plotly_axis_title_spec(tr(lang, "water_use_label"))),
        yaxis = list(title = plotly_axis_title_spec(tr(lang, "methane_label")))
      ) %>%
      plotly::config(displaylogo = FALSE, responsive = TRUE)
  })

  output$sustainability_cards <- renderUI({
    lang <- current_language()
    df <- simulated_sustainability()

    cards <- lapply(seq_len(nrow(df)), function(index) {
      row <- df[index, , drop = FALSE]
      accent_color <- species_palette[[row$species_id[[1]]]] %||% "#824C71"
      display_name <- localized_species_name_by_id(row$species_id[[1]], lang)

      tags$article(
        class = "sim-card",
        style = sprintf("--card-accent:%s;", accent_color),
        tags$h3(class = "story-title", display_name),
        div(
          class = "chip-grid breed-chip-grid",
          build_chip(tr(lang, "meat_output_short"), paste(format_text_value(row$scenario_meat_kg), "kg")),
          build_chip(tr(lang, "milk_output_short"), paste(format_text_value(row$scenario_milk_l), "L")),
          build_chip(tr(lang, "protein_label"), paste(format_text_value(row$scenario_protein_kg), "kg")),
          build_chip(tr(lang, "methane_total_label"), paste(format_text_value(row$scenario_methane_total_kg), "kg CH4")),
          build_chip(tr(lang, "water_total_label"), paste(format_text_value(row$scenario_water_total_l), "L"))
        ),
        tags$p(class = "story-text", format_text_value(row$environment_note))
      )
    })

    div(class = "sim-grid", cards)
  })

  output$genome_story_cards <- renderUI({
    lang <- current_language()
    cards <- lapply(seq_len(nrow(genome_story_data)), function(index) {
      story_row <- genome_story_data[index, , drop = FALSE]
      story_id <- format_text_value(story_row$story_id, fallback = "")
      output_id <- genome_story_output_ids[[story_id]]

      if (is.null(output_id)) {
        return(NULL)
      }

      build_genome_story_card(story_row, output_id, lang)
    })

    div(class = "story-grid", cards)
  })

  output$species_detail <- renderUI({
    lang <- current_language()
    row <- current_species()
    genome_row <- current_genome_entry()

    genome_section <- NULL

    if (nrow(genome_row) > 0) {
      genome_note_text <- format_text_value(genome_row$data_note, fallback = "")
      genome_metadata_values <- c(
        format_text_value(genome_row$assembly_name),
        format_text_value(genome_row$breed, fallback = tr(lang, "not_available")),
        format_text_value(genome_row$accession),
        format_text_value(genome_row$source_db),
        format_text_value(genome_row$assembly_level),
        format_numeric_value(genome_row$genome_mb),
        format_numeric_value(genome_row$gc_percent, digits = 0),
        format_numeric_value(genome_row$scaffold_n50_mb)
      )
      genome_metadata <- stats::setNames(
        genome_metadata_values,
        c(
          tr(lang, "assembly_name_label"),
          tr(lang, "breed_label"),
          tr(lang, "accession_label"),
          tr(lang, "source_database_label"),
          tr(lang, "assembly_level_label"),
          tr(lang, "genome_size_label"),
          tr(lang, "gc_percent_label"),
          tr(lang, "scaffold_n50_label")
        )
      )

      genome_section <- build_section(
        tr(lang, "genome_snapshot"),
        div(
          class = "chip-grid genome-chip-grid",
          build_chip(tr(lang, "assembly_label"), format_text_value(genome_row$assembly_name)),
          build_chip(tr(lang, "breed_label"), format_text_value(genome_row$breed, fallback = tr(lang, "not_available"))),
          build_chip(tr(lang, "accession_label"), format_text_value(genome_row$accession)),
          build_chip(tr(lang, "gc_percent_label"), format_numeric_value(genome_row$gc_percent, digits = 0))
        ),
        tags$table(
          class = "taxonomy-table genome-table",
          tags$tbody(build_metadata_rows(genome_metadata))
        ),
        if (nzchar(genome_note_text)) {
          div(
            class = "detail-subnote",
            tags$p(tags$strong(tr(lang, "data_note_label")), paste(" ", genome_note_text))
          )
        }
      )
    }

    div(
      class = "detail-panel",
      div(class = "detail-band", style = sprintf("background:%s;", row$color_hex)),
      div(
        class = "detail-body",
        tags$p(class = "detail-kicker", localized_species_text(row, "digestive_type", lang)),
        tags$h2(localized_species_label(row, lang)),
        tags$p(class = "scientific-name", row$scientific_name),
        build_species_image(
          row,
          "detail-figure-wrap",
          "detail-figure",
          alt_label = localized_species_label(row, lang)
        ),
        div(
          class = "chip-grid",
          build_chip(tr(lang, "common_names_en"), collapse_pipe(row$common_name_en)),
          build_chip(tr(lang, "common_names_es"), collapse_pipe(row$common_name_es))
        ),
        build_section(
          tr(lang, "taxonomy"),
          tags$table(
            class = "taxonomy-table",
            tags$tbody(build_taxonomy_rows(row, lang))
          )
        ),
        genome_section,
        build_section(tr(lang, "basic_biology"), tags$p(localized_species_text(row, "basic_biology", lang))),
        build_section(tr(lang, "religion_culture"), tags$p(localized_species_text(row, "religion_notes", lang))),
        build_section(tr(lang, "teaching_angle"), tags$p(localized_species_text(row, "teaching_focus", lang)))
      )
    )
  })

  output$genome_note <- renderText({
    lang <- current_language()
    df <- filtered_genome_data()

    if (nrow(df) == 0) {
      return(tr(lang, "genome_note_no_rows"))
    }

    if (all(df$data_status == "example")) {
      return(tr(lang, "genome_note_examples"))
    }

    sprintf(tr(lang, "genome_note_showing"), nrow(df), length(unique(df$species_id)))
  })

  output$download_genome_csv <- downloadHandler(
    filename = function() {
      paste0("filtered_genome_summary_", Sys.Date(), ".csv")
    },
    content = function(file) {
      df <- filtered_genome_data()

      if (nrow(df) > 0) {
        df <- df[order(df$species_id, df$assembly_name, df$accession), , drop = FALSE]
      }

      utils::write.csv(df, file, row.names = FALSE)
    }
  )

  output$genome_focus_selector <- renderUI({
    lang <- current_language()
    df <- current_genome_rows()

    if (nrow(df) == 0) {
      return(NULL)
    }

    selected_accession <- selected_genome_accession() %||% df$accession[[1]]

    if (!selected_accession %in% df$accession) {
      selected_accession <- df$accession[[1]]
    }

    choice_labels <- vapply(
      seq_len(nrow(df)),
      function(index) build_genome_choice_label(df[index, , drop = FALSE]),
      character(1)
    )
    display_name <- localized_species_name_by_id(df$species_id[[1]], lang)

    div(
      class = "learning-panel genome-focus-selector-panel",
      tags$h4(tr(lang, "genome_focus_selector_title")),
      tags$p(tr(lang, "genome_focus_selector_note")),
      selectInput(
        inputId = "genome_focus_accession",
        label = tr(lang, "genome_focus_selector_label"),
        choices = stats::setNames(df$accession, choice_labels),
        selected = selected_accession,
        width = "100%"
      ),
      tags$p(
        class = "learning-prompt",
        sprintf(tr(lang, "genome_focus_available"), nrow(df), display_name)
      )
    )
  })

  output$genome_metric_help <- renderUI({
    lang <- current_language()
    metric <- input$metric %||% "genome_mb"
    help_text <- metric_help_for(metric, lang)

    div(
      class = "learning-panel",
      tags$h4(help_text$title),
      tags$p(help_text$explanation),
      tags$p(
        class = "learning-prompt",
        tags$strong(tr(lang, "teaching_prompt_label")),
        paste(" ", help_text$teaching_prompt)
      )
    )
  })

  output$genome_focus_card <- renderUI({
    lang <- current_language()
    genome_row <- current_genome_entry()
    filtered_df <- filtered_genome_data()

    if (nrow(genome_row) == 0) {
      return(
        div(
          class = "focus-panel",
          tags$h3(tr(lang, "genome_focus_title")),
          tags$p(tr(lang, "genome_focus_empty"))
        )
      )
    }

    focus_row <- genome_row[1, , drop = FALSE]
    display_name <- localized_species_name_by_id(focus_row$species_id[[1]], lang)
    in_current_filter <- focus_row$accession[[1]] %in% filtered_df$accession
    size_mean <- mean(filtered_df$genome_mb, na.rm = TRUE)
    n50_mean <- mean(filtered_df$scaffold_n50_mb, na.rm = TRUE)

    size_note <- tr(lang, "genome_focus_filter_note")
    n50_note <- tr(lang, "genome_focus_filter_note")

    if (isTRUE(in_current_filter) && nrow(filtered_df) > 1 && !is.na(size_mean)) {
      size_diff <- round(focus_row$genome_mb[[1]] - size_mean, 2)
      n50_diff <- round(focus_row$scaffold_n50_mb[[1]] - n50_mean, 2)
      size_note <- if (abs(size_diff) < 0.01) {
        tr(lang, "genome_size_same")
      } else if (size_diff > 0) {
        sprintf(tr(lang, "genome_size_above"), abs(size_diff))
      } else {
        sprintf(tr(lang, "genome_size_below"), abs(size_diff))
      }
      n50_note <- if (abs(n50_diff) < 0.01) {
        tr(lang, "genome_n50_same")
      } else if (n50_diff > 0) {
        sprintf(tr(lang, "genome_n50_above"), abs(n50_diff))
      } else {
        sprintf(tr(lang, "genome_n50_below"), abs(n50_diff))
      }
    }

    div(
      class = "focus-panel",
      tags$h3(tr(lang, "genome_focus_title")),
      tags$p(
        class = "focus-intro",
        if (!is.na(focus_row$breed[[1]]) && nzchar(focus_row$breed[[1]])) {
          sprintf(
            tr(lang, "genome_focus_intro_with_breed"),
            display_name,
            focus_row$assembly_name[[1]],
            focus_row$breed[[1]]
          )
        } else {
          sprintf(
            tr(lang, "genome_focus_intro_without_breed"),
            display_name,
            focus_row$assembly_name[[1]]
          )
        }
      ),
      div(
        class = "chip-grid genome-chip-grid",
        build_chip(tr(lang, "breed_label"), format_text_value(focus_row$breed, fallback = tr(lang, "not_available"))),
        build_chip(tr(lang, "source_database_label"), format_text_value(focus_row$source_db)),
        build_chip(tr(lang, "assembly_level_label"), format_text_value(focus_row$assembly_level)),
        build_chip(tr(lang, "genome_size_label"), format_numeric_value(focus_row$genome_mb)),
        build_chip(tr(lang, "gc_percent_label"), format_numeric_value(focus_row$gc_percent, digits = 0)),
        build_chip(tr(lang, "scaffold_n50_label"), format_numeric_value(focus_row$scaffold_n50_mb))
      ),
      tags$p(class = "focus-note", size_note),
      tags$p(class = "focus-note", n50_note)
    )
  })

  output$genome_plot <- plotly::renderPlotly({
    lang <- current_language()
    df <- filtered_genome_data()
    metric <- input$metric %||% "genome_mb"
    metric_labels <- metric_labels_for(lang)

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "genome_note_no_rows"), source_id = "genome_metric_source"))
    }

    df <- df[!is.na(df[[metric]]), , drop = FALSE]

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "genome_note_no_rows"), source_id = "genome_metric_source"))
    }

    df <- df[order(df[[metric]], decreasing = TRUE), , drop = FALSE]
    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$metric_value <- as.numeric(df[[metric]])
    df$y_key <- df$accession
    assembly_text <- vapply(df$assembly_name, format_text_value, character(1), fallback = tr(lang, "not_available"))
    source_text <- vapply(df$source_db, format_text_value, character(1), fallback = tr(lang, "not_available"))
    df$tick_label <- paste(
      df$display_label,
      assembly_text,
      source_text,
      sep = " | "
    )
    df$target_key <- mapply(encode_genome_target, df$species_id, df$accession, USE.NAMES = FALSE)
    metric_digits <- if (identical(metric, "gc_percent")) 1 else 2
    metric_text <- vapply(df$metric_value, format_numeric_value, character(1), digits = metric_digits)
    accession_text <- vapply(df$accession, format_text_value, character(1), fallback = tr(lang, "not_available"))
    breed_text <- vapply(df$breed, format_text_value, character(1), fallback = tr(lang, "not_available"))
    level_text <- vapply(df$assembly_level, format_text_value, character(1), fallback = tr(lang, "not_available"))
    df$hover_text <- paste0(
      "<b>", df$display_label, "</b><br>",
      tr(lang, "assembly_name_label"), ": ", assembly_text, "<br>",
      tr(lang, "breed_label"), ": ", breed_text, "<br>",
      tr(lang, "accession_label"), ": ", accession_text, "<br>",
      tr(lang, "source_database_label"), ": ", source_text, "<br>",
      tr(lang, "assembly_level_label"), ": ", level_text, "<br>",
      metric_labels[[metric]], ": ", metric_text
    )

    palette_map <- stats::setNames(
      unname(species_palette[species_ids]),
      vapply(species_ids, localized_species_name_by_id, character(1), lang = lang)
    )

    p <- plotly::plot_ly(
      data = df,
      x = ~metric_value,
      y = ~y_key,
      type = "scatter",
      mode = "markers",
      color = ~display_label,
      colors = palette_map,
      symbol = ~source_db,
      symbols = c("GenBank" = "circle", "RefSeq" = "diamond"),
      customdata = ~target_key,
      hovertext = ~hover_text,
      hovertemplate = "%{hovertext}<extra></extra>",
      marker = list(size = 11, line = list(color = "white", width = 1.2)),
      showlegend = FALSE,
      source = "genome_metric_source"
    ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "genome_plot_title")),
        margin = list(l = 170, r = 16, b = 55, t = 46),
        xaxis = list(
          title = plotly_axis_title_spec(metric_labels[[metric]]),
          zeroline = FALSE
        ),
        yaxis = list(
          title = plotly_axis_title_spec(""),
          automargin = TRUE,
          categoryorder = "array",
          categoryarray = rev(df$y_key),
          tickvals = df$y_key,
          ticktext = df$tick_label
        )
      ) %>%
      plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)

    p <- plotly::event_register(p, "plotly_click")
    p
  })

  output$genome_landscape_plot <- plotly::renderPlotly({
    lang <- current_language()
    df <- filtered_genome_data()

    df <- df[!is.na(df$genome_mb) & !is.na(df$scaffold_n50_mb), , drop = FALSE]

    if (nrow(df) == 0) {
      return(build_empty_plotly_message(tr(lang, "genome_note_no_rows"), source_id = "genome_landscape_source"))
    }

    df$display_label <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)
    df$target_key <- mapply(encode_genome_target, df$species_id, df$accession, USE.NAMES = FALSE)
    size_map <- c(
      "Complete Genome" = 24,
      "Chromosome" = 20,
      "Scaffold" = 16,
      "Contig" = 13
    )
    df$marker_size <- unname(size_map[df$assembly_level])
    df$marker_size[is.na(df$marker_size)] <- 18
    assembly_text <- vapply(df$assembly_name, format_text_value, character(1), fallback = tr(lang, "not_available"))
    accession_text <- vapply(df$accession, format_text_value, character(1), fallback = tr(lang, "not_available"))
    breed_text <- vapply(df$breed, format_text_value, character(1), fallback = tr(lang, "not_available"))
    source_text <- vapply(df$source_db, format_text_value, character(1), fallback = tr(lang, "not_available"))
    level_text <- vapply(df$assembly_level, format_text_value, character(1), fallback = tr(lang, "not_available"))
    df$hover_text <- paste0(
      "<b>", df$display_label, "</b><br>",
      tr(lang, "assembly_name_label"), ": ", assembly_text, "<br>",
      tr(lang, "breed_label"), ": ", breed_text, "<br>",
      tr(lang, "accession_label"), ": ", accession_text, "<br>",
      tr(lang, "source_database_label"), ": ", source_text, "<br>",
      tr(lang, "assembly_level_label"), ": ", level_text, "<br>",
      tr(lang, "genome_size_label"), ": ", vapply(df$genome_mb, format_numeric_value, character(1)), "<br>",
      tr(lang, "scaffold_n50_label"), ": ", vapply(df$scaffold_n50_mb, format_numeric_value, character(1))
    )

    palette_map <- stats::setNames(
      unname(species_palette[species_ids]),
      vapply(species_ids, localized_species_name_by_id, character(1), lang = lang)
    )

    p <- plotly::plot_ly(
      data = df,
      x = ~genome_mb,
      y = ~scaffold_n50_mb,
      type = "scatter",
      mode = "markers",
      color = ~display_label,
      colors = palette_map,
      symbol = ~source_db,
      symbols = c("GenBank" = "circle", "RefSeq" = "diamond"),
      customdata = ~target_key,
      hovertext = ~hover_text,
      hovertemplate = "%{hovertext}<extra></extra>",
      marker = list(size = df$marker_size, opacity = 0.84, line = list(color = "white", width = 1.4)),
      source = "genome_landscape_source",
      showlegend = FALSE
      ) %>%
      plotly::layout(
        title = plotly_title_spec(tr(lang, "genome_landscape_title")),
        margin = list(l = 60, r = 16, b = 52, t = 40),
        xaxis = list(title = plotly_axis_title_spec(tr(lang, "genome_size_label"))),
        yaxis = list(title = plotly_axis_title_spec(tr(lang, "scaffold_n50_label")))
      ) %>%
      plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)

    p <- plotly::event_register(p, "plotly_click")
    p
  })

  output$genome_table <- renderUI({
    lang <- current_language()
    df <- filtered_genome_data()

    if (nrow(df) == 0) {
      return(
        div(
          class = "helper-note genome-empty-note",
          tr(lang, "genome_note_no_rows")
        )
      )
    }

    df$display_name <- vapply(df$species_id, localized_species_name_by_id, character(1), lang = lang)

    tags$table(
      class = "table genome-compact-table",
      tags$thead(
        tags$tr(
          tags$th(tr(lang, "species_label")),
          tags$th(tr(lang, "breed_label")),
          tags$th(tr(lang, "assembly_label")),
          tags$th(tr(lang, "accession_label")),
          tags$th(tr(lang, "genome_snapshot"))
        )
      ),
      tags$tbody(
        lapply(seq_len(nrow(df)), function(index) {
          row <- df[index, , drop = FALSE]

          tags$tr(
            tags$td(
              class = "compact-species-cell",
              tags$span(class = "compact-primary", format_text_value(row$display_name)),
              tags$span(class = "compact-secondary", format_text_value(row$scientific_name, fallback = ""))
            ),
            tags$td(format_text_value(row$breed, fallback = tr(lang, "not_available"))),
            tags$td(
              tags$span(class = "compact-primary", format_text_value(row$assembly_name)),
              tags$span(
                class = "compact-secondary",
                paste(
                  format_text_value(row$assembly_level, fallback = tr(lang, "not_available")),
                  format_text_value(row$source_db, fallback = tr(lang, "not_available")),
                  sep = " | "
                )
              )
            ),
            tags$td(
              class = "compact-accession-cell",
              format_text_value(row$accession)
            ),
            tags$td(
              class = "compact-metrics-cell",
              tags$span(
                class = "compact-metric-line",
                tags$strong(tr(lang, "genome_size_label")),
                paste0(": ", format_numeric_value(row$genome_mb))
              ),
              tags$span(
                class = "compact-metric-line",
                tags$strong(tr(lang, "gc_percent_label")),
                paste0(": ", format_numeric_value(row$gc_percent, digits = 2))
              ),
              tags$span(
                class = "compact-metric-line",
                tags$strong(tr(lang, "scaffold_n50_label")),
                paste0(": ", format_numeric_value(row$scaffold_n50_mb))
              )
            )
          )
        })
      )
    )
  })

  output$story_plot_karyotype_paradox <- plotly::renderPlotly({
    lang <- current_language()
    story_genome_data <- genome_data
    story_genome_data$display_name <- vapply(
      story_genome_data$species_id,
      localized_species_name_by_id,
      character(1),
      lang = lang
    )
    build_karyotype_paradox_plot(
      genome_data = story_genome_data,
      species_palette = species_palette,
      lang = lang
    ) %>%
      plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)
  })

  output$story_plot_chromosome_idiogram <- plotly::renderPlotly({
    build_chromosome_idiogram_plot(
      species_palette = species_palette,
      lang = current_language()
    ) %>%
      plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)
  })

  output$story_plot_genome_composition <- plotly::renderPlotly({
    build_genome_composition_plot(lang = current_language()) %>%
      plotly::config(displaylogo = FALSE, displayModeBar = FALSE, responsive = TRUE)
  })

  output$story_plot_phylogeny_tree <- renderImage({
    image_path <- file.path("figs", "phylogeny-tree.png")

    if (!file.exists(image_path)) {
      return(NULL)
    }

    list(
      src = normalizePath(image_path, winslash = "/", mustWork = TRUE),
      contentType = "image/png",
      width = "100%",
      alt = "Artiodactyla phylogeny figure"
    )
  }, deleteFile = FALSE)

  output$science_detail <- renderUI({
    lang <- current_language()
    species_row <- current_species()
    science_row <- current_science_entry()

    if (nrow(science_row) == 0) {
      return(
        div(
          class = "detail-panel science-panel",
          div(class = "detail-band", style = sprintf("background:%s;", species_row$color_hex)),
        div(
          class = "detail-body science-body",
            tags$h2(tr(lang, "science_coming")),
            tags$p(tr(lang, "science_missing"))
          )
        )
      )
    }

    uses <- split_pipe(localized_science_text(science_row, "primary_uses", lang))

    div(
      class = "detail-panel science-panel",
      div(class = "detail-band", style = sprintf("background:%s;", species_row$color_hex)),
      div(
        class = "detail-body science-body",
        tags$p(class = "detail-kicker", tr(lang, "science_kicker")),
        tags$h2(localized_science_text(science_row, "title", lang)),
        tags$p(class = "scientific-name", species_row$scientific_name),
        div(
          class = "chip-grid science-chip-grid",
          build_chip(tr(lang, "science_key_advantage"), localized_science_text(science_row, "key_advantage", lang)),
          build_chip(tr(lang, "science_scientific_name"), species_row$scientific_name)
        ),
        build_section(tr(lang, "science_summary"), tags$p(localized_science_text(science_row, "overview", lang))),
        build_science_figure(science_row, lang),
        build_section(
          tr(lang, "science_major_uses"),
          tags$ul(
            class = "science-bullet-list",
            lapply(uses, function(item) tags$li(item))
          )
        )
      )
    )
  })

  output$religion_detail <- renderUI({
    lang <- current_language()
    row <- current_species()
    species_id <- format_text_value(row$species_id, fallback = "")
    food_context <- format_text_value(
      row[["countries_most consumption"]],
      fallback = tr(lang, "religion_food_fallback")
    )

    div(
      class = "detail-panel religion-panel",
      div(class = "detail-band", style = sprintf("background:%s;", row$color_hex)),
      div(
        class = "detail-body religion-body",
        tags$p(class = "detail-kicker", tr(lang, "religion_kicker")),
        tags$h2(localized_species_label(row, lang)),
        tags$p(class = "scientific-name", row$scientific_name),
        build_species_image(
          row,
          "detail-figure-wrap",
          "detail-figure",
          alt_label = localized_species_label(row, lang)
        ),
        div(
          class = "chip-grid religion-chip-grid",
          build_chip(tr(lang, "religion_food_context"), food_context),
          build_chip(tr(lang, "teaching_angle"), localized_species_text(row, "teaching_focus", lang))
        ),
        build_section(
          tr(lang, "religion_highlights"),
          div(
            class = "chip-grid religion-highlight-grid",
            build_religion_highlight_chips(species_id, lang)
          )
        ),
        build_section(
          tr(lang, "religion_summary"),
          tags$p(localized_species_text(row, "religion_notes", lang))
        ),
        tags$div(
          class = "religion-callout",
          tags$h3(tr(lang, "religion_discussion")),
          tags$p(localized_species_text(row, "teaching_focus", lang))
        )
      )
    )
  })
}

shinyApp(ui, server)
