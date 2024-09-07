import 'dart:async';

import 'package:buoy/core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionRepository {
  Future<Either<SubscriptionFailure, bool>> initialize({String? userId});
  Future<Either<SubscriptionFailure, LogInResult>> logIn(String userId);
  Future<Either<SubscriptionFailure, CustomerInfo>> logOut();
  Future<Either<SubscriptionFailure, CustomerInfo>> getCustomerInfo();
  void setCustomerInfoUpdateListener();
  Future<Either<SubscriptionFailure, Offerings>> getOfferings();
}
