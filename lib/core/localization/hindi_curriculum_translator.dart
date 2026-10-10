/// Comprehensive Hindi translation helper for curriculum questions, hints,
/// step-by-step solutions, options, and pedagogical learning sheets.
class HindiCurriculumTranslator {
  const HindiCurriculumTranslator._();

  // ==========================================
  // 1. QUESTION PROMPT TRANSLATION
  // ==========================================
  static String translatePrompt(String text) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();

    // 1. Clean off trailing chapter or grade labels like "(Ch 1: Numbers 1 to 10)" or "(Class 1 Math)"
    final cleanCore = trimmed
        .replaceAll(RegExp(r'\s*\((Ch|Class|Chapter)\s+[^)]+\)$', caseSensitive: false), '')
        .trim();

    // Direct exact matches dictionary
    final exactMap = <String, String>{
      'Which of these items will SLIDE flat on the floor instead of rolling?':
          'इनमें से कौन सी वस्तु लुढ़कने के बजाय फर्श पर फिसलेगी (Slide)?',
      'Which object can BOTH roll and slide?':
          'कौन सी वस्तु लुढ़क (Roll) और फिसल (Slide) दोनों सकती है?',
      'Which of these everyday objects can easily ROLL along the floor?':
          'इनमें से कौन सी वस्तु फर्श पर आसानी से लुढ़क (Roll) सकती है?',
      'Pencils are placed neatly inside a pencil pouch. The pencils are...?':
          'पेंसिलें पेंसिल पाउच के अंदर रखी हैं। पेंसिलें कहां हैं...?',
      'A kitten is resting beneath a wooden dining table. The kitten is...?':
          'एक बिल्ली का बच्चा मेज के नीचे बैठा है। बिल्ली का बच्चा कहां है...?',
      'Which animal is BIGGER: an Elephant 🐘 or a Mouse 🐁?':
          'कौन सा जानवर बड़ा है: हाथी 🐘 या चूहा 🐁?',
      'Which fruit is SMALLER: a Watermelon 🍉 or a Cherry 🍒?':
          'कौन सा फल छोटा है: तरबूज 🍉 या चेरी 🍒?',
      'Which leaf is the SMALLEST: Banana leaf, Mango leaf, or Rose leaf?':
          'इनमें से कौन सी पत्ती सबसे छोटी है: केले की पत्ती, आम की पत्ती या गुलाब की पत्ती?',
      'Which letter comes first?':
          'वर्णमाला में कौन सा अक्षर पहले आता है?',
      'Which letter comes next?':
          'वर्णमाला में अगला अक्षर कौन सा आता है?',
      'Tap cards to find the matching pairs!':
          'समान कार्ड्स की जोड़ी मिलाने के लिए टैप करें!',
      'Tap the matching pairs!':
          'समान जोड़ियों को मिलाने के लिए टैप करें!',
      'Match each number with its shining stars!':
          'प्रत्येक संख्या को उसके चमकते सितारों से मिलाएं!',
      'Pop the opposite of Up!':
          'Up (ऊपर) का विलोम शब्द (Opposite) फोड़ें!',
      'Pop the opposite of Hot!':
          'Hot (गर्म) का विलोम शब्द (Opposite) फोड़ें!',
      'Pop the opposite of Big!':
          'Big (बड़ा) का विलोम शब्द (Opposite) फोड़ें!',
      'Pop the opposite of Day!':
          'Day (दिन) का विलोम शब्द (Opposite) फोड़ें!',
      'Pop the opposite of Happy!':
          'Happy (खुश) का विलोम शब्द (Opposite) फोड़ें!',
      'Which shape has exactly 3 straight sides and 3 sharp corners?':
          'किस आकृति की ठीक 3 सीधी भुजाएँ और 3 कोने होते हैं?',
      'Which shape is perfectly round with NO sides and NO corners?':
          'कौन सी आकृति पूरी तरह गोल होती है जिसकी कोई भुजा या कोना नहीं होता?',
      'Which shape has 4 straight sides that are ALL EQUAL in length?':
          'किस आकृति की चारों सीधी भुजाएँ लंबाई में बिल्कुल समान होती हैं?',
      'A door or a blackboard usually has opposite sides equal. What shape is it?':
          'दरवाजे या ब्लैकबोर्ड की आमने-सामने की भुजाएं समान होती हैं। यह कौन सा आकार है?',
      'Fractions & Tables: Find halves (1/2) in tables':
          'भिन्न और पहाड़े: तालिकाओं में 1/2 खोजें',
    };

    if (exactMap.containsKey(trimmed)) return exactMap[trimmed]!;
    if (exactMap.containsKey(cleanCore)) return exactMap[cleanCore]!;

    // 2. Dynamic Pattern Matching on cleanCore / trimmed
    final target = cleanCore.isNotEmpty ? cleanCore : trimmed;

    // A. Bubble Pop & Early Explorer
    final popItemMatch = RegExp(r'^Pop all bubbles that have\s*(\d+)\s*items or the number\s*(\d+)!?$', caseSensitive: false).firstMatch(target);
    if (popItemMatch != null) {
      return 'उन सभी बुलबुलों को फोड़ें जिनमें ${popItemMatch.group(1)} वस्तुएं या संख्या ${popItemMatch.group(2)} है!';
    }

    final popMatch = RegExp(r'^Pop all bubbles that equal\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (popMatch != null) {
      final val = popMatch.group(1)!.replaceAll('!', '').trim();
      return 'उन सभी बुलबुलों को फोड़ें जिनका मान $val के बराबर है!';
    }

    final popGreatMatch = RegExp(r'^Great!\s*Now pop all bubbles that equal\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (popGreatMatch != null) {
      final val = popGreatMatch.group(1)!.replaceAll('!', '').trim();
      return 'शाबाश! अब उन सभी बुलबुलों को फोड़ें जिनका मान $val है!';
    }

    final popSuperMatch = RegExp(r'^Superstar!\s*Pop all bubbles that equal\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (popSuperMatch != null) {
      final val = popSuperMatch.group(1)!.replaceAll('!', '').trim();
      return 'शानदार! अब उन सभी बुलबुलों को फोड़ें जिनका मान $val है!';
    }

    final popLetterMatch = RegExp(r'^Pop all bubbles with the letter\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (popLetterMatch != null) {
      final val = popLetterMatch.group(1)!.replaceAll('!', '').trim();
      return 'अक्षर $val वाले सभी बुलबुलों को फोड़ें!';
    }

    final popOppositeMatch = RegExp(r'^Pop the opposite of\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (popOppositeMatch != null) {
      final val = popOppositeMatch.group(1)!.replaceAll('!', '').trim();
      return '$val का विलोम शब्द (Opposite) फोड़ें!';
    }

