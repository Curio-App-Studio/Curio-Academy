// scripts/build_english_curriculum.js
const fs = require('fs');
const path = require('path');

function makeCh(id, num, title, grade, board, icon, desc, concepts, rules, q, exp, ans, fact, advice) {
  return {
    chapterId: id,
    chapterNumber: num,
    title,
    grade,
    board,
    subjectId: 'english',
    icon,
    description: desc,
    keyConcepts: concepts,
    rules: rules,
    exampleQuestion: q,
    exampleExplanation: exp,
    exampleAnswer: ans,
    funFact: fact,
    mascotAdvice: advice,
    activityIds: []
  };
}

const list = [];

// ==========================================
// LKG (5 Chapters - all)
// ==========================================
list.push(
  makeCh(
    'eng_lkg_ch01', 1, 'Phonics & Alphabet Sounds (A to Z)', 'LKG', 'all', '🔤',
    'Learn letter sounds, matching big letters (A) to small letters (a), and fun alphabet rhymes!',
    ['Letter Recognition A-Z', 'Phonic Sounds', 'Upper & Lower Case', 'Alphabet Song'],
    ["Every letter makes a sound: 'A' says /æ/ as in Apple, 'B' says /b/ as in Ball.", "Capital letters start our names, and small letters are used inside words."],
    "Which letter sound does the word 'Sun' start with?",
    "When we say 'Sun', the very first sound we make is /s/, which is the letter S!",
    "Letter S (as in Sun)",
    "The word 'alphabet' comes from the first two letters of the Greek alphabet: Alpha and Beta!",
    "Make letter shapes with playdough or in the sand to remember their curves!"
  ),
  makeCh(
    'eng_lkg_ch02', 2, 'Rhyming Words & Picture Naming', 'LKG', 'all', '🐱',
    'Discover words that sound the same at the end like Cat & Bat, and name everyday toys and animals!',
    ['Rhyming Endings', 'Picture Vocabulary', 'Animal Sounds', 'Word Repetition'],
    ["Rhyming words have the exact same ending sound: Cat rhymes with Hat, Mat, and Bat.", "Looking at picture clues helps us identify the first letter of words."],
    "Which word rhymes with 'Cat'?",
    "Cat and Hat end with the same 'at' sound! So Hat rhymes with Cat.",
    "Hat 🎩",
    "Nursery rhymes help our brains recognize speech sounds faster and build strong listening memory!",
    "Clap your hands whenever you hear two words that rhyme in a song!"
  ),
  makeCh(
    'eng_lkg_ch03', 3, 'Fun with Letters: Tracing & Shapes', 'LKG', 'all', '✏️',
    'Trace straight standing lines, sleeping lines, curves, and form big uppercase letters from A to Z!',
    ['Standing & Sleeping Lines', 'Slanting Lines', 'Curved Lines', 'Letter Formation'],
    ["Lines can be standing (vertical), sleeping (horizontal), or slanting.", "Letter O is round like a ball, while letter T has a sleeping line on a standing line."],
    "Which letter is made of one round circle like a ring?",
    "The letter O is completely round with no corners, just like a ring or donut!",
    "Letter O 🍩",
    "Ancient writing started as little carved pictures on clay tablets and cave walls!",
    "Hold your crayon gently like a little bird, not too tight!"
  ),
  makeCh(
    'eng_lkg_ch04', 4, 'Action Words & Nursery Fun', 'LKG', 'all', '🏃',
    'Sing, clap, hop, and jump! Learn action words that tell what our bodies can do.',
    ['Clapping, Stamping, Jumping', 'Action Songs', 'Following Simple Instructions', 'Body Movement Verbs'],
    ["Action words tell what we are doing: run, clap, hop, smile.", "We can act out the words as we say them out loud."],
    "What action do you do when you hear good music: 'clap' or 'sleep'?",
    "We clap our hands with the beat to enjoy the music!",
    "Clap hands 👏",
    "Singing songs helps little children remember new words twice as fast as just reading!",
    "Whenever you jump or run outside, shout the action word: 'I am jumping!'"
  ),
  makeCh(
    'eng_lkg_ch05', 5, 'Opposites & Daily Words', 'LKG', 'all', '🌓',
    'Discover opposites like Big & Small, Up & Down, Hot & Cold, and Happy & Sad!',
    ['Big vs Small', 'Up vs Down', 'Hot vs Cold', 'Day vs Night'],
    ["Opposites are word pairs that mean the completely reverse thing of each other.", "An elephant is big, and an ant is small."],
    "What is the opposite of 'Up'?",
    "Up means towards the sky, and Down means towards the ground. So the opposite of Up is Down!",
    "Down ⬇️",
    "The sun gives us day, and the moon visits us at night: nature's ultimate opposite pair!",
    "Look around your home: find one hot thing (soup) and one cold thing (ice cube)!"
  )
);

