import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction_model.dart';


abstract class FinanceRemoteDataSource {
  Future<TransactionModel> getParsedTransaction(String prompt);
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final GenerativeModel model;

  FinanceRemoteDataSourceImpl({required this.model});

  @override
  Future<TransactionModel> getParsedTransaction(String prompt) async {
    // SYSTEM PROMPT: To force gemini to return json response.
    final systemPrompt = """
    You are a financial assistant. Extract transaction data from the user's text.
    Return ONLY a JSON object with these keys: 'amount', 'category', 'description'.
    Example: { "amount": 500.0, "category": "Food", "description": "Biryani" }
    If no transaction is found, return empty values.
    """;

    final content = [Content.text("$systemPrompt \n User: $prompt")];
    final response = await model.generateContent(content);

    String responseText = response.text ?? "{}";

    if (responseText.contains("```")) {
    responseText = responseText.replaceAll(RegExp(r'```json|```'), '').trim();
    }

    final int startIndex = responseText.indexOf('{');
    final int endIndex = responseText.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1) {
      responseText = responseText.substring(startIndex, endIndex + 1);
    }

    // Parse the string into JSON
    try {
    final Map<String, dynamic> jsonMap = jsonDecode(responseText);
    return TransactionModel.fromJson(jsonMap);
    } catch (e) {
      print("JSON Parsing Error: $e");
      print("Raw string was: $responseText");

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