    final popAllTheMatch = RegExp(r'^Pop all the\s*(.+?)\s*bubbles!?$', caseSensitive: false).firstMatch(target);
    if (popAllTheMatch != null) {
      final val = popAllTheMatch.group(1)!.trim();
      return 'उन सभी $val बुलबुलों को फोड़ें!';
    }

    final popTheMatch = RegExp(r'^Pop the\s*(.+?)\s*bubbles!?$', caseSensitive: false).firstMatch(target);
    if (popTheMatch != null) {
      final val = popTheMatch.group(1)!.trim();
      return '$val वाले बुलबुलों को फोड़ें!';
    }

    final popTheThingsMatch = RegExp(r'^Pop the\s*(.+?)!$', caseSensitive: false).firstMatch(target);
    if (popTheThingsMatch != null) {
      final val = popTheThingsMatch.group(1)!.trim();
      return '$val को फोड़ें!';
    }

    final popAddUpMatch = RegExp(r'^Pop bubbles that add up to\s*(\d+)!?$', caseSensitive: false).firstMatch(target);
    if (popAddUpMatch != null) {
      return 'उन बुलबुलों को फोड़ें जिनका जोड़ ${popAddUpMatch.group(1)} बनता है!';
    }

    final popEqualMatch = RegExp(r'^Pop bubbles that equal\s*(.+?)!?$', caseSensitive: false).firstMatch(target);
    if (popEqualMatch != null) {
      final val = popEqualMatch.group(1)!.trim();
      return 'उन बुलबुलों को फोड़ें जिनका मान $val के बराबर है!';
    }

    final popDayNightMatch = RegExp(r'^Pop all (DAYTIME|NIGHTTIME) activities!?$', caseSensitive: false).firstMatch(target);
    if (popDayNightMatch != null) {
      final isDay = popDayNightMatch.group(1)!.toUpperCase().contains('DAY');
      return isDay ? 'दिन के समय की गतिविधियों वाले बुलबुलों को फोड़ें!' : 'रात के समय की गतिविधियों वाले बुलबुलों को फोड़ें!';
    }

    final cardMatchThePairsMatch = RegExp(r'^Match the\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (cardMatchThePairsMatch != null) {
      final val = cardMatchThePairsMatch.group(1)!.replaceAll('!', '').trim().toLowerCase();
      if (val.contains('rhym')) return 'समान तुक वाले शब्दों की जोड़ी मिलाएँ!';
      if (val.contains('opposite')) return 'विपरीत शब्दों की जोड़ी मिलाएँ!';
      if (val.contains('learning') || val.contains('fun')) return 'मज़ेदार जोड़ियाँ मिलाएँ!';
      return 'जोड़ी मिलाएँ!';
    }

    final matchEachMatch = RegExp(r'^Match each\s*(.+?)(?:!|\s*$)', caseSensitive: false).firstMatch(target);
    if (matchEachMatch != null) {
      final val = matchEachMatch.group(1)!.replaceAll('!', '').trim().toLowerCase();
      if (val.contains('shape')) return 'प्रत्येक आकृति को उसकी वस्तु से मिलाएँ!';
      if (val.contains('color')) return 'प्रत्येक रंग को उसकी रंगीन वस्तु से मिलाएँ!';
      if (val.contains('number') || val.contains('count')) return 'प्रत्येक संख्या को सही गिनती से मिलाएँ!';
      if (val.contains('letter')) return 'प्रत्येक अक्षर को उसके चित्र से मिलाएँ!';
      if (val.contains('animal') || val.contains('sound')) return 'प्रत्येक जानवर को उसकी आवाज़ से मिलाएँ!';
      return 'सही जोड़ी मिलाएँ!';
    }

    // B. Basic Arithmetic (What is A + B?, etc.)
    final addMatch = RegExp(r'^What is\s*(\d+)\s*\+\s*(\d+)\??$', caseSensitive: false).firstMatch(target);
    if (addMatch != null) {
      return '${addMatch.group(1)} + ${addMatch.group(2)} का मान क्या होगा?';
    }

    final subMatch = RegExp(r'^What is\s*(\d+)\s*[\-−]\s*(\d+)\??$', caseSensitive: false).firstMatch(target);
    if (subMatch != null) {
      return '${subMatch.group(1)} - ${subMatch.group(2)} का मान क्या होगा?';
    }

    final mulMatch = RegExp(r'^What is\s*(\d+)\s*[×\*x]\s*(\d+)\??$', caseSensitive: false).firstMatch(target);
    if (mulMatch != null) {
      return '${mulMatch.group(1)} × ${mulMatch.group(2)} का मान क्या होगा?';
    }

    final divMatch = RegExp(r'^What is\s*(\d+)\s*[÷\/]\s*(\d+)\??$', caseSensitive: false).firstMatch(target);
    if (divMatch != null) {
      return '${divMatch.group(1)} ÷ ${divMatch.group(2)} का मान क्या होगा?';
    }

    final sumBondsMatch = RegExp(r'^Find numbers and sums that make\s*(.+)!?$', caseSensitive: false).firstMatch(target);
    if (sumBondsMatch != null) {
      return 'उन संख्याओं और जोड़ को खोजें जिनका योग ${sumBondsMatch.group(1)} बनता है!';
    }

    final countItemsMatch = RegExp(r'^Count the items:\s*(.+?)\.\s*How many are there in total\??$', caseSensitive: false).firstMatch(target);
    if (countItemsMatch != null) {
      final items = countItemsMatch.group(1);
      return 'वस्तुओं को गिनें: $items। कुल कितनी वस्तुएं हैं?';
    }

    final matchPairsMatch = RegExp(r'^Match addition pairs that equal\s*(.+)!?$', caseSensitive: false).firstMatch(target);
    if (matchPairsMatch != null) {
      return 'उन जोड़ियों को मिलाएं जिनका योग ${matchPairsMatch.group(1)} है!';
    }

    // C. Word Problems (Story Math)
    final applesMatch = RegExp(r'Rani has\s*(\d+)\s*apples[^.]*\.\s*Rohit gives her\s*(\d+)\s*more[^.]*\.\s*How many apples does Rani have in all\??', caseSensitive: false).firstMatch(target);
    if (applesMatch != null) {
      return 'रानी के पास ${applesMatch.group(1)} सेब 🍎 हैं। रोहित उसे ${applesMatch.group(2)} और सेब 🍎 देता है। रानी के पास कुल कितने सेब हैं?';
    }

    final birdsMatch = RegExp(r'There were\s*(\d+)\s*birds[^.]*on a branch\.\s*(\d+)\s*birds flew away\.\s*How many birds are left\??', caseSensitive: false).firstMatch(target);
    if (birdsMatch != null) {
      return 'पेड़ की शाखा पर ${birdsMatch.group(1)} पक्षी 🐦 बैठे थे। उनमें से ${birdsMatch.group(2)} पक्षी उड़ गए। अब कितने पक्षी बचे हैं?';
    }

