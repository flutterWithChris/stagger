import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';

class InitializeNotificationsUsecase {
  final NotificationRepository _notificationRepository;

  InitializeNotificationsUsecase(this._notificationRepository);

  Future<void> call() async {
    await _notificationRepository.initializeNotifications();
  }
}
