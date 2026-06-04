enum MessageRole {user, model}

class ChatMessageEntity {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessageEntity ({
   required this.text,
   required this.role,
   required this.timestamp,
  });
} 