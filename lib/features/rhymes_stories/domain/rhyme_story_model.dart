import 'package:flutter/material.dart';

/// Represents a cheerful nursery rhyme for toddlers and early learners
class RhymeItem {
  final String id;
  final String title;
  final String titleHi;
  final String emoji;
  final List<String> lines;
  final List<String>? hindiLines;
  final String character;
  final Color themeColor;

  const RhymeItem({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.emoji,
    required this.lines,
    this.hindiLines,
    required this.character,
    required this.themeColor,
  });

  String get fullText => lines.join('\n');
  String get speechText => lines.join('. ');
}

/// Represents an illustrated moral fable/story for early learners
class StoryItem {
  final String id;
  final String title;
  final String titleHi;
  final String emoji;
  final String moral;
  final String moralHi;
  final List<StoryScene> scenes;
  final Color themeColor;

  const StoryItem({
    required this.id,
    required this.title,
    required this.titleHi,
    required this.emoji,
    required this.moral,
    required this.moralHi,
    required this.scenes,
    required this.themeColor,
  });

  String get fullSpeechText => scenes.map((s) => s.text).join(' ');
}

/// A scene / page of an illustrated story
class StoryScene {
  final String emoji;
  final String text;
  final String? textHi;

  const StoryScene({
    required this.emoji,
    required this.text,
    this.textHi,
  });
}

