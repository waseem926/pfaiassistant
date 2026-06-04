import 'package:pfaiassistant/core/database/app_database.dart';
import 'package:pfaiassistant/features/finance/domain/entities/transaction_entity.dart';

abstract class FinanceLocalDataSource {
  Future<void> saveTransaction(TransactionEntity transaction);
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> searchTransactions(String query);
}

class FinanceLocalDataSourceImpl implements FinanceLocalDataSource {
  FinanceLocalDataSourceImpl({required this.database});

  final AppDatabase database;

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    await database.into(database.transactions).insert(
          TransactionsCompanion.insert(
            amount: transaction.amount,
            category: transaction.category,
            description: transaction.description,
            date: transaction.date,
          ),
        );
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return database.getAllTransactions();
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    return database.searchTransactions(query);
  }
}
