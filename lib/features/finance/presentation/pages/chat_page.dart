import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/pages/voice_input_page.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import '../bloc/chat_event.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pfaiassistant/core/di/service_locator.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/dashboard_event.dart';
import '../../domain/repositories/finance_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String selectedCategory = "Food";

  // Categories from your Figma Design
  final List<Map<String, String>> categories = [
    {"label": "Food", "icon": "🍔"},
    {"label": "Transport", "icon": "🚗"},
    {"label": "Bills", "icon": "💡"},
    {"label": "Shopping", "icon": "🛍️"},
    {"label": "Entertainment", "icon": "🎬"},
    {"label": "Groceries", "icon": "🛒"},
  ];

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          if (val.finalResult) {
            setState(() => _isListening = false);
            _controller.text = val.recognizedWords;
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _submitExpense() {
    if (_controller.text.isNotEmpty) {
      final fullMessage = "[$selectedCategory] ${_controller.text}";
      context.read<ChatBloc>().add(SendMessageEvent(fullMessage));
      _controller.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Recording $selectedCategory expense..."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: const Text("Add Expense",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE0F2FE),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.dark_mode_outlined,
                  color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),
          ),
        ],
      ),
      body: BlocListener<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatSuccess) {

            context.read<DashboardBloc>().add(FetchExpensesEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
              content: Text("Recorded Successfully..."),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
      );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text("Type naturally or use voice",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              const SizedBox(height: 24),

              // 1. SEARCH/TEXT INPUT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "500 for groceries",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 2. CATEGORY GRID
              const Text("CATEGORY",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.1)),
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
                    onTap: () => setState(() => selectedCategory = cat['label']!),
                  );
                },
              ),

              const Spacer(),
              
              // LOADING INDICATOR
              BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) return const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: LinearProgressIndicator(),
                  );
                  return const SizedBox.shrink();
                },
              ),

              // 3. ACTION BUTTONS (Add & Voice)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9E9E9E),
                        foregroundColor: Theme.of(context).colorScheme.surface,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _submitExpense,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Expense",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VoiceInputPage()));
                    },
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic_none,
                        color: _isListening ? Colors.red : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3E8FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFD8B4FE) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF7C3AED) : Colors.grey[600],
                )),
          ],
        ),
      ),
    );
  }
}