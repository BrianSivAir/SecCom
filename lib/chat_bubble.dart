import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final Function onTap;
  final bool expired;
  final bool toRead;
  final bool isMine;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onTap,
    this.expired = false,
    this.toRead = true,
    this.isMine = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  late String displayText;

  @override
  void initState() {
    super.initState();
    _updateDisplayText();
  }

  @override
  void didUpdateWidget(covariant ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDisplayText();
  }

  void _updateDisplayText() {
    if (widget.expired) {
      displayText = 'opened';
    } else if (widget.isMine) {
      displayText = 'sended';
    } else if (widget.toRead) {
      displayText = 'Click to open';
    } else {
      displayText = widget.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!(widget.expired || widget.isMine)) {
          widget.onTap.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: widget.expired || widget.isMine ? Colors.blue[100] : Colors.blue[200],
        ),
        child: Text(
          displayText,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
