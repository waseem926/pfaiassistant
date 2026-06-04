import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatState extends Equatable {
  final List<ChatMessageEntity> messages;
  const ChatState(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial() : super(const []);
}

class ChatLoading extends ChatState {
  const ChatLoading(super.messages);
}

class ChatSuccess extends ChatState {
  final bool expenseRecorded;

  const ChatSuccess(super.messages, {this.expenseRecorded = false});

  @override
  List<Object?> get props => [messages, expenseRecorded];
}

class ChatFailure extends ChatState {
  final String error;

  const ChatFailure(super.messages, this.error);

  @override
  List<Object?> get props => [messages, error];
}
