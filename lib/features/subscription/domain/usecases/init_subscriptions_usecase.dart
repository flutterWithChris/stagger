import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';

class InitSubscriptionsUsecase {
  final SubscriptionRepository _subscriptionRepository;

  InitSubscriptionsUsecase(this._subscriptionRepository);

  Future<Either<SubscriptionFailure, bool>> execute() async {
    return await _subscriptionRepository.initialize();
  }
}
