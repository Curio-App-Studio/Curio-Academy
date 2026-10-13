import 'package:flutter_test/flutter_test.dart';
import 'package:curio_math/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    test('NotificationService singleton instance is accessible', () {
      final instance1 = NotificationService.instance;
      final instance2 = NotificationService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('NotificationService channel constants are correctly defined', () {
      expect(NotificationService.channelId, 'curio_learning_channel');
      expect(NotificationService.channelName, 'Learning & Practice Reminders');
      expect(NotificationService.channelDescription, contains('Curio Academy'));
    });
  });
}
