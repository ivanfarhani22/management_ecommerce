import 'package:get_it/get_it.dart';
import 'package:flutter_admin_app/data/api/api_client.dart';
import 'package:flutter_admin_app/data/api/finance_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;

  static void setup() {
    // Register secure storage
    _getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage()
    );

    // Register api client
    _getIt.registerLazySingleton<ApiClient>(() => ApiClient(
      client: null,
      storage: _getIt<FlutterSecureStorage>(),
    ));

    // Register finance api
    _getIt.registerLazySingleton<FinanceApi>(() => FinanceApi(_getIt<ApiClient>()));
  }

  static T get<T extends Object>() {
    return _getIt<T>();
  }
}