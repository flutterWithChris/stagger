import 'package:buoy/locate/view/home.dart';
import 'package:go_router/go_router.dart';

GoRouter goRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (context, state) => const Home()),
]);
