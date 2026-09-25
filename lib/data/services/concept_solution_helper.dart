import '../models/activity_model.dart';
import '../models/chapter_model.dart';

/// Structured solution and pedagogical concept breakdown for any activity
class ConceptSolutionDetails {
  final String questionText;
  final String visualIcon;
  final String correctAnswer;
  final String hint;
  final List<String> steps;
  final String conceptTitle;
  final String conceptDetail;
  final List<String> formulasAndRules;
  final String proTip;

  const ConceptSolutionDetails({
    required this.questionText,
    required this.visualIcon,
    required this.correctAnswer,
    required this.hint,
    required this.steps,
    required this.conceptTitle,
    required this.conceptDetail,
    required this.formulasAndRules,
    required this.proTip,
  });

  /// Audio narration text for TTS read-aloud
  String get speechNarration {
    final buffer = StringBuffer();
    buffer.writeln('Here is the concept and solution for this question.');
    buffer.writeln('The correct answer is $correctAnswer.');
    if (steps.isNotEmpty) {
      buffer.writeln('Step by step solution:');
      for (int i = 0; i < steps.length; i++) {
        buffer.writeln('Step ${i + 1}: ${steps[i]}');
      }
    }
    buffer.writeln('Concept: $conceptTitle. $conceptDetail');
    if (formulasAndRules.isNotEmpty) {
      buffer.writeln('Remember this rule: ${formulasAndRules.first}');
    }
    return buffer.toString();
  }
}

/// Helper service that generates authentic hints and concept-rich solutions
/// for every single question in Curio Math.
class ConceptSolutionHelper {
  static final ConceptSolutionHelper instance = ConceptSolutionHelper._();
  ConceptSolutionHelper._();

  ConceptSolutionDetails getDetails(Activity activity, {Chapter? chapter}) {
    final payload = activity.interactionPayload;
    final prompt = activity.promptData.text;
    final visualIcon = payload['visualIcon'] as String? ?? (activity.subjectId == 'english' ? '📚' : '📐');
    final rawExpected = activity.validationRule.expectedAnswer?.toString() ??
        payload['finalResult']?.toString() ??
        'Check concept rules';
    final correctAnswer = rawExpected.isNotEmpty ? rawExpected : 'Correct option';
    final explanation = payload['explanation'] as String? ?? '';

    // 1. Determine Hint
    String hint = '';
    if (payload['hint'] != null && payload['hint'].toString().isNotEmpty) {
      hint = payload['hint'].toString();
    } else if (activity.validationRule.hintTree.isNotEmpty) {
      hint = activity.validationRule.hintTree.map((h) => h.hintText).join('\n• ');
      if (activity.validationRule.hintTree.length > 1) {
        hint = '• $hint';
      }
    } else {
      hint = _generateSmartHint(prompt, activity, chapter);
    }

    // 2. Generate Step-by-Step Working
    List<String> steps = [];
    if (payload['stepWorking'] is List && (payload['stepWorking'] as List).isNotEmpty) {
      steps = (payload['stepWorking'] as List).map((e) => e.toString()).toList();
    } else {
      steps = _generateSteps(prompt, activity, correctAnswer, explanation, chapter);
    }

    // 3. Extract or Synthesize Concept Information
    String conceptTitle = '';
    String conceptDetail = '';
    if (payload['conceptTitle'] != null && payload['conceptDetail'] != null) {
      conceptTitle = payload['conceptTitle'].toString();
      conceptDetail = payload['conceptDetail'].toString();
    } else {
      final conceptInfo = _synthesizeConceptInfo(prompt, activity, chapter);
      conceptTitle = conceptInfo.$1;
      conceptDetail = conceptInfo.$2;
    }

    // 4. Extract or Synthesize Formulas & Golden Rules
    List<String> formulas = [];
    if (payload['rules'] is List && (payload['rules'] as List).isNotEmpty) {
      formulas = (payload['rules'] as List).map((e) => e.toString()).toList();
    } else {
      formulas = _extractFormulas(prompt, activity, chapter, conceptTitle);
    }

    // 5. Pro Tip
    final proTip = (payload['proTip'] as String?) ?? _generateProTip(prompt, activity, chapter);

    return ConceptSolutionDetails(
      questionText: prompt,
      visualIcon: visualIcon,
      correctAnswer: correctAnswer,
      hint: hint,
      steps: steps,
      conceptTitle: conceptTitle,
      conceptDetail: conceptDetail,
      formulasAndRules: formulas,
      proTip: proTip,
    );
  }

