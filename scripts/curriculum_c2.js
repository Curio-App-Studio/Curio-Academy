// scripts/curriculum_c2.js
const { makeCh } = require('./curriculum_base');

const list = [];

// =========================================================================
// CLASS 2 - CBSE (10 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c2_cbse_01', 1, 'Singular and Plural Nouns (-s and -es)', 'Class 2', 'cbse', '📚',
    'Master changing naming words from one to many by adding -s, -es, and spotting special words!',
    ['Adding -s (tree -> trees)', 'Adding -es (box -> boxes, bus -> buses)', 'Words ending in -ch, -sh, -x, -s', 'Special words (child -> children)'],
    ["For most nouns, add 's' to make plural: cup -> cups.", "When a noun ends in -s, -ss, -sh, -ch, or -x, add 'es': branch -> branches.", "Special words change completely: tooth -> teeth."],
    "What is the plural of 'brush'?",
    "Since 'brush' ends in 'sh', we add 'es' to make it plural: 'brushes'!",
    "Brushes 🖌️",
    "Some words stay the same whether one or many: one deer, ten deer!",
    "Listen to the end sound: if it has a hissing sound (-sh, -ch, -x), give it an 'es'!"
  ),
  makeCh(
    'eng_c2_cbse_02', 2, 'Pronouns: Replacing Nouns (He, She, It, We, They)', 'Class 2', 'cbse', '👥',
    'Replace repeated names in paragraphs with helpful pronouns: he, she, it, we, and they!',
    ['Subject Pronouns', 'Singular Pronouns (He, She, It)', 'Plural Pronouns (We, They)', 'Talking about Yourself (I, You)'],
    ["Use 'He' for a male, 'She' for a female, and 'It' for a thing or animal.", "Use 'They' for more than one person, animal, or object.", "Use 'We' when including yourself."],
    "Replace the underlined words: 'The birds are singing. The birds are in the tree.'",
    "'The birds' are plural, so we replace them with 'They'!",
    "They 🐦",
    "Pronouns make our speech faster and prevent clumsy repetition!",
    "When telling a story about a friend, use their name once, then switch to he or she!"
  ),
  makeCh(
    'eng_c2_cbse_03', 3, 'Action Verbs & Helping Verbs (is, am, are)', 'Class 2', 'cbse', '🏃',
    'Learn how action words combine with helping verbs like is, am, and are to show present action!',
    ['Action Verbs (walk, sing)', "Using 'Am' with I", "Using 'Is' with He, She, It", "Using 'Are' with You, We, They"],
    ["Use 'am' only with 'I': I am drawing.", "Use 'is' with singular subjects: The kite is flying.", "Use 'are' with plural subjects and 'you': They are playing."],
    "Fill in the blank: 'The children ______ playing football in the playground.'",
    "'Children' is plural, so we use the helping verb 'are'!",
    "Are ⚽",
    "Helping verbs are like sidekicks: they support the main action verb in the sentence!",
    "Sing the rule: 'I am, He is, She is, It is, We are, They are!'"
  ),
  makeCh(
    'eng_c2_cbse_04', 4, 'Describing Words & Opposites', 'Class 2', 'cbse', '🎨',
    'Describe feelings, tastes, colors, and learn opposite pairs like soft/hard and clean/dirty!',
    ['Describing Words (Adjectives)', 'Sensory Adjectives (sweet, sour, soft)', 'Opposite Pairs (clean/dirty, light/dark)', 'Enhancing Sentences'],
    ["Adjectives describe nouns: what kind, what color, or how many.", "Opposite words give the reverse description of an object."],
    "In 'The little girl drank warm milk', which word describes the milk?",
    "'Warm' tells the temperature of the milk! So 'warm' is the adjective.",
    "Warm 🥛",
    "There are over 100,000 descriptive words in English to help us describe anything imaginable!",
    "Look at three objects in your kitchen and describe their taste: sweet, salty, or spicy!"
  ),
  makeCh(
    'eng_c2_cbse_05', 5, 'Prepositions of Position (In, On, Under, Behind, Near)', 'Class 2', 'cbse', '📍',
    'Tell exactly where someone or something is: behind the door, near the gate, or under the umbrella!',
    ['In & On', 'Under & Behind', 'Near & Far', 'Spatial Descriptions'],
    ["Prepositions show where someone or something is placed.", "Use 'behind' when something is at the back. Use 'near' when something is close by."],
    "Where is the puppy if it is sleeping right next to the front door?",
    "When an object is close to something, we say it is 'near' the door.",
    "Near the door 🚪",
    "Prepositions are used in every navigation app and GPS system to give directions!",
    "Describe where your shoes are right now using 'under', 'near', or 'behind'!"
  ),
  makeCh(
    'eng_c2_cbse_06', 6, 'Punctuation: Capitals, Full Stops & Question Marks', 'Class 2', 'cbse', '❓',
    'Learn how punctuation marks guide the voice: statements finish with a dot, questions with a hook!',
    ['Capital Letters for Sentences & Names', 'Full Stop (.) for Statements', 'Question Mark (?) for Inquiries', 'Reading with Expression'],
    ["A statement tells something and ends with a full stop (.).", "A question asks something and ends with a question mark (?).", "Names of people, places, and days always begin with a capital letter."],
    "Which punctuation mark ends this sentence: 'What is your favorite color'?",
    "This sentence is asking for information (a question), so it ends with a question mark (?).",
    "Question Mark (?) 🎨",
    "The question mark comes from the Latin word 'Quaestio' (question), which was shortened to 'Qo'!",
    "Notice your voice: when asking a question, your pitch naturally goes up at the end!"
  ),
  makeCh(
    'eng_c2_cbse_07', 7, 'Conjunctions: Joining Words (And, But)', 'Class 2', 'cbse', '🔗',
    'Become a sentence builder! Connect two short sentences into one smooth sentence using and or but.',
    ["Using 'And' to combine similar ideas", "Using 'But' to show contrast", 'Sentence Joining', 'Writing Flow'],
    ["Use 'and' when joining similar ideas: I have a bat. I have a ball. -> I have a bat and a ball.", "Use 'but' when showing something unexpected or contrasting: He ran fast, but missed the bus."],
    "Join the sentences: 'Rohan likes mangoes. Rohan likes apples.'",
    "Combine the similar fruits using 'and': 'Rohan likes mangoes and apples.'",
    "Rohan likes mangoes and apples 🍎",
    "Conjunctions are like bridges that connect two sentence islands together!",
    "Practice: 'I wanted to play outside, but it started raining!'"
  ),
  makeCh(
    'eng_c2_cbse_08', 8, "Articles: Using 'A', 'An' and 'The'", 'Class 2', 'cbse', '🍎',
    "Master choosing 'a', 'an', or 'the' when talking about any item versus one specific item!",
    ["Indefinite Articles ('a', 'an')", "Definite Article ('the')", "Specific vs General Objects", "Unique things in nature"],
    ["Use 'a' before consonant sounds: a car.", "Use 'an' before vowel sounds: an ice cream.", "Use 'the' when talking about a specific thing already mentioned or unique things: The Sun, The Ganges."],
    "Fill in the blank: 'I saw a puppy. ______ puppy was barking happily.'",
    "Since we are now talking about that specific puppy we already mentioned, we say 'The puppy'.",
    "The puppy 🐕",
    "English has only three articles: a, an, and the, but they are used in almost every sentence!",
    "First time you mention it, say 'a cat'. Next time you mention it, say 'the cat'!"
  ),
  makeCh(
    'eng_c2_cbse_09', 9, 'Past Tense Intro: What Happened Yesterday (-ed)', 'Class 2', 'cbse', '⏳',
    'Learn how verbs travel back in time by adding -ed to show what happened yesterday or last week!',
    ['Past Tense with -ed (play -> played)', 'Yesterday & Last Night Clues', 'Common Irregular Verbs (go -> went, eat -> ate)', 'Time Expressions'],
    ["For most verbs, add '-ed' to show action in the past: walk -> walked, jump -> jumped.", "Some special verbs change form: go becomes went, eat becomes ate."],
    "Change the verb to past tense: 'Yesterday, I ______ (paint) a picture.'",
    "Add '-ed' to 'paint' for past action: 'painted'.",
    "Painted 🎨",
    "Old English had hundreds of irregular past tense verbs, but many changed to simple '-ed' over the centuries!",
    "Look for time clues like 'yesterday', 'last night', or 'this morning' to use past tense!"
  ),
  makeCh(
    'eng_c2_cbse_10', 10, 'Picture Reading & Creative Sentences', 'Class 2', 'cbse', '🖼️',
    'Look at detailed picture scenes of parks, markets, and classrooms, and write complete descriptive sentences!',
    ['Picture Comprehension', 'Sentence Framing', 'Using Capital Letters & Punctuation', 'Sequencing Thoughts'],
    ["Observe the setting, characters, and activities in the picture carefully.", "Write full sentences with a subject and verb, not just single words."],
    "In a picture of a zoo, a monkey is eating a banana under a tree. Who is eating the banana?",
    "The monkey is the character eating the banana under the tree!",
    "The monkey 🐒",
    "Visual reading of pictures uses the same brain pathways as reading printed words!",
    "Describe any picture using the 5 Ws: Who? What? Where? When? Why?"
  )
);

