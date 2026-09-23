// scripts/curriculum_c3.js
const { makeCh } = require('./curriculum_base');

const list = [];

// =========================================================================
// CLASS 3 - CBSE (11 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c3_cbse_01', 1, 'Types of Nouns: Common, Proper & Collective', 'Class 3', 'cbse', '🏛️',
    'Master specific names like India, general names like country, and collective group names like a herd of cows!',
    ['Common Nouns (city, dog)', 'Proper Nouns (Mumbai, Tommy)', 'Collective Nouns (flock, team, swarm)', 'Capitalization Rules'],
    ["A Proper Noun is the unique name of a particular person, place, or monument, and ALWAYS begins with a capital letter.", "A Collective Noun names a group of people, animals, or things considered as one unit."],
    "What is the collective noun for a group of wolves hunting together?",
    "Wolves live and hunt in a group called a 'pack'. So we say 'a pack of wolves'.",
    "Pack of wolves 🐺",
    "A group of flamingos is called a 'flamboyance', and a group of owls is called a 'parliament'!",
    "Common nouns are general; Proper nouns are VIP names that always get a capital letter!"
  ),
  makeCh(
    'eng_c3_cbse_02', 2, 'Verbs & Simple Tenses (Present, Past & Future)', 'Class 3', 'cbse', '⏳',
    'Travel across time: what happens today (Present), happened yesterday (Past), and will happen tomorrow (Future)!',
    ['Simple Present (walk, walks)', 'Simple Past with -ed (walked, played)', 'Irregular Past (go -> went, eat -> ate)', "Simple Future with 'will'"],
    ["Present tense tells what happens regularly: He plays football.", "Past tense tells what already finished: He played football yesterday.", "Future tense tells what will happen later: He will play football tomorrow."],
    "Change 'eat' into the past tense: 'Yesterday, I ______ an apple.'",
    "'Eat' is an irregular verb. Its past tense is 'ate', not 'eated'!",
    "Ate 🍎",
    "The word 'yesterday' originally meant 'the other day' in Old English!",
    "Look for time clues: 'yesterday' calls for past tense; 'tomorrow' calls for 'will'!"
  ),
  makeCh(
    'eng_c3_cbse_03', 3, 'Degrees of Comparison (Adjectives: Big, Bigger, Biggest)', 'Class 3', 'cbse', '📏',
    'Compare two or more things using positive, comparative (-er), and superlative (-est) degrees!',
    ['Positive Degree (tall)', 'Comparative Degree (-er / more: taller than)', 'Superlative Degree (-est / most: tallest of all)', 'Irregular Adjectives (good, better, best)'],
    ["Use Comparative (-er) when comparing two things: An elephant is bigger than a horse.", "Use Superlative (-est) when comparing three or more: The blue whale is the biggest animal.", "Always use 'the' before superlative adjectives: 'the fastest runner'."],
    "Fill in the blank: 'Mount Everest is the ______ mountain in the world.'",
    "We are comparing Everest to all mountains in the world (superlative), so we use 'highest' with 'the'.",
    "Highest 🏔️",
    "'Good, better, best' comes from different ancient roots, which is why 'gooder' is never used!",
    "Two items = compare with -er. Three or more = the champion with -est!"
  ),
  makeCh(
    'eng_c3_cbse_04', 4, 'Conjunctions: Joining Words (And, But, Because, Or)', 'Class 3', 'cbse', '🔗',
    'Become a sentence builder! Connect ideas smoothly using powerful joining words.',
    ['And (adding ideas)', 'But (contrasting ideas)', 'Because (giving reasons)', 'Or (offering choices)'],
    ["Use 'and' to connect similar thoughts: I like tea and biscuits.", "Use 'but' to show an opposite or contrast: I wanted to go out, but it rained.", "Use 'because' to answer 'why': I wore a sweater because it was cold."],
    "Choose the right conjunction: 'Rohan worked hard, ______ he passed with top marks.'",
    "Passing is the direct positive result/continuation of working hard, so 'and' (or 'so') connects the thoughts.",
    "And / So 🎯",
    "The word 'conjunction' comes from Latin 'con' (together) + 'jungere' (to join)!",
    "Think of conjunctions as glue: 'and' adds, 'but' turns around, and 'because' explains why!"
  ),
  makeCh(
    'eng_c3_cbse_05', 5, "Articles: Definite 'The' and Indefinite 'A/An'", 'Class 3', 'cbse', '🍎',
    "Master the rules for using 'a' and 'an' with consonant/vowel sounds and 'the' with unique or repeated nouns!",
    ["Vowel Sounds vs Consonant Sounds", "Special cases (a university, an hour)", "The with rivers, mountains, and holy books", "Zero article before proper names"],
    ["We say 'an hour' because the 'h' is silent and sounds like vowel /aʊ/.", "We say 'a university' because it begins with the consonant sound /j/ (yoo).", "Use 'the' before unique entities: The Himalayas, The Taj Mahal."],
    "Which article completes: 'We waited for ______ hour at the railway station.'",
    "The 'h' in 'hour' is silent, so it starts with a vowel sound: 'an hour'!",
    "An hour ⏱️",
    "Articles depend on SOUND, not letter spelling! That's why sound awareness is key.",
    "Say it out loud: if your vocal cords open without a consonant pop, it gets 'an'!"
  ),
  makeCh(
    'eng_c3_cbse_06', 6, 'Adverbs of Manner: Words Ending in -ly', 'Class 3', 'cbse', '⚡',
    'Learn how adverbs describe HOW an action takes place: loudly, sweetly, quickly, and bravely!',
    ['Adverbs of Manner', 'Forming Adverbs by adding -ly', 'Exceptions (fast -> fast, good -> well)', 'Modifying Verbs'],
    ["An Adverb of Manner tells how an action is performed: She sang sweetly.", "Most are formed by adding '-ly' to an adjective: quick -> quickly, quiet -> quietly.", "'Fast' and 'hard' do not take -ly: He runs fast (not fastly)."],
    "In 'The soldier fought bravely in the battle', which word is the adverb of manner?",
    "'Bravely' tells HOW the soldier fought! So 'bravely' is the adverb.",
    "Bravely 🛡️",
    "Adverbs are flexible: they can sit at the beginning, middle, or end of a sentence!",
    "Ask yourself 'How did they do it?' The answer word ending in -ly is your adverb!"
  ),
  makeCh(
    'eng_c3_cbse_07', 7, 'Prepositions of Time and Place (At, On, In)', 'Class 3', 'cbse', '📍',
    'Master the time and place triangle: AT for exact moments/spots, ON for days/surfaces, IN for months/rooms!',
    ['Prepositions of Time (at 5 o clock, on Monday, in June)', 'Prepositions of Place (at home, on the roof, in India)', 'Spatial Relationships', 'Time Expressions'],
    ["Use 'at' for precise clock times: at 4 PM.", "Use 'on' for days and dates: on Tuesday, on 15th August.", "Use 'in' for months, years, and large spaces: in July, in 2026, in Delhi."],
    "Which preposition completes: 'Our school reopens ______ Monday morning.'",
    "For specific days of the week, we always use 'on'!",
    "On Monday 📅",
    "Think of time like a pyramid: AT is the sharp point (hours), ON is the middle (days), IN is the wide base (months & years)!",
    "Hours get AT, days get ON, months and years get IN!"
  ),
  makeCh(
    'eng_c3_cbse_08', 8, 'Pronouns: Subject and Object Pronouns (I/Me, He/Him)', 'Class 3', 'cbse', '👥',
    'Learn when to use doer subject pronouns (I, he, she, we, they) versus receiver object pronouns (me, him, her, us, them)!',
    ['Subject Pronouns (doers of action)', 'Object Pronouns (receivers of action)', 'I vs Me', 'He vs Him, She vs Her, They vs Them'],
    ["Subject pronouns perform the action before the verb: She called Rohan.", "Object pronouns receive the action after the verb: Rohan called her.", "Never say 'Me and Rahul went'; say 'Rahul and I went'!"],
    "Choose the correct pronoun: 'The teacher gave the gold medal to ______ (he / him).'",
    "The pronoun comes after the preposition/verb as the receiver, so we use the object pronoun 'him'!",
    "Him 🏅",
    "Shakespeare often played with pronouns in famous lines like 'To be or not to be'!",
    "Before the verb = I, he, she, they. After the verb or preposition = me, him, her, them!"
  ),
  makeCh(
    'eng_c3_cbse_09', 9, 'Vocabulary: Synonyms and Antonyms', 'Class 3', 'cbse', '🧠',
    'Boost your vocabulary with twin words that mean the same (synonyms) and mirror words that mean the opposite (antonyms)!',
    ['Synonyms (rich word choices: huge, gigantic, enormous)', 'Antonyms (opposites: bright/dim, cruel/kind)', 'Context Clues', 'Dictionary Skills'],
    ["Synonyms have nearly identical meanings: beautiful and pretty.", "Antonyms have opposite meanings: ancient and modern.", "Using diverse synonyms makes your writing vibrant and interesting."],
    "What is a synonym for 'Huge'?",
    "'Enormous', 'gigantic', and 'massive' are all great synonyms for huge!",
    "Enormous / Gigantic 🐘",
    "The English language has over 500,000 words, more synonyms than almost any other language!",
    "Whenever you write 'happy', think of a synonym: cheerful, delighted, or joyful!"
  ),
  makeCh(
    'eng_c3_cbse_10', 10, 'Punctuation: Apostrophe for Contractions & Possession', 'Class 3', 'cbse', '✍️',
    "Learn the two powers of the apostrophe: showing ownership (Rohan's book) and joining words (don't, can't)!",
    ["Possessive Apostrophe ('s)", "Contractions (do not -> don't, cannot -> can't)", "It's (it is) vs Its (possessive)", "Plural possessives (boys' school)"],
    ["Use 's to show ownership: The girl's doll = the doll belonging to the girl.", "Use an apostrophe to replace missing letters in contractions: cannot -> can't.", "'Its' shows belonging (The cat licked its paw); 'It's' means 'it is'!"],
    "Which is correct for the bag belonging to Priya: 'Priyas bag' or 'Priya\\'s bag'?",
    "We add 's to show ownership: 'Priya's bag'!",
    "Priya's bag 🎒",
    "The apostrophe originally looked like a comma hanging in the air and was used to mark deleted letters in printing!",
    "Test: if you can replace it with 'it is', write 'it's'! Otherwise, write 'its'!"
  ),
  makeCh(
    'eng_c3_cbse_11', 11, 'Reading Comprehension & Sequencing Events', 'Class 3', 'cbse', '📖',
    'Read short stories and informational passages, identify the main idea, and answer who, what, when, where, and why!',
    ['Main Idea Identification', 'Locating Specific Details', 'Sequencing Chronological Events', 'Making Inferences'],
    ["Read the passage completely before looking at questions.", "Underline key names, dates, and action words as clues.", "Answer in complete, grammatically correct sentences."],
    "In a story where a crow drops pebbles into a pitcher to drink water, why did the crow drop pebbles?",
    "To make the water level rise high enough so that his beak could reach and drink it!",
    "To raise the water level 🪨",
    "Fables like the Thirsty Crow were written by Aesop over 2,500 years ago and are still taught worldwide!",
    "Always re-read the paragraph where you find the answer to verify every single detail!"
  )
);

