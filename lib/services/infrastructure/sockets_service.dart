import 'dart:convert';
import 'dart:io';
import 'package:sec_com/model/com.dart';
import 'package:sec_com/model/message.dart';

class SocketsService {
  Socket? socket;
  ServerSocket? s_socket;
  Function(Message message)? onMessageReceived;
  Function? onDestroy;
  String sig = '';

  static final SocketsService _instance = SocketsService._internal();

  factory SocketsService() {
    return _instance;
  }

  SocketsService._internal();

  Future<void> connect(Com com, Function(String) onStatusChange,
      Function onSuccess, Function onDestroy) async {
    sig = com.name;
    this.onDestroy = onDestroy;
    try {
      onStatusChange.call('Trying to connect...');
      socket = await Socket.connect(com.lip, com.lport,
          timeout: const Duration(seconds: 5));

      // socket!.writeln('Hello, server!');
      onSuccess.call();

      // Listen for data from the server
      socket!.listen(
        (data) {
          var str = String.fromCharCodes(data);
          print('Received from server: $str');
          onMessageReceived?.call(Message.fromJson(jsonDecode(str)));
        },
        onDone: () {
          print('Server disconnected.');
          socket!.destroy();
        },
        onError: (error) {
          print('OnError: Error: $error');
          socket!.destroy();
        },
      );
    } catch (e) {
      print('Destination host unavailable.');
      onStatusChange.call('Listening on port ${com.port}');
      s_socket = await ServerSocket.bind(InternetAddress.anyIPv4, com.port);
      print('SERVER: Binding done.');
      s_socket!.listen((socket) {
        this.socket = socket;
        print('SERVER: Listening..');
        onSuccess.call();
        socket.listen(
          (data) {
            var str = String.fromCharCodes(data);
            print(
                'SERVER: Received from client: $str');
            onMessageReceived?.call(Message.fromJson(jsonDecode(str)));
          },
          onDone: () {
            print('SERVER: Client disconnected.');
            socket.destroy();
            onDestroy.call();
          },
          onError: (error) {
            print('SERVER: OnError: Error: $error');
            socket.destroy();
          },
        );
      },
      );
    }
  }

  handleMessage(Socket socket) {}

  void destroy() {
    socket?.destroy();
    s_socket?.close();
    onDestroy?.call();
  }
}
