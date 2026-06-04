import 'package:pfaiassistant/features/finance/domain/entities/transaction_entity.dart';

class TransactionValidator {
  static const allowedCategories = {
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Entertainment',
    'Groceries',
    'General',
  };

  static bool isValid(TransactionEntity transaction) {
    return transaction.amount > 0 &&
        transaction.category.trim().isNotEmpty &&
        transaction.description.trim().isNotEmpty &&
        transaction.description.toLowerCase() != 'failed to parse';
  }

  static String? validationError(TransactionEntity transaction) {
    if (transaction.amount <= 0) return 'Amount must be greater than zero.';
    if (transaction.category.trim().isEmpty) return 'Category is required.';
    if (transaction.description.trim().isEmpty) {
      return 'Description is required.';
    }
    if (transaction.description.toLowerCase() == 'failed to parse') {
      return 'Could not parse transaction details.';
    }
    return null;
  }
}
