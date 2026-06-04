import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/core/config/app_config.dart';
import 'package:pfaiassistant/core/theme/app_theme.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/main_navigation_page.dart';
import 'package:pfaiassistant/features/settings/presentation/bloc/theme_cubit.dart';
import 'core/di/service_locator.dart' as di;
import 'package:pfaiassistant/features/auth/presentation/pages/login_page.dart';
import 'package:pfaiassistant/features/auth/presentation/pages/register_page.dart';
import 'package:pfaiassistant/features/auth/presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.load();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.serviceLocator<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'AI Finance Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashPage(),
              '/register': (context) => const RegisterPage(),
              '/login': (context) => const LoginPage(),
              '/home': (context) => const MainNavigationPage(),
            },
          );
        },
      ),
    );
  }
}
