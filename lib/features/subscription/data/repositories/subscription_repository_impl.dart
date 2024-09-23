import 'package:buoy/core/constants.dart';
import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/data/data_sources/subscription_data_source.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/models/offerings_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SubscriptionRepositoryImpl extends SubscriptionRepository {
  final SubscriptionDataSource subscriptionDataSource;

  SubscriptionRepositoryImpl({required this.subscriptionDataSource});

  @override
  Future<Either<SubscriptionFailure, CustomerInfo>> getCustomerInfo() async {
    try {
      final customerInfo = await subscriptionDataSource.getCustomerInfo();
      return Right(customerInfo);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to get customer info'),
      );
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(SubscriptionFailure('Failed to get customer info'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, Offerings>> getOfferings() async {
    try {
      final offerings = await subscriptionDataSource.getOfferings();
      return Right(offerings);
    } catch (e) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        getErrorSnackbar('Failed to get offerings'),
      );
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(SubscriptionFailure('Failed to get offerings'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, bool>> initialize({String? userId}) async {
    try {
      final result = await subscriptionDataSource.initialize(userId: userId);

      if (result == true) {
        return Right(result);
      } else {
        showErrorSnackbar('Failed to initialize subscription');
        await Sentry.captureException(
          Exception('Failed to initialize subscription'),
          stackTrace: StackTrace.current,
        );
        return Left(SubscriptionFailure('Failed to initialize subscription'));
      }
    } catch (e) {
      showErrorSnackbar('Failed to initialize subscription');
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(SubscriptionFailure('Failed to initialize subscription'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, LogInResult>> logIn(String userId) async {
    try {
      final result = await subscriptionDataSource.logIn(userId);
      return Right(result);
    } catch (e) {
      showErrorSnackbar('Failed to log in');
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(SubscriptionFailure('Failed to log in'));
    }
  }

  @override
  Future<Either<SubscriptionFailure, CustomerInfo>> logOut() async {
    try {
      final customerInfo = await subscriptionDataSource.logOut();
      return Right(customerInfo);
    } catch (e) {
      showErrorSnackbar('Failed to log out');
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
      );
      return Left(SubscriptionFailure('Failed to log out'));
    }
  }

  @override
  void setCustomerInfoUpdateListener() {
    subscriptionDataSource.setCustomerInfoUpdateListener();
  }
}
