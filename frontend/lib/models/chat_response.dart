class ChatResponse {
  final int? chatId;
  final String answer;
  final String responseType;
  final String? imageUrl;
  final String? pdfUrl;
  final String? wordUrl;
  final String modelUsed;

  ChatResponse({
    this.chatId,
    required this.answer,
    required this.responseType,
    this.imageUrl,
    this.pdfUrl,
    this.wordUrl,
    required this.modelUsed,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      chatId: json['chat_id'],
      answer: json['answer'] ?? '',
      responseType: json['response_type'] ?? 'text',
      imageUrl: json['image_url'],
      pdfUrl: json['pdf_url'],
      wordUrl: json['word_url'],
      modelUsed: json['model_used'] ?? 'unknown',
    );
  }
}
