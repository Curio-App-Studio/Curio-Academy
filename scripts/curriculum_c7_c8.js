// scripts/curriculum_c7_c8.js
const { makeCh } = require('./curriculum_base');

const list = [];

// =========================================================================
// CLASS 7 - CBSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c7_cbse_01', 1, 'Reported Speech: Statements, Commands & Questions', 'Class 7', 'cbse', '🗣️',
    'Master reporting statements, questions (if/whether & WH-words), and imperative commands/requests with accurate backshift!',
    ['Backshift of Tenses (Present -> Past, Past -> Past Perfect)', 'Pronoun & Time Changes (now -> then, today -> that day)', 'Questions (asked if/whether)', 'Orders & Requests (ordered/requested + to-infinitive)'],
    ["When reporting verb is past ('said'), tenses shift back: 'I am' becomes 'he was', 'I have' becomes 'he had'.", "Universal truths DO NOT shift tense: Teacher said, “Water boils at 100°C” -> Teacher said that water boils at 100°C.", "For yes/no questions, use 'if' or 'whether': He asked if I was coming."],
    "Convert to reported speech: She said, “I bought a new laptop yesterday.”",
    "Past simple 'bought' shifts to past perfect 'had bought', and 'yesterday' becomes 'the previous day'.",
    "She said that she had bought a new laptop the previous day 💻",
    "If the reporting verb is in present tense ('She says...'), the reported tense does not change at all!",
    "Watch out for universal truths: the sun still rises in the east, so don't change it to 'rose'!"
  ),
  makeCh(
    'eng_c7_cbse_02', 2, 'Subject-Verb Concord: Advanced Rules & Inversions', 'Class 7', 'cbse', '⚖️',
    'Solve tricky concord challenges: indefinite pronouns, collective nouns, intervening phrases, and inverted sentence syntax!',
    ['Indefinite Pronouns (each, every, neither, either take singular verbs)', 'Parenthetical phrases (accompanied by, as well as, together with)', 'Nouns plural in form but singular in concept (Physics, News, Economics)', 'Inverted subjects after "there" and "here"'],
    ["Words like 'each', 'everyone', 'nobody' are grammatically singular: Everyone has submitted their assignment.", "Parenthetical phrases like 'as well as' do not compound the subject number: The captain, as well as the players, was honored.", "'Physics' and 'News' take singular verbs."],
    "Choose the correct verb: 'The news ______ (was / were) broadcast to the entire nation.'",
    "'News' is an uncountable singular noun, so it takes the singular verb 'was'!",
    "Was broadcast 📰",
    "'News' was coined in the 14th century from 'new things', treated grammatically as a mass singular noun!",
    "Strip away parenthetical phrases inside commas: only the true head subject controls the verb!"
  ),
  makeCh(
    'eng_c7_cbse_03', 3, 'Conditionals: Zero, First & Second Conditionals', 'Class 7', 'cbse', '🔀',
    'Express cause and effect (Zero), future possibilities (First), and hypothetical imaginary situations (Second) with If-clauses!',
    ['Zero Conditional (Facts: If + present, present)', 'First Conditional (Real Future: If + present, will + V1)', 'Second Conditional (Hypothetical: If + past, would + V1)', 'Unless = If not'],
    ["Zero: If you heat ice, it melts (scientific certainty).", "First: If it rains tomorrow, we will stay home (realistic possibility).", "Second: If I won the lottery, I would travel the world (imaginary hypothetical)."],
    "Complete the first conditional: 'If you study consistently, you ______ (achieve) top marks.'",
    "First conditional uses 'If + simple present', followed by 'will + base verb': 'will achieve'!",
    "Will achieve 🎯",
    "In formal English, the subjunctive 'were' is used for all persons in second conditionals: 'If I were you', not 'If I was you'!",
    "Real possibility = If + present, WILL. Imaginary hypothetical = If + past, WOULD!"
  ),
  makeCh(
    'eng_c7_cbse_04', 4, 'Non-Finite Verbs: Infinitives, Gerunds & Participles', 'Class 7', 'cbse', '🎭',
    'Unlock verbs that do not change with tense or person: to-infinitives, -ing gerunds as nouns, and participles as adjectives!',
    ['Infinitives (to + verb: to err is human)', 'Gerunds (-ing verb acting as a noun: Swimming is great exercise)', 'Present Participles (adjective: barking dog)', 'Past Participles (adjective: broken glass)'],
    ["A Finite verb changes with the subject and tense (I walk, he walks, we walked).", "A Non-Finite verb never changes with tense or number: to eat, eating, eaten.", "A Gerund functions as a noun (subject or object): I enjoy reading."],
    "In 'Smoking is injurious to health', what grammatical role does 'Smoking' play?",
    "'Smoking' is a verb ending in -ing acting as the subject noun of the sentence: that is a Gerund!",
    "Gerund (Noun) 🚭",
    "Participles can create funny errors called 'dangling modifiers': 'Walking into the room, the phone rang' makes it sound like the phone was walking!",
    "If an -ing word can be replaced by 'it' or 'something', it's a Gerund acting as a noun!"
  ),
  makeCh(
    'eng_c7_cbse_05', 5, 'Modal Auxiliaries: Deduction, Obligation & Advice', 'Class 7', 'cbse', '🛡️',
    'Use modals for logical deduction (must be, can’t be), past obligation (should have), and polite advisability (ought to)!',
    ['Modals of Logical Deduction (must be, can’t be, might be)', 'Past Modals (should have + V3, could have + V3)', 'Degrees of Certainty', 'Semi-modals (used to, need, dare)'],
    ["Use 'must be' for strong affirmative deduction: The lights are on, so he must be home.", "Use 'can't be' for strong negative deduction: That can't be true.", "Use 'should have + V3' for past regrets: You should have listened to the doctor."],
    "Which modal expression indicates past regret: 'We ______ (leave) earlier to avoid the traffic.'",
    "'Should have left' indicates that leaving earlier was advisable in the past but was not done!",
    "Should have left 🚗",
    "The English word 'ought' originally was the past tense of 'owe', meaning what one owes to moral duty!",
    "Must be = 99% sure it is. Can't be = 99% sure it isn't. Should have = past regret!"
  ),
  makeCh(
    'eng_c7_cbse_06', 6, 'Active and Passive Voice: Modals and Perfect Tenses', 'Class 7', 'cbse', '🔄',
    'Transform complex structures into passive voice: modal auxiliaries, Present/Past Perfect, and sentences with two objects!',
    ['Passive with Modals (modal + be + past participle)', 'Passive in Present & Past Perfect (has/have/had + been + V3)', 'Verbs with Direct and Indirect Objects', 'Prepositional Verbs in Passive'],
    ["Passive with Modals: Subject + modal + be + V3: You must submit the form -> The form must be submitted by you.", "When a sentence has two objects, either can become the subject: They gave me a prize -> I was given a prize OR A prize was given to me."],
    "Transform to passive: 'You must lock all doors before leaving.'",
    "Modal passive formula: 'All doors must be locked before leaving.'",
    "All doors must be locked 🔐",
    "Legal statutes and instruction manuals almost exclusively use modal passives: 'Applications must be submitted by Friday'!",
    "Modal + active = modal + V1. Modal + passive = modal + be + V3!"
  ),
  makeCh(
    'eng_c7_cbse_07', 7, 'Prepositions of Direction, Motion and Time', 'Class 7', 'cbse', '🧭',
    'Master advanced prepositions: across, along, through, past, onto, off, towards, throughout, and during!',
    ['Prepositions of Motion (onto, off, into, out of)', 'Prepositions of Trajectory (past, along, across, through)', 'Prepositions of Duration (throughout, during, over)', 'Prepositional Nuance in Extended Writing'],
    ["Use 'onto' for movement to an elevated surface: The cat leaped onto the refrigerator.", "Use 'throughout' for continuous presence across time or space: It rained throughout the entire night."],
    "Complete the sentence: 'The explorer hiked ______ the freezing arctic blizzard.'",
    "Moving continuously across an ongoing weather phenomenon requires 'through': 'through the blizzard'!",
    "Through the blizzard ❄️",
    "Prepositions are among the oldest functional words in human language, dating back to Proto-Indo-European roots!",
    "Onto = motion to top. Into = motion to interior. Through = motion from one end to other inside!"
  ),
  makeCh(
    'eng_c7_cbse_08', 8, 'Clauses: Relative Clauses with Defining & Non-Defining Rules', 'Class 7', 'cbse', '📐',
    'Master Defining relative clauses (essential information, no commas) versus Non-Defining clauses (extra information, with commas)!',
    ['Defining / Restrictive Relative Clauses (essential to identity)', 'Non-Defining / Non-Restrictive Clauses (extra info with commas)', 'Who vs Whom vs Whose', 'Which vs That rules'],
    ["Defining: The doctor [who treated me] was kind (tells which doctor; no commas).", "Non-Defining: Dr. Sharma, [who is my neighbor], is very kind (extra information; surrounded by commas).", "'That' is only used in defining clauses."],
    "Punctuate correctly: 'My elder brother who lives in London is a software engineer.'",
    "Since I only have one elder brother, the clause is non-defining (extra info): 'My elder brother, who lives in London, is a software engineer.'",
    "Commas around 'who lives in London' 🇬🇧",
    "Omitting commas in non-defining clauses can change the entire meaning of legal contracts and treaties!",
    "Test: Can you drop the clause without losing who the subject is? If yes, wrap it in commas!"
  ),
  makeCh(
    'eng_c7_cbse_09', 9, 'Integrated Grammar: Sentence Reordering & Cloze Gap Filling', 'Class 7', 'cbse', '✍️',
    'Solve CBSE board grammar tasks: unscramble jumbled words into coherent sentences and complete cloze passages!',
    ['Jumbled Word Reconstruction', 'Identifying Head Subject and Verb in Jumbled Segments', 'Cloze Gap-Filling (articles, prepositions, verb forms)', 'Grammatical Cohesion'],
    ["In jumbled words, find the subject and main verb first.", "Match prepositions to nouns and adjectives.", "Read the finished sentence aloud to verify that the rhythm and syntax are standard English."],
    "Rearrange into a meaningful sentence: 'greatest / the / health / wealth / is / of / all'",
    "'Health is the greatest wealth of all.'",
    "Health is the greatest wealth of all 🌟",
    "Cloze tests were invented in 1953 by Wilson Taylor to measure text readability and comprehension automatically!",
    "Sentence building formula: Find Subject -> Find Finite Verb -> Attach Objects & Prepositional Phrases!"
  ),
  makeCh(
    'eng_c7_cbse_10', 10, 'Idioms, Proverbs & Figurative Language in Context', 'Class 7', 'cbse', '💡',
    'Interpret figurative idioms, timeless cultural proverbs, and distinguish literal truth from rhetorical metaphor in texts!',
    ['Idioms in Discourse', 'Proverbs and Cultural Values', 'Figurative Language in Media', 'Avoiding Clichés in Writing'],
    ["'Burn the candle at both ends' means working late into the night and waking up early.", "'Bite off more than you can chew' means taking on a commitment larger than you can handle."],
    "What does the idiom 'burn the midnight oil' mean?",
    "It means to stay awake working or studying late into the night!",
    "Working late into the night 🕯️",
    "Before electric lighting was invented in the late 19th century, scholars literally burned oil in lamps to read after dark!",
    "Use idioms sparingly like seasoning on a dish: one well-placed idiom enhances your writing immensely!"
  ),
  makeCh(
    'eng_c7_cbse_11', 11, 'Writing: Diary Entry and Formal Letter to Editor', 'Class 7', 'cbse', '✉️',
    'Master the introspective format of Diary Writing and the public civic advocacy format of Formal Letters to the Editor!',
    ['Diary Entry Format (Day, Date, Time, Introspective Tone, First Person, Sign-off)', 'Letter to the Editor Format (Sender Address, Date, Receiver Address, Subject, Salutation, 3-Paragraph Body, Subscription)', 'Civic Tone & Problem Solving', 'Word Count Discipline'],
    ["A Diary Entry expresses personal emotional reflections in first person ('I felt...').", "A Letter to the Editor discusses a public civic issue: Para 1 introduces the issue, Para 2 explains impact, Para 3 offers constructive solutions."],
    "What is the standard opening phrase for a formal Letter to the Editor?",
    "“Through the columns of your esteemed newspaper, I wish to draw the attention of the authorities concerned...”",
    "Through the columns of your esteemed newspaper 📰",
    "Anne Frank's diary, written while hiding during World War II, is one of the most widely read books in human history!",
    "Diary = intimate and personal. Letter to Editor = formal, public, and civic-minded!"
  ),
  makeCh(
    'eng_c7_cbse_12', 12, 'Critical Reading: Tone, Theme and Contextual Clues', 'Class 7', 'cbse', '📖',
    'Analyze author perspective, identify literary tone (humorous, nostalgic, sarcastic, somber), and deduce underlying themes!',
    ['Author’s Purpose (Persuade, Inform, Entertain, Criticize)', 'Identifying Tone & Mood', 'Underlying Central Themes', 'Contextual Meaning of Nuanced Vocabulary'],
    ["Tone reflects the author's attitude towards the subject (e.g. humorous, serious, critical).", "Theme is the deeper underlying truth about life that the text reveals (e.g. loyalty, courage against adversity)."],
    "If an author describes a character's foolish boastfulness with gentle teasing irony, what is the tone?",
    "The tone is 'humorous' or 'satirical'!",
    "Humorous / Satirical 🎭",
    "Tone is created primarily through word choice (diction) and sentence arrangement (syntax)!",
    "Ask yourself: How does the author feel about what they are describing? Angry? Joyful? Neutral? That is the Tone!"
  )
);

