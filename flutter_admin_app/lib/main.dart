import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'data/api/auth_api.dart';
import 'data/local/secure_storage.dart';
import 'data/api/api_client.dart';  // Pastikan import ini benar
import 'data/repositories/auth_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'utils/notification_helper.dart';

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi layanan pendukung
    await NotificationHelper.initialize();

    // Inisialisasi ApiClient
    final apiClient = ApiClient(
      baseUrl: 'http://127.0.0.1:8000/api/',
      client: http.Client(),
      storage: const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ),
    );

    // Buat AuthApi dengan ApiClient
    final authApi = AuthApi(apiClient);

    // Setup repository
    final authRepository = AuthRepository(
      authApi: authApi,
      secureStorage: SecureStorageHelper.instance,
    );

    // Jalankan aplikasi dengan provider
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: apiClient),
          RepositoryProvider.value(value: SecureStorageHelper.instance),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: authRepository,
              ),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    // Tangani error inisialisasi dengan lebih detail
    debugPrint('Initialization Error: $e');
    debugPrint('Stack Trace: $stackTrace');
  }
}