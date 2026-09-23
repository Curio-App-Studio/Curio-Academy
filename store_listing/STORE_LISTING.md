# Google Play Store Listing & Submission Guide: Curio Academy

---

## 1. Store Listing Details

### App Title (Max 30 characters)
`Curio Academy: Math & English`  *(30 characters)*

### Short Description (Max 80 characters)
`Fun, interactive Math and English learning from Pre-K (LKG) to Class 8. 100% ad-free!`  *(80 characters)*

### Full Description (Markdown ready for Play Console)
```text
Welcome to Curio Academy — the playful, interactive learning companion designed to help children build strong foundations in Mathematics and English!

From early learners in LKG/UKG exploring letters and shapes to Grade 8 students mastering algebra and grammar, Curio Academy transforms study time into an engaging educational adventure.

🌟 WHY PARENTS & EDUCATORS LOVE CURIO ACADEMY:
• Complete Curriculum (LKG to Class 8): Structured chapters, topics, and question sets tailored specifically to each grade level.
• Interactive Learning for Early Learners: Pre-K, LKG, and UKG modules feature visual questions, tactile touch cards, cheerful audio guidance, and read-aloud prompts so young learners never feel stuck.
• Dual Subjects: Seamlessly switch between Math and English with tailored syllabus coverage.
• Dynamic Practice Challenges: Practice sessions with instant feedback, encouraging hints, and gentle guidance.
• Offline & Safe: Works 100% offline. No internet connection required after installation.
• 100% Ad-Free & Kid-Safe: No ads, no third-party trackers, and no subscriptions. Designed strictly following COPPA and Google Play Families guidelines.

📚 WHAT’S INSIDE:
🔢 MATHEMATICS:
- Early Years: Counting, shapes, patterns, big/small, more/less, basic addition & subtraction.
- Primary (Classes 1–5): Place values, multiplication tables, mental math, fractions, measurement, geometry, and word problems.
- Middle School (Classes 6–8): Integers, algebra, ratios, percentages, exponents, coordinate geometry, and data handling.

📖 ENGLISH:
- Early Years: Alphabet phonics, sight words, opposites, rhyming sounds, colors, and picture-word association.
- Primary (Classes 1–5): Nouns, verbs, adjectives, tenses, sentence formation, vocabulary, spelling, and reading comprehension.
- Middle School (Classes 6–8): Advanced grammar, active/passive voice, direct/indirect speech, idioms, clauses, and analytical reading.

🏆 MOTIVATING PROGRESS:
• Star rewards and badges celebrate learning milestones.
• Real-time streak and mastery tracking help students stay motivated every day.
• Audio read-aloud support ensures all questions are accessible, even for developing readers.

Give your child the confidence to excel in school and love learning with Curio Academy!
```

---

## 2. Google Play Console Form Answers

### App Category & Contact Details
- **App Category:** Educational / Education
- **Tags:** Education, Kids, Math, English, Learning Games, Preschool, Elementary
- **Content Rating:** Suitable for all ages / Everyone / PEGI 3
- **Contact Email:** your-email@domain.com
- **Website / Privacy Policy URL:** Link to your hosted `privacy_policy.html` (e.g. GitHub Pages)

### Target Audience & Content (Families Policy)
- **Target Age Groups:** Check boxes for:
  - 5 and under
  - 6–8
  - 9–12
  - 13 and older
- **Neutral Age Screen:** Not required if you target children exclusively or declare content is safe for all.
- **Is your app designed for children?** YES ("Teacher Approved / Designed for Families").
- **Does the app display ads?** NO (Select "No, my app does not contain ads").

### Data Safety Form (Google Play)
Google Play requires answering the Data Safety questionnaire:
- **Does your app collect or share any of the required user data types?** -> **NO**
- **Is all of the user data collected by your app encrypted in transit?** -> **N/A** (No data collected or transmitted)
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
