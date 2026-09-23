// scripts/curriculum_c4_c5.js
const { makeCh } = require('./curriculum_base');

const list = [];

// =========================================================================
// CLASS 4 - CBSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c4_cbse_01', 1, 'Sentences: Subject and Predicate', 'Class 4', 'cbse', '🧩',
    'Every complete sentence has two vital halves: the Subject (who or what) and the Predicate (what they do)!',
    ['Subject (who or what the sentence is about)', 'Predicate (contains the verb and tells about subject)', 'Complete Thoughts', 'Fragments vs Sentences'],
    ["The Subject names who or what performs the action.", "The Predicate begins with the verb and tells what the subject is or does.", "Example: [The brave firefighter] (Subject) [rescued the scared cat] (Predicate)."],
    "Identify the Subject in: 'The brave firefighter rescued the scared cat.'",
    "Ask: Who performed the action of rescuing? 'The brave firefighter' is the complete subject!",
    "The brave firefighter 🚒",
    "In command sentences like 'Sit down!', the subject is silently understood to be '(You)'!",
    "Find the verb first! Everything before it answering 'who?' is your subject."
  ),
  makeCh(
    'eng_c4_cbse_02', 2, 'Nouns: Collective and Material Nouns', 'Class 4', 'cbse', '🏛️',
    'Identify collective group names (crew, bouquet) and material nouns (gold, wood, cotton) from nature!',
    ['Collective Nouns (colony of ants, bouquet of flowers)', 'Material Nouns (wood, iron, cotton, milk)', 'Countable vs Uncountable', 'Grammar Agreement'],
    ["A Material Noun names a raw substance or matter from which things are made: gold, silk, timber.", "Material nouns are generally uncountable and do not take 'a' or 'an': We say 'gold is precious' (not 'a gold')."],
    "Identify the Material Noun in: 'The carpenter crafted a sturdy table from oak wood.'",
    "'Wood' is the raw material used to construct the table, so 'wood' is the material noun!",
    "Oak wood 🪵",
    "Gold is so ductile that a single ounce can be stretched into a thin wire over 80 kilometers long!",
    "Ask: Is it the substance something is made of? If yes, it's a Material Noun!"
  ),
  makeCh(
    'eng_c4_cbse_03', 3, 'Verbs: Helping Verbs & Simple Past Irregular Verbs', 'Class 4', 'cbse', '⏳',
    'Master primary helping verbs (has, have, had, was, were) and irregular past tense transformations!',
    ['Primary Auxiliaries (has, have, had)', 'Past tense of irregular verbs (fly -> flew, write -> wrote)', 'Base form vs Past form', 'Time Markers in Sentences'],
    ["Has and Have show present possession or action; Had shows past.", "Irregular verbs do not end in -ed in the past tense: bring -> brought, buy -> bought, catch -> caught."],
    "What is the past tense of the irregular verb 'catch'?",
    "The past tense of 'catch' is 'caught' (not 'catched')!",
    "Caught 🎣",
    "English irregular verbs are survivors from ancient Germanic 'strong verbs' that changed vowel sounds!",
    "Never add '-ed' to catch, teach, or bring: catch becomes caught, teach becomes taught!"
  ),
  makeCh(
    'eng_c4_cbse_04', 4, 'Adverbs: Modifying Verbs (Manner, Time & Place)', 'Class 4', 'cbse', '⚡',
    'Discover words that tell HOW (slowly), WHEN (yesterday), and WHERE (everywhere) an action happened!',
    ['Adverbs of Manner (how: quickly, softly)', 'Adverbs of Time (when: now, soon, tomorrow)', 'Adverbs of Place (where: outside, here)', 'Forming adverbs with -ly'],
    ["An Adverb tells more about a verb, an adjective, or another adverb.", "Most adverbs of manner are formed by adding '-ly' to adjectives: slow -> slowly.", "Beware of exceptions: fast remains 'fast' (never 'fastly')!"],
    "In 'The tortoise walked slowly along the path', which word is the adverb?",
    "'Slowly' describes HOW the tortoise walked (manner). So 'slowly' is the adverb!",
    "Slowly 🐢",
    "The word 'well' is the adverb form of the adjective 'good': 'He plays well', not 'He plays good'!",
    "Ask: How was it done? When was it done? Where was it done? That word is an adverb!"
  ),
  makeCh(
    'eng_c4_cbse_05', 5, 'Pronouns: Relative and Possessive (Mine, Yours, Whose)', 'Class 4', 'cbse', '🏷️',
    'Show ownership without apostrophes (mine, ours, theirs) and link descriptions with who, which, and that!',
    ['Possessive Pronouns (mine, yours, his, hers, ours, theirs)', 'Possessive Adjectives vs Pronouns', 'Relative Pronouns (who, which, that)', "Avoiding 'it's' vs 'its' errors"],
    ["Possessive pronouns stand alone without a noun after them: 'This bag is mine' (not 'my').", "'Its' shows possession (The dog wagged its tail). 'It's' is short for 'it is'!", "Use 'who' for people, and 'which' or 'that' for animals and objects."],
    "Fill in the blank: 'This book belongs to Ria. It is ______.'",
    "The possessive pronoun replacing 'Ria's book' is 'hers'.",
    "Hers 📖",
    "Possessive pronouns NEVER have apostrophes: yours, hers, ours, theirs, its are all apostrophe-free!",
    "If you can replace it with 'it is', write 'it's'. If it shows ownership, write 'its'!"
  ),
  makeCh(
    'eng_c4_cbse_06', 6, 'Conjunctions & Compound Sentences', 'Class 4', 'cbse', '🔗',
    'Combine sentences using coordinating conjunctions (for, and, nor, but, or, yet, so) with correct commas!',
    ['Compound Sentences', 'Coordinating Conjunctions (FANBOYS)', 'Comma before Conjunction', 'Avoiding Run-on Sentences'],
    ["A compound sentence joins two complete independent clauses using a conjunction.", "Place a comma before the conjunction when joining two complete sentences: I wanted to go, but it was raining."],
    "Join into a compound sentence: 'Rohan likes cricket. His brother prefers football.'",
    "Join the contrasting sentences with 'but': 'Rohan likes cricket, but his brother prefers football.'",
    "Rohan likes cricket, but his brother prefers football 🏏",
    "Remember the mnemonic FANBOYS: For, And, Nor, But, Or, Yet, So!",
    "Two complete thoughts need glue (conjunction) and a pause (comma) to join!"
  ),
  makeCh(
    'eng_c4_cbse_07', 7, 'Prepositions of Movement and Direction', 'Class 4', 'cbse', '🧭',
    'Express movement with prepositions: through the tunnel, across the street, into the room, and along the path!',
    ['Into and Out of', 'Through and Across', 'Along and Around', 'Towards and Away from'],
    ["Use 'into' for movement entering a boundary: He walked into the classroom.", "Use 'along' for moving in a line parallel to something: We walked along the beach.", "Use 'through' for moving within an enclosed 3D space: driving through a tunnel."],
    "Which preposition completes: 'The brave horse jumped ______ the tall fence.'",
    "When clearing something from above to the other side, we use 'over'!",
    "Over the fence 🐎",
    "Prepositions of movement almost always accompany motion verbs like run, jump, walk, and dive!",
    "Picture the motion: into goes inside, over goes above, through goes within!"
  ),
  makeCh(
    'eng_c4_cbse_08', 8, 'Vocabulary: Synonyms, Antonyms & Homophones', 'Class 4', 'cbse', '🧠',
    'Expand word power with identical meanings (synonyms), opposites (antonyms), and tricky twin sounds (homophones)!',
    ['Synonyms (happy/joyful, huge/enormous)', 'Antonyms (ancient/modern, brave/cowardly)', 'Homophones (sun/son, sea/see, pair/pear)', 'Context Clues'],
    ["Synonyms are words with nearly identical meanings.", "Antonyms are words with opposite meanings.", "Homophones sound the exact same but have different spellings and meanings: 'hear' (with ear) vs 'here' (place)."],
    "Which word is an antonym (opposite) of 'Ancient'?",
    "'Ancient' means very old from long ago. Its direct opposite is 'Modern' or 'New'.",
    "Modern 🏙️",
    "The word 'set' has over 400 different dictionary meanings, making it one of the most flexible words in English!",
    "Break homophones down: 'hear' has 'ear' inside it, reminding you that you hear with your ear!"
  ),
  makeCh(
    'eng_c4_cbse_09', 9, 'Punctuation: Commas in Lists and Quotations', 'Class 4', 'cbse', '✍️',
    'Learn to use commas to separate series of items, introductory phrases, and direct speech dialogue!',
    ['Commas in a series (apples, bananas, and oranges)', 'Commas after introductory words (Yes, However)', 'Commas before quotation marks', 'Apostrophes in Contractions'],
    ["Use commas to separate three or more items in a list: I bought pencils, erasers, and a ruler.", "In direct speech, place a comma before the opening quotation mark: She said, “I am ready.”"],
    "Punctuate correctly: 'I need to buy paper pens glue and scissors.'",
    "Insert commas to separate items: 'I need to buy paper, pens, glue, and scissors.'",
    "I need to buy paper, pens, glue, and scissors ✂️",
    "The comma after the penultimate item before 'and' is called the famous Oxford Comma!",
    "Read your list aloud: whenever you take a tiny breath between items, place a comma!"
  ),
  makeCh(
    'eng_c4_cbse_10', 10, 'Tenses: Simple Present vs Present Continuous', 'Class 4', 'cbse', '🔄',
    'Distinguish between habits/facts (Simple Present) and actions happening right this second (Present Continuous)!',
    ['Simple Present for regular habits and universal truths (The sun rises)', 'Present Continuous with is/are + ing for ongoing action (is playing)', 'Key Time Markers (always, everyday vs now, currently)', 'Verb Conjugation'],
    ["Simple Present expresses habits or facts: I drink milk every morning.", "Present Continuous expresses action in progress now: I am drinking milk right now.", "Do not use -ing for state verbs like know, believe, like."],
    "Fill in the blank: 'Look! The peacock ______ (dance) in the rain.'",
    "'Look!' shows the action is happening right now in front of our eyes: use Present Continuous 'is dancing'!",
    "Is dancing 🦚",
    "English is one of the only languages that strictly separates ongoing action (-ing) from habitual facts!",
    "Habit or universal fact? Simple present. Happening right this second? Present continuous (-ing)!"
  ),
  makeCh(
    'eng_c4_cbse_11', 11, 'Idioms & Everyday Expressions', 'Class 4', 'cbse', '💡',
    'Understand common figurative expressions like a piece of cake, raining cats and dogs, and break a leg!',
    ['What is an Idiom?', 'Literal vs Figurative Meaning', 'Common Idioms in Storybooks', 'Using Idioms in Speech'],
    ["An idiom has a figurative meaning that cannot be understood from the literal words alone.", "'A piece of cake' means very easy; 'Raining cats and dogs' means raining very heavily."],
    "What does the idiom 'a piece of cake' mean in 'The math test was a piece of cake'?",
    "It means the test was very easy and simple to complete!",
    "Very easy 🍰",
    "The idiom 'raining cats and dogs' dates back to 17th century England and describes torrential storms!",
    "Never visualize idioms literally: they are colorful metaphors that add spice to language!"
  ),
  makeCh(
    'eng_c4_cbse_12', 12, 'Creative Writing: Paragraph & Dialogue Writing', 'Class 4', 'cbse', '📝',
    'Draft expressive narrative paragraphs with strong topic sentences and write realistic dialogue between characters!',
    ['Writing realistic Dialogue with quotes', 'Paragraph Structure (Beginning, Middle, End)', 'Sensory Language', 'Character Voices'],
    ["When writing dialogue, start a new paragraph every time the speaker changes.", "Put the spoken words inside quotation marks with punctuation inside the quotes: “Where are you going?” asked Ravi."],
    "When a new character speaks in a story, what should the writer always do?",
    "Start a new paragraph / line to clearly signal to the reader that a new character is speaking!",
    "Start a new paragraph 💬",
    "Great writers read their dialogues out loud to ensure they sound natural and engaging!",
    "New speaker = new line! Keep your dialogue tags lively: whispered, exclaimed, or replied!"
  )
);

