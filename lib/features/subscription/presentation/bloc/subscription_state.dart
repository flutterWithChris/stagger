part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

final class SubscriptionInitial extends SubscriptionState {}

final class SubscriptionLoaded extends SubscriptionState {
  final Offerings? offerings;

  const SubscriptionLoaded(this.offerings);

  @override
  List<Object?> get props => [offerings];
}

final class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

final class SubscriptionLoading extends SubscriptionState {}
