import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sec_com/chat_bubble.dart';
import 'package:sec_com/services/application/chat_service.dart';
import 'package:sec_com/services/infrastructure/cypher_service.dart';
import 'package:sec_com/services/infrastructure/sockets_service.dart';

import 'model/com.dart';
import 'model/message.dart';

class Chat extends StatefulWidget {
  final Com com;

  const Chat({super.key, required this.com});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messageQueue = [];
  Socket socket = SocketsService().socket!;
  ChatService chatService = ChatService();

  @override
  void initState() {
    super.initState();
    SocketsService().onMessageReceived = (msg) => {
          print('Recived new message. Adding to queue.'),
          print(msg.content),
          msg.isMine = false,
          setState(() {
            messageQueue.add(msg);
          }),
        };
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      var cypherText =
          CypherService().encrypt(widget.com.key, _messageController.text);
      var message = Message(content: cypherText, duration: 10, isMine: true);
      chatService.sendMessage(message);
      setState(() {
        message.content = '';
        messageQueue = [...messageQueue, message];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.com.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: messageQueue.length,
                itemBuilder: (context, index) {
                  return ExpiryMessage(
                    message: messageQueue[index],
                    com: widget.com,
                  );
                }),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: 'Enter message'),
                ),
              ),
              IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.arrow_upward,
                    size: 40,
                  ))
            ],
          )
        ],
      ),
    );
  }
}

class ExpiryMessage extends StatefulWidget {
  final Message message;
  final Com com;

  const ExpiryMessage({
    super.key,
    required this.message,
    required this.com,
  });

  @override
  State<ExpiryMessage> createState() => _ExpiryMessageState();
}

class _ExpiryMessageState extends State<ExpiryMessage> {
  Message? message;
  Com? com;
  var toRead = true;
  var expired = false;
  int secLeft = 0;
  bool isMine = false;

  @override
  void initState() {
    super.initState();
    message = widget.message;
    com = widget.com;
    secLeft = message!.duration;
    isMine = message!.isMine;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: message!.content,
              expired: expired,
              toRead: toRead,
              isMine: isMine,
              onTap: () => {
                print('parent: ONTAP'),
                secLeft = message!.duration,
                Timer.periodic(
                    const Duration(seconds: 1),
                        (timer) {
                          if (secLeft < 1) {
                            setState(() {
                              message!.content = '';
                              expired = true;
                            });
                          } else {
                            setState(() {
                              secLeft--;
                            });
                          }
                        }),
                // Future.delayed(Duration(seconds: message!.duration))
                //     .then((value) => {
                //
                //         }),
                setState(() {
                  message!.content =
                      CypherService().decrypt(com!.key, message!.content);
                  toRead = false;
                }),
              },
            ),
            Text(expired ? '' : '${secLeft.toString()}s')
          ],
        ),
      ),
    );
  }
}
