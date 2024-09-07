import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/data/data_sources/subscription_data_source.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionRepositoryImpl extends SubscriptionRepository {
  final SubscriptionDataSource subscriptionDataSource;

  SubscriptionRepositoryImpl({required this.subscriptionDataSource});

  @override
  Future<Either<SubscriptionFailure, CustomerInfo>> getCustomerInfo() async {
    try {
      final customerInfo = await subscriptionDataSource.getCustomerInfo();
      return Right(customerInfo);
    } catch (e) {
      return Left(SubscriptionFailure('Failed to get customer info'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, Offerings>> getOfferings() async {
    try {
      final offerings = await subscriptionDataSource.getOfferings();
      return Right(offerings);
    } catch (e) {
      return Left(SubscriptionFailure('Failed to get offerings'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, bool>> initialize({String? userId}) async {
    try {
      await subscriptionDataSource.initialize(userId);
      return const Right(true);
    } catch (e) {
      return Left(SubscriptionFailure('Failed to initialize subscription'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, LogInResult>> logIn(String userId) async {
    try {
      final result = await subscriptionDataSource.logIn(userId);
      return Right(result);
    } catch (e) {
      return Left(SubscriptionFailure('Failed to log in'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, CustomerInfo>> logOut() async {
    try {
      final customerInfo = await subscriptionDataSource.logOut();
      return Right(customerInfo);
    } catch (e) {
      return Left(SubscriptionFailure('Failed to log out'));
    }
  }

  @override
  void setCustomerInfoUpdateListener() {
    subscriptionDataSource.setCustomerInfoUpdateListener();
  }
}