// =========================================================================
// CLASS 7 - ICSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c7_icse_01', 1, 'Synthesis of Sentences: Participles, Infinitives & Gerunds', 'Class 7', 'icse', '🏗️',
    'Combine two or more simple sentences into a single elegant simple sentence using participles, infinitives, and prepositional gerunds!',
    ['Combining using Present Participles (Seeing the police, the thief fled)', 'Combining using Past Participles', 'Combining using Infinitives (He worked hard to pass the exam)', 'Combining using Noun/Gerund with Preposition'],
    ["When two actions are performed by the same subject, the earlier action can become a present participle: 'He took his hat. He went out.' -> 'Taking his hat, he went out.'", "Use infinitives to express purpose: 'I went to the market to buy books.'"],
    "Combine into one simple sentence: 'The hunter raised his rifle. He shot the fierce tiger.'",
    "Using present participle: 'Raising his rifle, the hunter shot the fierce tiger.'",
    "Raising his rifle, the hunter shot the tiger 🐅",
    "Synthesis is the definitive hallmark of mature classical writing, transforming juvenile choppy sentences into sweeping prose!",
    "Ensure the subject of the participle is the same as the main clause to prevent dangling participles!"
  ),
  makeCh(
    'eng_c7_icse_02', 2, 'Synthesis of Sentences: Conjunctions & Relative Pronouns', 'Class 7', 'icse', '🔗',
    'Combine multiple short sentences into compound sentences (using coordinating conjunctions) and complex sentences (using relative pronouns and subordinate conjunctions)!',
    ['Coordinating Conjunctions (Cumulative, Adversative, Disjunctive, Illative)', 'Subordinating Conjunctions of Cause, Condition, and Time', 'Relative Pronouns (who, which, that) in Synthesis', 'Compound-Complex Sentences'],
    ["Cumulative conjunctions add ideas (and, both...and, not only...but also).", "Adversative conjunctions show opposition (but, yet, whereas, while).", "Relative pronouns join clauses into complex sentences: 'I met a girl. She was very kind.' -> 'I met a girl who was very kind.'"],
    "Combine using 'not only... but also': 'He is intelligent. He is industrious.'",
    "'He is not only intelligent but also industrious.'",
    "He is not only intelligent but also industrious 🌟",
    "Correlative conjunctions like 'not only... but also' require strict parallel grammatical structure on both sides!",
    "Check parallelism: If an adjective follows 'not only', an adjective must follow 'but also'!"
  ),
  makeCh(
    'eng_c7_icse_03', 3, 'Transformation of Sentences: Affirmative, Negative & Interrogative', 'Class 7', 'icse', '🔄',
    'Transform sentence structures without altering meaning: Affirmative to Negative, Interrogative to Assertive, and Exclamatory to Assertive!',
    ['Affirmative to Negative using Antonyms (He is honest -> He is not dishonest)', 'Negative using "None but" / "No sooner... than"', 'Interrogative to Assertive (rhetorical questions)', 'Exclamatory to Assertive'],
    ["To make a sentence negative without changing meaning, combine 'not' with an antonym: He is rich -> He is not poor.", "Transform rhetorical questions: 'Who does not love his country?' -> 'Everyone loves his country.'", "'As soon as' transforms to 'No sooner... than'."],
    "Transform into Negative without changing meaning: 'Everyone found the story fascinating.'",
    "Combine negative with antonym: 'No one found the story dull (uninteresting).' OR 'There was no one who did not find the story fascinating.'",
    "No one found the story dull 📖",
    "Transforming sentences while preserving exact truth value is a fundamental skill in legal and formal English!",
    "Remember: The core meaning must remain 100% unchanged! Check by translating both sentences back and forth."
  ),
  makeCh(
    'eng_c7_icse_04', 4, 'Direct and Indirect Speech: Dialogue Conversion & Exclamations', 'Class 7', 'icse', '🗣️',
    'Convert complex multi-speaker dialogues, exclamations (Alas, Hurrah), and optative blessings into indirect speech!',
    ['Exclamatory Sentences in Reported Speech (exclaimed with joy / sorrow / wonder)', 'Optative Sentences (prayed that, wished that)', 'Multi-turn Dialogues in passages', 'Eliminating interjections (Hurrah!, Alas!)'],
    ["Replace interjections with vivid descriptive phrases: He said, “Hurrah! We won” -> He exclaimed with delight that they had won.", "Alas -> exclaimed with sorrow; Bravo -> applauded him saying that..."],
    "Convert to reported speech: The captain said, “Bravo! You played exceptionally well.”",
    "The captain applauded him, saying that he had played exceptionally well.",
    "The captain applauded him 🏆",
    "In reporting exclamations, the emotion of the speaker is encapsulated directly into the reporting verb phrase!",
    "Never repeat words like 'Hurrah' or 'Alas' inside indirect speech: turn them into 'exclaimed with joy'!"
  ),
  makeCh(
    'eng_c7_icse_05', 5, 'Non-Finite Verbs: Gerunds vs Present Participles', 'Class 7', 'icse', '🎭',
    'Distinguish between words ending in -ing acting as Verbal Nouns (Gerunds) versus those acting as Verbal Adjectives (Present Participles)!',
    ['Gerund as Subject, Object, or Object of Preposition', 'Present Participle as Adjective modifying a noun', 'Participle in Continuous Verb Tense', 'Dangling / Unattached Participles'],
    ["A Gerund is a verb ending in -ing that functions as a noun: 'Swimming is healthy.'", "A Participle is a verb ending in -ing that functions as an adjective: 'Look at the swimming duck.'", "Test: If you can replace it with 'it', it is a Gerund!"],
    "In 'I love reading mystery novels', what grammatical function does 'reading' perform?",
    "'Reading' answers what I love (object of verb 'love') as a verbal noun: it is a Gerund!",
    "Gerund (Verbal Noun) 📚",
    "The Gerund carries over the nominal properties of Old English nouns ending in '-ung'!",
    "Ask: Is it naming an activity (Gerund)? Or is it describing a noun doing the activity (Participle)?"
  ),
  makeCh(
    'eng_c7_icse_06', 6, 'Subject-Verb Agreement: Indefinite Pronouns & Collective Nouns', 'Class 7', 'icse', '⚖️',
    'Master advanced concord: Indefinite pronouns (each, either, neither, none), nouns with plural forms, and collective nouns acting as units vs individuals!',
    ['Collective Noun as a single unit (takes singular verb: The jury was unanimous)', 'Collective Noun as separate individuals (takes plural verb: The jury were divided in their opinions)', 'None (singular or plural in usage)', 'Quantifiers with mass vs count nouns'],
    ["When members of a collective noun act in unison, use a singular verb: The committee has agreed.", "When members act separately or disagree, use a plural verb: The committee are divided.", "'None' can take singular or plural depending on sense: None of the cake is left / None of the students were absent."],
    "Choose the correct verb: 'The jury ______ (was / were) divided in their opinions.'",
    "Because the members of the jury are in disagreement acting as separate individuals, we use 'were'!",
    "Were divided ⚖️",
    "British English frequently treats collective nouns as plural (The government are...), while American English treats them as singular!",
    "United in decision = Singular verb (was). Divided in disagreement = Plural verb (were)!"
  ),
  makeCh(
    'eng_c7_icse_07', 7, 'Conditionals: Type 1, 2 and Inverted Conditionals', 'Class 7', 'icse', '🔀',
    'Master conditional clauses: Open Future (Type 1), Hypothetical Present (Type 2), and Inverted conditional syntax without "If" (Were I, Had I)!',
    ['Conditional Type 1 (If + present, will/can + V1)', 'Conditional Type 2 (If + past, would/could + V1)', 'Inversion in Conditionals (Should you need help... / Were I in your place...)', 'Subjunctive "Were" for all subjects'],
    ["In formal English, invert without 'if': 'If you should require assistance' becomes 'Should you require assistance'.", "'If I were a bird' becomes 'Were I a bird, I would fly to you.'"],
    "Invert the conditional without using 'If': 'If I were the prime minister, I would reduce taxes.'",
    "Inverting subject and subjunctive verb: 'Were I the prime minister, I would reduce taxes.'",
    "Were I the prime minister 🏛️",
    "Conditional inversion is common in formal parliamentary debates and high-level diplomatic treaties!",
    "Drop 'if', move the auxiliary verb to the front: 'If I were...' becomes 'Were I...'!"
  ),
  makeCh(
    'eng_c7_icse_08', 8, 'Prepositions: Fixed Prepositions with Adjectives & Verbs', 'Class 7', 'icse', '🧭',
    'Master fixed combinations: prohibited from, capable of, proficient in, adverse to, acquainted with, and oblivious of!',
    ['Verbs followed by specific prepositions (accuse of, charge with, refrain from)', 'Adjectives followed by specific prepositions (congenial to, conscious of, addicted to)', 'Distinguishing confusing prepositions (die of illness vs die from overwork)', 'Prepositional Concord'],
    ["A person dies 'of' a disease (died of cholera), but dies 'from' an external cause or overwork (died from exhaustion).", "We are 'accused of' a crime, but 'charged with' a crime."],
    "Fill in the blank: 'The old general died ______ pneumonia during the harsh winter.'",
    "For death caused directly by a disease, standard English uses 'of': 'died of pneumonia'!",
    "Died of pneumonia ❄️",
    "Fixed prepositions are an inherited idiomatic feature of English with origins spanning Norman French and Anglo-Saxon usage!",
    "Disease = die OF. External cause = die FROM. Refrain = FROM. Accused = OF!"
  ),
  makeCh(
    'eng_c7_icse_09', 9, 'Figures of Speech: Onomatopoeia, Irony, Alliteration & Oxymoron', 'Class 7', 'icse', '🎭',
    'Analyze figurative devices: Onomatopoeia (sound words), Irony (saying the opposite of what is meant), and Oxymoron (contradictory terms paired together)!',
    ['Onomatopoeia (words that imitate natural sounds: buzz, hiss, rustle, splash)', 'Situational and Verbal Irony', 'Oxymoron (pairing contradictory terms: deafening silence, bittersweet)', 'Literary Aesthetic Evaluation'],
    ["Onomatopoeia creates auditory imagery: The bees buzzed; the leaves rustled in the breeze.", "An Oxymoron places two seemingly contradictory words side by side: 'open secret', 'bittersweet', 'deafening silence'."],
    "Identify the figure of speech: 'There was a deafening silence in the courtroom.'",
    "Pairing 'deafening' (extremely loud) with 'silence' (complete absence of sound) is an Oxymoron!",
    "Oxymoron 🤫",
    "Oxymoron comes from Greek 'oxys' (sharp) + 'moros' (foolish), literally meaning 'sharp-foolish'!",
    "Sound word = Onomatopoeia. Opposite pairs side-by-side = Oxymoron. Saying opposite of meaning = Irony!"
  ),
  makeCh(
    'eng_c7_icse_10', 10, 'Phrasal Verbs and Idiomatic Prepositional Phrases', 'Class 7', 'icse', '💡',
    'Master high-frequency phrasal verbs (bear with, call off, come across, look down upon) and prepositional phrases (in accordance with, in spite of)!',
    ['Phrasal Verbs with Bear, Call, Come, Get, Look, Put, Turn', 'Compound Prepositional Phrases (on account of, in lieu of, by dint of)', 'Contextual Application', 'Sentence Rewrite Exercises'],
    ["'Call off' means cancel (The match was called off). 'Call on' means visit.", "'In spite of' means despite (In spite of hard work, he failed).", "'Come across' means to meet or find by chance."],
    "Which phrasal verb means 'to cancel an event': 'call off' or 'call out'?",
    "'Call off' means to cancel an event that was previously scheduled!",
    "Call off 📢",
    "In sports commentary and aviation, phrasal verbs provide rapid, unambiguous shorthand for complex actions!",
    "Call on = visit. Call off = cancel. Call up = phone or summon!"
  ),
  makeCh(
    'eng_c7_icse_11', 11, 'Formal Essay Writing: Argumentative and Expository', 'Class 7', 'icse', '📝',
    'Structure formal 300-word essays: thesis statement, topical topic sentences, counter-arguments, logical evidence, and conclusion!',
    ['Essay Types: Argumentative, Expository, Narrative, Descriptive', 'Crafting a compelling Thesis Statement', 'Topic Sentences and Paragraph Cohesion', 'Addressing Counter-arguments', 'Formal Academic Vocabulary'],
    ["An Argumentative essay takes a firm stance on a debatable topic and defends it with evidence.", "Begin with a clear Thesis Statement in the introduction.", "Each body paragraph must begin with a strong topic sentence."],
    "What is the single sentence in the introduction that clearly states the main argument of an essay called?",
    "The core sentence defining the main claim and direction of an essay is the 'Thesis Statement'!",
    "Thesis Statement 🎯",
    "The five-paragraph essay structure mirrors classical Aristotelian rhetoric used in ancient Greek debates!",
    "Thesis statement in intro -> Supporting evidence in body -> Reaffirm thesis in conclusion!"
  ),
  makeCh(
    'eng_c7_icse_12', 12, 'Précis Writing: Title Selection & Essential Points Extraction', 'Class 7', 'icse', '📜',
    'Master the ICSE Précis requirements: read unseen passages, extract 5 to 6 key points, draft a rough summary, and produce a flawless fair copy with title!',
    ['Reading for Core Points', 'Eliminating digressions, examples, and figurative flourishes', 'Title Formulation reflecting the essence', 'Word count strictness (within ±5 words of target)', 'Continuous prose requirement'],
    ["A Précis must always have an appropriate, concise Title.", "Write in third person and past tense, maintaining the original author's logical progression.", "Count words strictly: write the exact word count at the bottom."],
    "What must always be provided at the beginning of a formal précis?",
    "A concise, suitable Title that encapsulates the central subject of the passage!",
    "A concise, suitable Title 📜",
    "The legendary British Prime Minister Winston Churchill insisted that all wartime cabinet memos be summarized onto a single page précis!",
    "Extract 5 main facts -> Draft in 1/3 words -> Add a clear Title -> State final word count!"
  )
);

