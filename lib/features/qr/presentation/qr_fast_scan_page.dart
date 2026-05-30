import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'bloc/qr_fast_scan_bloc.dart';
import 'bloc/qr_fast_scan_event.dart';
import 'bloc/qr_fast_scan_state.dart';

class QrFastScanPage extends StatelessWidget {
  const QrFastScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrFastScanBloc(),
      child: const _QrFastScanView(),
    );
  }
}

class _QrFastScanView extends StatefulWidget {
  const _QrFastScanView();

  @override
  State<_QrFastScanView> createState() => _QrFastScanViewState();
}

class _QrFastScanViewState extends State<_QrFastScanView>
    with WidgetsBindingObserver, RouteAware {
  late final MobileScannerController controller;
  bool _isStartingCamera = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed
          .unrestricted, // Allow continuous scanning without delay
      detectionTimeoutMs: 250, // Short timeout to allow quick successive scans
      formats: const [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
      torchEnabled: false, // Start with torch off, user can toggle if needed
      returnImage: false,
      autoStart: true, // Start camera immediately
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _resumeCameraSafely();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _stopCameraSafely();
        break;
    }
  }

  Future<void> _resumeCameraSafely() async {
    if (_isStartingCamera) return;
    _isStartingCamera = true;

    try {
      // Small delay to ensure camera resources are released before restarting
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      await controller.stop();

      // Small delay to ensure camera resources are released before restarting
      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      await controller.start();
    } catch (e) {
      debugPrint('Resume camera failed: $e');
    } finally {
      _isStartingCamera = false;
    }
  }

  Future<void> _stopCameraSafely() async {
    try {
      await controller.stop();
    } catch (e) {
      debugPrint('Stop camera failed: $e');
    }
  }

  void onDetect(BarcodeCapture capture) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;

    final code = barcode?.rawValue;

    if (code == null || code.trim().isEmpty) return;

    context.read<QrFastScanBloc>().add(QrCodeDetected(code));
  }

  void showResultSheet(QrFastScanState state) {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) {
        final isSuccess = state.status == QrFastScanStatus.success;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: 64,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message ?? 'Unknown result',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (state.code != null)
                  Text(state.code!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                if (state.voucherValue != null)
                  Text(
                    'Value: ${formatVnd(state.voucherValue!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();

                      if (!mounted) return;

                      context.read<QrFastScanBloc>().add(
                        const QrFastScanReset(),
                      );
                    },
                    child: const Text('Scan Again'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).pop(state.code);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatVnd(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;

      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${buffer.toString()}đ';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrFastScanBloc, QrFastScanState>(
      listenWhen: (previous, current) {
        return previous.status != current.status &&
            (current.status == QrFastScanStatus.success ||
                current.status == QrFastScanStatus.failure);
      },
      listener: (context, state) {
        showResultSheet(state);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Fast Scan Voucher'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            final scanSize = screenSize.width * 0.75;

            final scanWindow = Rect.fromCenter(
              center: screenSize.center(Offset.zero),
              width: scanSize,
              height: scanSize,
            );

            return Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  scanWindow: scanWindow,
                  onDetect: onDetect,
                ),

                Center(
                  child: Container(
                    width: scanSize,
                    height: scanSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),

                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 48,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(165),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Place the QR code inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                BlocBuilder<QrFastScanBloc, QrFastScanState>(
                  buildWhen: (previous, current) {
                    return previous.status != current.status;
                  },
                  builder: (context, state) {
                    if (state.status != QrFastScanStatus.processing) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      left: 24,
                      right: 24,
                      top: 24,
                      child: SafeArea(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(230),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Validating voucher...',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
