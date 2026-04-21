import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🚀 dotenv 임포트

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    // 🚀 .env 파일에서 API 키를 안전하게 불러옵니다.
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final apiModel = dotenv.env['GEMINI_MODEL'];

    if (apiKey == null) {
      debugPrint('🚨 [오류] .env 파일에서 GEMINI_API_KEY를 찾을 수 없습니다.');
      setState(() {
        _messages.add({'role': 'model', 'text': 'API 키를 찾을 수 없습니다. .env 파일을 확인해주세요.'});
        _isLoading = false;
      });
      return;
    }

    if (apiModel == null) {
      debugPrint('🚨 [오류] .env 파일에서 GEMINI_MODEL을 찾을 수 없습니다.');
      setState(() {
        _messages.add({'role': 'model', 'text': 'API Model을 찾을 수 없습니다. .env 파일을 확인해주세요.'});
        _isLoading = false;
      });
      return;
    }

    try {
      debugPrint('🚀 [요청] Gemini API 호출 시작 - 모델: $apiModel');
      final model = GenerativeModel(
        model: apiModel,
        apiKey: apiKey,
      );

      final content = [Content.text(text)];
      final response = await model.generateContent(content);

      debugPrint('✅ [성공] Gemini API 응답 완료');

      setState(() {
        _messages.add({'role': 'model', 'text': response.text ?? '응답을 받을 수 없습니다.'});
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      // 🔥 에러 로깅 추가: 에러 객체와 스택 트레이스를 모두 출력합니다.
      debugPrint('🔥 [예외 발생] Gemini API 호출 중 에러: $e');
      debugPrint('🔥 [스택 트레이스]: $stackTrace');

      setState(() {
        _messages.add({'role': 'model', 'text': '오류가 발생했습니다. API 키나 네트워크 상태를 확인해주세요!'});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가족 AI 조수 🤖'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'AI에게 무엇이든 물어보세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}