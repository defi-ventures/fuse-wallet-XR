import 'package:fusecash/worldxr/src/services/auth_service.dart';
import 'package:fusecash/worldxr/src/services/unity_service.dart';
import 'package:fusecash/worldxr/src/services/wallet_service.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

registerLocatorItems() {
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => UnityService());
  locator.registerLazySingleton(() => WalletService());
}
