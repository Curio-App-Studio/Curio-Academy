/// Transforms mathematical formulas, equations, symbols, fractions, and units
/// into clear, natural phonetic phrases for speech synthesizers (TTS).
///
/// Prevents TTS engines from speaking "-" as "dash", "/" as "slash",
/// "*" as silence, or "___" as "underscore underscore".
class MathSpeechSanitizer {
  static const Map<String, String> _commonFractionsEn = {
    '1/2': 'one half',
    '1/3': 'one third',
    '2/3': 'two thirds',
    '1/4': 'one quarter',
    '3/4': 'three quarters',
    '1/5': 'one fifth',
    '2/5': 'two fifths',
    '3/5': 'three fifths',
    '4/5': 'four fifths',
    '1/6': 'one sixth',
    '5/6': 'five sixths',
    '1/8': 'one eighth',
    '3/8': 'three eighths',
    '5/8': 'five eighths',
    '7/8': 'seven eighths',
    '1/10': 'one tenth',
    '3/10': 'three tenths',
    '7/10': 'seven tenths',
    '9/10': 'nine tenths',
  };

  static const Map<String, String> _commonFractionsHi = {
    '1/2': 'आधा',
    '1/3': 'एक तिहाई',
    '2/3': 'दो तिहाई',
    '1/4': 'एक चौथाई',
    '3/4': 'तीन चौथाई',
    '1/5': 'एक बटा पांच',
    '2/5': 'दो बटा पांच',
    '3/5': 'तीन बटा पांच',
    '4/5': 'चार बटा पांच',
    '1/6': 'एक बटा छह',
    '5/6': 'पांच बटा छह',
    '1/8': 'एक बटा आठ',
    '3/8': 'तीन बटा आठ',
    '5/8': 'पांच बटा आठ',
    '7/8': 'सात बटा आठ',
    '1/10': 'एक बटा दस',
    '3/10': 'तीन बटा दस',
    '7/10': 'सात बटा दस',
    '9/10': 'नौ बटा दस',
  };

