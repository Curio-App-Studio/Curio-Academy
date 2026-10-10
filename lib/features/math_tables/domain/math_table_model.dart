/// Represents a single multiplication equation line (e.g. 7 × 8 = 56).
class MathTableRow {
  final int tableNumber;
  final int multiplier;
  final int product;
  final String repeatedAddition;
  final String chantEn;
  final String chantHi;

  const MathTableRow({
    required this.tableNumber,
    required this.multiplier,
    required this.product,
    required this.repeatedAddition,
    required this.chantEn,
    required this.chantHi,
  });

  String get formula => '$tableNumber × $multiplier = $product';
}

/// Represents a full multiplication table with tricks and mnemonic aids.
class MathTableData {
  final int number;
  final List<MathTableRow> rows;
  final String trickTitle;
  final String trickDescription;
  final String trickTitleHi;
  final String trickDescriptionHi;

  const MathTableData({
    required this.number,
    required this.rows,
    required this.trickTitle,
    required this.trickDescription,
    required this.trickTitleHi,
    required this.trickDescriptionHi,
  });

  /// Generates the standard multiplication table for [tableNumber] up to [maxMultiplier] (default 10 or 12).
  factory MathTableData.generate(int tableNumber, {int maxMultiplier = 10}) {
    final List<MathTableRow> rows = [];
    final trick = _getTrickForNumber(tableNumber);

    for (int i = 1; i <= maxMultiplier; i++) {
      final product = tableNumber * i;
      final repeated = List.filled(i, '$tableNumber').join(' + ');

      // Traditional & rhythm chants
      final chantEn = '$tableNumber times $i is $product';
      final chantHi = _getHindiChant(tableNumber, i, product);

      rows.add(
        MathTableRow(
          tableNumber: tableNumber,
          multiplier: i,
          product: product,
          repeatedAddition: repeated,
          chantEn: chantEn,
          chantHi: chantHi,
        ),
      );
    }

    return MathTableData(
      number: tableNumber,
      rows: rows,
      trickTitle: trick.titleEn,
      trickDescription: trick.descEn,
      trickTitleHi: trick.titleHi,
      trickDescriptionHi: trick.descHi,
    );
  }

  static String _getHindiChant(int n, int m, int prod) {
    const hindiSuffixes = [
      '',
      'एकम',    // 1
      'दूनी',    // 2
      'तिया',    // 3
      'चौके',    // 4
      'पंजे',    // 5
      'छक्के',   // 6
      'सत्ते',    // 7
      'अट्ठे',    // 8
      'नम्मे',    // 9
      'दहाई',   // 10
      'ग्यारह', // 11
      'बारह',   // 12
    ];

    final suffix = m < hindiSuffixes.length ? hindiSuffixes[m] : 'गुणा $m';
    return '$n $suffix $prod';
  }

