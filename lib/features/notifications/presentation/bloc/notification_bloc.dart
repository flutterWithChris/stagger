import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/bloc.dart';
import 'package:buoy/features/notifications/domain/usecase/check_notification_permission_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/initialize_notifications_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/set_notifications_listener_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/show_notification_usecase.dart';
import 'package:equatable/equatable.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final InitializeNotificationsUsecase initializeNotificationsUsecase;
  final ShowNotificationUsecase showNotificationUsecase;
  final SetNotificationsListenerUsecase setNotificationsListenerUsecase;
  final CheckNotificationPermissionUsecase checkNotificationPermissionUsecase;

  NotificationBloc(
      {required this.initializeNotificationsUsecase,
      required this.showNotificationUsecase,
      required this.setNotificationsListenerUsecase,
      required this.checkNotificationPermissionUsecase})
      : super(NotificationLoading()) {
    on<InitializeNotifications>((event, emit) async {
      try {
        await initializeNotificationsUsecase.call();
        await setNotificationsListenerUsecase.call();
        emit(NotificationInitialized());
      } catch (e) {
        emit(NotificationError());
      }
    });
    on<ShowNotification>((event, emit) async {
      try {
        await showNotificationUsecase.call(event.title, event.body);
        emit(NotificationSuccess());
      } catch (e) {
        emit(NotificationError());
      }
    });
    on<ShowLocationInUseNotification>((event, emit) async {
      try {
        await showNotificationUsecase.call('Location Currently in Use',
            'Your location is still being updated in the background',
            category: NotificationCategory.Service);
        emit(NotificationSuccess());
      } catch (e) {
        emit(NotificationError());
      }
    });
  }
}
