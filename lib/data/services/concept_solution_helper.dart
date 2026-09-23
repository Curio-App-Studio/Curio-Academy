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

  /// Synthesizes a pedagogical hint that guides without giving away the answer
  String _generateSmartHint(String prompt, Activity activity, Chapter? chapter) {
    final lower = prompt.toLowerCase();

    if (lower.contains('quadrant') || lower.contains('coordinate') || lower.contains('abscissa') || lower.contains('ordinate')) {
      return 'Recall the Cartesian plane sign convention:\n• Quadrant I: (+, +)\n• Quadrant II: (−, +)\n• Quadrant III: (−, −)\n• Quadrant IV: (+, −)\nLook closely at the signs of x and y!';
    }
    if (lower.contains('reciprocal') || lower.contains('multiplicative inverse')) {
      return 'The reciprocal (or multiplicative inverse) flips the numerator and denominator: for a fraction a/b, its reciprocal is b/a. What multiplied by the number equals 1?';
    }
    if (lower.contains('additive inverse')) {
      return 'The additive inverse is the number that adds up to 0 with the original number. Just change the sign (+ to − or − to +)!';
    }
    if (lower.contains('solve for x') || lower.contains('equation')) {
      return 'Use inverse operations to isolate x! Step 1: Move the constant term to the other side. Step 2: Divide both sides by the coefficient of x.';
    }
    if (lower.contains('perimeter')) {
      return 'Perimeter is the total boundary distance around a shape. Add all side lengths together (or use 2 × (length + breadth) for a rectangle).';
    }
    if (lower.contains('area')) {
      return 'Area measures the surface inside a 2D shape. For a rectangle, multiply length × breadth. For a square, multiply side × side.';
    }
    if (lower.contains('volume') || lower.contains('surface area') || lower.contains('cylinder') || lower.contains('cuboid')) {
      return 'Identify the 3D solid first. Cylinder Volume = πr²h. Cuboid Volume = l × b × h. Check the given units before calculating!';
    }
    if (lower.contains('exponent') || lower.contains('power') || lower.contains('law of exponents')) {
      return 'Recall the laws of exponents:\n• aᵐ × aⁿ = aᵐ⁺ⁿ\n• aᵐ ÷ aⁿ = aᵐ⁻ⁿ\n• (aᵐ)ⁿ = aᵐⁿ\n• a⁰ = 1';
    }
    if (lower.contains('square root') || lower.contains('cube root')) {
      return 'Think in reverse: What number multiplied by itself gives this target? (e.g., 5 × 5 = 25, so √25 = 5).';
    }
    if (lower.contains('roman numeral')) {
      return 'Remember the Roman symbols: I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000. When a smaller symbol appears before a larger one, subtract it!';
    }
    if (lower.contains('fraction') || lower.contains('equivalent')) {
      return 'To find equivalent fractions, multiply or divide both the numerator and denominator by the exact same non-zero number.';
    }
    if (lower.contains('time') || lower.contains('clock') || lower.contains('minute') || lower.contains('hour')) {
      return 'Remember that 1 hour = 60 minutes. Half past an hour means 30 minutes past, and quarter past means 15 minutes past.';
    }
    if (lower.contains('angle') || lower.contains('degree')) {
      return 'Acute angle < 90°, Right angle = 90°, Obtuse angle is between 90° and 180°, and Straight angle = 180°.';
    }

    // Fallback to chapter's authentic rules
    if (chapter != null && chapter.rules.isNotEmpty) {
      return 'Key Rule to Apply: ${chapter.rules.first}';
    }

    return 'Read the problem statement carefully, identify the given quantities, and look for key mathematical keywords.';
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
