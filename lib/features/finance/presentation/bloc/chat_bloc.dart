import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required this.repository}) : super(const ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage);
  }

  final FinanceRepository repository;

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final currentMessages = List<ChatMessageEntity>.from(state.messages);

    final userMsg = ChatMessageEntity(
      text: event.message,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final withUserMessage = [...currentMessages, userMsg];
    emit(ChatLoading(withUserMessage));

    try {
      final aiResponse = await repository.getAIResponse(event.message);
      final expenseRecorded = aiResponse.text.startsWith('✅');

      emit(
        ChatSuccess(
          [...withUserMessage, aiResponse],
          expenseRecorded: expenseRecorded,
        ),
      );
    } catch (e) {
      emit(ChatFailure(withUserMessage, e.toString()));
    }
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading(state.messages));

    try {
      final transactions = await repository.getAllTransactions();

      final historyMessages = transactions
          .map(
            (t) => ChatMessageEntity(
              text: '✅ Recorded ${t.amount} for ${t.description}.',
              role: MessageRole.model,
              timestamp: t.date,
            ),
          )
          .toList();

      emit(ChatSuccess(historyMessages));
    } catch (e) {
      emit(ChatFailure(state.messages, 'Failed to load history: $e'));
    }
  }
}
