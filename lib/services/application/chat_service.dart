import 'dart:convert';

import 'package:sec_com/model/message.dart';
import 'package:sec_com/services/infrastructure/sockets_service.dart';

class ChatService {
  void sendMessage(Message message) {
    var serialized = jsonEncode(message);
    SocketsService().socket!.write(serialized);
  }
}