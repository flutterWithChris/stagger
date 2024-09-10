import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/core/success/success.dart';
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class NotificationRepository {
  Future<Either<NotificationFailure, NotificationSuccess>>
      initializeNotifications();
  Future<Either<NotificationFailure, NotificationSuccess>> showNotification(
      String title, String body,
      {NotificationCategory? category});
  Future<Either<NotificationFailure, NotificationSuccess>>
      setListenerForLocalNotifications();
  Future<Either<NotificationFailure, PermissionStatus>> requestPermissions();
}
