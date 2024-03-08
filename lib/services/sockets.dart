import 'dart:io';

import 'package:async/async.dart';
import 'package:sec_com/model/com.dart';
import 'package:tcp_socket_connection/tcp_socket_connection.dart';

class Sockets {
  Com? com;
  Socket? socket;

  Sockets(this.com);

  Future<void> connect(Function(String) onStatusChange) async {
    try {
      socket = await Socket.connect('localhost', 8372,
          timeout: const Duration(seconds: 5));

      socket!.writeln('Hello, server!');

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
      ServerSocket.bind('localhost', 8372).then((ServerSocket server) {
        print('SERVER: Binding done.');
        server.listen((socket) {
          print('SERVER: Listening..');
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

  void close() {
    socket?.close();
  }

}