// ==========================================
// UKG (6 Chapters - all)
// ==========================================
list.push(
  makeCh(
    'eng_ukg_ch01', 1, 'Vowels & Consonants (A, E, I, O, U)', 'UKG', 'all', '⭐',
    'Meet the 5 super vowel friends: A, E, I, O, U, and learn how they give voice to words!',
    ['5 Vowels (A, E, I, O, U)', '21 Consonants', 'CVC Words', 'Vowel Sounds'],
    ["The 5 special letters are A, E, I, O, U. All other 21 letters are consonants.", "Almost every English word needs at least one vowel to be spoken out loud."],
    "Which of these is a special Vowel letter?",
    "The vowels are A, E, I, O, and U. Letter 'E' is one of the five vowels!",
    "E 🌟",
    "The word 'facetious' contains all five vowels in alphabetical order: a, e, i, o, u!",
    "Touch your thumb and 4 fingers to remember the 5 vowels: A, E, I, O, U!"
  ),
  makeCh(
    'eng_ukg_ch02', 2, 'Sight Words & Three-Letter CVC Words', 'UKG', 'all', '👁️',
    'Read simple three-letter words like P-E-N and catch sight words like THE, AND, IS at a glance!',
    ['Sight Words (the, is, in, at, on)', 'Blending 3 Letters', 'Short Vowel Sounds', 'Reading Simple Sentences'],
    ["Sight words are common words we recognize instantly by sight without sounding out every letter.", "Blend the sounds together: /b/ + /e/ + /d/ = bed!"],
    "Read and blend the sounds: /p/ + /i/ + /g/. What word is it?",
    "When we blend /p/, /i/, and /g/ together smoothly, it forms the word 'pig'!",
    "Pig 🐷",
    "Just 100 sight words make up about half of all written English in children's storybooks!",
    "Spot sight words on street signs, milk cartons, and storybooks every day!"
  ),
  makeCh(
    'eng_ukg_ch03', 3, 'Word Families (-at, -en, -in, -op, -ug)', 'UKG', 'all', '🏠',
    'Group words with identical rhyming word family houses like cat/mat, hen/pen, and sun/run!',
    ['-at family (bat, cat, rat)', '-en family (hen, pen, ten)', '-in family (bin, pin, tin)', '-ug family (bug, jug, mug)'],
    ["Words in the same word family share the exact same vowel and final consonant sound.", "Changing the first letter creates a brand new word in the family."],
    "Which word belongs to the '-ug' family: 'Mug' or 'Map'?",
    "Mug ends with '-ug' (/ʌɡ/), so it belongs to the -ug word family house!",
    "Mug ☕",
    "Word families make learning to read 10 times faster because if you can read 'cat', you can read 10 other words!",
    "Build a word ladder by swapping only the first letter: bag -> rag -> tag!"
  ),
  makeCh(
    'eng_ukg_ch04', 4, 'Simple Action Words & Opposites', 'UKG', 'all', '⚡',
    'Learn everyday verbs and opposite concepts like open/shut, push/pull, and hot/cold!',
    ['Action Verbs (eat, drink, play)', 'Opposite Pairs', 'Descriptive Pairs', 'Picture Action Matching'],
    ["An action word tells what someone is doing right now.", "Opposites give the reverse meaning: open the door vs shut the door."],
    "What is the opposite of 'Open'?",
    "The opposite of opening something is closing or shutting it: 'Close' or 'Shut'!",
    "Close / Shut 🚪",
    "Cheetahs are the fastest land runners, while snails are the slowest: nature's living opposites!",
    "Act out opposite words: reach high up to the sky, then touch down low to the floor!"
  ),
  makeCh(
    'eng_ukg_ch05', 5, 'This, That & Simple Sentences', 'UKG', 'all', '👆',
    "Point near with 'This is' and point far with 'That is' to build your very first complete sentences!",
    ['Using "This is" for near objects', 'Using "That is" for far objects', 'Capital Letter at Start', 'Full Stop at End'],
    ["Use 'This' when an object is close to you: 'This is my pencil.'", "Use 'That' when an object is far away: 'That is a bird in the sky.'"],
    "A mango is in your hand. Would you say 'This is a mango' or 'That is a mango'?",
    "Because the mango is in your hand right next to you, you say 'This is a mango'!",
    "This is a mango 🥭",
    "The word 'This' is one of the oldest words in the English language, used for over a thousand years!",
    "Touch your nose and say 'This is my nose!' Point to the ceiling and say 'That is the fan!'"
  ),
  makeCh(
    'eng_ukg_ch06', 6, 'Picture Talk & Story Time', 'UKG', 'all', '📖',
    'Look at vibrant story scenes, describe what animals and kids are doing, and answer simple story questions!',
    ['Picture Observation', 'Who, What, Where', 'Character Identification', 'Expressing Thoughts Aloud'],
    ["Look at the full picture carefully before answering who, what, or where.", "A character is who the story is about: a girl, a puppy, or a friendly bear."],
    "In a picture of children playing in the rain with umbrellas, what season is it?",
    "Umbrellas and raindrops show that it is the rainy (monsoon) season!",
    "Rainy Season 🌧️",
    "Every great book ever written started as a simple picture or idea in someone's imagination!",
    "Tell your family a bedtime story about your favorite animal or toy today!"
  )
);

// We will export helper to add grades
module.exports = { list, makeCh };