// =========================================================================
// CLASS 2 - ICSE (10 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c2_icse_01', 1, 'Common and Proper Nouns: Special vs Ordinary Names', 'Class 2', 'icse', '🏛️',
    'Distinguish between general common names (boy, city) and unique proper names (Rohan, Mumbai)!',
    ['Common Nouns (ordinary names of things)', 'Proper Nouns (unique VIP names)', 'Capitalization Rule for Proper Nouns', 'Days, Months & Festivals'],
    ["A Common Noun is the general name of any person, place, or thing: country, dog, book.", "A Proper Noun is the special name given to a particular person, place, or holiday, and ALWAYS starts with a capital letter: India, Bruno, Christmas."],
    "Which word in 'We visited Delhi during Diwali' is a Common Noun: 'Delhi', 'Diwali', or neither?",
    "Both 'Delhi' and 'Diwali' are Proper Nouns! If we said 'city' or 'festival', those would be Common Nouns.",
    "Both are Proper Nouns 🏙️",
    "Your own name is a Proper Noun, which is why it always begins with a majestic capital letter!",
    "Remember: Common nouns are everyday names; Proper nouns are VIP names that always wear a capital hat!"
  ),
  makeCh(
    'eng_c2_icse_02', 2, 'Nouns: Number (Regular -s, -es and Irregular Plurals)', 'Class 2', 'icse', '📚',
    'Master plural formation rules: adding -s, -es, changing -y to -ies, and irregular plural nouns!',
    ['Adding -es to words ending in -s, -ss, -sh, -ch, -x', 'Changing consonant + y to -ies (baby -> babies)', 'Vowel change plurals (foot -> feet, man -> men)', 'Zero change plurals (sheep -> sheep)'],
    ["If a word ends in a consonant + y, drop the 'y' and add '-ies': city -> cities.", "Some nouns change their internal vowels: foot -> feet, goose -> geese.", "Some nouns change entirely: child -> children."],
    "What is the plural form of 'butterfly'?",
    "Because 'butterfly' ends in consonant 'l' + 'y', we drop 'y' and add '-ies': 'butterflies'!",
    "Butterflies 🦋",
    "The word 'mouse' becomes 'mice', and 'louse' becomes 'lice', following ancient Germanic plural patterns!",
    "If there is a vowel before 'y' (boy, toy), just add 's'! If a consonant is before 'y' (baby), change to 'ies'!"
  ),
  makeCh(
    'eng_c2_icse_03', 3, 'Nouns: Gender (Masculine, Feminine & Common)', 'Class 2', 'icse', '👥',
    'Study noun genders: Masculine (male), Feminine (female), and Common gender words used for both!',
    ['Masculine Gender (hero, bull, nephew)', 'Feminine Gender (heroine, cow, niece)', 'Common Gender (baby, teacher, doctor, friend)', 'Neuter Gender (book, pen)'],
    ["Masculine denotes male beings; Feminine denotes female beings.", "Common Gender words can refer to either male or female: teacher, child, cousin, student.", "Neuter Gender words refer to non-living objects: desk, table."],
    "What gender category does the word 'Teacher' belong to?",
    "A teacher can be a man or a woman, so 'teacher' belongs to the Common Gender!",
    "Common Gender 👩‍🏫",
    "In Old English, the word 'girl' originally meant any young child, whether boy or girl!",
    "Classify words: Uncle (Masculine), Aunt (Feminine), Cousin (Common), Clock (Neuter)!"
  ),
  makeCh(
    'eng_c2_icse_04', 4, 'Pronouns: Personal & Demonstrative (This, That, These, Those)', 'Class 2', 'icse', '👆',
    'Master personal pronouns and demonstrative pointers for singular/plural near and far objects!',
    ['Personal Pronouns (I, you, he, she, it, we, they)', 'Demonstrative Pronouns (This, That, These, Those)', 'Near vs Far Pointers', 'Singular vs Plural Pointers'],
    ["Use 'This' (singular) and 'These' (plural) for objects close at hand.", "Use 'That' (singular) and 'Those' (plural) for objects farther away.", "Demonstrative pronouns point out specific items."],
    "Point to several apples on a distant tree. Would you say 'These are apples' or 'Those are apples'?",
    "Because the apples are plural and far away on the tree, we say 'Those are apples'!",
    "Those are apples 🍎",
    "Demonstrative comes from the Latin word 'demonstrare', which means 'to point out clearly'!",
    "Touch your shoes: 'These are my shoes.' Point to the stars: 'Those are stars!'"
  ),
  makeCh(
    'eng_c2_icse_05', 5, 'Verbs: Action Words and Helping Verbs (is, are, was, were)', 'Class 2', 'icse', '⚡',
    'Understand primary auxiliary helping verbs in present (is/are) and past (was/were) tense with subjects!',
    ['Action Verbs (write, read, build)', 'Present Helping Verbs (is, am, are)', 'Past Helping Verbs (was, were)', 'Singular vs Plural Concord'],
    ["Use 'was' with singular subjects in the past: He was sleepy.", "Use 'were' with plural subjects and 'you' in the past: They were playing.", "Helping verbs state when the action happened."],
    "Fill in the blank for past tense: 'The boys ______ very excited about the school picnic yesterday.'",
    "'Boys' is plural and the time is past (yesterday), so we use 'were'!",
    "Were 🎒",
    "The verb 'to be' (am, is, are, was, were, been) is the most frequently used verb in the entire English language!",
    "Singular = was (He was, She was, It was). Plural = were (We were, They were, You were)!"
  ),
  makeCh(
    'eng_c2_icse_06', 6, 'Adjectives: Describing Qualities, Sizes & Feelings', 'Class 2', 'icse', '🎨',
    'Classify adjectives into qualities, quantities, colors, sizes, and emotional states!',
    ['Adjectives of Quality (brave, kind, dishonest)', 'Adjectives of Quantity & Number (some, many, four)', 'Emotions & Feelings (cheerful, nervous)', 'Sensory Adjectives'],
    ["Adjectives qualify nouns by giving specific details about their nature.", "They can appear before the noun (a gentle breeze) or after a linking verb (The breeze was gentle)."],
    "Identify the two adjectives in: 'The brave knight wore shiny armor.'",
    "'Brave' describes the knight, and 'shiny' describes the armor! Both are adjectives of quality.",
    "Brave and Shiny 🛡️",
    "Poets rely on rich adjectives to evoke powerful emotions in just a few lines of verse!",
    "When writing stories, don't just say 'a dog': say 'a playful, golden puppy'!"
  ),
  makeCh(
    'eng_c2_icse_07', 7, 'Prepositions of Place and Direction', 'Class 2', 'icse', '🧭',
    'Learn prepositions showing exact location and movement: between, among, into, through, and above!',
    ['Between (two items)', 'Among (three or more)', 'Into (movement inside)', 'Through (passage)', 'Above & Below'],
    ["Use 'between' when referring to two persons or objects: Sit between John and Mary.", "Use 'among' when referring to more than two: Distribute sweets among all the students.", "Use 'into' to show motion entering inside: The frog jumped into the pond."],
    "Choose the correct word: 'The diver jumped ______ the swimming pool.'",
    "Because there is motion from outside to inside the water, we use 'into'!",
    "Into the pool 🏊",
    "The distinction between 'between' (two) and 'among' (three or more) has been observed for over 500 years!",
    "Between two friends; among a whole crowd!"
  ),
  makeCh(
    'eng_c2_icse_08', 8, 'Conjunctions: Joining Sentences with And, But, Or', 'Class 2', 'icse', '🔗',
    'Construct compound ideas by joining sentences using coordinating conjunctions: and, but, and or!',
    ['And (addition of ideas)', 'But (contrast or exception)', 'Or (choices and alternatives)', 'Avoiding Repetition in Joined Sentences'],
    ["Use 'and' to connect similar statements.", "Use 'but' to introduce an opposing idea.", "Use 'or' when offering a choice between alternatives: Would you like tea or milk?"],
    "Which conjunction connects: 'Would you like to read a story ______ play outside?'",
    "This offers an alternative choice between two activities, so we use 'or'!",
    "Or 📖",
    "In logic and mathematics, AND and OR are fundamental operators just like addition and subtraction!",
    "Use 'and' to add, 'but' to contrast, and 'or' to choose!"
  ),
  makeCh(
    'eng_c2_icse_09', 9, 'Punctuation & Sentence Types: Statements and Questions', 'Class 2', 'icse', '❓',
    'Distinguish between assertive telling sentences (statements) and interrogative asking sentences (questions)!',
    ['Assertive Sentences (Statements)', 'Interrogative Sentences (Questions)', 'WH-Question Words (Who, What, Where, When, Why, How)', 'Proper Punctuation Marks'],
    ["A statement provides information and ends with a full stop (.).", "A question asks for information using question words (Who, What, Where) or inverted verbs, and ends with a question mark (?)."],
    "Identify the sentence type: 'Where did you find this golden key?'",
    "This sentence begins with the interrogative word 'Where' and asks for information: it is a Question!",
    "Question (Interrogative) 🗝️",
    "In Spanish, questions have two question marks: an upside-down one at the start (¿) and one at the end (?)!",
    "If you can answer it with an answer, it's a question: put a question mark '?' at the end!"
  ),
  makeCh(
    'eng_c2_icse_10', 10, 'Guided Composition: Short Paragraph & Picture Narration', 'Class 2', 'icse', '📝',
    'Write cohesive 4 to 5 sentence paragraphs with a title, opening topic sentence, supporting facts, and concluding line!',
    ['Title Selection', 'Topic Sentence', 'Connecting Sentences', 'Capitalization & Punctuation Review'],
    ["A good paragraph focuses on one single main idea.", "Always begin with a strong topic sentence that tells the reader what the paragraph is about.", "Check spelling and full stops before finishing."],
    "When writing a paragraph about 'My Pet Dog', which would make the best opening topic sentence?",
    "'I have a cheerful golden retriever named Bruno who is my best friend.' clearly introduces the topic and pet!",
    "A clear sentence introducing your pet's name and kind 🐕",
    "The word 'paragraph' comes from Greek 'paragraphos', which was a little mark drawn in the margin to show a new thought!",
    "Think of a paragraph like a sandwich: topic sentence top bun, tasty details filling, conclusion bottom bun!"
  )
);

module.exports = { list };
