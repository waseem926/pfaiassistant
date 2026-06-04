import 'package:pfaiassistant/features/finance/data/datasources/finance_local_datasource.dart';
import 'package:pfaiassistant/features/finance/data/datasources/finance_remote_datasource.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/entities/chat_message_entity.dart';

class FinanceRepositoryImpl implements FinanceRepository {

  final FinanceRemoteDataSource remoteDataSource;
  final FinanceLocalDataSource localDataSource;


  FinanceRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
Future<ChatMessageEntity> getAIResponse(String prompt) async {
  try {
    print("REPO: Calling AI...");
    final transactionModel = await remoteDataSource.getParsedTransaction(prompt);
    print("REPO: AI returned: ${transactionModel.amount}");
    
    if (transactionModel.amount > 0) {
       print("REPO: Saving to Database...");
       await localDataSource.saveTransaction(transactionModel);
       print("REPO: Saved Successfully!");
       
       return ChatMessageEntity(
         text: "✅ Recorded ${transactionModel.amount} for ${transactionModel.description}.",
         role: MessageRole.model,
         timestamp: DateTime.now(),
       );
    } else {
       return ChatMessageEntity(
         text: "I couldn't find a specific expense in your message.",
         role: MessageRole.model,
         timestamp: DateTime.now(),
       );
    }
  } catch (e, stack) {
    // THIS IS THE MOST IMPORTANT PART
    print("CRITICAL ERROR IN REPO: $e");
    print("STACKTRACE: $stack"); 
    
    return ChatMessageEntity(
      text: "Error: $e", // Show the actual error to the user for debugging
      role: MessageRole.model,
      timestamp: DateTime.now(),
    );
  }
}

  @override
  Future<void> saveTransaction(TransactionEntity transaction) async {
    await localDataSource.saveTransaction(transaction);
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final dbList = await localDataSource.getAllTransactions();

    return dbList.map((db) => TransactionEntity(
      id: db.id.toString(), 
      amount: db.amount, 
      category: db.category, 
      description: db.description,
       date: db.date)).toList();
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    final dbList = await localDataSource.searchTransactions(query);
    return dbList.map((db) => TransactionEntity(
      id: db.id.toString(),
      amount: db.amount,
      category: db.category,
      description: db.description,
      date: db.date)).toList();
  }
}