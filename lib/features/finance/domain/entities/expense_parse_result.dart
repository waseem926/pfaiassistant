import '../../domain/entities/transaction_entity.dart';

class ExpenseParseResult {
  const ExpenseParseResult({
    required this.success,
    this.transaction,
    this.message = '',
  });

  final bool success;
  final TransactionEntity? transaction;
  final String message;

  factory ExpenseParseResult.failure(String message) {
    return ExpenseParseResult(success: false, message: message);
  }

  factory ExpenseParseResult.fromTransaction(TransactionEntity transaction) {
    return ExpenseParseResult(success: true, transaction: transaction);
  }
}
