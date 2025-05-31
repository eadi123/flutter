import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(QRScannerApp());
}

class QRScannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRScannerScreen(),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String apiUrl =
      "http://192.168.100.5/wp-json/school-management/v1/attendance";
  bool isProcessing = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        isProcessing = true;
        _sendToApi(scanData.code);
      }
    });
  }

  Future<void> _sendToApi(String? scannedId) async {
    if (scannedId == null || apiUrl.isEmpty) {
      isProcessing = false;
      return;
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'app-key': '9f8c8f6f8f760d3d5f5b6b2c5c3401b0', // Your app key here
        'app-password':
            '492d249824a5438c4e3d1209efae5fe9', // Your app password here
      },
      body: jsonEncode({'id': scannedId}),
    );

    if (response.statusCode == 200) {
      _showMessage("Scan Completed");
    } else {
      _showMessage("Error: ${response.statusCode}");
    }

    Future.delayed(Duration(seconds: 1), () {
      isProcessing = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("QR Scanner")),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
