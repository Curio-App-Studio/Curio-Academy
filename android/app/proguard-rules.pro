# Flutter & Engine
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# AndroidX WorkManager, Room & SQLite (Prevents Failed to create an instance of androidx.work.impl.WorkDatabase)
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class * extends androidx.work.impl.WorkDatabase { *; }
-keep class androidx.room.** { *; }
-keep class * extends androidx.room.RoomDatabase { *; }
-keepclassmembers class * extends androidx.room.RoomDatabase { void <init>(); }
-keep class androidx.sqlite.db.** { *; }
-keep class androidx.startup.** { *; }
-dontwarn androidx.work.**
-dontwarn androidx.room.**
-dontwarn androidx.sqlite.**
-dontwarn androidx.startup.**

# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Flutter Plugins (TTS, Audio, SharedPreferences)
-keep class com.tundralabs.fluttertts.** { *; }
-keep class xyz.luan.audioplayers.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Google Play Core (In-App Update & In-App Review)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