  static _TableTrick _getTrickForNumber(int n) {
    switch (n) {
      case 1:
        return const _TableTrick(
          titleEn: 'Identity Magic 🌟',
          descEn: 'Any number multiplied by 1 stays completely unchanged! It is like looking into a mirror.',
          titleHi: 'आईना नियम 🌟',
          descHi: 'किसी भी संख्या को 1 से गुणा करने पर वही संख्या मिलती है। यह आईने जैसा है!',
        );
      case 2:
        return const _TableTrick(
          titleEn: 'Double Trouble & Even Numbers ✌️',
          descEn: 'Multiplying by 2 is just doubling! Every answer ends in an even digit: 0, 2, 4, 6, or 8.',
          titleHi: 'दोगुना करने का नियम ✌️',
          descHi: '2 का पहाड़ा यानी बस संख्या को दोगुना करना! सभी उत्तर सम (0, 2, 4, 6, 8) पर खत्म होते हैं।',
        );
      case 3:
        return const _TableTrick(
          titleEn: 'Digit Sum Mystery 🔍',
          descEn: 'Add the digits of any answer in the 3s table! The sum will always be 3, 6, or 9.',
          titleHi: 'अंकों का जोड़ रहस्य 🔍',
          descHi: 'उत्तर के अंकों को जोड़ें! जोड़ हमेशा 3, 6 या 9 ही आएगा (उदा: 12 -> 1+2=3, 27 -> 2+7=9)।',
        );
      case 4:
        return const _TableTrick(
          titleEn: 'Double the Double ⚡',
          descEn: 'To multiply by 4, just double the number twice! For 4 × 6: double 6 is 12, double 12 is 24!',
          titleHi: 'दोगुने का दोगुना ⚡',
          descHi: '4 से गुणा करने के लिए संख्या को दो बार दोगुना करें! 4 × 6: 6 का दोगुना 12, 12 का दोगुना 24!',
        );
      case 5:
        return const _TableTrick(
          titleEn: 'Clock & Coin Rhythm ⏰',
          descEn: 'Look at the minutes on a clock! Every answer in the 5s table ends in either 5 or 0 alternately.',
          titleHi: 'घड़ी की सुई का जादू ⏰',
          descHi: '5 के पहाड़े में हर उत्तर के अंत में बारी-बारी से 5 या 0 आता है (5, 10, 15, 20...)!',
        );
      case 6:
        return const _TableTrick(
          titleEn: 'Even Partner Pattern 🤝',
          descEn: 'When multiplying 6 by an even number, the last digit matches! 6 × 2 = 12, 6 × 4 = 24, 6 × 8 = 48!',
          titleHi: 'सम संख्या जोड़ीदार 🤝',
          descHi: 'जब 6 को किसी सम संख्या से गुणा करते हैं, तो इकाई का अंक वही होता है (6×2=12, 6×4=24, 6×8=48)!',
        );
      case 7:
        return const _TableTrick(
          titleEn: 'Lucky Seven Days in a Week 📅',
          descEn: 'Think of weeks! 1 week = 7 days, 2 weeks = 14 days, 3 weeks = 21 days, 4 weeks = 28 days.',
          titleHi: 'सप्ताह के 7 दिन 📅',
          descHi: 'हफ़्ते के दिनों से याद रखें! 1 हफ़्ता = 7 दिन, 2 हफ़्ते = 14 दिन, 3 हफ़्ते = 21 दिन, 4 हफ़्ते = 28 दिन।',
        );
      case 8:
        return const _TableTrick(
          titleEn: 'Triple Double Rocket 🚀',
          descEn: 'Double it three times! To find 8 × 7: double 7 is 14, double 14 is 28, double 28 is 56!',
          titleHi: 'तीन बार दोगुना 🚀',
          descHi: 'संख्या को 3 बार दोगुना करें! 8 × 7: 7 का 14, 14 का 28, और 28 का दोगुना 56!',
        );
      case 9:
        return const _TableTrick(
          titleEn: 'Magic Fingers & Sum of 9 🖐️',
          descEn: 'Tens digit goes up (0,1,2,3...), units digit goes down (9,8,7,6...)! Also, digits always add to 9!',
          titleHi: 'जादुई 9 का नियम 🖐️',
          descHi: 'दहाई का अंक 0 से 9 तक बढ़ता है और इकाई का अंक 9 से 0 तक घटता है! अंकों का जोड़ हमेशा 9 होता है!',
        );
      case 10:
        return const _TableTrick(
          titleEn: 'The Zero Hero 🦸',
          descEn: 'Simply stick a zero (0) at the end of the number! 10 × 7 = 70. Fast and effortless!',
          titleHi: 'शून्य का कमाल 🦸',
          descHi: 'संख्या के अंत में बस एक शून्य (0) लगा दें! 10 × 7 = 70. सबसे आसान!',
        );
      case 11:
        return const _TableTrick(
          titleEn: 'Double Digit Twins 👯',
          descEn: 'For 1 to 9, just repeat the digit twice: 11, 22, 33, 44, 55, 66, 77, 88, 99!',
          titleHi: 'जुड़वां अंक नियम 👯',
          descHi: '1 से 9 तक बस अंक को दो बार लिखें: 11, 22, 33, 44, 55, 66, 77, 88, 99!',
        );
      case 12:
        return const _TableTrick(
          titleEn: 'Dozen Master (10 + 2) 📦',
          descEn: 'A dozen is 12! Split 12 into 10 + 2: multiply by 10, multiply by 2, and add them together!',
          titleHi: 'एक दर्जन का नियम (10 + 2) 📦',
          descHi: '12 को 10 + 2 में बांटें: पहले 10 से गुणा करें, फिर 2 से गुणा करें, और दोनों को जोड़ लें!',
        );
      default:
        return _TableTrick(
          titleEn: 'Split & Add Strategy 🧩',
          descEn: 'Split $n into 10 and ${n - 10}! Multiply each part separately and add together.',
          titleHi: 'विभाजित करें और जोड़ें 🧩',
          descHi: '$n को 10 और ${n - 10} में तोड़ें! दोनों से अलग-अलग गुणा करके जोड़ लें।',
        );
    }
  }
}

