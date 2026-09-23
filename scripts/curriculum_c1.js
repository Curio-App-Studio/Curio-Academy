// scripts/curriculum_primary.js
const { makeCh } = require('./curriculum_base');

const list = [];

// =========================================================================
// CLASS 1 - CBSE (10 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c1_cbse_01', 1, 'Naming Words: People, Places & Animals', 'Class 1', 'cbse', '🎒',
    'Discover how every person, place, animal, and object in the world has a naming word!',
    ['Person Names (doctor, teacher)', 'Place Names (school, park)', 'Animal Names (cat, elephant)', 'Things (book, toy)'],
    ["A Noun is the name of a person, animal, place, or thing.", "Special names of people always start with a Capital Letter."],
    "In the sentence 'The little puppy runs in the park', which word is an animal name?",
    "'Puppy' is the name of a baby dog, which is an animal! So 'puppy' is the noun.",
    "Puppy 🐶",
    "Even feelings like 'happiness' and 'joy' are nouns because they name emotions!",
    "Look around your room: every item you can touch is a naming word!"
  ),
  makeCh(
    'eng_c1_cbse_02', 2, 'Action Words: Verbs in Daily Routines', 'Class 1', 'cbse', '🏃',
    'Explore doing words like run, jump, eat, read, and sleep that show what people and animals do!',
    ['Doing Words / Action Verbs', 'Physical Actions (skip, hop)', 'Daily Routine Verbs (brush, eat)', 'Sentence Building'],
    ["An Action Word (Verb) tells us what someone or something is doing.", "Every complete sentence needs an action word."],
    "Which word in 'Birds fly high in the blue sky' is an action word?",
    "'Fly' is what the birds are doing! Flying is an action, so 'fly' is the verb.",
    "Fly 🕊️",
    "The shortest complete sentence in English is 'Go!' which has just one action verb!",
    "Whenever you do an action, say the verb out loud: 'I am dancing!'"
  ),
  makeCh(
    'eng_c1_cbse_03', 3, "Articles: Using 'A' and 'An'", 'Class 1', 'cbse', '🍎',
    "Learn the magic rule for choosing 'A' or 'An' before singular naming words!",
    ["Using 'A' before Consonant Sounds", "Using 'An' before Vowel Sounds (a, e, i, o, u)", 'Singular Nouns'],
    ["Use 'AN' before words starting with vowel sounds (a, e, i, o, u): an apple, an egg, an umbrella.", "Use 'A' before words starting with consonant sounds: a ball, a kite."],
    "Which article goes before 'owl': 'a' or 'an'?",
    "'Owl' begins with vowel letter 'o' with a vowel sound /aʊ/. Therefore we say 'an owl'.",
    "An owl 🦉",
    "We use 'an' because it makes speaking smooth: 'an orange' flows much better than 'a orange'!",
    "Check the first sound: if it starts with vowel sounds (a, e, i, o, u), put 'an' first!"
  ),
  makeCh(
    'eng_c1_cbse_04', 4, 'Describing Words: Colors, Shapes & Sizes', 'Class 1', 'cbse', '🎨',
    'Make your stories vivid with words that describe colors, sizes, shapes, and numbers!',
    ['Color Adjectives (red, green)', 'Size Adjectives (tall, tiny)', 'Number Adjectives (one, three)', 'Feelings (happy, brave)'],
    ["A Describing Word (Adjective) tells more about a noun: what color, what size, or how many.", "Describing words usually sit right before the noun: a 'sweet' apple."],
    "In 'The big yellow sunflower bloomed', which word describes the color?",
    "'Yellow' describes the color of the sunflower! It is a describing word.",
    "Yellow 🌻",
    "Without adjectives, stories would be plain: describing words add all the color and taste to language!",
    "Describe your favorite toy with 3 words: its color, size, and how it feels!"
  ),
  makeCh(
    'eng_c1_cbse_05', 5, 'Singular and Plural: One and Many', 'Class 1', 'cbse', '📚',
    'Discover how words change when we talk about one thing versus many things by adding -s!',
    ['One (Singular)', 'Many (Plural)', 'Adding -s (cat -> cats, dog -> dogs)', 'Counting Objects'],
    ["For most words, simply add 's' to make plural: one book, two books.", "Plural means more than one."],
    "What is the plural of 'star' when you see many in the night sky?",
    "Add 's' to 'star' to make 'stars'!",
    "Stars ⭐",
    "Some animal names don't change at all: one sheep, five sheep!",
    "Point to one object, then find more and say: 'one pencil, three pencils!'"
  ),
  makeCh(
    'eng_c1_cbse_06', 6, 'Pronouns: He, She, It, They', 'Class 1', 'cbse', '👥',
    'Stop repeating names again and again by using friendly helper pronouns!',
    ['He (for boys/men)', 'She (for girls/women)', 'It (for animals/things)', 'They (for groups)'],
    ["Use 'He' for a boy: Aman is smart. He is reading.", "Use 'She' for a girl: Maya is kind. She is singing.", "Use 'It' for objects and animals."],
    "Replace the underlined name: 'Aarav is happy because Aarav won the race.'",
    "Aarav is a boy, so we replace the repeated name with 'He'!",
    "He 🏃",
    "The word 'I' is always written as a capital letter in English!",
    "Listen to your sentences: whenever you hear a name twice, replace the second one with he or she!"
  ),
  makeCh(
    'eng_c1_cbse_07', 7, 'Prepositions of Position: In, On, Under', 'Class 1', 'cbse', '📍',
    'Discover where objects are hiding: inside boxes, on top of tables, or under the bed!',
    ['In (inside)', 'On (touching the top)', 'Under (below)', 'Position Clues'],
    ["Use 'in' when inside an enclosed space: The fish is in the bowl.", "Use 'on' when touching the upper surface: The cat sits on the mat.", "Use 'under' when directly below: The ball is under the table."],
    "Where is the pencil if it is resting on top of the notebook?",
    "When an object touches the top surface, we use 'on': 'On the notebook'.",
    "On the notebook ✏️",
    "The word preposition means 'positioned before' because it sits before the noun!",
    "Put a toy on your head and say: 'The toy is on my head!'"
  ),
  makeCh(
    'eng_c1_cbse_08', 8, 'Simple Sentences & Capital Letters', 'Class 1', 'cbse', '🔠',
    'Build clear complete sentences that start with a capital letter and end with a full stop!',
    ['Capital Letter at Start', 'Full Stop at End (.)', 'Word Order', 'Expressing a Complete Thought'],
    ["Every sentence begins with a Capital Letter.", "A sentence ends with a Full Stop (.).", "Words must be arranged in the right order to make sense."],
    "Which is a correctly written sentence with a capital letter and full stop?",
    "'The sun shines brightly.' starts with a capital T and ends with a full stop!",
    "The sun shines brightly. ☀️",
    "Sentences are like trains: the capital letter is the engine and the full stop is the caboose!",
    "Always check: Did I start with a capital? Did I put a full stop at the end?"
  ),
  makeCh(
    'eng_c1_cbse_09', 9, 'Fun with Opposites & Action Verbs', 'Class 1', 'cbse', '🌓',
    'Expand your vocabulary with opposite word pairs and dynamic action words!',
    ['Opposites (hot/cold, fast/slow)', 'Action Verbs (climb, crawl)', 'Pairs in Stories', 'Picture Matching'],
    ["Opposite words have completely different, reverse meanings.", "Hot tea is the opposite of cold ice cream."],
    "What is the opposite of 'Fast'?",
    "The opposite of fast is slow, like a gentle snail or turtle!",
    "Slow 🐢",
    "Words with opposite meanings are formally called antonyms!",
    "Pair actions with their opposites: stand up and sit down!"
  ),
  makeCh(
    'eng_c1_cbse_10', 10, 'Rhymes, Sight Words & Story Sequencing', 'Class 1', 'cbse', '📖',
    'Read exciting story adventures, recognize instant sight words, and put story scenes in order!',
    ['Sight Words (come, see, look, go)', 'Story Sequencing (First, Next, Last)', 'Nursery Rhyme Comprehension', 'Picture Clues'],
    ["Story events happen in order: what happens first, next, and last.", "Sight words help you read stories smoothly without stopping to sound out."],
    "In the story of planting a seed, what happens first: 'water the plant' or 'plant the seed'?",
    "First you must plant the seed in soil before it can grow into a plant!",
    "Plant the seed 🌱",
    "Reading storybooks together with family builds the strongest reading skills!",
    "After finishing a story, retell what happened using: 'First... Then... Finally!'"
  )
);

