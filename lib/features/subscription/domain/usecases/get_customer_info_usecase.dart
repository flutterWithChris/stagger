import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

class GetCustomerInfoUsecase {
  final SubscriptionRepository _subscriptionRepository;

  GetCustomerInfoUsecase(this._subscriptionRepository);

  Future<Either<SubscriptionFailure, CustomerInfo>> execute() async {
    return await _subscriptionRepository.getCustomerInfo();
  }
}