// =========================================================================
// CLASS 3 - ICSE (11 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c3_icse_01', 1, 'Nouns: Proper, Common, Collective & Abstract Intro', 'Class 3', 'icse', '🏛️',
    'Classify nouns into Proper, Common, Collective, and introduce Abstract nouns for feelings and qualities!',
    ['Proper vs Common Nouns', 'Collective Nouns (crew, choir, fleet, swarm)', 'Abstract Nouns Intro (kindness, bravery, truth)', 'Concrete vs Abstract'],
    ["A Concrete Noun can be seen or touched (flower, table).", "An Abstract Noun is the name of a quality, state, or concept that cannot be seen or touched (honesty, joy, wisdom).", "Collective nouns name an entire group treated as a single entity: a fleet of ships."],
    "What type of noun is 'Honesty' in the sentence 'Honesty is the best policy'?",
    "'Honesty' is a moral quality you cannot touch with your hands: it is an Abstract Noun!",
    "Abstract Noun 💎",
    "Abstract comes from Latin 'abstractus' meaning 'drawn away' from physical objects!",
    "Can you touch it? Yes = Concrete. Is it a thought, feeling, or quality? Yes = Abstract!"
  ),
  makeCh(
    'eng_c3_icse_02', 2, 'Nouns: Number, Gender and Possessives (Apostrophe \'s)', 'Class 3', 'icse', '🏷️',
    'Master irregular plural nouns, four genders (masculine, feminine, common, neuter), and possessive apostrophes!',
    ['Irregular plurals (ox -> oxen, datum -> data)', 'Four Genders in English', 'Possessive Singular (\'s) & Plural (s\')', 'Apostrophe Rules'],
    ["Singular possessive adds 's: The boy's coat.", "Plural nouns ending in -s add only an apostrophe at the end: The boys' hostel.", "Plural nouns not ending in -s add 's: Children's park."],
    "Where does the apostrophe go for the nest belonging to many birds?",
    "Since 'birds' already ends in -s, we place the apostrophe after the 's': 'The birds' nest'!",
    "Birds' nest 🪺",
    "In medieval English, possession was shown by adding '-es' (the kinges crown), which became 's!",
    "If plural ends in 's', hang the apostrophe outside: students' books!"
  ),
  makeCh(
    'eng_c3_icse_03', 3, 'Pronouns: Personal, Demonstrative & Possessive', 'Class 3', 'icse', '👥',
    'Classify pronouns: Personal (subject & object), Demonstrative (this/that/these/those), and Possessive (mine, yours, his, hers)!',
    ['Personal Pronouns (First, Second, Third Person)', 'Subject vs Object Pronouns', 'Demonstrative Pronouns', 'Possessive Pronouns (mine, ours, theirs)'],
    ["First Person refers to the speaker (I, we). Second Person refers to the listener (you). Third Person refers to the person spoken about (he, she, they).", "Possessive pronouns stand alone without a noun: The red pen is mine."],
    "In 'This jacket is mine', which word is the Possessive Pronoun?",
    "'Mine' stands by itself to show ownership without repeating 'my jacket'! It is a possessive pronoun.",
    "Mine 🧥",
    "Possessive pronouns never take an apostrophe: yours, hers, ours, and theirs are always apostrophe-free!",
    "If it has a noun after it (my book), it's an adjective. If it stands alone (it is mine), it's a pronoun!"
  ),
  makeCh(
    'eng_c3_icse_04', 4, 'Adjectives: Kinds of Adjectives (Quality, Quantity, Number)', 'Class 3', 'icse', '🎨',
    'Identify and categorize adjectives: Quality (what kind), Quantity (how much), Number (how many), and Demonstrative!',
    ['Adjectives of Quality (honest, large)', 'Adjectives of Quantity (some, little, much)', 'Adjectives of Number (two, several, first)', 'Demonstrative Adjectives (this, that)'],
    ["Adjectives of Quality describe kind or nature: wise king.", "Adjectives of Quantity answer 'How much?' for uncountable nouns: some water, little time.", "Adjectives of Number answer 'How many?' for countable nouns: three birds, few pencils."],
    "In 'There is little milk left in the jug', what kind of adjective is 'little'?",
    "'Milk' is uncountable, and 'little' answers 'how much milk?': it is an Adjective of Quantity!",
    "Adjective of Quantity 🥛",
    "Adjectives of number are divided into Definite (one, two, first) and Indefinite (some, several)!",
    "Ask: Can I count it? Countable = Number (five books). Uncountable = Quantity (some milk)!"
  ),
  makeCh(
    'eng_c3_icse_05', 5, 'Comparison of Adjectives: Positive, Comparative & Superlative', 'Class 3', 'icse', '📏',
    'Master the three degrees of comparison, spelling changes (-er, -ier, doubling consonants), and irregular comparisons!',
    ['Positive Degree (sweet)', 'Comparative Degree (sweeter, heavier, more beautiful)', 'Superlative Degree (sweetest, heaviest, most beautiful)', 'Irregular Adjectives (good/better/best, bad/worse/worst)'],
    ["When an adjective has two or more syllables, we often use 'more' and 'most': more beautiful, most beautiful.", "If ending in single consonant preceded by short vowel, double consonant: hot -> hotter -> hottest.", "Bad -> Worse -> Worst."],
    "What is the comparative degree of 'Good'?",
    "The comparative form of 'good' is 'better'!",
    "Better ⭐",
    "'Worse' and 'worst' come from an entirely different ancient root word than 'bad'!",
    "Comparing two = comparative (-er or more). The ultimate champion of three or more = superlative (-est or most)!"
  ),
  makeCh(
    'eng_c3_icse_06', 6, 'Verbs: Transitive and Intransitive Intro & Simple Tenses', 'Class 3', 'icse', '⏳',
    'Discover verbs that need an object to complete their meaning (Transitive) versus verbs that make sense alone (Intransitive)!',
    ['Transitive Verbs (require an object: He kicked the ball)', 'Intransitive Verbs (no object: The baby slept)', 'Identifying Objects (answering what or whom)', 'Simple Tenses'],
    ["A Transitive verb passes action from subject to object: The boy kicked (what?) the ball.", "An Intransitive verb expresses action or state that does not pass to an object: The bird flew.", "Ask 'What?' or 'Whom?' after the verb to find the object."],
    "In 'She wrote a letter', is 'wrote' Transitive or Intransitive?",
    "Ask: She wrote what? Answer: 'a letter' (object). Because it has an object, 'wrote' is Transitive!",
    "Transitive Verb ✉️",
    "The word 'transitive' comes from Latin 'transire' meaning 'to go across', because the action goes across to an object!",
    "Find the verb and ask 'What?' or 'Whom?' If there is an answer, it is Transitive!"
  ),
  makeCh(
    'eng_c3_icse_07', 7, 'Adverbs: Modifying Verbs (Manner, Time & Place)', 'Class 3', 'icse', '⚡',
    'Classify adverbs: Manner (How: softly), Time (When: early, yesterday), and Place (Where: everywhere, outside)!',
    ['Adverbs of Manner (answer How)', 'Adverbs of Time (answer When)', 'Adverbs of Place (answer Where)', 'Distinguishing Adverbs from Adjectives'],
    ["Adverbs of Manner tell how: The lion roared loudly.", "Adverbs of Place tell where: Come inside.", "Adverbs of Time tell when: We will leave tomorrow.", "Adverbs modify verbs, adjectives, or other adverbs."],
    "In 'The children played happily outside yesterday', identify the Adverb of Place.",
    "'Outside' answers WHERE the children played, so 'outside' is the Adverb of Place!",
    "Outside 🏡",
    "Some words can be both adjectives and adverbs depending on use: 'He is a fast runner' (adj) vs 'He runs fast' (adv)!",
    "Ask: How? = Manner. Where? = Place. When? = Time!"
  ),
  makeCh(
    'eng_c3_icse_08', 8, 'Prepositions: Position, Direction & Time', 'Class 3', 'icse', '🧭',
    'Master prepositions of place, movement, and duration: across, through, into, during, since, and until!',
    ['Prepositions of Place (over, beneath, across)', 'Prepositions of Movement (into, out of, towards)', 'Prepositions of Duration (during, for, until)', 'Correct Prepositional Usage'],
    ["Use 'through' for moving inside a three-dimensional space: The train went through the tunnel.", "Use 'across' for moving from one side to the opposite: Swim across the river.", "Use 'during' to state when something happened within a period of time."],
    "Complete the sentence: 'The explorer walked ______ the dense forest.'",
    "Moving through the inside of a dense 3D space like a forest requires 'through'!",
    "Through the forest 🌲",
    "Prepositions govern the grammatical objective case of pronouns: 'between you and me' (never 'between you and I')!",
    "Across = flat surface (across the bridge). Through = 3D surroundings (through the tunnel)!"
  ),
  makeCh(
    'eng_c3_icse_09', 9, 'Conjunctions: Coordinating (And, But, So, Because)', 'Class 3', 'icse', '🔗',
    'Combine independent clauses using coordinating and causal conjunctions: and, but, so, because, and although!',
    ['Coordinating Conjunctions (and, but, or)', 'Causal Conjunctions (because, since)', 'Consequential Conjunction (so)', 'Punctuation in Compound Sentences'],
    ["'Because' introduces the reason: I stayed in bed because I was unwell.", "'So' introduces the result: I was unwell, so I stayed in bed.", "Use a comma before coordinating conjunctions when connecting two complete sentences."],
    "Join the clauses: 'It was raining heavily. We took an umbrella.'",
    "Taking an umbrella is the result of rain, so we use 'so': 'It was raining heavily, so we took an umbrella.'",
    "It was raining heavily, so we took an umbrella ☔",
    "In formal English writing, coordinating conjunctions keep sentences from sounding choppy and disjointed!",
    "Because states the cause (why); So states the effect (what happened as a result)!"
  ),
  makeCh(
    'eng_c3_icse_10', 10, 'Figures of Speech: Introduction to Similes', 'Class 3', 'icse', '🦁',
    "Discover the beauty of figurative comparisons using 'as...as' and 'like' (Similes) in literature and poetry!",
    ['Definition of Simile', "Using 'as...as' (as brave as a lion, as cold as ice)", "Using 'like' (runs like the wind)", 'Literary and Poetic Impact'],
    ["A Simile is a figure of speech that directly compares two different things using the words 'like' or 'as'.", "Similes make descriptions vivid and memorable: 'Her smile was as bright as the sun.'", "Both compared items must share a specific striking quality."],
    "Complete the classic simile: 'The courageous warrior fought as brave as a ______.'",
    "The traditional simile comparing courage uses the king of beasts: 'as brave as a lion'!",
    "Lion 🦁",
    "Similes have been used in poetry since the ancient epics of Homer and Valmiki over 3,000 years ago!",
    "Look for the magic comparison words: if it has 'like' or 'as...as', it is a Simile!"
  ),
  makeCh(
    'eng_c3_icse_11', 11, 'Formal Writing: Friendly Letters & Paragraph Composition', 'Class 3', 'icse', '✉️',
    'Master the five elements of an informal/friendly letter and structured paragraph writing with vivid vocabulary!',
    ['5 Parts of a Letter (Address/Date, Salutation, Body, Subscription, Signature)', 'Opening Greetings', 'Topic Sentence & Supporting Details', 'Polite Closings (Yours lovingly / affectionately)'],
    ["An informal letter is written to friends or family members.", "The greeting is called the Salutation: 'Dear Maya,'.", "The closing sign-off is called the Subscription: 'Yours lovingly, Rohan'."],
    "What is the opening greeting in a letter to a friend called?",
    "The opening greeting like 'Dear Friend' is formally called the 'Salutation'!",
    "Salutation ✉️",
    "Before stamps were invented, the receiver of a letter had to pay for its delivery upon arrival!",
    "Letter checklist: Date on top, greeting comma, capital letter for 'Yours', and sign your name!"
  )
);

module.exports = { list };
