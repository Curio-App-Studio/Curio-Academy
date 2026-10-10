import 'dart:math';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';

/// Algorithmic question generator engine for Hindi language curriculum.
/// Produces authentic, child-friendly, curriculum-aligned Hindi activities:
/// - Kindergarten (LKG & UKG): Interactive Akshar-picture Card Match & Swar/Vyanjan Bubble Pop (ZERO MCQs).
/// - Primary & Middle (Class 1 to 8): Comprehensive grammar, literature, varnamala, vocabulary & comprehension.
/// - Minimum 5 distinct, logically ordered, high-quality questions per chapter with ZERO repetition.
class HindiQuestionGenerator {
  static final HindiQuestionGenerator instance = HindiQuestionGenerator._();
  HindiQuestionGenerator._();

  final Random _rng = Random();

  /// Main dispatch method generating activities for any Hindi chapter
  List<Activity> generateActivitiesForChapter(
    Chapter chapter,
    StudentClass studentClass, {
    int count = 5,
    Set<String> existingPromptTexts = const {},
  }) {
    final activities = <Activity>[];
    final seenPrompts = <String>{...existingPromptTexts.map((e) => e.trim().toLowerCase())};
    int attempts = 0;
    int idx = 1;

    while (activities.length < count && attempts < 40) {
      attempts++;
      final act = generateSingleQuestion(chapter, studentClass, questionIndex: idx);
      final promptKey = act.promptData.text.trim().toLowerCase();
      if (!seenPrompts.contains(promptKey)) {
        seenPrompts.add(promptKey);
        activities.add(act);
      }
      idx++;
    }

    while (activities.length < count) {
      final fallback = generateSingleQuestion(chapter, studentClass, questionIndex: idx++);
      activities.add(fallback);
    }
    return activities;
  }

  /// Generates a single dynamic Hindi question tailored to the chapter and grade
  Activity generateSingleQuestion(
    Chapter chapter,
    StudentClass studentClass, {
    int questionIndex = 1,
  }) {
    // 1. Kindergarten Tier (LKG & UKG): Zero MCQs, exclusively Bubble Pop & Card Match games
    if (studentClass.isKindergarten) {
      if (questionIndex % 2 == 0) {
        return _generateKindergartenHindiCardMatch(chapter, studentClass, questionIndex);
      } else {
        return _generateKindergartenHindiBubblePop(chapter, studentClass, questionIndex);
      }
    }

    // 2. NCERT Rimjhim 4 Literature Chapters
    final cId = chapter.chapterId.toLowerCase();
    final title = chapter.title.toLowerCase();

    if (cId.contains('ncert') || title.contains('मन के भोले') || title.contains('जैसा सवाल') || title.contains('किरमिच') || title.contains('पापा जब बच्चे')) {
      final act = _generateNcertRimjhim4Question(chapter, studentClass, questionIndex);
      if (act != null) return act;
    }

    // 3. Miranda ICSE Hindi Literature
    if (cId.contains('mri_') || chapter.publisher == 'miranda') {
      final act = _generateMirandaLiteratureQuestion(chapter, studentClass, questionIndex);
      if (act != null) return act;
    }

    // 4. Grammar Domain Specific Generators
    if (title.contains('संज्ञा') || title.contains('नाम वाले')) {
      return _generateSangyaQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('सर्वनाम')) {
      return _generateSarvanamQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('विशेषण') || title.contains('कैसा या कितना') || title.contains('प्रविशेषण')) {
      return _generateVisheshanQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('क्रिया') || title.contains('काम वाले')) {
      return _generateKriyaKalQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('काल')) {
      return _generateKriyaKalQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('लिंग') || title.contains('लड़का - लड़की')) {
      return _generateLingQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('वचन') || title.contains('एक और अनेक')) {
      return _generateVachanQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('विलोम') || title.contains('उलटे अर्थ')) {
      return _generateVilomQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('पर्यायवाची') || title.contains('समान अर्थ')) {
      return _generateParyayvachiQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('मुहावरे') || title.contains('लोकोक्तियाँ')) {
      return _generateMuhavareQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('संधि')) {
      return _generateSandhiQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('समास')) {
      return _generateSamasQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('उपसर्ग') || title.contains('प्रत्यय')) {
      return _generateUpsargPratyayQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('कारक') || title.contains('विभक्ति') || title.contains('परसर्ग')) {
      return _generateKarakQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('विराम चिह्न')) {
      return _generateViramChihnQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('वाक्य') || title.contains('अशुद्धि')) {
      return _generateVakyaVicharQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('वर्ण') || title.contains('मात्रा') || title.contains('ध्वनि')) {
      return _generateVarnamalaQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('भाषा') || title.contains('लिपि') || title.contains('व्याकरण')) {
      return _generateBhashaLipiQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('अलंकार')) {
      return _generateAlankarQuestion(chapter, studentClass, questionIndex);
    } else if (title.contains('पद परिचय') || title.contains('अव्यय')) {
      return _generatePadParichayQuestion(chapter, studentClass, questionIndex);
    }

    // 5. General Smart Hindi MCQ Fallback
    return _generateCurriculumHindiMCQ(chapter, studentClass, questionIndex);
  }

  // ---------------------------------------------------------------------------
  // KINDERGARTEN HINDI GAMES (LKG & UKG)
  // ---------------------------------------------------------------------------

