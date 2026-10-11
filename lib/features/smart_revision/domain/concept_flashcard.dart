import '../../../data/models/grade_tier.dart';
import '../../../data/models/student_profile.dart';

class ConceptFlashcard {
  final String id;
  final String subjectId;
  final String subjectName;
  final String emoji;
  final String frontPromptEn;
  final String frontPromptHi;
  final String backAnswerEn;
  final String backAnswerHi;
  final String explanationEn;
  final String explanationHi;
  final GradeTier targetTier;

  const ConceptFlashcard({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.emoji,
    required this.frontPromptEn,
    required this.frontPromptHi,
    required this.backAnswerEn,
    required this.backAnswerHi,
    required this.explanationEn,
    required this.explanationHi,
    required this.targetTier,
  });
}

class FlashcardRepository {
  static final FlashcardRepository instance = FlashcardRepository._();
  FlashcardRepository._();

  List<ConceptFlashcard> getAllFlashcards() => List.unmodifiable(_allCards);

  List<ConceptFlashcard> getFlashcardsForTier(GradeTier tier, {String? filterSubject}) {
    final list = _allCards.where((c) => c.targetTier == tier).toList();
    if (filterSubject == null || filterSubject.isEmpty || filterSubject == 'all') {
      return list;
    }
    return list.where((c) => c.subjectId == filterSubject).toList();
  }

  List<ConceptFlashcard> getFlashcardsForClass(StudentClass studentClass, {String? filterSubject}) {
    final list = getFlashcardsForTier(studentClass.tier, filterSubject: filterSubject);
    if (list.isNotEmpty) return list;
    return filterSubject == null || filterSubject == 'all'
        ? _allCards.take(15).toList()
        : _allCards.where((c) => c.subjectId == filterSubject).toList();
  }

