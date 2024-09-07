import 'package:bloc/bloc.dart';
import 'package:buoy/features/subscription/domain/usecases/init_subscriptions_usecase.dart';
import 'package:buoy/features/subscription/domain/usecases/show_paywall_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final InitSubscriptionsUsecase initSubscriptionsUsecase;
  final ShowPaywallUsecase showPaywallUsecase;
  SubscriptionBloc(this.initSubscriptionsUsecase, this.showPaywallUsecase)
      : super(SubscriptionInitial()) {
    on<InitializeSubscription>((event, emit) async {
      await initSubscriptionsUsecase.execute();
    });
    on<ShowPaywall>((event, emit) async {
      final result = await showPaywallUsecase.execute();
      result.fold(
        (failure) => emit(SubscriptionError(failure.message)),
        (offerings) => emit(SubscriptionLoaded(offerings)),
      );
    });
  }
}
