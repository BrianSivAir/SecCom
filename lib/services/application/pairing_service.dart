import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:random_name_generator/random_name_generator.dart';
import 'package:sec_com/database/com_db.dart';

import '../../model/com.dart';
import '../infrastructure/cypher_service.dart';

class PairingService {
  ServerSocket? serverSocket;

  static Future<void> ensurePermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (!(await Permission.locationWhenInUse.request().isGranted)) {
        throw Exception("Network permission denied");
      }
    }
  }

  static int generatePort(Random random) {
    int min = 49152;
    int max = 65535;
    return min + random.nextInt(max - min + 1);
  }

  static Future<Com> getMyCom() async {
    await ensurePermissions();
    Random random = Random();
    return Com(
        id: -1,
        name: RandomNames(Zone.us).name(),
        lip: await NetworkInfo().getWifiIP() ?? InternetAddress.anyIPv4.address,
        lport: generatePort(random),
        port: generatePort(random),
        key: CypherService().generateKey());
  }

  static Future<void> pairing(Com destination, Function onDone) async {
    print("[Pairing] Connecting to Server");
    try {
      var socket = await Socket.connect(destination.lip, destination.lport,
          timeout: const Duration(seconds: 5));

      print("[Pairing] Connected to Server");
      var myCom = await getMyCom();
      myCom = Com(
          id: destination.id,
          name: myCom.name,
          lip: myCom.lip,
          lport: destination.port,
          port: destination.lport,
          key: destination.key
      );
      print("[Pairing] Sending myCom to server: ${jsonEncode(myCom)}");
      socket.writeln(jsonEncode(myCom));
      onDone.call();

      // Listen for data from the server
      socket.listen(
            (data) {
          var str = String.fromCharCodes(data);
          print('[Pairing] Received from server: $str');
        },
        onDone: () {
          print('[Pairing] Server disconnected.');
          socket.destroy();
        },
        onError: (error) {
          print('[Pairing] OnError: Error: $error');
          socket.destroy();
        },
      );
    } catch (e) {
      print("[Pairing] Exception during pair client: $e");
    }
  }

  Future<void> hostPairing(Com myCom, Function onDone) async {
    var s_socket = await ServerSocket.bind(InternetAddress.anyIPv4, myCom.lport);
    print('[Pairing] SERVER: Binding done.');
    this.serverSocket = s_socket;
    s_socket.listen((socket) {
      print('[Pairing] SERVER: Listening..');
      socket.listen(
            (data) {
          var str = String.fromCharCodes(data);
          print(
              '[Pairing] SERVER: Received from client: $str');
          // onMessageReceived?.call(Message.fromJson(jsonDecode(str)));
          ComDB().create(com: Com.fromJson(jsonDecode(str))).then((value) => onDone.call());
          socket.destroy();
        },
        onDone: () {
          print('[Pairing] SERVER: Client disconnected.');
          socket.destroy();
        },
        onError: (error) {
          print('[Pairing] SERVER: OnError: Error: $error');
          socket.destroy();
        },
      );
    });
  }
}
