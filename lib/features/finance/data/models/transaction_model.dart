import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.description,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: 'temp_${DateTime.now().microsecondsSinceEpoch}',
      amount: _parseAmount(json['amount']),
      category: _parseString(json['category'], fallback: 'General'),
      description: _parseString(
        json['description'],
        fallback: 'No description',
      ),
      date: DateTime.now(),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0;

    if (value is num) return value.toDouble();

    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }

    return 0;
  }

  static String _parseString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  TransactionEntity toEntity() => this;
}
