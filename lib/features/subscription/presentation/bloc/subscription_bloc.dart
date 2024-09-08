import 'dart:ffi';

import 'package:bloc/bloc.dart';
import 'package:buoy/features/subscription/domain/usecases/get_customer_info_usecase.dart';
import 'package:buoy/features/subscription/domain/usecases/init_subscriptions_usecase.dart';
import 'package:buoy/features/subscription/domain/usecases/show_paywall_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_ui_flutter/paywall_result.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final InitSubscriptionsUsecase initSubscriptionsUsecase;
  final ShowPaywallUsecase showPaywallUsecase;
  final GetCustomerInfoUsecase _getCustomerInfoUsecase;
  SubscriptionBloc(this.initSubscriptionsUsecase, this.showPaywallUsecase,
      this._getCustomerInfoUsecase)
      : super(SubscriptionLoading()) {
    on<InitializeSubscription>((event, emit) async {
      try {
        final response = await initSubscriptionsUsecase.execute();
        response.fold(
          (failure) {
            print('Caught failure: ${failure.message}');
            emit(SubscriptionError(failure.message));
          },
          (success) => emit(SubscriptionInitial()),
        );
      } catch (e) {
        print('Caught exception: $e');
        emit(SubscriptionError(e.toString()));
      }
    });
    on<ShowPaywall>((event, emit) async {
      final result = await showPaywallUsecase.execute();
      print('ShowPaywall result: $result');
      result.fold(
        (failure) => emit(SubscriptionError(failure.message)),
        (paywallResult) => add(HandlePaywallResult(paywallResult)),
      );
    });
    on<HandlePaywallResult>((event, emit) async {
      if (event.paywallResult != PaywallResult.error &&
          event.paywallResult != PaywallResult.notPresented) {
        emit(SubscriptionLoading());
        final customerInfo = await _getCustomerInfoUsecase.execute();
        customerInfo.fold(
          (failure) {
            print('Caught failure: ${failure.message}');
            emit(SubscriptionError(failure.message));
          },
          (customerInfo) =>
              emit(SubscriptionLoaded(customerInfo: customerInfo)),
        );
      } else {
        emit(const SubscriptionError('Error showing paywall'));
      }
    });
  }
}
