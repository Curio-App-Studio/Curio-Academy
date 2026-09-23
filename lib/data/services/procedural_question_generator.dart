import 'dart:math';
import '../models/activity_model.dart';
import '../models/chapter_model.dart';
import '../models/grade_tier.dart';
import '../models/student_profile.dart';

/// Algorithmic / Procedural Question Generator Engine
/// Generates infinite mathematically sound learning activities dynamically for any class.
class ProceduralQuestionGenerator {
  static final ProceduralQuestionGenerator instance =
      ProceduralQuestionGenerator._();
  ProceduralQuestionGenerator._();

  final Random _rng = Random();

  /// Generates a dynamic Linear Equation activity for Class 6-8
  Activity generateLinearEquation({
    String targetGrade = 'Class 7',
    int difficulty = 2,
  }) {
    final a = _rng.nextInt(4) + 2; // 2 to 5
    final xRoot = _rng.nextInt(9) + 2; // 2 to 10
    final bSign = _rng.nextBool() ? 1 : -1;
    final b = (_rng.nextInt(8) + 1) * bSign; // non-zero -8 to +8
    final c = (a * xRoot) + b;

    final eqString = b >= 0 ? '${a}x + $b = $c' : '${a}x - ${b.abs()} = $c';
    final step1Result = c - b;

    final id = 'proc_eq_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_linear_equations',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.gridCalc,
      difficultyLevel: difficulty,
      pointsReward: 30 + (difficulty * 10),
      promptData: PromptData(
        text: 'Solve for x: $eqString',
        ttsFallback: 'Solve for x in the equation $eqString',
      ),
      interactionPayload: {
        'equation': eqString,
        'variable': 'x',
        'coefficient': a,
        'constant': b,
        'rhs': c,
        'xRoot': xRoot,
        'step1Result': '${a}x = $step1Result',
        'finalResult': 'x = $xRoot',
        'stepsRequired': [
          {
            'step': 1,
            'action': b >= 0 ? 'subtract_both_sides' : 'add_both_sides',
            'operand': b.abs(),
            'resultPrompt': '${a}x = $step1Result',
          },
          {
            'step': 2,
            'action': 'divide_both_sides',
            'operand': a,
            'resultPrompt': 'x = $xRoot',
          },
        ],
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: xRoot,
        hintTree: [
          StepHint(
            stepIndex: 1,
            hintText: b >= 0
                ? 'Subtract $b from both sides ($c - $b = $step1Result)'
                : 'Add ${b.abs()} to both sides ($c + ${b.abs()} = $step1Result)',
          ),
          StepHint(
            stepIndex: 2,
            hintText: 'Divide both sides by $a ($step1Result ÷ $a = $xRoot)',
          ),
        ],
      ),
    );
  }

  /// Generates a dynamic Equivalent Fractions activity for Class 4
  Activity generateEquivalentFractions({
    String targetGrade = 'Class 4',
    int difficulty = 2,
  }) {
    final baseFractions = [
      {'num': 1, 'den': 2, 'label': '1/2'},
      {'num': 1, 'den': 3, 'label': '1/3'},
      {'num': 2, 'den': 3, 'label': '2/3'},
      {'num': 3, 'den': 4, 'label': '3/4'},
      {'num': 1, 'den': 4, 'label': '1/4'},
    ];
    final base = baseFractions[_rng.nextInt(baseFractions.length)];
    final baseNum = base['num'] as int;
    final baseDen = base['den'] as int;
    final baseLabel = base['label'] as String;

    final multipliers = [2, 3, 4, 5, 6]..shuffle(_rng);
    final correctMultipliers = multipliers.take(3).toList();

    final draggableItems = <Map<String, dynamic>>[];
    for (int i = 0; i < correctMultipliers.length; i++) {
      final k = correctMultipliers[i];
      draggableItems.add({
        'itemId': 'eq_$i',
        'numerator': baseNum * k,
        'denominator': baseDen * k,
        'displayText': '${baseNum * k}/${baseDen * k}',
        'isEquivalent': true,
      });
    }

    for (int i = 0; i < 3; i++) {
      final distNum = _rng.nextInt(5) + 1;
      int distDen = _rng.nextInt(7) + 2;
      if (distNum * baseDen == distDen * baseNum) {
        distDen += 1;
      }
      draggableItems.add({
        'itemId': 'dist_$i',
        'numerator': distNum,
        'denominator': distDen,
        'displayText': '$distNum/$distDen',
        'isEquivalent': false,
      });
    }
    draggableItems.shuffle(_rng);

    final id = 'proc_frac_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_halves_quarters',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.dragDrop,
      difficultyLevel: difficulty,
      pointsReward: 35,
      promptData: PromptData(
        text: 'Drag all fractions equal to $baseLabel into the Cauldron! (Halves & Quarters)',
        ttsFallback: 'Drag all fractions equivalent to $baseLabel into the Cauldron!',
      ),
      interactionPayload: {
        'targetBase': baseLabel,
        'baseNum': baseNum,
        'baseDen': baseDen,
        'targetDenominatorRatio': baseNum / baseDen,
        'draggableItems': draggableItems,
      },
      validationRule: const ValidationRule(
        format: 'set_match',
        expectedAnswer: [],
      ),
    );
  }

  /// Generates a Perimeter problem (Fields & Fences - CBSE Class 4 Chapter 13)
  Activity generatePerimeterProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      final length = (_rng.nextInt(8) + 4) * 2; // 8 to 22 cm
      final width = (_rng.nextInt(5) + 3) * 2; // 6 to 14 cm
      final perimeter = 2 * (length + width);
      prompt = 'A rectangular garden has length $length cm and width $width cm. What is its perimeter?';
      answer = '$perimeter cm';
      options = ['$perimeter cm', '${length * width} cm', '${length + width} cm', '${perimeter + 4} cm']..shuffle(_rng);
      explanation = 'Perimeter = 2 × (Length + Width) = 2 × ($length + $width) = $perimeter cm.';
    } else if (v % 5 == 1) {
      final side = _rng.nextInt(15) + 5; // 5 to 19 meters
      final perim = 4 * side;
      prompt = 'A square playground has each side measuring $side meters. What is the total perimeter of the playground?';
      answer = '$perim meters';
      options = ['$perim meters', '${side * side} meters', '${2 * side} meters', '${perim + 8} meters']..shuffle(_rng);
      explanation = 'A square has 4 equal sides: Perimeter = 4 × Side = 4 × $side = $perim meters.';
    } else if (v % 5 == 2) {
      final perim = (_rng.nextInt(8) + 4) * 10; // 40 to 110 meters
      final costPerM = 5; // ₹5 per meter
      final totalCost = perim * costPerM;
      prompt = 'A rectangular farm has a boundary of $perim meters. At ₹$costPerM per meter, what is the cost of fencing it with wire?';
      answer = '₹$totalCost';
      options = ['₹$totalCost', '₹${totalCost + 50}', '₹${totalCost - 40}', '₹${perim * 2}']..shuffle(_rng);
      explanation = 'Cost = Boundary ($perim m) × Rate (₹$costPerM/m) = ₹$totalCost.';
    } else if (v % 5 == 3) {
      final a = _rng.nextInt(8) + 5;
      final b = _rng.nextInt(8) + 5;
      final c = _rng.nextInt(8) + 5;
      final p = a + b + c;
      prompt = 'A triangular park has sides of length $a m, $b m, and $c m. What length of wire is needed to fence around it once?';
      answer = '$p meters';
      options = ['$p meters', '${p + 4} meters', '${p - 3} meters', '${a * b} meters']..shuffle(_rng);
      explanation = 'Boundary of a triangle = Sum of all 3 sides = $a + $b + $c = $p meters.';
    } else {
      final l = _rng.nextInt(10) + 10;
      final w = _rng.nextInt(6) + 4;
      final perim = 2 * (l + w);
      prompt = 'Rahmat walks around a rectangular field of length $l m and width $w m. How far does he walk in 2 complete rounds?';
      final totalWalk = perim * 2;
      answer = '$totalWalk meters';
      options = ['$totalWalk meters', '$perim meters', '${totalWalk + 20} meters', '${l * w} meters']..shuffle(_rng);
      explanation = '1 round = 2 × ($l + $w) = $perim m. In 2 rounds = 2 × $perim = $totalWalk meters.';
    }

    final id = 'proc_perim_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_fields_and_fences',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Fields & Fences (Perimeter)',
        'visualIcon': '🏡',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Time Conversion problem (Tick-Tick-Tick - CBSE Class 4 Chapter 4)
  Activity generateTimeConversion({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      final hours = _rng.nextInt(4) + 2; // 2 to 5 hours
      final extraMinutes = _rng.nextInt(4) * 15; // 0, 15, 30, 45 mins
      final totalMinutes = (hours * 60) + extraMinutes;
      prompt = 'Convert $hours hours ${extraMinutes > 0 ? "and $extraMinutes minutes " : ""}into minutes.';
      answer = '$totalMinutes minutes';
      options = [
        '$totalMinutes minutes',
        '${totalMinutes + 30} minutes',
        '${totalMinutes - 20} minutes',
        '${hours * 100} minutes',
      ]..shuffle(_rng);
      explanation = '1 hour = 60 minutes. $hours hours = $hours × 60 = ${hours * 60} mins. Total = $totalMinutes minutes.';
    } else if (v % 5 == 1) {
      final pmHour = _rng.nextInt(9) + 1; // 1 to 9 PM
      final format24 = 12 + pmHour;
      prompt = 'What is $pmHour:30 PM in 24-hour railway clock time?';
      answer = '$format24:30';
      options = [
        '$format24:30',
        '0$pmHour:30',
        '${format24 + 1}:30',
        '${pmHour + 10}:30',
      ]..shuffle(_rng);
      explanation = 'For PM times, add 12 hours: $pmHour + 12 = $format24. Time is $format24:30.';
    } else if (v % 5 == 2) {
      final from = _rng.nextInt(5) + 1; // 1 to 5
      final to = from + _rng.nextInt(4) + 2; // e.g. 2 to 6
      final diffMins = (to - from) * 5;
      prompt = 'How many minutes have passed when the minute hand moves on a clock face from digit $from to digit $to?';
      answer = '$diffMins minutes';
      options = [
        '$diffMins minutes',
        '${diffMins + 10} minutes',
        '${diffMins - 5} minutes',
        '${(to - from)} minutes',
      ]..shuffle(_rng);
      explanation = 'Each number mark on a clock represents 5 minutes. From $from to $to is (${to - from}) steps × 5 = $diffMins minutes.';
    } else if (v % 5 == 3) {
      final startH = _rng.nextInt(3) + 2; // 2 to 4 PM
      final durH = _rng.nextInt(2) + 2; // 2 or 3 hours
      final endH = startH + durH;
      prompt = 'A school sports day starts at $startH:00 PM and lasts for $durH hours. At what time does it finish?';
      answer = '$endH:00 PM';
      options = [
        '$endH:00 PM',
        '${endH + 1}:00 PM',
        '${endH - 1}:00 PM',
        '${endH + 2}:00 PM',
      ]..shuffle(_rng);
      explanation = '$startH:00 PM + $durH hours = $endH:00 PM.';
    } else {
      final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
      final startMonthIdx = _rng.nextInt(6); // Jan to June
      final validMonths = 6;
      final expiryMonthIdx = startMonthIdx + validMonths;
      prompt = 'A medicine bottle is manufactured in ${months[startMonthIdx]} 2026 with label "Best before 6 months". In which month does it expire?';
      answer = '${months[expiryMonthIdx]} 2026';
      options = [
        '${months[expiryMonthIdx]} 2026',
        '${months[(expiryMonthIdx + 2) % 12]} 2026',
        '${months[(expiryMonthIdx - 2) % 12]} 2026',
        '${months[startMonthIdx]} 2027',
      ]..shuffle(_rng);
      explanation = 'Adding 6 months to ${months[startMonthIdx]} gives ${months[expiryMonthIdx]} 2026.';
    }

    final id = 'proc_time_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_tick_tick_tick',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Tick-Tick-Tick (Clocks & Time)',
        'visualIcon': '⏰',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Capacity / Volume problem (Jugs and Mugs - CBSE Class 4 Chapter 7)
  Activity generateCapacityProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      final liters = _rng.nextInt(5) + 2; // 2 to 6 L
      final ml = (_rng.nextInt(7) + 1) * 100; // 100 to 700 mL
      final totalMl = (liters * 1000) + ml;
      prompt = 'A bucket contains $liters L and $ml mL of water. How many milliliters is that in total?';
      answer = '$totalMl mL';
      options = [
        '$totalMl mL',
        '${liters * 100 + ml} mL',
        '${totalMl + 200} mL',
        '${totalMl - 500} mL',
      ]..shuffle(_rng);
      explanation = '1 Liter = 1,000 mL. So $liters L = ${liters * 1000} mL. Adding $ml mL gives $totalMl mL.';
    } else if (v % 5 == 1) {
      final glassSize = [100, 200, 250, 500][_rng.nextInt(4)];
      final glasses = 1000 ~/ glassSize;
      prompt = 'How many $glassSize mL glasses of orange juice are needed to fill a 1-liter jug completely?';
      answer = '$glasses glasses';
      options = [
        '$glasses glasses',
        '${glasses + 2} glasses',
        '${glasses - 1} glasses',
        '${glasses * 2} glasses',
      ]..shuffle(_rng);
      explanation = '1 Liter = 1,000 mL. 1,000 mL ÷ $glassSize mL = $glasses glasses.';
    } else if (v % 5 == 2) {
      final remaining = (_rng.nextInt(6) + 2) * 100; // 200 to 700 mL
      final drank = 1000 - remaining;
      prompt = 'A full 1-liter thermos bottle has $remaining mL of milk left after breakfast. How many milliliters were consumed?';
      answer = '$drank mL';
      options = [
        '$drank mL',
        '${drank + 150} mL',
        '${drank - 100} mL',
        '$remaining mL',
      ]..shuffle(_rng);
      explanation = '1 Liter = 1,000 mL. Consumed = 1,000 mL - $remaining mL = $drank mL.';
    } else if (v % 5 == 3) {
      final servings = _rng.nextInt(5) + 4; // 4 to 8 servings
      final perServing = 250; // mL
      final totalMl = servings * perServing;
      final liters = totalMl / 1000;
      prompt = 'To prepare sweet kheer, each bowl needs $perServing mL of milk. How many liters of milk are required for $servings bowls?';
      answer = '$liters Liters';
      options = [
        '$liters Liters',
        '${liters + 1} Liters',
        '${liters - 0.5} Liters',
        '$servings Liters',
      ]..shuffle(_rng);
      explanation = '$servings bowls × $perServing mL = $totalMl mL = $liters Liters.';
    } else {
      final p1 = (_rng.nextInt(4) + 2) * 100; // 200 to 500 mL
      final p2 = (_rng.nextInt(4) + 3) * 100; // 300 to 600 mL
      final total = p1 + p2;
      prompt = 'A watering can has $p1 mL and a sprayer has $p2 mL of liquid plant food. What is the combined capacity?';
      answer = '$total mL';
      options = [
        '$total mL',
        '${total + 200} mL',
        '${total - 100} mL',
        '${p1 + 500} mL',
      ]..shuffle(_rng);
      explanation = '$p1 mL + $p2 mL = $total mL.';
    }

    final id = 'proc_cap_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_jugs_and_mugs',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Jugs & Mugs (Capacity in Liters/mL)',
        'visualIcon': '🫗',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Division & Shares problem (Tables & Shares - CBSE Class 4 Chapter 11)
  Activity generateDivisionProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      final divisor = _rng.nextInt(5) + 3; // 3 to 7
      final quotient = _rng.nextInt(8) + 4; // 4 to 11
      final total = divisor * quotient;
      prompt = 'A teacher has $total chocolates and distributes them equally among $divisor students. How many chocolates does each student get?';
      answer = '$quotient chocolates';
      options = [
        '$quotient chocolates',
        '${quotient + 2} chocolates',
        '${quotient - 1} chocolates',
        '${quotient + 4} chocolates',
      ]..shuffle(_rng);
      explanation = '$total ÷ $divisor = $quotient. Each student receives $quotient chocolates.';
    } else if (v % 5 == 1) {
      final shelves = _rng.nextInt(4) + 4; // 4 to 7 shelves
      final perShelf = _rng.nextInt(5) + 6; // 6 to 10 books
      final totalBooks = shelves * perShelf;
      prompt = 'A librarian has $totalBooks books to be arranged equally on $shelves wooden shelves. How many books will be placed on each shelf?';
      answer = '$perShelf books';
      options = [
        '$perShelf books',
        '${perShelf + 2} books',
        '${perShelf - 1} books',
        '$shelves books',
      ]..shuffle(_rng);
      explanation = '$totalBooks books ÷ $shelves shelves = $perShelf books per shelf.';
    } else if (v % 5 == 2) {
      final leap = 3;
      final count = _rng.nextInt(6) + 5; // 5 to 10 leaps
      final target = leap * count;
      prompt = 'A frog starts at 0 and leaps $leap steps in every jump. How many jumps are needed to land exactly on step $target?';
      answer = '$count jumps';
      options = [
        '$count jumps',
        '${count + 2} jumps',
        '${count - 1} jumps',
        '${count * 2} jumps',
      ]..shuffle(_rng);
      explanation = '$target steps ÷ $leap steps per jump = $count jumps.';
    } else if (v % 5 == 3) {
      final friends = 4;
      final totalMoney = (_rng.nextInt(8) + 3) * 20; // ₹60 to ₹200
      final each = totalMoney ~/ friends;
      prompt = 'Four friends share a restaurant food bill of ₹$totalMoney equally. How much does each friend have to contribute?';
      answer = '₹$each';
      options = [
        '₹$each',
        '₹${each + 10}',
        '₹${each - 5}',
        '₹${totalMoney ~/ 2}',
      ]..shuffle(_rng);
      explanation = '₹$totalMoney ÷ $friends friends = ₹$each each.';
    } else {
      final rows = _rng.nextInt(4) + 4; // 4 to 7 rows
      final perRow = _rng.nextInt(5) + 5; // 5 to 9 trees
      final total = rows * perRow;
      prompt = 'A gardener planted $total saplings in $rows equal rows. How many saplings are there in each row?';
      answer = '$perRow saplings';
      options = [
        '$perRow saplings',
        '${perRow + 3} saplings',
        '${perRow - 2} saplings',
        '$rows saplings',
      ]..shuffle(_rng);
      explanation = '$total saplings ÷ $rows rows = $perRow saplings per row.';
    }

    final id = 'proc_div_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_tables_and_shares',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Tables & Shares (Division Word Problem)',
        'visualIcon': '🍫',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }


  /// Generates an Integers problem (Class 6 & 7)
  Activity generateIntegerProblem({String targetGrade = 'Class 7'}) {
    final a = _rng.nextInt(9) + 2; // 2 to 10
    final b = _rng.nextInt(9) + 2; // 2 to 10
    final mode = _rng.nextInt(3); // 0: (-a)*(-b), 1: (-a)*(+b), 2: a - (-b)

    final String prompt;
    final int ans;
    final String explanation;

    if (mode == 0) {
      prompt = 'Calculate the product: (-$a) × (-$b) = ?';
      ans = a * b;
      explanation = 'Both signs are negative. Negative times negative equals positive: ($a × $b = +$ans).';
    } else if (mode == 1) {
      prompt = 'Calculate the product: (-$a) × (+$b) = ?';
      ans = -(a * b);
      explanation = 'Opposite signs: Negative times positive equals negative: -($a × $b) = $ans.';
    } else {
      prompt = 'Solve the integer subtraction: $a - (-$b) = ?';
      ans = a + b;
      explanation = 'Subtracting a negative number turns into addition: $a - (-$b) = $a + $b = $ans.';
    }

    final options = [
      '$ans',
      '${-ans}',
      '${ans + 2}',
      '${ans - 3}',
    ]..shuffle(_rng);

    final id = 'proc_int_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_integers',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Integers (Sign Operations)',
        'visualIcon': '➕➖',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: '$ans',
        hintTree: const [
          StepHint(stepIndex: 1, hintText: 'Remember the Golden Rule: Like signs make positive (+), unlike signs make negative (-)!'),
        ],
      ),
    );
  }

  /// Generates an Exponents & Powers problem (Class 7 & 8)
  Activity generateExponentProblem({String targetGrade = 'Class 7'}) {
    final base = _rng.nextInt(3) + 2; // 2, 3, or 4
    final m = _rng.nextInt(3) + 2; // 2 to 4
    final n = _rng.nextInt(3) + 1; // 1 to 3
    final isProductRule = _rng.nextBool();

    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (isProductRule) {
      final sumExp = m + n;
      prompt = 'Simplify using laws of exponents: $base^$m × $base^$n = ?';
      answer = '$base^$sumExp';
      options = [
        '$base^$sumExp',
        '$base^${m * n}',
        '${base * base}^$sumExp',
        '$base^${sumExp + 1}',
      ]..shuffle(_rng);
      explanation = 'Law of exponents: aᵐ × aⁿ = aᵐ⁺ⁿ. Here bases are same ($base), so add exponents: $m + $n = $sumExp. Result = $base^$sumExp.';
    } else {
      final diffExp = m;
      final total = m + n;
      prompt = 'Simplify using laws of exponents: $base^$total ÷ $base^$n = ?';
      answer = '$base^$diffExp';
      options = [
        '$base^$diffExp',
        '$base^$total',
        '$base^${total * n}',
        '$base^1',
      ]..shuffle(_rng);
      explanation = 'Law of exponents: aᵐ ÷ aⁿ = aᵐ⁻ⁿ. Subtract powers: $total - $n = $diffExp. Result = $base^$diffExp.';
    }

    final id = 'proc_exp_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_exponents',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Exponents & Powers (Laws of Indices)',
        'visualIcon': '⚡',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: answer,
        hintTree: const [
          StepHint(stepIndex: 1, hintText: 'When multiplying same base, ADD the powers. When dividing, SUBTRACT the powers!'),
        ],
      ),
    );
  }

  /// Generates a Squares & Square Roots problem (Class 8)
  Activity generateSquareRootProblem({String targetGrade = 'Class 8'}) {
    final roots = [6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 20, 25];
    final root = roots[_rng.nextInt(roots.length)];
    final square = root * root;

    final prompt = 'What is the square root of $square (√$square)?';
    final answer = '$root';
    final options = [
      '$root',
      '${root - 1}',
      '${root + 2}',
      '${root * 2}',
    ]..shuffle(_rng);

    final id = 'proc_sqrt_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_squares_and_roots',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Squares and Square Roots',
        'visualIcon': '⬛',
        'options': options,
        'explanation': 'Since $root × $root = $square, the square root √$square is $root.',
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: answer,
        hintTree: [
          StepHint(stepIndex: 1, hintText: 'Find the number that gives $square when multiplied by itself.'),
        ],
      ),
    );
  }

  /// Generates an Algebraic Expressions problem (Class 6 & 7)
  Activity generateAlgebraicExpressionProblem({String targetGrade = 'Class 7'}) {
    final a = _rng.nextInt(5) + 2;
    final b = _rng.nextInt(6) + 1;
    final xVal = _rng.nextInt(4) + 2;
    final val = (a * xVal) + b;

    final prompt = 'Evaluate the value of the expression $a' 'x + $b when x = $xVal:';
    final answer = '$val';
    final options = [
      '$val',
      '${val + 3}',
      '${val - 2}',
      '${a * xVal}',
    ]..shuffle(_rng);

    final id = 'proc_alg_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_algebraic_expressions',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Algebraic Expressions (Substitution)',
        'visualIcon': '🧮',
        'options': options,
        'explanation': 'Substitute x = $xVal into $a' 'x + $b: $a × $xVal + $b = ${a * xVal} + $b = $val.',
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: answer,
        hintTree: [
          StepHint(stepIndex: 1, hintText: 'Multiply $a with $xVal first, then add $b!'),
        ],
      ),
    );
  }

  /// Generates a dynamic Coordinate Graphs & Linear Graphs problem (Class 8 Ch 15 / ICSE)
  Activity generateCoordinateGraphsProblem({String targetGrade = 'Class 8'}) {
    final types = [
      {
        'prompt': 'What are the coordinates of the origin where the X-axis and Y-axis intersect?',
        'answer': '(0, 0)',
        'options': ['(0, 0)', '(1, 1)', '(0, 1)', '(1, 0)'],
        'explanation': 'The origin is the starting reference point on the Cartesian plane where both x and y are 0, written as (0, 0).',
      },
      {
        'prompt': 'In the ordered coordinate pair (4, 7), what is the X-coordinate (abscissa)?',
        'answer': '4',
        'options': ['4', '7', '11', '(4, 7)'],
        'explanation': 'In an ordered pair (x, y), the first number is the x-coordinate (abscissa) and the second is the y-coordinate (ordinate). So x = 4.',
      },
      {
        'prompt': 'A point has coordinates (0, 5). Where does this point lie on the Cartesian plane?',
        'answer': 'On the Y-axis',
        'options': ['On the Y-axis', 'On the X-axis', 'At the Origin', 'In Quadrant IV'],
        'explanation': 'When the x-coordinate is 0 and y is non-zero, the point lies directly on the vertical Y-axis.',
      },
      {
        'prompt': 'A point has coordinates (6, 0). Where does this point lie on the Cartesian plane?',
        'answer': 'On the X-axis',
        'options': ['On the X-axis', 'On the Y-axis', 'At the Origin', 'In Quadrant II'],
        'explanation': 'When the y-coordinate is 0 and x is non-zero, the point lies directly on the horizontal X-axis.',
      },
      {
        'prompt': 'In which quadrant do points with a negative x and positive y coordinate, like (-3, 5), lie?',
        'answer': 'Quadrant II',
        'options': ['Quadrant II', 'Quadrant I', 'Quadrant III', 'Quadrant IV'],
        'explanation': 'Quadrant I is (+, +), Quadrant II is (-, +), Quadrant III is (-, -), and Quadrant IV is (+, -).',
      },
      {
        'prompt': 'In a distance-time graph, what does a straight flat horizontal line represent?',
        'answer': 'The object is at rest (stationary)',
        'options': ['The object is at rest (stationary)', 'Constant speed acceleration', 'Infinite speed', 'Moving backward'],
        'explanation': 'A horizontal line means distance does not change as time passes, indicating the object is stationary.',
      },
    ];

    final q = types[_rng.nextInt(types.length)];
    final id = 'proc_graph_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_introduction_to_graphs',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: q['prompt'] as String,
        ttsFallback: q['prompt'] as String,
      ),
      interactionPayload: {
        'topicTitle': 'Introduction to Graphs & Coordinates',
        'visualIcon': '📈',
        'options': List<String>.from(q['options'] as List)..shuffle(_rng),
        'explanation': q['explanation'] as String,
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: q['answer'] as String,
      ),
    );
  }

  /// Generates a dynamic Middle School Mensuration problem (Class 8 / Class 7)
  Activity generateMiddleMensurationProblem({String targetGrade = 'Class 8'}) {
    final v = _rng.nextInt(4);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    if (v == 0) {
      final side = _rng.nextInt(5) + 3; // 3 to 7
      final volume = side * side * side;
      prompt = 'Find the volume of a cube having an edge length of $side cm:';
      answer = '$volume cm³';
      options = ['$volume cm³', '${volume + 12} cm³', '${side * side * 6} cm³', '${side * 4} cm³']..shuffle(_rng);
      explanation = 'Volume of a cube = Side³ = $side × $side × $side = $volume cm³.';
    } else if (v == 1) {
      final side = _rng.nextInt(4) + 2; // 2 to 5
      final totalSurfaceArea = 6 * side * side;
      prompt = 'What is the Total Surface Area (TSA) of a cube with side $side cm?';
      answer = '$totalSurfaceArea cm²';
      options = ['$totalSurfaceArea cm²', '${4 * side * side} cm²', '${side * side * side} cm²', '${6 * side} cm²']..shuffle(_rng);
      explanation = 'Total Surface Area of a cube has 6 square faces = 6 × Side² = 6 × ${side * side} = $totalSurfaceArea cm².';
    } else if (v == 2) {
      final h = _rng.nextInt(6) + 5; // 5 to 10 cm
      final volume = 154 * h;
      prompt = 'Find the volume of a right circular cylinder with radius 7 cm and height $h cm (use π = 22/7):';
      answer = '$volume cm³';
      options = ['$volume cm³', '${volume + 77} cm³', '${volume - 154} cm³', '${2 * 22 * h} cm³']..shuffle(_rng);
      explanation = 'Volume of cylinder = π × r² × h = (22/7) × 7 × 7 × $h = 154 × $h = $volume cm³.';
    } else {
      final l = _rng.nextInt(4) + 4; // 4 to 7
      final w = _rng.nextInt(3) + 2; // 2 to 4
      final h = _rng.nextInt(3) + 2; // 2 to 4
      final vol = l * w * h;
      prompt = 'Find the volume of a rectangular cuboid measuring $l cm × $w cm × $h cm:';
      answer = '$vol cm³';
      options = ['$vol cm³', '${vol + 10} cm³', '${2 * (l * w + w * h + l * h)} cm³', '${l + w + h} cm³']..shuffle(_rng);
      explanation = 'Volume of cuboid = Length × Width × Height = $l × $w × $h = $vol cm³.';
    }

    final id = 'proc_mens8_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_mensuration_class8',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Mensuration (Surface Area & Volume)',
        'visualIcon': '📦',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Rational Numbers problem (Class 8 / Class 7)
  Activity generateRationalNumbersProblem({String targetGrade = 'Class 8'}) {
    final types = [
      {
        'prompt': 'Which number is the Additive Identity for rational numbers?',
        'answer': '0',
        'options': ['0', '1', '-1', 'Any fraction'],
        'explanation': 'Adding 0 to any rational number leaves it unchanged: a/b + 0 = a/b. So 0 is the additive identity.',
      },
      {
        'prompt': 'Which number is the Multiplicative Identity for rational numbers?',
        'answer': '1',
        'options': ['1', '0', '-1', '2'],
        'explanation': 'Multiplying any rational number by 1 leaves it unchanged: (a/b) × 1 = a/b. So 1 is the multiplicative identity.',
      },
      {
        'prompt': 'What is the reciprocal (multiplicative inverse) of -5/8?',
        'answer': '-8/5',
        'options': ['-8/5', '5/8', '8/5', '-5/8'],
        'explanation': 'The reciprocal of a/b is b/a. The reciprocal of -5/8 is -8/5, because (-5/8) × (-8/5) = 1.',
      },
      {
        'prompt': 'Which rational number does NOT have a reciprocal?',
        'answer': '0',
        'options': ['0', '1', '-1', '1/2'],
        'explanation': 'Division by 0 is undefined, so 0 has no reciprocal (1/0 does not exist).',
      },
    ];

    final q = types[_rng.nextInt(types.length)];
    final id = 'proc_rat_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_rational_numbers',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: q['prompt'] as String, ttsFallback: q['prompt'] as String),
      interactionPayload: {
        'topicTitle': 'Rational Numbers & Properties',
        'visualIcon': '🔢',
        'options': List<String>.from(q['options'] as List)..shuffle(_rng),
        'explanation': q['explanation'] as String,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: q['answer'] as String),
    );
  }

  /// Generates an Angles & Shapes problem (Class 5)
  Activity generateAnglesProblem({String targetGrade = 'Class 5'}) {
    final angleTypes = [
      {'name': 'Right angle', 'desc': 'An exact 90° angle looking like an L-corner', 'eg': '90°'},
      {'name': 'Acute angle', 'desc': 'An angle less than 90° (sharp)', 'eg': '45°'},
      {'name': 'Obtuse angle', 'desc': 'An angle greater than 90° and less than 180°', 'eg': '130°'},
    ];
    final selected = angleTypes[_rng.nextInt(angleTypes.length)];
    final prompt = 'What type of angle is an angle measuring ${selected['eg']}?';
    final answer = selected['name'] as String;
    final options = ['Right angle', 'Acute angle', 'Obtuse angle', 'Straight angle']..shuffle(_rng);

    final id = 'proc_ang_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_shapes_and_angles',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Shapes & Angles',
        'visualIcon': '📐',
        'options': options,
        'explanation': '${selected['name']} is correct: ${selected['desc']}.',
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: answer,
        hintTree: const [
          StepHint(stepIndex: 1, hintText: 'Remember: Less than 90° = Acute, Exactly 90° = Right, Greater than 90° = Obtuse!'),
        ],
      ),
    );
  }

  /// Generates a Place Value problem (Class 2 & 3)
  Activity generatePlaceValueProblem({String targetGrade = 'Class 2'}) {
    final tens = _rng.nextInt(7) + 2; // 2 to 8
    final ones = _rng.nextInt(9) + 1; // 1 to 9
    final number = (tens * 10) + ones;

    final prompt = 'In the number $number, how many tens and how many ones are there?';
    final answer = '$tens tens and $ones ones';
    final options = [
      '$tens tens and $ones ones',
      '$ones tens and $tens ones',
      '${tens + 1} tens and $ones ones',
      '$tens tens and ${ones + 1} ones',
    ]..shuffle(_rng);

    final id = 'proc_pv_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_tens_and_ones',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 25,
      promptData: PromptData(
        text: prompt,
        ttsFallback: prompt,
      ),
      interactionPayload: {
        'topicTitle': 'Tens and Ones (Place Value)',
        'visualIcon': '🔟',
        'options': options,
        'explanation': '$number has $tens in the tens position (${tens * 10}) and $ones in the ones position ($ones).',
      },
      validationRule: ValidationRule(
        format: 'exact',
        expectedAnswer: answer,
        hintTree: const [
          StepHint(stepIndex: 1, hintText: 'The left digit is the Tens and the right digit is the Ones!'),
        ],
      ),
    );
  }

  /// Generates Large Numbers & Place Value problems (Indian/International systems, expanded form, place/face value)
  Activity generateLargeNumbersProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(7);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 7) {
      case 0:
        // Place value of a digit
        prompt = 'In the number 5,74,320, what is the PLACE VALUE of the digit 7?';
        answer = '70,000';
        options = ['70,000', '7,000', '700', '7']..shuffle(_rng);
        explanation = '7 is in the Ten-Thousands place, so its place value is 7 × 10,000 = 70,000.';
        break;

      case 1:
        // Indian system comma placement
        prompt = 'Which option shows the number 4582910 written with proper Indian periods and commas?';
        answer = '45,82,910';
        options = ['45,82,910', '4,582,910', '458,291,0', '4,5,8,2,9,1,0']..shuffle(_rng);
        explanation = 'In the Indian system, commas are placed after 3 digits from the right, then after every 2 digits (3, 2, 2): 45,82,910.';
        break;

      case 2:
        // Successor & Predecessor
        prompt = 'What is the SUCCESSOR of 99,999?';
        answer = '1,00,000 (One Lakh)';
        options = ['1,00,000 (One Lakh)', '99,998', '1,00,001', '10,00,000']..shuffle(_rng);
        explanation = 'Successor means adding 1: 99,999 + 1 = 1,00,000 (One Lakh).';
        break;

      case 3:
        // International system comma placement
        prompt = 'Which option shows the number 7349512 written with proper International periods and commas?';
        answer = '7,349,512';
        options = ['7,349,512', '73,49,512', '734,95,12', '7,34,95,12']..shuffle(_rng);
        explanation = 'In the International system, periods are grouped by 3s: Millions, Thousands, Ones (7,349,512).';
        break;

      case 4:
        // System conversion: Lakhs to Millions
        prompt = 'How many Lakhs in the Indian system are equal to 1 Million in the International system?';
        answer = '10 Lakhs';
        options = ['10 Lakhs', '1 Lakh', '100 Lakhs', '1 Crore']..shuffle(_rng);
        explanation = '1 Million = 1,000,000 = 10,00,000 (10 Lakhs).';
        break;

      case 5:
        // Expanded form to standard numeral
        prompt = 'What is the standard numeral for: 4,00,000 + 50,000 + 3,000 + 200 + 8?';
        answer = '4,53,208';
        options = ['4,53,208', '4,53,280', '45,328', '4,05,328']..shuffle(_rng);
        explanation = 'Lakhs: 4, Ten-Th: 5, Th: 3, Hundreds: 2, Tens: 0, Ones: 8 = 4,53,208.';
        break;

      default:
        // Face value vs place value
        prompt = 'What is the FACE VALUE of the digit 9 in the number 8,92,415?';
        answer = '9';
        options = ['9', '90,000', '9,000', '900']..shuffle(_rng);
        explanation = 'The face value of any digit is always the digit itself (9), regardless of the position it occupies.';
        break;
    }

    final id = 'proc_large_num_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_large_numbers',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Large Numbers & Place Value',
        'visualIcon': '🔢',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Roman Numerals problems (conversion, interpretation, and validity rules)
  Activity generateRomanNumeralsProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 6) {
      case 0:
        // 49 in Roman numerals
        prompt = 'Write the number 49 in Roman numerals:';
        answer = 'XLIX';
        options = ['XLIX', 'IL', 'XXXXIX', 'LIX']..shuffle(_rng);
        explanation = '49 = 40 + 9 = XL + IX = XLIX (remember: I can only be subtracted from V and X, so IL is invalid!).';
        break;

      case 1:
        // Convert Roman to Arabic: XCIV
        prompt = 'What is the Hindu-Arabic value of the Roman numeral XCIV?';
        answer = '94';
        options = ['94', '114', '84', '96']..shuffle(_rng);
        explanation = 'XC represents 90 (100 - 10) and IV represents 4 (5 - 1). 90 + 4 = 94.';
        break;

      case 2:
        // Invalid Roman numeral rule
        prompt = 'Which of the following Roman numerals is INVALID according to standard Roman rules?';
        answer = 'IL';
        options = ['IL', 'XL', 'IX', 'XC']..shuffle(_rng);
        explanation = 'IL is invalid because "I" can only be subtracted from "V" and "X". 49 must be written as XLIX.';
        break;

      case 3:
        // Symbol meaning: L = 50
        prompt = 'Which Roman symbol represents the number 50?';
        answer = 'L';
        options = ['L', 'C', 'D', 'V']..shuffle(_rng);
        explanation = 'In Roman numerals: I=1, V=5, X=10, L=50, C=100, D=500, M=1000.';
        break;

      case 4:
        // Convert 74 to Roman numerals
        prompt = 'Write the number 74 in Roman numerals:';
        answer = 'LXXIV';
        options = ['LXXIV', 'LXXVI', 'LXXIVV', 'LXXIIII']..shuffle(_rng);
        explanation = '74 = 50 + 20 + 4 = L + XX + IV = LXXIV.';
        break;

      default:
        // Roman addition: XXV + XIV
        prompt = 'Evaluate the Roman expression: XXV + XIV = ?';
        answer = 'XXXIX (39)';
        options = ['XXXIX (39)', 'XXXXIX', 'XLIX (49)', 'XXIX (29)']..shuffle(_rng);
        explanation = 'XXV = 25 and XIV = 14. 25 + 14 = 39, which in Roman numerals is XXXIX (30 + 9).';
        break;
    }

    final id = 'proc_roman_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_roman_numerals',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Roman Numerals',
        'visualIcon': '🏛️',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Factors & Multiples problems (Prime, Composite, HCF, LCM)
  Activity generateFactorsAndMultiplesProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 5) {
      case 0:
        prompt = 'Which of the following numbers is a PRIME number?';
        answer = '17';
        options = ['17', '15', '21', '27']..shuffle(_rng);
        explanation = '17 has only two factors: 1 and itself (17). 15, 21, and 27 are composite.';
        break;
      case 1:
        prompt = 'Which of the following numbers is a COMPOSITE number?';
        answer = '25';
        options = ['25', '13', '19', '23']..shuffle(_rng);
        explanation = '25 has factors 1, 5, and 25, making it a composite number.';
        break;
      case 2:
        prompt = 'What is the Highest Common Factor (HCF) of 12 and 18?';
        answer = '6';
        options = ['6', '3', '2', '12']..shuffle(_rng);
        explanation = 'Factors of 12: {1, 2, 3, 4, 6, 12}. Factors of 18: {1, 2, 3, 6, 9, 18}. The highest common factor is 6.';
        break;
      case 3:
        prompt = 'What is the Least Common Multiple (LCM) of 4 and 6?';
        answer = '12';
        options = ['12', '24', '8', '2']..shuffle(_rng);
        explanation = 'Multiples of 4: 4, 8, 12, 16... Multiples of 6: 6, 12, 18... The smallest common multiple is 12.';
        break;
      default:
        prompt = 'Which of the following is NOT a factor of 36?';
        answer = '8';
        options = ['8', '4', '6', '9']..shuffle(_rng);
        explanation = '36 ÷ 8 = 4 with remainder 4, so 8 is not an exact factor of 36.';
        break;
    }

    final id = 'proc_factors_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_factors_multiples',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Factors and Multiples',
        'visualIcon': '🔢',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Estimation & Rounding off problems
  Activity generateEstimationProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(3);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 3) {
      case 0:
        prompt = 'Round off the number 476 to the nearest TEN:';
        answer = '480';
        options = ['480', '470', '500', '475']..shuffle(_rng);
        explanation = 'The ones digit is 6 (which is >= 5), so round up: 476 rounds to 480.';
        break;
      case 1:
        prompt = 'Round off the number 1,348 to the nearest HUNDRED:';
        answer = '1,300';
        options = ['1,300', '1,400', '1,350', '1,000']..shuffle(_rng);
        explanation = 'The tens digit is 4 (which is < 5), so round down: 1,348 rounds to 1,300.';
        break;
      default:
        prompt = 'Estimate the sum of 38 + 53 by rounding each number to the nearest 10:';
        answer = '90 (40 + 50)';
        options = ['90 (40 + 50)', '100', '80', '95']..shuffle(_rng);
        explanation = '38 rounds to 40, and 53 rounds to 50. Estimated sum = 40 + 50 = 90.';
        break;
    }

    final id = 'proc_estimate_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_estimation',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Estimation',
        'visualIcon': '🎯',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Money & Currency problems
  Activity generateMoneyProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(3);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 3) {
      case 0:
        prompt = 'Convert 750 paise into Rupees:';
        answer = '₹7.50';
        options = ['₹7.50', '₹75.0', '₹0.75', '₹750']..shuffle(_rng);
        explanation = '1 Rupee = 100 paise. 750 ÷ 100 = ₹7.50.';
        break;
      case 1:
        prompt = 'A notebook costs ₹25. What is the total cost of 6 notebooks?';
        answer = '₹150';
        options = ['₹150', '₹125', '₹175', '₹100']..shuffle(_rng);
        explanation = 'Total cost = 6 × ₹25 = ₹150.';
        break;
      default:
        prompt = 'You buy a drawing book for ₹65 and pay with a ₹100 note. What change should you get back?';
        answer = '₹35';
        options = ['₹35', '₹45', '₹25', '₹15']..shuffle(_rng);
        explanation = 'Change = ₹100 - ₹65 = ₹35.';
        break;
    }

    final id = 'proc_money_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_money',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Money & Calculations',
        'visualIcon': '💰',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Geometry & Angles basics (Line, Ray, Segment, Angles)
  Activity generateGeometryBasicsProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    switch (v % 5) {
      case 0:
        prompt = 'A straight line path that has ONE fixed start point and extends endlessly in one direction is called a...';
        answer = 'Ray ➔';
        options = ['Ray ➔', 'Line Segment ⎯', 'Line ⟷', 'Angle ∠']..shuffle(_rng);
        explanation = 'A ray has 1 fixed endpoint and continues infinitely in the other direction (like a ray from a torch or the sun).';
        break;
      case 1:
        prompt = 'A straight part of a line having TWO definite end points is called a...';
        answer = 'Line Segment ⎯';
        options = ['Line Segment ⎯', 'Ray ➔', 'Line ⟷', 'Curve 〰️']..shuffle(_rng);
        explanation = 'A line segment has 2 fixed end points and its length can be measured.';
        break;
      case 2:
        prompt = 'An angle that measures exactly 90° (forming a square corner) is called a...';
        answer = 'Right Angle ∟';
        options = ['Right Angle ∟', 'Acute Angle ∠', 'Obtuse Angle', 'Straight Angle']..shuffle(_rng);
        explanation = 'A 90° angle forms an exact perpendicular corner and is called a Right Angle.';
        break;
      case 3:
        prompt = 'An angle that is SMALLER than 90° is called an...';
        answer = 'Acute Angle ∠';
        options = ['Acute Angle ∠', 'Obtuse Angle', 'Right Angle ∟', 'Straight Angle']..shuffle(_rng);
        explanation = 'Any angle greater than 0° and less than 90° is an Acute Angle.';
        break;
      default:
        prompt = 'An angle that measures GREATER than 90° but LESS than 180° is called an...';
        answer = 'Obtuse Angle';
        options = ['Obtuse Angle', 'Acute Angle ∠', 'Right Angle ∟', 'Reflex Angle']..shuffle(_rng);
        explanation = 'Angles between 90° and 180° are called Obtuse Angles.';
        break;
    }

    final id = 'proc_geom_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_geometry',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Basic Geometry',
        'visualIcon': '📐',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Building with Bricks problem (Ch 1 - Class 4)
  Activity generateBricksProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 6 == 0) {
      prompt = 'How many flat rectangular faces does a standard building brick have?';
      answer = '6 faces';
      options = ['6 faces', '4 faces', '8 faces', '12 faces']..shuffle(_rng);
      explanation = 'A standard cuboid brick has 6 flat rectangular faces (top, bottom, and 4 sides).';
    } else if (v % 6 == 1) {
      prompt = 'How many edges (straight boundary lines) does a rectangular brick have?';
      answer = '12 edges';
      options = ['12 edges', '8 edges', '6 edges', '16 edges']..shuffle(_rng);
      explanation = 'A cuboid brick has 4 top edges + 4 bottom edges + 4 vertical edges = 12 edges in total.';
    } else if (v % 6 == 2) {
      prompt = 'How many corners (vertices) does a rectangular brick have?';
      answer = '8 corners';
      options = ['8 corners', '6 corners', '12 corners', '4 corners']..shuffle(_rng);
      explanation = 'A cuboid brick has 4 top corners and 4 bottom corners = 8 corners (vertices).';
    } else if (v % 6 == 3) {
      final costPerThousand = (_rng.nextInt(4) + 2) * 1000; // ₹2000, ₹3000, ₹4000, ₹5000
      final bricksAsked = [500, 2000, 3000][_rng.nextInt(3)];
      final totalCost = (costPerThousand * bricksAsked) ~/ 1000;
      prompt = 'At a brick kiln, 1,000 bricks cost ₹$costPerThousand. How much will $bricksAsked bricks cost?';
      answer = '₹$totalCost';
      options = ['₹$totalCost', '₹${totalCost + 1000}', '₹${totalCost - 500}', '₹${bricksAsked * 2}']..shuffle(_rng);
      explanation = '1 brick costs ₹$costPerThousand ÷ 1,000 = ₹${costPerThousand ~/ 1000}. So $bricksAsked bricks cost $bricksAsked × ₹${costPerThousand ~/ 1000} = ₹$totalCost.';
    } else if (v % 6 == 4) {
      final wallM = _rng.nextInt(5) + 5; // 5 to 9 m
      final brickCm = 20; // 20 cm
      final count = (wallM * 100) ~/ brickCm;
      prompt = 'A garden wall is $wallM meters long. If each brick is $brickCm cm long, how many bricks are in one complete row?';
      answer = '$count bricks';
      options = ['$count bricks', '${count + 10} bricks', '${count - 5} bricks', '${wallM * 10} bricks']..shuffle(_rng);
      explanation = '$wallM meters = ${wallM * 100} cm. $count bricks = ${wallM * 100} cm ÷ $brickCm cm.';
    } else {
      prompt = 'What geometrical 2D shape is each face of a standard building brick?';
      answer = 'Rectangle';
      options = ['Rectangle', 'Circle', 'Triangle', 'Pentagon']..shuffle(_rng);
      explanation = 'Every face of a cuboid brick is a flat rectangle.';
    }

    final id = 'proc_brick_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_building_with_bricks',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Building with Bricks (Faces & Edges)',
        'visualIcon': '🧱',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Long and Short metric conversion problem (Ch 2 - Class 4)
  Activity generateDistanceProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 6 == 0) {
      final km = _rng.nextInt(35) + 5; // 5 to 39 km
      final meters = km * 1000;
      prompt = 'A marathon race distance is $km km. How many meters is that?';
      answer = '$meters meters';
      options = ['$meters meters', '${km * 100} meters', '${meters + 500} meters', '${meters - 1000} meters']..shuffle(_rng);
      explanation = '1 kilometer = 1,000 meters. So $km km = $km × 1,000 = $meters meters.';
    } else if (v % 6 == 1) {
      final meters = _rng.nextInt(6) + 3; // 3 to 8 m
      final cm = _rng.nextInt(80) + 10; // 10 to 89 cm
      final totalCm = (meters * 100) + cm;
      prompt = 'A tailor measures a roll of curtain cloth as $meters meters and $cm cm. How many centimeters is that in total?';
      answer = '$totalCm cm';
      options = ['$totalCm cm', '${meters * 10 + cm} cm', '${totalCm + 100} cm', '${totalCm - 50} cm']..shuffle(_rng);
      explanation = '1 meter = 100 cm. So $meters m = ${meters * 100} cm. Total = ${meters * 100} + $cm = $totalCm cm.';
    } else if (v % 6 == 2) {
      final h1 = _rng.nextInt(20) + 135; // 135 to 154 cm
      final h2 = _rng.nextInt(15) + 115; // 115 to 129 cm
      final diff = h1 - h2;
      prompt = 'Aman is $h1 cm tall and his younger brother Rahul is $h2 cm tall. How much taller is Aman than Rahul?';
      answer = '$diff cm';
      options = ['$diff cm', '${diff + 5} cm', '${diff - 3} cm', '${h1 - 100} cm']..shuffle(_rng);
      explanation = 'Height difference = $h1 cm - $h2 cm = $diff cm.';
    } else if (v % 6 == 3) {
      final laps = _rng.nextInt(5) + 4; // 4 to 8 laps
      final lapDist = 400; // 400 m
      final totalDist = laps * lapDist;
      prompt = 'An athlete runs around a $lapDist-meter running track $laps times during training. What total distance did they run?';
      answer = '$totalDist meters';
      options = ['$totalDist meters', '${totalDist + 400} meters', '${totalDist - 200} meters', '${laps * 100} meters']..shuffle(_rng);
      explanation = '$laps laps × $lapDist meters per lap = $totalDist meters (${totalDist / 1000} km).';
    } else if (v % 6 == 4) {
      final totalKm = _rng.nextInt(30) + 50; // 50 to 79 km
      final covered = _rng.nextInt(25) + 20; // 20 to 44 km
      final rem = totalKm - covered;
      prompt = 'The highway distance between two cities is $totalKm km. A car has travelled $covered km. How many kilometers are remaining?';
      answer = '$rem km';
      options = ['$rem km', '${rem + 10} km', '${rem - 5} km', '$covered km']..shuffle(_rng);
      explanation = 'Remaining distance = $totalKm km - $covered km = $rem km.';
    } else {
      final jumpM = _rng.nextInt(3) + 2; // 2 to 4
      final jumpCm = (_rng.nextInt(8) + 1) * 10; // 10 to 80
      final total = (jumpM * 100) + jumpCm;
      prompt = 'In the school sports meet, Gurjeet made a long jump of $jumpM m $jumpCm cm. How many centimeters is this jump?';
      answer = '$total cm';
      options = ['$total cm', '${jumpM * 10 + jumpCm} cm', '${total + 50} cm', '${jumpM * 100} cm']..shuffle(_rng);
      explanation = '$jumpM m = ${jumpM * 100} cm. Adding $jumpCm cm gives $total cm.';
    }

    final id = 'proc_dist_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_long_and_short',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Long and Short (Kilometers & Meters)',
        'visualIcon': '🏃',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Trip to Bhopal trip math problem (Ch 3 - Class 4)
  Activity generateTripBhopalProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 6 == 0) {
      final buses = _rng.nextInt(3) + 3; // 3 to 5
      final seats = 50;
      final totalSeats = buses * seats;
      prompt = 'A school is going on a trip to Bhopal with $buses buses. Each bus has $seats seats. How many children can sit?';
      answer = '$totalSeats children';
      options = ['$totalSeats children', '${totalSeats - 50} children', '${totalSeats + 50} children', '${buses * 100} children']..shuffle(_rng);
      explanation = '$buses buses × $seats seats each = $totalSeats children.';
    } else if (v % 6 == 1) {
      final buses = 4;
      final seats = 50;
      final totalSeats = buses * seats; // 200
      final children = totalSeats + (_rng.nextInt(4) + 1) * 5; // 205 to 220
      final standing = children - totalSeats;
      prompt = 'There are $children students going to Bhopal, but only $buses mini-buses with $seats seats each are available. How many students will not get a seat?';
      answer = '$standing students';
      options = ['$standing students', '${standing + 5} students', '${standing - 2} students', '15 students']..shuffle(_rng);
      explanation = 'Total seats = $buses × $seats = $totalSeats. Without seats = $children - $totalSeats = $standing students.';
    } else if (v % 6 == 2) {
      final liters = (_rng.nextInt(5) + 3) * 10; // 30 to 70 liters
      final rate = 90; // ₹90/liter
      final total = liters * rate;
      prompt = 'At the fuel station, the school bus takes $liters liters of diesel. If 1 liter costs ₹$rate, what is the total diesel bill?';
      answer = '₹$total';
      options = ['₹$total', '₹${total + 450}', '₹${total - 300}', '₹${liters * 100}']..shuffle(_rng);
      explanation = '$liters liters × ₹$rate per liter = ₹$total.';
    } else if (v % 6 == 3) {
      final fare = 15; // ₹15
      final kids = _rng.nextInt(4) + 4; // 4 to 7 kids
      final totalFare = kids * fare;
      prompt = 'At Upper Lake Bhopal, paddle-boat ride tickets cost ₹$fare per student. How much will a group of $kids students pay in total?';
      answer = '₹$totalFare';
      options = ['₹$totalFare', '₹${totalFare + 15}', '₹${totalFare - 10}', '₹${kids * 20}']..shuffle(_rng);
      explanation = '$kids students × ₹$fare each = ₹$totalFare.';
    } else if (v % 6 == 4) {
      final startH = 9;
      final travelH = _rng.nextInt(3) + 2; // 2 to 4 hours
      final reachH = startH + travelH;
      prompt = 'The excursion bus departs school at $startH:00 AM and travels for $travelH hours to reach the caves of Bhimbetka. At what time will it arrive?';
      answer = '$reachH:00 ${reachH >= 12 ? 'PM' : 'AM'}';
      options = [
        '$reachH:00 ${reachH >= 12 ? 'PM' : 'AM'}',
        '${reachH + 1}:00 ${reachH + 1 >= 12 ? 'PM' : 'AM'}',
        '${reachH - 1}:00 AM',
        '1:00 PM',
      ]..shuffle(_rng);
      explanation = '$startH:00 AM + $travelH hours = $reachH:00 ${reachH >= 12 ? 'PM' : 'AM'}.';
    } else {
      final students = (_rng.nextInt(4) + 4) * 10; // 40 to 70 students
      final biscuitsEach = 5;
      final totalBiscuits = students * biscuitsEach;
      prompt = 'During lunchtime on the Bhopal trip, each of the $students students is given $biscuitsEach biscuits. How many biscuits were shared in total?';
      answer = '$totalBiscuits biscuits';
      options = ['$totalBiscuits biscuits', '${totalBiscuits + 50} biscuits', '${totalBiscuits - 20} biscuits', '${students * 10} biscuits']..shuffle(_rng);
      explanation = '$students students × $biscuitsEach biscuits = $totalBiscuits biscuits.';
    }

    final id = 'proc_trip_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_trip_to_bhopal',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'A Trip to Bhopal (Multi-Step Math)',
        'visualIcon': '🚌',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a The Way the World Looks perspective problem (Ch 5 - Class 4)
  Activity generatePerspectiveProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      prompt = 'From which viewpoint does a round dinner plate or glass bowl look like a perfect circle?';
      answer = 'Top view';
      options = ['Top view', 'Side view', 'Bottom-edge view', 'Corner view']..shuffle(_rng);
      explanation = 'Looking directly from above (Top view), a cylindrical or circular object appears as a 2D circle.';
    } else if (v % 5 == 1) {
      final top = _rng.nextInt(6) + 1;
      final bottom = 7 - top;
      prompt = 'On a standard playing dice, opposite faces always sum to 7. If the top face shows $top dots, what number is on the bottom face?';
      answer = '$bottom';
      options = ['$bottom', '${(bottom % 6) + 1}', '${7 - bottom + 1}', '$top']..shuffle(_rng);
      explanation = 'Opposite faces on a standard dice add up to 7: 7 - $top = $bottom.';
    } else if (v % 5 == 2) {
      prompt = 'Railway tracks appear wide near your feet and narrow far away in the distance. This visual phenomenon is called:';
      answer = 'Perspective';
      options = ['Perspective', 'Perimeter', 'Symmetry', 'Reflection']..shuffle(_rng);
      explanation = 'In perspective projection, parallel lines appear to converge as distance from the eye increases.';
    } else if (v % 5 == 3) {
      prompt = 'Looking down at a car from the terrace of a tall building (top view), what is mainly visible?';
      answer = 'The car roof and windshields';
      options = ['The car roof and windshields', 'The 4 round wheels', 'The headlights and license plate', 'The door handles']..shuffle(_rng);
      explanation = 'From directly above (Top view), only the horizontal top surface (roof and hoods) is seen.';
    } else {
      prompt = 'When looking at a staircase from the side view, what shape do the steps create?';
      answer = 'A zigzag staircase profile';
      options = ['A zigzag staircase profile', 'A straight flat rectangle', 'A round circle', 'A single dot']..shuffle(_rng);
      explanation = 'The side profile of a staircase reveals the step-by-step zigzag risers and treads.';
    }

    final id = 'proc_persp_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_way_the_world_looks',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'The Way the World Looks (Perspectives)',
        'visualIcon': '🗺️',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a The Junk Seller rate list problem (Ch 6 - Class 4)
  Activity generateJunkSellerProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 6 == 0) {
      final kg = _rng.nextInt(8) + 3; // 3 to 10 kg
      final rate = 14; // ₹14 per kg
      final total = kg * rate;
      prompt = 'Kiran buys old newspapers at ₹$rate per kg. How much money will she pay for $kg kg of newspapers?';
      answer = '₹$total';
      options = ['₹$total', '₹${total + 14}', '₹${total - 10}', '₹${kg * 10}']..shuffle(_rng);
      explanation = '$kg kg × ₹$rate/kg = ₹$total.';
    } else if (v % 6 == 1) {
      final kg = _rng.nextInt(6) + 3; // 3 to 8 kg
      final rate = 25; // ₹25 per kg
      final total = kg * rate;
      prompt = 'The scrap junk dealer buys scrap iron at ₹$rate per kg. How much will he pay for $kg kg of iron?';
      answer = '₹$total';
      options = ['₹$total', '₹${total + 25}', '₹${total - 25}', '₹${kg * 20}']..shuffle(_rng);
      explanation = '$kg kg × ₹$rate = ₹$total.';
    } else if (v % 6 == 2) {
      final n100 = _rng.nextInt(4) + 2; // 2 to 5
      final n50 = _rng.nextInt(4) + 2; // 2 to 5
      final total = (n100 * 100) + (n50 * 50);
      prompt = 'Kiran collected $n100 notes of ₹100 and $n50 notes of ₹50 from selling scrap. How much money is that in total?';
      answer = '₹$total';
      options = ['₹$total', '₹${total + 50}', '₹${total - 100}', '₹${(n100 + n50) * 50}']..shuffle(_rng);
      explanation = '($n100 × ₹100 = ₹${n100 * 100}) + ($n50 × ₹50 = ₹${n50 * 50}) = ₹$total.';
    } else if (v % 6 == 3) {
      final bill = (_rng.nextInt(7) + 3) * 50; // ₹150 to ₹450
      final change = 500 - bill;
      prompt = 'A customer purchased recycled goods worth ₹$bill and gave Kiran a ₹500 note. How much change must Kiran return?';
      answer = '₹$change';
      options = ['₹$change', '₹${change + 50}', '₹${change - 50}', '₹$bill']..shuffle(_rng);
      explanation = 'Change = ₹500 - ₹$bill = ₹$change.';
    } else if (v % 6 == 4) {
      final loan = 300;
      final monthly = 60;
      final totalPaid = monthly * 6; // 360
      final extra = totalPaid - loan; // 60
      prompt = 'Hari borrowed ₹$loan from a bank. He paid back ₹$monthly every month for 6 months. How much extra interest did he pay?';
      answer = '₹$extra';
      options = ['₹$extra', '₹${extra + 20}', '₹${extra - 10}', '₹$totalPaid']..shuffle(_rng);
      explanation = 'Total paid = 6 × ₹$monthly = ₹$totalPaid. Extra interest = ₹$totalPaid - ₹$loan = ₹$extra.';
    } else {
      final bought = (_rng.nextInt(6) + 4) * 100; // ₹400 to ₹900
      final profit = (_rng.nextInt(4) + 2) * 50; // ₹100 to ₹250
      final sold = bought + profit;
      prompt = 'Kiran bought junk for ₹$bought and sold it to a big dealer for ₹$sold. What was her profit?';
      answer = '₹$profit';
      options = ['₹$profit', '₹${profit + 50}', '₹${profit - 30}', '₹${bought ~/ 2}']..shuffle(_rng);
      explanation = 'Profit = Selling Price (₹$sold) - Cost Price (₹$bought) = ₹$profit.';
    }

    final id = 'proc_junk_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_junk_seller',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'The Junk Seller (Rate Lists & Multiplication)',
        'visualIcon': '📰',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Carts and Wheels circles problem (Ch 8 - Class 4)
  Activity generateCircleProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 6 == 0) {
      final r = _rng.nextInt(8) + 3; // 3 to 10 cm
      final d = 2 * r;
      prompt = 'A cart wheel has a radius of $r cm. What is its diameter?';
      answer = '$d cm';
      options = ['$d cm', '${r + 2} cm', '${r * 4} cm', '${d + 4} cm']..shuffle(_rng);
      explanation = 'Diameter = 2 × Radius = 2 × $r cm = $d cm.';
    } else if (v % 6 == 1) {
      final d = (_rng.nextInt(8) + 3) * 2; // 6 to 20 cm (even)
      final r = d ~/ 2;
      prompt = 'A round plate has a diameter of $d cm. What is its radius?';
      answer = '$r cm';
      options = ['$r cm', '${d + 2} cm', '${d * 2} cm', '${r + 1} cm']..shuffle(_rng);
      explanation = 'Radius = Diameter ÷ 2 = $d ÷ 2 = $r cm.';
    } else if (v % 6 == 2) {
      prompt = 'What is the straight line segment from the center of a circle to any point on its boundary called?';
      answer = 'Radius';
      options = ['Radius', 'Diameter', 'Chord', 'Circumference']..shuffle(_rng);
      explanation = 'The distance from center to outer edge of a circle is the Radius.';
    } else if (v % 6 == 3) {
      prompt = 'What is the longest straight line passing through the center connecting two opposite points on a circle called?';
      answer = 'Diameter';
      options = ['Diameter', 'Radius', 'Arc', 'Sector']..shuffle(_rng);
      explanation = 'The longest line across a circle passing through the center is the Diameter.';
    } else if (v % 6 == 4) {
      prompt = 'Which of the following household objects can be used to trace a circle on paper?';
      answer = 'A circular glass bangle';
      options = ['A circular glass bangle', 'A rectangular eraser', 'A triangular ruler', 'A matchbox']..shuffle(_rng);
      explanation = 'Round bangles and coins have circular boundaries.';
    } else {
      final r1 = _rng.nextInt(3) + 3; // 3 to 5
      final r2 = r1 + _rng.nextInt(3) + 2; // 5 to 9
      prompt = 'Circle A has a radius of $r1 cm, and Circle B has a radius of $r2 cm. Which circle has the larger boundary (circumference)?';
      answer = 'Circle B';
      options = ['Circle B', 'Circle A', 'Both are equal', 'Cannot determine']..shuffle(_rng);
      explanation = 'Larger radius ($r2 cm > $r1 cm) produces a larger circle boundary.';
    }

    final id = 'proc_circ_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_carts_and_wheels',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Carts & Wheels (Radius & Diameter)',
        'visualIcon': '🎡',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Halves and Quarters / Fraction problem (Ch 9 - Class 4)
  Activity generateFractionProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    final String prompt;
    final String answer;
    final List<String> options;
    final String explanation;

    if (v % 5 == 0) {
      final total = (_rng.nextInt(8) + 4) * 2; // 8 to 22 even
      final half = total ~/ 2;
      prompt = 'A chocolate bar has $total pieces. If Seema eats half (1/2) of it, how many pieces did she eat?';
      answer = '$half pieces';
      options = ['$half pieces', '${half + 2} pieces', '${half - 1} pieces', '${total - 2} pieces']..shuffle(_rng);
      explanation = 'Half (1/2) of $total = $total ÷ 2 = $half pieces.';
    } else if (v % 5 == 1) {
      final total = (_rng.nextInt(6) + 3) * 4; // 12 to 32 multiple of 4
      final quarter = total ~/ 4;
      prompt = 'In a basket of $total apples, one-fourth (1/4) are red and the rest are green. How many apples are red?';
      answer = '$quarter apples';
      options = ['$quarter apples', '${quarter * 2} apples', '${quarter + 2} apples', '${quarter - 1} apples']..shuffle(_rng);
      explanation = 'One-fourth (1/4) of $total = $total ÷ 4 = $quarter apples.';
    } else if (v % 5 == 2) {
      final total = (_rng.nextInt(5) + 3) * 4; // 12 to 28
      final threeFourths = (total * 3) ~/ 4;
      prompt = 'A test has $total questions. Aryan answered three-fourths (3/4) of them correctly. How many questions did he get right?';
      answer = '$threeFourths questions';
      options = ['$threeFourths questions', '${total ~/ 2} questions', '${threeFourths - 2} questions', '${total - 1} questions']..shuffle(_rng);
      explanation = '3/4 of $total = ($total ÷ 4) × 3 = ${total ~/ 4} × 3 = $threeFourths.';
    } else if (v % 5 == 3) {
      final pricePerKg = (_rng.nextInt(6) + 4) * 10; // ₹40 to ₹90
      final halfPrice = pricePerKg ~/ 2;
      prompt = 'One kilogram of fresh tomatoes costs ₹$pricePerKg. What is the cost of half (1/2) kg of tomatoes?';
      answer = '₹$halfPrice';
      options = ['₹$halfPrice', '₹${halfPrice + 10}', '₹${halfPrice - 5}', '₹${pricePerKg - 10}']..shuffle(_rng);
      explanation = 'Half kg costs ₹$pricePerKg ÷ 2 = ₹$halfPrice.';
    } else {
      return generateEquivalentFractions(targetGrade: targetGrade);
    }

    final id = 'proc_frac_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_halves_quarters',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Halves & Quarters (Fractions)',
        'visualIcon': '🍰',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }



  /// Generates a Pythagoras theorem problem (Class 7)
  Activity generatePythagorasProblem({String targetGrade = 'Class 7'}) {
    final triplets = [
      {'base': 3, 'height': 4, 'hyp': 5},
      {'base': 6, 'height': 8, 'hyp': 10},
      {'base': 5, 'height': 12, 'hyp': 13},
    ];
    final t = triplets[_rng.nextInt(triplets.length)];
    final base = t['base']!;
    final height = t['height']!;
    final hyp = t['hyp']!;

    final prompt = 'In a right-angled triangle, the base is $base cm and perpendicular height is $height cm. What is the length of the hypotenuse?';
    final answer = '$hyp cm';
    final options = ['$hyp cm', '${hyp + 2} cm', '${base + height} cm', '${hyp - 1} cm']..shuffle(_rng);

    final id = 'proc_pyth_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_triangle_properties',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.middleAchiever,
      activityType: ActivityType.mcq,
      difficultyLevel: 3,
      pointsReward: 35,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Triangle Properties (Pythagoras Theorem)',
        'visualIcon': '📐',
        'options': options,
        'explanation': 'Pythagoras Theorem: Hypotenuse² = Base² + Height² = $base² + $height² = ${base * base} + ${height * height} = ${hyp * hyp}. So Hypotenuse = $hyp cm.',
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }
  /// Generates a Play with Patterns problem (Class 4 Ch 10)
  Activity generatePatternsRotationProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    switch (v % 5) {
      case 0:
        final turns = [
          {'start': 'UP (⬆️)', 'turn': 'a 1/4 turn clockwise', 'ans': 'RIGHT (➡️)', 'alts': ['DOWN (⬇️)', 'LEFT (⬅️)', 'UP (⬆️)']},
          {'start': 'RIGHT (➡️)', 'turn': 'a 1/4 turn clockwise', 'ans': 'DOWN (⬇️)', 'alts': ['LEFT (⬅️)', 'UP (⬆️)', 'RIGHT (➡️)']},
          {'start': 'UP (⬆️)', 'turn': 'a 1/2 turn (180°)', 'ans': 'DOWN (⬇️)', 'alts': ['RIGHT (➡️)', 'LEFT (⬅️)', 'UP (⬆️)']},
          {'start': 'LEFT (⬅️)', 'turn': 'a 1/2 turn (180°)', 'ans': 'RIGHT (➡️)', 'alts': ['UP (⬆️)', 'DOWN (⬇️)', 'LEFT (⬅️)']},
        ];
        final t = turns[_rng.nextInt(turns.length)];
        prompt = 'An arrow points ${t['start']}. After ${t['turn']}, which direction does it point?';
        answer = t['ans'] as String;
        options = [answer, ...(t['alts'] as List<String>)]..shuffle(_rng);
        explanation = 'Turning from ${t['start']} by ${t['turn']} points ${t['ans']}.';
        break;

      case 1:
        final letters = [
          {'q': 'Which of these English letters looks exactly the same after a 1/2 turn (upside down)?', 'ans': 'H', 'opts': ['H', 'A', 'M', 'B'], 'exp': 'H remains H when flipped upside down.'},
          {'q': 'Which of these letters has the same shape after a 1/2 turn (180° rotation)?', 'ans': 'N', 'opts': ['N', 'E', 'C', 'P'], 'exp': 'N looks identical when rotated by 180 degrees.'},
          {'q': 'Which digit looks identical after a half turn upside down?', 'ans': '8', 'opts': ['8', '4', '7', '6'], 'exp': '8 is symmetric top-to-bottom and looks the same upside down.'},
          {'q': 'Which digit becomes 9 when rotated by a half turn?', 'ans': '6', 'opts': ['6', '8', '5', '3'], 'exp': '6 turned upside down becomes 9.'},
        ];
        final item = letters[_rng.nextInt(letters.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      case 2:
        final step = _rng.nextInt(5) + 3; // 3 to 7
        final start = _rng.nextInt(10) + 2;
        final seq = [start, start + step, start + 2 * step, start + 3 * step];
        final next = start + 4 * step;
        prompt = 'Find the next number in this sequence pattern: ${seq.join(", ")}, ___ ?';
        answer = '$next';
        options = ['$next', '${next + step}', '${next - 1}', '${next + 2}']..shuffle(_rng);
        explanation = 'The pattern adds $step every time ($start + $step = ${start + step}...). So next is ${seq.last} + $step = $next.';
        break;

      case 3:
        final shapes = [
          {'pat': '🔴, 🔷, 🔺, 🔴, 🔷, 🔺, 🔴, 🔷', 'next': '🔺', 'dist': ['🔴', '🔷', '⭐'], 'rule': 'Repeating 3-shape sequence: Red circle, Blue diamond, Red triangle.'},
          {'pat': '🟡, 🟡, 🟢, 🟡, 🟡, 🟢, 🟡', 'next': '🟡', 'dist': ['🟢', '🔵', '🔺'], 'rule': 'Pattern repeats two Yellow circles followed by one Green circle.'},
          {'pat': '⬆️, ➡️, ⬇️, ⬅️, ⬆️, ➡️', 'next': '⬇️', 'dist': ['⬆️', '⬅️', '↗️'], 'rule': 'Quarter-turn clockwise arrow cycle: Up, Right, Down, Left.'},
        ];
        final s = shapes[_rng.nextInt(shapes.length)];
        prompt = 'What comes next in the pattern: ${s['pat']}, ___ ?';
        answer = s['next'] as String;
        options = [answer, ...(s['dist'] as List<String>)]..shuffle(_rng);
        explanation = s['rule'] as String;
        break;

      default:
        final words = [
          {'word': 'CAT', 'code': '3-1-20', 'alt': ['3-2-21', '2-1-19', '3-1-19']},
          {'word': 'DOG', 'code': '4-15-7', 'alt': ['4-14-6', '5-15-7', '4-16-8']},
          {'word': 'SUN', 'code': '19-21-14', 'alt': ['18-20-13', '19-22-15', '19-21-15']},
          {'word': 'BOOK', 'code': '2-15-15-11', 'alt': ['2-14-14-10', '3-15-15-12', '2-16-16-11']},
        ];
        final w = words[_rng.nextInt(words.length)];
        prompt = 'If A=1, B=2, C=3... (alphabet position code), what is the secret number code for "${w['word']}"?';
        answer = w['code'] as String;
        options = [answer, ...(w['alt'] as List<String>)]..shuffle(_rng);
        explanation = 'Substitute each letter with its alphabet number rank to get $answer.';
        break;
    }

    final id = 'proc_pat_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_patterns',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Play with Patterns',
        'visualIcon': '🎨',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a How Heavy? How Light? (Weights & Pan Balance) problem (Class 4 Ch 12)
  Activity generateWeightsProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    switch (v % 5) {
      case 0:
        final weights = [
          {'kg': 1, 'bagG': 250, 'bags': 4},
          {'kg': 1, 'bagG': 500, 'bags': 2},
          {'kg': 2, 'bagG': 500, 'bags': 4},
          {'kg': 1, 'bagG': 100, 'bags': 10},
          {'kg': 1, 'bagG': 200, 'bags': 5},
        ];
        final w = weights[_rng.nextInt(weights.length)];
        prompt = 'How many packets of ${w['bagG']} g sugar are needed to balance exactly ${w['kg']} kg on a balance scale?';
        answer = '${w['bags']} packets';
        options = [
          '${w['bags']} packets',
          '${(w['bags'] as int) + 2} packets',
          '${max(1, (w['bags'] as int) - 1)} packets',
          '${(w['bags'] as int) * 2} packets'
        ]..shuffle(_rng);
        explanation = '${w['kg']} kg = ${(w['kg'] as int) * 1000} g. ${(w['kg'] as int) * 1000} ÷ ${w['bagG']} = ${w['bags']} packets.';
        break;

      case 1:
        final kg = _rng.nextInt(6) + 2; // 2 to 7 kg
        final extraG = (_rng.nextInt(8) + 1) * 100; // 100 to 800 g
        final totalG = (kg * 1000) + extraG;
        prompt = 'A sack of potatoes weighs $kg kg and $extraG g. How many grams is this in total?';
        answer = '$totalG g';
        options = [
          '$totalG g',
          '${kg * 100 + extraG} g',
          '${totalG + 500} g',
          '${totalG - 200} g'
        ]..shuffle(_rng);
        explanation = '1 kg = 1000 g. So $kg kg = ${kg * 1000} g. Total = ${kg * 1000} + $extraG = $totalG g.';
        break;

      case 2:
        final g = (_rng.nextInt(6) + 1) * 500; // 500, 1000, 1500, ... 3000
        final kgEquivalent = g / 1000.0;
        final formattedKg = kgEquivalent == kgEquivalent.toInt() ? '${kgEquivalent.toInt()}' : '$kgEquivalent';
        prompt = 'Convert $g grams into kilograms:';
        answer = '$formattedKg kg';
        options = [
          '$formattedKg kg',
          '${(g / 100.0).toStringAsFixed(1)} kg',
          '${(kgEquivalent + 1).toStringAsFixed(1)} kg',
          '${max(0.5, kgEquivalent - 0.5)} kg'
        ]..shuffle(_rng);
        explanation = 'Since 1000 g = 1 kg, divide $g by 1000: $g ÷ 1000 = $formattedKg kg.';
        break;

      case 3:
        final heavierItems = [
          {'heavy': 'A full school bag with textbooks', 'light': 'A feather', 'prompt': 'Which of these items weighs MORE than 1 kilogram?'},
          {'heavy': 'A large pumpkin 🎃', 'light': 'A single strawberry 🍓', 'prompt': 'Which vegetable / fruit is likely to weigh more than 1 kg?'},
          {'heavy': 'A bicycle 🚲', 'light': 'An empty plastic cup 🥤', 'prompt': 'Which of these objects has a weight greater than 5 kilograms?'},
        ];
        final item = heavierItems[_rng.nextInt(heavierItems.length)];
        prompt = item['prompt']!;
        answer = item['heavy']!;
        options = [
          item['heavy']!,
          item['light']!,
          'A single eraser',
          'A postage stamp',
        ]..shuffle(_rng);
        explanation = '${item['heavy']} has significant mass, exceeding 1 kilogram, while other objects weigh only a few grams.';
        break;

      default:
        final fractionQueries = [
          {'q': 'How many grams are in 1/2 (half) a kilogram?', 'ans': '500 g', 'opts': ['500 g', '250 g', '750 g', '100 g'], 'exp': 'Half of 1000 g is 1000 ÷ 2 = 500 g.'},
          {'q': 'How many grams are in 1/4 (one quarter) kilogram?', 'ans': '250 g', 'opts': ['250 g', '500 g', '150 g', '750 g'], 'exp': 'Quarter of 1000 g is 1000 ÷ 4 = 250 g.'},
          {'q': 'How many grams are in 3/4 kilogram?', 'ans': '750 g', 'opts': ['750 g', '500 g', '250 g', '800 g'], 'exp': '3/4 of 1000 g is 3 × 250 = 750 g.'},
        ];
        final f = fractionQueries[_rng.nextInt(fractionQueries.length)];
        prompt = f['q'] as String;
        answer = f['ans'] as String;
        options = (f['opts'] as List<String>)..shuffle(_rng);
        explanation = f['exp'] as String;
        break;
    }

    final id = 'proc_wt_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_weights',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'How Heavy? How Light?',
        'visualIcon': '⚖️',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates a Smart Charts / Data Handling problem (Class 4 Ch 14)
  Activity generateSmartChartsProblem({String targetGrade = 'Class 4', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    switch (v % 5) {
      case 0:
        final tallyBundles = _rng.nextInt(3) + 2; // 2 to 4 bundles (10 to 20)
        final extraStrokes = _rng.nextInt(4); // 0 to 3 extra
        final totalCount = (tallyBundles * 5) + extraStrokes;
        final tallyStr = List.filled(tallyBundles, '卌').join(' ') + (extraStrokes > 0 ? ' ${'|' * extraStrokes}' : '');
        prompt = 'In a survey, students made the tally marks: $tallyStr. What number does this represent?';
        answer = '$totalCount';
        options = ['$totalCount', '${totalCount + 2}', '${totalCount - 3}', '${totalCount + 5}']..shuffle(_rng);
        explanation = 'Each closed bundle "卌" represents 5. So $tallyBundles bundles = ${tallyBundles * 5}, plus $extraStrokes extra = $totalCount.';
        break;

      case 1:
        final scale = _rng.nextInt(4) + 2; // 2 to 5 per symbol
        final count = _rng.nextInt(5) + 3; // 3 to 7 symbols
        final total = scale * count;
        final icons = '🌲 ' * count;
        prompt = 'If each 🌲 symbol represents $scale trees, how many trees do these symbols represent: $icons?';
        answer = '$total trees';
        options = [
          '$total trees',
          '${total + scale} trees',
          '$count trees',
          '${total - scale} trees'
        ]..shuffle(_rng);
        explanation = '$count symbols × $scale trees each = $total trees.';
        break;

      case 2:
        final totalKids = [20, 40, 60, 80][_rng.nextInt(4)];
        final half = totalKids ~/ 2;
        final quarter = totalKids ~/ 4;
        prompt = 'In a Chapati Chart (circle pie chart) of $totalKids students: 1/2 like Football, 1/4 like Cricket, and 1/4 like Tennis. How many students like Cricket?';
        answer = '$quarter students';
        options = [
          '$quarter students',
          '$half students',
          '${quarter + 5} students',
          '${quarter - 2} students'
        ]..shuffle(_rng);
        explanation = '1/4 of $totalKids students = $totalKids ÷ 4 = $quarter students.';
        break;

      case 3:
        final dogs = (_rng.nextInt(4) + 3) * 5; // 15 to 30
        final cats = (_rng.nextInt(3) + 1) * 5; // 5 to 15
        final diff = dogs - cats;
        prompt = 'A bar chart shows: Dogs = $dogs votes, Cats = $cats votes. How many MORE votes did Dogs get than Cats?';
        answer = '$diff votes';
        options = [
          '$diff votes',
          '${dogs + cats} votes',
          '${diff + 5} votes',
          '${max(2, diff - 4)} votes'
        ]..shuffle(_rng);
        explanation = 'Difference = $dogs - $cats = $diff votes.';
        break;

      default:
        final sunny = _rng.nextInt(5) + 10;
        final rainy = _rng.nextInt(4) + 4;
        final cloudy = 30 - (sunny + rainy);
        prompt = 'In a month of 30 days: Sunny days = $sunny, Rainy days = $rainy. How many days were cloudy?';
        answer = '$cloudy days';
        options = [
          '$cloudy days',
          '${cloudy + 2} days',
          '${sunny + rainy} days',
          '${max(1, cloudy - 3)} days'
        ]..shuffle(_rng);
        explanation = 'Cloudy days = 30 - ($sunny + $rainy) = 30 - ${sunny + rainy} = $cloudy days.';
        break;
    }

    final id = 'proc_chart_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_smart_charts',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 30,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Smart Charts (Data Handling)',
        'visualIcon': '📊',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Shapes and Space problems (Class 1 Ch 1, LKG Ch 1, Class 2 Ch 1)
  Activity generateShapesAndSpaceProblem({String targetGrade = 'Class 1', int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    switch (v % 6) {
      case 0:
        final shapes = [
          {'q': 'Which shape has exactly 3 straight sides and 3 sharp corners?', 'ans': 'Triangle 🔺', 'opts': ['Triangle 🔺', 'Circle ⚪', 'Square 🟩', 'Rectangle 🟧'], 'exp': 'A triangle has 3 sides and 3 corners (vertices).'},
          {'q': 'Which shape is perfectly round with NO sides and NO corners?', 'ans': 'Circle ⚪', 'opts': ['Circle ⚪', 'Triangle 🔺', 'Square 🟩', 'Star ⭐'], 'exp': 'A circle is a smooth curve with zero corners.'},
          {'q': 'Which shape has 4 straight sides that are ALL EQUAL in length?', 'ans': 'Square 🟩', 'opts': ['Square 🟩', 'Triangle 🔺', 'Circle ⚪', 'Oval 🥚'], 'exp': 'A square has 4 equal sides and 4 corners.'},
          {'q': 'A door or a blackboard usually has opposite sides equal. What shape is it?', 'ans': 'Rectangle 🟧', 'opts': ['Rectangle 🟧', 'Circle ⚪', 'Triangle 🔺', 'Oval 🥚'], 'exp': 'A rectangle has 4 sides where opposite sides are equal.'},
        ];
        final item = shapes[_rng.nextInt(shapes.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      case 1:
        final rollSlide = [
          {'q': 'Which of these everyday objects can easily ROLL along the floor?', 'ans': 'Football ⚽', 'opts': ['Football ⚽', 'Eraser 🧱', 'Notebook 📘', 'Wooden Box 📦'], 'exp': 'Round objects like balls roll smoothly on surfaces.'},
          {'q': 'Which of these items will SLIDE flat on the floor instead of rolling?', 'ans': 'Flat Pencil Box 📦', 'opts': ['Flat Pencil Box 📦', 'Round Marble 🔮', 'Orange 🍊', 'Tennis Ball 🎾'], 'exp': 'Flat-faced objects slide along surfaces.'},
          {'q': 'Which object can BOTH roll and slide?', 'ans': 'Coin (or Candle) 🪙', 'opts': ['Coin (or Candle) 🪙', 'Ball ⚽', 'Kite 🪁', 'Dice 🎲'], 'exp': 'A coin can roll on its curved edge and slide on its flat faces.'},
        ];
        final item = rollSlide[_rng.nextInt(rollSlide.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      case 2:
        final spatial = [
          {'q': 'A bird is sitting at the very highest branch of a tree. The bird is at the...?', 'ans': 'TOP of the tree 🌳', 'opts': ['TOP of the tree 🌳', 'BOTTOM of the tree', 'UNDER the roots', 'INSIDE the trunk'], 'exp': 'The highest part of an object is the TOP.'},
          {'q': 'Pencils are placed neatly inside a pencil pouch. The pencils are...?', 'ans': 'INSIDE the pouch ✏️', 'opts': ['INSIDE the pouch ✏️', 'OUTSIDE the pouch', 'FAR away from the pouch', 'BEHIND the pouch'], 'exp': 'Contained within an object means INSIDE.'},
          {'q': 'A kitten is resting beneath a wooden dining table. The kitten is...?', 'ans': 'UNDER the table 🐱', 'opts': ['UNDER the table 🐱', 'ON TOP of the roof', 'FAR in the forest', 'INSIDE the teapot'], 'exp': 'Resting beneath an object is described as UNDER.'},
        ];
        final item = spatial[_rng.nextInt(spatial.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      case 3:
        final sizes = [
          {'q': 'Which animal is BIGGER: an Elephant 🐘 or a Mouse 🐁?', 'ans': 'Elephant 🐘', 'opts': ['Elephant 🐘', 'Mouse 🐁', 'Both are equal size', 'Neither'], 'exp': 'An elephant is much bigger and heavier than a mouse.'},
          {'q': 'Which fruit is SMALLER: a Watermelon 🍉 or a Cherry 🍒?', 'ans': 'Cherry 🍒', 'opts': ['Cherry 🍒', 'Watermelon 🍉', 'Both are same size', 'Pumpkin 🎃'], 'exp': 'A cherry fits in your fingers, making it far smaller.'},
          {'q': 'Which leaf is the SMALLEST: Banana leaf, Mango leaf, or Rose leaf?', 'ans': 'Rose leaf 🍃', 'opts': ['Rose leaf 🍃', 'Banana leaf 🌿', 'Mango leaf 🥭', 'Papaya leaf 🍃'], 'exp': 'Rose leaves are tiny compared to mango and giant banana leaves.'},
        ];
        final item = sizes[_rng.nextInt(sizes.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      case 4:
        final solidShapes = [
          {'q': 'What 3D shape is a birthday party hat 🥳?', 'ans': 'Cone 🍦', 'opts': ['Cone 🍦', 'Cube 🎲', 'Sphere ⚽', 'Cylinder 🥫'], 'exp': 'A party hat has a circular base tapering to a single point: a Cone.'},
          {'q': 'What 3D shape is a playing dice 🎲?', 'ans': 'Cube 🎲', 'opts': ['Cube 🎲', 'Sphere ⚽', 'Cylinder 🥫', 'Cone 🍦'], 'exp': 'A dice has 6 equal square faces: a Cube.'},
          {'q': 'What 3D shape is a soup can or soda can 🥫?', 'ans': 'Cylinder 🥫', 'opts': ['Cylinder 🥫', 'Cube 🎲', 'Cone 🍦', 'Pyramid 🔺'], 'exp': 'A can has two flat circular faces and a curved surface: a Cylinder.'},
        ];
        final item = solidShapes[_rng.nextInt(solidShapes.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;

      default:
        final nearFar = [
          {'q': 'A puppy is 1 step from home, and a bird is 50 steps away. Who is NEARER to home?', 'ans': 'The puppy 🐶', 'opts': ['The puppy 🐶', 'The bird 🐦', 'Both same distance', 'Neither'], 'exp': '1 step is a shorter distance, so the puppy is NEARER.'},
          {'q': 'Two boats are on the lake: Boat A is close to the shore, Boat B is far in the middle. Which boat is FARTHER from the shore?', 'ans': 'Boat B ⛵', 'opts': ['Boat B ⛵', 'Boat A 🚣', 'Both same', 'Shore is moving'], 'exp': 'Boat B in the deep middle is FARTHER from shore.'},
        ];
        final item = nearFar[_rng.nextInt(nearFar.length)];
        prompt = item['q'] as String;
        answer = item['ans'] as String;
        options = (item['opts'] as List<String>)..shuffle(_rng);
        explanation = item['exp'] as String;
        break;
    }

    final id = 'proc_shapes_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_shapes_space',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Shapes and Space',
        'visualIcon': '🟡',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Generates Early Numbers & Arithmetic problems for Class 1 / LKG / UKG
  Activity generateEarlyNumbersProblem({String targetGrade = 'Class 1', int? variant}) {
    final v = variant ?? _rng.nextInt(5);
    String prompt;
    String answer;
    List<String> options;
    String explanation;

    switch (v % 5) {
      case 0:
        final n = _rng.nextInt(7) + 2; // 2 to 8
        final icons = ['🍎', '⭐', '🎈', '🐱', '🚗', '🍭'][_rng.nextInt(6)];
        prompt = 'Count the items: ${List.filled(n, icons).join(" ")}. How many are there in total?';
        answer = '$n';
        options = ['$n', '${n + 1}', '${max(1, n - 1)}', '${n + 2}']..shuffle(_rng);
        explanation = 'Count one by one: there are exactly $n items!';
        break;

      case 1:
        final a = _rng.nextInt(5) + 1; // 1 to 5
        final b = _rng.nextInt(4) + 1; // 1 to 4
        final sum = a + b;
        prompt = 'Riya has $a balloons 🎈 and her brother gives her $b more. How many balloons does she have now? ($a + $b = ?)';
        answer = '$sum balloons';
        options = ['$sum balloons', '${sum + 1} balloons', '${max(1, sum - 1)} balloons', '${sum + 2} balloons']..shuffle(_rng);
        explanation = '$a + $b = $sum balloons in total.';
        break;

      case 2:
        final total = _rng.nextInt(5) + 4; // 4 to 8
        final take = _rng.nextInt(total - 2) + 1;
        final left = total - take;
        prompt = 'There were $total birds on a branch 🐦. $take birds flew away. How many birds are left? ($total - $take = ?)';
        answer = '$left birds';
        options = ['$left birds', '${left + 1} birds', '${max(0, left - 1)} birds', '${left + 2} birds']..shuffle(_rng);
        explanation = 'Start with $total, take away $take: $total - $take = $left birds.';
        break;

      case 3:
        final n = _rng.nextInt(15) + 2; // 2 to 16
        final isAfter = _rng.nextBool();
        if (isAfter) {
          prompt = 'What number comes immediately AFTER $n?';
          answer = '${n + 1}';
          options = ['${n + 1}', '${n - 1}', '${n + 2}', '$n']..shuffle(_rng);
          explanation = 'Counting up: after $n comes ${n + 1}.';
        } else {
          prompt = 'What number comes BETWEEN $n and ${n + 2}?';
          answer = '${n + 1}';
          options = ['${n + 1}', '${n + 3}', '$n', '${n - 1}']..shuffle(_rng);
          explanation = 'Between $n and ${n + 2} is ${n + 1}.';
        }
        break;

      default:
        final tens = 1;
        final ones = _rng.nextInt(9) + 1; // 1 to 9
        final total = (tens * 10) + ones;
        prompt = 'How much is 1 ten and $ones ones?';
        answer = '$total';
        options = ['$total', '${total + 10}', '${total - 1}', '${ones * 10 + 1}']..shuffle(_rng);
        explanation = '1 ten is 10. 10 + $ones = $total.';
        break;
    }

    final id = 'proc_num_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_numbers_early',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.mcq,
      difficultyLevel: 1,
      pointsReward: 20,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': 'Numbers & Early Operations',
        'visualIcon': '🔢',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  /// Synthesizes authentic questions directly from a Chapter\'s curriculum metadata:
  /// keyConcepts, rules, exampleQuestion, and description.
  /// GUARANTEED: Zero class name in prompts, rich diversity across question types, no repeated boilerplate.
  Activity generateConceptQuestionsForChapter(Chapter chapter, StudentClass studentClass, {int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    String prompt = '';
    String answer = '';
    List<String> options = [];
    String explanation = '';

    final bool hasValidExample = chapter.exampleQuestion != null &&
        chapter.exampleQuestion!.trim().length > 15 &&
        !chapter.exampleQuestion!.toLowerCase().endsWith('problem:') &&
        !chapter.exampleQuestion!.toLowerCase().contains('problem:') &&
        chapter.exampleAnswer != null &&
        chapter.exampleAnswer!.isNotEmpty &&
        chapter.exampleAnswer != 'Correct!' &&
        chapter.exampleAnswer != 'Correct';

    // Strategy 1: Worked Textbook Example from curriculum
    if (hasValidExample && (v % 3 == 0 || chapter.rules.isEmpty)) {
      prompt = chapter.exampleQuestion!;
      answer = chapter.exampleAnswer!;
      explanation = chapter.exampleExplanation ?? 'This follows the core concept of ${chapter.title}.';
      final distractors = <String>[];
      final digitsOnly = answer.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.isNotEmpty && int.tryParse(digitsOnly) != null) {
        final numVal = int.parse(digitsOnly);
        final unit = answer.replaceAll(RegExp(r'[0-9]'), '').trim();
        final unitSuffix = unit.isNotEmpty ? ' $unit' : '';
        distractors.add('${numVal + 2}$unitSuffix');
        distractors.add('${max(1, numVal - 2)}$unitSuffix');
        distractors.add('${numVal + 5}$unitSuffix');
      } else {
        if (answer.toLowerCase().startsWith('yes')) {
          distractors.addAll(['No, only in special cases', 'No, that is not possible', 'Only when numbers are equal']);
        } else if (answer.toLowerCase().startsWith('no')) {
          distractors.addAll(['Yes, always', 'Yes, in all conditions', 'Only for negative numbers']);
        } else {
          for (final kc in chapter.keyConcepts) {
            if (kc != answer && distractors.length < 3) distractors.add(kc);
          }
          final fallbackAlternatives = ['Cannot be determined directly', 'Depends on the scale used', 'Double the original amount'];
          for (final fa in fallbackAlternatives) {
            if (distractors.length < 3 && !distractors.contains(fa) && fa != answer) {
              distractors.add(fa);
            }
          }
        }
      }
      options = [answer, ...distractors.take(3)]..shuffle(_rng);
    }
    // Strategy 2: Authentic Concept & Rule Application
    else if (chapter.rules.isNotEmpty) {
      final ruleIndex = (v ~/ 2) % chapter.rules.length;
      final trueRule = chapter.rules[ruleIndex];
      prompt = 'Which statement is TRUE for "${chapter.title}"?';
      answer = trueRule;

      final distractors = <String>[];
      for (int i = 0; i < chapter.rules.length; i++) {
        if (i != ruleIndex && distractors.length < 2) {
          final other = chapter.rules[i];
          if (other != trueRule && !distractors.contains(other)) distractors.add(other);
        }
      }
      if (distractors.length < 3) {
        distractors.add('This rule is only valid when multiplying by zero');
      }
      if (distractors.length < 3) {
        distractors.add('The result always decreases regardless of operation');
      }
      options = [answer, ...distractors.take(3)]..shuffle(_rng);
      explanation = 'According to the curriculum: $trueRule.';
    }
    // Strategy 3: Key Concept Recognition
    else {
      final conceptIndex = v % (chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts.length : 1);
      final targetConcept = chapter.keyConcepts.isNotEmpty ? chapter.keyConcepts[conceptIndex] : chapter.title;
      prompt = 'Which key mathematical topic is explored in "${chapter.title}"?';
      answer = targetConcept;

      final distractors = <String>[];
      for (final kc in chapter.keyConcepts) {
        if (kc != targetConcept && distractors.length < 3) {
          distractors.add(kc);
        }
      }
      final defaultFallbacks = ['Basic Counting', 'Metric Measurement', 'Geometric Patterns', 'Number Operations'];
      for (final df in defaultFallbacks) {
        if (df != targetConcept && !distractors.contains(df) && distractors.length < 3) {
          distractors.add(df);
        }
      }
      options = [answer, ...distractors.take(3)]..shuffle(_rng);
      explanation = 'In "${chapter.title}", understanding "$targetConcept" is a key learning goal.';
    }

    final id = 'proc_concept_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
    return Activity(
      activityId: id,
      topicId: 'topic_${chapter.chapterId}',
      subjectId: 'math',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.mcq,
      difficultyLevel: 2,
      pointsReward: 25,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': chapter.icon.isNotEmpty ? chapter.icon : '✨',
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
    );
  }


  // =========================================================================
  // Helper for Math Multiple Choice Questions
  // =========================================================================
  Activity _buildMathMcq({
    required String id,
    required String targetGrade,
    required GradeTier gradeTier,
    required String topicId,
    required String topicTitle,
    required String prompt,
    required String answer,
    required List<String> options,
    required String explanation,
    String visualIcon = '🔢',
    int pointsReward = 20,
    int difficultyLevel = 1,
    String? chapterId,
    String? chapterName,
  }) {
    return Activity(
      activityId: id,
      topicId: topicId,
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: gradeTier,
      activityType: ActivityType.mcq,
      difficultyLevel: difficultyLevel,
      pointsReward: pointsReward,
      chapterId: chapterId,
      chapterName: chapterName,
      promptData: PromptData(text: prompt, ttsFallback: prompt),
      interactionPayload: {
        'topicTitle': topicTitle,
        'visualIcon': visualIcon,
        'options': options,
        'explanation': explanation,
      },
      validationRule: ValidationRule(format: 'exact', expectedAnswer: answer),
    );
  }

  // =========================================================================
  // Kindergarten Math Bubble Pop Generators (100% Interactive for LKG & UKG)
  // =========================================================================
  Activity _buildMathBubblePop({
    required String id,
    required Chapter chapter,
    required StudentClass studentClass,
    required String promptText,
    required String ttsText,
    required dynamic targetValue,
    required List<Map<String, dynamic>> bubbles,
    String visualIcon = '🫧',
    int pointsReward = 20,
  }) {
    return Activity(
      activityId: id,
      topicId: 'topic_${chapter.chapterId}',
      subjectId: 'math',
      targetGrade: studentClass.label,
      gradeTier: studentClass.tier,
      activityType: ActivityType.bubblePop,
      difficultyLevel: 1,
      pointsReward: pointsReward,
      chapterId: chapter.chapterId,
      chapterName: chapter.title,
      promptData: PromptData(
        text: promptText,
        ttsFallback: ttsText,
      ),
      interactionPayload: {
        'topicTitle': chapter.title,
        'visualIcon': visualIcon,
        'targetValue': targetValue,
        'bubbles': bubbles,
      },
      validationRule: const ValidationRule(
        format: 'bubble_pop',
        expectedAnswer: [],
        hintTree: [
          StepHint(stepIndex: 1, hintText: 'Look at each bubble and pop the ones that match!'),
        ],
      ),
    );
  }

  Activity _generateKindergartenMathBubblePop(Chapter ch, StudentClass sc, int idx) {
    final title = ch.title.toLowerCase();
    final colors = ['#4CAF50', '#2196F3', '#FF9800', '#E91E63', '#9C27B0', '#00BCD4'];

    if (title.contains('shape') || title.contains('space')) {
      final shapes = [
        {'target': 'circle', 'label': 'Circle ⭕', 'matches': ['Circle ⭕', 'Wheel 🛞', 'Chapati 🫓', 'Coin 🪙'], 'distractors': ['Square 🟦', 'Triangle 🔺', 'Box 📦', 'Tent ⛺']},
        {'target': 'square', 'label': 'Square 🟦', 'matches': ['Square 🟦', 'Box 📦', 'Tile 🔲', 'Window 🪟'], 'distractors': ['Circle ⭕', 'Ball ⚽', 'Triangle 🔺', 'Slice 🍕']},
        {'target': 'triangle', 'label': 'Triangle 🔺', 'matches': ['Triangle 🔺', 'Pizza Slice 🍕', 'Tent ⛺', 'Hanger 📐'], 'distractors': ['Circle ⭕', 'Square 🟦', 'Wheel 🛞', 'Box 📦']},
      ];
      final item = shapes[(idx - 1) % shapes.length];
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (final m in (item['matches'] as List<String>)) {
        if (bubbles.length < 3) {
          bubbles.add({
            'id': 'b_${bId++}',
            'label': m,
            'value': item['target'],
            'displayType': 'label',
            'color': colors[_rng.nextInt(colors.length)],
          });
        }
      }
      for (final d in (item['distractors'] as List<String>)) {
        if (bubbles.length < 6) {
          bubbles.add({
            'id': 'b_${bId++}',
            'label': d,
            'value': 'wrong',
            'displayType': 'label',
            'color': colors[_rng.nextInt(colors.length)],
          });
        }
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_shape_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: 'Pop all the ${item['label']} bubbles!',
        ttsText: 'Pop all the ${item['label']} bubbles!',
        targetValue: item['target'],
        bubbles: bubbles,
        visualIcon: '⭕',
      );
    }

    if (title.contains('pattern') || title.contains('color')) {
      final colorPicks = [
        {'target': 'red', 'name': 'RED 🔴', 'matches': ['Red 🔴', 'Apple 🍎', 'Strawberry 🍓', 'Balloon 🎈'], 'distractors': ['Blue 🔵', 'Green 🟢', 'Yellow 🟡', 'Leaf 🍃']},
        {'target': 'blue', 'name': 'BLUE 🔵', 'matches': ['Blue 🔵', 'Water 💧', 'Blueberry 🫐', 'Cloud ☁️'], 'distractors': ['Red 🔴', 'Orange 🍊', 'Green 🟢', 'Banana 🍌']},
        {'target': 'green', 'name': 'GREEN 🟢', 'matches': ['Green 🟢', 'Leaf 🍃', 'Frog 🐸', 'Pear 🍐'], 'distractors': ['Red 🔴', 'Sun ☀️', 'Blue 🔵', 'Strawberry 🍓']},
        {'target': 'yellow', 'name': 'YELLOW 🟡', 'matches': ['Yellow 🟡', 'Sun ☀️', 'Banana 🍌', 'Star ⭐'], 'distractors': ['Blue 🔵', 'Frog 🐸', 'Red 🔴', 'Grape 🍇']},
      ];
      final item = colorPicks[(idx - 1) % colorPicks.length];
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (final m in (item['matches'] as List<String>)) {
        if (bubbles.length < 3) {
          bubbles.add({'id': 'b_${bId++}', 'label': m, 'value': item['target'], 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
        }
      }
      for (final d in (item['distractors'] as List<String>)) {
        if (bubbles.length < 6) {
          bubbles.add({'id': 'b_${bId++}', 'label': d, 'value': 'other', 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
        }
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_color_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: 'Pop the ${item['name']} bubbles!',
        ttsText: 'Pop the ${item['name']} bubbles!',
        targetValue: item['target'],
        bubbles: bubbles,
        visualIcon: '🎨',
      );
    }

    if (title.contains('sorting') || title.contains('comparing') || title.contains('comparison')) {
      final sortPicks = [
        {'target': 'big', 'name': 'BIG things', 'matches': ['Elephant 🐘', 'Whale 🐋', 'Castle 🏰'], 'distractors': ['Ant 🐜', 'Mouse 🐭', 'Berry 🍓']},
        {'target': 'small', 'name': 'SMALL things', 'matches': ['Ant 🐜', 'Mouse 🐭', 'Coin 🪙'], 'distractors': ['Elephant 🐘', 'Bus 🚌', 'Mountain 🏔️']},
        {'target': 'tall', 'name': 'TALL things', 'matches': ['Giraffe 🦒', 'Tall Tree 🌲', 'Tower 🗼'], 'distractors': ['Turtle 🐢', 'Mushroom 🍄', 'Snail 🐌']},
        {'target': 'short', 'name': 'SHORT things', 'matches': ['Turtle 🐢', 'Mushroom 🍄', 'Cat 🐱'], 'distractors': ['Giraffe 🦒', 'Tower 🗼', 'Pine Tree 🌲']},
      ];
      final item = sortPicks[(idx - 1) % sortPicks.length];
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (final m in (item['matches'] as List<String>)) {
        bubbles.add({'id': 'b_${bId++}', 'label': m, 'value': item['target'], 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
      }
      for (final d in (item['distractors'] as List<String>)) {
        bubbles.add({'id': 'b_${bId++}', 'label': d, 'value': 'not_${item['target']}', 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_sort_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: 'Pop the ${item['name']}!',
        ttsText: 'Pop the ${item['name']}!',
        targetValue: item['target'],
        bubbles: bubbles,
        visualIcon: '⚖️',
      );
    }

    if (title.contains('addition') || title.contains('add')) {
      final sums = [3, 4, 5, 6];
      final targetSum = sums[(idx - 1) % sums.length];
      final pairs = <String>[];
      for (int a = 0; a <= targetSum; a++) {
        pairs.add('$a + ${targetSum - a}');
      }
      pairs.shuffle(_rng);
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (int i = 0; i < min(3, pairs.length); i++) {
        bubbles.add({'id': 'b_${bId++}', 'label': pairs[i], 'value': targetSum, 'displayType': 'equation', 'color': colors[_rng.nextInt(colors.length)]});
      }
      while (bubbles.length < 6) {
        final wrongVal = (targetSum + _rng.nextInt(4) + 1);
        bubbles.add({'id': 'b_${bId++}', 'label': '${wrongVal - 1} + 1', 'value': wrongVal, 'displayType': 'equation', 'color': colors[_rng.nextInt(colors.length)]});
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_add_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: 'Pop bubbles that add up to $targetSum!',
        ttsText: 'Pop bubbles that add up to $targetSum!',
        targetValue: targetSum,
        bubbles: bubbles,
        visualIcon: '➕',
      );
    }

    if (title.contains('subtraction') || title.contains('subtract')) {
      final diffs = [1, 2, 3];
      final targetDiff = diffs[(idx - 1) % diffs.length];
      final pairs = <String>[];
      for (int top = targetDiff + 1; top <= targetDiff + 4; top++) {
        pairs.add('$top - ${top - targetDiff}');
      }
      pairs.shuffle(_rng);
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (int i = 0; i < min(3, pairs.length); i++) {
        bubbles.add({'id': 'b_${bId++}', 'label': pairs[i], 'value': targetDiff, 'displayType': 'equation', 'color': colors[_rng.nextInt(colors.length)]});
      }
      while (bubbles.length < 6) {
        final wrongDiff = targetDiff + _rng.nextInt(3) + 2;
        bubbles.add({'id': 'b_${bId++}', 'label': '$wrongDiff - 1', 'value': wrongDiff - 1, 'displayType': 'equation', 'color': colors[_rng.nextInt(colors.length)]});
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_sub_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: 'Pop bubbles that equal $targetDiff!',
        ttsText: 'Pop bubbles that equal $targetDiff!',
        targetValue: targetDiff,
        bubbles: bubbles,
        visualIcon: '➖',
      );
    }

    if (title.contains('time') || title.contains('calendar')) {
      final isDay = (idx % 2 == 1);
      final target = isDay ? 'day' : 'night';
      final dayItems = ['Sun ☀️', 'Go to School 🏫', 'Play in Park ⚽', 'Eat Breakfast 🥪'];
      final nightItems = ['Moon 🌙', 'Sleep in Bed 🛌', 'Shining Stars 🌟', 'Bedtime Story 📖'];
      final matches = isDay ? dayItems : nightItems;
      final distractors = isDay ? nightItems : dayItems;
      final bubbles = <Map<String, dynamic>>[];
      int bId = 1;
      for (int i = 0; i < 3; i++) {
        bubbles.add({'id': 'b_${bId++}', 'label': matches[i], 'value': target, 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
      }
      for (int i = 0; i < 3; i++) {
        bubbles.add({'id': 'b_${bId++}', 'label': distractors[i], 'value': isDay ? 'night' : 'day', 'displayType': 'label', 'color': colors[_rng.nextInt(colors.length)]});
      }
      bubbles.shuffle(_rng);
      return _buildMathBubblePop(
        id: 'math_k_time_${DateTime.now().microsecondsSinceEpoch}_$idx',
        chapter: ch,
        studentClass: sc,
        promptText: isDay ? 'Pop all DAYTIME activities!' : 'Pop all NIGHTTIME activities!',
        ttsText: isDay ? 'Pop all DAYTIME activities!' : 'Pop all NIGHTTIME activities!',
        targetValue: target,
        bubbles: bubbles,
        visualIcon: '⏰',
      );
    }

    // Default Numbers (1 to 5, 6 to 10, or 1 to 20)
    final int minNum = title.contains('6 to 10') || title.contains('6-10')
        ? 6
        : (title.contains('1 to 20') || title.contains('1-20') ? 11 : 1);
    final int maxNum = title.contains('6 to 10') || title.contains('6-10')
        ? 10
        : (title.contains('1 to 20') || title.contains('1-20') ? 20 : 5);
    final rangeSize = maxNum - minNum + 1;
    final target = minNum + ((idx - 1) % rangeSize);

    final bubbles = <Map<String, dynamic>>[];
    bubbles.add({'id': 'b_1', 'label': '$target', 'value': target, 'displayType': 'number', 'color': colors[0]});
    bubbles.add({'id': 'b_2', 'label': '$target', 'value': target, 'displayType': 'number', 'color': colors[1]});

    int bId = 3;
    final otherCandidates = List<int>.generate(maxNum - minNum + 1, (i) => minNum + i)..remove(target);
    otherCandidates.shuffle(_rng);
    for (final other in otherCandidates) {
      if (bubbles.length < 6) {
        bubbles.add({'id': 'b_${bId++}', 'label': '$other', 'value': other, 'displayType': 'number', 'color': colors[_rng.nextInt(colors.length)]});
      }
    }
    bubbles.shuffle(_rng);

    return _buildMathBubblePop(
      id: 'math_k_num_${DateTime.now().microsecondsSinceEpoch}_$idx',
      chapter: ch,
      studentClass: sc,
      promptText: 'Pop all bubbles that equal $target!',
      ttsText: 'Pop all bubbles that equal $target!',
      targetValue: target,
      bubbles: bubbles,
      visualIcon: '🔢',
    );
  }

  // =========================================================================
  // Class 1 Primary Math Generators
  // =========================================================================
  Activity _generateClass1MathProblem(Chapter ch, StudentClass sc, int idx) {
    final title = ch.title.toLowerCase();

    if (title.contains('shape') || title.contains('space')) {
      return generateShapesAndSpaceProblem(targetGrade: sc.label, variant: idx);
    }
    if (title.contains('addition') || title.contains('add')) {
      return generateClass1AdditionProblem(variant: idx);
    }
    if (title.contains('subtraction') || title.contains('subtract')) {
      return generateClass1SubtractionProblem(variant: idx);
    }
    if (title.contains('time') || title.contains('calendar')) {
      return generateClass1TimeProblem(variant: idx);
    }
    if (title.contains('measurement') || title.contains('measure')) {
      return generateClass1MeasurementProblem(variant: idx);
    }
    if (title.contains('money')) {
      return generateClass1MoneyProblem(variant: idx);
    }
    if (title.contains('pattern')) {
      return generateClass1PatternsProblem(variant: idx);
    }
    if (title.contains('data') || title.contains('how many')) {
      return generateClass1DataHandlingProblem(variant: idx);
    }
    if (title.contains('10 to 20') || title.contains('21 to 50') || title.contains('up to 100') || title.contains('place value')) {
      return generateClass1TensAndOnesProblem(variant: idx);
    }
    return generateClass1NumbersProblem(variant: idx);
  }

  Activity generateClass1AdditionProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(10);
    final a = (v % 5) + 2; // 2 to 6
    final b = ((v ~/ 2) % 4) + 1; // 1 to 4
    final sum = a + b;

    final isWord = (v % 2 == 1);
    final prompt = isWord
        ? 'Rani has $a apples 🍎. Rohit gives her $b more 🍎. How many apples does Rani have in all?'
        : 'What is $a + $b?';
    final answer = '$sum';
    final options = ['$sum', '${sum + 1}', '${max(1, sum - 1)}', '${sum + 2}']..shuffle(_rng);

    return _buildMathMcq(
      id: 'c1_add_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_addition',
      topicTitle: 'Addition',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: '$a plus $b is equal to $sum ($a + $b = $sum).',
      visualIcon: '➕',
    );
  }

  Activity generateClass1SubtractionProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(10);
    final a = (v % 5) + 5; // 5 to 9
    final b = ((v ~/ 2) % 4) + 1; // 1 to 4
    final diff = a - b;

    final isWord = (v % 2 == 1);
    final prompt = isWord
        ? 'There were $a birds 🐦 on a branch. $b birds flew away. How many birds are left?'
        : 'What is $a - $b?';
    final answer = '$diff';
    final options = ['$diff', '${diff + 1}', '${max(0, diff - 1)}', '${diff + 2}']..shuffle(_rng);

    return _buildMathMcq(
      id: 'c1_sub_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_subtraction',
      topicTitle: 'Subtraction',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: '$a minus $b leaves $diff ($a - $b = $diff).',
      visualIcon: '➖',
    );
  }

  Activity generateClass1TensAndOnesProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(10);
    final tens = (v % 3) + 1; // 1 to 3
    final ones = ((v ~/ 2) % 9) + 1; // 1 to 9
    final total = (tens * 10) + ones;

    final isWord = (v % 2 == 0);
    final prompt = isWord
        ? 'What number is formed by $tens Tens and $ones Ones?'
        : 'In the number $total, how many TENS are there?';
    final answer = isWord ? '$total' : '$tens';
    final List<String> options;
    if (isWord) {
      options = ['$total', '${total + 10}', '${total - 1}', '${ones * 10 + tens}']..shuffle(_rng);
    } else {
      options = ['$tens', '$ones', '${tens + 1}', '${max(0, tens - 1)}']..shuffle(_rng);
    }

    return _buildMathMcq(
      id: 'c1_pv_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_tens_ones',
      topicTitle: 'Tens and Ones',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: '$tens tens = ${tens * 10}, and $ones ones = $ones. Total is $total.',
      visualIcon: '🧱',
    );
  }

  Activity generateClass1TimeProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final questions = [
      {'q': 'The short hand points to 4 and the long hand points to 12. What time is it?', 'a': "4 o'clock", 'opts': ["4 o'clock", "12 o'clock", "3 o'clock", "5 o'clock"], 'exp': 'When long hand is at 12, short hand shows the hour.'},
      {'q': 'When do we wake up and see the bright sun rising?', 'a': 'Morning ☀️', 'opts': ['Morning ☀️', 'Night 🌙', 'Afternoon 🌤️', 'Midnight 🌌'], 'exp': 'The sun rises in the morning.'},
      {'q': 'Which day comes immediately AFTER Monday?', 'a': 'Tuesday 📅', 'opts': ['Tuesday 📅', 'Sunday 📅', 'Wednesday 📅', 'Friday 📅'], 'exp': 'The order of days is Sunday, Monday, Tuesday, ...'},
      {'q': 'When do shining stars and the moon appear in the sky?', 'a': 'Night 🌙', 'opts': ['Night 🌙', 'Morning ☀️', 'Afternoon 🌤️', 'Noon 🕛'], 'exp': 'Stars and moon shine brightly at night.'},
      {'q': 'How many days are there in 1 full week?', 'a': '7 days', 'opts': ['7 days', '5 days', '10 days', '12 days'], 'exp': 'There are 7 days from Sunday to Saturday.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'c1_time_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_time',
      topicTitle: 'Time & Calendar',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '⏰',
    );
  }

  Activity generateClass1MeasurementProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final questions = [
      {'q': 'Which of these everyday objects is LONGER?', 'a': 'Pencil ✏️', 'opts': ['Pencil ✏️', 'Eraser 🧼', 'Sharpener 🔘', 'Paperclip 📎'], 'exp': 'A pencil is longer than an eraser or sharpener.'},
      {'q': 'Which of these objects is HEAVIER?', 'a': 'Watermelon 🍉', 'opts': ['Watermelon 🍉', 'Apple 🍎', 'Strawberry 🍓', 'Grape 🍇'], 'exp': 'A large watermelon weighs much more than small fruits.'},
      {'q': 'Which animal is TALLER?', 'a': 'Giraffe 🦒', 'opts': ['Giraffe 🦒', 'Dog 🐶', 'Cat 🐱', 'Rabbit 🐰'], 'exp': 'A giraffe has a long neck and is very tall.'},
      {'q': 'Can you measure the length of your study table using handspans?', 'a': 'Yes, with handspans 🖐️', 'opts': ['Yes, with handspans 🖐️', 'No, impossible', 'Only with water', 'Only with balloons'], 'exp': 'Handspan is an easy non-standard measurement tool.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'c1_meas_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_measurement',
      topicTitle: 'Measurement',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '📏',
    );
  }

  Activity generateClass1MoneyProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final questions = [
      {'q': 'Which coin has the number 5 stamped on it?', 'a': '₹5 coin', 'opts': ['₹5 coin', '₹1 coin', '₹2 coin', '₹10 coin'], 'exp': 'A 5 rupee coin has number 5.'},
      {'q': 'A pencil costs ₹3 and an eraser costs ₹2. How much money do you need in all?', 'a': '₹5', 'opts': ['₹5', '₹4', '₹6', '₹7'], 'exp': '₹3 + ₹2 = ₹5.'},
      {'q': 'Raju has a ₹10 note. He buys an ice-candy for ₹6. How much money is left?', 'a': '₹4', 'opts': ['₹4', '₹3', '₹5', '₹2'], 'exp': '₹10 - ₹6 = ₹4.'},
      {'q': 'Which Indian currency note is green in color with number 20 on it?', 'a': '₹20 note', 'opts': ['₹20 note', '₹10 note', '₹50 note', '₹100 note'], 'exp': 'The ₹20 note has number 20 printed on it.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'c1_money_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_money',
      topicTitle: 'Money',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '🪙',
    );
  }

  Activity generateClass1PatternsProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final questions = [
      {'q': 'What comes next in the pattern: 🔴 🔵 🔴 🔵 ___?', 'a': '🔴', 'opts': ['🔴', '🔵', '🟢', '🟡'], 'exp': 'The pattern alternates: red, blue, red, blue, red.'},
      {'q': 'Complete the number sequence: 2, 4, 6, 8, ___?', 'a': '10', 'opts': ['10', '9', '11', '12'], 'exp': 'Skip counting by 2: 2, 4, 6, 8, 10.'},
      {'q': 'What comes next in the shape pattern: ▲ ▼ ▲ ▼ ___?', 'a': '▲', 'opts': ['▲', '▼', '●', '■'], 'exp': 'The triangles alternate pointing up and down.'},
      {'q': 'Complete the number sequence: 1, 3, 5, 7, ___?', 'a': '9', 'opts': ['9', '8', '10', '11'], 'exp': 'Adding 2 each time: 1, 3, 5, 7, 9.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'c1_pat_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_patterns',
      topicTitle: 'Patterns',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '🔁',
    );
  }

  Activity generateClass1DataHandlingProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(4);
    final questions = [
      {'q': 'Look at the fruit basket: 🍎 🍎 🍎 and 🍌 🍌. How many APPLES 🍎 are there?', 'a': '3', 'opts': ['3', '2', '5', '4'], 'exp': 'Counting the apples: 1, 2, 3 apples.'},
      {'q': 'Look at the playful pets: 🐶 🐶 🐶 🐶 and 🐱 🐱. Which animal is MORE in number?', 'a': 'Dogs 🐶', 'opts': ['Dogs 🐶', 'Cats 🐱', 'Both equal', 'None'], 'exp': 'There are 4 dogs and only 2 cats: Dogs are more!'},
      {'q': 'Count the toys in the box: 🚗 🚗 and ⚽ ⚽ ⚽. How many toys are there in total?', 'a': '5 toys', 'opts': ['5 toys', '4 toys', '6 toys', '3 toys'], 'exp': '2 cars + 3 footballs = 5 toys in all.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'c1_data_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_data',
      topicTitle: 'Data Handling',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '📊',
    );
  }

  Activity generateClass1NumbersProblem({int? variant}) {
    final v = variant ?? _rng.nextInt(8);
    final num = (v % 8) + 2; // 2 to 9
    final isAfter = (v % 2 == 0);
    final prompt = isAfter
        ? 'What number comes immediately AFTER $num?'
        : 'What number comes immediately BEFORE $num?';
    final ans = isAfter ? '${num + 1}' : '${num - 1}';
    final options = [ans, '$num', '${num + 2}', '${max(0, num - 2)}']..shuffle(_rng);

    return _buildMathMcq(
      id: 'c1_num_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: 'Class 1',
      gradeTier: GradeTier.earlyExplorer,
      topicId: 'topic_c1_numbers',
      topicTitle: 'Numbers 1 to 9',
      prompt: prompt,
      answer: ans,
      options: options,
      explanation: isAfter ? 'Counting up: after $num comes ${num + 1}.' : 'Counting down: before $num comes ${num - 1}.',
      visualIcon: '🔢',
    );
  }

  // =========================================================================
  // Primary Math Generators (Class 2 to 5)
  // =========================================================================
  Activity generatePrimaryMultiplicationProblem({required String targetGrade, int? variant}) {
    final v = variant ?? _rng.nextInt(12);
    final a = (v % 7) + 2; // 2 to 8
    final b = ((v ~/ 2) % 7) + 2; // 2 to 8
    final prod = a * b;

    final isWord = (v % 3 == 0);
    final prompt = isWord
        ? 'There are $a bicycles. Each bicycle has $b wheels. How many wheels are there in all?'
        : 'What is $a × $b?';
    final answer = isWord ? '$prod wheels' : '$prod';
    final List<String> options;
    if (isWord) {
      options = ['$prod wheels', '${prod + b} wheels', '${max(1, prod - b)} wheels', '${prod + 2} wheels']..shuffle(_rng);
    } else {
      options = ['$prod', '${prod + b}', '${max(1, prod - b)}', '${prod + 4}']..shuffle(_rng);
    }

    return _buildMathMcq(
      id: 'prim_mul_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      topicId: 'topic_multiplication',
      topicTitle: 'Multiplication & Tables',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: '$a groups of $b equals $prod ($a × $b = $prod).',
      visualIcon: '✖️',
    );
  }

  Activity generatePrimaryAdditionProblem({required String targetGrade, int? variant}) {
    final v = variant ?? _rng.nextInt(10);
    final a = (v % 50) + 25; // 25 to 74
    final b = ((v * 3) % 40) + 15; // 15 to 54
    final sum = a + b;

    final prompt = 'Calculate: $a + $b = ?';
    final answer = '$sum';
    final options = ['$sum', '${sum + 10}', '${max(1, sum - 10)}', '${sum + 2}']..shuffle(_rng);

    return _buildMathMcq(
      id: 'prim_add_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      topicId: 'topic_primary_addition',
      topicTitle: 'Addition',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: 'Adding $a and $b gives $sum.',
      visualIcon: '➕',
    );
  }

  Activity generatePrimarySubtractionProblem({required String targetGrade, int? variant}) {
    final v = variant ?? _rng.nextInt(10);
    final a = (v % 40) + 55; // 55 to 94
    final b = ((v * 2) % 30) + 12; // 12 to 41
    final diff = a - b;

    final prompt = 'Calculate: $a - $b = ?';
    final answer = '$diff';
    final options = ['$diff', '${diff + 10}', '${max(0, diff - 10)}', '${diff + 2}']..shuffle(_rng);

    return _buildMathMcq(
      id: 'prim_sub_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      topicId: 'topic_primary_subtraction',
      topicTitle: 'Subtraction',
      prompt: prompt,
      answer: answer,
      options: options,
      explanation: 'Subtracting $b from $a leaves $diff.',
      visualIcon: '➖',
    );
  }

  Activity generateDecimalsProblem({required String targetGrade, int? variant}) {
    final v = variant ?? _rng.nextInt(6);
    final questions = [
      {'q': 'What is the fraction 3/10 written as a decimal?', 'a': '0.3', 'opts': ['0.3', '0.03', '3.0', '3.1'], 'exp': '3 divided by 10 is three-tenths = 0.3.'},
      {'q': 'In the decimal number 7.45, which digit is in the TENTHS place?', 'a': '4', 'opts': ['4', '7', '5', '0'], 'exp': 'The first digit after the decimal point is the tenths place: 4.'},
      {'q': 'What is 0.4 + 0.3?', 'a': '0.7', 'opts': ['0.7', '0.1', '0.07', '7.0'], 'exp': '0.4 + 0.3 = 0.7.'},
      {'q': 'What is 1.5 - 0.5?', 'a': '1.0', 'opts': ['1.0', '0.5', '2.0', '0.0'], 'exp': '1.5 - 0.5 = 1.0.'},
    ];
    final item = questions[v % questions.length];

    return _buildMathMcq(
      id: 'dec_${DateTime.now().microsecondsSinceEpoch}_$v',
      targetGrade: targetGrade,
      gradeTier: GradeTier.primaryBuilder,
      topicId: 'topic_decimals',
      topicTitle: 'Decimals',
      prompt: item['q'] as String,
      answer: item['a'] as String,
      options: List<String>.from(item['opts'] as List)..shuffle(_rng),
      explanation: item['exp'] as String,
      visualIcon: '🔢',
    );
  }

  /// Generates a set of unique, authenticated learning activities for a specific Chapter
  List<Activity> generateActivitiesForChapter(
    Chapter chapter,
    StudentClass studentClass, {
    int count = 3,
    Set<String> existingPromptTexts = const {},
  }) {
    final title = chapter.title.toLowerCase();
    final result = <Activity>[];
    final seenPrompts = Set<String>.from(existingPromptTexts);

    Activity Function(int variant) generator;

    // 1. Kindergarten Tier (LKG & UKG) - 100% interactive, voice-guided Bubble Pop
    if (studentClass.isKindergarten) {
      generator = (v) => _generateKindergartenMathBubblePop(chapter, studentClass, v + 1);
    }
    // 2. Class 1 Primary Math - age-appropriate, concrete foundations
    else if (studentClass == StudentClass.class1) {
      generator = (v) => _generateClass1MathProblem(chapter, studentClass, v + 1);
    }
    // 3. Middle School Tier (Class 6, 7, 8) - strictly grade-appropriate
    else if (studentClass.tier == GradeTier.middleAchiever) {
      if (title.contains('graph') || title.contains('coordinate')) {
        generator = (v) => generateCoordinateGraphsProblem(targetGrade: studentClass.label);
      } else if (title.contains('mensuration') || title.contains('surface') || title.contains('volume')) {
        generator = (v) => generateMiddleMensurationProblem(targetGrade: studentClass.label);
      } else if (title.contains('rational')) {
        generator = (v) => generateRationalNumbersProblem(targetGrade: studentClass.label);
      } else if (title.contains('equation')) {
        generator = (v) => generateLinearEquation(targetGrade: studentClass.label);
      } else if (title.contains('exponent') || title.contains('power')) {
        generator = (v) => generateExponentProblem(targetGrade: studentClass.label);
      } else if (title.contains('square') || title.contains('root') || title.contains('cube')) {
        generator = (v) => generateSquareRootProblem(targetGrade: studentClass.label);
      } else if (title.contains('expression') || title.contains('algebra') || title.contains('factor')) {
        generator = (v) => generateAlgebraicExpressionProblem(targetGrade: studentClass.label);
      } else if (title.contains('integer')) {
        generator = (v) => generateIntegerProblem(targetGrade: studentClass.label);
      } else if (title.contains('triangle') || title.contains('pythagor')) {
        generator = (v) => generatePythagorasProblem(targetGrade: studentClass.label);
      } else if (title.contains('place value') || title.contains('large number') || title.contains('numeration')) {
        generator = (v) => generateLargeNumbersProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('roman')) {
        generator = (v) => generateRomanNumeralsProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('fraction')) {
        generator = (v) => generateFractionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('division') || title.contains('divide')) {
        generator = (v) => generateDivisionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('time')) {
        generator = (v) => generateTimeConversion(targetGrade: studentClass.label, variant: v);
      } else {
        generator = (v) => generateConceptQuestionsForChapter(chapter, studentClass, variant: v);
      }
    }
    // 4. Primary Builder Tier (Class 2, 3, 4, 5)
    else {
      if (title.contains('place value') || title.contains('large number') || title.contains('numeration') || title.contains('tens and ones') || title.contains('counting in tens') || title.contains('counting in groups')) {
        generator = (v) => generatePlaceValueProblem(targetGrade: studentClass.label);
      } else if (title.contains('roman')) {
        generator = (v) => generateRomanNumeralsProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('factor') || title.contains('multiple')) {
        generator = (v) => generateFactorsAndMultiplesProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('estimat')) {
        generator = (v) => generateEstimationProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('money') || title.contains('rupee') || title.contains('paise') || title.contains('junk seller')) {
        generator = (v) => generateMoneyProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('geometry') || title.contains('shape') || title.contains('what is long') || title.contains('footprint') || title.contains('line')) {
        generator = (v) => generateGeometryBasicsProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('angle')) {
        generator = (v) => generateAnglesProblem(targetGrade: studentClass.label);
      } else if (title.contains('brick')) {
        generator = (v) => generateBricksProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('long and short') || title.contains('distance') || title.contains('longest step')) {
        generator = (v) => generateDistanceProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('trip') || title.contains('bhopal')) {
        generator = (v) => generateTripBhopalProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('tick') || title.contains('time') || title.contains('clock') || title.contains('funday') || title.contains('calendar')) {
        generator = (v) => generateTimeConversion(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('world') || title.contains('look') || title.contains('perspective')) {
        generator = (v) => generatePerspectiveProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('jug') || title.contains('mug') || title.contains('capacity')) {
        generator = (v) => generateCapacityProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('cart') || title.contains('wheel') || title.contains('circle')) {
        generator = (v) => generateCircleProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('fraction') || title.contains('half') || title.contains('part') || title.contains('quarter') || title.contains('whole')) {
        generator = (v) => generateFractionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('decimal') || title.contains('tenth') || title.contains('hundredth')) {
        generator = (v) => generateDecimalsProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('pattern') || title.contains('symmetry')) {
        generator = (v) => generatePatternsRotationProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('table') || title.contains('share') || title.contains('divide') || title.contains('division')) {
        generator = (v) => generateDivisionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('multipl') || title.contains('how many times')) {
        generator = (v) => generatePrimaryMultiplicationProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('add our points') || title.contains('give and take') || title.contains('birds come') || title.contains('addition')) {
        generator = (v) => generatePrimaryAdditionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('subtraction') || title.contains('subtract')) {
        generator = (v) => generatePrimarySubtractionProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('heavy') || title.contains('light') || title.contains('weight') || title.contains('carry')) {
        generator = (v) => generateWeightsProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('fence') || title.contains('perimeter') || title.contains('boundary') || title.contains('area') || title.contains('square')) {
        generator = (v) => generatePerimeterProblem(targetGrade: studentClass.label, variant: v);
      } else if (title.contains('chart') || title.contains('data') || title.contains('ponytail')) {
        generator = (v) => generateSmartChartsProblem(targetGrade: studentClass.label, variant: v);
      } else {
        generator = (v) => generateConceptQuestionsForChapter(chapter, studentClass, variant: v);
      }
    }

    for (int i = 0; i < count; i++) {
      Activity candidate = generator(i);
      int attempts = 0;
      while (seenPrompts.contains(candidate.promptData.text) && attempts < 20) {
        attempts++;
        candidate = generator(i + attempts);
        if (attempts >= 10) {
          candidate = generateConceptQuestionsForChapter(chapter, studentClass, variant: attempts);
        }
      }

      seenPrompts.add(candidate.promptData.text);

      final tagged = Activity(
        activityId: '${chapter.chapterId}_${candidate.activityId}',
        topicId: candidate.topicId,
        subjectId: candidate.subjectId,
        targetGrade: candidate.targetGrade,
        gradeTier: candidate.gradeTier,
        activityType: candidate.activityType,
        difficultyLevel: candidate.difficultyLevel,
        pointsReward: candidate.pointsReward,
        promptData: candidate.promptData,
        interactionPayload: candidate.interactionPayload,
        validationRule: candidate.validationRule,
        chapterId: chapter.chapterId,
        chapterName: chapter.title,
      );

      result.add(tagged);
    }

    return result;
  }

  /// Randomly pick any Class 4 concept
  Activity generateRandomClass4Concept() {
    final dice = _rng.nextInt(4);
    switch (dice) {
      case 0:
        return generatePerimeterProblem();
      case 1:
        return generateTimeConversion();
      case 2:
        return generateCapacityProblem();
      default:
        return generateDivisionProblem();
    }
  }

  /// Generates a dynamic Bubble Pop Counting activity for LKG - Class 1
  Activity generateBubblePopCounting({
    String targetGrade = 'Class 1',
    int? targetVal,
    int difficulty = 1,
  }) {
    final target = targetVal ?? (_rng.nextInt(7) + 3); // 3 to 10
    final colors = [
      '#4ADE80',
      '#FBBF24',
      '#60A5FA',
      '#F472B6',
      '#A78BFA',
      '#38BDF8',
      '#FB923C'
    ];

    final bubbles = <Map<String, dynamic>>[];

    bubbles.add({
      'id': 'b_target_1',
      'label': '$target',
      'value': target,
      'displayType': 'number',
      'color': colors[_rng.nextInt(colors.length)],
    });

    if (target <= 8) {
      bubbles.add({
        'id': 'b_target_2',
        'label': '⭐' * target,
        'value': target,
        'displayType': 'objects',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    if (target > 2) {
      final part1 = _rng.nextInt(target - 1) + 1;
      final part2 = target - part1;
      bubbles.add({
        'id': 'b_target_3',
        'label': '$part1 + $part2',
        'value': target,
        'displayType': 'expression',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    for (int i = 0; i < 3; i++) {
      int dist = _rng.nextInt(9) + 1;
      if (dist == target) dist = (target % 9) + 1;
      bubbles.add({
        'id': 'b_dist_$i',
        'label': '$dist',
        'value': dist,
        'displayType': 'number',
        'color': colors[_rng.nextInt(colors.length)],
      });
    }

    bubbles.shuffle(_rng);

    final id = 'proc_bubble_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';

    return Activity(
      activityId: id,
      topicId: 'topic_counting',
      subjectId: 'math',
      targetGrade: targetGrade,
      gradeTier: GradeTier.earlyExplorer,
      activityType: ActivityType.bubblePop,
      difficultyLevel: difficulty,
      pointsReward: 20,
      promptData: PromptData(
        text: 'Pop all bubbles that equal $target! ($targetGrade Math)',
        ttsFallback: 'Pop all bubbles that equal $target!',
      ),
      interactionPayload: {
        'targetValue': target,
        'bubbles': bubbles,
      },
      validationRule: const ValidationRule(
        format: 'set_match',
        expectedAnswer: [],
      ),
    );
  }

  /// Generates a dynamic question set tailored specifically for a given StudentClass
  List<Activity> generatePlaylistForClass(StudentClass studentClass, {int count = 4}) {
    final list = <Activity>[];
    if (studentClass == StudentClass.class4) {
      // For Class 4, provide a balanced syllabus mixture!
      list.add(generateEquivalentFractions(targetGrade: 'Class 4'));
      list.add(generatePerimeterProblem(targetGrade: 'Class 4'));
      list.add(generateTimeConversion(targetGrade: 'Class 4'));
      list.add(generateCapacityProblem(targetGrade: 'Class 4'));
      list.add(generateDivisionProblem(targetGrade: 'Class 4'));
      return list;
    }

    for (int i = 0; i < count; i++) {
      switch (studentClass.tier) {
        case GradeTier.earlyExplorer:
          list.add(generateBubblePopCounting(
            targetGrade: studentClass.label,
            targetVal: (studentClass == StudentClass.lkg ? 3 + i : 5 + i),
            difficulty: studentClass.gradeNumber + 1,
          ));
          break;
        case GradeTier.primaryBuilder:
          list.add(generateEquivalentFractions(
            targetGrade: studentClass.label,
            difficulty: studentClass.gradeNumber,
          ));
          break;
        case GradeTier.middleAchiever:
          list.add(generateLinearEquation(
            targetGrade: studentClass.label,
            difficulty: max(1, studentClass.gradeNumber - 4),
          ));
          break;
      }
    }
    return list;
  }
}
