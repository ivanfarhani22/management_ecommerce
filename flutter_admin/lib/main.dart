import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/api/auth_api.dart';
import 'data/api/transaction_api.dart';
import 'data/local/secure_storage.dart';
import 'data/api/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'utils/notification_helper.dart';
import 'data/api/service_locator.dart'; // Import the ServiceLocator

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize the ServiceLocator first
    ServiceLocator.setup();
    
    // Inisialisasi layanan pendukung
    await NotificationHelper.initialize();

    // Get the initialized ApiClient from ServiceLocator
    final apiClient = ServiceLocator.get<ApiClient>();
    
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