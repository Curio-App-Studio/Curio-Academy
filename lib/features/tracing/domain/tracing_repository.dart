import 'package:flutter/material.dart';
import 'tracing_character.dart';

class TracingRepository {
  static final TracingRepository instance = TracingRepository._();
  TracingRepository._();

  List<TracingCharacter> getCharactersByCategory(TracingCategory category) {
    switch (category) {
      case TracingCategory.englishUpper:
        return _englishUpperList;
      case TracingCategory.englishLower:
        return _englishLowerList;
      case TracingCategory.numbers:
        return _numbersList;
      case TracingCategory.hindiSwar:
        return _hindiSwarList;
      case TracingCategory.hindiVyanjan:
        return _hindiVyanjanList;
    }
  }

  // --- English Uppercase A-Z ---
  static const List<TracingCharacter> _englishUpperList = [
    TracingCharacter(id: 'en_u_a', character: 'A', titleEn: 'A for Apple', titleHi: 'A फॉर ऍपल', emoji: '🍎', soundPromptEn: 'A for Apple', soundPromptHi: 'ए फॉर एप्पल', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_b', character: 'B', titleEn: 'B for Ball', titleHi: 'B फॉर बॉल', emoji: '⚽', soundPromptEn: 'B for Ball', soundPromptHi: 'बी फॉर बॉल', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_c', character: 'C', titleEn: 'C for Cat', titleHi: 'C फॉर कैट', emoji: '🐱', soundPromptEn: 'C for Cat', soundPromptHi: 'सी फॉर कैट', category: TracingCategory.englishUpper, startHint: Offset(0.7, 0.3)),
    TracingCharacter(id: 'en_u_d', character: 'D', titleEn: 'D for Dog', titleHi: 'D फॉर डॉग', emoji: '🐶', soundPromptEn: 'D for Dog', soundPromptHi: 'डी फॉर डॉग', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_e', character: 'E', titleEn: 'E for Elephant', titleHi: 'E फॉर एलिफेंट', emoji: '🐘', soundPromptEn: 'E for Elephant', soundPromptHi: 'ई फॉर एलिफेंट', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_f', character: 'F', titleEn: 'F for Fish', titleHi: 'F फॉर फिश', emoji: '🐟', soundPromptEn: 'F for Fish', soundPromptHi: 'एफ फॉर फिश', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_g', character: 'G', titleEn: 'G for Grapes', titleHi: 'G फॉर ग्रेप्स', emoji: '🍇', soundPromptEn: 'G for Grapes', soundPromptHi: 'जी फॉर ग्रेप्स', category: TracingCategory.englishUpper, startHint: Offset(0.7, 0.3)),
    TracingCharacter(id: 'en_u_h', character: 'H', titleEn: 'H for Horse', titleHi: 'H फॉर हॉर्स', emoji: '🐴', soundPromptEn: 'H for Horse', soundPromptHi: 'एच फॉर हॉर्स', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_i', character: 'I', titleEn: 'I for Ice cream', titleHi: 'I फॉर आइसक्रीम', emoji: '🍦', soundPromptEn: 'I for Ice cream', soundPromptHi: 'आई फॉर आइसक्रीम', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_j', character: 'J', titleEn: 'J for Jug', titleHi: 'J फॉर जग', emoji: '🫖', soundPromptEn: 'J for Jug', soundPromptHi: 'जे फॉर जग', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_k', character: 'K', titleEn: 'K for Kite', titleHi: 'K फॉर काइट', emoji: '🪁', soundPromptEn: 'K for Kite', soundPromptHi: 'के फॉर काइट', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_l', character: 'L', titleEn: 'L for Lion', titleHi: 'L फॉर लायन', emoji: '🦁', soundPromptEn: 'L for Lion', soundPromptHi: 'एल फॉर लायन', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_m', character: 'M', titleEn: 'M for Mango', titleHi: 'M फॉर मैंगो', emoji: '🥭', soundPromptEn: 'M for Mango', soundPromptHi: 'एम फॉर मैंगो', category: TracingCategory.englishUpper, startHint: Offset(0.25, 0.8)),
    TracingCharacter(id: 'en_u_n', character: 'N', titleEn: 'N for Nest', titleHi: 'N फॉर नेस्ट', emoji: '🪺', soundPromptEn: 'N for Nest', soundPromptHi: 'एन फॉर नेस्ट', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.8)),
    TracingCharacter(id: 'en_u_o', character: 'O', titleEn: 'O for Orange', titleHi: 'O फॉर ऑरेंज', emoji: '🍊', soundPromptEn: 'O for Orange', soundPromptHi: 'ओ फॉर ऑरेंज', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_p', character: 'P', titleEn: 'P for Parrot', titleHi: 'P फॉर पैरट', emoji: '🦜', soundPromptEn: 'P for Parrot', soundPromptHi: 'पी फॉर पैरट', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_q', character: 'Q', titleEn: 'Q for Queen', titleHi: 'Q फॉर क्वीन', emoji: '👑', soundPromptEn: 'Q for Queen', soundPromptHi: 'क्यू फॉर क्वीन', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_r', character: 'R', titleEn: 'R for Rabbit', titleHi: 'R फॉर रैबिट', emoji: '🐰', soundPromptEn: 'R for Rabbit', soundPromptHi: 'आर फॉर रैबिट', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_s', character: 'S', titleEn: 'S for Sun', titleHi: 'S फॉर सन', emoji: '☀️', soundPromptEn: 'S for Sun', soundPromptHi: 'एस फॉर सन', category: TracingCategory.englishUpper, startHint: Offset(0.7, 0.3)),
    TracingCharacter(id: 'en_u_t', character: 'T', titleEn: 'T for Tiger', titleHi: 'T फॉर टाइगर', emoji: '🐯', soundPromptEn: 'T for Tiger', soundPromptHi: 'टी फॉर टाइगर', category: TracingCategory.englishUpper, startHint: Offset(0.5, 0.2)),
    TracingCharacter(id: 'en_u_u', character: 'U', titleEn: 'U for Umbrella', titleHi: 'U फॉर अम्ब्रेला', emoji: '☂️', soundPromptEn: 'U for Umbrella', soundPromptHi: 'यू फॉर अम्ब्रेला', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_v', character: 'V', titleEn: 'V for Van', titleHi: 'V फॉर वैन', emoji: '🚐', soundPromptEn: 'V for Van', soundPromptHi: 'वी फॉर वैन', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_w', character: 'W', titleEn: 'W for Watch', titleHi: 'W फॉर वॉच', emoji: '⌚', soundPromptEn: 'W for Watch', soundPromptHi: 'डब्लू फॉर वॉच', category: TracingCategory.englishUpper, startHint: Offset(0.25, 0.2)),
    TracingCharacter(id: 'en_u_x', character: 'X', titleEn: 'X for Xylophone', titleHi: 'X फॉर जाइलोफोन', emoji: '🎵', soundPromptEn: 'X for Xylophone', soundPromptHi: 'एक्स फॉर जाइलोफोन', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_y', character: 'Y', titleEn: 'Y for Yak', titleHi: 'Y फॉर याक', emoji: '🐂', soundPromptEn: 'Y for Yak', soundPromptHi: 'वाई फॉर याक', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
    TracingCharacter(id: 'en_u_z', character: 'Z', titleEn: 'Z for Zebra', titleHi: 'Z फॉर ज़ेब्रा', emoji: '🦓', soundPromptEn: 'Z for Zebra', soundPromptHi: 'ज़ेड फॉर ज़ेब्रा', category: TracingCategory.englishUpper, startHint: Offset(0.3, 0.2)),
  ];

  // --- English Lowercase a-z ---
  static const List<TracingCharacter> _englishLowerList = [
    TracingCharacter(id: 'en_l_a', character: 'a', titleEn: 'small a for apple', titleHi: 'छोटा a फॉर ऍपल', emoji: '🍎', soundPromptEn: 'small a for apple', soundPromptHi: 'छोटा ए', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_b', character: 'b', titleEn: 'small b for ball', titleHi: 'छोटा b फॉर बॉल', emoji: '⚽', soundPromptEn: 'small b for ball', soundPromptHi: 'छोटा बी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_c', character: 'c', titleEn: 'small c for cat', titleHi: 'छोटा c फॉर कैट', emoji: '🐱', soundPromptEn: 'small c for cat', soundPromptHi: 'छोटा सी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_d', character: 'd', titleEn: 'small d for dog', titleHi: 'छोटा d फॉर डॉग', emoji: '🐶', soundPromptEn: 'small d for dog', soundPromptHi: 'छोटा डी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_e', character: 'e', titleEn: 'small e for egg', titleHi: 'छोटा e फॉर एग', emoji: '🥚', soundPromptEn: 'small e for egg', soundPromptHi: 'छोटा ई', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_f', character: 'f', titleEn: 'small f for fan', titleHi: 'छोटा f फॉर फैन', emoji: '🪭', soundPromptEn: 'small f for fan', soundPromptHi: 'छोटा एफ', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_g', character: 'g', titleEn: 'small g for goat', titleHi: 'छोटा g फॉर गोट', emoji: '🐐', soundPromptEn: 'small g for goat', soundPromptHi: 'छोटा जी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_h', character: 'h', titleEn: 'small h for hat', titleHi: 'छोटा h फॉर हैट', emoji: '👒', soundPromptEn: 'small h for hat', soundPromptHi: 'छोटा एच', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_i', character: 'i', titleEn: 'small i for ink', titleHi: 'छोटा i फॉर इंक', emoji: '🖋️', soundPromptEn: 'small i for ink', soundPromptHi: 'छोटा आई', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_j', character: 'j', titleEn: 'small j for jar', titleHi: 'छोटा j फॉर जार', emoji: '🍯', soundPromptEn: 'small j for jar', soundPromptHi: 'छोटा जे', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_k', character: 'k', titleEn: 'small k for key', titleHi: 'छोटा k फॉर की', emoji: '🔑', soundPromptEn: 'small k for key', soundPromptHi: 'छोटा के', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_l', character: 'l', titleEn: 'small l for leaf', titleHi: 'छोटा l फॉर लीफ', emoji: '🍃', soundPromptEn: 'small l for leaf', soundPromptHi: 'छोटा एल', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_m', character: 'm', titleEn: 'small m for moon', titleHi: 'छोटा m फॉर मून', emoji: '🌙', soundPromptEn: 'small m for moon', soundPromptHi: 'छोटा एम', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_n', character: 'n', titleEn: 'small n for net', titleHi: 'छोटा n फॉर नेट', emoji: '🥅', soundPromptEn: 'small n for net', soundPromptHi: 'छोटा एन', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_o', character: 'o', titleEn: 'small o for owl', titleHi: 'छोटा o फॉर आउल', emoji: '🦉', soundPromptEn: 'small o for owl', soundPromptHi: 'छोटा ओ', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_p', character: 'p', titleEn: 'small p for pen', titleHi: 'छोटा p फॉर पेन', emoji: '🖊️', soundPromptEn: 'small p for pen', soundPromptHi: 'छोटा पी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_q', character: 'q', titleEn: 'small q for quilt', titleHi: 'छोटा q फॉर क्विल्ट', emoji: '🛏️', soundPromptEn: 'small q for quilt', soundPromptHi: 'छोटा क्यू', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_r', character: 'r', titleEn: 'small r for rose', titleHi: 'छोटा r फॉर रोज़', emoji: '🌹', soundPromptEn: 'small r for rose', soundPromptHi: 'छोटा आर', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_s', character: 's', titleEn: 'small s for star', titleHi: 'छोटा s फॉर स्टार', emoji: '⭐', soundPromptEn: 'small s for star', soundPromptHi: 'छोटा एस', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_t', character: 't', titleEn: 'small t for tree', titleHi: 'छोटा t फॉर ट्री', emoji: '🌳', soundPromptEn: 'small t for tree', soundPromptHi: 'छोटा टी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_u', character: 'u', titleEn: 'small u for urn', titleHi: 'छोटा u फॉर अर्न', emoji: '🏺', soundPromptEn: 'small u for urn', soundPromptHi: 'छोटा यू', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_v', character: 'v', titleEn: 'small v for vase', titleHi: 'छोटा v फॉर वेस', emoji: '🏺', soundPromptEn: 'small v for vase', soundPromptHi: 'छोटा वी', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_w', character: 'w', titleEn: 'small w for water', titleHi: 'छोटा w फॉर वॉटर', emoji: '💧', soundPromptEn: 'small w for water', soundPromptHi: 'छोटा डब्लू', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_x', character: 'x', titleEn: 'small x for box', titleHi: 'छोटा x फॉर बॉक्स', emoji: '📦', soundPromptEn: 'small x for box', soundPromptHi: 'छोटा एक्स', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_y', character: 'y', titleEn: 'small y for yarn', titleHi: 'छोटा y फॉर यार्न', emoji: '🧶', soundPromptEn: 'small y for yarn', soundPromptHi: 'छोटा वाई', category: TracingCategory.englishLower),
    TracingCharacter(id: 'en_l_z', character: 'z', titleEn: 'small z for zip', titleHi: 'छोटा z फॉर ज़िप', emoji: '🤐', soundPromptEn: 'small z for zip', soundPromptHi: 'छोटा ज़ेड', category: TracingCategory.englishLower),
  ];

  // --- Numbers 1 to 20 ---
  static const List<TracingCharacter> _numbersList = [
    TracingCharacter(id: 'num_1', character: '1', titleEn: 'Number 1 (One)', titleHi: 'संख्या 1 (एक)', emoji: '🥇', soundPromptEn: 'Number One', soundPromptHi: 'एक', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_2', character: '2', titleEn: 'Number 2 (Two)', titleHi: 'संख्या 2 (दो)', emoji: '✌️', soundPromptEn: 'Number Two', soundPromptHi: 'दो', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_3', character: '3', titleEn: 'Number 3 (Three)', titleHi: 'संख्या 3 (तीन)', emoji: '🥉', soundPromptEn: 'Number Three', soundPromptHi: 'तीन', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_4', character: '4', titleEn: 'Number 4 (Four)', titleHi: 'संख्या 4 (चार)', emoji: '🍀', soundPromptEn: 'Number Four', soundPromptHi: 'चार', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_5', character: '5', titleEn: 'Number 5 (Five)', titleHi: 'संख्या 5 (पाँच)', emoji: '🖐️', soundPromptEn: 'Number Five', soundPromptHi: 'पाँच', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_6', character: '6', titleEn: 'Number 6 (Six)', titleHi: 'संख्या 6 (छह)', emoji: '🎲', soundPromptEn: 'Number Six', soundPromptHi: 'छह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_7', character: '7', titleEn: 'Number 7 (Seven)', titleHi: 'संख्या 7 (सात)', emoji: '🌈', soundPromptEn: 'Number Seven', soundPromptHi: 'सात', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_8', character: '8', titleEn: 'Number 8 (Eight)', titleHi: 'संख्या 8 (आठ)', emoji: '🎱', soundPromptEn: 'Number Eight', soundPromptHi: 'आठ', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_9', character: '9', titleEn: 'Number 9 (Nine)', titleHi: 'संख्या 9 (नौ)', emoji: '🎈', soundPromptEn: 'Number Nine', soundPromptHi: 'नौ', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_10', character: '10', titleEn: 'Number 10 (Ten)', titleHi: 'संख्या 10 (दस)', emoji: '🔟', soundPromptEn: 'Number Ten', soundPromptHi: 'दस', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_11', character: '11', titleEn: 'Number 11 (Eleven)', titleHi: 'संख्या 11 (ग्यारह)', emoji: '🥢', soundPromptEn: 'Number Eleven', soundPromptHi: 'ग्यारह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_12', character: '12', titleEn: 'Number 12 (Twelve)', titleHi: 'संख्या 12 (बारह)', emoji: '🕛', soundPromptEn: 'Number Twelve', soundPromptHi: 'बारह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_13', character: '13', titleEn: 'Number 13 (Thirteen)', titleHi: 'संख्या 13 (तेरह)', emoji: '✨', soundPromptEn: 'Number Thirteen', soundPromptHi: 'तेरह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_14', character: '14', titleEn: 'Number 14 (Fourteen)', titleHi: 'संख्या 14 (चौदह)', emoji: '🌟', soundPromptEn: 'Number Fourteen', soundPromptHi: 'चौदह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_15', character: '15', titleEn: 'Number 15 (Fifteen)', titleHi: 'संख्या 15 (पंद्रह)', emoji: '🌕', soundPromptEn: 'Number Fifteen', soundPromptHi: 'पंद्रह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_16', character: '16', titleEn: 'Number 16 (Sixteen)', titleHi: 'संख्या 16 (सोलह)', emoji: '🎯', soundPromptEn: 'Number Sixteen', soundPromptHi: 'सोलह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_17', character: '17', titleEn: 'Number 17 (Seventeen)', titleHi: 'संख्या 17 (सत्रह)', emoji: '🎨', soundPromptEn: 'Number Seventeen', soundPromptHi: 'सत्रह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_18', character: '18', titleEn: 'Number 18 (Eighteen)', titleHi: 'संख्या 18 (अठारह)', emoji: '🚀', soundPromptEn: 'Number Eighteen', soundPromptHi: 'अठारह', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_19', character: '19', titleEn: 'Number 19 (Nineteen)', titleHi: 'संख्या 19 (उन्नीस)', emoji: '💎', soundPromptEn: 'Number Nineteen', soundPromptHi: 'उन्नीस', category: TracingCategory.numbers),
    TracingCharacter(id: 'num_20', character: '20', titleEn: 'Number 20 (Twenty)', titleHi: 'संख्या 20 (बीस)', emoji: '👑', soundPromptEn: 'Number Twenty', soundPromptHi: 'बीस', category: TracingCategory.numbers),
  ];

  // --- Hindi Swar (अ - अः) ---
  static const List<TracingCharacter> _hindiSwarList = [
    TracingCharacter(id: 'hi_s_a', character: 'अ', titleEn: 'A - Anar', titleHi: 'अ से अनार', emoji: '🍎', soundPromptEn: 'A se Anar', soundPromptHi: 'अ से अनार', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_aa', character: 'आ', titleEn: 'Aa - Aam', titleHi: 'आ से आम', emoji: '🥭', soundPromptEn: 'Aa se Aam', soundPromptHi: 'आ से आम', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_i', character: 'इ', titleEn: 'I - Imli', titleHi: 'इ से इमली', emoji: '🫒', soundPromptEn: 'I se Imli', soundPromptHi: 'इ से इमली', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_ee', character: 'ई', titleEn: 'Ee - Eekh', titleHi: 'ई से ईख', emoji: '🎋', soundPromptEn: 'Ee se Eekh', soundPromptHi: 'ई से ईख', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_u', character: 'उ', titleEn: 'U - Ullu', titleHi: 'उ से उल्लू', emoji: '🦉', soundPromptEn: 'U se Ullu', soundPromptHi: 'उ से उल्लू', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_oo', character: 'ऊ', titleEn: 'Oo - Oon', titleHi: 'ऊ से ऊन', emoji: '🧶', soundPromptEn: 'Oo se Oon', soundPromptHi: 'ऊ से ऊन', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_ri', character: 'ऋ', titleEn: 'Ri - Rishi', titleHi: 'ऋ से ऋषि', emoji: '🧘', soundPromptEn: 'Ri se Rishi', soundPromptHi: 'ऋ से ऋषि', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_e', character: 'ए', titleEn: 'E - Ek', titleHi: 'ए से एक', emoji: '1️⃣', soundPromptEn: 'E se Ek', soundPromptHi: 'ए से एक', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_ai', character: 'ऐ', titleEn: 'Ai - Ainak', titleHi: 'ऐ से ऐनक', emoji: '👓', soundPromptEn: 'Ai se Ainak', soundPromptHi: 'ऐ से ऐनक', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_o', character: 'ओ', titleEn: 'O - Okhli', titleHi: 'ओ से ओखली', emoji: '🥣', soundPromptEn: 'O se Okhli', soundPromptHi: 'ओ से ओखली', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_au', character: 'औ', titleEn: 'Au - Aurat', titleHi: 'औ से औरत', emoji: '👩', soundPromptEn: 'Au se Aurat', soundPromptHi: 'औ से औरत', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_ang', character: 'अं', titleEn: 'Ang - Angoor', titleHi: 'अं से अंगूर', emoji: '🍇', soundPromptEn: 'Ang se Angoor', soundPromptHi: 'अं से अंगूर', category: TracingCategory.hindiSwar),
    TracingCharacter(id: 'hi_s_aha', character: 'अः', titleEn: 'Aha - Khali', titleHi: 'अः खाली', emoji: '✨', soundPromptEn: 'Aha khali', soundPromptHi: 'अः खाली', category: TracingCategory.hindiSwar),
  ];

  // --- Hindi Vyanjan (क - ह) ---
  static const List<TracingCharacter> _hindiVyanjanList = [
    TracingCharacter(id: 'hi_v_ka', character: 'क', titleEn: 'Ka - Kabutar', titleHi: 'क से कबूतर', emoji: '🕊️', soundPromptEn: 'Ka se Kabutar', soundPromptHi: 'क से कबूतर', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_kha', character: 'ख', titleEn: 'Kha - Khargosh', titleHi: 'ख से खरगोश', emoji: '🐰', soundPromptEn: 'Kha se Khargosh', soundPromptHi: 'ख से खरगोश', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ga', character: 'ग', titleEn: 'Ga - Gamla', titleHi: 'ग से गमला', emoji: '🪴', soundPromptEn: 'Ga se Gamla', soundPromptHi: 'ग से गमला', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_gha', character: 'घ', titleEn: 'Gha - Ghar', titleHi: 'घ से घर', emoji: '🏠', soundPromptEn: 'Gha se Ghar', soundPromptHi: 'घ से घर', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_cha', character: 'च', titleEn: 'Cha - Chammach', titleHi: 'च से चम्मच', emoji: '🥄', soundPromptEn: 'Cha se Chammach', soundPromptHi: 'च से चम्मच', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_chha', character: 'छ', titleEn: 'Chha - Chhatri', titleHi: 'छ से छतरी', emoji: '☂️', soundPromptEn: 'Chha se Chhatri', soundPromptHi: 'छ से छतरी', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ja', character: 'ज', titleEn: 'Ja - Jahaj', titleHi: 'ज से जहाज', emoji: '🚢', soundPromptEn: 'Ja se Jahaj', soundPromptHi: 'ज से जहाज', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_jha', character: 'झ', titleEn: 'Jha - Jhanda', titleHi: 'झ से झंडा', emoji: '🇮🇳', soundPromptEn: 'Jha se Jhanda', soundPromptHi: 'झ से झंडा', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ta', character: 'ट', titleEn: 'Ta - Tamatar', titleHi: 'ट से टमाटर', emoji: '🍅', soundPromptEn: 'Ta se Tamatar', soundPromptHi: 'ट से टमाटर', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_tha', character: 'ठ', titleEn: 'Tha - Thathera', titleHi: 'ठ से ठठेरा', emoji: '🔨', soundPromptEn: 'Tha se Thathera', soundPromptHi: 'ठ से ठठेरा', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_da', character: 'ड', titleEn: 'Da - Damru', titleHi: 'ड से डमरू', emoji: '🥁', soundPromptEn: 'Da se Damru', soundPromptHi: 'ड से डमरू', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_dha', character: 'ढ', titleEn: 'Dha - Dhakkan', titleHi: 'ढ से ढक्कन', emoji: '🫙', soundPromptEn: 'Dha se Dhakkan', soundPromptHi: 'ढ से ढक्कन', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_na', character: 'ण', titleEn: 'Na - Baan', titleHi: 'ण से बाण', emoji: '🏹', soundPromptEn: 'Na se Baan', soundPromptHi: 'ण से बाण', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ta2', character: 'त', titleEn: 'Ta - Tarbooj', titleHi: 'त से तरबूज', emoji: '🍉', soundPromptEn: 'Ta se Tarbooj', soundPromptHi: 'त से तरबूज', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_tha2', character: 'थ', titleEn: 'Tha - Thermos', titleHi: 'थ से थर्मस', emoji: '🍶', soundPromptEn: 'Tha se Thermos', soundPromptHi: 'थ से थर्मस', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_da2', character: 'द', titleEn: 'Da - Dawaat', titleHi: 'द से दवात', emoji: '✒️', soundPromptEn: 'Da se Dawaat', soundPromptHi: 'द से दवात', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_dha2', character: 'ध', titleEn: 'Dha - Dhanush', titleHi: 'ध से धनुष', emoji: '🏹', soundPromptEn: 'Dha se Dhanush', soundPromptHi: 'ध से धनुष', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_na2', character: 'न', titleEn: 'Na - Nal', titleHi: 'न से नल', emoji: '🚰', soundPromptEn: 'Na se Nal', soundPromptHi: 'न से नल', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_pa', character: 'प', titleEn: 'Pa - Patang', titleHi: 'प से पतंग', emoji: '🪁', soundPromptEn: 'Pa se Patang', soundPromptHi: 'प से पतंग', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_pha', character: 'फ', titleEn: 'Pha - Phal', titleHi: 'फ से फल', emoji: '🍎', soundPromptEn: 'Pha se Phal', soundPromptHi: 'फ से फल', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ba', character: 'ब', titleEn: 'Ba - Bakri', titleHi: 'ब से बकरी', emoji: '🐐', soundPromptEn: 'Ba se Bakri', soundPromptHi: 'ब से बकरी', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_bha', character: 'भ', titleEn: 'Bha - Bhalu', titleHi: 'भ से भालू', emoji: '🐻', soundPromptEn: 'Bha se Bhalu', soundPromptHi: 'भ से भालू', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ma', character: 'म', titleEn: 'Ma - Machhli', titleHi: 'म से मछली', emoji: '🐟', soundPromptEn: 'Ma se Machhli', soundPromptHi: 'म से मछली', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ya', character: 'य', titleEn: 'Ya - Yagya', titleHi: 'य से यज्ञ', emoji: '🔥', soundPromptEn: 'Ya se Yagya', soundPromptHi: 'य से यज्ञ', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ra', character: 'र', titleEn: 'Ra - Rassi', titleHi: 'र से रस्सी', emoji: '🪢', soundPromptEn: 'Ra se Rassi', soundPromptHi: 'र से रस्सी', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_la', character: 'ल', titleEn: 'La - Lattoo', titleHi: 'ल से लट्टू', emoji: '🪀', soundPromptEn: 'La se Lattoo', soundPromptHi: 'ल से लट्टू', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_va', character: 'व', titleEn: 'Va - Van', titleHi: 'व से वन', emoji: '🌳', soundPromptEn: 'Va se Van', soundPromptHi: 'व से वन', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_sha', character: 'श', titleEn: 'Sha - Shalgam', titleHi: 'श से शलजम', emoji: '🧅', soundPromptEn: 'Sha se Shalgam', soundPromptHi: 'श से शलजम', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_shha', character: 'ष', titleEn: 'Sha - Shatkon', titleHi: 'ष से षटकोण', emoji: '🔷', soundPromptEn: 'Sha se Shatkon', soundPromptHi: 'ष से षटकोण', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_sa', character: 'स', titleEn: 'Sa - Seb', titleHi: 'स से सेब', emoji: '🍎', soundPromptEn: 'Sa se Seb', soundPromptHi: 'स से सेब', category: TracingCategory.hindiVyanjan),
    TracingCharacter(id: 'hi_v_ha', character: 'ह', titleEn: 'Ha - Hathi', titleHi: 'ह से हाथी', emoji: '🐘', soundPromptEn: 'Ha se Hathi', soundPromptHi: 'ह से हाथी', category: TracingCategory.hindiVyanjan),
  ];
}