    final tensOnesFormed = RegExp(r'What number is formed by\s*(\d+)\s*Tens and\s*(\d+)\s*Ones\??', caseSensitive: false).firstMatch(target);
    if (tensOnesFormed != null) {
      return '${tensOnesFormed.group(1)} दहाई (Tens) और ${tensOnesFormed.group(2)} इकाई (Ones) से कौन सी संख्या बनेगी?';
    }

    final howManyTens = RegExp(r'In the number\s*(\d+),\s*how many TENS are there\??', caseSensitive: false).firstMatch(target);
    if (howManyTens != null) {
      return 'संख्या ${howManyTens.group(1)} में कितनी दहाई (TENS) हैं?';
    }

    final howManyOnes = RegExp(r'In the number\s*(\d+),\s*how many ONES are there\??', caseSensitive: false).firstMatch(target);
    if (howManyOnes != null) {
      return 'संख्या ${howManyOnes.group(1)} में कितनी इकाई (ONES) हैं?';
    }

    final placeValMatch = RegExp(r'In the number\s*(\d+),\s*what is the place value of\s*(\d+)\??', caseSensitive: false).firstMatch(target);
    if (placeValMatch != null) {
      return 'संख्या ${placeValMatch.group(1)} में अंक ${placeValMatch.group(2)} का स्थानीय मान क्या है?';
    }

    final faceValMatch = RegExp(r'In the number\s*(\d+),\s*what is the face value of\s*(\d+)\??', caseSensitive: false).firstMatch(target);
    if (faceValMatch != null) {
      return 'संख्या ${faceValMatch.group(1)} में अंक ${faceValMatch.group(2)} का अंकित मान (Face Value) क्या है?';
    }

    // D. Cauldron / Fractions & Measurements
    final cauldronFracMatch = RegExp(r'Drag (all )?fractions (equal|equivalent) to\s*(.+?)\s*into the (Golden )?Cauldron!?$', caseSensitive: false).firstMatch(target);
    if (cauldronFracMatch != null) {
      final val = cauldronFracMatch.group(3)!.trim();
      return '$val के बराबर सभी भिन्नों को कड़ाही (Cauldron) में खींचें!';
    }

    final cauldronTurnMatch = RegExp(r'Drag equivalent\s*(.+?)\s*turns into the Cauldron!?$', caseSensitive: false).firstMatch(target);
    if (cauldronTurnMatch != null) {
      final val = cauldronTurnMatch.group(1)!.trim();
      return '$val घुमाव के समतुल्य आकारों को कड़ाही में खींचें!';
    }

    final fenceMatch = RegExp(r'A field has length\s*(.+)\s*and width\s*(.+)\.\s*What length of fence wire is needed to go around it\??', caseSensitive: false).firstMatch(target);
    if (fenceMatch != null) {
      return 'एक मैदान की लंबाई ${fenceMatch.group(1)} और चौड़ाई ${fenceMatch.group(2)} है। इसके चारों ओर बाड़ लगाने के लिए कितने तार की आवश्यकता होगी?';
    }

    final gardenMatch = RegExp(r'A rectangular garden has length\s*(.+?)\s*and width\s*(.+?)\.\s*What is its perimeter\??', caseSensitive: false).firstMatch(target);
    if (gardenMatch != null) {
      return 'एक आयताकार बगीचे की लंबाई ${gardenMatch.group(1)} और चौड़ाई ${gardenMatch.group(2)} है। इसका परिमाप क्या है?';
    }

    final squarePlaygroundMatch = RegExp(r'A square playground has each side measuring\s*(.+?)\.\s*What is the total perimeter.*?\??', caseSensitive: false).firstMatch(target);
    if (squarePlaygroundMatch != null) {
      return 'एक वर्गाकार खेल मैदान की प्रत्येक भुजा ${squarePlaygroundMatch.group(1)} है। मैदान का कुल परिमाप क्या होगा?';
    }

    final farmBoundaryMatch = RegExp(r'A rectangular farm has a boundary of\s*(.+?)\.\s*At ₹(\d+) per meter, what is the cost of fencing.*?\??', caseSensitive: false).firstMatch(target);
    if (farmBoundaryMatch != null) {
      return 'एक आयताकार खेत की सीमा ${farmBoundaryMatch.group(1)} है। ₹${farmBoundaryMatch.group(2)} प्रति मीटर की दर से बाड़ लगाने का कुल खर्च क्या होगा?';
    }

    final triangleParkMatch = RegExp(r'A triangular park has sides of length\s*(.+?),\s*(.+?),\s*and\s*(.+?)\.\s*What length of wire.*?\??', caseSensitive: false).firstMatch(target);
    if (triangleParkMatch != null) {
      return 'एक त्रिभुजाकार पार्क की भुजाएँ ${triangleParkMatch.group(1)}, ${triangleParkMatch.group(2)} और ${triangleParkMatch.group(3)} हैं। इसके चारों ओर एक बार तार लगाने के लिए कितने तार की आवश्यकता होगी?';
    }

    final roundsMatch = RegExp(r'Rahmat walks around a rectangular field of length\s*(.+?)\s*and width\s*(.+?)\.\s*How far does he walk in\s*(\d+)\s*complete rounds\??', caseSensitive: false).firstMatch(target);
    if (roundsMatch != null) {
      return 'रहमत ${roundsMatch.group(1)} लंबी और ${roundsMatch.group(2)} चौड़ी आयताकार मैदान के चारों ओर चलता है। ${roundsMatch.group(3)} पूरे चक्कर लगाने पर वह कुल कितनी दूरी तय करेगा?';
    }

    final minutesMatch = RegExp(r'How many minutes are (there )?in\s*(.+)\??$', caseSensitive: false).firstMatch(target);
    if (minutesMatch != null) {
      return '${minutesMatch.group(2)} में कुल कितने मिनट होते हैं?';
    }

    final convertHoursMatch = RegExp(r'Convert\s*(\d+)\s*hours\s*(and\s*(\d+)\s*minutes\s*)?into minutes\.?', caseSensitive: false).firstMatch(target);
    if (convertHoursMatch != null) {
      final h = convertHoursMatch.group(1);
      final m = convertHoursMatch.group(3);
      if (m != null && m.isNotEmpty) {
        return '$h घंटे और $m मिनट को मिनटों में बदलें।';
      }
      return '$h घंटे को मिनटों में बदलें।';
    }

    final railwayClockMatch = RegExp(r'What is\s*(.+?)\s*in 24-hour railway clock time\??', caseSensitive: false).firstMatch(target);
    if (railwayClockMatch != null) {
      return '24-घंटे वाली रेलवे घड़ी में ${railwayClockMatch.group(1)} का समय क्या होगा?';
    }

