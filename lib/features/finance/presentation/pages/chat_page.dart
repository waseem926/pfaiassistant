import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/core/theme/app_theme.dart';
import 'package:pfaiassistant/core/widgets/theme_toggle_button.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/voice_input_page.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedCategory = 'Food';

  final List<Map<String, String>> categories = [
    {'label': 'Food', 'icon': '🍔'},
    {'label': 'Transport', 'icon': '🚗'},
    {'label': 'Bills', 'icon': '💡'},
    {'label': 'Shopping', 'icon': '🛍️'},
    {'label': 'Entertainment', 'icon': '🎬'},
    {'label': 'Groceries', 'icon': '🛒'},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitExpense() {
    if (_controller.text.isEmpty) return;

    final fullMessage = '[$selectedCategory] ${_controller.text}';
    context.read<ChatBloc>().add(SendMessageEvent(fullMessage));
    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Recording $selectedCategory expense...')),
    );
  }

  void _openVoiceInput() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<DashboardBloc>(),
          child: const VoiceInputPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Expense',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listenWhen: (previous, current) =>
            current is ChatSuccess && current.expenseRecorded,
        listener: (context, state) {
          context.read<DashboardBloc>().add(FetchExpensesEvent());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense recorded successfully')),
          );
        },
        child: BlocListener<ChatBloc, ChatState>(
          listenWhen: (previous, current) => current is ChatFailure,
          listener: (context, state) {
            if (state is ChatFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Type naturally or use voice',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.inputFillColor(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: const InputDecoration(
                      hintText: '500 for groceries',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'CATEGORY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _CategoryItem(
                      label: cat['label']!,
                      icon: cat['icon']!,
                      isSelected: selectedCategory == cat['label'],
                      onTap: () =>
                          setState(() => selectedCategory = cat['label']!),
                    );
                  },
                ),
                const Spacer(),
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: LinearProgressIndicator(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submitExpense,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add Expense',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _openVoiceInput,
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.mic_none,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.chipBackground(context, selected: isSelected),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.chipBorderColor(context, selected: isSelected),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: AppTheme.chipLabelColor(context, selected: isSelected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