class _TableTrick {
  final String titleEn;
  final String descEn;
  final String titleHi;
  final String descHi;

  const _TableTrick({
    required this.titleEn,
    required this.descEn,
    required this.titleHi,
    required this.descHi,
  });
}

/// A fill-in-the-blank or quiz question for tables practice.
class TableQuestion {
  final int tableNumber;
  final int multiplier;
  final int product;
  final int missingIndex; // 0 for tableNumber, 1 for multiplier, 2 for product
  final List<int> options;

  const TableQuestion({
    required this.tableNumber,
    required this.multiplier,
    required this.product,
    required this.missingIndex,
    required this.options,
  });

  int get correctAnswer {
    switch (missingIndex) {
      case 0:
        return tableNumber;
      case 1:
        return multiplier;
      default:
        return product;
    }
  }

  String get promptEquation {
    switch (missingIndex) {
      case 0:
        return '? × $multiplier = $product';
      case 1:
        return '$tableNumber × ? = $product';
      default:
        return '$tableNumber × $multiplier = ?';
    }
  }

  /// Generates 10 quiz questions for [tableNumber].
  static List<TableQuestion> generateQuiz(int tableNumber, {int count = 10, int maxMultiplier = 10}) {
    return generateMultiTableQuiz([tableNumber], count: count, maxMultiplier: maxMultiplier);
  }

  /// Generates quiz questions spanning multiple tables from [tableNumbers].
  static List<TableQuestion> generateMultiTableQuiz(
    List<int> tableNumbers, {
    int count = 10,
    int maxMultiplier = 10,
  }) {
    if (tableNumbers.isEmpty) {
      tableNumbers = [2];
    }

    // Build all possible (table, multiplier) combinations
    final List<MapEntry<int, int>> pairs = [];
    for (final t in tableNumbers) {
      for (int m = 1; m <= maxMultiplier; m++) {
        pairs.add(MapEntry(t, m));
      }
    }
    pairs.shuffle();

    final List<TableQuestion> questions = [];
    for (int i = 0; i < count && i < pairs.length; i++) {
      final pair = pairs[i];
      final t = pair.key;
      final m = pair.value;
      final prod = t * m;
      final missingIdx = (i % 3 == 2) ? 1 : 2;
      final correct = (missingIdx == 1) ? m : prod;

      final Set<int> distractors = {correct};
      final deltas = [-3, -2, -1, 1, 2, 3, t, -t];
      deltas.shuffle();

      for (final d in deltas) {
        final candidate = correct + d;
        if (candidate > 0 && candidate != correct) {
          distractors.add(candidate);
        }
        if (distractors.length == 4) break;
      }

      while (distractors.length < 4) {
        distractors.add(correct + distractors.length);
      }

      final opts = distractors.toList()..shuffle();

      questions.add(
        TableQuestion(
          tableNumber: t,
          multiplier: m,
          product: prod,
          missingIndex: missingIdx,
          options: opts,
        ),
      );
    }

    return questions;
  }
}
