part of 'subscription_bloc.dart';

sealed class SubscriptionState extends Equatable {
  final CustomerInfo? customerInfo;
  const SubscriptionState({this.customerInfo});

  @override
  List<Object?> get props => [customerInfo];
}

final class SubscriptionInitial extends SubscriptionState {
  final CustomerInfo customerInfo;

  const SubscriptionInitial({required this.customerInfo});

  @override
  // TODO: implement props
  List<Object?> get props => [customerInfo];
}

final class SubscriptionLoaded extends SubscriptionState {
  final CustomerInfo customerInfo;

  const SubscriptionLoaded({required this.customerInfo});

  @override
  List<Object?> get props => [customerInfo];
}

final class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}

final class SubscriptionLoading extends SubscriptionState {}