  /// Synthesizes an authentic pedagogical hint that is dynamically tailored
  /// to the specific numbers, operations, grammar rules, and challenge in the question.
  String _generateSmartHint(String prompt, Activity activity, Chapter? chapter) {
    final lower = prompt.toLowerCase();
    final numbers = RegExp(r'\b\d+\b').allMatches(prompt).map((m) => int.tryParse(m.group(0)!) ?? 0).toList();

    // 1. Math - Specific Topics & Concepts (Higher Precedence)
    if (lower.contains('quadrant') || lower.contains('coordinate') || lower.contains('abscissa') || lower.contains('ordinate')) {
      return 'Recall the Cartesian plane sign convention:\n• Quadrant I: (+, +)\n• Quadrant II: (−, +)\n• Quadrant III: (−, −)\n• Quadrant IV: (+, −)\nLook closely at the signs of x and y!';
    }

    if (lower.contains('reciprocal') || lower.contains('multiplicative inverse')) {
      return 'The reciprocal (or multiplicative inverse) flips the numerator and denominator: for a fraction a/b, its reciprocal is b/a (their product must equal 1).';
    }

    if (lower.contains('additive inverse')) {
      return 'The additive inverse is the number that sums to 0 with it. Just flip the positive/negative sign (+ to − or − to +)!';
    }

    if (lower.contains('fraction') || lower.contains('numerator') || lower.contains('denominator') || prompt.contains('/') && !prompt.contains('//')) {
      if (lower.contains('equivalent')) {
        return 'To find an equivalent fraction, multiply or divide both top (numerator) and bottom (denominator) by the exact same number!';
      }
      return 'Check the denominators: When adding or subtracting fractions, make sure denominators match by finding the LCM first!';
    }

    if (lower.contains('solve for x') || lower.contains('equation') || (prompt.contains('=') && lower.contains('x') && !lower.contains('index'))) {
      return 'Isolate x! Step 1: Undo addition/subtraction to move numbers to the other side. Step 2: Undo multiplication/division to find x.';
    }

    if (lower.contains('exponent') || lower.contains('power') || lower.contains('law of exponents')) {
      return 'Laws of exponents: When multiplying with identical base, ADD powers (aᵐ × aⁿ = aᵐ⁺ⁿ). When dividing, SUBTRACT powers (aᵐ ÷ aⁿ = aᵐ⁻ⁿ).';
    }

    if (lower.contains('square root') || lower.contains('cube root')) {
      return 'Think backwards: What number multiplied by itself gives this target value?';
    }

    if (lower.contains('roman numeral') || lower.contains('roman')) {
      return 'Roman values: I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000. When a smaller symbol appears before a larger one, subtract it!';
    }

    // 2. Math - Arithmetic Operations with concrete numbers
    if (prompt.contains('+') || lower.contains('sum of') || lower.contains('add ') || lower.contains('in all') || lower.contains('altogether')) {
      if (numbers.length >= 2) {
        final a = numbers[0];
        final b = numbers[1];
        return 'To calculate $a + $b: Break it down into tens and ones (e.g. add the tens first, then add the ones, and combine).';
      }
      return 'For addition: Combine the values step by step. Align by place value (ones under ones, tens under tens) and carry over if needed.';
    }

    final hasSubtractionPattern = RegExp(r'\b\d+\s*[-−]\s*\d+\b').hasMatch(prompt);
    if (hasSubtractionPattern || lower.contains('subtract') || lower.contains('difference') || lower.contains('how much more') || lower.contains('how many left')) {
      if (numbers.length >= 2) {
        final a = numbers[0];
        final b = numbers[1];
        return 'To find $a − $b: Take away the tens first, then take away the ones (or count up from $b to $a).';
      }
      return 'For subtraction: Remember to borrow (regroup) from the higher place value if the top digit is smaller than the bottom digit.';
    }

    if (prompt.contains('×') || RegExp(r'\b\d+\s*[*×]\s*\d+\b').hasMatch(prompt) || lower.contains('multiply') || lower.contains('product of') || lower.contains('times')) {
      if (numbers.length >= 2) {
        final a = numbers[0];
        final b = numbers[1];
        return 'To calculate $a × $b: Think of it as adding $a repeatedly $b times, or recall your $a times table!';
      }
      return 'For multiplication: Break large numbers using the distributive property (e.g., multiply by tens, then ones, and sum the results).';
    }

    if (prompt.contains('÷') || lower.contains('divide') || lower.contains('quotient') || lower.contains('split equally') || lower.contains('shared equally')) {
      if (numbers.length >= 2) {
        final a = numbers[0];
        final b = numbers[1];
        return 'To calculate $a ÷ $b: Ask yourself: "What number multiplied by $b equals $a?"';
      }
      return 'For division: Use inverse multiplication to determine how many times the divisor fits into the dividend.';
    }

    // 2. Math - Geometry & Spatial Reasoning
    if (lower.contains('brick') || lower.contains('face') || lower.contains('edge') || lower.contains('vertic') || lower.contains('corner')) {
      if (lower.contains('brick') || lower.contains('cuboid')) {
        return 'Remember: A standard brick or cuboid has 6 rectangular flat faces, 12 straight edges, and 8 corners (vertices).';
      }
      if (lower.contains('cube')) {
        return 'A cube has 6 identical square faces, 12 equal edges, and 8 corners.';
      }
      if (lower.contains('cylinder')) {
        return 'A cylinder has 2 circular flat faces and 1 curved surface with no sharp corners.';
      }
      if (lower.contains('sphere')) {
        return 'A sphere is completely round with 1 continuous curved surface and 0 edges or corners.';
      }
      if (lower.contains('cone')) {
        return 'A cone has 1 flat circular base, 1 curved surface, and 1 pointed top (apex).';
      }
      return 'Count the flat surfaces (faces), the lines where two faces meet (edges), and the sharp points (vertices).';
    }

    if (lower.contains('perimeter')) {
      return 'Perimeter is the distance all the way around the outside. Add all the outer side lengths together!';
    }

    if (lower.contains('area')) {
      return 'Area is the surface inside. For rectangles: Area = Length × Breadth. For squares: Area = Side × Side.';
    }

    if (lower.contains('volume') || lower.contains('capacity') || lower.contains('cylinder') || lower.contains('cuboid')) {
      return 'Volume is 3D capacity. For cuboids: Volume = Length × Breadth × Height. Check if units match (cm³ or m³).';
    }

    if (lower.contains('angle') || lower.contains('degree')) {
      return 'Remember:\n• Acute < 90°\n• Right = 90° (square corner)\n• Obtuse is between 90° and 180°\n• Straight = 180°.';
    }

    // 3. Math - Decimals (digits before and after point)
    if (lower.contains('decimal') || RegExp(r'\b\d+\.\d+\b').hasMatch(prompt)) {
      return 'Line up the decimal points straight down before adding, subtracting, or comparing decimals!';
    }

    // 4. Math - Powers, Roots & Roman Numerals
    if (lower.contains('exponent') || lower.contains('power') || lower.contains('law of exponents')) {
      return 'Laws of exponents: When multiplying with identical base, ADD powers (aᵐ × aⁿ = aᵐ⁺ⁿ). When dividing, SUBTRACT powers (aᵐ ÷ aⁿ = aᵐ⁻ⁿ).';
    }

    if (lower.contains('square root') || lower.contains('cube root')) {
      return 'Think backwards: What number multiplied by itself gives this target value?';
    }

    if (lower.contains('roman numeral') || lower.contains('roman')) {
      return 'Roman values: I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000. If smaller comes before larger, subtract it!';
    }

    // 5. Math - Algebra & Equations
    if (lower.contains('solve for x') || lower.contains('equation') || prompt.contains('=') && lower.contains('x')) {
      return 'Isolate x! Step 1: Undo addition/subtraction to move numbers to the other side. Step 2: Undo multiplication/division to find x.';
    }

    // 6. Math - Number Theory (LCM, HCF, Factors, Multiples)
    if (lower.contains('lcm') || lower.contains('least common multiple')) {
      return 'LCM is the smallest positive number that is a multiple of all given numbers. List multiples or use prime factorization!';
    }

    if (lower.contains('hcf') || lower.contains('gcd') || lower.contains('highest common factor') || lower.contains('greatest common')) {
      return 'HCF is the largest number that divides into all given numbers without leaving a remainder. Find their common prime factors!';
    }

    if (lower.contains('prime') || lower.contains('composite')) {
      return 'A prime number has only 2 factors (1 and itself). A composite number has more than 2 factors.';
    }

    // 7. Math - Time, Money, Patterns & Measurement
    if (lower.contains('time') || lower.contains('clock') || lower.contains('minute') || lower.contains('hour')) {
      return 'Remember: 1 hour = 60 minutes, 1 minute = 60 seconds. "Half past" means 30 minutes, "Quarter past" means 15 minutes.';
    }

    if (lower.contains('rupee') || lower.contains('paisa') || lower.contains('cost') || lower.contains('price') || lower.contains('₹')) {
      return 'Remember that ₹1 = 100 paise. Calculate total cost by multiplying unit price by quantity, or subtract to find change.';
    }

    if (lower.contains('pattern') || lower.contains('sequence') || lower.contains('next number') || lower.contains('comes next')) {
      return 'Look at the gap between consecutive numbers: Is it adding a constant amount, multiplying, or following a square sequence?';
    }

    // 8. English - Parts of Speech & Grammar
    if (lower.contains('noun')) {
      return 'A noun names a person, place, animal, or thing (e.g. teacher, Delhi, tiger, book). Ask: Which word represents an object or being?';
    }

    if (lower.contains('verb')) {
      return 'A verb is an action or state word (e.g. jump, writes, is, play). Ask: What action is taking place in this sentence?';
    }

    if (lower.contains('adjective')) {
      return 'An adjective describes a noun (e.g. blue, large, fast, beautiful). Ask: Which word tells what kind, how many, or color?';
    }

    if (lower.contains('adverb')) {
      return 'An adverb describes how, when, or where an action happens (often ending in -ly, like quickly, brightly, yesterday).';
    }

    if (lower.contains('pronoun')) {
      return 'A pronoun takes the place of a noun to avoid repeating names (e.g. he, she, it, they, we, us).';
    }

    if (lower.contains('preposition')) {
      return 'A preposition indicates position, direction, or time (e.g. in, on, at, under, behind, through, between).';
    }

    if (lower.contains('conjunction')) {
      return 'A conjunction connects words, phrases, or clauses (e.g. and, but, because, although, or, so).';
    }

    if (lower.contains('article') || lower.contains(' a ') || lower.contains(' an ') || lower.contains(' the ')) {
      return 'Use "an" before vowel sounds (a, e, i, o, u). Use "a" before consonant sounds. Use "the" when speaking of a specific item.';
    }

    if (lower.contains('past tense') || lower.contains('present tense') || lower.contains('future tense') || lower.contains('tense')) {
      if (lower.contains('past')) {
        return 'Past tense describes actions that have already finished (look for -ed endings or irregular forms like went, took, ate).';
      }
      if (lower.contains('future')) {
        return 'Future tense describes actions that will happen later (look for "will" or "shall").';
      }
      return 'Check whether the action happens in the past (already done), present (happening now), or future (yet to come).';
    }

    if (lower.contains('synonym')) {
      return 'A synonym is a word that has the same or very similar meaning as the given word.';
    }

    if (lower.contains('antonym') || lower.contains('opposite')) {
      return 'An antonym is a word that means the exact opposite of the target word.';
    }

    if (lower.contains('plural') || lower.contains('singular')) {
      return 'Singular means exactly one. Plural means two or more (check for -s, -es, -ies, or irregular plurals like children, feet).';
    }

    if (lower.contains('idiom')) {
      return 'An idiom has a figurative meaning different from its literal words. Think about the underlying metaphor or lesson.';
    }

    // 9. Phonics, Letters & Early Explorer
    if (lower.contains('rhyme') || lower.contains('rhyming')) {
      return 'Say the words out loud! Rhyming words have the exact same ending sound (e.g. cat, bat, hat).';
    }

    if (lower.contains('phonic') || lower.contains('sound') || lower.contains('starts with') || lower.contains('letter')) {
      return 'Listen to the starting or ending sound of the word and match it with the correct letter sound.';
    }

    if (lower.contains('count') || lower.contains('how many')) {
      return 'Point and count each item one by one carefully so you don\'t double count or miss any!';
    }

    // 10. Intelligent Fallback: Question-Targeted Clue (never a generic chapter rule)
    final options = (activity.interactionPayload['options'] as List<dynamic>?)?.map((e) => e.toString()).toList();
    if (options != null && options.isNotEmpty) {
      return 'Carefully read the question prompt: "$prompt". Test each of the options (${options.take(3).join(', ')}) to see which one logically satisfies the condition!';
    }

    return 'Carefully read the question: "$prompt". Identify the key terms and given information to solve step by step.';
  }