// =========================================================================
// CLASS 4 - ICSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c4_icse_01', 1, 'The Sentence: Subject, Predicate and Object', 'Class 4', 'icse', '🧩',
    'Deconstruct sentences into Subject, Predicate, Direct Object (answers what), and Indirect Object (answers to whom)!',
    ['Subject & Predicate', 'Direct Object (verb + what)', 'Indirect Object (verb + to whom)', 'Sentence Structure (S-V-O)'],
    ["The Direct Object receives the action of the verb directly: He threw (what?) the ball.", "The Indirect Object receives the direct object: He threw (to whom?) me the ball.", "Sentence formula: Subject + Verb + Indirect Object + Direct Object."],
    "In 'Grandmother told us an exciting story', what is the Direct Object?",
    "Ask: Grandmother told what? Answer: 'an exciting story'! That is the Direct Object ('us' is indirect object).",
    "An exciting story 📖",
    "In classical Latin and Greek grammar, objects determined whether nouns took accusative or dative cases!",
    "Ask 'What?' to find Direct Object; ask 'To whom?' to find Indirect Object!"
  ),
  makeCh(
    'eng_c4_icse_02', 2, 'Kinds of Sentences: Declarative, Interrogative, Imperative & Exclamatory', 'Class 4', 'icse', '❗',
    'Master the 4 sentence types: Assertive/Declarative, Interrogative (?), Imperative (orders/requests), and Exclamatory (!)!',
    ['Declarative / Assertive (states a fact)', 'Interrogative (asks a question)', 'Imperative (gives command, request, or advice)', 'Exclamatory (expresses strong emotion)'],
    ["Declarative ends with a full stop: The sun is hot.", "Interrogative ends with a question mark: Is it hot?", "Imperative ends with a full stop (understood subject 'you'): Please close the door.", "Exclamatory ends with an exclamation mark: What a hot day it is!"],
    "Identify the sentence type: 'Please pass the salt.'",
    "This sentence makes a polite request: it is an Imperative Sentence!",
    "Imperative Sentence 🧂",
    "Imperative sentences are the only English sentences that do not require an explicit subject written down!",
    "Look at the purpose: Statement = Declarative. Question = Interrogative. Command/Request = Imperative. Strong feeling = Exclamatory!"
  ),
  makeCh(
    'eng_c4_icse_03', 3, 'Nouns: Abstract Nouns and Formation', 'Class 4', 'icse', '🏛️',
    'Discover abstract nouns and learn how they are formed from adjectives, verbs, and common nouns using suffixes!',
    ['Abstract Nouns (qualities, states, concepts)', 'Forming from Adjectives (kind -> kindness, honest -> honesty)', 'Forming from Verbs (grow -> growth, think -> thought)', 'Forming from Common Nouns (child -> childhood)'],
    ["Abstract nouns cannot be perceived by the 5 physical senses: justice, friendship, beauty.", "Add suffixes like -ness, -ity, -tion, -ship, -hood: wise -> wisdom, brave -> bravery."],
    "Form an abstract noun from the adjective 'Brave':",
    "The abstract noun of quality derived from 'brave' is 'Bravery'!",
    "Bravery 🛡️",
    "Abstract nouns are essential in philosophy, law, and science to discuss ideas that have no physical shape!",
    "Add -ness (darkness), -hood (brotherhood), or -dom (freedom) to create abstract nouns!"
  ),
  makeCh(
    'eng_c4_icse_04', 4, 'Pronouns: Emphatic, Reflexive & Relative Pronouns', 'Class 4', 'icse', '👥',
    'Differentiate between Reflexive pronouns (action reflects back on subject) and Emphatic pronouns (for emphasis)!',
    ['Reflexive Pronouns (myself, himself, herself, themselves)', 'Emphatic Pronouns (I myself solved it)', 'Relative Pronouns (who, whom, whose, which, that)', 'Distinguishing Reflexive vs Emphatic'],
    ["A Reflexive pronoun shows that the doer and receiver are the same person: He hurt himself.", "An Emphatic pronoun merely emphasizes a noun and can be removed without ruining sentence sense: The President himself arrived.", "Relative pronouns connect clauses: The girl who won the prize is my sister."],
    "In 'The Queen herself attended the ceremony', is 'herself' Reflexive or Emphatic?",
    "If you remove 'herself', the sentence still makes complete sense ('The Queen attended...'). It adds emphasis, so it is Emphatic!",
    "Emphatic Pronoun 👑",
    "Test for Emphatic: remove the self-word! If the sentence still makes sense, it's Emphatic; if it collapses, it's Reflexive!",
    "Action turns back on subject = Reflexive (cut himself). Simply highlighting = Emphatic (did it himself)!"
  ),
  makeCh(
    'eng_c4_icse_05', 5, 'Adjectives: Kinds & Correct Use of Degrees', 'Class 4', 'icse', '📏',
    'Master proper adjective classification and avoid double comparatives (more better) and double superlatives!',
    ['Adjectives of Quality, Quantity & Number', 'Demonstrative & Interrogative Adjectives', 'Rules for Comparison', 'Avoiding Double Comparatives'],
    ["Never use double comparatives: say 'better' (not 'more better') and 'fastest' (not 'most fastest').", "When comparing two things, use the comparative degree: Of the two brothers, Rohan is the taller."],
    "Correct the error: 'This is the most sweetest mango I have ever tasted.'",
    "Remove 'most' because 'sweetest' is already superlative: 'This is the sweetest mango...'!",
    "The sweetest mango 🥭",
    "In Elizabethan English, double superlatives were acceptable (Shakespeare wrote 'most unkindest cut of all'), but modern grammar forbids them!",
    "Never mix 'more' with -er, or 'most' with -est: choose one or the other!"
  ),
  makeCh(
    'eng_c4_icse_06', 6, 'Verbs: Transitive & Intransitive Verbs with Objects', 'Class 4', 'icse', '⚡',
    'Analyze verbs with complete sense, verbs of incomplete predication (linking verbs), and transitive objects!',
    ['Transitive Verbs & Direct Objects', 'Intransitive Verbs of Complete Predication', 'Intransitive Verbs of Incomplete Predication (linking verbs/complements)', 'Subject Complements'],
    ["A linking verb (be, become, seem, look) is intransitive of incomplete predication; what follows is a Subject Complement, not an object: He is a doctor.", "A transitive verb requires an object: He hit the ball."],
    "In 'The sky grew dark', what grammatical role does 'dark' play?",
    "'Dark' describes the subject 'sky' after the linking verb 'grew': it is a Subject Complement!",
    "Subject Complement ☁️",
    "Linking verbs act like equal signs in math: 'The sky = dark'!",
    "Does the verb link the subject to an adjective/noun? That's a complement, not an object!"
  ),
  makeCh(
    'eng_c4_icse_07', 7, 'Subject-Verb Agreement: Basic Rules', 'Class 4', 'icse', '⚖️',
    'Ensure perfect harmony between subject and verb: singular subjects take singular verbs with -s, plural take base verbs!',
    ['Singular Subject + Singular Verb (-s)', 'Plural Subject + Plural Verb', 'Two subjects joined by "and"', 'Collective Nouns as Singular Units'],
    ["A singular subject requires a singular verb ending in -s: The bird flies.", "A plural subject requires a plural verb without -s: The birds fly.", "When two singular subjects are joined by 'and', use a plural verb: Maya and Sita are sisters."],
    "Choose the correct verb: 'A bouquet of yellow roses ______ (was / were) presented to the chief guest.'",
    "The real subject is the singular collective noun 'bouquet' (not 'roses'): use singular 'was'!",
    "Was presented 💐",
    "English has this curious mirror rule: Nouns add -s to become plural, but Verbs add -s to become singular!",
    "Look at the head noun: 'bouquet' is singular, so it takes singular 'was'!"
  ),
  makeCh(
    'eng_c4_icse_08', 8, 'Tenses: Simple and Continuous Forms', 'Class 4', 'icse', '🔄',
    'Conjugate verbs across Simple and Continuous aspects in Present, Past, and Future tenses!',
    ['Simple Present, Past & Future', 'Present Continuous (is/are + verb-ing)', 'Past Continuous (was/were + verb-ing)', 'Future Continuous (will be + verb-ing)'],
    ["Past Continuous describes an ongoing action interrupted in the past: I was reading when the phone rang.", "Future Continuous describes what will be ongoing at a specific time: Tomorrow at 4 PM, we will be flying to Mumbai."],
    "Complete with Past Continuous: 'While father was cooking, mother ______ (wash) the dishes.'",
    "Mother (singular) + was + washing: 'was washing'.",
    "Was washing 🍽️",
    "The continuous aspect gives readers a 'you are there' feeling of live action unfolding!",
    "Continuous always requires a form of 'be' (is, was, will be) + verb with '-ing'!"
  ),
  makeCh(
    'eng_c4_icse_09', 9, 'Adverbs: Formation and Degrees of Comparison', 'Class 4', 'icse', '⚡',
    'Form adverbs from adjectives and compare how actions are performed using positive, comparative, and superlative degrees!',
    ['Forming Adverbs (happy -> happily, gentle -> gently)', 'Degrees of Comparison of Adverbs (hard, harder, hardest)', 'Adverbs with more/most (carefully, more carefully, most carefully)', 'Irregular Adverbs (well, better, best; badly, worse, worst)'],
    ["Like adjectives, adverbs have three degrees of comparison: fast, faster, fastest.", "Adverbs ending in -ly use 'more' and 'most': clearly, more clearly, most clearly.", "Irregular comparison: well -> better -> best."],
    "Fill in the blank: 'Of all the runners in the final race, Arjun ran the ______ (fast).' ",
    "Comparing all runners (superlative), we use 'fastest'!",
    "Fastest 🏃",
    "Never say 'fastly': 'fast' functions as both an adjective and an adverb in English!",
    "Comparing two actions = more carefully. Comparing all actions = most carefully!"
  ),
  makeCh(
    'eng_c4_icse_10', 10, 'Prepositions: Correct Usage & Confusing Pairs', 'Class 4', 'icse', '🧭',
    'Master tricky pairs: Beside vs Besides, Between vs Among, Since vs For, In vs Into!',
    ['Beside (by the side of) vs Besides (in addition to)', 'Between (two) vs Among (more than two)', 'Since (point in time) vs For (duration)', 'In (state of rest) vs Into (state of motion)'],
    ["'Beside' means next to: Sit beside me. 'Besides' means in addition to: Besides English, she speaks French.", "'Since' marks the starting point of time: since morning. 'For' marks the duration: for three hours."],
    "Fill in the blank: '______ playing the violin, Anita is an outstanding chess player.'",
    "The sentence means 'in addition to playing violin', so we use 'Besides'!",
    "Besides 🎻",
    "A single letter 's' completely changes the meaning: beside = next to; besides = in addition to!",
    "Check: Does it mean next to? Use beside. Does it mean in addition to? Use besides!"
  ),
  makeCh(
    'eng_c4_icse_11', 11, 'Figures of Speech: Similes and Metaphors', 'Class 4', 'icse', '🦁',
    'Explore figurative comparisons: explicit comparisons with like/as (Simile) and direct implicit comparisons (Metaphor)!',
    ['Simile (using like or as)', 'Metaphor (direct implicit comparison without like/as)', 'Converting Simile to Metaphor', 'Appreciation of Poetic Imagery'],
    ["A Simile says one thing is LIKE another: 'He is as brave as a lion.'", "A Metaphor says one thing IS another: 'He is a lion in battle.'", "Metaphors create stronger, more condensed figurative impact."],
    "Identify the figure of speech: 'The classroom was a zoo during recess.'",
    "It directly calls the classroom a zoo without using 'like' or 'as': this is a Metaphor!",
    "Metaphor 🏫",
    "Metaphor comes from Greek 'metapherein' meaning 'to carry over' qualities from one object to another!",
    "If it has 'like' or 'as', it's a Simile. If it directly equates them, it's a Metaphor!"
  ),
  makeCh(
    'eng_c4_icse_12', 12, 'Formal Writing: Informal Letters & Descriptive Essay Outline', 'Class 4', 'icse', '✉️',
    'Master structural letter conventions (address, date, greeting, body, subscription) and brainstorm essay outlines!',
    ['Parts of an Informal Letter', 'Paragraph Transitions in Letters', 'Brainstorming Essay Outlines (Mind Maps)', 'Descriptive Vocabulary & Sensory Details'],
    ["Address and date appear on the top left.", "The body of the letter should have three paragraphs: opening inquiry, main news/message, and warm closing.", "End with appropriate subscription: 'Yours affectionately'."],
    "In an informal letter, which subscription is most appropriate for a cousin or dear friend?",
    "'Yours affectionately' or 'Your loving friend' is warm, polite, and standard for informal letters!",
    "Yours affectionately ✉️",
    "The British penny post system, launched in 1840, was the first affordable nationwide letter service in the world!",
    "Plan your essay like a journey: Introduction (destination), Body (scenery and stops), Conclusion (safe arrival)!"
  )
);