    final minuteHandMatch = RegExp(r'How many minutes have passed when the minute hand moves on a clock face from digit\s*(\d+)\s*to digit\s*(\d+)\??', caseSensitive: false).firstMatch(target);
    if (minuteHandMatch != null) {
      return 'घड़ी की सुई के अंक ${minuteHandMatch.group(1)} से अंक ${minuteHandMatch.group(2)} पर जाने में कितने मिनट बीतते हैं?';
    }

    final sportsDayMatch = RegExp(r'A school sports day starts at\s*(.+?)\s*and lasts for\s*(\d+)\s*hours\.\s*At what time does it finish\??', caseSensitive: false).firstMatch(target);
    if (sportsDayMatch != null) {
      return 'स्कूल का खेल दिवस ${sportsDayMatch.group(1)} शुरू होता है और ${sportsDayMatch.group(2)} घंटे चलता है। यह किस समय समाप्त होगा?';
    }

    final juiceMatch = RegExp(r'A bottle has\s*(.+)\s*of juice\.\s*How much more juice is needed to make exactly\s*(.+)\??', caseSensitive: false).firstMatch(target);
    if (juiceMatch != null) {
      return 'एक बोतल में ${juiceMatch.group(1)} जूस है। पूरा ${juiceMatch.group(2)} बनाने के लिए और कितने जूस की आवश्यकता है?';
    }

    final bucketMatch = RegExp(r'A bucket contains\s*(.+?)\s*L and\s*(.+?)\s*mL of water\.\s*How many milliliters is that in total\??', caseSensitive: false).firstMatch(target);
    if (bucketMatch != null) {
      return 'एक बाल्टी में ${bucketMatch.group(1)} लीटर और ${bucketMatch.group(2)} मिलीलीटर पानी है। कुल मिलाकर यह कितने मिलीलीटर हुआ?';
    }

    final glassesMatch = RegExp(r'How many\s*(.+?)\s*mL glasses of orange juice are needed to fill a 1-liter jug completely\??', caseSensitive: false).firstMatch(target);
    if (glassesMatch != null) {
      return '1-लीटर जग को पूरा भरने के लिए ${glassesMatch.group(1)} मिलीलीटर के कितने गिलास संतरे के रस की आवश्यकता होगी?';
    }

    final thermosMatch = RegExp(r'A full 1-liter thermos bottle has\s*(.+?)\s*mL of milk left.*?\.\s*How many milliliters were consumed\??', caseSensitive: false).firstMatch(target);
    if (thermosMatch != null) {
      return '1-लीटर की भरी बोतल में से नाश्ते के बाद ${thermosMatch.group(1)} मिलीलीटर दूध बचा है। कुल कितना मिलीलीटर दूध पिया गया?';
    }

    final packingMatch = RegExp(r'(\d+)\s*pencils are packed equally into\s*(\d+)\s*boxes\.\s*How many pencils are in each box\??', caseSensitive: false).firstMatch(target);
    if (packingMatch != null) {
      return '${packingMatch.group(1)} पेंसिलों को ${packingMatch.group(2)} डिब्बों में बराबर बांटा गया है। प्रत्येक डिब्बे में कितनी पेंसिलें हैं?';
    }

    final chocolatesMatch = RegExp(r'A teacher has\s*(\d+)\s*chocolates and distributes them equally among\s*(\d+)\s*students\.\s*How many chocolates does each student get\??', caseSensitive: false).firstMatch(target);
    if (chocolatesMatch != null) {
      return 'एक शिक्षक के पास ${chocolatesMatch.group(1)} चॉकलेट हैं और वे उन्हें ${chocolatesMatch.group(2)} छात्रों में बराबर बांटते हैं। प्रत्येक छात्र को कितनी चॉकलेट मिलेंगी?';
    }

    final booksShelvesMatch = RegExp(r'A librarian has\s*(\d+)\s*books to be arranged equally on\s*(\d+)\s*wooden shelves\.\s*How many books will be placed on each shelf\??', caseSensitive: false).firstMatch(target);
    if (booksShelvesMatch != null) {
      return 'एक पुस्तकालय में ${booksShelvesMatch.group(1)} किताबें ${booksShelvesMatch.group(2)} अलमारियों में बराबर रखी जानी हैं। प्रत्येक अलमारी में कितनी किताबें होंगी?';
    }

    final frogMatch = RegExp(r'A frog starts at 0 and leaps\s*(\d+)\s*steps in every jump\.\s*How many jumps are needed to land exactly on step\s*(\d+)\??', caseSensitive: false).firstMatch(target);
    if (frogMatch != null) {
      return 'एक मेंढक 0 से शुरू करके हर छलांग में ${frogMatch.group(1)} कदम कूदता है। कदम संख्या ${frogMatch.group(2)} पर पहुँचने के लिए उसे कुल कितनी छलांगें लगानी होंगी?';
    }

    final billMatch = RegExp(r'Four friends share a restaurant food bill of ₹(\d+) equally\.\s*How much does each friend have to contribute\??', caseSensitive: false).firstMatch(target);
    if (billMatch != null) {
      return 'चार दोस्त ₹${billMatch.group(1)} का रेस्टोरेंट बिल आपस में बराबर बांटते हैं। प्रत्येक दोस्त को कितने रुपये देने होंगे?';
    }

    final saplingsMatch = RegExp(r'A gardener planted\s*(\d+)\s*saplings in\s*(\d+)\s*equal rows\.\s*How many saplings are there in each row\??', caseSensitive: false).firstMatch(target);
    if (saplingsMatch != null) {
      return 'एक माली ने ${saplingsMatch.group(1)} पौधे ${saplingsMatch.group(2)} बराबर पंक्तियों में लगाए। प्रत्येक पंक्ति में कितने पौधे हैं?';
    }

    // E. Algebra, Equations & Math Operations
    final productCalcMatch = RegExp(r'^Calculate the product:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (productCalcMatch != null) {
      return 'गुणनफल ज्ञात कीजिए: ${productCalcMatch.group(1)}';
    }

    final integerSubMatch = RegExp(r'^Solve the integer subtraction:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (integerSubMatch != null) {
      return 'पूर्णांक घटाव हल कीजिए: ${integerSubMatch.group(1)}';
    }

    final exponentsMatch = RegExp(r'^Simplify using laws of exponents:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (exponentsMatch != null) {
      return 'घातांक के नियमों का प्रयोग करके सरल कीजिए: ${exponentsMatch.group(1)}';
    }

    final sqrtMatch = RegExp(r'^What is the square root of\s*(.+?)\s*(\(√\d+\))?\??$', caseSensitive: false).firstMatch(target);
    if (sqrtMatch != null) {
      return '${sqrtMatch.group(1)} का वर्गमूल (Square Root) क्या है?';
    }