  /// Synthesizes clear step-by-step mathematical working
  List<String> _generateSteps(
    String prompt,
    Activity activity,
    String correctAnswer,
    String explanation,
    Chapter? chapter,
  ) {
    final lower = prompt.toLowerCase();
    final steps = <String>[];

    // Linear equation steps if available in payload
    final stepsReq = activity.interactionPayload['stepsRequired'] as List<dynamic>?;
    if (stepsReq != null && stepsReq.isNotEmpty) {
      for (final s in stepsReq) {
        if (s is Map<String, dynamic>) {
          final action = s['action']?.toString() ?? '';
          final operand = s['operand']?.toString() ?? '';
          final resultPrompt = s['resultPrompt']?.toString() ?? '';
          steps.add('Apply $action ($operand): gives $resultPrompt');
        }
      }
      steps.add('Final Answer: $correctAnswer');
      return steps;
    }

    // Cartesian Coordinates & Quadrants
    if (lower.contains('quadrant') || lower.contains('coordinate')) {
      steps.add('Identify the given coordinate pair (x, y) from the question.');
      steps.add('Check the algebraic sign of the x-coordinate (abscissa) and y-coordinate (ordinate).');
      steps.add('Match with the coordinate quadrant rules: (+,+) → QI, (−,+) → QII, (−,−) → QIII, (+,−) → QIV.');
      steps.add('Conclusion: The correct position or quadrant is $correctAnswer.');
      return steps;
    }

    // Exponents
    if (lower.contains('exponent') || lower.contains('power')) {
      steps.add('Examine the base numbers and the powers in the expression.');
      steps.add('Check if bases are identical so exponential multiplication or division rules can be applied.');
      steps.add('Simplify exponents step by step using mathematical identity rules.');
      steps.add('Conclusion: The evaluated result is $correctAnswer.');
      return steps;
    }

    // Rational numbers & Fractions
    if (lower.contains('reciprocal') || lower.contains('multiplicative inverse')) {
      steps.add('Express the given number as a clear fraction a/b.');
      steps.add('Invert the fraction by placing the denominator in the numerator and vice versa (b/a).');
      steps.add('Verify: (a/b) × (b/a) = 1 (satisfies the multiplicative inverse definition).');
      steps.add('Conclusion: The reciprocal is $correctAnswer.');
      return steps;
    }

    // Mensuration (Area / Perimeter / Volume)
    if (lower.contains('area') || lower.contains('perimeter') || lower.contains('volume')) {
      steps.add('Identify the geometric shape and list all given dimensions.');
      steps.add('Select the standard formula corresponding to the requested property.');
      steps.add('Substitute the values into the formula and perform the calculation.');
      steps.add('Conclusion: The calculated value with appropriate units is $correctAnswer.');
      return steps;
    }

    // General step synthesis from explanation or chapter
    if (explanation.isNotEmpty && explanation != 'Review the concept and try again!') {
      steps.add('Analyze the problem statement: "$prompt".');
      steps.add('Reasoning: $explanation');
      steps.add('Therefore, the correct choice is $correctAnswer.');
      return steps;
    }

    steps.add('Understand what the question is asking: "$prompt".');
    if (chapter != null && chapter.keyConcepts.isNotEmpty) {
      steps.add('Apply core chapter concept: ${chapter.keyConcepts.first}.');
    }
    steps.add('Evaluate the given options against mathematical rules.');
    steps.add('The verified correct solution is $correctAnswer.');
    return steps;
  }

