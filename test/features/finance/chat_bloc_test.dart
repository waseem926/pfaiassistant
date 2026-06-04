import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pfaiassistant/features/finance/domain/entities/chat_message_entity.dart';
import 'package:pfaiassistant/features/finance/domain/entities/transaction_entity.dart';
import 'package:pfaiassistant/features/finance/domain/repositories/finance_repository.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/chat_bloc.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/chat_event.dart';
import 'package:pfaiassistant/features/finance/presentation/bloc/chat_state.dart';

class MockFinanceRepository extends Mock implements FinanceRepository {}

void main() {
  late MockFinanceRepository repository;
  late ChatBloc bloc;

  setUp(() {
    repository = MockFinanceRepository();
    bloc = ChatBloc(repository: repository);
  });

  tearDown(() => bloc.close());

  blocTest<ChatBloc, ChatState>(
    'emits success with expenseRecorded when AI saves expense',
    build: () {
      when(() => repository.getAIResponse('500 groceries')).thenAnswer(
        (_) async => ChatMessageEntity(
          text: '✅ Recorded 500.0 for groceries.',
          role: MessageRole.model,
          timestamp: DateTime(2026, 1, 1),
        ),
      );
      return bloc;
    },
    act: (bloc) => bloc.add(const SendMessageEvent('500 groceries')),
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatSuccess>().having(
        (state) => state.expenseRecorded,
        'expenseRecorded',
        isTrue,
      ),
    ],
  );

  blocTest<ChatBloc, ChatState>(
    'emits failure when repository throws',
    build: () {
      when(() => repository.getAIResponse(any())).thenThrow(Exception('network'));
      return bloc;
    },
    act: (bloc) => bloc.add(const SendMessageEvent('500 groceries')),
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatFailure>(),
    ],
  );

  blocTest<ChatBloc, ChatState>(
    'loads transaction history as chat messages',
    build: () {
      when(() => repository.getAllTransactions()).thenAnswer(
        (_) async => [
          TransactionEntity(
            id: '1',
            amount: 250,
            category: 'Food',
            description: 'Lunch',
            date: DateTime(2026, 1, 2),
          ),
        ],
      );
      return bloc;
    },
    act: (bloc) => bloc.add(LoadChatHistoryEvent()),
    expect: () => [
      isA<ChatLoading>(),
      isA<ChatSuccess>().having(
        (state) => state.messages.length,
        'message count',
        1,
      ),
    ],
  );
}
