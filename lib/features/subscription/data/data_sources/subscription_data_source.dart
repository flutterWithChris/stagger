import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class SubscriptionDataSource {
  Future<bool> initialize({String? userId});
  Future<LogInResult> logIn(String userId);
  Future<CustomerInfo> logOut();
  void setCustomerInfoUpdateListener();
  Future<CustomerInfo> getCustomerInfo();
  Future<Offerings> getOfferings();
}

class SubscriptionDataSourceImpl extends SubscriptionDataSource {
  @override
  Future<bool> initialize({String? userId}) async {
    try {
      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(
          dotenv.env['REVCAT_ANDROID_API_KEY']!,
        );
      } else {
        configuration = PurchasesConfiguration(
          dotenv.env['REVCAT_IOS_API_KEY']!,
        );
      }
      await Purchases.configure(configuration..appUserID ??= userId)
          .then((value) {}, onError: (error) {
        throw Exception('Error configuring purchases');
      });

      return true;
    } catch (e) {
      throw Exception('Error initializing subscription');
    }
  }

  @override
  Future<LogInResult> logIn(String userId) async {
    try {
      return await Purchases.logIn(userId);
    } catch (e) {
      throw Exception('Error logging in');
    }
  }

  @override
  Future<CustomerInfo> logOut() async {
    try {
      return await Purchases.logOut();
    } catch (e) {
      throw Exception('Error logging out');
    }
  }

  @override
  void setCustomerInfoUpdateListener() {
    Purchases.addCustomerInfoUpdateListener((purchaserInfo) {});
  }

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      throw Exception('Error getting customer info');
    }
  }

  @override
  Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      throw Exception('Error getting offerings');
    }
  }
}
