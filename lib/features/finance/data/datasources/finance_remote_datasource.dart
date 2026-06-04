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
    var userPrompt = prompt;
    var preferredCategory = '';

    final categoryMatch = RegExp(r'^\[([^\]]+)\]\s*(.*)$').firstMatch(prompt);
    if (categoryMatch != null) {
      preferredCategory = categoryMatch.group(1) ?? '';
      userPrompt = categoryMatch.group(2) ?? prompt;
    }

    final systemPrompt =
        '''
You are a financial assistant. Extract transaction data from the user's text.
Return ONLY a JSON object with these keys: "amount", "category", "description".
Rules:
- "amount" must be a number greater than 0 when an expense is found
- "category" must be a short label such as Food, Transport, Bills, Shopping, Entertainment, or Groceries
- "description" must briefly describe the purchase
Example: { "amount": 500, "category": "Food", "description": "Biryani" }
If no transaction is found, return: { "amount": 0, "category": "", "description": "" }
${preferredCategory.isNotEmpty ? 'Prefer category: $preferredCategory' : ''}
''';

    final content = [Content.text('$systemPrompt \n User: $userPrompt')];
    final response = await model.generateContent(content);

    var responseText = response.text ?? '{}';

    if (responseText.contains('```')) {
      responseText = responseText.replaceAll(RegExp(r'```json|```'), '').trim();
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
