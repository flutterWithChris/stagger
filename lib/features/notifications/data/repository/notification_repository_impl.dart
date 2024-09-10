import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/core/success/success.dart';
import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';
import 'package:buoy/features/notifications/helpers/notification_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class NotificationRepositoryImpl extends NotificationRepository {
  @override
  Future<Either<NotificationFailure, NotificationSuccess>>
      initializeNotifications() async {
    try {
      bool response = await AwesomeNotifications()
          .initialize('resource://drawable/res_app_icon', [
        NotificationChannel(
            channelKey: 'stagger',
            channelName: 'notifications',
            channelDescription: 'Stagger notifications')
      ]);

      await AwesomeNotifications().setChannel(NotificationChannel(
          channelKey: 'stagger',
          channelName: 'stagger',
          channelDescription: 'Stagger notifications',
          channelShowBadge: true));
      if (response == true) {
        return Right(NotificationSuccess('Notifications initialized'));
      } else {
        return Left(NotificationFailure('Failed to initialize notifications'));
      }
    } catch (e) {
      print('Error initializing notifications: $e');
      return Left(NotificationFailure('Failed to initialize notifications'));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationSuccess>> showNotification(
      String title, String body,
      {NotificationCategory? category}) async {
    try {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              category: category,
              id: 10,
              channelKey: 'stagger',
              title: title,
              body: body,
              bigPicture: 'resource://drawable/res_app_icon',
              notificationLayout: NotificationLayout.Default));
      return Right(NotificationSuccess('Notification shown'));
    } catch (e) {
      print('Error showing notification: $e');
      return Left(NotificationFailure('Failed to show notification'));
    }
  }

  @override
  Future<Either<NotificationFailure, NotificationSuccess>>
      setListenerForLocalNotifications() async {
    // Only after at least the action method is set, the notification events are delivered
    final result = await AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onActionReceivedMethod(receivedAction);
      },
      onNotificationCreatedMethod:
          (ReceivedNotification receivedNotification) async {
        NotificationController.onNotificationCreatedMethod(
            receivedNotification);
      },
      onNotificationDisplayedMethod:
          (ReceivedNotification receivedNotification) async {
        NotificationController.onNotificationDisplayedMethod(
            receivedNotification);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onDismissActionReceivedMethod(receivedAction);
      },
    );
    if (result == true) {
      return Right(NotificationSuccess('Listeners set'));
    } else {
      return Left(NotificationFailure('Failed to set listeners'));
    }
  }

  @override
  Future<Either<NotificationFailure, PermissionStatus>>
      requestPermissions() async {
    try {
      // Check if permissions are permanently denied
      if (await Permission.notification.isPermanentlyDenied) {
        return const Right(PermissionStatus.permanentlyDenied);
      }
      PermissionStatus response = await Permission.notification.request();

      return Right(response);
    } catch (e) {
      print('Error requesting permissions: $e');
      return Left(NotificationFailure('Failed to grant permissions'));
    }
  }
}