/// Bundled collection of toddler favorite rhymes and stories
class RhymesStoriesData {
  static const List<RhymeItem> rhymes = [
    RhymeItem(
      id: 'twinkle_star',
      title: 'Twinkle, Twinkle, Little Star',
      titleHi: 'ट्विंकल ट्विंकल लिटिल स्टार',
      emoji: '🌟',
      character: 'Twinkling Star ✨',
      themeColor: Color(0xFFF59E0B),
      lines: [
        'Twinkle, twinkle, little star,',
        'How I wonder what you are!',
        'Up above the world so high,',
        'Like a diamond in the sky.',
        'Twinkle, twinkle, little star,',
        'How I wonder what you are!',
      ],
      hindiLines: [
        'ट्विंकल, ट्विंकल, लिटिल स्टार,',
        'हाउ आई वंडर व्हॉट यू आर!',
        'अप अबव द वर्ल्ड सो हाई,',
        'लाइक अ डायमंड इन द स्काई।',
      ],
    ),
    RhymeItem(
      id: 'baa_baa_black_sheep',
      title: 'Baa, Baa, Black Sheep',
      titleHi: 'बा बा ब्लैक शीप',
      emoji: '🐑',
      character: 'Fluffy Sheep 🧶',
      themeColor: Color(0xFF6366F1),
      lines: [
        'Baa, baa, black sheep,',
        'Have you any wool?',
        'Yes sir, yes sir,',
        'Three bags full!',
        'One for the master,',
        'And one for the dame,',
        'And one for the little boy',
        'Who lives down the lane.',
      ],
    ),
    RhymeItem(
      id: 'humpty_dumpty',
      title: 'Humpty Dumpty',
      titleHi: 'हम्प्टी डम्प्टी',
      emoji: '🥚',
      character: 'Humpty Dumpty 👑',
      themeColor: Color(0xFFEF4444),
      lines: [
        'Humpty Dumpty sat on a wall,',
        'Humpty Dumpty had a great fall!',
        "All the king's horses",
        "And all the king's men,",
        "Couldn't put Humpty",
        'Together again!',
      ],
    ),
    RhymeItem(
      id: 'wheels_on_the_bus',
      title: 'The Wheels on the Bus',
      titleHi: 'द व्हील्स ऑन द बस',
      emoji: '🚌',
      character: 'Yellow School Bus 🚏',
      themeColor: Color(0xFFEAB308),
      lines: [
        'The wheels on the bus go round and round,',
        'Round and round, round and round!',
        'The wheels on the bus go round and round,',
        'All through the town!',
        'The wipers on the bus go swish, swish, swish,',
        'All through the town!',
        'The horn on the bus goes beep, beep, beep,',
        'All through the town!',
      ],
    ),
    RhymeItem(
      id: 'johny_johny',
      title: 'Johny Johny Yes Papa',
      titleHi: 'जॉनी जॉनी यस पापा',
      emoji: '🍬',
      character: 'Little Johny 👦',
      themeColor: Color(0xFF10B981),
      lines: [
        'Johny, Johny,',
        'Yes, Papa?',
        'Eating sugar?',
        'No, Papa!',
        'Telling lies?',
        'No, Papa!',
        'Open your mouth!',
        'Ha! Ha! Ha!',
      ],
    ),
    RhymeItem(
      id: 'jack_and_jill',
      title: 'Jack and Jill',
      titleHi: 'जैक एंड जिल',
      emoji: '🪣',
      character: 'Jack & Jill ⛰️',
      themeColor: Color(0xFF06B6D4),
      lines: [
        'Jack and Jill went up the hill,',
        'To fetch a pail of water.',
        'Jack fell down and broke his crown,',
        'And Jill came tumbling after!',
      ],
    ),
    RhymeItem(
      id: 'incy_wincy_spider',
      title: 'Incy Wincy Spider',
      titleHi: 'इंसी विंसी स्पाइडर',
      emoji: '🕷️',
      character: 'Little Spider 🌧️',
      themeColor: Color(0xFF8B5CF6),
      lines: [
        'Incy Wincy spider climbed up the water spout,',
        'Down came the rain and washed the spider out!',
        'Out came the sun and dried up all the rain,',
        'And Incy Wincy spider climbed up the spout again!',
      ],
    ),
    RhymeItem(
      id: 'row_row_boat',
      title: 'Row, Row, Row Your Boat',
      titleHi: 'रो रो रो योर बोट',
      emoji: '🚣',
      character: 'River Boatman 🌊',
      themeColor: Color(0xFF0284C7),
      lines: [
        'Row, row, row your boat,',
        'Gently down the stream,',
        'Merrily, merrily, merrily, merrily,',
        'Life is but a dream!',
      ],
    ),
    RhymeItem(
      id: 'five_little_monkeys',
      title: 'Five Little Monkeys',
      titleHi: 'फाइव लिटिल मंकीज़',
      emoji: '🐒',
      character: 'Cheeky Monkey 🍌',
      themeColor: Color(0xFFF97316),
      lines: [
        'Five little monkeys jumping on the bed,',
        'One fell off and bumped his head!',
        'Mama called the doctor and the doctor said:',
        '"No more monkeys jumping on the bed!"',
      ],
    ),
    RhymeItem(
      id: 'hickory_dickory',
      title: 'Hickory Dickory Dock',
      titleHi: 'हिकरी डिकरी डॉक',
      emoji: '⏰',
      character: 'Little Mouse 🐭',
      themeColor: Color(0xFFEC4899),
      lines: [
        'Hickory, dickory, dock,',
        'The mouse ran up the clock!',
        'The clock struck one,',
        'The mouse ran down,',
        'Hickory, dickory, dock!',
      ],
    ),
  ];