    final evalExprMatch = RegExp(r'^Evaluate the value of the expression\s*(.+?):?$', caseSensitive: false).firstMatch(target);
    if (evalExprMatch != null) {
      return 'व्यंजक ${evalExprMatch.group(1)} का मान ज्ञात कीजिए:';
    }

    final cubeVolMatch = RegExp(r'^Find the volume of a cube having an edge length of\s*(.+?):?$', caseSensitive: false).firstMatch(target);
    if (cubeVolMatch != null) {
      return 'भुजा ${cubeVolMatch.group(1)} वाले घन का आयतन ज्ञात कीजिए:';
    }

    final cubeTsaMatch = RegExp(r'^What is the Total Surface Area \(TSA\) of a cube with side\s*(.+?)\??$', caseSensitive: false).firstMatch(target);
    if (cubeTsaMatch != null) {
      return 'भुजा ${cubeTsaMatch.group(1)} वाले घन का कुल पृष्ठीय क्षेत्रफल (TSA) क्या है?';
    }

    final cylVolMatch = RegExp(r'^Find the volume of a right circular cylinder with radius\s*(.+?)\s*and height\s*(.+?)(?:\s*\(use π = 22/7\))?:?$', caseSensitive: false).firstMatch(target);
    if (cylVolMatch != null) {
      return 'त्रिज्या ${cylVolMatch.group(1)} और ऊँचाई ${cylVolMatch.group(2)} वाले लम्ब वृत्तीय बेलन का आयतन ज्ञात कीजिए:';
    }

    final solveForXMatch = RegExp(r'^Solve for x:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (solveForXMatch != null) {
      return 'x का मान ज्ञात कीजिए: ${solveForXMatch.group(1)}';
    }

    final solveMatch = RegExp(r'^Solve:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (solveMatch != null) {
      return 'हल कीजिए: ${solveMatch.group(1)}';
    }

    final calcMatch = RegExp(r'^Calculate:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (calcMatch != null) {
      return 'गणना कीजिए: ${calcMatch.group(1)}';
    }

    final simplifyMatch = RegExp(r'^Simplify:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (simplifyMatch != null) {
      return 'सरल कीजिए: ${simplifyMatch.group(1)}';
    }

    final valMatch = RegExp(r'^Find the value of\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (valMatch != null) {
      return 'मान ज्ञात कीजिए: ${valMatch.group(1)}';
    }

    final sumMatch = RegExp(r'^What is the sum of\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (sumMatch != null) {
      return 'योगफल क्या है: ${sumMatch.group(1)}';
    }

    final whatIsMathExpr = RegExp(r'^What is\s*(\d+[\s\+\-\*\/×÷]+\d+(?:[\s\+\-\*\/×÷]+\d+)*)\??$', caseSensitive: false).firstMatch(target);
    if (whatIsMathExpr != null) {
      return '${whatIsMathExpr.group(1)} का मान क्या होगा?';
    }

    final fracMatch = RegExp(r'^Which fraction is equivalent to\s*(.+)\??$', caseSensitive: false).firstMatch(target);
    if (fracMatch != null) {
      return 'कौन सा भिन्न ${fracMatch.group(1)} के समतुल्य है?';
    }

    // F. Grammar & English
    final nounIdentify = RegExp(r'Identify the noun in the sentence:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (nounIdentify != null) {
      return 'इस वाक्य में संज्ञा (Noun) पहचानें: ${nounIdentify.group(1)}';
    }

    final verbIdentify = RegExp(r'Identify the verb in the sentence:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (verbIdentify != null) {
      return 'इस वाक्य में क्रिया (Verb) पहचानें: ${verbIdentify.group(1)}';
    }

    final adjIdentify = RegExp(r'Identify the adjective in the sentence:\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (adjIdentify != null) {
      return 'इस वाक्य में विशेषण (Adjective) पहचानें: ${adjIdentify.group(1)}';
    }

    final antonymMatch = RegExp(r'Which word is an antonym of\s*["\u201c]?(.+?)["\u201d]?\??$', caseSensitive: false).firstMatch(target);
    if (antonymMatch != null) {
      return '"${antonymMatch.group(1)}" का विलोम शब्द (Antonym) कौन सा है?';
    }

    final synonymMatch = RegExp(r'Which word is a synonym of\s*["\u201c]?(.+?)["\u201d]?\??$', caseSensitive: false).firstMatch(target);
    if (synonymMatch != null) {
      return '"${synonymMatch.group(1)}" का समानार्थी शब्द (Synonym) कौन सा है?';
    }

    final pluralMatch = RegExp(r'What is the plural of\s*["\u201c]?(.+?)["\u201d]?\??$', caseSensitive: false).firstMatch(target);
    if (pluralMatch != null) {
      return '"${pluralMatch.group(1)}" का बहुवचन (Plural) रूप क्या होगा?';
    }

    final rhymingMatch = RegExp(r'Which rhyming word matches with\s*["\u201c]?(.+?)["\u201d]?\??$', caseSensitive: false).firstMatch(target);
    if (rhymingMatch != null) {
      return '"${rhymingMatch.group(1)}" से कौन सा तुकबंदी वाला (Rhyming) शब्द मिलता है?';
    }

    final soundMatch = RegExp(r'Which letter makes the sound\s*["\u201c]?\/?(.+?)\/?["\u201d]?\??$', caseSensitive: false).firstMatch(target);
    if (soundMatch != null) {
      return '/${soundMatch.group(1)}/ ध्वनि किस अक्षर से निकलती है?';
    }

    final startsWithMatch = RegExp(r'Which word starts with the letter\s*(.+?)\??$', caseSensitive: false).firstMatch(target);
    if (startsWithMatch != null) {
      return 'कौन सा शब्द अक्षर ${startsWithMatch.group(1)} से शुरू होता है?';
    }

    final grammarMatch = RegExp(r'Which word is (a|an)?\s*(NOUN|VERB|ADJECTIVE|ADVERB|PRONOUN|PREPOSITION) in this sentence:?\s*(.+)$', caseSensitive: false).firstMatch(target);
    if (grammarMatch != null) {
      return 'इस वाक्य में कौन सा शब्द ${grammarMatch.group(2)} है: ${grammarMatch.group(3)}';
    }

    final oppositeWordMatch = RegExp(r'Which word is the OPPOSITE \(antonym\) of\s*(.+)\??$', caseSensitive: false).firstMatch(target);
    if (oppositeWordMatch != null) {
      return '${oppositeWordMatch.group(1)} का विलोम शब्द (Opposite) कौन सा है?';
    }

    final synonymWordMatch = RegExp(r'Which word means the same as\s*(.+)\??$', caseSensitive: false).firstMatch(target);
    if (synonymWordMatch != null) {
      return '${synonymWordMatch.group(1)} का समान अर्थ वाला (Synonym) शब्द कौन सा है?';
    }

