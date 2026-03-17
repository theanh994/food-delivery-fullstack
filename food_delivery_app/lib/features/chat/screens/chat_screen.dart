import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final int orderId;
  final String receiverName;
  final int receiverId;

  const ChatScreen({super.key, required this.orderId, required this.receiverName, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgC = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Bắt đầu chế độ Real-time (3s load 1 lần)
    Future.microtask(() => context.read<ChatProvider>().startPolling(widget.orderId));
  }

  @override
  void dispose() {
    context.read<ChatProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final myId = context.read<AuthProvider>().currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Tin mới hiện ở dưới cùng
              padding: const EdgeInsets.all(15),
              itemCount: chatProv.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProv.messages[chatProv.messages.length - 1 - index];
                bool isMe = msg['sender_id'].toString() == myId.toString();

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? AppTheme.darkPurple : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(msg['message'], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                  ),
                );
              },
            ),
          ),
          // Ô nhập tin nhắn
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgC, decoration: const InputDecoration(hintText: "Nhập tin nhắn..."))),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.bronzeGold),
                  onPressed: () {
                    if (_msgC.text.isNotEmpty) {
                      context.read<ChatProvider>().sendMessage(widget.orderId, myId, _msgC.text);
                      _msgC.clear();
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}