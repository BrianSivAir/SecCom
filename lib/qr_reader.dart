import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sec_com/model/com.dart';

class QRReader extends StatefulWidget {
  final void Function(Com com) onData;

  const QRReader({super.key, required Function(Com com) this.onData});

  @override
  State<QRReader> createState() => _QRReaderState();
}

class _QRReaderState extends State<QRReader> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? result;
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR"),
      ),
      body: Expanded(
          child: QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(),
          ),
        ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      widget.onData.call(Com.fromJson(jsonDecode(scanData.code!)));
      controller.dispose();
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
