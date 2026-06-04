import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pfaiassistant/core/di/service_locator.dart';
import 'package:pfaiassistant/core/theme/app_theme.dart';
import 'package:pfaiassistant/features/finance/domain/repositories/finance_repository.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _words = '';
  bool _isProcessing = false;
  bool _showReview = false;
  String? _errorMessage;

  double _parsedAmount = 0;
  String _parsedCategory = '';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startListening() async {
    final hasPermission = await _ensureMicrophonePermission();
    if (!mounted) return;

    if (!hasPermission) {
      setState(() {
        _errorMessage = 'Microphone permission is required for voice input.';
      });
      return;
    }

    final available = await _speech.initialize();
    if (!mounted) return;

    if (!available) {
      setState(() {
        _errorMessage = 'Speech recognition is not available on this device.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _words = result.recognizedWords;
          if (result.finalResult) {
            _isListening = false;
            _processWithAI(_words);
          }
        });
      },
      listenOptions: stt.SpeechListenOptions(partialResults: true),
    );
  }

  Future<void> _processWithAI(String text) async {
    if (text.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final result =
          await serviceLocator<FinanceRepository>().getAIResponse(text);
      if (!mounted) return;

      final words = result.text.split(' ');
      final amount = double.tryParse(
            words.firstWhere(
              (word) => double.tryParse(word) != null,
              orElse: () => '0',
            ),
          ) ??
          0;

      setState(() {
        _isProcessing = false;
        _parsedAmount = amount;
        _parsedCategory =
            words.length > 1 ? words.last.replaceAll('.', '') : '';
        _showReview = amount > 0;
      });

      if (amount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI couldn't find an amount. Try again?"),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sorry, couldn't process that expense.")),
      );
    }
  }

  void _onConfirm() {
    context.read<DashboardBloc>().add(FetchExpensesEvent());
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Expense saved successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _statusTitle {
    if (_errorMessage != null) return 'Unavailable';
    if (_isProcessing) return 'Processing';
    if (_showReview) return 'Got it';
    if (_isListening) return 'Listening';
    return 'Ready';
  }

  String get _statusSubtitle {
    if (_errorMessage != null) return _errorMessage!;
    if (_isProcessing) return 'Analyzing your expense';
    if (_showReview) return 'Review your expense';
    if (_isListening) return 'Speak naturally';
    return 'Tap below to try again';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outline),
              ),
              child: Icon(
                Icons.close,
                color: colorScheme.onSurface,
                size: 16,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(child: _buildStatusIcon(context)),
            const SizedBox(height: 40),
            Text(
              _statusTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _statusSubtitle,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (_isProcessing)
              const CircularProgressIndicator()
            else if (!_showReview && _errorMessage == null)
              _buildWaveform(context),
            const SizedBox(height: 40),
            _buildInfoCard(
              context,
              title: 'TRANSCRIPT',
              content: _words.isEmpty ? '...' : _words,
            ),
            const SizedBox(height: 20),
            if (_showReview) _buildDetectedCard(context),
            const Spacer(),
            if (_errorMessage != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startListening,
                  child: const Text('Try again'),
                ),
              ),
            if (_showReview) _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _showReview
            ? colorScheme.primaryContainer
            : colorScheme.onSurface,
      ),
      child: Icon(
        _errorMessage != null
            ? Icons.mic_off
            : _showReview
                ? Icons.check
                : _isProcessing
                    ? Icons.hourglass_top
                    : Icons.mic,
        color: _showReview ? Colors.green : colorScheme.surface,
        size: 50,
      ),
    );
  }

  Widget _buildWaveform(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(15, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 4,
          height: index.isEven ? 20 : 40,
          decoration: BoxDecoration(
            color: colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor(context),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.chipBackground(context, selected: true),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.chipBorderColor(context, selected: true),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 8),
              const SizedBox(width: 8),
              Text(
                'DETECTED',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDataRow(context, 'Amount', _parsedAmount.toString()),
          Divider(
            height: 32,
            color: colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          _buildDataRow(context, 'Category', _parsedCategory, icon: '🛒'),
        ],
      ),
    );
  }

  Widget _buildDataRow(
    BuildContext context,
    String label,
    String value, {
    String? icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            if (icon != null) Text(icon, style: const TextStyle(fontSize: 18)),
            if (icon != null) const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: colorScheme.outline),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onSurface,
              foregroundColor: colorScheme.surface,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _onConfirm,
            icon: const Icon(Icons.check, size: 18),
            label: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
