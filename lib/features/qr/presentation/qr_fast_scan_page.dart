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
    with WidgetsBindingObserver {
  late final MobileScannerController controller;

  bool _isStartingCamera = false;
  bool _isSheetShowing = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.unrestricted,
      detectionTimeoutMs: 250,
      formats: const [BarcodeFormat.qrCode],
      facing: CameraFacing.back,
      torchEnabled: false,
      returnImage: false,
      autoStart: true,
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
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;

      await controller.stop();

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
    if (_isSheetShowing) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final code = barcode?.rawValue;

    if (code == null || code.trim().isEmpty) return;

    context.read<QrFastScanBloc>().add(QrCodeDetected(code));
  }

  void showResultSheet(QrFastScanState state) {
    if (_isSheetShowing) return;
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    _isSheetShowing = true;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isSuccess = state.status == QrFastScanStatus.success;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: _ResultSheetCard(
              isSuccess: isSuccess,
              code: state.code,
              message: state.message ?? 'Unknown result',
              voucherValue: state.voucherValue,
              onScanAgain: () {
                Navigator.of(sheetContext).pop();

                if (!mounted) return;

                context.read<QrFastScanBloc>().add(
                      const QrFastScanReset(),
                    );
              },
              onDone: () {
                final code = state.code;

                Navigator.of(sheetContext).pop();

                if (!mounted) return;
                if (ModalRoute.of(context)?.isCurrent != true) return;

                Navigator.of(context).pop(code);
              },
              formatVnd: formatVnd,
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isSheetShowing = false;
    });
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
          title: const Text(
            'Fast Scan Voucher',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                controller.toggleTorch();
              },
              icon: const Icon(Icons.flash_on_rounded),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            final scanSize = screenSize.width * 0.74;

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

                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ScannerOverlayPainter(
                        scanWindow: scanWindow,
                      ),
                    ),
                  ),
                ),

                Center(
                  child: _ScanFrame(size: scanSize),
                ),

                const Positioned(
                  left: 18,
                  right: 18,
                  top: 16,
                  child: SafeArea(
                    child: _ScannerTipCard(),
                  ),
                ),

                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 34,
                  child: _InstructionCard(
                    onReset: () {
                      context.read<QrFastScanBloc>().add(
                            const QrFastScanReset(),
                          );
                    },
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

                    return const Positioned(
                      left: 18,
                      right: 18,
                      top: 96,
                      child: SafeArea(
                        child: _ProcessingBanner(),
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

class _ScanFrame extends StatelessWidget {
  final double size;

  const _ScanFrame({
    required this.size,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 3,
        ),
      ),
      child: Stack(
        children: const [
          _CornerMark(
            alignment: Alignment.topLeft,
            top: 14,
            left: 14,
          ),
          _CornerMark(
            alignment: Alignment.topRight,
            top: 14,
            right: 14,
          ),
          _CornerMark(
            alignment: Alignment.bottomLeft,
            bottom: 14,
            left: 14,
          ),
          _CornerMark(
            alignment: Alignment.bottomRight,
            bottom: 14,
            right: 14,
          ),
          Center(
            child: Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white70,
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  final Alignment alignment;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const _CornerMark({
    required this.alignment,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(
                    color: Color(0xFF52C41A),
                    width: 5,
                  )
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(
                    color: Color(0xFF52C41A),
                    width: 5,
                  )
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(
                    color: Color(0xFF52C41A),
                    width: 5,
                  )
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(
                    color: Color(0xFF52C41A),
                    width: 5,
                  )
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ScannerTipCard extends StatelessWidget {
  const _ScannerTipCard();

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(
            Icons.bolt_rounded,
            color: Colors.orange,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Fast scan mode is enabled. Keep the QR code inside the frame.',
              style: TextStyle(
                color: Color(0xFF303030),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  final VoidCallback onReset;

  const _InstructionCard({
    required this.onReset,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.center_focus_strong_rounded,
              color: Color(0xFF1677FF),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Place the meal voucher QR code inside the frame.',
              style: TextStyle(
                color: Color(0xFF303030),
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProcessingBanner extends StatelessWidget {
  const _ProcessingBanner();

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
          width: 2.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Validating voucher...',
              style: TextStyle(
                color: Color(0xFF303030),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSheetCard extends StatelessWidget {
  final bool isSuccess;
  final String? code;
  final String message;
  final int? voucherValue;
  final VoidCallback onScanAgain;
  final VoidCallback onDone;
  final String Function(int value) formatVnd;

  const _ResultSheetCard({
    required this.isSuccess,
    required this.code,
    required this.message,
    required this.voucherValue,
    required this.onScanAgain,
    required this.onDone,
    required this.formatVnd,
  });

  static const borderColor = Color(0xFF2F2F2F);
  static const primaryGreen = Color(0xFF52C41A);
  static const dangerRed = Color(0xFFFF5A5F);

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? primaryGreen : dangerRed;
    final background = isSuccess
        ? const Color(0xFFEFFFF0)
        : const Color(0xFFFFEFF4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 2.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: borderColor,
            offset: Offset(5, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 2.6,
              ),
              boxShadow: const [
                BoxShadow(
                  color: borderColor,
                  offset: Offset(3, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_rounded,
              size: 42,
              color: color,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF303030),
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (code != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width: 2,
                ),
              ),
              child: Text(
                code!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF303030),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],

          if (voucherValue != null) ...[
            const SizedBox(height: 14),
            Text(
              'Value: ${formatVnd(voucherValue!)}',
              style: const TextStyle(
                color: Color(0xFF303030),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],

          const SizedBox(height: 22),

          _SheetButton(
            label: 'Scan Again',
            icon: Icons.qr_code_scanner_rounded,
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            onPressed: onScanAgain,
          ),

          const SizedBox(height: 12),

          _SheetButton(
            label: 'Done',
            icon: Icons.check_rounded,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF303030),
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  static const borderColor = Color(0xFF2F2F2F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: borderColor,
              width: 2.4,
            ),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;

  const _ScannerOverlayPainter({
    required this.scanWindow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withAlpha(120)
      ..style = PaintingStyle.fill;

    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          const Radius.circular(28),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}