// =========================================================================
// CLASS 8 - CBSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c8_cbse_01', 1, 'Synthesis of Sentences: Simple, Compound & Complex', 'Class 8', 'cbse', '🏗️',
    'Combine multiple short sentences into elegant simple, compound (FANBOYS), and complex structures using subordinate conjunctions!',
    ['Simple Sentences (one independent clause)', 'Compound Sentences (two independent clauses + coordinating conjunction)', 'Complex Sentences (one independent + one or more dependent clauses)', 'FANBOYS Conjunctions'],
    ["A Simple Sentence contains exactly one independent clause with a subject and finite verb.", "A Compound Sentence joins two equal independent clauses using coordinating conjunctions (FANBOYS).", "A Complex Sentence contains one main clause and at least one dependent clause."],
    "Identify the sentence type: 'Although the weather was stormy, the brave sailors set out to sea.'",
    "'Although the weather was stormy' is a dependent clause; 'the brave sailors set out to sea' is an independent clause. One main + one dependent = Complex Sentence!",
    "Complex Sentence ⛵",
    "FANBOYS is one of the most famous mnemonics in the world: For, And, Nor, But, Or, Yet, So!",
    "Count independent clauses: 1 alone = Simple. 2 equal joined by FANBOYS = Compound. 1 main + 1 dependent = Complex!"
  ),
  makeCh(
    'eng_c8_cbse_02', 2, 'Transformation of Sentences: Degrees, Voice & Assertive/Negative', 'Class 8', 'cbse', '🔄',
    'Transform sentences from Affirmative to Negative, Interrogative to Assertive, and Exclamatory without altering meaning!',
    ['Affirmative to Negative without changing meaning', 'Interrogative to Assertive (Rhetorical Questions)', 'Exclamatory to Assertive', 'Too...to into So...that'],
    ["Transforming meaning requires using antonyms with negative words: 'He is honest' -> 'He is not dishonest'.", "Remove 'too...to': 'He is too weak to walk' -> 'He is so weak that he cannot walk'.", "Transforming rhetorical questions: 'Who does not know Mahatma Gandhi?' -> 'Everyone knows Mahatma Gandhi'."],
    "Transform without changing meaning: 'He is too proud to apologize.'",
    "Replace 'too...to' with 'so...that cannot': 'He is so proud that he will not (cannot) apologize.'",
    "He is so proud that he will not apologize 👑",
    "This art of rewriting sentences while preserving exact truth value is a key test of linguistic mastery in board exams!",
    "Always check your answer by translating both sentences: their core meaning MUST remain identical!"
  ),
  makeCh(
    'eng_c8_cbse_03', 3, 'Direct and Indirect Speech: Mastery of Dialogue', 'Class 8', 'cbse', '💬',
    'Master converting complex dialogues, exclamations, wishes, and imperative orders into flawless indirect narration!',
    ['Exclamatory Sentences (exclaimed with joy/sorrow)', 'Optative Sentences (wished, prayed)', 'Imperative Sentences (forbade, commanded)', 'Tense harmony across multiple sentences'],
    ["Exclamations change to: Subject + exclaimed with joy/sorrow/wonder + that... (He said, “Hurrah! We won” -> He exclaimed with joy that they had won).", "Negative imperatives using 'Do not' can be transformed using 'forbade': Father said, “Do not play with fire” -> Father forbade him to play with fire."],
    "Convert to indirect speech: The old man said, “Alas! I have lost everything.”",
    "Alas expresses sorrow: 'The old man exclaimed with sorrow that he had lost everything.'",
    "The old man exclaimed with sorrow 💔",
    "Reported speech in English mirrors the psychological distance of the narrator from the original event!",
    "Replace emotional exclamations with vivid reporting phrases: 'exclaimed with delight' or 'cried in disbelief'!"
  ),
  makeCh(
    'eng_c8_cbse_04', 4, 'Modals & Advanced Auxiliaries (Need, Dare, Used to, Ought to)', 'Class 8', 'cbse', '🛡️',
    'Master semi-modals (need, dare, used to, ought to) and perfect modal constructions (must have been, could have done)!',
    ['Semi-modals (need not, dare not, used to)', 'Past Habit with "used to" vs "would"', 'Perfect Modals (might have, must have, could have)', 'Obligation vs Recommendation'],
    ["'Need' and 'dare' act as modals in negative sentences: You need not worry (not 'need to').", "'Used to' expresses a past habit that no longer occurs: He used to live in Delhi.", "'Must have + V3' expresses past logical certainty: He must have forgotten his keys."],
    "Fill in the blank: 'You ______ (not / worry); everything has been taken care of.'",
    "As a negative modal of absence of obligation, we say 'need not worry'!",
    "Need not worry 🛡️",
    "'Dare' and 'need' are called marginal or semi-modals because they can function both as main verbs and auxiliary modals!",
    "Absence of obligation = need not. Past habit that ended = used to!"
  ),
  makeCh(
    'eng_c8_cbse_05', 5, 'Conditionals: Third Conditional & Unreal Past', 'Class 8', 'cbse', '🔀',
    'Express past regrets, missed opportunities, and impossible hypothetical outcomes using the Third Conditional!',
    ['Third Conditional formula (If + had + V3, would have + V3)', 'Unreal Past in history and biography', 'Mixed Conditionals Introduction', 'Inversion with "Had" (Had I known...)'],
    ["Third Conditional refers to impossible past situations that cannot be changed: If you had invited me, I would have attended the party.", "Inverted form without 'if': 'Had you invited me, I would have attended.'"],
    "Complete the third conditional: 'If we had caught the early train, we ______ (arrive) on time.'",
    "Formula: would have + V3: 'would have arrived on time'!",
    "Would have arrived 🚆",
    "The Third Conditional is often termed the 'regret conditional' because humans use it constantly to reflect on past choices!",
    "If + HAD done, WOULD HAVE happened. Two past parts working together!"
  ),
  makeCh(
    'eng_c8_cbse_06', 6, 'Non-Finite Verbs: Participle Clauses & Perfect Infinitives', 'Class 8', 'cbse', '🎭',
    'Construct advanced participle clauses (Having finished his work...) and perfect infinitives (to have been, to have seen)!',
    ['Perfect Participle (Having + V3: Having eaten dinner, he went for a walk)', 'Participle Clauses replacing adverbial clauses', 'Perfect Infinitives (He claims to have seen the ghost)', 'Avoiding Dangling Modifiers'],
    ["Use Perfect Participle 'Having + V3' when one action was fully finished before another began: Having packed his bags, he called a cab.", "Ensure participle agrees with main subject: 'Walking in the park, a snake bit him' is incorrect because the snake wasn't walking in the park!"],
    "Correct the dangling modifier: 'Walking across the lawn, a prickly thorn hurt my foot.'",
    "Rewrite so the human subject is walking: 'While I was walking across the lawn, a prickly thorn hurt my foot.'",
    "While I was walking across the lawn 🦶",
    "Dangling modifiers are among the most famous and humorous errors in high school and college essays!",
    "Always check: Who is doing the action in the participle? That person MUST be the grammatical subject!"
  ),
  makeCh(
    'eng_c8_cbse_07', 7, 'Determiners & Subject-Verb Concord in Complex Sentences', 'Class 8', 'cbse', '⚖️',
    'Analyze intricate subject-verb agreement inside relative clauses, compound subjects, and inverted structures!',
    ['Concord in Relative Clauses (It is I who am to blame)', 'Neither of, Either of, One of the students who...', 'Majority, Minority, Percentages agreement', 'Indefinite Pronouns Concord'],
    ["In 'One of the students who...', the relative pronoun 'who' refers to plural 'students', so the verb is plural: He is one of those boys who work hard.", "In 'The only one of the boys who...', the verb is singular: He is the only one who works hard."],
    "Choose the correct verb: 'It is I who ______ (am / is) responsible for this error.'",
    "The relative pronoun 'who' refers back to 'I', and 'I' agrees with 'am': 'It is I who am responsible'!",
    "Am responsible ⚖️",
    "In Latin grammar, this principle is called 'antecedent concord', where the relative pronoun reflects the person and number of its antecedent!",
    "Look at the noun right before 'who': that antecedent controls the verb inside the clause!"
  ),
  makeCh(
    'eng_c8_cbse_08', 8, 'Active and Passive Voice: Prepositional & Double Object Verbs', 'Class 8', 'cbse', '🔄',
    'Transform complex structures: sentences with prepositional verbs, cognate objects, and verbs followed by that-clauses!',
    ['Prepositional Verbs in Passive (The doctor operated on the patient -> The patient was operated on by the doctor)', 'Retaining prepositions in passive voice', 'Passive with "It is said that..." / "He is said to be..."', 'Double Object Verbs transformation'],
    ["Do not drop prepositions when converting to passive: They laughed at him -> He was laughed at by them.", "Passive of reporting: People say that he is honest -> It is said that he is honest OR He is said to be honest."],
    "Transform to passive: 'The committee looked into the matter thoroughly.'",
    "Retain the preposition 'into': 'The matter was looked into thoroughly by the committee.'",
    "The matter was looked into thoroughly 🔍",
    "News headlines frequently use impersonal passive constructions: 'A breakthrough is reported to have been achieved'!",
    "Never lose the preposition: 'operated on' stays 'operated on'; 'looked into' stays 'looked into'!"
  ),
  makeCh(
    'eng_c8_cbse_09', 9, 'Integrated Grammar: Editing, Omission and Transformation', 'Class 8', 'cbse', '✍️',
    'Attain complete mastery over advanced CBSE grammar sections: error correction, gap filling, and sentence transformation!',
    ['Systematic Line-by-Line Error Spotting', 'Tense Harmony throughout Passages', 'Prepositional & Determiner Omissions', 'High-Speed Exam Strategies'],
    ["Read the whole passage first to determine the overall timeframe (present or past narrative).", "Check every finite verb for subject concord and tense consistency.", "Verify prepositions, articles, and conjunctions in every clause."],
    "In an editing passage describing a historical event in 1947, a line says: 'The leaders gather to celebrate.' What is the error?",
    "Since the event occurred in 1947 (past history), present 'gather' must be changed to past 'gathered'!",
    "Change 'gather' to 'gathered' 📜",
    "Standardized board exam rubrics deduct marks strictly for grammatical errors in integrated passages!",
    "Timeframe check: Is the passage talking about history? Then every single narrative verb must be past tense!"
  ),
  makeCh(
    'eng_c8_cbse_10', 10, 'Idioms, Proverbs & Advanced Vocabulary', 'Class 8', 'cbse', '💡',
    'Enrich your writing with figurative idioms, timeless proverbs, foreign loanwords, and collocations!',
    ['Idioms & Figurative Meanings', 'Timeless Proverbs', 'Prefixes & Suffixes (un-, dis-, -able, -tion)', 'Common Collocations (make an effort, take a decision)'],
    ["An idiom's figurative meaning is completely different from its literal word-by-word meaning: 'bite the bullet' means to face a difficult situation courageously.", "Proverbs express universal wisdom: 'Every cloud has a silver lining' means there is always hope even in dark times."],
    "What does the idiom 'once in a blue moon' mean?",
    "A blue moon happens very rarely (a second full moon in a month). So 'once in a blue moon' means something that happens very rarely!",
    "Very rarely / Almost never 🌕",
    "A genuine astronomical 'blue moon' only occurs once roughly every 2.7 years!",
    "Never take idioms literally! Picture the metaphor in your mind to guess the real meaning."
  ),
  makeCh(
    'eng_c8_cbse_11', 11, 'Writing: Article Writing, Debate & Formal Letter', 'Class 8', 'cbse', '📰',
    'Master high-scoring writing formats: newspaper Article Writing (with byline), Debate speeches, and formal letters of complaint/inquiry!',
    ['Article Writing Format (Catchy Title, Byline, 3-4 Paragraph Body)', 'Debate Speech Format (Salutation to jury, Stance, Arguments with evidence, Conclusion)', 'Formal Letters of Complaint and Inquiry', 'Persuasive Rhetorical Devices'],
    ["An Article requires a catchy title followed by the author's byline (By: Name).", "A Debate must take a clear side: either FOR or AGAINST the motion, never both.", "Use rhetorical questions and statistical evidence to persuade the audience."],
    "In an Article for a school magazine, where does the Byline (author's name) appear?",
    "Directly underneath the catchy title: 'By [Your Name]'!",
    "Directly underneath the title ✍️",
    "The word 'debate' comes from Old French 'debatre' meaning 'to fight or beat down' with words and logic!",
    "Article format: Title in center -> Byline -> Introduction -> Analytical Body -> Constructive Conclusion!"
  ),
  makeCh(
    'eng_c8_cbse_12', 12, "Analytical Comprehension: Inferences & Author's Purpose", 'Class 8', 'cbse', '📖',
    'Deconstruct complex prose: analyze author intent, evaluate persuasive arguments, deduce thematic subtext, and summarize concisely!',
    ['Author’s Purpose (inform, satirize, advocate, analyze)', 'Deducing Subtext and Implicit Themes', 'Evaluating Logical Arguments and Fallacies', 'High-Level Vocabulary Contextual Extraction'],
    ["Subtext is the unspoken or less obvious meaning running beneath the literal words.", "Examine word connotations: calling a leader 'stubborn' has a negative connotation; calling them 'resolute' has a positive connotation."],
    "What is the difference in connotation between describing someone as 'frugal' versus 'stingy'?",
    "'Frugal' has a positive connotation (wise with money), whereas 'stingy' has a negative connotation (mean and selfish)!",
    "'Frugal' is positive; 'stingy' is negative 💰",
    "Connotation awareness is what distinguishes average readers from master analytical thinkers!",
    "Look past the dictionary definition: Ask what emotional flavor or judgment the chosen word carries!"
  )
);

