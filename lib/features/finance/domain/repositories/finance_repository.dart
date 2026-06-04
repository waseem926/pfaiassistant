import '../entities/transaction_entity.dart';
import '../entities/chat_message_entity.dart';

abstract class FinanceRepository {

  // To talk to Gemini
  Future<ChatMessageEntity> getAIResponse(String prompt);

  // To save the identified transaction to local DB
  Future<void> saveTransaction(TransactionEntity transaction);

  // To get all transactions for the dashboard
  Future<List<TransactionEntity>> getAllTransactions();

  Future<List<TransactionEntity>> searchTransactions(String query);
}