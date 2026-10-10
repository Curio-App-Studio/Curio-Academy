import 'package:flutter/material.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/student_profile.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../../services/ad_service.dart';
import 'bubble_pop/presentation/bubble_pop_screen.dart';
import 'card_match/presentation/card_match_screen.dart';
import 'concept_quiz/presentation/concept_challenge_screen.dart';
import 'drag_drop/presentation/fraction_cauldron_screen.dart';
import 'grid_calc/presentation/equation_solver_screen.dart';

/// Centralized dispatcher that navigates between diverse chapter activities
/// ensuring seamless transitions between Bubble Pop, Card Match, and Quiz activities.
class ActivityDispatcher {
  static Widget buildActivityScreen({
    required Activity activity,
    List<Activity>? activities,
    required int index,
    Chapter? chapter,
    void Function(List<Activity>)? onActivitiesUpdated,
  }) {
    switch (activity.activityType) {
      case ActivityType.bubblePop:
        return BubblePopScreen(
          activity: activity,
          activities: activities,
          initialLevelIndex: index,
        );
      case ActivityType.cardMatch:
        return CardMatchScreen(
          activity: activity,
          activities: activities,
          initialLevelIndex: index,
        );
      case ActivityType.dragDrop:
        return FractionCauldronScreen(activity: activity);
      case ActivityType.gridCalc:
        return EquationSolverScreen(activity: activity);
      case ActivityType.mcq:
      default:
        return ConceptChallengeScreen(
          activity: activity,
          chapter: chapter,
          activities: activities,
          initialIndex: index,
          studentClass: StudentClass.fromJson(activity.targetGrade),
          onActivitiesUpdated: onActivitiesUpdated,
        );
    }
  }

  static void proceedToNextActivity(
    BuildContext context, {
    required int currentIndex,
    required List<Activity>? activities,
    Activity? currentActivity,
    Chapter? chapter,
  }) {
    if (activities == null || activities.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }

    AdService().showInterstitialAdIfReady();

    final activitiesList = List<Activity>.from(activities);
    final nextIndex = currentIndex + 1;

    if (nextIndex < activitiesList.length) {
      final nextActivity = activitiesList[nextIndex];
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => buildActivityScreen(
            activity: nextActivity,
            activities: activitiesList,
            index: nextIndex,
            chapter: chapter,
          ),
        ),
      );
      return;
    }

    // At the end of the chapter activity list:
    // Generate the next activity with alternating game types for Kindergarten
    final chId = currentActivity?.chapterId ?? chapter?.chapterId ?? 'k_ch1';
    final targetGrade = currentActivity?.targetGrade ?? chapter?.grade ?? 'LKG';
    final sc = StudentClass.fromJson(targetGrade);

    final generated = CurriculumRepository().generateActivitiesForChapter(
      chId,
      sc,
      count: 2,
      chapter: chapter,
      existingPromptTexts: activitiesList.map((a) => a.promptData.text).toSet(),
    );

    Activity nextAct;
    if (sc.isKindergarten && currentActivity != null) {
      final currentType = currentActivity.activityType;
      // Pick the alternate game type so the child gets a fresh game every time!
      final alternateType = (currentType == ActivityType.bubblePop)
          ? ActivityType.cardMatch
          : ActivityType.bubblePop;
      nextAct = generated.firstWhere(
        (a) => a.activityType == alternateType,
        orElse: () => generated.isNotEmpty ? generated.first : currentActivity,
      );
    } else {
      nextAct = generated.isNotEmpty ? generated.first : (currentActivity ?? activitiesList.last);
    }

    activitiesList.add(nextAct);
    LocalStorageService.instance.saveChapterActivities(chId, activitiesList);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => buildActivityScreen(
          activity: nextAct,
          activities: activitiesList,
          index: nextIndex,
          chapter: chapter,
        ),
      ),
    );
  }
}
