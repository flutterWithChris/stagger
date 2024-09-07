import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ShowPaywallUsecase {
  final SubscriptionRepository _subscriptionRepository;

  ShowPaywallUsecase(this._subscriptionRepository);

  Future<Either<SubscriptionFailure, Offerings>> execute() async {
    return await _subscriptionRepository.getOfferings();
  }
}
