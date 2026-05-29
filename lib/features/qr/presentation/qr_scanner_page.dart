import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    detectionTimeoutMs: 250,
    formats: const [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
    torchEnabled: false,
    returnImage: false,
    autoStart: true,
  );

  bool isProcessing = false;
  String? scannedCode;
  String? voucherMessage;
  int? voucherValue;
  DateTime? lastScanTime;
  String? lastCode;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // prevent camera issues when app goes to background or comes back to foreground :3
    if (state == AppLifecycleState.resumed && !isProcessing) {
      cameraController.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      cameraController.stop();
    }
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    final code = capture.barcodes.first.rawValue;

    if (code == null) return;

    final now = DateTime.now();

    // prevent duplicate scan
    if (lastCode == code &&
        lastScanTime != null &&
        now.difference(lastScanTime!) < const Duration(seconds: 2)) {
      return;
    }

    lastCode = code;
    lastScanTime = now;

    validateVoucher(code);
  }

  Future<void> validateVoucher(String code) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // prevent showing result if not on this page :))
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

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

  Future<void> resetScanner(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();

    if (!mounted) return; // prevent using context if widget is disposed :3

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
    // prevent showing bottom sheet if not on this page :))
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
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
                  'Voucher Value: ${formatVnd(voucherValue!)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  // prevent using parent context to pop, which might cause issues if not on this page :))
                  onPressed: () => resetScanner(sheetContext),
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
    WidgetsBinding.instance.removeObserver(this);
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