    // 3. Keyword / Structural Replacements for Any General Question
    var translated = target;
    translated = translated.replaceAll('What is the place value of', 'स्थानीय मान क्या है:');
    translated = translated.replaceAll('What is the face value of', 'अंकित मान क्या है:');
    translated = translated.replaceAll('Which of these items', 'इनमें से कौन सी वस्तु');
    translated = translated.replaceAll('Which of these objects', 'इनमें से कौन सी वस्तु');
    translated = translated.replaceAll('Which of these', 'इनमें से कौन सा');
    translated = translated.replaceAll('Which object', 'कौन सी वस्तु');
    translated = translated.replaceAll('Which number', 'कौन सी संख्या');
    translated = translated.replaceAll('Which shape', 'कौन सी आकृति');
    translated = translated.replaceAll('Find the perimeter of', 'परिमाप ज्ञात कीजिए:');
    translated = translated.replaceAll('Find the area of', 'क्षेत्रफल ज्ञात कीजिए:');
    translated = translated.replaceAll('What is the sum of', 'योगफल क्या है:');
    translated = translated.replaceAll('What is the value of', 'मान क्या है:');
    translated = translated.replaceAll('How many', 'कितने');
    translated = translated.replaceAll('Calculate', 'गणना कीजिए:');
    translated = translated.replaceAll('Solve', 'हल कीजिए:');
    translated = translated.replaceAll('Simplify', 'सरल कीजिए:');