  static const List<ConceptFlashcard> _allCards = [
    // --- Early Explorer (LKG - Class 1) ---
    ConceptFlashcard(
      id: 'ee_m_1',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '📐',
      frontPromptEn: 'How many sides does a Triangle have?',
      frontPromptHi: 'त्रिभुज (Triangle) की कितनी भुजाएँ (Sides) होती हैं?',
      backAnswerEn: '3 Sides',
      backAnswerHi: '3 भुजाएँ',
      explanationEn: 'A triangle has 3 straight sides and 3 corners.',
      explanationHi: 'त्रिभुज में 3 सीधी भुजाएँ और 3 कोने होते हैं।',
      targetTier: GradeTier.earlyExplorer,
    ),
    ConceptFlashcard(
      id: 'ee_m_2',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '⭕',
      frontPromptEn: 'Does a Circle have any corners?',
      frontPromptHi: 'क्या वृत्त (Circle) का कोई कोना होता है?',
      backAnswerEn: 'No (0 corners)',
      backAnswerHi: 'नहीं (0 कोने)',
      explanationEn: 'A circle is perfectly round and has no straight sides or corners.',
      explanationHi: 'वृत्त पूरी तरह गोल होता है और इसका कोई कोना नहीं होता।',
      targetTier: GradeTier.earlyExplorer,
    ),
    ConceptFlashcard(
      id: 'ee_e_1',
      subjectId: 'english',
      subjectName: 'English',
      emoji: '🔤',
      frontPromptEn: 'What are the 5 English Vowels?',
      frontPromptHi: 'अंग्रेजी में 5 स्वर (Vowels) कौन से हैं?',
      backAnswerEn: 'A, E, I, O, U',
      backAnswerHi: 'A, E, I, O, U',
      explanationEn: 'Every English word has at least one vowel sound!',
      explanationHi: 'हर अंग्रेजी शब्द में कम से कम एक स्वर की ध्वनि होती है!',
      targetTier: GradeTier.earlyExplorer,
    ),
    ConceptFlashcard(
      id: 'ee_s_1',
      subjectId: 'science',
      subjectName: 'Science',
      emoji: '🌱',
      frontPromptEn: 'Which part of a plant grows under the soil?',
      frontPromptHi: 'पौधे का कौन सा भाग जमीन के अंदर बढ़ता है?',
      backAnswerEn: 'Roots',
      backAnswerHi: 'जड़ें (Roots)',
      explanationEn: 'Roots absorb water and nutrients from the soil.',
      explanationHi: 'जड़ें मिट्टी से पानी और पोषक तत्व सोखती हैं।',
      targetTier: GradeTier.earlyExplorer,
    ),
    ConceptFlashcard(
      id: 'ee_h_1',
      subjectId: 'hindi',
      subjectName: 'Hindi',
      emoji: '🥭',
      frontPromptEn: 'हिंदी वर्णमाला में पहला स्वर कौन सा है?',
      frontPromptHi: 'हिंदी वर्णमाला में पहला स्वर कौन सा है?',
      backAnswerEn: 'अ (A)',
      backAnswerHi: 'अ (अ से अनार)',
      explanationEn: 'अ से अनार, आ से आम हिंदी के प्रारंभिक स्वर हैं।',
      explanationHi: 'अ से अनार, आ से आम हिंदी के प्रारंभिक स्वर हैं।',
      targetTier: GradeTier.earlyExplorer,
    ),

    // --- Primary Builder (Class 2 - 5) ---
    ConceptFlashcard(
      id: 'pb_m_1',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '📏',
      frontPromptEn: 'What is the formula for the Perimeter of a Rectangle?',
      frontPromptHi: 'आयत के परिमाप (Perimeter) का सूत्र क्या है?',
      backAnswerEn: '2 × (Length + Breadth)',
      backAnswerHi: '2 × (लंबाई + चौड़ाई)',
      explanationEn: 'Perimeter is the total boundary distance around the shape.',
      explanationHi: 'परिमाप किसी आकृति के चारों ओर की कुल दूरी होती है।',
      targetTier: GradeTier.primaryBuilder,
    ),
    ConceptFlashcard(
      id: 'pb_m_2',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '🥧',
      frontPromptEn: 'What is an Equivalent Fraction to 1/2?',
      frontPromptHi: '1/2 का समतुल्य भिन्न (Equivalent Fraction) क्या है?',
      backAnswerEn: '2/4 or 3/6 or 5/10',
      backAnswerHi: '2/4 या 3/6 या 5/10',
      explanationEn: 'Multiplying numerator and denominator by the same number gives an equivalent fraction.',
      explanationHi: 'अंश और हर दोनों को एक ही संख्या से गुणा करने पर समतुल्य भिन्न मिलता है।',
      targetTier: GradeTier.primaryBuilder,
    ),
    ConceptFlashcard(
      id: 'pb_e_1',
      subjectId: 'english',
      subjectName: 'English',
      emoji: '📖',
      frontPromptEn: 'What is a Noun?',
      frontPromptHi: 'संज्ञा (Noun) क्या है?',
      backAnswerEn: 'Name of a Person, Place, Animal, or Thing',
      backAnswerHi: 'किसी व्यक्ति, वस्तु, स्थान या जानवर का नाम',
      explanationEn: 'Examples: Rahul, Delhi, Dog, Book are all nouns.',
      explanationHi: 'उदाहरण: राहुल, दिल्ली, कुत्ता, किताब सभी संज्ञा हैं।',
      targetTier: GradeTier.primaryBuilder,
    ),
    ConceptFlashcard(
      id: 'pb_s_1',
      subjectId: 'science',
      subjectName: 'Science',
      emoji: '☀️',
      frontPromptEn: 'What process do green plants use to make food?',
      frontPromptHi: 'हरे पौधे भोजन बनाने के लिए किस प्रक्रिया का उपयोग करते हैं?',
      backAnswerEn: 'Photosynthesis',
      backAnswerHi: 'प्रकाश संश्लेषण (Photosynthesis)',
      explanationEn: 'Plants use sunlight, water, and carbon dioxide with chlorophyll to produce food.',
      explanationHi: 'पौधे सूर्य के प्रकाश, पानी और कार्बन डाइऑक्साइड से भोजन बनाते हैं।',
      targetTier: GradeTier.primaryBuilder,
    ),
    ConceptFlashcard(
      id: 'pb_s_2',
      subjectId: 'science',
      subjectName: 'Science',
      emoji: '💧',
      frontPromptEn: 'At what temperature does pure water freeze into ice?',
      frontPromptHi: 'शुद्ध पानी किस तापमान पर बर्फ में जमता है?',
      backAnswerEn: '0° Celsius (32° Fahrenheit)',
      backAnswerHi: '0° सेल्सियस (0° C)',
      explanationEn: '0°C is the freezing point of water and 100°C is the boiling point.',
      explanationHi: '0°C पानी का हिमांक है और 100°C क्वथनांक (उबलने का बिंदु) है।',
      targetTier: GradeTier.primaryBuilder,
    ),

    // --- Middle Achiever (Class 6 - 8) ---
    ConceptFlashcard(
      id: 'ma_m_1',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '📐',
      frontPromptEn: 'What is Pythagoras Theorem for a right-angled triangle?',
      frontPromptHi: 'समकोण त्रिभुज के लिए पाइथागोरस प्रमेय क्या है?',
      backAnswerEn: 'Hypotenuse² = Base² + Perpendicular²',
      backAnswerHi: 'कर्ण² = आधार² + लंब²',
      explanationEn: 'In a right triangle with legs a and b and hypotenuse c: a² + b² = c².',
      explanationHi: 'समकोण त्रिभुज में सबसे लंबी भुजा (कर्ण) का वर्ग अन्य दो भुजाओं के वर्गों के योग के बराबर होता है।',
      targetTier: GradeTier.middleAchiever,
    ),
    ConceptFlashcard(
      id: 'ma_m_2',
      subjectId: 'math',
      subjectName: 'Math',
      emoji: '📊',
      frontPromptEn: 'What is the sum of interior angles in any triangle?',
      frontPromptHi: 'किसी भी त्रिभुज के तीनों अंतः कोणों का योग कितना होता है?',
      backAnswerEn: '180°',
      backAnswerHi: '180° (एक सौ अस्सी अंश)',
      explanationEn: 'No matter the shape of the triangle, angle A + B + C always equals 180°.',
      explanationHi: 'त्रिभुज के तीनों कोणों का योग सदैव 180 अंश होता है।',
      targetTier: GradeTier.middleAchiever,
    ),
    ConceptFlashcard(
      id: 'ma_s_1',
      subjectId: 'science',
      subjectName: 'Science',
      emoji: '⚡',
      frontPromptEn: 'What is the SI unit of Electric Current?',
      frontPromptHi: 'विद्युत धारा (Electric Current) का SI मात्रक क्या है?',
      backAnswerEn: 'Ampere (A)',
      backAnswerHi: 'एम्पीयर (Ampere / A)',
      explanationEn: 'Electric current is measured in amperes using an ammeter.',
      explanationHi: 'विद्युत धारा को एमीटर द्वारा एम्पीयर में मापा जाता है।',
      targetTier: GradeTier.middleAchiever,
    ),
    ConceptFlashcard(
      id: 'ma_s_2',
      subjectId: 'science',
      subjectName: 'Science',
      emoji: '🧪',
      frontPromptEn: 'What is the chemical formula for common table salt?',
      frontPromptHi: 'साधारण नमक (Common Salt) का रासायनिक सूत्र क्या है?',
      backAnswerEn: 'NaCl (Sodium Chloride)',
      backAnswerHi: 'NaCl (सोडियम क्लोराइड)',
      explanationEn: 'Formed by sodium (Na⁺) and chloride (Cl⁻) ions in an ionic crystal lattice.',
      explanationHi: 'सोडियम और क्लोरीन आयनों से मिलकर बना यौगिक।',
      targetTier: GradeTier.middleAchiever,
    ),
    ConceptFlashcard(
      id: 'ma_e_1',
      subjectId: 'english',
      subjectName: 'English',
      emoji: '📝',
      frontPromptEn: 'What is an Active vs Passive voice difference?',
      frontPromptHi: 'Active Voice और Passive Voice में क्या अंतर है?',
      backAnswerEn: 'Active: Subject performs action. Passive: Subject receives action.',
      backAnswerHi: 'Active में कर्ता कार्य करता है। Passive में कर्म पर बल होता है।',
      explanationEn: 'Active: "Rohan kicked the ball." Passive: "The ball was kicked by Rohan."',
      explanationHi: 'Active: "रोहन ने गेंद मारी।" Passive: "गेंद रोहन द्वारा मारी गई।"',
      targetTier: GradeTier.middleAchiever,
    ),
  ];
}
