import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController cameraController = MobileScannerController();

  bool isProcessing = false;
  String? scannedCode;
  String? voucherMessage;
  int? voucherValue;

  Future<void> onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      isProcessing = true;
      scannedCode = rawValue;
    });

    await cameraController.stop();
    await validateVoucher(rawValue);
  }

  Future<void> validateVoucher(String code) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    if (code == 'MEAL_100K_ABC') {
      setState(() {
        voucherMessage = 'Meal Voucher Valid';
        voucherValue = 100000;
      });
    } else if (code.startsWith('MEAL_')) {
      setState(() {
        voucherMessage = 'Meal Voucher Recognized';
        voucherValue = 50000;
      });
    } else {
      setState(() {
        voucherMessage = 'Invalid Voucher';
        voucherValue = null;
      });
    }
    showResultBottomSheet();
  }

  Future<void> resetScanner() async {
    Navigator.of(context).pop();

    setState(() {
      isProcessing = false;
      scannedCode = null;
      voucherMessage = null;
      voucherValue = null;
    });

    await cameraController.start();
  }

  String formatVnd(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      if ((text.length - i) > 1 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
    }
    return '${buffer.toString()}đ';
  }

  void showResultBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) {
        final isValid = voucherValue != null;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                size: 64,
                color: isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                voucherMessage ?? 'Unknown result',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (scannedCode != null)
                Text(scannedCode!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (voucherValue != null)
                Text(
                  'Voucher Value: $voucherValue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: resetScanner,
                  child: Text('Scan Again'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: onDetect),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 24,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Place the meal voucher QR inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