  /// Synthesizes the concept title and detailed pedagogical concept note
  (String, String) _synthesizeConceptInfo(String prompt, Activity activity, Chapter? chapter) {
    final lower = prompt.toLowerCase();

    if (lower.contains('quadrant') || lower.contains('coordinate') || lower.contains('abscissa')) {
      return (
        'Cartesian Coordinate System',
        'In Cartesian geometry, two perpendicular axes (the horizontal x-axis and vertical y-axis) intersect at the origin (0,0), dividing the 2D plane into four quadrants. Every point is specified by an ordered pair (x, y).'
      );
    }
    if (lower.contains('reciprocal') || lower.contains('multiplicative inverse')) {
      return (
        'Multiplicative Inverse & Rational Numbers',
        'The multiplicative inverse (or reciprocal) of any non-zero number x is 1/x such that their product is strictly 1. Note: Zero (0) is the only number that has NO reciprocal.'
      );
    }
    if (lower.contains('additive inverse')) {
      return (
        'Additive Inverse & Integers',
        'The additive inverse of a number is what you add to it to get zero (the additive identity). For any real number a, its additive inverse is −a.'
      );
    }
    if (lower.contains('solve for x') || lower.contains('equation')) {
      return (
        'Linear Equations in One Variable',
        'An equation is a statement of equality between two algebraic expressions. To solve for the unknown variable, whatever mathematical operation is done to one side must also be done to the other side to maintain balance.'
      );
    }
    if (lower.contains('exponent') || lower.contains('power')) {
      return (
        'Exponents and Powers',
        'Exponents represent repeated multiplication of the same base. Key laws include product of powers with same base, quotient of powers, and power of a power.'
      );
    }
    if (lower.contains('surface area') || lower.contains('volume') || lower.contains('mensuration')) {
      return (
        'Mensuration of Solid Shapes',
        'Mensuration deals with the measurement of lengths, areas, and volumes of 2D and 3D geometric figures. 3D solids have curved/lateral surface area, total surface area, and internal volume capacity.'
      );
    }
    if (lower.contains('roman numeral')) {
      return (
        'Roman Numeral Number System',
        'The Roman numeral system is an ancient additive-subtractive base system using 7 key letter symbols (I, V, X, L, C, D, M). Symbols can be repeated at most 3 times consecutively.'
      );
    }
    if (lower.contains('fraction')) {
      return (
        'Fractions and Parts of a Whole',
        'A fraction represents a part of a whole or collection. The denominator indicates how many equal parts the whole is divided into, while the numerator indicates how many parts are taken.'
      );
    }
    if (lower.contains('time') || lower.contains('clock')) {
      return (
        'Measurement of Time',
        'Standard units of time include seconds, minutes, and hours. The clock face is divided into 12 hours with 60 minute increments, where the short hand points to hours and the long hand points to minutes.'
      );
    }

    // Default to Chapter metadata if available
    final title = chapter?.title ?? activity.chapterName ?? 'Mathematical Concept';
    final desc = (chapter != null && chapter.description.isNotEmpty)
        ? chapter.description
        : 'This activity reinforces foundational mathematical reasoning, problem solving, and analytical thinking according to the CBSE & ICSE syllabus.';
    return (title, desc);
  }