  static const List<StoryItem> stories = [
    StoryItem(
      id: 'thirsty_crow',
      title: 'The Thirsty Crow',
      titleHi: 'प्यासा कौआ',
      emoji: '🦅',
      moral: 'Where there is a will, there is a way! 💡',
      moralHi: 'जहाँ चाह, वहाँ राह! 💡',
      themeColor: Color(0xFF0284C7),
      scenes: [
        StoryScene(
          emoji: '☀️',
          text: 'On a very hot sunny day, a thirsty black crow flew across the fields looking for water.',
          textHi: 'एक गर्म दिन, एक प्यासा कौआ पानी की तलाश में यहाँ-वहाँ उड़ रहा था।',
        ),
        StoryScene(
          emoji: '🏺',
          text: 'He found a pitcher in a garden. But there was only a little water at the very bottom!',
          textHi: 'उसे एक बगीचे में घड़ा दिखा, पर उसमें बहुत थोड़ा पानी नीचे था।',
        ),
        StoryScene(
          emoji: '💡',
          text: 'The clever crow looked around and saw smooth little pebbles scattered on the ground.',
          textHi: 'समझदार कौए ने चारों ओर देखा और जमीन पर पड़े छोटे-छोटे कंकड़ देखे।',
        ),
        StoryScene(
          emoji: '🪨',
          text: 'One by one, he picked the pebbles with his beak and dropped them into the pitcher!',
          textHi: 'एक-एक करके उसने अपनी चोंच से कंकड़ उठाए और घड़े में डालने लगा!',
        ),
        StoryScene(
          emoji: '💧',
          text: 'The water slowly rose to the top! The crow drank the cool water happily and flew away.',
          textHi: 'पानी ऊपर आ गया! कौए ने खुशी-खुशी पानी पिया और खुशी से उड़ गया।',
        ),
      ],
    ),
    StoryItem(
      id: 'hare_and_tortoise',
      title: 'The Hare & The Tortoise',
      titleHi: 'खरगोश और कछुआ',
      emoji: '🐢',
      moral: 'Slow and steady wins the race! 🏆',
      moralHi: 'लगातार मेहनत करने वाला ही जीतता है! 🏆',
      themeColor: Color(0xFF10B981),
      scenes: [
        StoryScene(
          emoji: '🐇',
          text: 'A speedy hare always boasted about how fast he could run in the forest.',
          textHi: 'एक तेज खरगोश हमेशा अपनी तेज चाल पर घमंड करता था।',
        ),
        StoryScene(
          emoji: '🐢',
          text: 'The wise slow tortoise challenged him to a friendly running race to the big tree.',
          textHi: 'शांत कछुए ने उसे बड़े पेड़ तक दौड़ लगाने की चुनौती दी।',
        ),
        StoryScene(
          emoji: '🏃',
          text: 'The race started! The hare sprinted ahead and took a nap under a shady tree.',
          textHi: 'दौड़ शुरू हुई! खरगोश तेजी से आगे निकल गया और पेड़ के नीचे सो गया।',
        ),
        StoryScene(
          emoji: '🚶',
          text: 'The tortoise kept walking step by step without stopping even once!',
          textHi: 'कछुआ बिना रुके धीमे-धीमे लगातार आगे बढ़ता रहा!',
        ),
        StoryScene(
          emoji: '🏁',
          text: 'When the hare woke up, the tortoise had already crossed the finish line and won!',
          textHi: 'जब खरगोश जागा, तब तक कछुआ जीत की रेखा पार कर चुका था!',
        ),
      ],
    ),
    StoryItem(
      id: 'lion_and_mouse',
      title: 'The Lion & The Mouse',
      titleHi: 'शेर और नन्हा चूहा',
      emoji: '🦁',
      moral: 'No act of kindness is ever wasted! 💖',
      moralHi: 'भलाई का बदला हमेशा अच्छा होता है! 💖',
      themeColor: Color(0xFFF59E0B),
      scenes: [
        StoryScene(
          emoji: '😴',
          text: 'A mighty lion was sleeping peacefully when a tiny playful mouse tickled his nose.',
          textHi: 'एक जंगल का राजा शेर सो रहा था, जब एक नन्हे चूहे ने उसकी नाक गुदगुदाई।',
        ),
        StoryScene(
          emoji: '🐭',
          text: 'The lion caught the mouse, but kindly let him go when the mouse begged for mercy.',
          textHi: 'शेर ने चूहे को पकड़ लिया, पर चूहे की प्रार्थना पर उसे दया करके छोड़ दिया।',
        ),
        StoryScene(
          emoji: '🕸️',
          text: 'Days later, the lion got caught in a hunter\'s strong rope net and roared loudly.',
          textHi: 'कुछ दिन बाद, शेर शिकारी के मजबूत जाल में फँस गया और जोर से दहाड़ा।',
        ),
        StoryScene(
          emoji: '✂️',
          text: 'The little mouse heard the roar, ran to the net, and chewed through the thick ropes!',
          textHi: 'नन्हे चूहे ने आवाज सुनी, दौड़कर आया और अपने तीखे दांतों से जाल काट दिया!',
        ),
        StoryScene(
          emoji: '🤝',
          text: 'The lion was free! From that sunny day on, the lion and mouse became best friends.',
          textHi: 'शेर आजाद हो गया! उस दिन से शेर और नन्हा चूहा पक्के दोस्त बन गए।',
        ),
      ],
    ),
    StoryItem(
      id: 'boy_cried_wolf',
      title: 'The Boy Who Cried Wolf',
      titleHi: 'झूठ बोलने वाला चरवाहा',
      emoji: '🐺',
      moral: 'Always speak the truth so people can trust you! 🌟',
      moralHi: 'हमेशा सच बोलें ताकि लोग आप पर भरोसा करें! 🌟',
      themeColor: Color(0xFFEF4444),
      scenes: [
        StoryScene(
          emoji: '🐑',
          text: 'A shepherd boy watched his sheep near a quiet village on a grassy hill.',
          textHi: 'एक चरवाहा लड़का पहाड़ी पर अपनी भेड़ों की देखभाल करता था।',
        ),
        StoryScene(
          emoji: '📢',
          text: 'For fun, he shouted loudly: "Wolf! Wolf! Help my sheep!" to fool the villagers.',
          textHi: 'मजाक में वह चिल्लाया: "भेड़िया आया! भेड़िया आया!" और गाँव वालों को मूर्ख बनाया।',
        ),
        StoryScene(
          emoji: '🏃',
          text: 'The kind villagers ran to help him, only to find the boy laughing playfully.',
          textHi: 'गाँव वाले मदद करने दौड़े, पर देखा लड़का उनपर हँस रहा था।',
        ),
        StoryScene(
          emoji: '🐺',
          text: 'One evening, a real wolf emerged from the dark forest. The boy shouted for help!',
          textHi: 'एक शाम सचमुच का भेड़िया आ गया। लड़का डरकर जोर से चिल्लाया!',
        ),
        StoryScene(
          emoji: '😢',
          text: 'Nobody came because they thought he was lying again. He learned to always tell the truth.',
          textHi: 'कोई मदद को नहीं आया क्योंकि सबने सोचा वह फिर झूठ बोल रहा है। उसने सच बोलने की सीख ली।',
        ),
      ],
    ),
    StoryItem(
      id: 'ant_and_dove',
      title: 'The Ant & The Dove',
      titleHi: 'चींटी और कबूतर',
      emoji: '🐜',
      moral: 'A good deed is its own reward! 🍃',
      moralHi: 'कर भला तो हो भला! 🍃',
      themeColor: Color(0xFF8B5CF6),
      scenes: [
        StoryScene(
          emoji: '🌊',
          text: 'A little ant fell into a fast-flowing river and struggled to stay afloat.',
          textHi: 'एक छोटी चींटी नदी की तेज धार में गिर गई और बहने लगी।',
        ),
        StoryScene(
          emoji: '🕊️',
          text: 'A gentle dove in a tree plucked a green leaf and dropped it into the water.',
          textHi: 'पेड़ पर बैठे एक दयालु कबूतर ने पत्ता तोड़कर पानी में गिरा दिया।',
        ),
        StoryScene(
          emoji: '🍃',
          text: 'The ant climbed safely onto the floating leaf and reached the dry river bank.',
          textHi: 'चींटी तैरते पत्ते पर चढ़ गई और सुरक्षित किनारे पहुँच गई।',
        ),
        StoryScene(
          emoji: '🏹',
          text: 'Later, a hunter aimed his arrow at the dove. The ant quickly bit the hunter\'s foot!',
          textHi: 'बाद में एक शिकारी ने कबूतर पर तीर साधा। चींटी ने शिकारी के पैर पर काट लिया!',
        ),
        StoryScene(
          emoji: '💖',
          text: 'The hunter yelped in pain, the arrow missed, and the grateful dove flew to safety!',
          textHi: 'शिकारी का निशाना चूक गया और कबूतर सुरक्षित उड़ गया!',
        ),
      ],
    ),
  ];
}
