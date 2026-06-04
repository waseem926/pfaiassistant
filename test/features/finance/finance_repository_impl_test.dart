import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pfaiassistant/features/finance/data/datasources/finance_local_datasource.dart';
import 'package:pfaiassistant/features/finance/data/datasources/finance_remote_datasource.dart';
import 'package:pfaiassistant/features/finance/data/models/transaction_model.dart';
import 'package:pfaiassistant/features/finance/data/repositories/finance_repository_impl.dart';

import 'package:pfaiassistant/features/finance/domain/entities/transaction_entity.dart';

class MockFinanceRemoteDataSource extends Mock
    implements FinanceRemoteDataSource {}

class MockFinanceLocalDataSource extends Mock
    implements FinanceLocalDataSource {}

void main() {
  late MockFinanceRemoteDataSource remote;
  late MockFinanceLocalDataSource local;
  late FinanceRepositoryImpl repository;

  setUp(() {
    remote = MockFinanceRemoteDataSource();
    local = MockFinanceLocalDataSource();
    repository = FinanceRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );

    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        amount: 1,
        category: 'Food',
        description: 'Test',
        date: DateTime(2026),
      ),
    );
  });

  test('parseExpense returns success for valid transaction', () async {
    when(() => remote.getParsedTransaction('500 lunch')).thenAnswer(
      (_) async => TransactionModel(
        id: '1',
        amount: 500,
        category: 'Food',
        description: 'Lunch',
        date: DateTime(2026, 1, 1),
      ),
    );

    final result = await repository.parseExpense('500 lunch');

    expect(result.success, isTrue);
    expect(result.transaction?.amount, 500);
  });

  test('parseExpense rejects zero amount', () async {
    when(() => remote.getParsedTransaction('hello')).thenAnswer(
      (_) async => TransactionModel(
        id: '1',
        amount: 0,
        category: 'Food',
        description: 'Unknown',
        date: DateTime(2026, 1, 1),
      ),
    );

    final result = await repository.parseExpense('hello');

    expect(result.success, isFalse);
  });

  test('getAIResponse saves valid transaction', () async {
    when(() => remote.getParsedTransaction('[Food] 500 lunch')).thenAnswer(
      (_) async => TransactionModel(
        id: '1',
        amount: 500,
        category: 'Food',
        description: 'Lunch',
        date: DateTime(2026, 1, 1),
      ),
    );
    when(() => local.saveTransaction(any())).thenAnswer((_) async {});

    final response = await repository.getAIResponse('[Food] 500 lunch');

    expect(response.text.startsWith('✅'), isTrue);
    verify(() => local.saveTransaction(any())).called(1);
  });
}
