import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/repositories/patient_repository.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _repo = PatientRepository();
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage("Hi! I'm CareCell AI. I can explain medical terms, suggest hospitals, or guide you on government schemes. How can I help today?", false),
  ];
  bool _sending = false;

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() { _messages.add(_ChatMessage(text, true)); _sending = true; _ctrl.clear(); });
    _scrollToBottom();

    final r = await _repo.aiChat(text);
    setState(() {
      _sending = false;
      _messages.add(_ChatMessage(r.isSuccess ? (r.data?['reply'] ?? 'I could not process that. Please try again.') : 'CareCell AI is temporarily unavailable.', false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20)),
          SizedBox(width: 10),
          Text('CareCell AI'),
        ]),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: AppColors.info.withOpacity(0.08),
          child: const Text('CareCell AI provides informational support only and does not replace professional medical advice.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.info)),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            itemCount: _messages.length + (_sending ? 1 : 0),
            itemBuilder: (c, i) {
              if (i == _messages.length) {
                return _bubble('Typing...', false, isLoading: true);
              }
              final m = _messages[i];
              return _bubble(m.text, m.isUser);
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: InputDecoration(
                    hintText: 'Ask about symptoms, schemes, hospitals...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true, fillColor: AppColors.background,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _sending ? null : _send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _bubble(String text, bool isUser, {bool isLoading = false}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: isUser ? null : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
        ),
        child: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(text, style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 14)),
      ),
    );
  }
}
