import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';

class InitSubscriptionsUsecase {
  final SubscriptionRepository _subscriptionRepository;

  InitSubscriptionsUsecase(this._subscriptionRepository);

  Future<void> execute() async {
    await _subscriptionRepository.initialize();
  }
}
