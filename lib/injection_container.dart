import 'package:buoy/features/subscription/data/data_sources/subscription_data_source.dart';
import 'package:buoy/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:buoy/features/subscription/domain/usecases/init_subscriptions_usecase.dart';
import 'package:buoy/features/subscription/domain/usecases/show_paywall_usecase.dart';
import 'package:buoy/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Subscription

  locator.registerLazySingleton<SubscriptionDataSource>(
      () => SubscriptionDataSourceImpl());
  locator.registerLazySingleton<SubscriptionRepository>(
      () => SubscriptionRepositoryImpl(subscriptionDataSource: locator()));
  locator.registerLazySingleton<InitSubscriptionsUsecase>(
      () => InitSubscriptionsUsecase(locator()));
  locator.registerLazySingleton<ShowPaywallUsecase>(
      () => ShowPaywallUsecase(locator()));
  locator.registerFactory<SubscriptionBloc>(
      () => SubscriptionBloc(locator(), locator()));
}