  /// Extracts formulas and rules from chapter or mathematical domain
  List<String> _extractFormulas(String prompt, Activity activity, Chapter? chapter, String conceptTitle) {
    final lower = prompt.toLowerCase();
    final list = <String>[];

    if (lower.contains('quadrant') || lower.contains('coordinate')) {
      list.add('Quadrant I: (+, +) | Quadrant II: (−, +)');
      list.add('Quadrant III: (−, −) | Quadrant IV: (+, −)');
      list.add('Point on x-axis: (x, 0) | Point on y-axis: (0, y)');
      return list;
    }
    if (lower.contains('reciprocal') || lower.contains('multiplicative inverse')) {
      list.add('Reciprocal of a/b = b/a (where a ≠ 0, b ≠ 0)');
      list.add('Property: (a/b) × (b/a) = 1');
      list.add('Special case: 0 has NO reciprocal; 1 has reciprocal 1; −1 has reciprocal −1');
      return list;
    }
    if (lower.contains('solve for x') || lower.contains('equation')) {
      list.add('If ax + b = c, then ax = c − b');
      list.add('x = (c − b) ÷ a');
      return list;
    }
    if (lower.contains('exponent') || lower.contains('power')) {
      list.add('Product Law: aᵐ × aⁿ = aᵐ⁺ⁿ');
      list.add('Quotient Law: aᵐ ÷ aⁿ = aᵐ⁻ⁿ');
      list.add('Power Law: (aᵐ)ⁿ = aᵐⁿ');
      list.add('Zero Exponent: a⁰ = 1 (for any a ≠ 0)');
      return list;
    }
    if (lower.contains('volume') || lower.contains('surface area')) {
      list.add('Cylinder Volume = πr²h | Total Surface Area = 2πr(r + h)');
      list.add('Cuboid Volume = l × b × h | Total Surface Area = 2(lb + bh + hl)');
      list.add('Cube Volume = a³ | Total Surface Area = 6a²');
      return list;
    }

    // Inherit chapter's authentic rules
    if (chapter != null && chapter.rules.isNotEmpty) {
      list.addAll(chapter.rules);
      return list;
    }

    list.add('Read the question and verify unit conversions before choosing your answer.');
    return list;
  }

  /// Generates exam pro-tips and common pitfalls
  String _generateProTip(String prompt, Activity activity, Chapter? chapter) {
    final lower = prompt.toLowerCase();

    if (lower.contains('quadrant') || lower.contains('coordinate')) {
      return '⚠️ Common Pitfall: Mixing up the order of coordinates! Always check x (horizontal first) then y (vertical second).';
    }
    if (lower.contains('reciprocal')) {
      return '💡 Exam Tip: Remember that the negative sign stays in the reciprocal! The reciprocal of −5/7 is −7/5, not +7/5.';
    }
    if (lower.contains('equation')) {
      return '💡 Verification Tip: Always substitute your answer back into the original equation to verify that LHS = RHS!';
    }
    if (lower.contains('volume') || lower.contains('area')) {
      return '⚠️ Watch Units: Ensure all dimensions (length, radius, height) are in the same unit (cm or m) before computing.';
    }
    if (lower.contains('roman numeral')) {
      return '💡 Roman Rule: Never repeat V, L, or D. Only I, X, C, and M can be repeated up to three times.';
    }

    return '💡 Exam Tip: Eliminate obviously incorrect options first, then double-check your arithmetic calculation!';
  }
}