// =========================================================================
// CLASS 5 - CBSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c5_cbse_01', 1, 'Continuous and Perfect Tenses (Present & Past)', 'Class 5', 'cbse', '🔄',
    'Master ongoing actions (-ing continuous) and completed accomplishments (has/have/had + past participle)!',
    ['Present Continuous (is/are + verb-ing)', 'Past Continuous (was/were + verb-ing)', 'Present Perfect (has/have + V3)', 'Past Perfect (had + V3)'],
    ["Continuous tenses describe actions in progress at that moment: She is studying.", "Present Perfect connects past actions to now: I have finished my homework.", "Use 'has' with singular subjects (He, She, It) and 'have' with plural subjects (I, You, We, They)."],
    "Fill in the blank: 'We ______ (live) in this city for five years now.'",
    "The action started in the past and continues up to the present: use Present Perfect 'have lived'.",
    "Have lived 🏡",
    "English is one of the few languages with a distinct continuous tense using '-ing' for immediate actions!",
    "Has/Have + 3rd form (V3) = action finished with impact on the present!"
  ),
  makeCh(
    'eng_c5_cbse_02', 2, 'Subject-Verb Agreement Rules', 'Class 5', 'cbse', '⚖️',
    'Ensure harmony in your sentences: singular subjects take singular verbs, and plural subjects take plural verbs!',
    ['Singular Subject = Singular Verb (with -s: runs, eats)', 'Plural Subject = Plural Verb (without -s: run, eat)', 'Either/Or & Neither/Nor Rules', 'Collective Nouns Agreement'],
    ["A singular noun takes a singular verb ending in -s or -es: The train arrives at 5 PM.", "A plural noun takes a plural verb without -s: The trains arrive at 5 PM.", "When two subjects are joined by 'and', use a plural verb: Bread and butter are on the table."],
    "Choose the correct verb: 'Neither the teacher nor the students ______ present.'",
    "When subjects are joined by 'neither...nor', the verb agrees with the subject closest to it ('students' is plural -> 'were').",
    "Were 🏫",
    "Notice the opposite rule: Nouns add -s to become plural (dogs), but Verbs add -s to become singular (runs)!",
    "Singular subject needs an 's' on the present tense verb: He walks, She sings, It works!"
  ),
  makeCh(
    'eng_c5_cbse_03', 3, 'Direct and Indirect Speech Introduction', 'Class 5', 'cbse', '💬',
    'Learn the difference between quoting exact spoken words with quotation marks versus reporting the message!',
    ['Direct Speech with Quotation Marks (“...”)', 'Indirect / Reported Speech', "Removing Quotation Marks with 'that'", 'Changing Pronouns (I -> he/she)'],
    ["Direct Speech quotes the speaker's exact words inside speech marks: She said, “I am hungry.”", "Indirect Speech reports what was said without quotation marks: She said that she was hungry.", "In indirect speech, the present tense often steps back into the past tense."],
    "Convert to indirect: Rohan said, “I like ice cream.”",
    "Remove quotes, add 'that', change 'I' to 'he', and step present 'like' back to past 'liked': Rohan said that he liked ice cream.",
    "Rohan said that he liked ice cream 🍦",
    "Speech marks are also called inverted commas or quote marks!",
    "When reporting what someone said in the past, push their words one step back in time!"
  ),
  makeCh(
    'eng_c5_cbse_04', 4, 'Active and Passive Voice Foundations', 'Class 5', 'cbse', '🔄',
    'Discover how the doer of the action and the receiver of the action can switch places in a sentence!',
    ['Active Voice (Subject performs action)', 'Passive Voice (Subject receives action)', 'Formula: Object + helping verb + V3 + by + Subject', 'Past Participle (V3)'],
    ["In Active Voice, the subject does the action: The chef baked the cake.", "In Passive Voice, the object becomes the subject: The cake was baked by the chef.", "Passive voice always uses a form of 'be' (is, was, were) plus the past participle (3rd form) of the verb."],
    "Turn into Passive Voice: 'Alexander Graham Bell invented the telephone.'",
    "Object 'The telephone' comes first + 'was' + V3 'invented' + 'by' + 'Alexander Graham Bell'.",
    "The telephone was invented by Alexander Graham Bell ☎️",
    "News reports and science textbooks use passive voice frequently when the result is more important than who did it!",
    "Passive formula: Object becomes Leader + Be verb + 3rd form verb + by + Doer!"
  ),
  makeCh(
    'eng_c5_cbse_05', 5, 'Determiners & Quantifiers (Much, Many, Few, Little)', 'Class 5', 'cbse', '📊',
    'Master countability determiners: Many and Few for countable nouns; Much and Little for uncountable mass nouns!',
    ['Countable Quantifiers (many, few, several)', 'Uncountable Quantifiers (much, little, a great deal of)', 'Few vs A Few (negative vs positive)', 'Little vs A Little'],
    ["Use 'many' and 'few' with countable nouns: many books, few friends.", "Use 'much' and 'little' with uncountable nouns: much milk, little patience.", "'A few' means some (positive); 'few' means almost none (negative)."],
    "Fill in the blank: 'There isn't ______ sugar left in the jar.'",
    "'Sugar' is uncountable mass noun in a negative sentence: we use 'much'!",
    "Much sugar 🍬",
    "Quantifiers are special determiners that limit and define the exact quantity of nouns in discourse!",
    "Countable items = many/few. Uncountable liquids and concepts = much/little!"
  ),
  makeCh(
    'eng_c5_cbse_06', 6, 'Conjunctions: Subordinating (Although, Because, Unless)', 'Class 5', 'cbse', '🔗',
    'Link dependent clauses to independent clauses using subordinating conjunctions: although, because, unless, since, and if!',
    ['Subordinating Conjunctions (although, unless, because, since, if)', 'Expressing Condition (unless = if not)', 'Expressing Concession (although/even though)', 'Comma rules with introductory clauses'],
    ["A subordinating conjunction introduces a dependent clause that cannot stand alone.", "'Unless' means 'if not': You will not pass unless you study.", "'Although' shows unexpected contrast: Although it rained, we enjoyed the picnic."],
    "Fill in the blank: 'You will miss the train ______ you hurry up immediately.'",
    "The condition means 'if you do not hurry': use 'unless'!",
    "Unless 🚆",
    "Subordinating conjunctions turn independent thoughts into dependent clauses that provide rich context!",
    "Unless already contains 'not' inside its meaning: never say 'unless you do not hurry'!"
  ),
  makeCh(
    'eng_c5_cbse_07', 7, 'Adverb Kinds: Frequency, Degree and Interrogative', 'Class 5', 'cbse', '⚡',
    'Explore adverbs of Frequency (always, never, rarely), Degree (very, extremely, completely), and Interrogative adverbs!',
    ['Adverbs of Frequency (always, usually, seldom, never)', 'Adverbs of Degree (extremely, quite, almost, entirely)', 'Interrogative Adverbs (when, where, why, how)', 'Placement of Adverbs in Sentences'],
    ["Adverbs of Frequency answer 'How often?' and usually sit before the main verb: He always arrives on time.", "Adverbs of Degree answer 'How much?' or 'To what extent?': It is extremely hot today."],
    "In 'She rarely eats junk food', what kind of adverb is 'rarely'?",
    "'Rarely' answers HOW OFTEN she eats junk food: it is an Adverb of Frequency!",
    "Adverb of Frequency 🥗",
    "Adverbs of degree can modify other adverbs: 'She ran very quickly' ('very' modifies adverb 'quickly')!",
    "How often = Frequency. How intense = Degree!"
  ),
  makeCh(
    'eng_c5_cbse_08', 8, 'Prepositions: Fixed Prepositional Phrases', 'Class 5', 'cbse', '🧭',
    'Master fixed combinations of verbs/adjectives with prepositions: fond of, good at, listen to, rely on, and belong to!',
    ['Adjective + Preposition (proud of, afraid of, interested in)', 'Verb + Preposition (depend on, agree with, look for)', 'Fixed Idiomatic Phrases (at once, in advance)', 'Error Correction'],
    ["Certain words take specific prepositions: 'good at' mathematics (not 'good in'), 'fond of' music (not 'fond with').", "'Rely on', 'listen to', 'congratulate on' (not 'congratulate for')."],
    "Fill in the blank: 'Kavita is exceptionally good ______ solving difficult puzzles.'",
    "For skills and talents, standard English uses 'good at': 'good at solving'!",
    "Good at 🧩",
    "Fixed prepositions are among the most tested items in competitive exams because they cannot be guessed by literal translation!",
    "Memorize in pairs: good at, afraid of, interested in, proud of!"
  ),
  makeCh(
    'eng_c5_cbse_09', 9, 'Vocabulary: Prefixes, Suffixes & Root Words', 'Class 5', 'cbse', '🧠',
    'Build thousands of words by adding prefixes (un-, dis-, im-, re-) and suffixes (-ful, -less, -able, -tion) to Latin and Greek roots!',
    ['Root Words', 'Negative Prefixes (unhappy, dishonest, impossible)', 'Action/Repetition Prefixes (replay, preview)', 'Suffixes forming Nouns & Adjectives (-ness, -ful, -less, -able)'],
    ["A Prefix is added to the beginning of a root word to alter its meaning: un + kind = unkind.", "A Suffix is added to the end of a root word to change its part of speech: care + less = careless (adjective)."],
    "Add a negative prefix to 'Possible' to form its antonym:",
    "Words starting with 'p' or 'm' usually take the prefix 'im-': 'Impossible'!",
    "Impossible 🌟",
    "Over 60% of all English vocabulary is derived from Latin and Greek root words!",
    "Prefix goes in front (pre = before); suffix attaches at the tail!"
  ),
  makeCh(
    'eng_c5_cbse_10', 10, 'Punctuation: Inverted Commas & Direct Quotes', 'Class 5', 'cbse', '✍️',
    'Master punctuation inside and outside quotation marks: commas, capital letters, question marks, and dialogue tags!',
    ['Opening and Closing Speech Marks (“ ”)', 'Comma before Dialogue Tag', 'Terminal punctuation inside quotes', 'Split Dialogues (“Yes,” said Tina, “I will come.”)'],
    ["Inverted commas enclose the exact spoken words.", "Punctuation marks like full stops and commas belong INSIDE the closing quotation mark: “I love reading,” said Ananya.", "The first word inside the quote starts with a Capital letter."],
    "Which sentence is punctuated correctly according to standard rules?",
    "“The match will begin at three,” announced the referee. (Comma inside quotation mark)",
    "“The match will begin at three,” announced the referee. ⏱️",
    "British English traditionally used single quotes ('...'), while American English used double quotes (“...”), but double quotes are now standard internationally!",
    "Punctuation goes inside the quote hug: “Hello,” said the bear!"
  ),
  makeCh(
    'eng_c5_cbse_11', 11, 'Reading Comprehension: Main Idea & Inference', 'Class 5', 'cbse', '📖',
    'Read non-fiction articles and classic stories, distinguish fact from opinion, and make logical inferences from subtle text clues!',
    ['Main Idea vs Supporting Details', 'Fact vs Opinion', 'Making Logical Inferences', 'Vocabulary in Context'],
    ["A Fact can be proven true by evidence: The Earth orbits the Sun.", "An Opinion expresses a personal belief or feeling: Chocolate ice cream is the best.", "An Inference is reading between the lines using clues."],
    "Identify whether this statement is a Fact or an Opinion: 'Cheetahs can run at speeds over 100 km/h.'",
    "This is a scientifically measured and verified biological truth: it is a Fact!",
    "Fact 🐆",
    "Critical reading skills developed in comprehension passages are the foundation of scientific and analytical thinking!",
    "Always look for proof in the text: can it be proven? Fact! Is it someone's personal taste? Opinion!"
  ),
  makeCh(
    'eng_c5_cbse_12', 12, 'Informal Letter & Story Writing with Prompts', 'Class 5', 'cbse', '📝',
    'Write heartfelt informal letters to family and compose original stories using picture prompts, conflict, and satisfying resolutions!',
    ['Informal Letter Format & Tone', 'Story Elements (Setting, Character, Problem, Climax, Resolution)', 'Using Dialogue in Stories', 'Sensory Description'],
    ["Every compelling story needs a central problem or conflict that characters must solve.", "Build suspense towards a climax before reaching the ending resolution.", "Use expressive verbs and descriptive adjectives rather than repetitive words."],
    "In a story plot, what is the highest, most exciting turning point called?",
    "The most thrilling moment of maximum tension before the mystery is solved is the 'Climax'!",
    "Climax ⚡",
    "Storytelling is humanity's oldest art form, passed down around campfires for tens of thousands of years!",
    "Story formula: Character wants something -> Facing an obstacle -> Brave action -> Resolution!"
  )
);

