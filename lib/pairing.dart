import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sec_com/database/com_db.dart';
import 'package:sec_com/qr_reader.dart';
import 'package:sec_com/services/application/pairing_service.dart';

import 'model/com.dart';

class Pairing extends StatelessWidget {
  final void Function() onDone;

  const Pairing({super.key, required Function() this.onDone});

  Future<void> pairing(Com com, BuildContext context) async {
    print("[PairingClient] Adding scanned Com to DB");
    await ComDB().create(com: com);
    print("[PairingClient] Com added to DB. Preparing to connect to PairingServer");
    PairingService.pairing(com,
        () => {print("[PairingClient] Pairing Done!"), Navigator.of(context).pop(), onDone.call()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ComQRDisplay(onDone: onDone),
                    ))
                  },
              child: const Text('Generate QR')),
          ElevatedButton(
              onPressed: () => {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => QRReader(onData: (Com com) {
                        print("---------------------------------------------------------------");
                        print(com.toJson());
                        pairing(com, context);
                      }),
                    ))
                  },
              child: const Text('Scan QR'))
        ],
      ),
    );
  }
}

class ComQRDisplay extends StatefulWidget {
  final void Function() onDone;

  const ComQRDisplay({super.key, required Function() this.onDone});

  @override
  State<ComQRDisplay> createState() => _ComQRDisplayState();
}

class _ComQRDisplayState extends State<ComQRDisplay> {
  late Future<Com> com;
  late final PairingService pairingService;

  void initPairing(BuildContext context) {
    var myCom = PairingService.getMyCom();
    myCom.then((value) => {
          pairingService.hostPairing(
              value,
              () => {
                    print("[PairingServer] Pairing Done!"),
                    Navigator.of(context).pop(),
                    Navigator.of(context).pop(),
                    widget.onDone.call(),
                  })
        });
    setState(() {
      com = myCom;
    });
  }

  @override
  void initState() {
    super.initState();
    pairingService = PairingService();
  }

  @override
  void dispose() {
    super.dispose();
    pairingService.serverSocket?.close();
  }

  @override
  Widget build(BuildContext context) {
    initPairing(context);
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<Com>(
          future: com,
          builder: (context, snapshot) {
            print("[Pairing] Sharing com: ${jsonEncode(snapshot.data)}");
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                      flex: 4, child: Center(child: QrImageView(data: jsonEncode(snapshot.data)))),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Text(
                          snapshot.data?.name ?? 'This Device',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(snapshot.data?.lip ?? 'localhost')
                      ],
                    ),
                  ),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ));
  }
}
