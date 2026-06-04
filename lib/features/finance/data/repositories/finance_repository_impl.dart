import 'package:pfaiassistant/features/finance/data/datasources/finance_local_datasource.dart';
import 'package:pfaiassistant/features/finance/data/datasources/finance_remote_datasource.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/expense_parse_result.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  FinanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final FinanceRemoteDataSource remoteDataSource;
  final FinanceLocalDataSource localDataSource;

  @override
  Future<ExpenseParseResult> parseExpense(String prompt) async {
    try {
      final transactionModel =
          await remoteDataSource.getParsedTransaction(prompt);

      if (transactionModel.amount > 0) {
        return ExpenseParseResult.fromTransaction(transactionModel);
      }

      return ExpenseParseResult.failure(
        "I couldn't find a specific expense in your message.",
      );
    } catch (_) {
      return ExpenseParseResult.failure(
        "Sorry, I couldn't process that expense. Please try again.",
      );
    }
  }

  @override
  Future<ChatMessageEntity> getAIResponse(String prompt) async {
    final parsed = await parseExpense(prompt);

    if (parsed.success && parsed.transaction != null) {
      final transaction = parsed.transaction!;
      await localDataSource.saveTransaction(transaction);

      return ChatMessageEntity(
        text: '✅ Recorded ${transaction.amount} for ${transaction.description}.',
        role: MessageRole.model,
        timestamp: DateTime.now(),
      );
    }

    return ChatMessageEntity(
      text: parsed.message.isNotEmpty
          ? parsed.message
          : "I couldn't find a specific expense in your message.",
      role: MessageRole.model,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    await localDataSource.saveTransaction(transaction);
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final dbList = await localDataSource.getAllTransactions();

    return dbList
        .map(
          (db) => TransactionEntity(
            id: db.id.toString(),
            amount: db.amount,
            category: db.category,
            description: db.description,
            date: db.date,
          ),
        )
        .toList();
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    final dbList = await localDataSource.searchTransactions(query);

    return dbList
        .map(
          (db) => TransactionEntity(
            id: db.id.toString(),
            amount: db.amount,
            category: db.category,
            description: db.description,
            date: db.date,
          ),
        )
        .toList();
  }
}
