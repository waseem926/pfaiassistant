import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FinanceRepository repository;

  ChatBloc({required this.repository}) : super(const ChatInitial()) {
    on<LoadChatHistoryEvent>(_onLoadChatHistory);
    on<SendMessageEvent>(_onSendMessage); 
  }

Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
  // Always work with a fresh copy of the PREVIOUS list
  final List<ChatMessageEntity> currentMessages = List.from(state.messages);

  final userMsg = ChatMessageEntity(
    text: event.message,
    role: MessageRole.user,
    timestamp: DateTime.now(),
  );

  final List<ChatMessageEntity> step1Messages = [...currentMessages, userMsg];
  emit(ChatLoading(step1Messages));

  try {
    final aiResponse = await repository.getAIResponse(event.message);
    
    // Merge the AI response into the list that already has the user message
    final List<ChatMessageEntity> step2Messages = [...step1Messages, aiResponse];
    emit(ChatSuccess(step2Messages));
  } catch (e) {
    emit(ChatFailure(step1Messages, e.toString()));
  }
}

  Future<void> _onLoadChatHistory(
    LoadChatHistoryEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading(state.messages));

    try {
      final transactions = await repository.getAllTransactions();

      final historyMessages = transactions.map((t) => ChatMessageEntity(
            text: "✅ Recorded ${t.amount} for ${t.description}.",
            role: MessageRole.model,
            timestamp: t.date,
          )).toList();

      emit(ChatSuccess(historyMessages));
    } catch (e) {
      emit(ChatFailure(state.messages, "Failed to load history: $e"));
    }
  }
}