    return translated;
  }

  // ==========================================
  // 2. OPTION / CHOICE TRANSLATION
  // ==========================================
  static String translateOption(String option) {
    final trimmed = option.trim();
    final lower = trimmed.toLowerCase();

    final map = <String, String>{
      'inside': 'अंदर (Inside)',
      'outside': 'बाहर (Outside)',
      'rolling': 'लुढ़कना (Rolling)',
      'sliding': 'फिसलना (Sliding)',
      'both roll and slide': 'दोनों (Roll & Slide)',
      'top': 'ऊपर (Top)',
      'bottom': 'नीचे (Bottom)',
      'bigger': 'बड़ा (Bigger)',
      'smaller': 'छोटा (Smaller)',
      'more': 'अधिक (More)',
      'less': 'कम (Less)',
      'true': 'सत्य (True)',
      'false': 'असत्य (False)',
      'yes': 'हाँ (Yes)',
      'no': 'नहीं (No)',
      'circle': 'वृत्त ⚪ (Circle)',
      'square': 'वर्ग 🟩 (Square)',
      'triangle': 'त्रिभुज 🔺 (Triangle)',
      'rectangle': 'आयत 🟧 (Rectangle)',
      'oval': 'अंडाकार 🥚 (Oval)',
      'star': 'तारा ⭐ (Star)',
      'triangle 🔺': 'त्रिभुज 🔺',
      'circle ⚪': 'वृत्त ⚪',
      'square 🟩': 'वर्ग 🟩',
      'rectangle 🟧': 'आयत 🟧',
      'oval 🥚': 'अंडाकार 🥚',
      'star ⭐': 'तारा ⭐',
      'football ⚽': 'फुटबॉल ⚽',
      'eraser 🧱': 'रबर (Eraser) 🧱',
      'notebook 📘': 'कॉपी 📘',
      'wooden box 📦': 'लकड़ी का डिब्बा 📦',
      'flat pencil box 📦': 'पेंसिल बॉक्स 📦',
      'round marble 🔮': 'कंचा (Marble) 🔮',
      'orange 🍊': 'संतरा 🍊',
      'tennis ball 🎾': 'टेनिस बॉल 🎾',
      'watermelon 🍉': 'तरबूज 🍉',
      'cherry 🍒': 'चेरी 🍒',
      'elephant 🐘': 'हाथी 🐘',
      'mouse 🐁': 'चूहा 🐁',
      'banana leaf': 'केले की पत्ती 🍃',
      'mango leaf': 'आम की पत्ती 🍃',
      'rose leaf': 'गुलाब की पत्ती 🌹',
      'even': 'सम (Even)',
      'odd': 'विषम (Odd)',
      'prime': 'अभाज्य (Prime)',
      'composite': 'भाज्य (Composite)',
    };

    if (map.containsKey(lower)) {
      return map[lower]!;
    }

    // Check for math steps options like "Add 4 to both sides (+ 4)"
    final addStepMatch = RegExp(r'^Add\s*(\d+)\s*to both sides.*$', caseSensitive: false).firstMatch(trimmed);
    if (addStepMatch != null) {
      return 'दोनों पक्षों में ${addStepMatch.group(1)} जोड़ें (+ ${addStepMatch.group(1)})';
    }

    final subStepMatch = RegExp(r'^Subtract\s*(\d+)\s*from both sides.*$', caseSensitive: false).firstMatch(trimmed);
    if (subStepMatch != null) {
      return 'दोनों पक्षों से ${subStepMatch.group(1)} घटाएं (- ${subStepMatch.group(1)})';
    }

    final mulStepMatch = RegExp(r'^Multiply both sides by\s*(\d+).*$', caseSensitive: false).firstMatch(trimmed);
    if (mulStepMatch != null) {
      return 'दोनों पक्षों को ${mulStepMatch.group(1)} से गुणा करें';
    }

    final divStepMatch = RegExp(r'^Divide both sides by\s*(\d+).*$', caseSensitive: false).firstMatch(trimmed);
    if (divStepMatch != null) {
      return 'दोनों पक्षों को ${divStepMatch.group(1)} से भाग दें';
    }

    // Unit suffixes like "50 m", "150 minutes", "9 pencils", "250 mL"
    if (trimmed.endsWith(' minutes')) {
      return '${trimmed.replaceAll(' minutes', '')} मिनट';
    }
    if (trimmed.endsWith(' minute')) {
      return '${trimmed.replaceAll(' minute', '')} मिनट';
    }
    if (trimmed.endsWith(' pencils')) {
      return '${trimmed.replaceAll(' pencils', '')} पेंसिलें';
    }
    if (trimmed.endsWith(' pencil')) {
      return '${trimmed.replaceAll(' pencil', '')} पेंसिल';
    }
    if (trimmed.endsWith(' chocolates')) {
      return '${trimmed.replaceAll(' chocolates', '')} चॉकलेट';
    }
    if (trimmed.endsWith(' books')) {
      return '${trimmed.replaceAll(' books', '')} किताबें';
    }
    if (trimmed.endsWith(' saplings')) {
      return '${trimmed.replaceAll(' saplings', '')} पौधे';
    }
    if (trimmed.endsWith(' jumps')) {
      return '${trimmed.replaceAll(' jumps', '')} छलांगें';
    }
    if (trimmed.endsWith(' rounds')) {
      return '${trimmed.replaceAll(' rounds', '')} चक्कर';
    }
    if (trimmed.endsWith(' hours')) {
      return '${trimmed.replaceAll(' hours', '')} घंटे';
    }
    if (trimmed.endsWith(' hour')) {
      return '${trimmed.replaceAll(' hour', '')} घंटा';
    }

    return option;
  }

  // ==========================================
  // 3. CHAPTER TITLE TRANSLATION
  // ==========================================
  static String translateChapterTitle(String title) {
    final lower = title.trim().toLowerCase();

    final map = <String, String>{
      'shapes and space': 'आकृतियाँ और स्थान',
      'shapes & space': 'आकृतियाँ और स्थान',
      'numbers from one to nine': '1 से 9 तक की संख्याएँ',
      'numbers 1 to 9': '1 से 9 तक की संख्याएँ',
      'addition': 'जोड़ (Addition)',
      'subtraction': 'घटाव (Subtraction)',
      'numbers from ten to twenty': '10 से 20 तक की संख्याएँ',
      'numbers 10 to 20': '10 से 20 तक की संख्याएँ',
      'time': 'समय (Time)',
      'measurement': 'मापन (Measurement)',
      'numbers from twenty-one to fifty': '21 से 50 तक की संख्याएँ',
      'numbers 21 to 50': '21 से 50 तक की संख्याएँ',
      'data handling': 'आँकड़ों का प्रबंधन',
      'patterns': 'पैटर्न (Patterns)',
      'numbers 51 to 100': '51 से 100 तक की संख्याएँ',
      'numbers': 'संख्याएँ (Numbers)',
      'money': 'रुपये और पैसे (Money)',
      'how many': 'कितने (How Many)',
      'fractions': 'भिन्न (Fractions)',
      'decimals': 'दशमलव (Decimals)',
      'factors and multiples': 'गुणनखंड और गुणज',
      'integers': 'पूर्णांक (Integers)',
      'algebra': 'बीजगणित (Algebra)',
      'simple equations': 'सरल समीकरण',
      'linear equations': 'एक चर वाले रैखिक समीकरण',
      'rational numbers': 'परिमेय संख्याएँ',
      'exponents and powers': 'घातांक और घात',
      'mensuration': 'क्षेत्रमिति (Mensuration)',
      'comparing quantities': 'राशियों की तुलना',
      'geometry': 'ज्यामिति (Geometry)',
      'lines and angles': 'रेखाएँ और कोण',
      'the triangle and its properties': 'त्रिभुज और उसके गुण',
      'practical geometry': 'प्रायोगिक ज्यामिति',
      'perimeter and area': 'परिमाप और क्षेत्रफल',
      'algebraic expressions': 'बीजीय व्यंजक',
      'visualising solid shapes': 'ठोस आकारों का चित्रण',
      'squares and square roots': 'वर्ग और वर्गमूल',
      'cubes and cube roots': 'घन और घनमूल',
      'letters & sounds': 'अक्षर और ध्वनियां',
      'letters and sounds': 'अक्षर और ध्वनियां',
      'opposites & daily words': 'विलोम शब्द और दैनिक शब्द',
      'opposites and daily words': 'विलोम शब्द और दैनिक शब्द',
      'nouns & naming words': 'संज्ञा और नाम वाले शब्द',
      'pronouns': 'सर्वनाम (Pronouns)',
      'verbs & action words': 'क्रिया और कार्य शब्द',
      'adjectives & describing words': 'विशेषण (Adjectives)',
      'prepositions & position words': 'संबंधबोधक (Prepositions)',
      'tenses': 'काल (Tenses)',
      'vocabulary builder': 'शब्दावली विकास',
    };

    for (final entry in map.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    return title;
  }

  // ==========================================
  // 4. CHAPTER DESCRIPTION TRANSLATION
  // ==========================================
  static String translateChapterDescription(String desc, String chapterTitle) {
    if (desc.isEmpty) return desc;
    final lowerTitle = chapterTitle.toLowerCase();

    if (lowerTitle.contains('shapes') || lowerTitle.contains('space') || lowerTitle.contains('rolling') || lowerTitle.contains('sliding')) {
      return 'स्थानिक समझ, आकृतियों (गोल, चौकोर) और लुढ़कने व फिसलने की अवधारणा। सपाट सतह (Flat surfaces) फिसलती हैं, जबकि गोल सतह (Curved surfaces) लुढ़कती हैं।';
    } else if (lowerTitle.contains('addition') || lowerTitle.contains('sum')) {
      return 'संख्याओं को एक साथ जोड़ना और कुल योग निकालना सीखें।';
    } else if (lowerTitle.contains('subtraction')) {
      return 'संख्याओं को घटाना और शेष राशि ज्ञात करना सीखें।';
    } else if (lowerTitle.contains('number') || lowerTitle.contains('counting')) {
      return 'संख्याओं की पहचान, सही गिनती और बढ़ते-घटते क्रम का अभ्यास करें।';
    } else if (lowerTitle.contains('linear') || lowerTitle.contains('equation')) {
      return 'अज्ञात चर (x) का मान निकालने के लिए समीकरणों को चरणबद्ध तरीके से हल करें।';
    } else if (lowerTitle.contains('fraction')) {
      return 'अंश, हर और समतुल्य भिन्नों की सरल व दृश्य अवधारणा को समझें।';
    } else if (lowerTitle.contains('decimal')) {
      return 'दशमलव संख्याओं का स्थानीय मान, जोड़ और घटाव सीखें।';
    } else if (lowerTitle.contains('pattern')) {
      return 'संख्याओं और आकृतियों के नियमों को पहचानकर अगला पैटर्न पूरा करें।';
    } else if (lowerTitle.contains('time')) {
      return 'घड़ी देखना, घंटे, मिनट और दिन-रात के समय की गणना करना सीखें।';
    } else if (lowerTitle.contains('money')) {
      return 'सिक्कों, नोटों की पहचान और खरीदारी में जोड़-घटाव का अभ्यास करें।';
    } else if (lowerTitle.contains('integers')) {
      return 'धनात्मक और ऋणात्मक संख्याओं के नियम और संख्या रेखा की समझ।';
    } else if (lowerTitle.contains('opposite')) {
      return 'विपरीत अर्थ वाले शब्द (विलोम शब्द) जैसे बड़ा-छोटा, ऊपर-नीचे सीखें।';
    } else if (lowerTitle.contains('letter') || lowerTitle.contains('sound') || lowerTitle.contains('phonics')) {
      return 'अक्षरों की पहचान, उनकी ध्वनियाँ (Phonics) और नए शब्द बनाना सीखें।';
    } else if (lowerTitle.contains('noun')) {
      return 'व्यक्ति, वस्तु, स्थान और जानवरों के नाम (संज्ञा) की पहचान करें।';
    }

    return desc;
  }

  // ==========================================
  // 5. KEY CONCEPTS & RULES TRANSLATION
  // ==========================================
  static String translateConcept(String concept) {
    final lower = concept.trim().toLowerCase();
    final map = <String, String>{
      'inside vs outside': 'अंदर और बाहर की पहचान',
      'rolling vs sliding': 'लुढ़कना और फिसलना',
      'bigger vs smaller': 'बड़ा और छोटा',
      'top vs bottom': 'ऊपर और नीचे',
      'near vs far': 'पास और दूर',
      'counting 1 to 9': '1 से 9 तक की गिनती',
      'counting 1 to 20': '1 से 20 तक की गिनती',
      'combining groups': 'समूहों को जोड़ना',
      'taking away': 'घटाना और अलग करना',
      'comparing numbers': 'संख्याओं की तुलना',
      'identifying shapes': 'आकृतियों की पहचान',
      'skip counting': 'संख्या छोड़ गिनती',
      'place value': 'स्थानीय मान',
      'equivalent fractions': 'समतुल्य भिन्न',
      'numerator and denominator': 'अंश और हर',
      'simplifying fractions': 'भिन्नों का सरलीकरण',
      'solving for x': 'x का मान निकालना',
      'both sides equality': 'दोनों पक्षों की समानता',
      'inverse operations': 'उलटी संक्रियाएं (जोड़ ↔ घटाव)',
      'up vs down': 'ऊपर और नीचे (Up vs Down)',
      'hot vs cold': 'गर्म और ठंडा (Hot vs Cold)',
      'big vs small': 'बड़ा और छोटा (Big vs Small)',
      'day vs night': 'दिन और रात (Day vs Night)',
      'happy vs sad': 'खुश और उदास (Happy vs Sad)',
      'letter tracing': 'अक्षर अनुरेखण',
      'vowels and consonants': 'स्वर और व्यंजन',
    };

    if (map.containsKey(lower)) {
      return map[lower]!;
    }
    return concept;
  }

  static String translateRule(String rule) {
    final lower = rule.trim().toLowerCase();
    if (lower.contains('flat surface') || lower.contains('slide')) {
      return 'सपाट सतह वाली वस्तुएं फिसलती हैं, जबकि गोल वस्तुएं लुढ़कती हैं।';
    }
    if (lower.contains('inside') && lower.contains('contain')) {
      return 'जो वस्तु किसी डिब्बे या थैले के भीतर हो, वह Inside (अंदर) होती है।';
    }
    if (lower.contains('equal sign') || lower.contains('balance')) {
      return 'समीकरण एक तराजू की तरह होता है; जो एक पक्ष में करें, वही दूसरे पक्ष में भी करें।';
    }
    if (lower.contains('opposite')) {
      return 'विलोम शब्द वे शब्द होते हैं जिनका अर्थ एक दूसरे के बिल्कुल विपरीत होता है।';
    }
    if (lower.contains('fraction')) {
      return 'भिन्न किसी पूरी वस्तु का एक समान हिस्सा प्रदर्शित करता है (अंश/हर)।';
    }
    if (lower.contains('addition') || lower.contains('sum')) {
      return 'जोड़ने पर हमेशा कुल संख्या बढ़ती है या उतनी ही रहती है।';
    }
    return rule;
  }

  // ==========================================
  // 6. HINTS & STEP-BY-STEP SOLUTIONS
  // ==========================================
  static String translateHint(String hint) {
    if (hint.isEmpty) return hint;
    var t = hint;

    t = t.replaceAllMapped(RegExp(r'Subtract\s+(\d+)\s+from both sides', caseSensitive: false), (m) => 'दोनों पक्षों से ${m[1]} घटाएं');
    t = t.replaceAllMapped(RegExp(r'Add\s+(\d+)\s+to both sides', caseSensitive: false), (m) => 'दोनों पक्षों में ${m[1]} जोड़ें');
    t = t.replaceAllMapped(RegExp(r'Divide both sides by\s+(\d+)', caseSensitive: false), (m) => 'दोनों पक्षों को ${m[1]} से भाग दें');
    t = t.replaceAllMapped(RegExp(r'Multiply both sides by\s+(\d+)', caseSensitive: false), (m) => 'दोनों पक्षों को ${m[1]} से गुणा करें');
    t = t.replaceAll('Look closely at the object shape', 'वस्तु के आकार को ध्यान से देखें');
    t = t.replaceAll('Flat surfaces slide, rounded surfaces roll', 'सपाट सतह फिसलती है और गोल सतह लुढ़कती है');
    t = t.replaceAll('Count the total items carefully', 'सभी वस्तुओं को ध्यान से गिनें');
    t = t.replaceAll('Think about what is the reverse meaning', 'विपरीत अर्थ वाले शब्द के बारे में सोचें');

    return t;
  }

  static String translateStep(String step) {
    if (step.isEmpty) return step;
    var s = step;

    s = s.replaceAllMapped(RegExp(r'^Step\s*(\d+):', caseSensitive: false), (m) => 'चरण ${m[1]}:');
    s = s.replaceAllMapped(RegExp(r'Subtract\s+(\d+)\s+from both sides', caseSensitive: false), (m) => 'दोनों पक्षों से ${m[1]} घटाएं');
    s = s.replaceAllMapped(RegExp(r'Add\s+(\d+)\s+to both sides', caseSensitive: false), (m) => 'दोनों पक्षों में ${m[1]} जोड़ें');
    s = s.replaceAllMapped(RegExp(r'Divide both sides by\s+(\d+)', caseSensitive: false), (m) => 'दोनों पक्षों को ${m[1]} से भाग दें');
    s = s.replaceAllMapped(RegExp(r'Multiply both sides by\s+(\d+)', caseSensitive: false), (m) => 'दोनों पक्षों को ${m[1]} से गुणा करें');
    s = s.replaceAll('Subtract', 'घटाएं');
    s = s.replaceAll('Add', 'जोड़ें');
    s = s.replaceAll('Divide', 'भाग दें');
    s = s.replaceAll('Multiply', 'गुणा करें');
    s = s.replaceAll('from both sides', 'दोनों पक्षों से');
    s = s.replaceAll('to both sides', 'दोनों पक्षों में');
    s = s.replaceAll('by both sides', 'दोनों पक्षों में');
    s = s.replaceAll('We get', 'हमें प्राप्त होता है');
    s = s.replaceAll('Analyze the problem statement', 'प्रश्न को ध्यान से समझें');
    s = s.replaceAll('Reasoning', 'तार्किक व्याख्या');
    s = s.replaceAll('Therefore, the correct choice is', 'अतः सही विकल्प है:');
    s = s.replaceAll('The correct answer is', 'सही उत्तर है:');
    s = s.replaceAll('Conclusion', 'निष्कर्ष');

    return s;
  }

  static String translateFact(String fact) {
    if (fact.isEmpty) return fact;
    return translateStep(fact);
  }
}
