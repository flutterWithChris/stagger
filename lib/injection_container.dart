import 'package:buoy/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:buoy/features/notifications/domain/repository/notification_repository.dart';
import 'package:buoy/features/notifications/domain/usecase/check_notification_permission_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/initialize_notifications_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/set_notifications_listener_usecase.dart';
import 'package:buoy/features/notifications/domain/usecase/show_notification_usecase.dart';
import 'package:buoy/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:buoy/features/subscription/data/data_sources/subscription_data_source.dart';
import 'package:buoy/features/subscription/data/repositories/subscription_repository_impl.dart';
import 'package:buoy/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:buoy/features/subscription/domain/usecases/get_customer_info_usecase.dart';
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
  locator.registerLazySingleton(() => GetCustomerInfoUsecase(locator()));
  locator.registerFactory<SubscriptionBloc>(
      () => SubscriptionBloc(locator(), locator(), locator()));
  // Notifications
  locator.registerFactory<InitializeNotificationsUsecase>(
      () => InitializeNotificationsUsecase(locator()));
  locator.registerFactory<ShowNotificationUsecase>(
      () => ShowNotificationUsecase(locator()));
  locator.registerFactory<SetNotificationsListenerUsecase>(
      () => SetNotificationsListenerUsecase(locator()));
  locator.registerFactory<CheckNotificationPermissionUsecase>(
      () => CheckNotificationPermissionUsecase(locator()));
  locator.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl());
  locator.registerFactory<NotificationBloc>(() => NotificationBloc(
      initializeNotificationsUsecase: locator(),
      showNotificationUsecase: locator(),
      setNotificationsListenerUsecase: locator(),
      checkNotificationPermissionUsecase: locator()));
}
