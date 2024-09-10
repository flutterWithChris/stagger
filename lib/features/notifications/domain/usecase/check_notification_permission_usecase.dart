import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckNotificationPermissionUsecase {
  final NotificationRepository _notificationRepository;

  CheckNotificationPermissionUsecase(this._notificationRepository);

  Future<Either<NotificationFailure, PermissionStatus>> call() async {
    return await _notificationRepository.requestPermissions();
  }
}
