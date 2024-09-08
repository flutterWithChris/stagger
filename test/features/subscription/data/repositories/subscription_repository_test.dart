import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  late SubscriptionRepositoryImpl subscriptionRepository;
  late MockSubscriptionDataSource mockSubscriptionDataSource;

  setUp(() {
    mockSubscriptionDataSource = MockSubscriptionDataSource();
    subscriptionRepository = SubscriptionRepositoryImpl(
        subscriptionDataSource: mockSubscriptionDataSource);
  });

  group('SubscriptionRepository', () {
    CustomerInfo mockCustomerInfo = const CustomerInfo(
      EntitlementInfos({}, {}),
      {},
      [],
      [],
      [],
      '123',
      '123',
      {},
      '123',
    );
    test('should initialize the subscription', () async {
      // arrange
      const userId = '123';
      when(mockSubscriptionDataSource.initialize(userId: userId))
          .thenAnswer((_) async => true);

      // act
      final result = await subscriptionRepository.initialize(userId: userId);
      // assert
      expect(result, const Right(true));
    });

    test('should fail to initialize the subscription', () async {
      const userId = '123';
      when(mockSubscriptionDataSource.initialize(userId: userId)).thenThrow(
          (_) async => PlatformException(
              code: 'error', message: 'Failed to initialize subscription'));

      // act
      final result = await subscriptionRepository.initialize(userId: userId);
      // assert
      expect(result.isLeft(), true);
    });

    test('should log in the subscription', () async {
      String userId = '123';

      when(mockSubscriptionDataSource.logIn(userId)).thenAnswer((_) async =>
          LogInResult(created: true, customerInfo: mockCustomerInfo));
      // act
      final result = await subscriptionRepository.logIn(userId);
      // assert
      expect(result.isRight(), true);
    });

    test('should fail to log in the subscription', () async {
      String userId = '123';
      when(mockSubscriptionDataSource.logIn(userId)).thenThrow((_) async =>
          PlatformException(code: 'error', message: 'Failed to log in'));
      // act
      final result = await subscriptionRepository.logIn(userId);
      // assert
      expect(result.isLeft(), true);
    });

    test('should get customer info', () async {
      // arrange
      when(mockSubscriptionDataSource.getCustomerInfo())
          .thenAnswer((_) async => mockCustomerInfo);

      // act
      final result = await subscriptionRepository.getCustomerInfo();
      // assert
      expect(result.isRight(), true);
    });

    test('should fail to get customer info', () async {
      when(mockSubscriptionDataSource.getCustomerInfo()).thenThrow((_) async =>
          PlatformException(
              code: 'error', message: 'Failed to get customer info'));

      // act
      final result = await subscriptionRepository.getCustomerInfo();
      // assert
      expect(result.isLeft(), true);
    });

    test('should get offerings', () async {
      // arrange
      when(mockSubscriptionDataSource.getOfferings())
          .thenAnswer((_) async => const Offerings({}));

      // act
      final result = await subscriptionRepository.getOfferings();
      // assert
      expect(result.isRight(), true);
    });

    test('should fail to get offerings', () async {
      when(mockSubscriptionDataSource.getOfferings()).thenThrow((_) async =>
          PlatformException(code: 'error', message: 'Failed to get offerings'));

      // act
      final result = await subscriptionRepository.getOfferings();
      // assert
      expect(result.isLeft(), true);
    });
  });
}
