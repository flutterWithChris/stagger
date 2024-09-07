import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionDataSource {
  Future<void> initialize(String? userId) async {
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
    userId != null
        ? await Purchases.configure(configuration..appUserID = userId)
        : await Purchases.configure(configuration);
  }

  Future<LogInResult> logIn(String userId) async {
    try {
      return await Purchases.logIn(userId);
    } catch (e) {
      throw Exception('Error logging in');
    }
  }

  Future<CustomerInfo> logOut() async {
    try {
      return await Purchases.logOut();
    } catch (e) {
      throw Exception('Error logging out');
    }
  }

  void setCustomerInfoUpdateListener() {
    Purchases.addCustomerInfoUpdateListener((purchaserInfo) {
      print('Purchaser info updated');
    });
  }

  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      throw Exception('Error getting customer info');
    }
  }

  Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      throw Exception('Error getting offerings');
    }
  }
}
