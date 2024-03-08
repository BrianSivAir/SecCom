import 'dart:io';

import 'package:async/async.dart';
import 'package:sec_com/model/com.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

class Sockets {
  Socket? socket;
  Function? onDestroy;
  String sig = '';

  static final Sockets _instance = Sockets._internal();

  factory Sockets() {
    return _instance;
  }

  Sockets._internal();

  Future<void> connect(Com com, Function(String) onStatusChange, Function onSuccess, Function onDestroy) async {
    sig = com.name;
    this.onDestroy = onDestroy;
    try {
      onStatusChange.call('Trying to connect...');
      socket = await Socket.connect(com.lip, com.lport,
          timeout: const Duration(seconds: 5));

      socket!.writeln('Hello, server!');
      onSuccess.call();

      // Listen for data from the server
      socket!.listen(
        (data) {
          print('Received from server: ${String.fromCharCodes(data)}');
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
      ServerSocket.bind(InternetAddress.anyIPv4, com.port).then((ServerSocket server) {
        print('SERVER: Binding done.');
        server.listen((socket) {
          print('SERVER: Listening..');
          onSuccess.call();
          socket.listen(
            (data) {
              print(
                  'SERVER: Received from client: ${String.fromCharCodes(data)}');
            },
            onDone: () {
              print('SERVER: Client disconnected.');
              socket.destroy();
            },
            onError: (error) {
              print('SERVER: OnError: Error: $error');
              socket.destroy();
            },
          );
          ;
        });
      });
    }
  }

  handleMessage(Socket socket) {}

  void destroy() {
    socket?.destroy();
    onDestroy?.call();
  }

}
