part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class InitializeNotifications extends NotificationEvent {}

class ShowNotification extends NotificationEvent {
  final String title;
  final String body;

  const ShowNotification({required this.title, required this.body});

  @override
  List<Object> get props => [title, body];
}

class ShowLocationInUseNotification extends NotificationEvent {}
