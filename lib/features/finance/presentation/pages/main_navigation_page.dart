import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/core/di/service_locator.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/chat_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/chat_event.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/analytics_page.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/chat_page.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/history_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ChatPage(),
    AnalyticsPage(),
    HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              serviceLocator<ChatBloc>()..add(LoadChatHistoryEvent()),
        ),
        BlocProvider(
          create: (context) =>
              serviceLocator<DashboardBloc>()..add(FetchExpensesEvent()),
        ),
      ],
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