// =========================================================================
// CLASS 1 - ICSE (10 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c1_icse_01', 1, 'Phonics, Letter Sounds & Consonant Blends (sh, ch, th)', 'Class 1', 'icse', '🔤',
    'Master individual consonant sounds and special two-letter team blends like sh, ch, and th!',
    ['Consonant Blends (sh, ch, th, wh)', 'Initial & Final Blends (ship, fish)', 'Digraphs', 'Pronunciation & Phonics'],
    ["When 's' and 'h' join, they make the soft /ʃ/ sound as in 'ship' and 'shell'.", "When 'c' and 'h' join, they make the /tʃ/ sound as in 'chin' and 'chair'."],
    "Which consonant blend does the word 'Chair' begin with?",
    "'Chair' begins with the two-letter sound team 'Ch' (/tʃ/)!",
    "Ch 🪑",
    "Two letters working together to make one unique sound are called a digraph!",
    "Put your finger to your lips and say 'Shh!' to remember the 'sh' sound in ship!"
  ),
  makeCh(
    'eng_c1_icse_02', 2, 'Naming Words: Persons, Places, Animals & Objects', 'Class 1', 'icse', '🎒',
    'Identify and categorize nouns into persons, places, animals, birds, and inanimate objects!',
    ['Persons (baker, nurse)', 'Places (temple, garden)', 'Animals & Birds (sparrow, lion)', 'Things (clock, umbrella)'],
    ["A Noun is the name of any person, animal, place, or thing.", "Special individual names like Rohit or Mumbai are Proper Nouns."],
    "Sort the word 'Hospital': is it a Person, Place, Animal, or Thing?",
    "'Hospital' is a building where doctors help people, so it is a Place!",
    "Place 🏥",
    "Everything in the entire universe that you can see, touch, or name is a noun!",
    "Categorize your bag: book (thing), teacher (person), school (place)!"
  ),
  makeCh(
    'eng_c1_icse_03', 3, 'Noun Genders: Boy & Girl, King & Queen', 'Class 1', 'icse', '👑',
    'Learn how words denote male and female beings in people and the animal kingdom!',
    ['Masculine Gender (male: father, boy, bull)', 'Feminine Gender (female: mother, girl, cow)', 'Pairs in Nature', 'Animal Families'],
    ["Masculine words refer to male persons or animals: King, Prince, Lion, Rooster.", "Feminine words refer to female persons or animals: Queen, Princess, Lioness, Hen."],
    "What is the feminine gender of 'King'?",
    "The female counterpart of a King is a 'Queen'!",
    "Queen 👑",
    "In some languages like French, even inanimate objects have gender, but in English things are neuter!",
    "Make royal pairs: Prince and Princess, King and Queen, Actor and Actress!"
  ),
  makeCh(
    'eng_c1_icse_04', 4, 'One and Many: Plurals with -s and -es', 'Class 1', 'icse', '📚',
    'Master making words plural by adding -s and knowing when words ending in s, sh, ch, x require -es!',
    ['Adding -s (lamp -> lamps)', 'Adding -es (box -> boxes, watch -> watches)', 'Words ending in -x, -ch, -sh, -s', 'Singular vs Plural'],
    ["When a naming word ends in s, sh, ch, or x, we add '-es' to form the plural: bus -> buses, fox -> foxes.", "For most other words, simply add '-s'."],
    "What is the correct plural form of 'glass'?",
    "Since 'glass' ends in 'ss', we add '-es' to form 'glasses'!",
    "Glasses 🥛",
    "The extra 'es' adds an extra syllable so we can clearly hear the plural ending!",
    "Listen for the hissing snake sounds at the end: s, sh, ch, x always get 'es'!"
  ),
  makeCh(
    'eng_c1_icse_05', 5, 'Doing Words: Verbs & Present Actions', 'Class 1', 'icse', '🏃',
    'Understand how verbs express action, movement, and what living beings do in daily life!',
    ['Action Verbs (write, read, swim)', 'Daily Actions', 'Singular vs Plural Verbs (The boy runs / The boys run)', 'Sentence Roles'],
    ["A Verb is an action word that tells what a person, animal, or thing does.", "When one person does an action now, we usually add -s: The dog barks."],
    "Choose the action verb: 'The happy chef cooks delicious food.'",
    "'Cooks' describes the action the chef is performing! Cooking is a verb.",
    "Cooks 👨‍🍳",
    "Verbs are the engine of every English sentence; without a verb, a sentence cannot move!",
    "Mime an action for a friend to guess: brushing, sleeping, or driving!"
  ),
  makeCh(
    'eng_c1_icse_06', 6, 'Describing Words: Qualities, Shapes & Numbers', 'Class 1', 'icse', '🎨',
    'Learn how adjectives describe size, color, shape, taste, and quantity of nouns!',
    ['Quality Adjectives (kind, sharp)', 'Size & Shape (round, square, huge)', 'Taste & Touch (sweet, rough)', 'Number Adjectives (five)'],
    ["An Adjective describes or qualifies a noun.", "Adjectives answer: What kind? How many? What color?"],
    "In 'The clever monkey climbed the tall tree', find the adjective describing the monkey.",
    "'Clever' tells what kind of monkey it is! So 'clever' is the describing adjective.",
    "Clever 🐒",
    "Authors use vivid adjectives to help readers paint pictures in their minds!",
    "Describe an apple using 3 senses: red (sight), sweet (taste), and crunchy (sound)!"
  ),
  makeCh(
    'eng_c1_icse_07', 7, "The Little Words: Articles 'A', 'An' and 'The'", 'Class 1', 'icse', '🍎',
    "Master the indefinite articles 'A' and 'An' and the definite article 'The' for specific things!",
    ["Vowel Sounds (A, E, I, O, U)", "Using 'An' before vowel sounds", "Using 'A' before consonant sounds", "Using 'The' for unique things (The Sun)"],
    ["Use 'an' before words starting with vowel sounds: an engine, an insect.", "Use 'a' before consonant sounds: a table.", "Use 'the' when referring to a specific thing or unique objects in nature: the Moon."],
    "Which article completes: '______ Moon shines brightly at night.'",
    "The Moon is unique in nature, so we always use the definite article 'The'!",
    "The Moon 🌕",
    "There is only one Earth, one Sun, and one Moon, which is why they always get 'The'!",
    "Remember: A and An mean 'any one', but The points to 'that specific one'!"
  ),
  makeCh(
    'eng_c1_icse_08', 8, 'Prepositions: In, On, Under, Behind & Beside', 'Class 1', 'icse', '📍',
    'Learn formal spatial words showing the exact position and location of objects!',
    ['In & On', 'Under & Above', 'Behind (at back)', 'Beside / Next to'],
    ["Prepositions show where a noun is located in relation to another noun.", "Behind means at the back of something. Beside means by the side of something."],
    "Where is the kitten if it is sitting right next to the mother cat?",
    "When sitting directly by the side of someone, we say 'beside' or 'next to'!",
    "Beside 🐱",
    "Cats are masters of prepositions: they love being in boxes, under tables, and on top of bookshelves!",
    "Play 'Simon Says Prepositions': Simon says put your pencil beside your eraser!"
  ),
  makeCh(
    'eng_c1_icse_09', 9, 'Punctuation: Capital Letters & Full Stop', 'Class 1', 'icse', '✏️',
    'Practice structural sentence mechanics: starting with capitals, ending with full stops, and capitalizing names!',
    ['Initial Capitalization', 'Terminal Full Stop (.)', 'Capitalizing Proper Nouns (Names, Days)', 'The Pronoun "I"'],
    ["Every sentence must begin with a capital letter and end with a full stop.", "Names of people (John), places (London), and the word 'I' are always capitalized."],
    "Correct the capitalization in: 'my friend rohan lives in delhi.'",
    "Start with capital 'M', capitalize 'Rohan' (person name), and capitalize 'Delhi' (city name)!",
    "My friend Rohan lives in Delhi. 🏛️",
    "In ancient times, sentences were written with all uppercase letters and no spaces at all!",
    "Be a sentence detective: check every name to ensure it wears its capital hat!"
  ),
  makeCh(
    'eng_c1_icse_10', 10, 'Polite Words, Greetings & Picture Composition', 'Class 1', 'icse', '🤝',
    'Learn polite language (Please, Thank you, Excuse me) and write descriptive sentences from pictures!',
    ['Polite Expressions (Please, Thank You, Sorry)', 'Greetings (Good Morning, Goodbye)', 'Picture Observation', 'Guided Sentence Formation'],
    ["Use polite words to show courtesy and respect: 'Please' when asking, 'Thank you' when receiving.", "Observe pictures closely: identify characters, actions, and settings before writing."],
    "What polite magic word should you say when someone gives you a gift?",
    "When receiving something, always say 'Thank you!' with a warm smile.",
    "Thank you! 🎁",
    "Good manners are understood in every country and culture across the entire world!",
    "Say 'Please' and 'Thank you' to family members at home today!"
  )
);

module.exports = { list };
