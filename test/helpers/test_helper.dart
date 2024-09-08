import 'package:buoy/features/subscription/data/data_sources/subscription_data_source.dart';
import 'package:buoy/features/subscription/domain/usecases/init_subscriptions_usecase.dart';
import 'package:buoy/features/subscription/domain/usecases/show_paywall_usecase.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks(
    [SubscriptionDataSource, InitSubscriptionsUsecase, ShowPaywallUsecase],
    customMocks: [])
void main() {}
