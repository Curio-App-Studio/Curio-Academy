import json

# Comprehensive English chapters for CBSE, ICSE, and State Board from LKG to Class 8
chapters = [
    # LKG
    {
        "chapterId": "eng_lkg_ch01",
        "chapterNumber": 1,
        "title": "Phonics & Letter Sounds (A to Z)",
        "grade": "LKG",
        "board": "all",
        "subjectId": "english",
        "icon": "🔤",
        "description": "Learn letter sounds, matching big letters (A) to small letters (a), and fun alphabet rhymes!",
        "keyConcepts": ["Letter Recognition A-Z", "Phonic Sounds", "Upper & Lower Case", "Alphabet Song"],
        "rules": [
            "Every letter has a name and makes a sound: 'A' says /æ/ as in Apple, 'B' says /b/ as in Ball.",
            "Capital letters start our names, and small letters are used inside words."
        ],
        "exampleQuestion": "Which letter sound does the word 'Sun' start with?",
        "exampleExplanation": "When we say 'Sun', the very first sound we make is /s/, which is the letter S!",
        "exampleAnswer": "Letter S (as in Sun)",
        "funFact": "The word 'alphabet' comes from the first two letters of the Greek alphabet: Alpha and Beta!",
        "mascotAdvice": "Make letter shapes with playdough or in the sand to remember their curves!",
        "activityIds": []
    },
    {
        "chapterId": "eng_lkg_ch02",
        "chapterNumber": 2,
        "title": "Rhyming Words & Picture Naming",
        "grade": "LKG",
        "board": "all",
        "subjectId": "english",
        "icon": "🐱",
        "description": "Discover words that sound the same at the end like Cat & Bat, and name everyday toys and animals!",
        "keyConcepts": ["Rhyming Endings", "Picture Vocabulary", "Animal Sounds", "Word Repetition"],
        "rules": [
            "Rhyming words have the exact same ending sound: Cat rhymes with Hat, Mat, and Bat.",
            "Looking at picture clues helps us identify the first letter of words."
        ],
        "exampleQuestion": "Which word rhymes with 'Cat'?",
        "exampleExplanation": "Cat and Hat end with the same 'at' sound! So Hat rhymes with Cat.",
        "exampleAnswer": "Hat 🎩",
        "funFact": "Nursery rhymes help our brains recognize speech sounds faster and build strong listening memory!",
        "mascotAdvice": "Clap your hands whenever you hear two words that rhyme in a song!",
        "activityIds": []
    },

    # UKG
    {
        "chapterId": "eng_ukg_ch01",
        "chapterNumber": 1,
        "title": "Vowels & Consonants (A, E, I, O, U)",
        "grade": "UKG",
        "board": "all",
        "subjectId": "english",
        "icon": "⭐",
        "description": "Meet the 5 super vowel friends: A, E, I, O, U, and learn how they give voice to words!",
        "keyConcepts": ["5 Vowels (A, E, I, O, U)", "21 Consonants", "CVC Words (Consonant-Vowel-Consonant)", "Vowel Sounds"],
        "rules": [
            "The 5 special letters are A, E, I, O, U. All other 21 letters are consonants.",
            "Almost every English word needs at least one vowel to be spoken out loud."
        ],
        "exampleQuestion": "Which of these is a special Vowel letter?",
        "exampleExplanation": "The vowels are A, E, I, O, and U. Letter 'E' is one of the five vowels!",
        "exampleAnswer": "E 🌟",
        "funFact": "The word 'facetious' contains all five vowels in alphabetical order: a, e, i, o, u!",
        "mascotAdvice": "Touch your thumb and 4 fingers to remember the 5 vowels: A, E, I, O, U!",
        "activityIds": []
    },
    {
        "chapterId": "eng_ukg_ch02",
        "chapterNumber": 2,
        "title": "Sight Words & Three-Letter CVC Words",
        "grade": "UKG",
        "board": "all",
        "subjectId": "english",
        "icon": "👁️",
        "description": "Read simple three-letter words like P-E-N and catch sight words like THE, AND, IS at a glance!",
        "keyConcepts": ["Sight Words (the, is, in, at, on)", "Blending 3 Letters", "Short Vowel Sounds", "Reading Simple Sentences"],
        "rules": [
            "Sight words are common words we recognize instantly by sight without sounding out every letter.",
            "Blend the sounds together: /b/ + /e/ + /d/ = bed!"
        ],
        "exampleQuestion": "Read and blend the sounds: /p/ + /i/ + /g/. What word is it?",
        "exampleExplanation": "When we blend /p/, /i/, and /g/ together smoothly, it forms the word 'pig'!",
        "exampleAnswer": "Pig 🐷",
        "funFact": "Just 100 sight words make up about half of all written English in children's storybooks!",
        "mascotAdvice": "Spot sight words on street signs, milk cartons, and storybooks every day!",
        "activityIds": []
    },

    # Class 1
    {
        "chapterId": "eng_c1_ch01",
        "chapterNumber": 1,
        "title": "Naming Words (Nouns: People, Places & Things)",
        "grade": "Class 1",
        "board": "all",
        "subjectId": "english",
        "icon": "🎒",
        "description": "Discover how every person, place, animal, and object in the world has a naming word!",
        "keyConcepts": ["Person Names (teacher, boy)", "Place Names (school, park)", "Animal Names (dog, bird)", "Thing Names (book, pencil)"],
        "rules": [
            "A Noun is the name of a person, animal, place, or thing.",
            "Special names of people and places always begin with a Capital Letter (e.g. Rahul, Delhi)."
        ],
        "exampleQuestion": "In the sentence 'The cat sits on the chair', which word is an animal naming word?",
        "exampleExplanation": "'Cat' is the name of an animal, so 'cat' is the noun!",
        "exampleAnswer": "Cat",
        "funFact": "Even feelings like 'happiness' and 'joy' are nouns because they are names of emotions!",
        "mascotAdvice": "Look around your room: every single item you can point to is a naming word (noun)!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c1_ch02",
        "chapterNumber": 2,
        "title": "Action Words (Verbs in Daily Life)",
        "grade": "Class 1",
        "board": "all",
        "subjectId": "english",
        "icon": "🏃",
        "description": "Explore doing words like run, jump, eat, read, smile, and sleep that show what people and animals do!",
        "keyConcepts": ["Doing Words / Action Words", "Physical Actions (run, jump)", "Daily Routine Verbs", "Sentence Building"],
        "rules": [
            "An Action Word (Verb) tells us what someone or something is doing.",
            "Every complete sentence must have an action word to tell what is happening."
        ],
        "exampleQuestion": "Which word in 'Birds fly in the sky' is an action word?",
        "exampleExplanation": "'Fly' is what the birds are doing! Flying is an action, so 'fly' is the verb.",
        "exampleAnswer": "Fly 🕊️",
        "funFact": "The shortest complete sentence in English is 'Go!' which has just one action verb!",
        "mascotAdvice": "Whenever you do something fun, say the action verb out loud: 'I am jumping!'",
        "activityIds": []
    },
    {
        "chapterId": "eng_c1_ch03",
        "chapterNumber": 3,
        "title": "Articles: Using 'A' and 'An'",
        "grade": "Class 1",
        "board": "all",
        "subjectId": "english",
        "icon": "🍎",
        "description": "Learn the magic rule for choosing 'A' or 'An' before singular naming words!",
        "keyConcepts": ["Using 'A' before Consonant Sounds", "Using 'An' before Vowel Sounds (a, e, i, o, u)", "Singular Nouns"],
        "rules": [
            "Use 'AN' before words that start with a vowel sound (a, e, i, o, u): an apple, an elephant, an umbrella.",
            "Use 'A' before words that start with a consonant sound: a book, a tree, a dog."
        ],
        "exampleQuestion": "Which article goes before 'orange': 'a' or 'an'?",
        "exampleExplanation": "'Orange' begins with the vowel 'o' which has a vowel sound /ɒ/. Therefore we say 'an orange'.",
        "exampleAnswer": "An orange 🍊",
        "funFact": "We use 'an' because it makes speaking smoother: saying 'an apple' flows much easier than saying 'a apple'!",
        "mascotAdvice": "Listen to the very first sound: if it starts with your vowels (a, e, i, o, u), put 'an' first!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c1_ch04",
        "chapterNumber": 4,
        "title": "Describing Words (Adjectives: Colors, Shapes & Sizes)",
        "grade": "Class 1",
        "board": "all",
        "subjectId": "english",
        "icon": "🎨",
        "description": "Make your stories vivid with words that describe colors, sizes, shapes, and numbers!",
        "keyConcepts": ["Color Adjectives (red, blue)", "Size Adjectives (big, tiny)", "Number Adjectives (two, three)", "Feel & Taste Adjectives (sweet, soft)"],
        "rules": [
            "A Describing Word (Adjective) tells us more about a noun: what color, what size, or how many.",
            "Describing words usually sit right before the naming word: a 'sweet' mango, a 'big' house."
        ],
        "exampleQuestion": "In 'The red balloon flew high', which word is a describing word?",
        "exampleExplanation": "'Red' tells us the color of the balloon! Describing words tell us about the noun.",
        "exampleAnswer": "Red 🎈",
        "funFact": "Without describing words, our stories would be plain: adjectives add all the colors and flavors to reading!",
        "mascotAdvice": "Describe your favorite toy using three words: color, size, and how it feels!",
        "activityIds": []
    },

    # Class 2
    {
        "chapterId": "eng_c2_ch01",
        "chapterNumber": 1,
        "title": "Singular and Plural Nouns (One and Many)",
        "grade": "Class 2",
        "board": "all",
        "subjectId": "english",
        "icon": "📚",
        "description": "Learn how words change when we talk about one thing versus many: adding -s, -es, and special words!",
        "keyConcepts": ["Adding -s (book -> books)", "Adding -es (bus -> buses, box -> boxes)", "Words ending in -ch, -sh, -x, -s", "Irregular plurals (child -> children)"],
        "rules": [
            "For most nouns, simply add 's' to make plural: boy -> boys, tree -> trees.",
            "When a noun ends in -s, -ss, -sh, -ch, or -x, add 'es': brush -> brushes, watch -> watches.",
            "Special nouns change completely: foot -> feet, tooth -> teeth, child -> children."
        ],
        "exampleQuestion": "What is the plural of 'box'?",
        "exampleExplanation": "Since 'box' ends in 'x', we add 'es' to make it plural: 'boxes'!",
        "exampleAnswer": "Boxes 📦",
        "funFact": "Some words stay exactly the same in singular and plural: one sheep, ten sheep; one fish, many fish!",
        "mascotAdvice": "Listen to the end of the word: if it hisses like a snake (-s, -sh, -ch, -x), give it an 'es'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c2_ch02",
        "chapterNumber": 2,
        "title": "Pronouns: Replacing Naming Words (He, She, It, They)",
        "grade": "Class 2",
        "board": "all",
        "subjectId": "english",
        "icon": "👥",
        "description": "Stop repeating names again and again by using smart pronouns: he, she, it, they, and we!",
        "keyConcepts": ["Subject Pronouns", "He (male)", "She (female)", "It (objects/animals)", "They & We (groups)"],
        "rules": [
            "Use 'He' for a boy or man: Rohan is kind. He helps everyone.",
            "Use 'She' for a girl or woman: Priya sings well. She is talented.",
            "Use 'It' for a thing, animal, or baby.",
            "Use 'They' for more than one person, animal, or thing."
        ],
        "exampleQuestion": "Replace the underlined word: 'Priya is reading. Priya loves books.'",
        "exampleExplanation": "Priya is a girl, so we replace the repeated name with the pronoun 'She'!",
        "exampleAnswer": "She",
        "funFact": "The word 'I' is always capitalized in English, no matter where it appears in a sentence!",
        "mascotAdvice": "Notice when you repeat a friend's name: swap it with 'he' or 'she' to make sentences flow!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c2_ch03",
        "chapterNumber": 3,
        "title": "Prepositions of Position (In, On, Under, Behind, Near)",
        "grade": "Class 2",
        "board": "all",
        "subjectId": "english",
        "icon": "📍",
        "description": "Discover positional words that tell us exactly where someone or something is hiding or sitting!",
        "keyConcepts": ["In (inside)", "On (touching top)", "Under (below)", "Behind (at the back)", "Between (in the middle)"],
        "rules": [
            "A preposition shows the position of a noun relative to another thing.",
            "Use 'on' when an object touches the surface: The book is on the desk.",
            "Use 'in' when an object is inside a boundary: The pencil is in the pouch."
        ],
        "exampleQuestion": "Where is the ball if it is completely inside the cardboard box?",
        "exampleExplanation": "When something is inside an enclosed space or container, we use 'in'. The ball is in the box.",
        "exampleAnswer": "In the box 📦",
        "funFact": "The word 'preposition' literally means 'placed before' because it usually sits before a noun!",
        "mascotAdvice": "Play hide and seek with a toy and describe its location: 'The teddy is under the pillow!'",
        "activityIds": []
    },
    {
        "chapterId": "eng_c2_ch04",
        "chapterNumber": 4,
        "title": "Punctuation Basics: Capital Letters, Full Stops & Question Marks",
        "grade": "Class 2",
        "board": "all",
        "subjectId": "english",
        "icon": "❓",
        "description": "Learn the golden rules of punctuation: start with a capital letter, and finish with a full stop or question mark!",
        "keyConcepts": ["Starting Capital Letters", "Full Stop (.) for Statements", "Question Mark (?) for Questions", "Names of People & Days"],
        "rules": [
            "Every sentence starts with a Capital Letter.",
            "A telling sentence (statement) ends with a Full Stop (.).",
            "An asking sentence (question) ends with a Question Mark (?)."
        ],
        "exampleQuestion": "Which mark should end the sentence: 'Where are my shoes'?",
        "exampleExplanation": "This sentence is asking for information (a question), so it must end with a question mark (?).",
        "exampleAnswer": "Question Mark (?)",
        "funFact": "Punctuation was invented to help actors know when to pause and breathe when reading scripts out loud!",
        "mascotAdvice": "If your voice goes up at the end of a sentence, it's asking a question: use '?'!",
        "activityIds": []
    },

    # Class 3
    {
        "chapterId": "eng_c3_ch01",
        "chapterNumber": 1,
        "title": "Types of Nouns: Common, Proper & Collective",
        "grade": "Class 3",
        "board": "all",
        "subjectId": "english",
        "icon": "🏛️",
        "description": "Master specific names like India, general names like country, and collective group names like a herd of cows!",
        "keyConcepts": ["Common Nouns (city, dog)", "Proper Nouns (Mumbai, Tommy)", "Collective Nouns (flock, team, swarm)", "Capitalization of Proper Nouns"],
        "rules": [
            "A Proper Noun is the unique name of a particular person, place, or monument, and ALWAYS begins with a capital letter.",
            "A Collective Noun names a group of people, animals, or things taken as one whole (e.g. a swarm of bees, a bouquet of flowers)."
        ],
        "exampleQuestion": "What is the collective noun for a group of wolves hunting together?",
        "exampleExplanation": "Wolves live and hunt in a group called a 'pack'. So we say 'a pack of wolves'.",
        "exampleAnswer": "Pack of wolves 🐺",
        "funFact": "A group of flamingos is called a 'flamboyance', and a group of owls is called a 'parliament'!",
        "mascotAdvice": "Remember: Common nouns are general; Proper nouns are unique VIP names that get a Capital letter!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c3_ch02",
        "chapterNumber": 2,
        "title": "Verbs & Simple Tenses (Present, Past & Future)",
        "grade": "Class 3",
        "board": "all",
        "subjectId": "english",
        "icon": "⏳",
        "description": "Travel across time: what happens today (Present), happened yesterday (Past), and will happen tomorrow (Future)!",
        "keyConcepts": ["Simple Present (walk, walks)", "Simple Past with -ed (walked, played)", "Irregular Past (go -> went, eat -> ate)", "Simple Future with 'will'"],
        "rules": [
            "Present tense tells what happens regularly: He plays football.",
            "Past tense tells what already finished: He played football yesterday.",
            "Future tense tells what will happen later: He will play football tomorrow."
        ],
        "exampleQuestion": "Change 'eat' into the past tense: 'Yesterday, I ______ an apple.'",
        "exampleExplanation": "'Eat' is an irregular verb. Its past tense is 'ate', not 'eated'!",
        "exampleAnswer": "Ate 🍎",
        "funFact": "The word 'yesterday' originally meant 'the other day' in Old English!",
        "mascotAdvice": "Look for time clues: 'yesterday' calls for past tense; 'tomorrow' calls for 'will'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c3_ch03",
        "chapterNumber": 3,
        "title": "Degrees of Comparison (Adjectives: Big, Bigger, Biggest)",
        "grade": "Class 3",
        "board": "all",
        "subjectId": "english",
        "icon": "📏",
        "description": "Compare two or more things using positive, comparative (-er), and superlative (-est) degrees!",
        "keyConcepts": ["Positive Degree (tall)", "Comparative Degree (-er / more: taller than)", "Superlative Degree (-est / most: tallest of all)", "Irregular (good, better, best)"],
        "rules": [
            "Use Comparative (-er) when comparing two things: An elephant is bigger than a horse.",
            "Use Superlative (-est) when comparing three or more things: The blue whale is the biggest animal.",
            "Always use 'the' before superlative adjectives: 'the fastest runner'."
        ],
        "exampleQuestion": "Fill in the blank: 'Mount Everest is the ______ mountain in the world.'",
        "exampleExplanation": "We are comparing Everest to all mountains in the world (superlative), so we use 'highest' with 'the'.",
        "exampleAnswer": "Highest 🏔️",
        "funFact": "'Good, better, best' comes from different ancient roots, which is why 'gooder' is never used!",
        "mascotAdvice": "Two items = compare with -er. Three or more = the champion with -est!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c3_ch04",
        "chapterNumber": 4,
        "title": "Conjunctions: Joining Words (And, But, Because, Or)",
        "grade": "Class 3",
        "board": "all",
        "subjectId": "english",
        "icon": "🔗",
        "description": "Become a sentence builder! Connect ideas smoothly using powerful joining words.",
        "keyConcepts": ["And (adding ideas)", "But (contrasting ideas)", "Because (giving reasons)", "Or (offering choices)"],
        "rules": [
            "Use 'and' to connect similar thoughts: I like tea and biscuits.",
            "Use 'but' to show an opposite or contrast: I wanted to go out, but it rained.",
            "Use 'because' to answer 'why': I wore a sweater because it was cold."
        ],
        "exampleQuestion": "Choose the right conjunction: 'Rohan worked hard, ______ he passed with top marks.'",
        "exampleExplanation": "Passing is the direct positive result/continuation of working hard, so 'and' (or 'so') connects the thoughts.",
        "exampleAnswer": "And",
        "funFact": "The word 'conjunction' comes from Latin 'con' (together) + 'jungere' (to join)!",
        "mascotAdvice": "Think of conjunctions as glue: 'and' adds, 'but' turns around, and 'because' explains why!",
        "activityIds": []
    },

    # Class 4
    {
        "chapterId": "eng_c4_ch01",
        "chapterNumber": 1,
        "title": "Sentences: Subject and Predicate",
        "grade": "Class 4",
        "board": "all",
        "subjectId": "english",
        "icon": "🧩",
        "description": "Every complete sentence has two vital halves: the Subject (who or what) and the Predicate (what they do)!",
        "keyConcepts": ["Subject (who/what sentence is about)", "Predicate (contains the verb and tells about subject)", "Complete Thoughts", "Fragments vs Sentences"],
        "rules": [
            "The Subject names who or what performs the action.",
            "The Predicate begins with the verb and tells what the subject is or does.",
            "Example: [The little bird] (Subject) [built a cozy nest] (Predicate)."
        ],
        "exampleQuestion": "Identify the Subject in: 'The brave firefighter rescued the scared cat.'",
        "exampleExplanation": "Ask: Who performed the action of rescuing? 'The brave firefighter' is the complete subject!",
        "exampleAnswer": "The brave firefighter 🚒",
        "funFact": "In command sentences like 'Sit down!', the subject is silently understood to be '(You)'!",
        "mascotAdvice": "Find the verb first! Everything before it answering 'who?' is your subject.",
        "activityIds": []
    },
    {
        "chapterId": "eng_c4_ch02",
        "chapterNumber": 2,
        "title": "Adverbs: Modifying Verbs (Manner, Time & Place)",
        "grade": "Class 4",
        "board": "all",
        "subjectId": "english",
        "icon": "⚡",
        "description": "Discover words that tell HOW (slowly), WHEN (yesterday), and WHERE (everywhere) an action happened!",
        "keyConcepts": ["Adverbs of Manner (how: quickly, softly)", "Adverbs of Time (when: now, soon, tomorrow)", "Adverbs of Place (where: outside, here)", "Forming adverbs with -ly"],
        "rules": [
            "An Adverb tells more about a verb, an adjective, or another adverb.",
            "Most adverbs of manner are formed by adding '-ly' to adjectives: slow -> slowly, quick -> quickly.",
            "Beware of exceptions: fast remains 'fast' (never 'fastly')!"
        ],
        "exampleQuestion": "In 'The tortoise walked slowly along the path', which word is the adverb?",
        "exampleExplanation": "'Slowly' describes HOW the tortoise walked (manner). So 'slowly' is the adverb!",
        "exampleAnswer": "Slowly 🐢",
        "funFact": "The word 'well' is the adverb form of the adjective 'good': 'He plays well', not 'He plays good'!",
        "mascotAdvice": "Ask: How was it done? When was it done? Where was it done? That word is an adverb!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c4_ch03",
        "chapterNumber": 3,
        "title": "Pronouns: Relative and Possessive (Mine, Yours, Whose)",
        "grade": "Class 4",
        "board": "all",
        "subjectId": "english",
        "icon": "🏷️",
        "description": "Show ownership without apostrophes (mine, ours, theirs) and link descriptions with who, which, and that!",
        "keyConcepts": ["Possessive Pronouns (mine, yours, his, hers, ours, theirs)", "Possessive Adjectives vs Pronouns", "Relative Pronouns (who, which, that)", "Avoiding 'it's' vs 'its' errors"],
        "rules": [
            "Possessive pronouns stand alone without a noun after them: 'This bag is mine' (not 'my').",
            "'Its' shows possession (The dog wagged its tail). 'It's' is short for 'it is'!",
            "Use 'who' for people, and 'which' or 'that' for animals and objects."
        ],
        "exampleQuestion": "Fill in the blank: 'This book belongs to Ria. It is ______.'",
        "exampleExplanation": "The possessive pronoun replacing 'Ria's book' is 'hers'.",
        "exampleAnswer": "Hers 📖",
        "funFact": "Possessive pronouns NEVER have apostrophes: yours, hers, ours, theirs, its are all apostrophe-free!",
        "mascotAdvice": "If you can replace it with 'it is', write 'it\'s'. If it shows ownership, write 'its'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c4_ch04",
        "chapterNumber": 4,
        "title": "Vocabulary: Synonyms, Antonyms & Homophones",
        "grade": "Class 4",
        "board": "all",
        "subjectId": "english",
        "icon": "🧠",
        "description": "Expand your word power with identical meanings (synonyms), opposites (antonyms), and tricky twin sounds (homophones)!",
        "keyConcepts": ["Synonyms (happy/joyful, huge/enormous)", "Antonyms (ancient/modern, brave/cowardly)", "Homophones (sun/son, sea/see, pair/pear)", "Context Clues"],
        "rules": [
            "Synonyms are words with nearly identical meanings.",
            "Antonyms are words with opposite meanings.",
            "Homophones sound the exact same but have different spellings and meanings: 'hear' (with ear) vs 'here' (place)."
        ],
        "exampleQuestion": "Which word is an antonym (opposite) of 'Ancient'?",
        "exampleExplanation": "'Ancient' means very old from long ago. Its direct opposite is 'Modern' or 'New'.",
        "exampleAnswer": "Modern 🏙️",
        "funFact": "The word 'set' has over 400 different dictionary meanings, making it one of the most flexible words in English!",
        "mascotAdvice": "Break homophones down: 'hear' has 'ear' inside it, which helps you remember you hear with your ear!",
        "activityIds": []
    },

    # Class 5
    {
        "chapterId": "eng_c5_ch01",
        "chapterNumber": 1,
        "title": "Continuous and Perfect Tenses",
        "grade": "Class 5",
        "board": "all",
        "subjectId": "english",
        "icon": "🔄",
        "description": "Master ongoing actions (-ing continuous) and completed accomplishments (has/have/had + past participle)!",
        "keyConcepts": ["Present Continuous (is/are + verb-ing)", "Past Continuous (was/were + verb-ing)", "Present Perfect (has/have + V3)", "Past Perfect (had + V3)"],
        "rules": [
            "Continuous tenses describe actions in progress at that moment: She is studying.",
            "Present Perfect connects past actions to now: I have finished my homework.",
            "Use 'has' with singular subjects (He, She, It) and 'have' with plural subjects (I, You, We, They)."
        ],
        "exampleQuestion": "Fill in the blank: 'We ______ (live) in this city for five years now.'",
        "exampleExplanation": "The action started in the past and continues up to the present: use Present Perfect 'have lived'.",
        "exampleAnswer": "Have lived 🏡",
        "funFact": "English is one of the few languages with a distinct continuous tense using '-ing' for immediate actions!",
        "mascotAdvice": "Has/Have + 3rd form (V3) = action finished with impact on the present!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c5_ch02",
        "chapterNumber": 2,
        "title": "Subject-Verb Agreement Rules",
        "grade": "Class 5",
        "board": "all",
        "subjectId": "english",
        "icon": "⚖️",
        "description": "Ensure harmony in your sentences: singular subjects take singular verbs, and plural subjects take plural verbs!",
        "keyConcepts": ["Singular Subject = Singular Verb (with -s: runs, eats)", "Plural Subject = Plural Verb (without -s: run, eat)", "Either/Or & Neither/Nor", "Collective Nouns Agreement"],
        "rules": [
            "A singular noun takes a singular verb ending in -s or -es: The train arrives at 5 PM.",
            "A plural noun takes a plural verb without -s: The trains arrive at 5 PM.",
            "When two subjects are joined by 'and', use a plural verb: Bread and butter are on the table."
        ],
        "exampleQuestion": "Choose the correct verb: 'Neither the teacher nor the students ______ present.'",
        "exampleExplanation": "When subjects are joined by 'neither...nor', the verb agrees with the subject closest to it ('students' is plural -> 'were').",
        "exampleAnswer": "Were",
        "funFact": "Notice the opposite rule: Nouns add -s to become plural (dogs), but Verbs add -s to become singular (runs)!",
        "mascotAdvice": "Singular subject needs an 's' on the present tense verb: He walks, She sings, It works!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c5_ch03",
        "chapterNumber": 3,
        "title": "Direct and Indirect Speech Introduction",
        "grade": "Class 5",
        "board": "all",
        "subjectId": "english",
        "icon": "💬",
        "description": "Learn the difference between quoting exact spoken words with quotation marks versus reporting the message!",
        "keyConcepts": ["Direct Speech with Quotation Marks (\u201c...\u201d)", "Indirect / Reported Speech", "Removing Quotation Marks with 'that'", "Changing Pronouns (I -> he/she)"],
        "rules": [
            "Direct Speech quotes the speaker's exact words inside speech marks: She said, \u201cI am hungry.\u201d",
            "Indirect Speech reports what was said without quotation marks: She said that she was hungry.",
            "In indirect speech, the present tense often steps back into the past tense."
        ],
        "exampleQuestion": "Convert to indirect: Rohan said, \u201cI like ice cream.\u201d",
        "exampleExplanation": "Remove quotes, add 'that', change 'I' to 'he', and step present 'like' back to past 'liked': Rohan said that he liked ice cream.",
        "exampleAnswer": "Rohan said that he liked ice cream 🍦",
        "funFact": "Speech marks are also called inverted commas or quote marks!",
        "mascotAdvice": "When reporting what someone said in the past, push their words one step back in time!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c5_ch04",
        "chapterNumber": 4,
        "title": "Active and Passive Voice Foundations",
        "grade": "Class 5",
        "board": "all",
        "subjectId": "english",
        "icon": "🔄",
        "description": "Discover how the doer of the action and the receiver of the action can switch places in a sentence!",
        "keyConcepts": ["Active Voice (Subject performs action)", "Passive Voice (Subject receives action)", "Formula: Object + helping verb + V3 + by + Subject", "Past Participle (V3)"],
        "rules": [
            "In Active Voice, the subject does the action: The chef baked the cake.",
            "In Passive Voice, the object becomes the subject: The cake was baked by the chef.",
            "Passive voice always uses a form of 'be' (is, was, were) plus the past participle (3rd form) of the verb."
        ],
        "exampleQuestion": "Turn into Passive Voice: 'Alexander Graham Bell invented the telephone.'",
        "exampleExplanation": "Object 'The telephone' comes first + 'was' + V3 'invented' + 'by' + 'Alexander Graham Bell'.",
        "exampleAnswer": "The telephone was invented by Alexander Graham Bell ☎️",
        "funFact": "News reports and science textbooks use passive voice frequently when the result is more important than who did it!",
        "mascotAdvice": "Passive formula: Object becomes Leader + Be verb + 3rd form verb + by + Doer!",
        "activityIds": []
    },

    # Class 6
    {
        "chapterId": "eng_c6_ch01",
        "chapterNumber": 1,
        "title": "Noun, Adjective and Adverb Clauses",
        "grade": "Class 6",
        "board": "cbse",
        "subjectId": "english",
        "icon": "📐",
        "description": "Dive deep into subordinate clauses and discover how groups of words act as single parts of speech!",
        "keyConcepts": ["Independent vs Dependent Clauses", "Noun Clauses (answers what)", "Adjective / Relative Clauses (who, which, that)", "Adverb Clauses (condition, reason, time)"],
        "rules": [
            "A Clause has both a subject and a predicate of its own.",
            "An Adjective Clause describes a noun right before it: The boy [who won the race] is my brother.",
            "An Adverb Clause modifies a verb by showing when, why, or how: We stayed inside [because it was raining]."
        ],
        "exampleQuestion": "Identify the clause type: 'I know [where the treasure is hidden].'",
        "exampleExplanation": "The bracketed clause answers 'what do I know?' It acts as the object noun of the verb 'know': Noun Clause.",
        "exampleAnswer": "Noun Clause 💎",
        "funFact": "Clauses are the architectural building blocks that let writers build rich, sophisticated compound-complex sentences!",
        "mascotAdvice": "Ask what job the clause does: describing a noun = Adjective clause; answering what = Noun clause!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c6_ch02",
        "chapterNumber": 2,
        "title": "Prepositions & Phrasal Verbs",
        "grade": "Class 6",
        "board": "all",
        "subjectId": "english",
        "icon": "🧭",
        "description": "Master tricky prepositions of time, movement, and phrasal verbs like give up, look after, and bring about!",
        "keyConcepts": ["Prepositions of Time (at 5 PM, in July, on Monday)", "Prepositions of Direction (into, across, through)", "Phrasal Verbs (verb + preposition)", "Idiomatic Meanings"],
        "rules": [
            "Use 'at' for precise clock times (at 3 PM), 'on' for days and dates (on Sunday, on 15th August), 'in' for months, years, and long periods (in 2026, in summer).",
            "Phrasal verbs change the meaning of the original verb completely: 'give' = offer, but 'give up' = quit."
        ],
        "exampleQuestion": "Which preposition completes: 'The train arrived exactly ______ 6:30 PM.'",
        "exampleExplanation": "For exact clock times, always use the preposition 'at'.",
        "exampleAnswer": "At ⏰",
        "funFact": "There are over 10,000 phrasal verbs in the English language, making it one of the most expressive idioms!",
        "mascotAdvice": "Time pyramid: AT is narrow (hours), ON is medium (days/dates), IN is wide (months/years)!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c6_ch03",
        "chapterNumber": 3,
        "title": "Modal Auxiliaries (Can, Could, May, Might, Must, Should)",
        "grade": "Class 6",
        "board": "all",
        "subjectId": "english",
        "icon": "🛡️",
        "description": "Express ability, permission, possibility, necessity, and polite requests using modal verbs!",
        "keyConcepts": ["Ability (can, could)", "Permission (may, can)", "Obligation & Duty (must, should, ought to)", "Possibility (might, may)"],
        "rules": [
            "Modal verbs are helping verbs that never add '-s' or '-ed': He can swim (never 'He cans swim').",
            "Modals are always followed by the base root form (V1) of the main verb: You must study.",
            "'Must' expresses strong necessity; 'Should' expresses advice or duty."
        ],
        "exampleQuestion": "Which modal expresses moral duty or advice: 'You ______ respect your elders.'",
        "exampleExplanation": "'Should' or 'ought to' is used to express advice, moral obligation, or duty.",
        "exampleAnswer": "Should 🤝",
        "funFact": "Modals are called 'defective verbs' by linguists because they lack infinitive and participle forms!",
        "mascotAdvice": "Never put 'to' after can, could, may, might, must, or should: just say 'must go', not 'must to go'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c6_ch04",
        "chapterNumber": 4,
        "title": "Active and Passive Voice: All Tenses",
        "grade": "Class 6",
        "board": "all",
        "subjectId": "english",
        "icon": "🔄",
        "description": "Transform sentences between active and passive voice across present, past, future, and continuous tenses!",
        "keyConcepts": ["Present & Past Simple Passive", "Continuous Passive (being + V3)", "Perfect Passive (been + V3)", "Omitting the agent ('by someone')"],
        "rules": [
            "Continuous tenses use 'being': Active: She is writing a letter. -> Passive: A letter is being written by her.",
            "Perfect tenses use 'been': Active: They have solved the puzzle. -> Passive: The puzzle has been solved by them.",
            "Intransitive verbs (verbs without an object, like 'sleep' or 'arrive') cannot be transformed into passive voice."
        ],
        "exampleQuestion": "Transform into passive: 'The mechanics are repairing the car.'",
        "exampleExplanation": "'The car' (singular) + 'is being' (continuous) + 'repaired' (V3) + 'by the mechanics'.",
        "exampleAnswer": "The car is being repaired by the mechanics 🚗",
        "funFact": "Intransitive verbs cannot form passives: you can say 'The cake was eaten', but you cannot say 'The bed was slept'!",
        "mascotAdvice": "Continuous active -> insert 'being' in passive. Perfect active -> insert 'been' in passive!",
        "activityIds": []
    },

    # Class 7
    {
        "chapterId": "eng_c7_ch01",
        "chapterNumber": 1,
        "title": "Reported Speech: Statements, Commands & Questions",
        "grade": "Class 7",
        "board": "all",
        "subjectId": "english",
        "icon": "🗣️",
        "description": "Master reporting statements, questions (if/whether & WH-words), and imperative commands/requests!",
        "keyConcepts": ["Backshift of Tenses (Present -> Past, Past -> Past Perfect)", "Pronoun & Time Changes (now -> then, today -> that day)", "Questions (asked if/whether)", "Orders & Requests (ordered/requested + to-infinitive)"],
        "rules": [
            "When the reporting verb is in the past ('said'), tenses shift back: 'I am' becomes 'he was', 'I have' becomes 'he had'.",
            "Universal truths and scientific facts DO NOT shift tense: Teacher said, \u201cWater boils at 100°C\u201d -> Teacher said that water boils at 100°C.",
            "For yes/no questions, use 'if' or 'whether': He asked, \u201cAre you coming?\u201d -> He asked if I was coming."
        ],
        "exampleQuestion": "Convert to reported speech: She said, \u201cI bought a new laptop yesterday.\u201d",
        "exampleExplanation": "Past simple 'bought' shifts to past perfect 'had bought', and 'yesterday' becomes 'the previous day'.",
        "exampleAnswer": "She said that she had bought a new laptop the previous day 💻",
        "funFact": "If the reporting verb is in present tense ('She says...'), the reported tense does not change at all!",
        "mascotAdvice": "Watch out for universal truths: the sun still rises in the east, so don't change it to 'rose'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c7_ch02",
        "chapterNumber": 2,
        "title": "Subject-Verb Concord: Advanced Rules",
        "grade": "Class 7",
        "board": "all",
        "subjectId": "english",
        "icon": "⚖️",
        "description": "Solve tricky subject-verb agreement challenges: collective nouns, intervening phrases, and indefinite pronouns!",
        "keyConcepts": ["Each, Every, Either, Neither take Singular Verbs", "Intervening phrases ('along with', 'as well as')", "Nouns plural in form but singular in meaning (Physics, News, Mathematics)", "Pairs of items (scissors, trousers)"],
        "rules": [
            "Words like 'each', 'everyone', 'nobody' are grammatically singular: Everyone has submitted their work.",
            "Phrases like 'accompanied by' or 'as well as' do not change the subject number: The captain, as well as the players, was honored.",
            "'Mathematics', 'Physics', 'News' end in 's' but are singular subjects taking singular verbs."
        ],
        "exampleQuestion": "Choose the correct verb: 'The news ______ truly surprising.'",
        "exampleExplanation": "'News' is an uncountable singular noun, so it takes the singular verb 'is' or 'was'.",
        "exampleAnswer": "Was 📰",
        "funFact": "'News' is actually a 14th-century word meaning 'new things', treated as a singular mass noun!",
        "mascotAdvice": "Ignore everything between the subject and the verb inside commas: only the main subject matters!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c7_ch03",
        "chapterNumber": 3,
        "title": "Conditionals: Zero, First & Second Conditionals",
        "grade": "Class 7",
        "board": "all",
        "subjectId": "english",
        "icon": "🔀",
        "description": "Express cause and effect, future possibilities, and hypothetical imaginary situations with If-clauses!",
        "keyConcepts": ["Zero Conditional (Facts: If + present, present)", "First Conditional (Real Future: If + present, will + V1)", "Second Conditional (Hypothetical: If + past, would + V1)", "Unless = If not"],
        "rules": [
            "Zero: If you heat ice, it melts (scientific certainty).",
            "First: If it rains tomorrow, we will cancel the match (realistic possibility).",
            "Second: If I won the lottery, I would travel the world (imaginary/hypothetical)."
        ],
        "exampleQuestion": "Complete the first conditional: 'If you study consistently, you ______ excellent marks.'",
        "exampleExplanation": "First conditional uses 'If + simple present', followed by 'will + base verb': 'will achieve' or 'will score'.",
        "exampleAnswer": "Will achieve 🎯",
        "funFact": "In formal English, the subjunctive 'were' is used for all persons in second conditionals: 'If I were you', not 'If I was you'!",
        "mascotAdvice": "Real possibility = If + present, WILL. Imaginary dream = If + past, WOULD!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c7_ch04",
        "chapterNumber": 4,
        "title": "Non-Finite Verbs: Infinitives, Gerunds & Participles",
        "grade": "Class 7",
        "board": "all",
        "subjectId": "english",
        "icon": "🎭",
        "description": "Unlock verbs that do not change with tense or person: to-infinitives, -ing gerunds as nouns, and participles as adjectives!",
        "keyConcepts": ["Infinitives (to + verb: to err is human)", "Gerunds (-ing verb acting as a noun: Swimming is great exercise)", "Present Participles (adjective: barking dog)", "Past Participles (adjective: broken glass)"],
        "rules": [
            "A Finite verb changes with the subject and tense (I walk, he walks, we walked).",
            "A Non-Finite verb never changes with tense or number: to eat, eating, eaten.",
            "A Gerund functions as a noun (subject or object): I enjoy reading."
        ],
        "exampleQuestion": "In 'Smoking is injurious to health', what grammatical role does 'Smoking' play?",
        "exampleExplanation": "'Smoking' is a verb ending in -ing acting as the subject noun of the sentence: that is a Gerund!",
        "exampleAnswer": "Gerund (Noun) 🚭",
        "funFact": "Participles can create funny errors called 'dangling modifiers': 'Walking into the room, the phone rang' makes it sound like the phone was walking!",
        "mascotAdvice": "If an -ing word can be replaced by 'it' or 'something', it's a Gerund acting as a noun!",
        "activityIds": []
    },

    # Class 8
    {
        "chapterId": "eng_c8_ch01",
        "chapterNumber": 1,
        "title": "Synthesis of Sentences: Simple, Compound & Complex",
        "grade": "Class 8",
        "board": "cbse",
        "subjectId": "english",
        "icon": "🏗️",
        "description": "Combine multiple short sentences into elegant simple, compound (FANBOYS), and complex structures using subordinate conjunctions!",
        "keyConcepts": ["Simple Sentences (one independent clause)", "Compound Sentences (two independent clauses + coordinating conjunction)", "Complex Sentences (one independent + one or more dependent clauses)", "FANBOYS Conjunctions (For, And, Nor, But, Or, Yet, So)"],
        "rules": [
            "A Simple Sentence contains exactly one independent clause with a subject and finite verb.",
            "A Compound Sentence joins two equal independent clauses using coordinating conjunctions (FANBOYS) or a semicolon.",
            "A Complex Sentence contains one main clause and at least one dependent clause joined by subordinating conjunctions (although, since, while, because)."
        ],
        "exampleQuestion": "Identify the sentence type: 'Although the weather was stormy, the brave sailors set out to sea.'",
        "exampleExplanation": "'Although the weather was stormy' is a dependent clause; 'the brave sailors set out to sea' is an independent clause. One main + one dependent = Complex Sentence.",
        "exampleAnswer": "Complex Sentence ⛵",
        "funFact": "The acronym FANBOYS is one of the most famous grammar mnemonics in the world: For, And, Nor, But, Or, Yet, So!",
        "mascotAdvice": "Count the independent thoughts: 1 alone = Simple. 2 equal joined with FANBOYS = Compound. 1 main + 1 dependent = Complex!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c8_ch02",
        "chapterNumber": 2,
        "title": "Transformation of Sentences: Degrees, Voice & Assertive/Negative",
        "grade": "Class 8",
        "board": "all",
        "subjectId": "english",
        "icon": "🔄",
        "description": "Transform sentences from Affirmative to Negative, Interrogative to Assertive, and Exclamatory without altering meaning!",
        "keyConcepts": ["Affirmative to Negative without changing meaning", "Interrogative to Assertive (Rhetorical Questions)", "Exclamatory to Assertive", "Too...to into So...that"],
        "rules": [
            "Transforming meaning requires using antonyms with negative words: 'He is honest' -> 'He is not dishonest'.",
            "Remove 'too...to': 'He is too weak to walk' -> 'He is so weak that he cannot walk'.",
            "Transforming rhetorical questions: 'Who does not know Mahatma Gandhi?' -> 'Everyone knows Mahatma Gandhi'."
        ],
        "exampleQuestion": "Transform without changing meaning: 'He is too proud to apologize.'",
        "exampleExplanation": "Replace 'too...to' with 'so...that cannot': 'He is so proud that he will not (cannot) apologize.'",
        "exampleAnswer": "He is so proud that he will not apologize 👑",
        "funFact": "This art of rewriting sentences while preserving exact truth value is a key test of linguistic mastery in board exams!",
        "mascotAdvice": "Always check your answer by translating both sentences: their core meaning MUST remain identical!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c8_ch03",
        "chapterNumber": 3,
        "title": "Direct and Indirect Speech: Mastery of Dialogue",
        "grade": "Class 8",
        "board": "all",
        "subjectId": "english",
        "icon": "💬",
        "description": "Master converting complex dialogues, exclamations, wishes, and imperative orders into flawless indirect narration!",
        "keyConcepts": ["Exclamatory Sentences (exclaimed with joy/sorrow)", "Optative Sentences (wished, prayed)", "Imperative Sentences (forbade, commanded)", "Tense harmony across multiple sentences"],
        "rules": [
            "Exclamations change to: Subject + exclaimed with joy/sorrow/wonder + that... (He said, \u201cHurrah! We won\u201d -> He exclaimed with joy that they had won).",
            "Negative imperatives using 'Do not' can be transformed using 'forbade': Father said, \u201cDo not play with fire\u201d -> Father forbade him to play with fire.",
            "Omit words like 'Hurrah', 'Alas', 'Oh' in indirect speech and capture their emotion in the reporting verb."
        ],
        "exampleQuestion": "Convert to indirect speech: The old man said, \u201cAlas! I have lost everything.\u201d",
        "exampleExplanation": "Alas expresses sorrow: 'The old man exclaimed with sorrow that he had lost everything.'",
        "exampleAnswer": "The old man exclaimed with sorrow that he had lost everything 💔",
        "funFact": "Reported speech in English mirrors the psychological distance of the narrator from the original event!",
        "mascotAdvice": "Replace emotional exclamations with vivid reporting phrases: 'exclaimed with delight' or 'cried in disbelief'!",
        "activityIds": []
    },
    {
        "chapterId": "eng_c8_ch04",
        "chapterNumber": 4,
        "title": "Idioms, Proverbs & Advanced Vocabulary",
        "grade": "Class 8",
        "board": "all",
        "subjectId": "english",
        "icon": "💡",
        "description": "Enrich your writing with figurative idioms, timeless proverbs, foreign loanwords, and collocations!",
        "keyConcepts": ["Idioms & Figurative Meanings", "Timeless Proverbs", "Prefixes & Suffixes (un-, dis-, -able, -tion)", "Common Collocations (make an effort, take a decision)"],
        "rules": [
            "An idiom's figurative meaning is completely different from its literal word-by-word meaning: 'bite the bullet' means to face a difficult situation courageously.",
            "Proverbs express universal wisdom: 'Every cloud has a silver lining' means there is always hope even in dark times.",
            "Use collocations naturally: We say 'make a mistake' (not 'do a mistake') and 'take an exam' (not 'give an exam')."
        ],
        "exampleQuestion": "What does the idiom 'once in a blue moon' mean?",
        "exampleExplanation": "A blue moon happens very rarely (a second full moon in a month). So 'once in a blue moon' means something that happens very rarely!",
        "exampleAnswer": "Very rarely / Almost never 🌕",
        "funFact": "A genuine astronomical 'blue moon' only occurs once roughly every 2.7 years!",
        "mascotAdvice": "Never take idioms literally! Picture the metaphor in your mind to guess the real meaning.",
        "activityIds": []
    }
]

out_path = "d:/AI Learning/assets/curriculum/english_chapters.json"
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(chapters, f, indent=2, ensure_ascii=False)

print(f"Successfully generated {len(chapters)} English chapters to {out_path}!")