// =========================================================================
// CLASS 8 - ICSE (12 Chapters)
// =========================================================================
list.push(
  makeCh(
    'eng_c8_icse_01', 1, 'Transformation of Sentences: Simple, Compound and Complex', 'Class 8', 'icse', '🏗️',
    'Master mutual conversion between Simple, Compound, and Complex sentences without altering meaning!',
    ['Simple to Compound (by expanding phrases into clauses using coordinating conjunctions)', 'Simple to Complex (by expanding phrases into noun, adjective, or adverb clauses)', 'Complex to Simple (by contracting clauses into phrases)', 'Compound to Complex'],
    ["Simple: 'Hearing the noise, the boy woke up.' -> Compound: 'The boy heard the noise and woke up.' -> Complex: 'When the boy heard the noise, he woke up.'", "All three preserve identical semantic value."],
    "Transform into Complex: 'In spite of his poverty, he is scrupulously honest.'",
    "Expanding the prepositional phrase into an adverb clause: 'Although he is poor, he is scrupulously honest.'",
    "Although he is poor, he is scrupulously honest 💎",
    "This mutual transformation exercise is the cornerstone of the ICSE English Language Examination (Paper 1, Question 5)!",
    "Formula: 'In spite of + noun' (Simple) = 'Although + clause' (Complex) = '...yet / but' (Compound)!"
  ),
  makeCh(
    'eng_c8_icse_02', 2, 'Transformation of Sentences: Interchange of Voice & Speech', 'Class 8', 'icse', '🔄',
    'Execute sophisticated interchanges of Active/Passive voice and Direct/Indirect speech in complex literary paragraphs!',
    ['Complex Passive Transformations (verbs with clauses, infinitive passives)', 'Impersonal Passive (It is believed that...)', 'Converting Extended Multi-sentence Dialogue into Narrative', 'Preserving Tense Harmony and Register'],
    ["'People believe that hard work brings success' -> 'Hard work is believed to bring success.'", "In converting dialogue, combine related statements smoothly using participle phrases rather than mechanical repetitions of 'he said'."],
    "Transform into Passive: 'They say that virtue is its own reward.'",
    "'It is said that virtue is its own reward' OR 'Virtue is said to be its own reward.'",
    "Virtue is said to be its own reward 🌟",
    "Wren and Martin's English Grammar calls the passive with 'to be' the most refined transformation in the language!",
    "People say that X is Y -> X is said to be Y!"
  ),
  makeCh(
    'eng_c8_icse_03', 3, 'Transformation: Removal of "Too...to", Affirmative/Negative, Degrees', 'Class 8', 'icse', '🔄',
    'Master compulsory ICSE transformation patterns: removing "too...to" with "so...that", "No sooner...than", "As soon as", and Degrees!',
    ['Removing "too...to" (so... that + cannot/could not)', 'No sooner... than (with auxiliary inversion: No sooner had he...)', 'Hardly / Scarcely... when', 'Interchange of Degrees without meaning change'],
    ["'No sooner' is always followed by an auxiliary verb and 'than': 'No sooner did the bell ring than the students dispersed.'", "'Hardly' and 'Scarcely' take 'when' (never 'than'): 'Hardly had I arrived when the phone rang.'"],
    "Rewrite using 'No sooner... than': 'As soon as he entered the hall, the applause erupted.'",
    "'No sooner had he entered the hall than the applause erupted.'",
    "No sooner had he entered than applause erupted 👏",
    "Remember: 'No sooner' takes 'than', while 'Hardly/Scarcely' takes 'when'—confusing them is the #1 ICSE exam trap!",
    "No sooner + auxiliary (did/had) + subject + verb + THAN!"
  ),
  makeCh(
    'eng_c8_icse_04', 4, 'Conditional Sentences: Types 0, 1, 2, 3 and Conditional Inversions', 'Class 8', 'icse', '🔀',
    'Master all 4 conditionals (Zero, Type 1, Type 2, Type 3) and formal inversion structures without "If" (Were he, Had he, Should you)!',
    ['Type 0 (universal truth: present + present)', 'Type 1 (open future: present + will)', 'Type 2 (hypothetical present: past + would)', 'Type 3 (unreal past: had + V3 + would have + V3)', 'Inversion: Had I known, Were I, Should you'],
    ["Inversion replaces 'if': 'If he had arrived earlier' becomes 'Had he arrived earlier'.", "'If you should need assistance' becomes 'Should you need assistance'.", "'Unless' means 'if not'."],
    "Rewrite without 'If': 'If she had listened to my advice, she would not have failed.'",
    "Inverting 'had': 'Had she listened to my advice, she would not have failed.'",
    "Had she listened to my advice 💡",
    "Classical English literature frequently uses conditional inversions for high solemnity and dramatic weight!",
    "Had + Subject + V3 = If + Subject + had + V3!"
  ),
  makeCh(
    'eng_c8_icse_05', 5, 'Sequence of Tenses and Subjunctive Mood', 'Class 8', 'icse', '⏳',
    'Govern the tense of subordinate clauses by the principal clause and master the Subjunctive Mood for wishes and hypothetical demands!',
    ['The Fundamental Rule of Sequence of Tenses (Past in main clause requires Past in subordinate clause)', 'Exceptions (Universal truths, comparison with "than")', 'Subjunctive Mood (I wish I were, God save the King, It is imperative that he leave)'],
    ["If the main verb is in the past, subordinate verbs must be in the past: 'I found that he was weeping' (not 'is weeping').", "The Mandative Subjunctive uses base verb: 'The judge ordered that the prisoner be released' (not 'is released')."],
    "Choose the correct verb: 'It is essential that every student ______ (submit / submits) the project on time.'",
    "In the mandative subjunctive mood following 'essential that', the base form 'submit' is used without -s!",
    "Submit (Base Subjunctive) 📝",
    "The Subjunctive mood is one of the oldest features of Germanic grammar, still thriving in legal and formal English!",
    "Mandative subjunctive: 'demanded that he BE present', 'insisted that she LEAVE'!"
  ),
  makeCh(
    'eng_c8_icse_06', 6, 'Synthesis of Sentences: Absolute Nominative & Correlatives', 'Class 8', 'icse', '🔗',
    'Synthesize sentences using Nominative Absolute phrases (The sun having risen, the fog dispersed) and correlative conjunctions!',
    ['Nominative Absolute (Noun + Participle independent of main sentence)', 'Correlative Conjunctions (Either...or, Neither...nor, Not only...but also, Scarcely...when)', 'Absolute phrases in historical narrative', 'Synthesizing three or more clauses'],
    ["A Nominative Absolute consists of a noun or pronoun followed by a participle, grammatically independent of the main clause: 'The weather being stormy, we stayed indoors.'", "Both clauses have different subjects."],
    "Combine into one sentence using a Nominative Absolute: 'The rain stopped. The children went outside to play.'",
    "'The rain having stopped, the children went outside to play.'",
    "The rain having stopped, the children went out 🌦️",
    "Nominative Absolute comes from the famous Latin 'Ablative Absolute' used in Caesar's Gallic Wars!",
    "Use Nominative Absolute when the two sentences have DIFFERENT subjects: [Subject 1 + having done], [Subject 2 + main verb]!"
  ),
  makeCh(
    'eng_c8_icse_07', 7, 'Non-Finite Verbs: Dangling Modifiers & Split Infinitives', 'Class 8', 'icse', '🎭',
    'Detect and correct stylistic non-finite faults: dangling modifiers, misplaced participles, split infinitives, and faulty gerund cases!',
    ['Identifying Dangling Modifiers', 'Possessive Case before Gerunds (I object to his going, not him going)', 'Split Infinitives (to boldly go)', 'Participle Clause Placement'],
    ["A noun or pronoun before a gerund must be in the possessive case: 'I was surprised at his (not him) winning the race.'", "A dangling modifier occurs when the implied subject of the participle is missing from the main clause."],
    "Correct the sentence: 'Priya disliked him talking loudly during the film.'",
    "Before the gerund 'talking', use the possessive 'his': 'Priya disliked his talking loudly during the film.'",
    "Disliked his talking loudly 🎬",
    "The possessive before a gerund rule is one of the classic distinguishing markers of refined academic style!",
    "Before an -ing gerund noun, always use possessive: MY going, HIS winning, THEIR shouting!"
  ),
  makeCh(
    'eng_c8_icse_08', 8, 'Prepositions: Complete Prepositional Idioms & Phrasal Verbs', 'Class 8', 'icse', '🧭',
    'Master comprehensive prepositional idioms (at sixes and sevens, in the teeth of, by virtue of) and complex phrasal verbs!',
    ['Prepositional Idioms (in conformity with, on the verge of, for the sake of)', 'Phrasal Verbs with Bring, Come, Do, Get, Give, Go, Hold, Keep, Make, Pass, Put, Run, Set, Take, Turn', 'ICSE Question 5(b) drill questions', 'Error analysis'],
    ["'Set in' means begin and likely continue (Winter has set in). 'Set off' means begin a journey.", "'Turn down' means reject an offer. 'Turn up' means arrive unexpectedly."],
    "Which phrasal verb means 'to reject a proposal or request': 'turn off' or 'turn down'?",
    "'Turn down' means to decline or reject an offer or application!",
    "Turn down 📄",
    "Question 5(b) in ICSE English Language specifically tests candidates on 8 precise prepositions in a cloze passage!",
    "Set in = begin. Set out = begin journey. Set up = establish. Turn down = reject!"
  ),
  makeCh(
    'eng_c8_icse_09', 9, 'Figures of Speech & Poetic Devices: Metaphor, Irony & Paradox', 'Class 8', 'icse', '🎭',
    'Analyze sophisticated literary devices: Paradox (a self-contradictory statement revealing truth), Metonymy, Irony, and Apostrophe!',
    ['Paradox (The child is father of the man)', 'Metonymy (The pen is mightier than the sword)', 'Apostrophe (addressing the absent or dead as living)', 'Irony (verbal, situational, dramatic) in literature'],
    ["A Paradox is a statement that seems contradictory at first but conveys a profound underlying truth: 'The child is father of the man' (our childhood shapes our adulthood).", "Metonymy substitutes the name of an attribute for that of the thing meant: 'The crown' for the monarch."],
    "Identify the figure of speech: 'The pen is mightier than the sword.'",
    "'Pen' represents written ideas; 'sword' represents military force. Substituting an attribute/instrument is Metonymy!",
    "Metonymy ✒️",
    "William Wordsworth's line 'The child is the father of the man' is one of the most famous paradoxes in English poetry!",
    "Seeming contradiction revealing deep truth = Paradox. Attribute standing for whole = Metonymy!"
  ),
  makeCh(
    'eng_c8_icse_10', 10, 'Advanced Lexicon: Foreign Loanwords, Collocations & Confused Words', 'Class 8', 'icse', '🧠',
    'Enrich scholarly vocabulary: foreign borrowings in English (status quo, faux pas, bona fide, carte blanche), and nuanced word pairs!',
    ['Foreign Loanwords in English (Latin, French, Italian)', 'Words Often Confused and Misused (eminent/imminent, complimentary/complementary)', 'Collocations in Formal Register', 'Etymology and Root Analysis'],
    ["'Bona fide' is Latin for in good faith / genuine.", "'Faux pas' is French for an embarrassing social blunder.", "'Imminent' means about to happen right now; 'Eminent' means famous and respected."],
    "Which word means 'about to happen very soon': 'eminent' or 'imminent'?",
    "'Imminent' means impending or about to occur at any moment!",
    "Imminent ⏳",
    "English has borrowed words from over 350 languages, making it the most linguistically cosmopolitan language on Earth!",
    "Eminent = esteemed person. Imminent = immediate danger or event!"
  ),
  makeCh(
    'eng_c8_icse_11', 11, 'Composition: Original Story Writing & Argumentative Essays', 'Class 8', 'icse', '📝',
    'Compose 350-word ICSE compositions: gripping original short stories with psychological depth, or rigorous argumentative essays!',
    ['ICSE Composition Criteria (Subject matter, Organization, Vocabulary, Syntax, Mechanics)', 'Story Writing with given opening or ending lines', 'Argumentative Essay with logical refutation', 'Narrative arc, climax, and emotional catharsis'],
    ["If a prompt provides an opening line, you MUST begin the story with those exact words.", "An argumentative essay must not waffle between two sides; pick one clear stance and defend it with mature examples."],
    "If an ICSE exam question says: 'Write a story ending with: ...and then I realized it had all been a misunderstanding', where must that line appear?",
    "It must appear as the very final, concluding sentence of the story verbatim!",
    "As the exact final sentence 📝",
    "ICSE examiners award top marks for varied sentence structures, original vocabulary, and complete absence of grammatical slips!",
    "Vary your sentence lengths: short for drama; long and sweeping for rich description!"
  ),
  makeCh(
    'eng_c8_icse_12', 12, 'Critical Précis Writing & Comprehension of Unseen Passages', 'Class 8', 'icse', '📜',
    'Master ICSE Question 4: deep passage analysis, vocabulary in context, answering specific questions in own words, and writing a 50-word grid précis!',
    ['ICSE Question 4 Comprehension Architecture', 'Vocabulary questions: providing one-word synonyms matching grammatical form', 'Answering factual questions concisely in own words', 'The 50-word Grid Précis with Title'],
    ["In vocabulary questions, your synonym must match the exact part of speech and tense of the original word (noun for noun, past tense for past tense).", "The précis must be written within the prescribed 50-word grid with one word per box."],
    "If the passage word to be explained is the past-tense verb 'relinquished', what part of speech and tense must your replacement answer be?",
    "It must also be a past-tense verb (e.g. 'surrendered' or 'abandoned')!",
    "Past-tense verb (e.g. surrendered) 📜",
    "The 50-word grid précis in ICSE Question 4 is universally acknowledged as a masterpiece of rigorous conciseness testing!",
    "Check grammatical form: verb for verb, noun for noun! Fill the grid neatly, one word per box!"
  )
);

module.exports = { list };
