import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class ShowPaywallUsecase {
  final SubscriptionRepository _subscriptionRepository;

  ShowPaywallUsecase(this._subscriptionRepository);

  Future<Either<SubscriptionFailure, PaywallResult>> execute() async {
    try {
      return await RevenueCatUI.presentPaywall().then((value) => Right(value),
          onError: (e) => Left(SubscriptionFailure('Failed to show paywall')));
    } catch (e) {
      return Left(SubscriptionFailure('Failed to show paywall'));
    }
  }
}
