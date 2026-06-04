import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pfaiassistant/core/di/service_locator.dart';
import 'package:pfaiassistant/features/finance/domain/repositories/finance_repository.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _words = "";
  bool _isProcessing = false;
  bool _showReview = false;

  double _parsedAmount = 0.0;
  String _parsedCategory = "";
  String _parsedDescription = "";

  // Mock detected data (In real app, this comes from ChatBloc / Gemini)
  String _detectedAmount = "500 PKR";
  String _detectedCategory = "Groceries";

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) {
          setState(() {
            _words = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _processWithAI(_words);
            }
          });
        }
      );
    }
  }

  void _processWithAI(String text) async {
    setState(() => _isProcessing = true);

    try {
      final result = await serviceLocator<FinanceRepository>().getAIResponse(text);

      setState(() {
        _isProcessing = false;
        _showReview = true;

        final words = result.text.split(' ');

        _parsedAmount = double.tryParse(words.firstWhere((w) => double.tryParse(w) != null, orElse: () => "0")) ?? 0.0;

        _parsedCategory = words.last.replaceAll('.', '');

        if (_parsedAmount == 0) {
          _showReview = false;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AI couldn't find an amount. Try again?"))
          );
        }
      });
    } catch (e) {
      setState(() => _isProcessing = false); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    }
  }

  void _onConfirm() {
    context.read<ChatBloc>().add(SendMessageEvent(_words));

    context.read<DashboardBloc>().add(FetchExpensesEvent());

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Expense Saved Successfully"), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 16),
            ),
            onPressed: () => Navigator.pop(context), 
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(child: _buildStatusIcon()),
            const SizedBox(height: 40),

            Text(
              _showReview ? "Got it" : "Listening",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _showReview ? "Review your expense" : "Speak naturallly",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),

            if (!_showReview) _buildWaveform(),
            const SizedBox(height: 40),

            _buildInfoCard(
              title: "TRANSCRIPT",
              content: _words.isEmpty ? "..." : _words,
              backgroundColor: const Color(0xFFF8F9FA),
            ),

            const SizedBox(height: 20),

            if(_showReview) 
              _buildDetectedCard(),
            

            const Spacer(),

            if (_showReview) _buildActionButtons(),
            const SizedBox(height: 40),
          ], 
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _showReview ? const Color(0xFFF8F5E9) : Theme.of(context).colorScheme.onSurface,
      ),
      child: Icon(
        _showReview ? Icons.check : Icons.mic,
        color: _showReview ? Colors.green : Theme.of(context).colorScheme.surface,
        size: 50,
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: (index % 2 == 0) ? 20 : 40,
          decoration: BoxDecoration(
            color : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard({required String title, required String content, required Color backgroundColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface87)),
        ],
      ),
    );
  }

  Widget _buildDetectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, color: Colors.green, size: 8),
              SizedBox(width: 8),
              Text("DETECTED", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildDataRow("Amount", _detectedAmount),
          const Divider(height: 32, color: Theme.of(context).colorScheme.onSurface12),
          _buildDataRow("Category", _detectedCategory, icon: "🛒"),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {String? icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Row(
          children: [
            if(icon != null) Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        )
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, color: Theme.of(context).colorScheme.surface, size: 18),
            label: const Text("Confirm", style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}