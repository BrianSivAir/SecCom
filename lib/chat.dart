import 'package:flutter/material.dart';

import 'model/com.dart';


class Chat extends StatefulWidget {
  final Com com;
  const Chat({super.key, required this.com});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.com.name),
      ),
    );
  }
}
