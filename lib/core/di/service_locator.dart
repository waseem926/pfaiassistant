import 'package:get_it/get_it.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:pfaiassistant/core/config/app_config.dart';
import 'package:pfaiassistant/core/database/app_database.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import '../../features/finance/data/datasources/finance_remote_datasource.dart';
import '../../features/finance/data/repositories/finance_repository_impl.dart';
import '../../features/finance/domain/repositories/finance_repository.dart';
import '../../features/finance/presentation/bloc/chat_bloc.dart';
import '../../features/finance/data/datasources/finance_local_datasource.dart';
import 'package:pfaiassistant/core/services/auth_service.dart';
import 'package:pfaiassistant/core/services/security_service.dart';
import 'package:pfaiassistant/features/settings/presentation/bloc/theme_cubit.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  final config = AppConfig.instance;

  final db = AppDatabase();
  serviceLocator.registerSingleton<AppDatabase>(db);

  // TODO(Day 3+): swap to Node API when AppConfig.useNodeApi is true.
  serviceLocator.registerLazySingleton(
    () =>
        GenerativeModel(model: 'gemini-2.5-flash', apiKey: config.geminiApiKey),
  );

  serviceLocator.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(model: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<FinanceLocalDataSource>(
    () => FinanceLocalDataSourceImpl(database: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(() => ChatBloc(repository: serviceLocator()));

  serviceLocator.registerFactory(
    () => DashboardBloc(repository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => SecurityService());

  serviceLocator.registerLazySingleton(() => AuthService());

  final themeCubit = ThemeCubit();
  await themeCubit.loadSavedTheme();
  serviceLocator.registerSingleton<ThemeCubit>(themeCubit);
}
