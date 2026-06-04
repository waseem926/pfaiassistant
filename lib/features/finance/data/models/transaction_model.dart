import '../../domain/entities/transaction_entity.dart';

class TransactionModel  extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.description,
    required super.date,
  });

  // Convert JSON (from AI) to Model
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: "temp_${DateTime.now().microsecondsSinceEpoch}",
      amount: (json['amount'] ?? 0.0).toDouble(),
      category: json['category'] ?? 'General',
      description:json['description'] ?? 'No Description',
      date: DateTime.now(),
    );
  }

  // Convert Model back to Entity (to pass to Domain layer)
  TransactionEntity toEntity() => this;

}