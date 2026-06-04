import '../entities/chat_message_entity.dart';
import '../entities/expense_parse_result.dart';
import '../entities/transaction_entity.dart';

abstract class FinanceRepository {
  Future<ChatMessageEntity> getAIResponse(String prompt);

  Future<ExpenseParseResult> parseExpense(String prompt);

  Future<void> saveTransaction(TransactionEntity transaction);

  Future<List<TransactionEntity>> getAllTransactions();

  Future<List<TransactionEntity>> searchTransactions(String query);
}
