import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/api/auth_api.dart';
import 'data/api/transaction_api.dart'; // Import TransactionApi
import 'data/local/secure_storage.dart';
import 'data/api/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/transaction_repository.dart'; // Import TransactionRepository
import 'presentation/blocs/auth/auth_bloc.dart';
import 'utils/notification_helper.dart';

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi layanan pendukung
    await NotificationHelper.initialize();

    // Inisialisasi ApiClient - Removed baseUrl parameter
    final apiClient = ApiClient(
      client: http.Client(),
      storage: const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ),
    );

    // Buat AuthApi dengan ApiClient
    final authApi = AuthApi(apiClient);
    
    // Buat TransactionApi dengan ApiClient
    final transactionApi = TransactionApi(apiClient);

    // Setup repositories
    final authRepository = AuthRepository(
      authApi: authApi,
      secureStorage: SecureStorageHelper.instance,
    );
    
    // Setup TransactionRepository
    final transactionRepository = TransactionRepository(transactionApi);

    // Jalankan aplikasi dengan provider
    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: apiClient),
          RepositoryProvider.value(value: SecureStorageHelper.instance),
        ],
        child: ChangeNotifierProvider.value(
          value: transactionRepository,
          child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthBloc(
                authRepository: authRepository,
              ),
            ),
            // You can add any TransactionBloc here if needed
            // Example:
            // BlocProvider(
            //   create: (context) => TransactionBloc(
            //     transactionRepository: transactionRepository,
            //   ),
            // ),
          ],
          child: const MyApp(),
        ),
        ),
      ),
    );
  } catch (e, stackTrace) {
    // Tangani error inisialisasi dengan lebih detail
    debugPrint('Initialization Error: $e');
    debugPrint('Stack Trace: $stackTrace');
  }
}