// =========================================================================
// CLASS 5 - ICSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c5_icse_01', 1, 'Nouns: Classification, Gender & Abstract Formation', 'Class 5', 'icse', '🏛️',
    'Deepen understanding of all five noun classes, feminine/masculine derivations, and suffix-based abstract noun formation!',
    ['Proper, Common, Collective, Material & Abstract Nouns', 'Noun Genders & Formation of Feminines (-ess, entirely different words)', 'Abstract Nouns from Adjectives, Verbs & Common Nouns', 'Countable vs Uncountable Syntax'],
    ["Feminine forms can be made by adding '-ess' (author -> authoress, lion -> lioness), by using an entirely different word (monk -> nun, king -> queen), or by changing prefix/suffix (he-goat -> she-goat).", "Abstract nouns represent intangible concepts."],
    "What is the feminine counterpart of the noun 'Monk'?",
    "The female religious counterpart of a monk is a 'Nun'!",
    "Nun 🏛️",
    "The word 'noun' itself comes from Latin 'nomen', meaning 'name'!",
    "Countable nouns can take 'a/an' and numbers (three books); uncountable cannot (water, information)!"
  ),
  makeCh(
    'eng_c5_icse_02', 2, 'Pronouns: Reciprocal, Indefinite & Distributive', 'Class 5', 'icse', '👥',
    'Classify advanced pronouns: Distributive (each, either, neither), Indefinite (somebody, none), and Reciprocal (each other, one another)!',
    ['Distributive Pronouns (each, either, neither take singular verbs)', 'Indefinite Pronouns (all, some, none, everyone)', 'Reciprocal Pronouns (each other for two, one another for three or more)', 'Pronoun Case Harmony'],
    ["'Each other' is used when two persons are involved: The two brothers helped each other.", "'One another' is used when more than two persons are involved: The three friends helped one another.", "Distributive pronouns are always grammatically singular: Each of the boys has a book."],
    "Fill in the blank: 'The twin sisters always support ______ in times of difficulty.'",
    "Because there are exactly two people (twin sisters), we use 'each other'!",
    "Each other 👭",
    "Indefinite pronouns like 'everybody' and 'someone' are singular in formal grammar: 'Everybody has brought his/her lunch'!",
    "Two people = each other. Three or more = one another. Each/Either/Neither = singular verb!"
  ),
  makeCh(
    'eng_c5_icse_03', 3, 'Verbs: Strong and Weak Verbs & Conjugations', 'Class 5', 'icse', '⚡',
    'Categorize verbs into Weak Verbs (form past by adding -d, -ed, -t) and Strong Verbs (form past by changing root vowel)!',
    ['Weak / Regular Verbs (walk/walked, build/built, spend/spent)', 'Strong / Irregular Verbs (sing/sang/sung, drive/drove/driven)', 'The Three Principal Forms: Present (V1), Past (V2), Past Participle (V3)', 'Verbs with identical three forms (cut/cut/cut, put/put/put)'],
    ["Weak verbs form their past tense by adding 'd', 'ed', or 't' to the present: burn -> burnt, call -> called.", "Strong verbs form their past tense by modifying their internal vowel without adding an ending: drive -> drove -> driven.", "Some verbs have identical forms: hit, cost, hurt, shut."],
    "What are the three principal forms (V1, V2, V3) of the strong verb 'Begin'?",
    "Present: Begin (V1), Past: Began (V2), Past Participle: Begun (V3)!",
    "Begin, Began, Begun ⏳",
    "Strong verbs represent the oldest ancestral core of English vocabulary, preserved across millennia!",
    "Always check the vowel: sing -> sang -> sung; ring -> rang -> rung; swim -> swam -> swum!"
  ),
  makeCh(
    'eng_c5_icse_04', 4, 'Tenses: Present, Past and Future Perfect Forms', 'Class 5', 'icse', '⏳',
    'Master perfect aspects: Present Perfect (has/have + V3), Past Perfect (had + V3), and Future Perfect (will have + V3)!',
    ['Present Perfect (action completed with present link)', 'Past Perfect (the earlier of two past actions)', 'Future Perfect (action completed by a specific future deadline)', 'Time Prepositions (already, just, by 5 PM)'],
    ["Past Perfect describes an action completed BEFORE another past action: The train had left before we reached the station.", "Future Perfect describes an action that will be completed by a deadline: I will have finished my project by Monday."],
    "Combine using Past Perfect: 'The doctor arrived. The patient died before that.'",
    "'The patient had died before the doctor arrived.' (Had died happened earlier in past).",
    "The patient had died before the doctor arrived 🏥",
    "Past Perfect is often called the 'pluperfect' or 'past of the past' by grammarians!",
    "When two past actions occur, the FIRST one gets 'had + V3'; the later one gets simple past!"
  ),
  makeCh(
    'eng_c5_icse_05', 5, 'Agreement of Subject and Verb: Special Cases', 'Class 5', 'icse', '⚖️',
    'Navigate tricky concord rules: either...or, neither...nor, as well as, along with, and nouns plural in form but singular in meaning!',
    ['Either...or / Neither...nor (verb agrees with nearer subject)', 'Phrases like "along with", "as well as", "in addition to"', 'Plural looking nouns (mathematics, news, physics)', 'Amounts of money and periods of time as single units'],
    ["When subjects are joined by 'as well as' or 'along with', the verb agrees with the FIRST subject: The teacher, along with the students, was present.", "Words like 'Mathematics' and 'News' are singular: Mathematics is interesting."],
    "Choose the correct verb: 'The captain, as well as his crew members, ______ (was / were) awarded a medal.'",
    "The verb agrees with the primary subject 'The captain' (singular): use 'was'!",
    "Was awarded 🎖️",
    "The grammatical principle here is that parenthetical phrases introduced by 'as well as' do not compound the subject!",
    "Ignore what is inside commas: 'The captain [as well as his crew] WAS awarded'!"
  ),
  makeCh(
    'eng_c5_icse_06', 6, 'Active and Passive Voice: Simple Present and Past', 'Class 5', 'icse', '🔄',
    'Convert sentences between Active and Passive voice in Simple Present (is/are + V3) and Simple Past (was/were + V3)!',
    ['Active to Passive conversion formula', 'Subject-Object inversion', 'Selection of auxiliary verbs (am/is/are for present, was/were for past)', 'Retention of meaning and tense'],
    ["Formula: Object + appropriate 'be' verb + Past Participle (V3) + by + Subject.", "Present: He writes a letter -> A letter is written by him.", "Past: He wrote a letter -> A letter was written by him."],
    "Convert to Passive: 'The gardener planted these beautiful flowers.'",
    "'These beautiful flowers' (plural) + 'were' (past) + 'planted' (V3) + 'by the gardener'.",
    "These beautiful flowers were planted by the gardener 🌸",
    "Passive voice was extensively cultivated by Roman legal scholars and British civil servants for formal documentation!",
    "Plural object needs plural be-verb: 'flowers were planted', not 'flowers was planted'!"
  ),
  makeCh(
    'eng_c5_icse_07', 7, 'Direct and Indirect Speech: Assertive Sentences', 'Class 5', 'icse', '💬',
    'Learn formal rules of indirect narration: tense backshift, change of personal pronouns, and adverbial shifts of time and place!',
    ['Reporting Verb (said / told)', "Conjunction 'that'", 'Tense Changes (Simple Present -> Simple Past, Present Continuous -> Past Continuous)', 'Time and Place Changes (now -> then, here -> there, today -> that day)'],
    ["If reporting verb is in past tense ('said'), direct speech tenses step back: 'I am' becomes 'he was'.", "Said to + object becomes 'told': She said to me -> She told me.", "Today becomes that day; yesterday becomes the previous day."],
    "Convert to indirect speech: Ravi said, “I am writing a letter today.”",
    "Ravi said that he was writing a letter that day.",
    "Ravi said that he was writing a letter that day ✉️",
    "Universal truths NEVER change tense: Teacher said, “The earth rotates” -> Teacher said that the earth rotates!",
    "Backshift check: am -> was, have -> had, will -> would, today -> that day!"
  ),
  makeCh(
    'eng_c5_icse_08', 8, 'Prepositions: Tricky Pairs (Between/Among, Beside/Besides)', 'Class 5', 'icse', '🧭',
    'Examine precise prepositional nuances: beside/besides, between/among, in/at for places, and by/with for instruments and agents!',
    ['Beside vs Besides', 'Between vs Among', 'In vs At (at small towns/exact spots, in large cities/countries)', 'By (the agent/doer) vs With (the instrument used)'],
    ["Use 'by' for the person who does the action: The tiger was shot by the hunter.", "Use 'with' for the instrument or weapon used: The tiger was shot with a rifle.", "Live at a village, but live in a major nation or metropolis."],
    "Fill in the blanks: 'The tree was cut down ______ the lumberjack ______ a sharp axe.'",
    "The doer is the lumberjack ('by'), and the instrument is the axe ('with'): 'by the lumberjack with a sharp axe'!",
    "By the lumberjack with an axe 🪓",
    "English legal precision requires distinct prepositions for human agency (by) versus mechanical tools (with)!",
    "By = the person/doer. With = the tool/instrument in their hands!"
  ),
  makeCh(
    'eng_c5_icse_09', 9, 'Figures of Speech: Personification and Alliteration', 'Class 5', 'icse', '🎭',
    'Enrich literary appreciation with Personification (giving human traits to non-human things) and Alliteration (repetition of initial consonant sounds)!',
    ['Personification (attributing human qualities to animals, objects, nature)', 'Alliteration (repetition of initial consonant sounds in nearby words)', 'Poetic Effect & Musicality', 'Spotting in Poetry'],
    ["Personification gives human feelings or actions to non-human things: The wind whispered through the trees.", "Alliteration repeats the same starting sound: Peter Piper picked a peck of pickled peppers."],
    "Identify the figure of speech: 'The angry storm pounded furiously against our door.'",
    "A storm cannot literally feel anger or pound like a person: nature is given human emotions, so it is Personification!",
    "Personification ⛈️",
    "Alliteration was the core rhythmic mechanism of Old English poetry before rhyming was introduced!",
    "Human feelings given to an object = Personification. Tongue-twisting repeated sound = Alliteration!"
  ),
  makeCh(
    'eng_c5_icse_10', 10, 'Vocabulary: Idiomatic Expressions & Phrasal Verbs', 'Class 5', 'icse', '💡',
    'Master idiomatic expressions (burn the midnight oil, hit the nail on the head) and phrasal verbs (look after, give up, break down)!',
    ['Figurative Idioms', 'Phrasal Verbs (Verb + Preposition combinations)', 'Literal vs Figurative Phrasal Verbs', 'Precision in Composition'],
    ["'Break down' can mean stop working mechanically (The car broke down) or lose emotional control.", "'Look after' means to take care of someone.", "'Hit the nail on the head' means to describe exactly what is causing a situation."],
    "What phrasal verb means 'to take care of' in: 'Please ______ my pet dog while I am on vacation.'",
    "The phrasal verb meaning to take care of someone or something is 'look after'!",
    "Look after 🐶",
    "Phrasal verbs are so characteristic of English that foreign learners often find them the richest part of English idiom!",
    "Look at = observe. Look for = search. Look after = take care of! Prepositions change the whole meaning!"
  ),
  makeCh(
    'eng_c5_icse_11', 11, 'Comprehension & Summary Writing (Précis Basics)', 'Class 5', 'icse', '📖',
    'Extract essential core facts from informational passages and write clear, concise summaries in your own words!',
    ['Distinguishing Essential vs Non-essential Information', 'Identifying Topic Sentences in Paragraphs', 'Condensing long sentences into compact phrases', 'Rules of Summary Writing'],
    ["A summary or précis captures the main substance of a text in about one-third of the original length.", "Never include personal opinions or external information in a summary.", "Write in your own words using clear, direct sentences."],
    "When writing a concise summary of a passage, what should you avoid including?",
    "Avoid including repetitive examples, unnecessary minor details, and personal outside opinions!",
    "Avoid minor details and personal opinions 📝",
    "The word 'précis' is French for 'precise' or 'cut short'!",
    "Underline only the main facts. Strip away all adjectives and examples, then rewrite the core message!"
  ),
  makeCh(
    'eng_c5_icse_12', 12, 'Composition: Narrative and Descriptive Essays', 'Class 5', 'icse', '📝',
    'Structure 3 to 4 paragraph essays: gripping introduction, well-developed body with sensory imagery, and meaningful conclusion!',
    ['The Essay Triad (Introduction, Body Paragraphs, Conclusion)', 'Sensory Language (sight, sound, smell, touch)', 'Cohesive paragraph transitions', 'Proofreading for Grammar and Concord'],
    ["The Introduction hooks the reader and introduces the topic.", "The Body develops specific scenes, arguments, or descriptions with vivid details.", "The Conclusion summarizes the insight or feelings left with the reader."],
    "In a descriptive essay about 'A Stormy Night', which sentence uses the most evocative sensory description?",
    "'Fierce lightning illuminated the blackened sky while torrential rain lashed violently against the windowpane.' creates powerful visual and auditory imagery!",
    "Vivid description evoking sights and sounds ⚡",
    "The essay form was invented by French philosopher Michel de Montaigne in 1580, who called them 'essais' (attempts)!",
    "Show, don't just tell: don't just say 'it was hot'; describe the blistering sun and beads of perspiration!"
  )
);

module.exports = { list };