  /// Sanitizes text for TTS. Automatically detects Hindi if [isHindi] is omitted.
  static String sanitize(String input, {bool? isHindi}) {
    if (input.trim().isEmpty) return '';

    final bool hindi = isHindi ?? _containsHindi(input);
    String text = input;

    // 1. Remove markdown bold / headers / bullet marks
    text = text.replaceAll('**', '');
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    text = text.replaceAll('•', ', ');

    // 2. Units with slashes (km/h, m/s)
    text = _sanitizeUnits(text, hindi);

    // 3. Numbers range like "pages 5-10" or "Class 1-5" -> "5 to 10"
    text = _sanitizeRanges(text, hindi);

    // 4. Fractions & Mixed numbers (e.g. 3/4, 2 1/2)
    text = _sanitizeFractions(text, hindi);

    // 5. Fill-in-the-blank underscores (___ -> "blank")
    text = _sanitizeBlanks(text, hindi);

    // 6. Equals question mark ("= ?" -> "equals what?")
    text = _sanitizeEqualsQuestion(text, hindi);

    // 7. Exponents and Roots (x^2, 5², √25)
    text = _sanitizeExponentsAndRoots(text, hindi);

    // 8. Math Operators (+, -, *, /, =, <, >, etc.)
    text = _sanitizeOperators(text, hindi);

    // 9. Currency and Percent (₹50, 25%)
    text = _sanitizeCurrencyAndPercent(text, hindi);

    // 10. Strip emojis so speech engine doesn't read symbol names
    text = text.replaceAll(
      RegExp(
        r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE00}-\u{FE0F}]',
        unicode: true,
      ),
      '',
    );

    // 11. Normalize multiple spaces
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  static bool _containsHindi(String text) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(text);
  }

  static String _sanitizeUnits(String text, bool isHindi) {
    if (isHindi) {
      return text
          .replaceAll(RegExp(r'\bkm\s*/\s*h(r)?\b', caseSensitive: false), ' किलोमीटर प्रति घंटा ')
          .replaceAll(RegExp(r'\bm\s*/\s*s(ec)?\b', caseSensitive: false), ' मीटर प्रति सेकंड ')
          .replaceAll(RegExp(r'\bcm\s*/\s*s\b', caseSensitive: false), ' सेंटीमीटर प्रति सेकंड ');
    }
    return text
        .replaceAll(RegExp(r'\bkm\s*/\s*h(r)?\b', caseSensitive: false), ' kilometers per hour ')
        .replaceAll(RegExp(r'\bm\s*/\s*s(ec)?\b', caseSensitive: false), ' meters per second ')
        .replaceAll(RegExp(r'\bcm\s*/\s*s\b', caseSensitive: false), ' centimeters per second ');
  }

  static String _sanitizeRanges(String text, bool isHindi) {
    final toWord = isHindi ? ' से ' : ' to ';
    // Match patterns like "Class 1-5", "pages 10-12", "grades 1–3"
    return text.replaceAllMapped(
      RegExp(r'\b(class|grade|page|pages|questions?|chapters?|step|steps)\s+(\d+)\s*[-–—]\s*(\d+)\b',
          caseSensitive: false),
      (m) => '${m[1]} ${m[2]}$toWord${m[3]}',
    );
  }

  static String _sanitizeFractions(String text, bool isHindi) {
    final fractionsMap = isHindi ? _commonFractionsHi : _commonFractionsEn;

    // Handle mixed numbers first: e.g. "2 1/2" -> "2 and one half"
    for (final entry in fractionsMap.entries) {
      final fracEscaped = RegExp.escape(entry.key);
      final mixedWord = isHindi ? ' और ' : ' and ';
      text = text.replaceAllMapped(
        RegExp(r'\b(\d+)\s+' + fracEscaped + r'\b'),
        (m) => '${m[1]}$mixedWord${entry.value}',
      );
    }

    // Handle standalone common fractions: e.g. "3/4"
    for (final entry in fractionsMap.entries) {
      final fracEscaped = RegExp.escape(entry.key);
      text = text.replaceAllMapped(
        RegExp(r'(^|\s|\()' + fracEscaped + r'($|\s|\)|\.|\?|,|!)'),
        (m) => '${m[1]}${entry.value}${m[2]}',
      );
    }

    // Handle general numerical fractions or division with slash e.g. "12 / 3" or "7/12"
    final divWord = isHindi ? ' बटा ' : ' divided by ';
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*/\s*(\d+)'),
      (m) => '${m[1]}$divWord${m[2]}',
    );

    // Variable division e.g. "x / y" or "(a + b) / c"
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z\)])\s*/\s*([a-zA-Z\(])'),
      (m) => '${m[1]}$divWord${m[2]}',
    );

    return text;
  }

  static String _sanitizeBlanks(String text, bool isHindi) {
    final blankWord = isHindi ? ' खाली स्थान ' : ' blank ';
    // Match 2 or more underscores
    return text.replaceAll(RegExp(r'_{2,}'), blankWord);
  }

  static String _sanitizeEqualsQuestion(String text, bool isHindi) {
    if (isHindi) {
      return text.replaceAll(RegExp(r'=\s*\?'), ' बराबर क्या? ');
    }
    return text.replaceAll(RegExp(r'=\s*\?'), ' equals what? ');
  }

  static String _sanitizeExponentsAndRoots(String text, bool isHindi) {
    // Superscripts
    if (isHindi) {
      text = text.replaceAll('²', ' का वर्ग ').replaceAll('³', ' का घन ');
      text = text.replaceAllMapped(RegExp(r'\^2\b'), (m) => ' का वर्ग ');
      text = text.replaceAllMapped(RegExp(r'\^3\b'), (m) => ' का घन ');
      text = text.replaceAllMapped(RegExp(r'\^(\d+)\b'), (m) => ' की घात ${m[1]} ');
      text = text.replaceAllMapped(RegExp(r'√\s*(\d+)'), (m) => ' ${m[1]} का वर्गमूल ');
    } else {
      text = text.replaceAll('²', ' squared ').replaceAll('³', ' cubed ');
      text = text.replaceAllMapped(RegExp(r'\^2\b'), (m) => ' squared ');
      text = text.replaceAllMapped(RegExp(r'\^3\b'), (m) => ' cubed ');
      text = text.replaceAllMapped(RegExp(r'\^(\d+)\b'), (m) => ' to the power of ${m[1]} ');
      text = text.replaceAllMapped(RegExp(r'√\s*(\d+)'), (m) => ' square root of ${m[1]} ');
    }

    text = text.replaceAll('√', isHindi ? ' वर्गमूल ' : ' square root of ');
    text = text.replaceAll('π', isHindi ? ' पाई ' : ' pi ');
    return text;
  }

  static String _sanitizeOperators(String text, bool isHindi) {
    final plus = isHindi ? ' प्लस ' : ' plus ';
    final minus = isHindi ? ' माइनस ' : ' minus ';
    final multiplied = isHindi ? ' गुणा ' : ' multiplied by ';
    final divided = isHindi ? ' भाग ' : ' divided by ';
    final equals = isHindi ? ' बराबर ' : ' equals ';
    final notEquals = isHindi ? ' बराबर नहीं ' : ' does not equal ';
    final lessThan = isHindi ? ' से छोटा ' : ' is less than ';
    final greaterThan = isHindi ? ' से बड़ा ' : ' is greater than ';
    final lessOrEqual = isHindi ? ' से छोटा या बराबर ' : ' is less than or equal to ';
    final greaterOrEqual = isHindi ? ' से बड़ा या बराबर ' : ' is greater than or equal to ';
    final plusOrMinus = isHindi ? ' प्लस या माइनस ' : ' plus or minus ';

    // 1. Plus
    text = text.replaceAll('+', plus);
    text = text.replaceAll('±', plusOrMinus);

    // 2. Division symbols
    text = text.replaceAll('÷', divided);

    // 3. Multiplication symbols (× or standalone *)
    text = text.replaceAll('×', multiplied);
    // Standalone * between numbers/symbols or spaces (not markdown)
    text = text.replaceAllMapped(
      RegExp(r'(\d|[a-zA-Z\)])\s*\*+\s*(\d|[a-zA-Z\(])'),
      (m) => '${m[1]}$multiplied${m[2]}',
    );
    text = text.replaceAll('*', ''); // Clean any lingering markdown asterisks

    // 4. Relations and inequalities
    text = text.replaceAll('≠', notEquals);
    text = text.replaceAll('!=', notEquals);
    text = text.replaceAll('<=', lessOrEqual);
    text = text.replaceAll('>=', greaterOrEqual);
    text = text.replaceAll('≤', lessOrEqual);
    text = text.replaceAll('≥', greaterOrEqual);

    // Subtraction and minus:
    // IMPORTANT: Preserve hyphenated English words like "step-by-step", "two-digit", "part-to-whole"
    // Match any minus/dash character: '-' (\u002D), '−' (\u2212), '–' (\u2013), '—' (\u2014)

    // A. Between numbers: e.g. "15 - 7" or "15-7" or "15 – 7"
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*[-−–—]\s*(\d+)'),
      (m) => '${m[1]}$minus${m[2]}',
    );

    // B. Between a parenthesis or number and variable/parenthesis: e.g. "(x + 1) - 5", "5 - x", "(a) - (b)"
    text = text.replaceAllMapped(
      RegExp(r'(\)|\d)\s*[-−–—]\s*([a-zA-Z\(])'),
      (m) => '${m[1]}$minus${m[2]}',
    );
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z])\s*[-−–—]\s*(\d|\()'),
      (m) => '${m[1]}$minus${m[2]}',
    );

    // C. Between single variables with spaces around dash: e.g. "x - y", "a - b"
    text = text.replaceAllMapped(
      RegExp(r'\b([a-zA-Z])\s+[-−–—]\s+([a-zA-Z])\b'),
      (m) => '${m[1]}$minus${m[2]}',
    );

    // D. Spaced dashes (e.g. " 15 - 7 " or " - ")
    text = text.replaceAll(RegExp(r'\s+[-−–—]\s+'), minus);

    // E. Negative numbers after operators or start of prompt: e.g. "=-5", "(-7)", "-10 + 4"
    final negativePrefix = isHindi ? ' माइनस ' : ' negative ';
    text = text.replaceAllMapped(
      RegExp(r'(^|[\s(=+*×÷/<>≤≥≠])[-−–—](\d+)'),
      (m) => '${m[1]}$negativePrefix${m[2]}',
    );

    // F. Equals sign
    text = text.replaceAll('==', equals);
    text = text.replaceAll('=', equals);

    // G. Less than / Greater than between numbers or single variables
    text = text.replaceAllMapped(
      RegExp(r'(\d|[a-zA-Z])\s*<\s*(\d|[a-zA-Z])'),
      (m) => '${m[1]}$lessThan${m[2]}',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\d|[a-zA-Z])\s*>\s*(\d|[a-zA-Z])'),
      (m) => '${m[1]}$greaterThan${m[2]}',
    );

    return text;
  }

  static String _sanitizeCurrencyAndPercent(String text, bool isHindi) {
    if (isHindi) {
      text = text.replaceAllMapped(RegExp(r'₹\s*(\d+)'), (m) => '${m[1]} रुपये ');
      text = text.replaceAllMapped(RegExp(r'\$\s*(\d+)'), (m) => '${m[1]} डॉलर ');
      text = text.replaceAllMapped(RegExp(r'(\d+)\s*%'), (m) => '${m[1]} प्रतिशत ');
    } else {
      text = text.replaceAllMapped(RegExp(r'₹\s*(\d+)'), (m) => '${m[1]} rupees ');
      text = text.replaceAllMapped(RegExp(r'\$\s*(\d+)'), (m) => '${m[1]} dollars ');
      text = text.replaceAllMapped(RegExp(r'(\d+)\s*%'), (m) => '${m[1]} percent ');
    }
    return text;
  }
}
