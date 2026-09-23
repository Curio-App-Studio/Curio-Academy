# Google Play Store Listing & Submission Guide: Curio Academy

---

## 1. Store Listing Details

### App Title (Max 30 characters)
`Curio Academy: Math & English`  *(30 characters)*

### Short Description (Max 80 characters)
`Fun, interactive Math and English learning from LKG to Class 8. Free to try!`  *(76 characters)*

### Full Description (Max 4,000 characters — Current: 3,615 characters)
```text
Welcome to Curio Academy — the playful, interactive learning companion designed to help children from Pre-K (LKG/UKG) through Class 8 build strong foundations in Mathematics and English!

Whether your child is starting with alphabet phonics and counting or preparing for middle school exams in algebra and grammar, Curio Academy transforms study into an engaging learning adventure.

🌟 WHY PARENTS & EDUCATORS CHOOSE CURIO ACADEMY:
• Complete Curriculum (LKG to Class 8): Comprehensive, grade-by-grade syllabus aligned with CBSE, ICSE, and State Board standards.
• Dual Subject Learning: Switch seamlessly between Curio Math and Curio English with tailored lessons for every age group.
• Interactive Early Learning: Pre-K, LKG, and UKG modules feature tactile, voice-narrated Bubble Pop mini-games, visual cards, and cheerful audio prompts so young learners never feel stuck.
• Algorithmic Practice Engine: Thousands of authentic questions with step-by-step solutions and hints. Never repeat the same boring worksheet again!
• Audio & TTS Narration: Read-aloud support ensures all questions and explanations are accessible to auditory and developing readers.
• Offline Ready: Practice anytime, anywhere! Core learning activities work offline without requiring internet.
• Free to Learn: Access core learning activities and practice sets for free.
• Ad-Free with Premium: Upgrade to Curio Academy Premium for a 100% ad-free experience, unlimited practice, and zero distractions.

📚 IN-DEPTH CURRICULUM:

🔢 MATHEMATICS:
• Kindergarten (LKG & UKG): Number recognition (1 to 20), counting objects, shapes (circle, square, triangle), big/small, tall/short, colors, and addition bonds.
• Primary (Classes 1–3): Place value (tens & ones), 2-digit/3-digit addition & subtraction, times tables, basic division, clock reading, coins & currency, and measurement.
• Upper Primary (Classes 4–5): Multi-digit operations, fractions, decimals, capacity (liters/milliliters), perimeter, area, factors, multiples, primes, symmetry, and bar charts.
• Middle School (Classes 6–8): Integers, algebraic expressions, linear equations, ratios, percentages, exponents, coordinate geometry, surface area, volume, and statistics.

📖 ENGLISH:
• Kindergarten (LKG & UKG): Alphabet phonics (A–Z letter sounds), sight words, rhyming pairs, opposite words, vowels & consonants, and picture-word matching.
• Primary (Classes 1–3): Nouns (common, proper), action verbs, adjectives, articles (A, An, The), simple pronouns, prepositions, singular/plural, and basic sentences.
• Upper Primary (Classes 4–5): Verb tenses (past, present, future), adverbs, conjunctions, subject-verb agreement, prefixes/suffixes, synonyms, antonyms, and reading comprehension.
• Middle School (Classes 6–8): Advanced grammar, active/passive voice, direct/indirect speech, clauses, modal verbs, idioms, and analytical comprehension passages.

🏆 MOTIVATING PROGRESS:
• Star rewards and achievement badges celebrate learning milestones.
• Real-time streak tracking helps students build consistent daily study habits.
• Built-in scratchpad allows students to work out math steps directly on screen.

🔒 SAFE, SECURE & FAMILY FRIENDLY:
• COPPA & Families Policy Compliant: Zero personal data collected, no account login required, and local device storage.
• Kid-Safe Contextual Ads: Free tier uses only family-certified, non-personalized contextual ads with zero behavioral tracking.
• Ad-Free Subscription: Upgrade anytime to remove all advertisements and support distraction-free learning.

Download Curio Academy today and spark your child's love for Math and English!
```

---

## 2. Google Play Console Form Answers

### App Category & Contact Details
- **App Category:** Educational / Education
- **Tags:** Education, Kids, Math, English, Learning Games, Preschool, Elementary
- **Content Rating:** Suitable for all ages / Everyone / PEGI 3
- **Contact Email:** your-email@domain.com
- **Website / Privacy Policy URL:** `https://vivekeazework.github.io/curio-academy/`

### Target Audience & Content (Families Policy)
- **Target Age Groups:** Check boxes for:
  - 5 and under
  - 6–8
  - 9–12
  - 13 and older
- **Neutral Age Screen:** Not required if content is safe for all ages.
- **Is your app designed for children?** YES ("Teacher Approved / Designed for Families").
- **Does the app display ads?** **YES** (Select *"Yes, my app contains ads"*).
  > ⚠️ **Google Families Policy Ad Requirement:** When serving ads to children under 13, all ad SDKs must be Google Play Families Self-Certified Ads SDKs (e.g. Google AdMob configured with `tagForChildDirectedTreatment(true)` so no behavioral tracking or personal profiling occurs).

### Data Safety Form (Google Play)
Google Play requires answering the Data Safety questionnaire:
- **Does your app collect or share any of the required user data types?** -> **NO** (Progress data is stored locally on device only).
- **Is all of the user data collected by your app encrypted in transit?** -> **N/A** (No user personal data collected or transmitted).
- **Do you provide a way for users to request that their data be deleted?** -> **Yes** (Uninstalling or clearing app storage deletes all locally stored data immediately).

---

## 3. Release Files & Keystore Credentials

| Item | Details |
|---|---|
| **Package Name / Application ID** | `com.curio.academy` |
| **Android App Bundle (.aab)** | `build/app/outputs/bundle/release/app-release.aab` |
| **Release APK (.apk)** | `build/app/outputs/flutter-apk/app-release.apk` |
| **Keystore File** | `android/app/upload-keystore.jks` |
| **Key Alias** | `upload` |
| **Keystore Password** | `CurioAcademyRelease2026!` |
| **Key Password** | `CurioAcademyRelease2026!` |
| **Key Configuration File** | `android/key.properties` (secured in `.gitignore`) |

> ⚠️ **CRITICAL NOTE FOR DEVELOPER:** Keep your `android/app/upload-keystore.jks` and passwords securely backed up! Google Play uses this key to verify all future app updates.
