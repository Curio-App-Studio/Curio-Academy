import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import '../../../data/models/student_profile.dart';
import 'spell_bee_word.dart';

/// Grade-aligned Spell Bee word repository for LKG to Class 8
class SpellBeeRepository {
  static final SpellBeeRepository instance = SpellBeeRepository._internal();
  factory SpellBeeRepository() => instance;
  SpellBeeRepository._internal();

  final Random _random = Random();
  bool _isLoaded = false;
  List<SpellBeeWord> _loadedWords = [];

  List<SpellBeeWord> get allWordsList => _loadedWords.isNotEmpty ? _loadedWords : allWords;

  /// Loads 500+ competition words from assets/curriculum/spell_bee_words.json
  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/curriculum/spell_bee_words.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final list = <SpellBeeWord>[];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final word = (item['word'] as String? ?? '').trim().toUpperCase();
            if (word.isEmpty) continue;
            list.add(SpellBeeWord(
              word: word,
              definition: item['definition'] as String? ?? '',
              exampleSentence: item['exampleSentence'] as String? ?? '',
              emoji: item['emoji'] as String? ?? '🐝',
              phonetic: item['phonetic'] as String? ?? '',
              partOfSpeech: item['partOfSpeech'] as String? ?? 'Noun',
              origin: item['origin'] as String? ?? 'English',
              confusables: (item['confusables'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
              difficulty: item['difficulty'] as int? ?? 1,
              targetClass: _parseStudentClass(item['targetClass'] as String? ?? ''),
            ));
          }
        }
        if (list.isNotEmpty) {
          _loadedWords = list;
          _isLoaded = true;
        }
      }
    } catch (_) {
      // Fallback to static allWords if asset bundle is unavailable (e.g. unit tests)
      _isLoaded = true;
    }
  }

  static StudentClass _parseStudentClass(String raw) {
    switch (raw.toLowerCase()) {
      case 'lkg': return StudentClass.lkg;
      case 'ukg': return StudentClass.ukg;
      case 'class1': return StudentClass.class1;
      case 'class2': return StudentClass.class2;
      case 'class3': return StudentClass.class3;
      case 'class4': return StudentClass.class4;
      case 'class5': return StudentClass.class5;
      case 'class6': return StudentClass.class6;
      case 'class7': return StudentClass.class7;
      case 'class8': return StudentClass.class8;
      default: return StudentClass.class3;
    }
  }

  /// Curated fallback dictionary covering foundational phonics to national spelling bee competition words
  static const List<SpellBeeWord> allWords = [
    // --- LKG: 3-letter CVC Phonics & Sight Words ---
    SpellBeeWord(word: 'CAT', definition: 'A small furry pet that purrs', exampleSentence: 'The little cat is sleeping in the sun.', emoji: '🐱', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'DOG', definition: 'A loyal pet that barks', exampleSentence: 'The brown dog wags its happy tail.', emoji: '🐶', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'SUN', definition: 'The bright star that lights our day', exampleSentence: 'The golden sun rises in the east.', emoji: '☀️', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'BUS', definition: 'A big yellow vehicle for school kids', exampleSentence: 'We ride the yellow school bus together.', emoji: '🚌', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'CUP', definition: 'A small bowl with a handle to drink from', exampleSentence: 'Mom drinks warm milk from a red cup.', emoji: '☕', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'BAT', definition: 'A wooden stick used to hit a ball', exampleSentence: 'He hit a boundary with his cricket bat.', emoji: '🏏', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'PEN', definition: 'A tool filled with ink for writing', exampleSentence: 'Teacher writes notes with a blue pen.', emoji: '🖊️', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'HEN', definition: 'A mother bird that lays eggs', exampleSentence: 'The hen fed her fluffy yellow chicks.', emoji: '🐔', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'PIG', definition: 'A pink animal that says oink', exampleSentence: 'The baby pig rolled happily in the mud.', emoji: '🐷', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'BOX', definition: 'A square container for storing toys', exampleSentence: 'Pack all the colourful crayons in the box.', emoji: '📦', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'HAT', definition: 'Clothing worn on your head', exampleSentence: 'Put on your sunny hat before going outside.', emoji: '👒', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'BED', definition: 'A soft place where you sleep at night', exampleSentence: 'Time to hop into bed and have sweet dreams.', emoji: '🛏️', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'JAM', definition: 'Sweet fruit spread on toast', exampleSentence: 'I spread yummy strawberry jam on my bread.', emoji: '🍓', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'VAN', definition: 'A medium vehicle for carrying goods', exampleSentence: 'The delivery van arrived at our doorstep.', emoji: '🚐', targetClass: StudentClass.lkg, difficulty: 1),
    SpellBeeWord(word: 'NET', definition: 'Knitted strings used to catch a ball or fish', exampleSentence: 'The goalkeeper stopped the ball from hitting the net.', emoji: '🥅', targetClass: StudentClass.lkg, difficulty: 1),

    // --- UKG: 4-letter Blend & Phonics Words ---
    SpellBeeWord(word: 'DUCK', definition: 'A bird that swims and quacks', exampleSentence: 'The yellow duck swam across the pond.', emoji: '🦆', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'FROG', definition: 'A green animal that hops and croaks', exampleSentence: 'A little green frog jumped onto the lily pad.', emoji: '🐸', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'FISH', definition: 'A creature with fins that lives in water', exampleSentence: 'Colorful gold fish swim inside the aquarium.', emoji: '🐟', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'BIRD', definition: 'A feathered creature that flies in the sky', exampleSentence: 'The singing bird built a nest on the branch.', emoji: '🐦', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'BOOK', definition: 'Pages bound together for reading', exampleSentence: 'I love reading my bedtime story book.', emoji: '📖', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'TREE', definition: 'A tall woody plant with green leaves', exampleSentence: 'Mangoes grow on the giant shady tree.', emoji: '🌳', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'STAR', definition: 'A twinkling light in the night sky', exampleSentence: 'Look at the brightest star shining tonight.', emoji: '⭐', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'MOON', definition: 'The round glow in the night sky', exampleSentence: 'The silver moon lit up the night.', emoji: '🌙', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'BALL', definition: 'A round bouncy toy for games', exampleSentence: 'Kick the football across the playground.', emoji: '⚽', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'RAIN', definition: 'Water droplets falling from clouds', exampleSentence: 'Pitter-patter falls the cool monsoon rain.', emoji: '🌧️', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'MILK', definition: 'A healthy white drink rich in calcium', exampleSentence: 'Drink a glass of warm milk every morning.', emoji: '🥛', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'RING', definition: 'A circular band worn on a finger', exampleSentence: 'The golden ring sparkled in the sunlight.', emoji: '💍', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'DRUM', definition: 'A musical instrument you beat with sticks', exampleSentence: 'He played a joyful beat on the snare drum.', emoji: '🥁', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'KITE', definition: 'A light toy flown high on the wind', exampleSentence: 'Fly your diamond kite on a breezy afternoon.', emoji: '🪁', targetClass: StudentClass.ukg, difficulty: 1),
    SpellBeeWord(word: 'SHIP', definition: 'A very large boat that sails on oceans', exampleSentence: 'The cargo ship sailed across the Arabian Sea.', emoji: '🚢', targetClass: StudentClass.ukg, difficulty: 1),

    // --- Class 1: Sight Words & Everyday Vocabulary ---
    SpellBeeWord(word: 'APPLE', definition: 'A sweet round fruit that grows on trees', exampleSentence: 'An apple a day keeps the doctor away.', emoji: '🍎', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'WATER', definition: 'A clear liquid essential for life', exampleSentence: 'Always drink plenty of pure clean water.', emoji: '💧', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'HOUSE', definition: 'A building where a family lives', exampleSentence: 'Our warm house has a beautiful garden.', emoji: '🏡', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'CHAIR', definition: 'A piece of furniture to sit on', exampleSentence: 'Please sit comfortably in the wooden chair.', emoji: '🪑', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'TABLE', definition: 'Furniture with a flat top and four legs', exampleSentence: 'Dinner is served on the dining table.', emoji: '🪵', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'GREEN', definition: 'The color of grass and leaves', exampleSentence: 'The parrots have bright green feathers.', emoji: '🟩', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'SMILE', definition: 'A happy facial expression', exampleSentence: 'A warm smile brightens up everyone’s day.', emoji: '😊', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'TRAIN', definition: 'A railway vehicle that runs on tracks', exampleSentence: 'The express train zoomed past the platform.', emoji: '🚆', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'CLOUD', definition: 'A white fluffy mass of water vapour in sky', exampleSentence: 'The puffy white cloud looked like an elephant.', emoji: '☁️', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'PLANT', definition: 'A living organism that grows in soil', exampleSentence: 'Water the rose plant every morning.', emoji: '🌱', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'CLOCK', definition: 'An instrument used for telling time', exampleSentence: 'The wall clock struck exactly twelve noon.', emoji: '⏰', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'BREAD', definition: 'Baked food made of flour and yeast', exampleSentence: 'Freshly baked bread smells wonderful.', emoji: '🍞', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'TIGER', definition: 'A large wild cat with black stripes', exampleSentence: 'The royal Bengal tiger prowled the forest.', emoji: '🐅', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'HORSE', definition: 'A noble animal known for galloping', exampleSentence: 'The brown horse galloped across the green field.', emoji: '🐎', targetClass: StudentClass.class1, difficulty: 2),
    SpellBeeWord(word: 'RIVER', definition: 'A natural stream of flowing fresh water', exampleSentence: 'The Ganga is a sacred river in India.', emoji: '🏞️', targetClass: StudentClass.class1, difficulty: 2),

    // --- Class 2: Blends, Silent Letters & Compounds ---
    SpellBeeWord(word: 'GARDEN', definition: 'An outdoor area with plants and flowers', exampleSentence: 'Butterflies flutter across our school garden.', emoji: '🌷', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'FRIEND', definition: 'A person you know well and trust', exampleSentence: 'A true friend is a treasure for life.', emoji: '🤝', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'MONKEY', definition: 'A playful mammal that swings from branches', exampleSentence: 'The clever monkey peeled a ripe yellow banana.', emoji: '🐒', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'YELLOW', definition: 'The bright sunny color of sunflowers', exampleSentence: 'Ripe mangoes are golden yellow in color.', emoji: '🟨', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'SCHOOL', definition: 'A temple of education and learning', exampleSentence: 'We learn math and science at our school.', emoji: '🏫', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'PENCIL', definition: 'A graphite rod inside wood for drawing', exampleSentence: 'Sharpen your pencil before writing the test.', emoji: '✏️', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'ORANGE', definition: 'A citrus juicy fruit with thick skin', exampleSentence: 'Drink fresh orange juice for Vitamin C.', emoji: '🍊', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'WINTER', definition: 'The coldest season of the year', exampleSentence: 'Wear cozy woolen sweaters during chilly winter.', emoji: '❄️', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'SUMMER', definition: 'The warmest sunny season of the year', exampleSentence: 'We enjoy cold ice cream during hot summer.', emoji: '☀️', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'CANDLE', definition: 'Wax with a central wick giving light', exampleSentence: 'Light a birthday candle on the cake.', emoji: '🕯️', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'FOREST', definition: 'A large area densely covered with trees', exampleSentence: 'Wild deer graze peacefully in the deep forest.', emoji: '🌲', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'BRIDGE', definition: 'A structure built over rivers or roads', exampleSentence: 'The steel bridge spans across the wide river.', emoji: '🌉', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'PLANET', definition: 'A celestial body orbiting a star', exampleSentence: 'Earth is the third planet from the sun.', emoji: '🪐', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'DOCTOR', definition: 'A medical professional who heals the sick', exampleSentence: 'The kind doctor helped cure my fever.', emoji: '🩺', targetClass: StudentClass.class2, difficulty: 2),
    SpellBeeWord(word: 'BANANA', definition: 'A long yellow curved sweet fruit', exampleSentence: 'Bananas are rich in potassium and energy.', emoji: '🍌', targetClass: StudentClass.class2, difficulty: 2),

    // --- Class 3: Tricky Double Letters & Silent Letters ---
    SpellBeeWord(word: 'ISLAND', definition: 'Land completely surrounded by water', exampleSentence: 'The Andaman and Nicobar group is a tropical island chain.', emoji: '🏝️', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'KNIGHT', definition: 'A brave armored warrior of medieval history', exampleSentence: 'The valiant knight protected the royal kingdom.', emoji: '🛡️', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'WEATHER', definition: 'Day-to-day atmospheric conditions of air', exampleSentence: 'The morning weather is cool and breezy today.', emoji: '⛅', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'DOLPHIN', definition: 'An intelligent playful marine mammal', exampleSentence: 'A friendly dolphin leaped above the ocean waves.', emoji: '🐬', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'BLANKET', definition: 'A warm woolen covering on a bed', exampleSentence: 'Wrap yourself in a snug blanket on cold nights.', emoji: '🛏️', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'FEATHER', definition: 'Light epidermal growth on birds', exampleSentence: 'A peacock feather displays stunning royal colors.', emoji: '🪶', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'AUTUMN', definition: 'The season between summer and winter', exampleSentence: 'Golden leaves fall from trees during autumn.', emoji: '🍂', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'RAINBOW', definition: 'An arc of seven colors in the sky after rain', exampleSentence: 'Look at the vibrant rainbow formed in the morning sky.', emoji: '🌈', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'DIAMOND', definition: 'A precious brilliant gemstone of pure carbon', exampleSentence: 'The diamond ring sparkles with fiery brilliance.', emoji: '💎', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'COMPASS', definition: 'An instrument showing magnetic directions', exampleSentence: 'The compass needle always points towards North.', emoji: '🧭', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'CAPTAIN', definition: 'A leader of a ship, flight, or sports team', exampleSentence: 'The cricket captain guided the team to victory.', emoji: '🧑‍✈️', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'PUPPY', definition: 'A young baby dog', exampleSentence: 'The playful golden puppy ran after the tennis ball.', emoji: '🐕', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'CASTLE', definition: 'A large fortified stone building of kings', exampleSentence: 'The majestic castle stood upon the rocky hill.', emoji: '🏰', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'LISTEN', definition: 'To pay close attention with your ears', exampleSentence: 'Always listen carefully to your teacher in class.', emoji: '👂', targetClass: StudentClass.class3, difficulty: 3),
    SpellBeeWord(word: 'SHADOW', definition: 'A dark shape cast when light is blocked', exampleSentence: 'My shadow grows longer as the evening approaches.', emoji: '👤', targetClass: StudentClass.class3, difficulty: 3),

    // --- Class 4: Syllabic & Compound Intermediate Words ---
    SpellBeeWord(word: 'BUTTERFLY', definition: 'An insect with large, colourful wings', exampleSentence: 'A monarch butterfly hovered over the fragrant flower.', emoji: '🦋', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'BEAUTIFUL', definition: 'Pleasing the senses or mind aesthetically', exampleSentence: 'The Taj Mahal is a world-famous beautiful monument.', emoji: '🌸', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'MOUNTAIN', definition: 'A very tall natural elevation of Earth’s surface', exampleSentence: 'Mount Everest is the highest mountain peak on Earth.', emoji: '🏔️', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'COURAGE', definition: 'Bravery to face danger, pain, or difficulty', exampleSentence: 'It takes immense courage to stand up for the truth.', emoji: '🦁', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'CHAMPION', definition: 'A person who has surpassed all rivals in contest', exampleSentence: 'Curio Academy celebrates every hardworking champion.', emoji: '🏆', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'TREASURE', definition: 'A quantity of precious metals, gems, or valuables', exampleSentence: 'Books are a limitless treasure chest of wisdom.', emoji: '🪙', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'SURPRISE', definition: 'An unexpected event or pleasant astonishment', exampleSentence: 'Her friends organized a lovely surprise party.', emoji: '🎁', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'CALENDAR', definition: 'A chart showing days, weeks, and months of year', exampleSentence: 'Mark the annual sports day on your wall calendar.', emoji: '📅', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'DINOSAUR', definition: 'A prehistoric reptile that lived millions of years ago', exampleSentence: 'The giant dinosaur fossils are exhibited in the museum.', emoji: '🦖', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'ASTRONOMY', definition: 'The scientific study of stars and the universe', exampleSentence: 'He looked through the telescope to study astronomy.', emoji: '🔭', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'WHISPER', definition: 'To speak very softly using breath without vocal cords', exampleSentence: 'Speak in a gentle whisper when inside the silent library.', emoji: '🤫', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'FEATHER', definition: 'Light plumage structure of bird wings', exampleSentence: 'Birds clean each delicate feather with their beak.', emoji: '🪶', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'JEWELLERY', definition: 'Decorative ornaments worn on clothes or body', exampleSentence: 'Ancient queens adorned themselves with gemstone jewellery.', emoji: '👑', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'NEIGHBOUR', definition: 'A person living nearby or next door', exampleSentence: 'Our kind neighbour helped look after our plants.', emoji: '🏡', targetClass: StudentClass.class4, difficulty: 3),
    SpellBeeWord(word: 'VOLCANO', definition: 'A mountain with a crater that erupts magma and ash', exampleSentence: 'Red-hot molten lava erupted from the active volcano.', emoji: '🌋', targetClass: StudentClass.class4, difficulty: 3),

    // --- Class 5: Polysyllabic & Classical Spell Bee Words ---
    SpellBeeWord(word: 'EXPERIMENT', definition: 'A scientific procedure undertaken to test hypothesis', exampleSentence: 'We conducted an exciting gravity experiment in lab.', emoji: '🧪', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'GOVERNMENT', definition: 'The governing body of a nation, state, or community', exampleSentence: 'The democratic government builds roads and schools.', emoji: '🏛️', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'LABORATORY', definition: 'A room equipped for scientific experiments and study', exampleSentence: 'Students wear safety goggles inside the chemistry laboratory.', emoji: '🔬', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'KNOWLEDGE', definition: 'Facts, information, and skills acquired through learning', exampleSentence: 'Knowledge is power that illuminates your future.', emoji: '💡', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'ORCHESTRA', definition: 'A large group of musicians playing classical instruments', exampleSentence: 'The symphony orchestra performed a breathtaking melody.', emoji: '🎻', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'AEROPLANE', definition: 'A powered flying vehicle with fixed wings', exampleSentence: 'The supersonic aeroplane soared high above the clouds.', emoji: '✈️', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'SATELLITE', definition: 'An artificial body placed in orbit round the Earth', exampleSentence: 'The weather satellite sends photos of cyclonic storms.', emoji: '🛰️', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'SUBMARINE', definition: 'A warship designed to operate completely underwater', exampleSentence: 'The navy submarine dove beneath the deep ocean waves.', emoji: '🚢', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'DELICIOUS', definition: 'Highly pleasant to the taste and aroma', exampleSentence: 'Grandmother baked delicious warm cardamom cookies.', emoji: '🍪', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'EXCELLENT', definition: 'Extremely good and outstanding in quality', exampleSentence: 'Your effort and handwriting in this exam is excellent.', emoji: '🌟', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'SCIENTIST', definition: 'A person studying or having expert knowledge of sciences', exampleSentence: 'Dr. APJ Abdul Kalam was a revered Indian scientist.', emoji: '🧑‍🔬', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'TELEPHONE', definition: 'A system for transmitting sound over distances by wire', exampleSentence: 'The antique brass telephone rang in the living room.', emoji: '☎️', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'TRIANGLE', definition: 'A plane figure with three straight sides and angles', exampleSentence: 'A right-angled triangle has one angle equal to 90 degrees.', emoji: '📐', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'CHANDELIER', definition: 'A large decorative hanging light with crystal branches', exampleSentence: 'A sparkling crystal chandelier illuminated the palace hall.', emoji: '✨', targetClass: StudentClass.class5, difficulty: 4),
    SpellBeeWord(word: 'PYRAMID', definition: 'A monumental structure with a square base and triangle sides', exampleSentence: 'The Great Pyramid of Giza was built in ancient times.', emoji: '🔺', targetClass: StudentClass.class5, difficulty: 4),

    // --- Class 6: Middle School Competition Spell Bee Words ---
    SpellBeeWord(word: 'ACCOMMODATE', definition: 'To provide lodging or sufficient space for', exampleSentence: 'The grand auditorium can accommodate over two thousand guests.', emoji: '🏨', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'EMBARRASS', definition: 'To cause someone to feel awkward, self-conscious, or ashamed', exampleSentence: 'True gentlemen never embarrass others in public.', emoji: '😳', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'MILLENNIUM', definition: 'A period of a thousand years', exampleSentence: 'The dawn of the new millennium was celebrated globally.', emoji: '⏳', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'OCCURRENCE', definition: 'An incident or event that happens', exampleSentence: 'A solar eclipse is a fascinating astronomical occurrence.', emoji: '🌘', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'DISCIPLINE', definition: 'The practice of training people to obey rules and code', exampleSentence: 'Self-discipline is the bridge between goals and accomplishment.', emoji: '🎯', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'GUARANTEE', definition: 'A formal assurance that conditions will be fulfilled', exampleSentence: 'The manufacturer offers a two-year warranty guarantee.', emoji: '📜', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'PARALLEL', definition: 'Lines occurring side by side with continuous equal distance', exampleSentence: 'Railway tracks remain parallel throughout the journey.', emoji: '🛤️', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'HYGIENE', definition: 'Conditions or practices conducive to maintaining health', exampleSentence: 'Maintaining personal hygiene protects against bacterial diseases.', emoji: '🧼', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'LIEUTENANT', definition: 'A commissioned officer rank in the armed forces', exampleSentence: 'The brave army lieutenant led the rescue patrol.', emoji: '🎖️', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'RESTAURANT', definition: 'A place where people pay to sit and eat meals prepared', exampleSentence: 'The family dined at an authentic Indian heritage restaurant.', emoji: '🍽️', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'CAMOUFLAGE', definition: 'The disguising of military personnel or animals in nature', exampleSentence: 'The snow leopard uses rock camouflage to blend into mountains.', emoji: '🐆', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'METEORITE', definition: 'A piece of rock from outer space that strikes Earth', exampleSentence: 'The meteorite created a huge crater millions of years ago.', emoji: '☄️', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'PNEUMONIA', definition: 'Lung inflammation caused by bacterial or viral infection', exampleSentence: 'Doctors prescribed antibiotics to cure the chest pneumonia.', emoji: '🫁', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'SYMPHONY', definition: 'An elaborate musical composition for full orchestra', exampleSentence: 'Beethoven composed his famous Fifth Symphony in Vienna.', emoji: '🎼', targetClass: StudentClass.class6, difficulty: 4),
    SpellBeeWord(word: 'CATERPILLAR', definition: 'The worm-like larval form of a butterfly or moth', exampleSentence: 'The hungry caterpillar munched on juicy green leaves.', emoji: '🐛', targetClass: StudentClass.class6, difficulty: 4),

    // --- Class 7: Advanced Spell Bee Vocabulary ---
    SpellBeeWord(word: 'CONSCIENTIOUS', definition: 'Wishing to do one’s work or duty thoroughly and well', exampleSentence: 'She is a conscientious student who never misses homework.', emoji: '📚', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'MISCHIEVOUS', definition: 'Causing or showing a fondness for causing trouble playfully', exampleSentence: 'The mischievous puppy hid my favourite leather shoe.', emoji: '😼', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'RHYTHM', definition: 'A strong, regular, repeated pattern of movement or sound', exampleSentence: 'Dancers tapped their feet in harmony with the drum rhythm.', emoji: '🥁', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'PHARAOH', definition: 'A monarch or ruler in ancient Egypt', exampleSentence: 'King Tutankhamun was a famed pharaoh of ancient Egypt.', emoji: '🏺', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'ENTREPRENEUR', definition: 'A person who sets up a business taking on financial risks', exampleSentence: 'The visionary entrepreneur built an innovative clean-tech startup.', emoji: '💼', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'EXAGGERATE', definition: 'To represent something as greater or larger than is true', exampleSentence: 'Do not exaggerate small problems into giant crises.', emoji: '📢', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'BUREAUCRACY', definition: 'A system of government with many administrative procedures', exampleSentence: 'Digital governance simplifies paperwork and cuts red-tape bureaucracy.', emoji: '🏢', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'SOVEREIGNTY', definition: 'Supreme power or authority of a nation over its land', exampleSentence: 'Citizens take solemn pride in defending national sovereignty.', emoji: '🇮🇳', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'QUINTESSENCE', definition: 'The purest, most perfect example or embodiment of a quality', exampleSentence: 'Her selfless dedication was the quintessence of kindness.', emoji: '💎', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'RECONNAISSANCE', definition: 'Military observation of a region to locate an enemy or feature', exampleSentence: 'The surveillance drone flew on a high-altitude reconnaissance mission.', emoji: '🛰️', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'BOURGEOISIE', definition: 'The social class comprising the middle and upper-middle order', exampleSentence: 'Historians analyzed the rise of the merchant bourgeoisie.', emoji: '🏛️', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'HIERARCHY', definition: 'A system in which members of an organization are ranked by status', exampleSentence: 'Every ecosystem possesses a complex ecological hierarchy.', emoji: '📊', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'QUESTIONNAIRE', definition: 'A set of printed questions with a choice of answers for survey', exampleSentence: 'Volunteers answered a detailed environmental questionnaire.', emoji: '📝', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'SURVEILLANCE', definition: 'Close observation, especially of a suspected person or area', exampleSentence: 'Modern airports operate round-the-clock security surveillance.', emoji: '📹', targetClass: StudentClass.class7, difficulty: 5),
    SpellBeeWord(word: 'MAINTENANCE', definition: 'The process of preserving a condition or apparatus in good repair', exampleSentence: 'Regular engine maintenance guarantees smooth long journeys.', emoji: '🔧', targetClass: StudentClass.class7, difficulty: 5),

    // --- Class 8: Champion Spell Bee Words ---
    SpellBeeWord(word: 'ABERRATION', definition: 'A departure from what is normal, usual, or expected', exampleSentence: 'The sudden snowfall in the desert was a strange meteorological aberration.', emoji: '🌀', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'IDIOSYNCRASY', definition: 'A distinctive or peculiar mode of behavior of an individual', exampleSentence: 'One of his charming idiosyncrasies was drinking cocoa through a cinnamon stick.', emoji: '🧐', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'ONOMATOPOEIA', definition: 'A word that phonetically imitates the sound it describes', exampleSentence: 'Words like buzz, hiss, and sizzle are examples of onomatopoeia.', emoji: '🐝', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'KALEIDOSCOPE', definition: 'An optical toy showing shifting reflections and symmetrical patterns', exampleSentence: 'Turn the tube to watch a kaleidoscope of dazzling geometric shapes.', emoji: '🔭', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'PERSEVERANCE', definition: 'Persistence in doing something despite difficulty or delay', exampleSentence: 'Great scientific discoveries are born from relentless perseverance.', emoji: '🧗', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'PHILANTHROPY', definition: 'The desire to promote the welfare of others by donating funds', exampleSentence: 'The foundation engages in global medical philanthropy.', emoji: '🤲', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'PROSCRIPTION', definition: 'The action of forbidding or banishing something condemned', exampleSentence: 'The treaty established an international proscription against chemical weapons.', emoji: '🚫', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'SYNCHRONOUS', definition: 'Existing or occurring at the exact same time or rate', exampleSentence: 'Satellites travel in synchronous orbit matching the Earth’s rotation.', emoji: '⏱️', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'PSEUDONYM', definition: 'A fictitious name used by an author to publish writings', exampleSentence: 'Samuel Clemens used the famous pseudonym Mark Twain.', emoji: '✒️', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'VINDICATIVE', definition: 'Having or showing a strong unreasoning desire for revenge', exampleSentence: 'Wise leaders choose empathy and forgiveness over vindictive grudges.', emoji: '⚖️', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'ZEITGEIST', definition: 'The defining spirit or mood of a particular period of history', exampleSentence: 'Artificial intelligence defines the technological zeitgeist of our era.', emoji: '🌍', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'CHAUVINISM', definition: 'Excessive or prejudiced loyalty or support for one’s own cause', exampleSentence: 'Global peace requires overcoming blind nationalistic chauvinism.', emoji: '🕊️', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'MAGNANIMOUS', definition: 'Generous or forgiving, especially towards a rival or less powerful', exampleSentence: 'The victorious athlete was magnanimous in applauding her opponent.', emoji: '👑', targetClass: StudentClass.class8, difficulty: 5),
    SpellBeeWord(word: 'PUPIL', definition: 'A student in school or dark circular opening in center of eye', exampleSentence: 'The dedicated pupil solved every challenge in the spelling contest.', emoji: '👁️', targetClass: StudentClass.class8, difficulty: 4),
    SpellBeeWord(word: 'EQUILIBRIUM', definition: 'A state in which opposing forces or influences are balanced', exampleSentence: 'Tightrope walkers use long poles to maintain physical equilibrium.', emoji: '⚖️', targetClass: StudentClass.class8, difficulty: 5),
  ];

  /// Returns all available words for a specific class or adjacent classes
  List<SpellBeeWord> getWordsForClass(StudentClass studentClass) {
    final list = allWordsList;
    final exact = list.where((w) => w.targetClass == studentClass).toList();
    if (exact.length >= 10) return exact;

    // Expand to same tier if exact count is below 10
    final tierWords = list.where((w) => w.targetClass.tier == studentClass.tier).toList();
    return tierWords.isNotEmpty ? tierWords : list;
  }

  /// Returns 5 words tailored for an Adventure Stage (1 to 10)
  List<SpellBeeWord> getWordsForStage(StudentClass studentClass, int stage) {
    final pool = getWordsForClass(studentClass);
    // Deterministic progression for stages so replaying is consistent
    final seed = (studentClass.label.hashCode) ^ (stage * 31);
    final stageRandom = Random(seed);
    final shuffled = List<SpellBeeWord>.from(pool)..shuffle(stageRandom);
    
    // Pick 5 words (loop around if needed)
    final words = <SpellBeeWord>[];
    for (int i = 0; i < 5; i++) {
      words.add(shuffled[i % shuffled.length]);
    }
    return words;
  }

  /// Returns random words for 60-Second Speed Spell Bee Sprint
  SpellBeeWord getRandomSprintWord(StudentClass studentClass) {
    final pool = getWordsForClass(studentClass);
    return pool[_random.nextInt(pool.length)];
  }

  /// Returns a curated mock exam set (e.g. 10 competition words) for the student class
  List<SpellBeeWord> getMockExamWords(StudentClass studentClass, {int count = 10}) {
    final pool = getWordsForClass(studentClass);
    final shuffled = List<SpellBeeWord>.from(pool)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Returns words for Spot-The-Correct-Spelling Olympiad MCQ
  List<SpellBeeWord> getMcqWords(StudentClass studentClass, {int count = 10}) {
    final pool = getWordsForClass(studentClass);
    final shuffled = List<SpellBeeWord>.from(pool)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// Searches the word bank by word, meaning, or language of origin
  List<SpellBeeWord> searchWords(String query, {StudentClass? filterClass}) {
    final q = query.trim().toUpperCase();
    return allWordsList.where((w) {
      if (filterClass != null && w.targetClass != filterClass) return false;
      if (q.isEmpty) return true;
      return w.word.toUpperCase().contains(q) ||
          w.definition.toUpperCase().contains(q) ||
          w.origin.toUpperCase().contains(q);
    }).toList();
  }

  /// Finds a specific word in the repository
  SpellBeeWord? findWord(String word) {
    final clean = word.trim().toUpperCase();
    try {
      return allWordsList.firstWhere((w) => w.word.toUpperCase() == clean);
    } catch (_) {
      return null;
    }
  }

  /// Generates scrambled letter tiles + optional decoys for the student to tap
  List<String> generateLetterTiles(SpellBeeWord word, {int maxDecoys = 2}) {
    final letters = word.letterList;
    final decoys = <String>[];

    // Pick 1 to 2 random distinct alphabet decoys not in the word (or random letters)
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < maxDecoys; i++) {
      final randChar = alphabet[_random.nextInt(alphabet.length)];
      decoys.add(randChar);
    }

    final combined = [...letters, ...decoys];
    combined.shuffle(_random);
    return combined;
  }
}
