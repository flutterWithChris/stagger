import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';

class SetNotificationsListenerUsecase {
  final NotificationRepository _notificationRepository;

  SetNotificationsListenerUsecase(this._notificationRepository);

  Future<void> call() async {
    await _notificationRepository.setListenerForLocalNotifications();
  }
}
