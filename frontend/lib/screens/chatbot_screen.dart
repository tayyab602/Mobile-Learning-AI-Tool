import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/chat_response.dart';
import '../widgets/loading_widget.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _addBotMessage('Hi! I\'m Dev Assistant. Ask me anything about software development, web development, or mobile app development!');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isBotMessage: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isBotMessage: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    if (_questionController.text.trim().isEmpty) return;

    final question = _questionController.text.trim();
    _questionController.clear();
    _addUserMessage(question);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.askChatbot(question);
      _addBotMessage(response.answer);

      // Add resource buttons if available
      if (response.responseType != 'text') {
        _messages.add(
          ChatMessage(
            text: '',
            isBotMessage: true,
            timestamp: DateTime.now(),
            imageUrl: response.imageUrl,
            pdfUrl: response.pdfUrl,
            wordUrl: response.wordUrl,
            isResourceMessage: true,
          ),
        );
        _scrollToBottom();
      }
    } catch (e) {
      _addBotMessage(
        'Sorry, I encountered an error: $e. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Assistant Chatbot'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(_messages[index]);
                    },
                  ),
          ),
          // Input field
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: LoadingWidget(message: 'Getting response...'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: 'Ask me a question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    backgroundColor: const Color(0xFF1976D2),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    if (message.isResourceMessage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.imageUrl != null)
                      SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.image),
                          label: const Text('View Image'),
                        ),
                      ),
                    if (message.pdfUrl != null)
                      SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                        ),
                      ),
                    if (message.wordUrl != null)
                      SizedBox(
                        width: 150,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.description),
                          label: const Text('Word'),
                        ),
                      ),
                  ].where((element) => element is SizedBox).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isBotMessage
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isBotMessage)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isBotMessage
                    ? Colors.grey[200]
                    : const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isBotMessage ? Colors.black : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (!message.isBotMessage)
            Container(
              margin: const EdgeInsets.only(left: 8),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBotMessage;
  final DateTime timestamp;
  final String? imageUrl;
  final String? pdfUrl;
  final String? wordUrl;
  final bool isResourceMessage;

  ChatMessage({
    required this.text,
    required this.isBotMessage,
    required this.timestamp,
    this.imageUrl,
    this.pdfUrl,
    this.wordUrl,
    this.isResourceMessage = false,
  });
}
