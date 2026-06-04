import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/chat_page.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/history_page.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import 'analytics_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ChatPage(),
    const AnalyticsPage(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:  (context) => serviceLocator<ChatBloc>()..add(LoadChatHistoryEvent()),
          ),
        BlocProvider(
          create:  (context) => serviceLocator<DashboardBloc>()..add(FetchExpensesEvent()),
          ),
      ],
      
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "ADD "),
            BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "ANALYTICS"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "HISTORY"),
          ],
        ),
      ),
    );
  }
}