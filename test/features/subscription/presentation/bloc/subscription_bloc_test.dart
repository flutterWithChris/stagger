import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  group('SubscriptionBloc', () {
    late MockInitSubscriptionsUsecase mockInitSubscriptionsUsecase;
    late MockShowPaywallUsecase mockShowPaywallUsecase;
    late MockGetCustomerInfoUsecase mockGetCustomerInfoUsecase;
    late SubscriptionBloc subscriptionBloc;
    late CustomerInfo testCustomerInfo;

    setUp(() {
      mockInitSubscriptionsUsecase = MockInitSubscriptionsUsecase();
      mockShowPaywallUsecase = MockShowPaywallUsecase();
      mockGetCustomerInfoUsecase = MockGetCustomerInfoUsecase();
      subscriptionBloc = SubscriptionBloc(mockInitSubscriptionsUsecase,
          mockShowPaywallUsecase, mockGetCustomerInfoUsecase);
      testCustomerInfo = CustomerInfo.fromJson({});
    });
    test('Initially emits SubscriptionLoading', () {
      expect(subscriptionBloc.state, SubscriptionLoading());
    });

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionInitial] when InitializeSubscription is added',
      build: () {
        when(mockInitSubscriptionsUsecase.execute())
            .thenAnswer((_) async => const Right(true));
        when(mockGetCustomerInfoUsecase.execute())
            .thenAnswer((_) async => Right(testCustomerInfo));
        when(mockInitSubscriptionsUsecase.execute())
            .thenAnswer((_) async => const Right(true));
        return subscriptionBloc;
      },
      act: (bloc) => bloc.add(const InitializeSubscription()),
      expect: () => [SubscriptionInitial(customerInfo: testCustomerInfo)],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionError] when InitializeSubscription fails',
      build: () {
        when(mockInitSubscriptionsUsecase.execute())
            .thenAnswer((_) async => Left(SubscriptionFailure('error')));
        return subscriptionBloc;
      },
      act: (bloc) => bloc.add(const InitializeSubscription()),
      expect: () => [const SubscriptionError('error')],
    );
  });
}
