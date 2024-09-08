import 'package:buoy/core/errors/failure.dart';
import 'package:buoy/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import '../../../../helpers/test_helper.mocks.dart';

void main() {
  group('SubscriptionBloc', () {
    late MockInitSubscriptionsUsecase mockInitSubscriptionsUsecase;
    late MockShowPaywallUsecase mockShowPaywallUsecase;
    late MockGetCustomerInfoUsecase mockGetCustomerInfoUsecase;
    late SubscriptionBloc subscriptionBloc;

    setUp(() {
      mockInitSubscriptionsUsecase = MockInitSubscriptionsUsecase();
      mockShowPaywallUsecase = MockShowPaywallUsecase();
      mockGetCustomerInfoUsecase = MockGetCustomerInfoUsecase();
      subscriptionBloc = SubscriptionBloc(mockInitSubscriptionsUsecase,
          mockShowPaywallUsecase, mockGetCustomerInfoUsecase);
    });
    test('Initially emits SubscriptionLoading', () {
      expect(subscriptionBloc.state, SubscriptionLoading());
    });

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionInitial] when InitializeSubscription is added',
      build: () {
        when(mockInitSubscriptionsUsecase.execute())
            .thenAnswer((_) async => const Right(true));
        return subscriptionBloc;
      },
      act: (bloc) => bloc.add(const InitializeSubscription()),
      expect: () => [SubscriptionInitial()],
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
