part of 'subscription_bloc.dart';

sealed class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class InitializeSubscription extends SubscriptionEvent {
  final String userId;

  const InitializeSubscription(this.userId);

  @override
  List<Object> get props => [userId];
}

class LogIn extends SubscriptionEvent {
  final String userId;

  const LogIn(this.userId);

  @override
  List<Object> get props => [userId];
}

class LogOut extends SubscriptionEvent {}

class ShowPaywall extends SubscriptionEvent {}
