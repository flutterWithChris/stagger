part of 'notification_bloc.dart';

sealed class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

final class NotificationLoading extends NotificationState {}

final class NotificationInitialized extends NotificationState {}

final class NotificationError extends NotificationState {}

final class NotificationSuccess extends NotificationState {}