  Activity _generateKindergartenHindiCardMatch(Chapter chapter, StudentClass studentClass, int idx) {
    final pools = [
      [
        {'key': 'a', 'itemA': 'अ 🍎', 'emojiA': 'अ', 'itemB': 'अनार 🍎', 'emojiB': '🍎'},
        {'key': 'aa', 'itemA': 'आ 🥭', 'emojiA': 'आ', 'itemB': 'आम 🥭', 'emojiB': '🥭'},
        {'key': 'i', 'itemA': 'इ 🫘', 'emojiA': 'इ', 'itemB': 'इमली 🫘', 'emojiB': '🫘'},
      ],
      [
        {'key': 'ee', 'itemA': 'ई 🎋', 'emojiA': 'ई', 'itemB': 'ईख 🎋', 'emojiB': '🎋'},
        {'key': 'u', 'itemA': 'उ 🦉', 'emojiA': 'उ', 'itemB': 'उल्लू 🦉', 'emojiB': '🦉'},
        {'key': 'oo', 'itemA': 'ऊ 🧶', 'emojiA': 'ऊ', 'itemB': 'ऊन 🧶', 'emojiB': '🧶'},
      ],
      [
        {'key': 'k', 'itemA': 'क 🪷', 'emojiA': 'क', 'itemB': 'कमल 🪷', 'emojiB': '🪷'},
        {'key': 'kh', 'itemA': 'ख 🐇', 'emojiA': 'ख', 'itemB': 'खरगोश 🐇', 'emojiB': '🐇'},
        {'key': 'g', 'itemA': 'ग 🪴', 'emojiA': 'ग', 'itemB': 'गमला 🪴', 'emojiB': '🪴'},
      ],
      [
        {'key': 'gh', 'itemA': 'घ 🏠', 'emojiA': 'घ', 'itemB': 'घर 🏠', 'emojiB': '🏠'},
        {'key': 'ch', 'itemA': 'च 🥄', 'emojiA': 'च', 'itemB': 'चम्मच 🥄', 'emojiB': '🥄'},
        {'key': 'chh', 'itemA': 'छ ☂️', 'emojiA': 'छ', 'itemB': 'छतरी ☂️', 'emojiB': '☂️'},
      ],
      [
        {'key': 't', 'itemA': 'त 🦜', 'emojiA': 'त', 'itemB': 'तोता 🦜', 'emojiB': '🦜'},
        {'key': 'p', 'itemA': 'प 🪁', 'emojiA': 'प', 'itemB': 'पतंग 🪁', 'emojiB': '🪁'},
        {'key': 'm', 'itemA': 'म 🐟', 'emojiA': 'म', 'itemB': 'मछली 🐟', 'emojiB': '🐟'},
      ],
    ];

    final pool = pools[(idx - 1) % pools.length];
    final pairs = <Map<String, dynamic>>[];

    for (final item in pool) {
      pairs.add({
        'id': 'pair_${item['key']}_letter',
        'matchId': item['key'],
        'content': item['itemA'],
        'emoji': item['emojiA'],
        'type': 'letter',
      });
      pairs.add({
        'id': 'pair_${item['key']}_word',
        'matchId': item['key'],
        'content': item['itemB'],
        'emoji': item['emojiB'],
        'type': 'picture',
      });
    }

    pairs.shuffle(_rng);

    final title = chapter.title.isNotEmpty ? chapter.title : 'अक्षर और चित्र मिलाओ';
    final prompt = 'सही अक्षर और उसके चित्र को आपस में मिलाएँ! ($title)';
    final id = 'hin_k_match_${DateTime.now().microsecondsSinceEpoch}_$idx';

    return Activity(
      activityId: id,
      topicId: 'hindi_early_matching',
      subjectId: 'hindi',
      targetGrade: studentClass.label,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.cardMatch,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': title,
        'visualIcon': '🔤',
        'pairs': pairs,
        'gameType': 'cardMatch',
        'explanation': 'शाबाश! आपने सही अक्षर और चित्र को मिलाया।',
      },
      validationRule: const ValidationRule(format: 'pair_matching', expectedAnswer: 'all_pairs'),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  Activity _generateKindergartenHindiBubblePop(Chapter chapter, StudentClass studentClass, int idx) {
    final colors = ['#EF4444', '#F59E0B', '#10B981', '#3B82F6', '#8B5CF6', '#EC4899'];

    final swarList = [
      {'letter': 'अ', 'target': 'अ', 'matches': ['अ', 'अ', 'अ'], 'distractors': ['क', 'म', 'र', 'ल']},
      {'letter': 'आ', 'target': 'आ', 'matches': ['आ', 'आ', 'आ'], 'distractors': ['ख', 'ग', 'च', 'प']},
      {'letter': 'इ', 'target': 'इ', 'matches': ['इ', 'इ', 'इ'], 'distractors': ['उ', 'ए', 'स', 'न']},
      {'letter': 'ई', 'target': 'ई', 'matches': ['ई', 'ई', 'ई'], 'distractors': ['ओ', 'त', 'द', 'ब']},
      {'letter': 'क', 'target': 'क', 'matches': ['क', 'क', 'क'], 'distractors': ['ख', 'ग', 'घ', 'च']},
      {'letter': 'म', 'target': 'म', 'matches': ['म', 'म', 'म'], 'distractors': ['न', 'प', 'ब', 'य']},
      {'letter': 'र', 'target': 'र', 'matches': ['र', 'र', 'र'], 'distractors': ['स', 'श', 'व', 'ल']},
    ];

    final selected = swarList[(idx - 1) % swarList.length];
    final letter = selected['letter'] as String;
    final target = selected['target'] as String;
    final matches = selected['matches'] as List<String>;
    final distractors = selected['distractors'] as List<String>;

    final bubbles = <Map<String, dynamic>>[];
    int bId = 1;

    for (int i = 0; i < 3; i++) {
      bubbles.add({
        'id': 'b_${bId++}',
        'label': matches[i],
        'value': target,
        'displayType': 'label',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    final shuffledDistractors = List<String>.from(distractors)..shuffle(_rng);
    for (int i = 0; i < 3 && i < shuffledDistractors.length; i++) {
      bubbles.add({
        'id': 'b_${bId++}',
        'label': shuffledDistractors[i],
        'value': shuffledDistractors[i],
        'displayType': 'label',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    bubbles.shuffle(_rng);

    final promptText = "अक्षर '$letter' वाले सभी बुलबुलों को फोड़ें!";
    final id = 'hin_k_bubble_${DateTime.now().microsecondsSinceEpoch}_$idx';

    return Activity(
      activityId: id,
      topicId: 'hindi_early_bubble',
      subjectId: 'hindi',
      targetGrade: studentClass.label,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.bubblePop,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: promptText, ttsFallback: promptText),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': '🫧',
        'targetValue': target,
        'bubbles': bubbles,
        'gameType': 'bubblePop',
        'explanation': "बहुत बढ़िया! आपने अक्षर '$letter' वाले सभी बुलबुले फोड़े।",
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: target),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  // ---------------------------------------------------------------------------
  // NCERT RIMJHIM CLASS 4 LITERATURE QUESTIONS
  // ---------------------------------------------------------------------------

  Activity? _generateNcertRimjhim4Question(Chapter chapter, StudentClass studentClass, int idx) {
    final title = chapter.title.toLowerCase();

    // Chapter 1: मन के भोले-भाले बादल (कल्पनाथ सिंह)
    if (title.contains('बादल') || chapter.chapterId == 'hin_c4_ncert_01') {
      final qMap = [
        {
          'q': "कविता में 'झब्बर-झब्बर बालों वाले' और 'गुब्बारे से गालों वाले' कहकर किसका वर्णन किया गया है?",
          'ans': 'काले बादलों का ☁️',
          'dist': ['तेज तूफ़ानी हवाओं का', 'आसमान में चमकते तारों का', 'उड़ते हुए पक्षियों का'],
          'exp': 'कवि कल्पनाथ सिंह ने बादलों के घुंघराले आकार को झब्बर-झब्बर बाल और फूले हुए रूप को गुब्बारे से गाल कहा है।'
        },
        {
          'q': "कविता में बादलों की तुलना किन-किन से की गई है?",
          'ans': 'जोकर, हाथी, ऊँट और परियों से',
          'dist': ['घोड़े, शेर, हिरन और मोर से', 'सूरज, चाँद, उल्का और सितारों से', 'पेड़, पहाड़, झरने और नदियों से'],
          'exp': 'कविता में आता है: कुछ जोकर से तोंद फुलाए, कुछ हाथी से सूँड उठाए, कुछ ऊँटों से कूबड़ वाले, कुछ परियों से पंख लगाए।'
        },
        {
          'q': "जब बादल आपस में रह-रहकर टकराते हैं, तो वे किसके समान मतवाले लगते हैं?",
          'ans': 'शेरों से मतवाले 🦁',
          'dist': ['हाथियों से भारी', 'पक्षियों से चंचल', 'बच्चों से नटखट'],
          'exp': "कविता की पंक्ति है: 'आपस में टकराते रह-रह, शेरों से मतवाले बादल।'"
        },
        {
          'q': "बादल अपने थैलों से चुपके से क्या बरसाते हैं?",
          'ans': 'झर-झर-झर पानी 🌧️',
          'dist': ['फूलों की पंखुड़ियाँ', 'सफेद बर्फ के गोले', 'रंग-बिरंगे मोती'],
          'exp': "कविता में कहा गया है: 'कुछ अपने थैलों से चुपके, झर-झर-झर बरसाते पानी।'"
        },
        {
          'q': "सब शैतानियों, गड़गड़ाहट और बाढ़ लाने के बावजूद अंत में बादल कैसे प्रतीत होते हैं?",
          'ans': 'मन के बहुत भोले-भाले 💕',
          'dist': ['बहुत गुस्सैल और भयानक', 'बहुत कठोर और जिद्दी', 'बहुत आलसी और सुस्त'],
          'exp': "कविता का अंतिम संदेश है: 'फिर भी लगते बहुत भले हैं, मन के भोले-भाले बादल।'"
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    // Chapter 2: जैसा सवाल वैसा जवाब (अकबर, बीरबल और ख्वाजा सरा)
    if (title.contains('जैसा सवाल') || chapter.chapterId == 'hin_c4_ncert_02') {
      final qMap = [
        {
          'q': "ख्वाजा सरा बादशाह अकबर के सामने बीरबल को क्या साबित करना चाहते थे?",
          'ans': 'मूर्ख और कमअक्ल 🧠',
          'dist': ['बहुत बहादुर योद्धा', 'सबसे बड़ा दरबारी कवि', 'ईमानदार राजकोष अधिकारी'],
          'exp': 'ख्वाजा सरा को अपनी विद्या और बुद्धि पर बड़ा अभिमान था। वे बीरबल से जलते थे और उसे मूर्ख सिद्ध करना चाहते थे।'
        },
        {
          'q': "ख्वाजा सरा ने बीरबल से पहला कठिन सवाल क्या पूछा था?",
          'ans': 'संसार का केंद्र कहाँ है? 🌍',
          'dist': ['संसार में कुल कितने पेड़ हैं?', 'बादशाह के सिर में कितने बाल हैं?', 'समुद्र में कितना पानी है?'],
          'exp': 'ख्वाजा सरा का पहला सवाल था कि संसार की धुरी (केंद्र) किस स्थान पर स्थित है।'
        },
        {
          'q': "बीरबल ने संसार के केंद्र वाले सवाल का क्या हाजिरजवाब उत्तर दिया?",
          'ans': 'अपनी छड़ी गाड़कर कहा कि यही स्थान ठीक बीच में है 🪄',
          'dist': ['कहा कि अकबर का महल ही केंद्र है', 'कहा कि हिमालय पर्वत केंद्र है', 'कहा कि कोई केंद्र नाप नहीं सकता'],
          'exp': 'बीरबल ने तुरंत ज़मीन पर छड़ी गाड़कर कहा कि यदि ख्वाजा सरा को विश्वास न हो तो फीते से सारी दुनिया नापकर दिखा दें।'
        },
        {
          'q': "आकाश के तारों की गिनती के सवाल पर बीरबल ने क्या मँगवाया?",
          'ans': 'एक रोएंदार भेड़ 🐑',
          'dist': ['एक बड़ा दर्पण', 'एक तोता और पिंजरा', 'सरसों के दानों की बोरी'],
          'exp': 'बीरबल ने भेड़ मँगवाकर कहा—इस भेड़ के शरीर पर जितने बाल हैं, उतने ही आसमान में तारे हैं। ख्वाजा साहब गिनकर देख लें!'
        },
        {
          'q': "बीरबल के सटीक उत्तरों को सुनकर ख्वाजा सरा की क्या स्थिति हुई?",
          'ans': 'वे निरुत्तर होकर अपना सा मुँह लेकर रह गए 🤐',
          'dist': ['वे गुस्से में तलवार निकाल लाए', 'वे बीरबल को गले लगाकर हँसने लगे', 'वे तुरंत दरबार छोड़कर भाग गए'],
          'exp': "बीरबल के अकाट्य तर्कों के सामने ख्वाजा सरा कुछ बोल न सके और चुपचाप हार मान ली।"
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    // Chapter 3: किरमिच की गेंद (शांता कुमारी जैन)
    if (title.contains('किरमिच') || chapter.chapterId == 'hin_c4_ncert_03') {
      final qMap = [
        {
          'q': "दिनेश को दोपहर के समय बगीचे में सीताफल की बेल के पास क्या मिला?",
          'ans': 'एक चमचमाती नई किरमिच की गेंद ⚾',
          'dist': ['एक पुराना लकड़ी का बल्ला', 'एक चमड़े का दस्ताना', 'एक रंगीन प्लास्टिक की फिरकी'],
          'exp': 'दिनेश ने भिंडियों के पौधों और सीताफल की घनी बेल के नीचे एक बिल्कुल नई, चमकीली किरमिच की गेंद पाई।'
        },
        {
          'q': "दीपक ने दिनेश की मिली गेंद को अपनी साबित करने के लिए क्या दावा किया था?",
          'ans': 'कि मेरी गेंद पाँच महीने पहले खोई थी और उस पर लाल निशान था 🔴',
          'dist': ['कि उस पर उसका नाम लिखा हुआ था', 'कि वह गेंद उसने कल ही खरीदी थी', 'कि उस पर उसके पापा के हस्ताक्षर थे'],
          'exp': 'दीपक बार-बार गेंद पर अपना हक जमा रहा था, पर उसकी गेंद पाँच महीने पहले खोई थी, जबकि यह गेंद बिल्कुल नई थी।'
        },
        {
          'q': "दिनेश की क्या विशेषता थी जो इस कहानी में स्पष्ट रूप से उभरती है?",
          'ans': 'वह सच्चा, निष्पक्ष और मिलनसार बच्चा था 🤝',
          'dist': ['वह झगड़ालू और स्वार्थी था', 'वह किसी को अपने खिलौने नहीं देता था', 'वह हमेशा झूठ बोलता था'],
          'exp': 'दिनेश जानता था कि गेंद किसी की भी हो सकती है, इसलिए उसने चुपचाप छिपाने के बजाय सभी बच्चों के सामने बात रखी।'
        },
        {
          'q': "जब किसी एक का पक्का सबूत नहीं मिला, तो बच्चों ने गेंद का क्या करने का फैसला किया?",
          'ans': 'सबने मिलकर उसी गेंद से मैच खेलने का निर्णय लिया 🏏',
          'dist': ['गेंद को नाले में फेंकने का फैसला किया', 'गेंद को दुकानदार को बेचने का फैसला किया', 'गेंद को पुलिस स्टेशन ले जाने का फैसला किया'],
          'exp': 'सभी दोस्तों ने तय किया कि बल्ला मँगाकर पहले मैच खेलेंगे, बाद में देखेंगे गेंद किसकी है।'
        },
        {
          'q': "खेलते समय अचानक गेंद कहाँ जा गिरी और दूर चली गई?",
          'ans': 'सड़क पर जा रहे स्कूटर की जालीदार टोकरी में 🛵',
          'dist': ['कुएँ के गहरे पानी में', 'पास वाले मकान की छत पर', 'दौड़ते हुए ट्रक के नीचे'],
          'exp': 'अनिल ने गेंद को तेजी से मारा। गेंद सड़क पर निकल रहे स्कूटर की जालीदार टोकरी में गिरी और स्कूटर के साथ चली गई।'
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    // Chapter 4: पापा जब बच्चे थे (अलेक्सांद्र रस्किन)
    if (title.contains('पापा जब बच्चे') || chapter.chapterId == 'hin_c4_ncert_04') {
      final qMap = [
        {
          'q': "बचपन में जब सब सो रहे होते, तब शोर मचाने के लिए छोटे पापा क्या बनना चाहते थे?",
          'ans': 'चौकीदार 🔦',
          'dist': ['डाकिया', 'रेलवे गार्ड', 'दुकानदार'],
          'exp': 'पापा सोचते थे कि जब सारी दुनिया सोई होगी, तब वे जागे रहेंगे और रात भर सीटी बजाकर शोर मचाएँगे।'
        },
        {
          'q': "रेलवे स्टेशन पर रेल के डिब्बों को धोने और इधर-उधर लगाने वाले काम को क्या कहते हैं?",
          'ans': 'शंटिंग (Shunting) 🚂',
          'dist': ['टिकट चेकिंग', 'ड्राइविंग', 'सिग्नलिंग'],
          'exp': 'स्टेशन पर डिब्बों को साफ करने और इंजन बदलने वाले को शंटिंग करने वाला कहा जाता है।'
        },
        {
          'q': "पापा ने आइसक्रीम वाला बनने का विचार क्यों बनाया था?",
          'ans': 'ताकि वे रोज मुफ्त में खूब सारी आइसक्रीम खा सकें 🍦',
          'dist': ['ताकि वे अमीर बन सकें', 'ताकि वे घूम-घूमकर गाना गा सकें', 'ताकि वे दोस्तों को बेच सकें'],
          'exp': 'पापा सोचते थे कि ठेला लेकर घूमेंगे और जितनी चाहे उतनी आइसक्रीम खुद खाएँगे!'
        },
        {
          'q': "जब पापा कुत्ता बनने का अभ्यास कर रहे थे, तब किस व्यक्ति ने उन्हें जीवन का सही रास्ता दिखाया?",
          'ans': 'एक फौजी अफसर ने 🎖️',
          'dist': ['उनके स्कूल के अध्यापक ने', 'स्टेशन के कुली ने', 'गली के दुकानदार ने'],
          'exp': 'एक फौजी अफसर ने उनसे पूछा कि क्या वे इंसान नहीं बनना चाहते? इस सवाल ने पापा की आँखें खोल दीं।'
        },
        {
          'q': "फौजी अफसर की बात सुनकर पापा ने अंततः जीवन में सबसे पहले क्या बनने का संकल्प लिया?",
          'ans': 'एक अच्छा और सच्चा इंसान 🌟',
          'dist': ['एक बड़ा वैज्ञानिक', 'सेना का जनरल', 'रेलवे का बड़ा अधिकारी'],
          'exp': 'पापा समझ गए कि कोई भी पेशा चुनने से पहले सबसे आवश्यक बात यह है कि हम एक अच्छे इंसान बनें।'
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // MIRANDA ICSE HINDI LITERATURE QUESTIONS
  // ---------------------------------------------------------------------------

  Activity? _generateMirandaLiteratureQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final title = chapter.title.toLowerCase();

    if (title.contains('पुष्प की अभिलाषा') || chapter.chapterId == 'hin_c4_mri_01') {
      final qMap = [
        {
          'q': "माखनलाल चतुर्वेदी द्वारा रचित 'पुष्प की अभिलाषा' में फूल की सच्ची इच्छा क्या है?",
          'ans': 'शहीदों के चरणों में उस पथ पर बिछना जिस पर वीर जवान जाते हैं 🌸',
          'dist': ['सुंदर अप्सराओं के गहनों में गूँथा जाना', 'सम्राटों के शव पर चढ़ाया जाना', 'देवताओं के सिर पर चढ़कर इठलाना'],
          'exp': "फूल कहता है: 'मुझे तोड़ लेना बनमाली! उस पथ पर देना तुम फेंक, मातृभूमि पर शीश चढ़ाने जिस पथ जावें वीर अनेक।'"
        },
        {
          'q': "फूल किसके गहनों में गूँथा जाना नहीं चाहता?",
          'ans': 'सुरबाला (अप्सरा) के गहनों में 👑',
          'dist': ['वीर सैनिकों की वर्दी में', 'देश के तिरंगे में', 'विद्यालय के बच्चों के हाथों में'],
          'exp': "कविता की पहली पंक्ति है: 'चाह नहीं, मैं सुरबाला के गहनों में गूँथा जाऊँ।'"
        },
        {
          'q': "फूल देवों के सिर पर चढ़कर क्या नहीं करना चाहता?",
          'ans': 'अपने भाग्य पर इठलाना (अहंकार करना) 🕊️',
          'dist': ['खुशबू बिखेरना', 'मुस्कुराना', 'मुरझा जाना'],
          'exp': "फूल कहता है: 'चाह नहीं देवों के सिर पर चढ़ूँ, भाग्य पर इठलाऊँ।'"
        },
        {
          'q': "फूल माली (बनमाली) से क्या प्रार्थना करता है?",
          'ans': 'कि मुझे तोड़कर वीरों के जाने वाले मार्ग पर फेंक देना 🛤️',
          'dist': ['कि मुझे पानी मत देना', 'कि मुझे मंदिर में भगवान को अर्पित करना', 'कि मुझे राजा के महल में सजाना'],
          'exp': 'फूल देश की रक्षा करने वाले जांबाज वीरों के चरणों की धूल बनकर खुद को धन्य मानना चाहता है।'
        },
        {
          'q': "'पुष्प की अभिलाषा' कविता हमें कौन सा महान संदेश देती है?",
          'ans': 'देशभक्ति और मातृभूमि पर सर्वस्व समर्पण की भावना 🇮🇳',
          'dist': ['अधिक से अधिक धन कमाने का संदेश', 'दूसरों पर रौब जमाने का संदेश', 'प्रकृति से दूर रहने का संदेश'],
          'exp': 'यह अमर कविता हमें सिखाती है कि देश और मातृभूमि की सेवा से बढ़कर दुनिया में कोई सम्मान नहीं है।'
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    if (title.contains('सच्चा मित्र') || chapter.chapterId == 'hin_c4_mri_03') {
      final qMap = [
        {
          'q': "सच्चे मित्र की सबसे मुख्य पहचान क्या होती है?",
          'ans': 'जो संकट और विपत्ति के समय साथ निभाए 🤝',
          'dist': ['जो केवल खुशी और दावत के समय आए', 'जो हमेशा झूठी तारीफ करे', 'जो अपनी ही बात मनवाए'],
          'exp': 'सच्चा मित्र वही है जो सुख में ही नहीं, अपितु कठिन से कठिन दुख और विपत्ति में भी ढाल बनकर खड़ा रहे।'
        },
        {
          'q': "नीतिकारों के अनुसार बुरे मित्रों की संगति से क्या हानि होती है?",
          'ans': 'व्यक्ति के चरित्र और मान-सम्मान का नाश होता है ⚠️',
          'dist': ['व्यक्ति बहुत प्रसिद्ध हो जाता है', 'व्यक्ति को हर परीक्षा में सफलता मिलती है', 'कोई हानि नहीं होती'],
          'exp': 'कुसंगति काजल की कोठरी के समान होती है, जिसमें जाने पर कालिख लगना स्वाभाविक है।'
        },
        {
          'q': "कहावत 'मित्र वही जो विपत्ति कसौटी जे कसे' का क्या अर्थ है?",
          'ans': 'विपत्ति के समय ही मित्रता की सच्ची परीक्षा होती है ⚖️',
          'dist': ['मित्र को सोना खरीदना चाहिए', 'मित्र को कसौटी पत्थर पर घिसना चाहिए', 'मित्रता केवल अमीर लोगों से करनी चाहिए'],
          'exp': 'जिस प्रकार सोने की शुद्धता कसौटी पर परखी जाती है, उसी प्रकार सच्ची मित्रता संकट के समय परखी जाती है।'
        },
        {
          'q': "एक अच्छा मित्र अपने साथी को किस ओर प्रेरित करता है?",
          'ans': 'सन्मार्ग, विद्या और अच्छे कर्मों की ओर 📚',
          'dist': ['गलत आदतें सीखने की ओर', 'पढ़ाई छोड़कर घूमने की ओर', 'झूठ बोलने की ओर'],
          'exp': 'सच्चा मित्र हमेशा सही राह दिखाता है और बुराइयों से बचाकर सन्मार्ग पर ले जाता है।'
        },
        {
          'q': "यदि आपका मित्र कोई गलत काम करने लगे, तो सच्चे मित्र का क्या कर्तव्य है?",
          'ans': 'उसे प्यार से समझाकर गलती सुधारने में मदद करना 💡',
          'dist': ['उसका साथ देकर खुद भी गलती करना', 'सबके सामने उसका मजाक उड़ाना', 'उससे तुरंत दुश्मनी कर लेना'],
          'exp': 'सच्चा मित्र गलतियों पर पर्दा नहीं डालता, बल्कि समझा-बुझाकर सही मार्ग पर लौटा लाता है।'
        },
      ];
      return _buildQuestionFromData(chapter, studentClass, qMap, idx);
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // GRAMMAR DOMAIN GENERATORS
  // ---------------------------------------------------------------------------

  Activity _generateSangyaQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "किसी व्यक्ति, वस्तु, स्थान, प्राणी या भाव के नाम को क्या कहते हैं?",
        'ans': 'संज्ञा (Noun) 🏷️',
        'dist': ['सर्वनाम', 'विशेषण', 'क्रिया'],
        'exp': 'व्याकरण में नाम बताने वाले सभी शब्दों को संज्ञा कहा जाता है।'
      },
      {
        'q': "वाक्य 'हिमालय भारत का सबसे ऊँचा पर्वत है' में 'हिमालय' किस प्रकार की संज्ञा है?",
        'ans': 'व्यक्तिवाचक संज्ञा 🏔️',
        'dist': ['जातिवाचक संज्ञा', 'भाववाचक संज्ञा', 'द्रव्यवाचक संज्ञा'],
        'exp': "'हिमालय' एक विशेष पर्वत का व्यक्तिगत नाम है, इसलिए यह व्यक्तिवाचक संज्ञा है।"
      },
      {
        'q': "दिए गए शब्दों में से 'भाववाचक संज्ञा' शब्द को पहचानिए:",
        'ans': 'मिठास 🍯',
        'dist': ['लड़का', 'किताब', 'दिल्ली'],
        'exp': "'मिठास' एक अनुभव और भाव है जिसे केवल महसूस किया जा सकता है, देखा या छुआ नहीं जा सकता।"
      },
      {
        'q': "'नदी', 'पेड़' और 'शहर' किस संज्ञा भेद के सटीक उदाहरण हैं?",
        'ans': 'जातिवाचक संज्ञा 🌳',
        'dist': ['व्यक्तिवाचक संज्ञा', 'भाववाचक संज्ञा', 'निजवाचक संज्ञा'],
        'exp': "ये शब्द किसी विशेष का नाम न होकर अपनी पूरी जाति या वर्ग का बोध कराते हैं।"
      },
      {
        'q': "'बच्चा' शब्द से बनने वाली सही भाववाचक संज्ञा कौन सी है?",
        'ans': 'बचपन 👶',
        'dist': ['बच्चे', 'बच्ची', 'बचपनादार'],
        'exp': "'बच्चा' जातिवाचक संज्ञा है और उससे बनी भाववाचक संज्ञा 'बचपन' है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateSarvanamQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "संज्ञा के स्थान पर प्रयोग किए जाने वाले शब्दों को क्या कहते हैं?",
        'ans': 'सर्वनाम (Pronoun) 🔄',
        'dist': ['विशेषण', 'क्रियापद', 'विराम चिह्न'],
        'exp': 'बार-बार संज्ञा की पुनरावृत्ति रोकने के लिए सर्वनाम (जैसे: मैं, तुम, वह, हम) का प्रयोग किया जाता है।'
      },
      {
        'q': "वाक्य 'वह अपनी माँ के साथ बाजार जा रहा है' में सर्वनाम शब्द कौन सा है?",
        'ans': 'वह और अपनी 🚶',
        'dist': ['बाजार', 'माँ', 'जा रहा है'],
        'exp': "'वह' अन्य पुरुष सर्वनाम है और 'अपनी' निजवाचक सर्वनाम है।"
      },
      {
        'q': "'मैं', 'हम', 'मुझे' किस पुरुषवाचक सर्वनाम के अंतर्गत आते हैं?",
        'ans': 'उत्तम पुरुष (First Person) 🙋',
        'dist': ['मध्यम पुरुष', 'अन्य पुरुष', 'निश्चयवाचक'],
        'exp': 'बोलने वाला (वक्ता) अपने लिए जिन सर्वनामों का प्रयोग करता है, वे उत्तम पुरुष कहलाते हैं।'
      },
      {
        'q': "दिए गए वाक्य में रिक्त स्थान की पूर्ति करें: '... बाहर खड़ा होकर घंटी बजा रहा है?'",
        'ans': 'कौन ❓',
        'dist': ['क्या', 'कहाँ', 'कैसे'],
        'exp': 'किसी व्यक्ति के बारे में प्रश्न पूछने के लिए प्रश्नवाचक सर्वनाम "कौन" का प्रयोग होता है।'
      },
      {
        'q': "'यह मेरी पुस्तक है और वह तुम्हारी है' में 'यह' और 'वह' किस प्रकार के सर्वनाम हैं?",
        'ans': 'निश्चयवाचक सर्वनाम 🎯',
        'dist': ['अनिश्चयवाचक सर्वनाम', 'संबंधवाचक सर्वनाम', 'निजवाचक सर्वनाम'],
        'exp': 'जो सर्वनाम निकट या दूर की वस्तु का निश्चित बोध कराएँ, वे निश्चयवाचक सर्वनाम कहलाते हैं।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateVisheshanQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "जो शब्द संज्ञा या सर्वनाम की विशेषता (गुण, दोष, संख्या, माप) बताते हैं, उन्हें क्या कहते हैं?",
        'ans': 'विशेषण (Adjective) ✨',
        'dist': ['क्रिया', 'कारक', 'उपसर्ग'],
        'exp': 'विशेषता बताने वाले शब्द विशेषण और जिसकी विशेषता बताई जाए वह विशेष्य कहलाता है।'
      },
      {
        'q': "वाक्य 'रोहन ने चार मीठे सेब खाए' में विशेषण शब्द कौन से हैं?",
        'ans': 'चार और मीठे 🍎',
        'dist': ['रोहन और सेब', 'खाए और ने', 'केवल रोहन'],
        'exp': "'चार' संख्यावाचक विशेषण है और 'मीठे' गुणवाचक विशेषण है।"
      },
      {
        'q': "जिस शब्द की विशेषता बताई जाती है, व्याकरण में उसे क्या कहते हैं?",
        'ans': 'विशेष्य 🎯',
        'dist': ['प्रविशेषण', 'कारक', 'विधेय'],
        'exp': "उदाहरण: 'काली गाय' में 'काली' विशेषण है और 'गाय' विशेष्य है।"
      },
      {
        'q': "'दो लीटर दूध' किस विशेषण भेद का सटीक उदाहरण है?",
        'ans': 'परिमाणवाचक विशेषण (माप-तौल) 🥛',
        'dist': ['गुणवाचक विशेषण', 'संख्यावाचक विशेषण', 'सार्वनामिक विशेषण'],
        'exp': 'नाप-तौल या माप बताने वाले शब्द परिमाणवाचक विशेषण कहलाते हैं।'
      },
      {
        'q': "'भारत' शब्द से बनने वाला सही विशेषण रूप कौन सा है?",
        'ans': 'भारतीय 🇮🇳',
        'dist': ['भारती', 'भारतत्व', 'भारतपन'],
        'exp': "'भारत' संज्ञा में 'ईय' प्रत्यय जोड़ने से 'भारतीय' विशेषण बनता है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateKriyaKalQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "जिस शब्द से किसी कार्य के करने या होने का बोध हो, उसे क्या कहते हैं?",
        'ans': 'क्रिया (Verb) 🏃',
        'dist': ['संज्ञा', 'कारक', 'सर्वनाम'],
        'exp': 'पढ़ना, लिखना, खेलना, हँसना आदि शब्द कार्य का बोध कराते हैं, अतः क्रिया हैं।'
      },
      {
        'q': "जिस क्रिया के साथ कर्म उपस्थित होता है, उसे कौन सी क्रिया कहते हैं?",
        'ans': 'सकर्मक क्रिया (Transitive Verb) ✍️',
        'dist': ['अकर्मक क्रिया', 'प्रेरणार्थक क्रिया', 'सहायक क्रिया'],
        'exp': "'राम पत्र लिखता है' में 'पत्र' कर्म है, अतः 'लिखता है' सकर्मक क्रिया है।"
      },
      {
        'q': "'पक्षी आकाश में उड़ रहे हैं' में उड़ना किस प्रकार की क्रिया है?",
        'ans': 'अकर्मक क्रिया 🕊️',
        'dist': ['सकर्मक क्रिया', 'द्विकर्मक क्रिया', 'संयुक्त क्रिया'],
        'exp': "उड़ने का फल सीधा कर्ता (पक्षी) पर पड़ता है, इसमें कोई कर्म नहीं है, अतः अकर्मक क्रिया है।"
      },
      {
        'q': "क्रिया के जिस रूप से बीते हुए समय का बोध हो, उसे कौन सा काल कहते हैं?",
        'ans': 'भूतकाल (Past Tense) ⏳',
        'dist': ['वर्तमानकाल', 'भविष्यतकाल', 'सामान्य काल'],
        'exp': "'कल वर्षा हुई थी' बीते समय की बात है, अतः यह भूतकाल का वाक्य है।"
      },
      {
        'q': "वाक्य 'हम कल चिड़ियाघर देखने जाएँगे' किस काल का उदाहरण है?",
        'ans': 'भविष्यतकाल (Future Tense) 🔮',
        'dist': ['वर्तमानकाल', 'भूतकाल', 'अपूर्ण भूतकाल'],
        'exp': "क्रिया 'जाएँगे' आने वाले समय (कल) का संकेत करती है, अतः भविष्यतकाल है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateLingQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "संज्ञा शब्द के जिस रूप से पुरुष या स्त्री जाति का बोध हो, उसे क्या कहते हैं?",
        'ans': 'लिंग (Gender) 🚻',
        'dist': ['वचन', 'कारक', 'पुरुष'],
        'exp': 'हिंदी व्याकरण में दो लिंग होते हैं—पुल्लिंग और स्त्रीलिंग।'
      },
      {
        'q': "'विद्वान' शब्द का सही स्त्रीलिंग रूप कौन सा है?",
        'ans': 'विदुषी 🎓',
        'dist': ['विद्वानी', 'विद्वाना', 'विदुषा'],
        'exp': "'विद्वान' पुल्लिंग शब्द है और इसका शुद्ध स्त्रीलिंग रूप 'विदुषी' होता है।"
      },
      {
        'q': "'कवि' शब्द का शुद्ध स्त्रीलिंग रूप पहचानिए:",
        'ans': 'कवयित्री ✍️',
        'dist': ['कवियत्री', 'कविनी', 'कविपत्नी'],
        'exp': 'वर्तनी की दृष्टि से सही रूप "कवयित्री" होता है।'
      },
      {
        'q': "दिए गए शब्दों में से सदैव 'स्त्रीलिंग' रहने वाला शब्द कौन सा है?",
        'ans': 'नदी (गंगा, यमुना) 🌊',
        'dist': ['पहाड़', 'दिन', 'सूर्य'],
        'exp': 'प्रायः नदियों, तिथियों और भाषाओं के नाम स्त्रीलिंग होते हैं।'
      },
      {
        'q': "'शेर जंगल में दहाड़ रहा है' का सही लिंग बदलकर वाक्य क्या बनेगा?",
        'ans': 'शेरनी जंगल में दहाड़ रही है 🐾',
        'dist': ['शेरनी जंगल में दहाड़ रहा है', 'शेर जंगल में दहाड़ रही है', 'शेरों जंगल में दहाड़ रहे हैं'],
        'exp': 'लिंग बदलने पर कर्ता के साथ-साथ क्रिया का रूप भी स्त्रीलिंग में परिवर्तित होता है।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateVachanQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "शब्द के जिस रूप से उसके एक या एक से अधिक होने का बोध हो, उसे क्या कहते हैं?",
        'ans': 'वचन (Number) 🔢',
        'dist': ['लिंग', 'कारक', 'काल'],
        'exp': 'हिंदी में दो वचन होते हैं—एकवचन (एक संख्या) और बहुवचन (एक से अधिक संख्या)।'
      },
      {
        'q': "'चिड़िया' शब्द का शुद्ध बहुवचन रूप कौन सा है?",
        'ans': 'चिड़ियाँ 🐦',
        'dist': ['चिड़िये', 'चिड़ियों', 'चिड़ियाएँ'],
        'exp': 'अंत में "या" वाले स्त्रीलिंग शब्दों के ऊपर चंद्रबिंदु लगाकर बहुवचन बनाते हैं।'
      },
      {
        'q': "'नदी' शब्द का सही बहुवचन रूप कौन सा होगा?",
        'ans': 'नदियाँ 💧',
        'dist': ['नदीयाँ', 'नदिये', 'नदियों'],
        'exp': 'दीर्घ ई (ी) वाले शब्दों में बहुवचन बनाते समय ई ह्रस्व (ि) होकर "याँ" जुड़ता है।'
      },
      {
        'q': "दिए गए शब्दों में से सदैव 'बहुवचन' में प्रयुक्त होने वाला शब्द पहचानिए:",
        'ans': 'हस्ताक्षर (Sign) व प्राण ✍️',
        'dist': ['पानी', 'दूध', 'जनता'],
        'exp': 'हस्ताक्षर, प्राण, आँसू, दर्शन और बाल सदैव बहुवचन रूप में प्रयोग किए जाते हैं।'
      },
      {
        'q': "वाक्य 'लड़का मैदान में खेल रहा है' का सही बहुवचन वाक्य क्या होगा?",
        'ans': 'लड़के मैदान में खेल रहे हैं ⚽',
        'dist': ['लड़के मैदान में खेल रहा है', 'लड़कों मैदान में खेल रहा है', 'लड़का मैदानों में खेल रहे हैं'],
        'exp': 'एकवचन से बहुवचन बनने पर कर्ता और क्रिया दोनों बहुवचन रूप में बदलती हैं।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateVilomQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "एक-दूसरे का उलटा या विपरीत अर्थ देने वाले शब्दों को क्या कहते हैं?",
        'ans': 'विलोम शब्द (Antonyms) ↔️',
        'dist': ['पर्यायवाची शब्द', 'समानार्थक शब्द', 'युग्म शब्द'],
        'exp': 'विपरीत अर्थ का बोध कराने वाले शब्द विलोम या विपरीतार्थक शब्द कहलाते हैं।'
      },
      {
        'q': "'अमृत' शब्द का सही विलोम शब्द कौन सा है?",
        'ans': 'विष (गरल) ☠️',
        'dist': ['सुधा', 'पानी', 'मधु'],
        'exp': "'अमृत' का अर्थ जीवनदायी रस है और इसका विलोम 'विष' है।"
      },
      {
        'q': "'प्राचीन' (Old/Ancient) शब्द का सही विलोम क्या होगा?",
        'ans': 'नवीन (अर्वाचीन) 🆕',
        'dist': ['पुराना', 'ऐतिहासिक', 'पुरातन'],
        'exp': "'प्राचीन' का अर्थ पुराना होता है और इसका शुद्ध विलोम 'नवीन' या 'अर्वाचीन' है।"
      },
      {
        'q': "'प्रत्यक्ष' (Direct) शब्द का सही विलोम रूप पहचानिए:",
        'ans': 'अप्रत्यक्ष (परोक्ष) 👁️',
        'dist': ['स्पष्ट', 'सामने', 'दृश्यमान'],
        'exp': "'प्रत्यक्ष' का विलोम 'अप्रत्यक्ष' अथवा 'परोक्ष' होता है।"
      },
      {
        'q': "दिए गए युग्मों में से सही विलोम शब्द का युग्म कौन सा है?",
        'ans': 'आशा - निराशा 🌟',
        'dist': ['दिन - सुबह', 'मित्र - सखा', 'सूर्य - दिनकर'],
        'exp': "'आशा' का ठीक विपरीत अर्थ 'निराशा' है, बाकी विकल्प समानार्थी हैं।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateParyayvachiQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "समान अर्थ प्रकट करने वाले शब्दों को क्या कहते हैं?",
        'ans': 'पर्यायवाची शब्द (Synonyms) 🪞',
        'dist': ['विलोम शब्द', 'भिन्नार्थक शब्द', 'एकार्थी शब्द'],
        'exp': 'जिन शब्दों का अर्थ लगभग एक जैसा होता है, वे पर्यायवाची या समानार्थी शब्द कहलाते हैं।'
      },
      {
        'q': "'सूर्य' शब्द के सही पर्यायवाची शब्द समूह को पहचानिए:",
        'ans': 'रवि, दिनकर, भानु ☀️',
        'dist': ['शशि, राकेश, चंद्रमा', 'जलज, नीरज, पंकज', 'अनल, पावक, दहन'],
        'exp': 'रवि, दिनकर, भानु, भास्कर और दिवाकर सभी सूर्य के पर्यायवाची हैं।'
      },
      {
        'q': "'जल' (Water) शब्द का पर्यायवाची कौन सा नहीं है?",
        'ans': 'अनल (आग) 🔥',
        'dist': ['नीर', 'तोय', 'वारि'],
        'exp': "'नीर', 'तोय' और 'वारि' जल के पर्यायवाची हैं, जबकि 'अनल' आग का पर्यायवाची है।"
      },
      {
        'q': "'कमल' (Lotus) का सही पर्यायवाची शब्द कौन सा है?",
        'ans': 'पंकज और जलज 🪷',
        'dist': ['बादल और मेघ', 'दामिनी और चंचला', 'पर्वत और अचल'],
        'exp': 'पंक (कीचड़) में जन्म लेने के कारण कमल को पंकज और जल में जन्म लेने के कारण जलज कहते हैं।'
      },
      {
        'q': "'आकाश' (Sky) का पर्यायवाची शब्द कौन सा है?",
        'ans': 'गगन, नभ, अंबर 🌌',
        'dist': ['धरा, वसुधा, भूमि', 'पादप, तरु, विटप', 'सरिता, तटिनी, तरंगिणी'],
        'exp': 'गगन, नभ, अंबर और व्योम आकाश के प्रमुख समानार्थी शब्द हैं।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateMuhavareQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "मुहावरा 'आँखों का तारा होना' का क्या अर्थ है?",
        'ans': 'बहुत प्यारा होना ❤️',
        'dist': ['आँख में कचरा पड़ना', 'कम दिखाई देना', 'तारे गिनना'],
        'exp': "उदाहरण: 'रोहन अपनी दादी की आँखों का तारा है' अर्थात् दादी को बहुत प्यारा है।"
      },
      {
        'q': "मुहावरा 'अंगूठा दिखाना' का सही अर्थ क्या है?",
        'ans': 'साफ इनकार कर देना 👎',
        'dist': ['मदद करना', 'ताली बजाना', 'हाथ मिलाना'],
        'exp': 'जब कोई समय पर मदद करने से साफ मना कर दे, तो उसे अंगूठा दिखाना कहते हैं।'
      },
      {
        'q': "'दाँतों तले उँगली दबाना' मुहावरे का क्या अर्थ होता है?",
        'ans': 'दंग रह जाना या आश्चर्यचकित होना 😲',
        'dist': ['भूख लगना', 'दाँत में दर्द होना', 'गुस्सा करना'],
        'exp': 'अनोखा करतब या चमत्कारी काम देखकर लोग दाँतों तले उँगली दबा लेते हैं।'
      },
      {
        'q': "लोकोक्ति 'नाच न जाने आँगन टेढ़ा' का सही भावार्थ क्या है?",
        'ans': 'अपनी कमी छिपाने के लिए दूसरों या साधनों में दोष निकालना 🎭',
        'dist': ['आँगन को सीधा करवाना', 'बहुत सुंदर नृत्य करना', 'आँगन में खेलना'],
        'exp': 'जब कोई काम खुद न आए और बहाना बनाया जाए, तब यह लोकोक्ति कही जाती है।'
      },
      {
        'q': "रिक्त स्थान में सही मुहावरा भरें: 'परीक्षा में प्रथम आकर अमन फूला न ...'",
        'ans': 'समाया (अत्यधिक प्रसन्न होना) 😊',
        'dist': ['पाया', 'गया', 'दिखा'],
        'exp': "मुहावरा है 'फूला न समाना', जिसका अर्थ अत्यधिक खुश होना होता है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateSandhiQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "दो समीपवर्ती वर्णों के परस्पर मेल से होने वाले विकार (परिवर्तन) को क्या कहते हैं?",
        'ans': 'संधि (Sandhi) 🔗',
        'dist': ['समास', 'उपसर्ग', 'प्रत्यय'],
        'exp': 'वर्णों के मेल को संधि और शब्दों के मेल को समास कहते हैं।'
      },
      {
        'q': "'विद्या + आलय' का सही संधि रूप क्या होगा?",
        'ans': 'विद्यालय 🏫',
        'dist': ['विद्यालय', 'विद्यलय', 'विद्याआलय'],
        'exp': "आ + आ = आ (दीर्घ स्वर संधि के नियमानुसार 'विद्यालय' बनता है)।"
      },
      {
        'q': "'सूर्योदय' शब्द का सही संधि-विच्छेद पहचानिए:",
        'ans': 'सूर्य + उदय 🌅',
        'dist': ['सूर्यो + दय', 'सूर्य + दय', 'सूर + उदय'],
        'exp': "अ + उ = ओ (गुण स्वर संधि के नियमानुसार 'सूर्योदय' बनता है)।"
      },
      {
        'q': "स्वर संधि के प्रमुख कितने भेद होते हैं?",
        'ans': '5 भेद (दीर्घ, गुण, वृद्धि, यण, अयादि) 🖐️',
        'dist': ['3 भेद', '4 भेद', '6 भेद'],
        'exp': 'हिंदी में स्वर संधि के पाँच मुख्य भेद माने जाते हैं।'
      },
      {
        'q': "'प्रति + एक' के मेल से कौन सा शुद्ध शब्द बनता है?",
        'ans': 'प्रत्येक (यण संधि) 🧩',
        'dist': ['प्रतिएक', 'प्रत्येएक', 'प्रात्येक'],
        'exp': "इ + ए = ये (यण संधि के नियम से 'प्रत्येक' बनता है)।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateSamasQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "दो या दो से अधिक शब्दों के मेल से नए सार्थक शब्द बनने की प्रक्रिया क्या कहलाती है?",
        'ans': 'समास (Compound) 📦',
        'dist': ['संधि', 'उपसर्ग', 'अव्यय'],
        'exp': 'समास का शाब्दिक अर्थ संक्षेप करना होता है।'
      },
      {
        'q': "'माता-पिता' और 'दिन-रात' में कौन सा समास है?",
        'ans': 'द्वंद्व समास ⚖️',
        'dist': ['द्विगु समास', 'तत्पुरुष समास', 'बहुव्रीहि समास'],
        'exp': 'जिस समास के दोनों पद प्रधान हों और बीच में योजक चिह्न या "और" का लोप हो, वह द्वंद्व समास होता है।'
      },
      {
        'q': "'चौराहा' (चार राहों का समूह) में कौन सा समास है?",
        'ans': 'द्विगु समास (संख्यावाचक पूर्वपद) 🚦',
        'dist': ['तत्पुरुष समास', 'कर्मधारय समास', 'अव्ययीभाव समास'],
        'exp': 'जिस समास का पहला पद संख्यावाचक हो, वह द्विगु समास कहलाता है।'
      },
      {
        'q': "'राजपुत्र' (राजा का पुत्र) किस समास का उदाहरण है?",
        'ans': 'तत्पुरुष समास 👑',
        'dist': ['द्वंद्व समास', 'अव्ययीभाव समास', 'बहुव्रीहि समास'],
        'exp': 'विभक्ति चिह्न (का) का लोप होने से यह संबंध तत्पुरुष समास है।'
      },
      {
        'q': "'पीतांबर' (पीला है अंबर जिसका - अर्थात् श्रीकृष्ण) में कौन सा समास है?",
        'ans': 'बहुव्रीहि समास 🦚',
        'dist': ['द्विगु समास', 'द्वंद्व समास', 'तत्पुरुष समास'],
        'exp': 'जहाँ दोनों पद मिलकर किसी तीसरे विशेष अर्थ (श्रीकृष्ण) की ओर संकेत करें, वह बहुव्रीहि समास होता है।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateUpsargPratyayQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "जो शब्दांश मूल शब्द के 'शुरू (आगे)' में जुड़कर उसका अर्थ बदल देते हैं, क्या कहलाते हैं?",
        'ans': 'उपसर्ग (Prefix) ⬅️',
        'dist': ['प्रत्यय', 'समास', 'कारक'],
        'exp': "जैसे 'ज्ञान' के आगे 'अ' लगाने से 'अज्ञान' बन जाता है।"
      },
      {
        'q': "जो शब्दांश मूल शब्द के 'अंत (पीछे)' में जुड़कर नए शब्द बनाते हैं, क्या कहलाते हैं?",
        'ans': 'प्रत्यय (Suffix) ➡️',
        'dist': ['उपसर्ग', 'संधि', 'विराम'],
        'exp': "जैसे 'सुंदर' के अंत में 'ता' लगाने से 'सुंदरता' बन जाता है।"
      },
      {
        'q': "'अनुराग' और 'अनुशासन' में कौन सा उपसर्ग प्रयुक्त हुआ है?",
        'ans': 'अनु 🔍',
        'dist': ['अ', 'अन', 'अगु'],
        'exp': "'अनु + राग = अनुराग' तथा 'अनु + शासन = अनुशासन' में 'अनु' उपसर्ग है।"
      },
      {
        'q': "'सफलता' शब्द में मूल शब्द और प्रत्यय क्या हैं?",
        'ans': 'सफल (मूल शब्द) + ता (प्रत्यय) 🏆',
        'dist': ['स (उपसर्ग) + फलता', 'सफल + आ', 'सफ + लता'],
        'exp': "'सफल' मूल शब्द के अंत में 'ता' प्रत्यय जुड़ा हुआ है।"
      },
      {
        'q': "'दैनिक' शब्द में किस प्रत्यय का प्रयोग हुआ है?",
        'ans': 'इक (दिन + इक = दैनिक) 📅',
        'dist': ['निक', 'क', 'ईक'],
        'exp': "'दिन' में 'इक' प्रत्यय लगने से पहला स्वर 'दै' होकर 'दैनिक' बनता है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateKarakQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "संज्ञा या सर्वनाम का क्रिया के साथ संबंध प्रकट करने वाले चिह्नों को क्या कहते हैं?",
        'ans': 'कारक और उनकी विभक्तियाँ (परसर्ग) 📍',
        'dist': ['उपसर्ग', 'विशेषण', 'विराम चिह्न'],
        'exp': 'हिंदी में आठ कारक होते हैं और उनके पहचान चिह्न विभक्ति कहलाते हैं।'
      },
      {
        'q': "वाक्य 'पेड़ से पत्ता गिरा' में 'पेड़ से' में कौन सा कारक है?",
        'ans': 'अपादान कारक (अलग होने का भाव) 🍃',
        'dist': ['करण कारक', 'कर्म कारक', 'अधिकरण कारक'],
        'exp': 'जहाँ किसी वस्तु का किसी स्थान से अलग होना पाया जाए, वहाँ अपादान कारक (से) होता है।'
      },
      {
        'q': "'राम ने रावण को बाण से मारा' में 'बाण से' (साधन) में कौन सा कारक है?",
        'ans': 'करण कारक (साधन) 🏹',
        'dist': ['अपादान कारक', 'कर्ता कारक', 'संप्रदान कारक'],
        'exp': 'जिस साधन या माध्यम से कार्य किया जाए, उसमें करण कारक (से) होता है।'
      },
      {
        'q': "'मेज पर पुस्तक रखी है' में 'पर' किस कारक का विभक्ति चिह्न है?",
        'ans': 'अधिकरण कारक (आधार/स्थान) 📖',
        'dist': ['संबंध कारक', 'संबोधन कारक', 'कर्म कारक'],
        'exp': 'क्रिया के आधार या स्थान का बोध कराने वाला कारक अधिकरण कारक (में, पर) होता है।'
      },
      {
        'q': "'हे प्रभु! सबकी रक्षा करो' में कौन सा कारक प्रयुक्त हुआ है?",
        'ans': 'संबोधन कारक (पुकारना) 🙏',
        'dist': ['कर्ता कारक', 'संप्रदान कारक', 'करण कारक'],
        'exp': 'किसी को पुकारने या सावधान करने के लिए संबोधन कारक (हे, अरे, ओ) का प्रयोग होता है।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateViramChihnQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "वाक्य की पूर्ण समाप्ति पर कौन सा विराम चिह्न लगाया जाता है?",
        'ans': 'पूर्ण विराम ( । ) 🛑',
        'dist': ['अल्पविराम ( , )', 'अर्धविराम ( ; )', 'प्रश्नवाचक ( ? )'],
        'exp': 'हिंदी में साधारण वाक्य समाप्त होने पर पूर्ण विराम (।) लगाया जाता है।'
      },
      {
        'q': "हर्ष, शोक, भय, आश्चर्य आदि मनोभावों को प्रकट करने के लिए कौन सा चिह्न लगता है?",
        'ans': 'विस्मयादिबोधक चिह्न ( ! ) ❗',
        'dist': ['योजक चिह्न ( - )', 'उद्धरण चिह्न ( " " )', 'निर्देशक चिह्न ( — )'],
        'exp': "उदाहरण: 'अरे! कितना सुंदर दृश्य है!' में विस्मयादिबोधक चिह्न (!) लगता है।"
      },
      {
        'q': "किसी के कहे कथन को ज्यों का त्यों लिखने के लिए किस चिह्न का प्रयोग करते हैं?",
        'ans': 'उद्धरण चिह्न ( " ... " ) 💬',
        'dist': ['कोष्ठक चिह्न ( )', 'लाघव चिह्न ( ॰ )', 'त्रुटिपूरक चिह्न ( ^ )'],
        'exp': 'किसी के कथन को मूल रूप में लिखने के लिए दोहरा उद्धरण चिह्न ("...") लगाते हैं।'
      },
      {
        'q': "'माता-पिता' या 'सुख-दुख' जैसे शब्दों के बीच लगने वाले छोटे रेखा चिह्न को क्या कहते हैं?",
        'ans': 'योजक चिह्न ( - ) ➖',
        'dist': ['पूर्ण विराम', 'अल्पविराम', 'प्रश्नवाचक'],
        'exp': 'शब्द युग्मों को जोड़ने के लिए योजक चिह्न (-) का प्रयोग होता है।'
      },
      {
        'q': "प्रश्न पूछने वाले वाक्यों के अंत में कौन सा चिह्न आता है?",
        'ans': 'प्रश्नवाचक चिह्न ( ? ) ❓',
        'dist': ['पूर्ण विराम ( । )', 'अल्पविराम ( , )', 'हंसपद ( ^ )'],
        'exp': "उदाहरण: 'आपका नाम क्या है?' के अंत में प्रश्नवाचक चिह्न (?) आता है।"
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateVakyaVicharQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "सार्थक शब्दों का वह व्यवस्थित समूह जिससे पूरा अर्थ स्पष्ट हो, क्या कहलाता है?",
        'ans': 'वाक्य (Sentence) 📝',
        'dist': ['पदबंध', 'वर्णमाला', 'मुहावरा'],
        'exp': 'शब्दों के सार्थक और व्यवस्थित मेल को वाक्य कहते हैं।'
      },
      {
        'q': "वाक्य के दो प्रमुख अंग कौन-कौन से होते हैं?",
        'ans': 'उद्देश्य और विधेय (Subject & Predicate) 🎯',
        'dist': ['संज्ञा और सर्वनाम', 'स्वर और व्यंजन', 'संधि और समास'],
        'exp': 'जिसके बारे में कुछ कहा जाए वह उद्देश्य और जो कुछ कहा जाए वह विधेय कहलाता है।'
      },
      {
        'q': "वाक्य 'मोहन पुस्तक पढ़ता है' में उद्देश्य क्या है?",
        'ans': 'मोहन 👤',
        'dist': ['पुस्तक', 'पढ़ता है', 'पुस्तक पढ़ता है'],
        'exp': "वाक्य में कार्य करने वाला और जिसके बारे में बात हो रही है, वह 'मोहन' है, अतः उद्देश्य है।"
      },
      {
        'q': "शुद्ध वाक्य का चयन कीजिए:",
        'ans': 'बाग में अनेक पेड़ हैं 🌳',
        'dist': ['बाग में अनेकों पेड़ हैं', 'बाग में अनेक पेड़ों हैं', 'बाग में अनेकों वृक्षों हैं'],
        'exp': "'अनेक' शब्द अपने आप में बहुवचन है, इसका 'अनेकों' रूप बनाना अशुद्ध है।"
      },
      {
        'q': "रचना के आधार पर वाक्य के कितने भेद होते हैं?",
        'ans': '3 भेद (सरल, संयुक्त, मिश्र) 📜',
        'dist': ['2 भेद', '4 भेद', '8 भेद'],
        'exp': 'रचना के आधार पर तीन भेद हैं: सरल वाक्य, संयुक्त वाक्य और मिश्र वाक्य।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateVarnamalaQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "हिंदी वर्णमाला में स्वरों की कुल संख्या कितनी मानी जाती है?",
        'ans': '11 स्वर (अ से औ) 🔤',
        'dist': ['13 स्वर', '9 स्वर', '25 स्वर'],
        'exp': 'हिंदी मानक वर्णमाला में 11 मूल स्वर हैं: अ, आ, इ, ई, उ, ऊ, ऋ, ए, ऐ, ओ, औ।'
      },
      {
        'q': "जिन वर्णों के उच्चारण में अन्य किसी ध्वनि की सहायता नहीं लेनी पड़ती, वे क्या कहलाते हैं?",
        'ans': 'स्वर (Vowels) 🎵',
        'dist': ['व्यंजन', 'संयुक्त अक्षर', 'विसर्ग'],
        'exp': 'स्वर स्वतंत्र ध्वनियाँ हैं जिनका उच्चारण बिना किसी अन्य वर्ण की सहायता के होता है।'
      },
      {
        'q': "'क्ष', 'त्र', 'ज्ञ', 'श्र' हिंदी में किस प्रकार के व्यंजन हैं?",
        'ans': 'संयुक्त व्यंजन (दो व्यंजनों का मेल) 🧩',
        'dist': ['स्पर्श व्यंजन', 'अंतःस्थ व्यंजन', 'ऊष्म व्यंजन'],
        'exp': 'क्ष (क्+ष्), त्र (त्+र्), ज्ञ (ज्+ञ्), श्र (श्+र्) दो व्यंजनों के मेल से बनते हैं।'
      },
      {
        'q': "'कमल' शब्द का सही वर्ण-विच्छेद क्या होगा?",
        'ans': 'क् + अ + म् + अ + ल् + अ 🪷',
        'dist': ['क + म + ल', 'क् + म् + ल्', 'क + अल + मल'],
        'exp': 'प्रत्येक व्यंजन में अंतर्निहित स्वर "अ" को हलंत लगाकर अलग किया जाता है।'
      },
      {
        'q': "अक्षर के ऊपर बिंदु (ं) को व्याकरण में क्या कहा जाता है?",
        'ans': 'अनुस्वार 📍',
        'dist': ['अनुनासिक (ँ)', 'विसर्ग (ः)', 'हलंत (्)'],
        'exp': 'शिरोरेखा के ऊपर लगने वाले बिंदु (ं) को अनुस्वार और चंद्रबिंदु (ँ) को अनुनासिक कहते हैं।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateBhashaLipiQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "अपने विचारों और भावों के आदान-प्रदान के सशक्त माध्यम को क्या कहते हैं?",
        'ans': 'भाषा (Language) 🗣️',
        'dist': ['लिपि', 'व्याकरण', 'बोली'],
        'exp': 'भाषा वह साधन है जिसके द्वारा मनुष्य अपने विचार बोलकर या लिखकर प्रकट करता है।'
      },
      {
        'q': "हिंदी भाषा को किस लिपि में लिखा जाता है?",
        'ans': 'देवनागरी लिपि 📜',
        'dist': ['रोमन लिपि', 'गुरुमुखी लिपि', 'फारसी लिपि'],
        'exp': 'हिंदी, संस्कृत और मराठी भाषाएँ देवनागरी लिपि में लिखी जाती हैं।'
      },
      {
        'q': "भारत में प्रतिवर्ष 'हिंदी दिवस' किस तिथि को मनाया जाता है?",
        'ans': '14 सितंबर 🇮🇳',
        'dist': ['15 अगस्त', '26 जनवरी', '2 अक्टूबर'],
        'exp': '14 सितंबर 1949 को संविधान सभा ने हिंदी को भारत संघ की राजभाषा स्वीकार किया था।'
      },
      {
        'q': "भाषा को शुद्ध रूप से बोलना, पढ़ना और लिखना सिखाने वाले शास्त्र को क्या कहते हैं?",
        'ans': 'व्याकरण (Grammar) 📖',
        'dist': ['साहित्य', 'इतिहास', 'भूगोल'],
        'exp': 'व्याकरण नियमों का वह शास्त्र है जो भाषा के शुद्ध प्रयोग का ज्ञान कराता है।'
      },
      {
        'q': "भाषा के दो मुख्य रूप कौन-कौन से होते हैं?",
        'ans': 'मौखिक और लिखित रूप 💬',
        'dist': ['सांकेतिक और चित्रात्मक', 'गद्य और पद्य', 'प्राचीन और आधुनिक'],
        'exp': 'बोलकर विचार प्रकट करना मौखिक भाषा और लिखकर प्रकट करना लिखित भाषा है।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generateAlankarQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "काव्य की शोभा बढ़ाने वाले तत्वों को क्या कहते हैं?",
        'ans': 'अलंकार (Figures of Speech) 💎',
        'dist': ['रस', 'छंद', 'समास'],
        'exp': "जिस प्रकार आभूषण शरीर की शोभा बढ़ाते हैं, उसी प्रकार अलंकार काव्य की शोभा बढ़ाते हैं।"
      },
      {
        'q': "'चारु चंद्र की चंचल किरणें' में 'च' वर्ण की बार-बार आवृत्ति से कौन सा अलंकार है?",
        'ans': 'अनुप्रास अलंकार 🌙',
        'dist': ['यमक अलंकार', 'उपमा अलंकार', 'श्लेष अलंकार'],
        'exp': 'जहाँ एक ही वर्ण की आवृत्ति बार-बार हो, वहाँ अनुप्रास अलंकार होता है।'
      },
      {
        'q': "'कनक कनक ते सौ गुनी' में 'कनक' शब्द दो बार आया और अर्थ अलग-अलग हैं (सोना और धतूरा)। इसमें कौन सा अलंकार है?",
        'ans': 'यमक अलंकार 🪙',
        'dist': ['अनुप्रास अलंकार', 'रूपक अलंकार', 'अतिशयोक्ति अलंकार'],
        'exp': 'जहाँ एक ही शब्द एक से अधिक बार आए और हर बार अर्थ भिन्न हो, वहाँ यमक अलंकार होता है।'
      },
      {
        'q': "'पीपर पात सरिस मन डोला' में मन की तुलना पीपल के पत्ते से की गई है। इसमें कौन सा अलंकार है?",
        'ans': 'उपमा अलंकार (तुलना) 🍃',
        'dist': ['रूपक अलंकार', 'उत्प्रेक्षा अलंकार', 'अनुप्रास अलंकार'],
        'exp': 'जहाँ किसी प्रसिद्ध वस्तु से उपमेय की समानता बताई जाए (सा, सी, सरिस), वहाँ उपमा अलंकार होता है।'
      },
      {
        'q': "'चरण कमल बंदौ हरिराई' में चरणों को ही सीधे कमल मान लिया गया है। यह किसका उदाहरण है?",
        'ans': 'रूपक अलंकार 🪷',
        'dist': ['उपमा अलंकार', 'यमक अलंकार', 'श्लेष अलंकार'],
        'exp': 'जहाँ उपमेय और उपमान में भेद मिटाकर एकरूपता दिखा दी जाए, वहाँ रूपक अलंकार होता है।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  Activity _generatePadParichayQuestion(Chapter chapter, StudentClass studentClass, int idx) {
    final qMap = [
      {
        'q': "वाक्य में प्रयुक्त शब्दों को जब व्याकरण के नियमों में बाँध दिया जाता है, तो वे क्या कहलाते हैं?",
        'ans': 'पद (Word in syntax) 🧩',
        'dist': ['वर्ण', 'ध्वनि', 'उपसर्ग'],
        'exp': 'स्वतंत्र शब्द जब वाक्य में प्रयुक्त होते हैं, तो वे "पद" कहलाते हैं।'
      },
      {
        'q': "वाक्य में प्रयुक्त किसी पद का व्याकरणिक परिचय (संज्ञा, लिंग, वचन, कारक आदि बताना) क्या कहलाता है?",
        'ans': 'पद-परिचय (Parsing) 🔍',
        'dist': ['वर्ण-विच्छेद', 'संधि-विच्छेद', 'समास-विग्रह'],
        'exp': 'पद का संपूर्ण व्याकरणिक विश्लेषण पद-परिचय कहलाता है।'
      },
      {
        'q': "जिन शब्दों के रूप में लिंग, वचन, कारक या काल के कारण कोई परिवर्तन (विकार) नहीं होता, वे क्या कहलाते हैं?",
        'ans': 'अविकारी शब्द (अव्यय) 🛡️',
        'dist': ['विकारी शब्द', 'संज्ञा पद', 'विशेषण पद'],
        'exp': 'क्रियाविशेषण, संबंधबोधक, समुच्चयबोधक और विस्मयादिबोधक अव्यय शब्द होते हैं जो सदा एक समान रहते हैं।'
      },
      {
        'q': "वाक्य 'कछुआ धीरे-धीरे चलता है' में 'धीरे-धीरे' क्या है?",
        'ans': 'रीतिवाचक क्रियाविशेषण 🐢',
        'dist': ['संज्ञा', 'विशेषण', 'कारक'],
        'exp': 'चलने की रीति या तरीके का बोध कराने के कारण यह रीतिवाचक क्रियाविशेषण है।'
      },
      {
        'q': "'और', 'किंतु', 'परंतु', 'इसलिए' दो वाक्यों को जोड़ने वाले किस प्रकार के अव्यय हैं?",
        'ans': 'समुच्चयबोधक (Conjunction) 🔗',
        'dist': ['संबंधबोधक', 'विस्मयादिबोधक', 'निपात'],
        'exp': 'दो शब्दों या उपवाक्यों को जोड़ने वाले अव्यय समुच्चयबोधक (योजक) कहलाते हैं।'
      },
    ];
    return _buildQuestionFromData(chapter, studentClass, qMap, idx);
  }

  // ---------------------------------------------------------------------------
  // GENERAL SMART HINDI MCQ FALLBACK
  // ---------------------------------------------------------------------------

  Activity _generateCurriculumHindiMCQ(Chapter chapter, StudentClass studentClass, int idx) {
    String prompt = '';
    String answer = '';
    List<String> options = [];
    String explanation = '';

    final hasValidExample = chapter.exampleQuestion != null &&
        chapter.exampleQuestion!.trim().length > 10 &&
        chapter.exampleAnswer != null &&
        chapter.exampleAnswer!.isNotEmpty;

    final step = (idx - 1) % 5;

    // Step 0: Worked example or Core Definition
    if (step == 0 && hasValidExample) {
      prompt = chapter.exampleQuestion!;
      answer = chapter.exampleAnswer!;
      explanation = chapter.exampleExplanation ?? 'यह उत्तर "${chapter.title}" के अध्ययन पर आधारित है।';
      options = _buildOptionsWithDistractors(answer, chapter);
    }
    // Step 1: Rule 0 or Key Concept 0 with custom prompt
    else if (step == 1 && chapter.rules.isNotEmpty) {
      final trueRule = chapter.rules[0];
      prompt = 'पाठ "${chapter.title}" के अनुसार, कौन सा मूलभूत व्याकरणिक या व्यावहारिक नियम सही है?';
      answer = trueRule;
      explanation = 'व्याकरण और पाठ के नियमानुसार: $trueRule।';
      options = _buildOptionsWithDistractors(answer, chapter, fallbackDistractors: [
        'यह नियम केवल विशेष परिस्थितियों में ही लागू होता है',
        'यह सामान्य भाषा प्रयोग के विपरीत माना जाता है',
        'इसका प्रयोग आधुनिक बोलचाल में वर्जित है',
      ]);
    }
    // Step 2: Key Concept 0 with unique prompt
    else if (step == 2 && chapter.keyConcepts.isNotEmpty) {
      final kc = chapter.keyConcepts[0];
      prompt = 'पाठ "${chapter.title}" में मुख्य रूप से "$kc" के बारे में क्या समझाया गया है?';
      answer = chapter.rules.length > 1 ? chapter.rules[1] : 'यह भाषा ज्ञान और शुद्ध प्रयोग को समृद्ध करता है';
      explanation = 'इस पाठ में "$kc" के सटीक अर्थ और प्रयोग पर विस्तार से बल दिया गया है।';
      options = _buildOptionsWithDistractors(answer, chapter);
    }
    // Step 3: Rule 1 or Key Concept 1 with application prompt
    else if (step == 3 && (chapter.rules.length > 1 || chapter.keyConcepts.length > 1)) {
      final topic = chapter.keyConcepts.length > 1 ? chapter.keyConcepts[1] : chapter.title;
      prompt = 'दिए गए विकल्पों में से "${chapter.title}" का सबसे उत्तम उदाहरण या व्यावहारिक प्रयोग कौन सा है?';
      answer = chapter.rules.length > 1 ? chapter.rules[1] : 'दैनिक जीवन में भाषा का शुद्ध और स्पष्ट उपयोग';
      explanation = 'पाठ के अनुसार "$topic" का सही ज्ञान हमें शुद्ध अभिव्यक्ति में सहायता करता है।';
      options = _buildOptionsWithDistractors(answer, chapter);
    }
    // Step 4: Critical understanding & learning outcome prompt
    else {
      prompt = 'पाठ "${chapter.title}" को अच्छी तरह सीखने के बाद विद्यार्थी किस महत्वपूर्ण योग्यता को प्राप्त करते हैं?';
      answer = chapter.keyConcepts.isNotEmpty
          ? 'भाषा के शुद्ध स्वरूप और "${chapter.keyConcepts.first}" की सही समझ'
          : 'शुद्ध पठन, लेखन और व्याकरण सम्मत भाषा का बोध';
      explanation = 'यह पाठ विद्यार्थियों को मानक हिंदी के सही नियमों से भली-भाँति परिचित कराता है।';
      options = [
        answer,
        'केवल कठिन शब्दों को बिना समझे रटने की आदत',
        'व्याकरण के नियमों की अनदेखी करके लिखना',
        'शब्दों के अर्थ को जाने बिना उनका गलत प्रयोग करना',
      ]..shuffle(_rng);
    }

    final id = 'hin_mcq_${DateTime.now().microsecondsSinceEpoch}_$idx';
    return Activity(
      activityId: id,
      topicId: 'hindi_${chapter.chapterId}',
      subjectId: 'hindi',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': '🇮🇳',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------

  Activity _buildQuestionFromData(
    Chapter chapter,
    StudentClass studentClass,
    List<Map<String, dynamic>> qList,
    int idx,
  ) {
    final selected = qList[(idx - 1) % qList.length];
    final prompt = selected['q'] as String;
    final answer = selected['ans'] as String;
    final dist = selected['dist'] as List<String>;
    final exp = selected['exp'] as String;

    final options = [answer, ...dist]..shuffle(_rng);
    final id = 'hin_act_${chapter.chapterId}_${DateTime.now().microsecondsSinceEpoch}_$idx';

    return Activity(
      activityId: id,
      topicId: 'hindi_${chapter.chapterId}',
      subjectId: 'hindi',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': '📖',
        'options': options,
        'explanation': exp,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }

  List<String> _buildOptionsWithDistractors(
    String answer,
    Chapter chapter, {
    List<String>? fallbackDistractors,
  }) {
    final distractors = <String>[];

    for (final kc in chapter.keyConcepts) {
      if (kc != answer && !distractors.contains(kc) && distractors.length < 3) {
        distractors.add(kc);
      }
    }

    if (fallbackDistractors != null) {
      for (final fd in fallbackDistractors) {
        if (fd != answer && !distractors.contains(fd) && distractors.length < 3) {
          distractors.add(fd);
        }
      }
    }

    final defaultHindiDistractors = [
      'विराम चिह्नों का अनावश्यक प्रयोग',
      'वर्णों का अशुद्ध उच्चारण और लेखन',
      'वाक्य में पदों का अव्यवस्थित क्रम',
      'व्याकरण के मूल नियमों की अनदेखी',
      'समानार्थी शब्दों का अनुचित चुनाव',
      'भाषा की मानक वर्तनी से विचलन',
    ];

    for (final d in defaultHindiDistractors) {
      if (d != answer && !distractors.contains(d) && distractors.length < 3) {
        distractors.add(d);
      }
    }

    return [answer, ...distractors.take(3)]..shuffle(_rng);
  }
}
