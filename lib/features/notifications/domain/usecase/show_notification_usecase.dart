import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart';

class ShowNotificationUsecase {
  final NotificationRepository _notificationRepository;

  ShowNotificationUsecase(this._notificationRepository);

  Future<void> call(String title, String body,
      {NotificationCategory? category}) async {
    await _notificationRepository.showNotification(title, body,
        category: category);
  }
}
