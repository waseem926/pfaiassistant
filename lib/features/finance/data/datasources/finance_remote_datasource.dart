import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/transaction_model.dart';

abstract class FinanceRemoteDataSource {
  Future<TransactionModel> getParsedTransaction(String prompt);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  FinanceRemoteDataSourceImpl({required this.model});

  final GenerativeModel model;

  @override
  Future<TransactionModel> getParsedTransaction(String prompt) async {
    const systemPrompt = '''
You are a financial assistant. Extract transaction data from the user's text.
Return ONLY a JSON object with these keys: 'amount', 'category', 'description'.
Example: { "amount": 500.0, "category": "Food", "description": "Biryani" }
If no transaction is found, return empty values.
''';

    final content = [Content.text('$systemPrompt \n User: $prompt')];
    final response = await model.generateContent(content);

    var responseText = response.text ?? '{}';

    if (responseText.contains('```')) {
      responseText =
          responseText.replaceAll(RegExp(r'```json|```'), '').trim();
    }

    final startIndex = responseText.indexOf('{');
    final endIndex = responseText.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1) {
      responseText = responseText.substring(startIndex, endIndex + 1);
    }

    try {
      final jsonMap = jsonDecode(responseText) as Map<String, dynamic>;
      return TransactionModel.fromJson(jsonMap);
    } catch (_) {
      return TransactionModel(
        id: DateTime.now().toString(),
        amount: 0.0,
        category: 'Unknown',
        description: 'Failed to parse',
        date: DateTime.now(),
      );
    }
  }
}
