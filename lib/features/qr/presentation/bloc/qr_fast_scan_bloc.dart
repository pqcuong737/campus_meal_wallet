import 'package:flutter_bloc/flutter_bloc.dart';

import 'qr_fast_scan_event.dart';
import 'qr_fast_scan_state.dart';

class QrFastScanBloc extends Bloc<QrFastScanEvent, QrFastScanState> {
  String? _lastCode;
  DateTime? _lastScanAt;

  static const duplicateWindow = Duration(seconds: 2);

  QrFastScanBloc() : super(const QrFastScanState.initial()) {
    on<QrCodeDetected>(_onQrCodeDetected);
    on<QrFastScanReset>(_onReset);
  }

  Future<void> _onQrCodeDetected(
    QrCodeDetected event,
    Emitter<QrFastScanState> emit,
  ) async {
    final code = event.code.trim();

    if (code.isEmpty) return;
    if (state.status == QrFastScanStatus.processing) return;
    if (_isDuplicate(code)) return; // Prevent processing the same code multiple times in quick succession

    _lastCode = code;
    _lastScanAt = DateTime.now();

    emit(
      state.copyWith(
        status: QrFastScanStatus.processing,
        code: code,
        message: null,
        voucherValue: null,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (isClosed) return;

    if (code == 'MEAL_100K_ABC') {
      emit(
        state.copyWith(
          status: QrFastScanStatus.success,
          code: code,
          message: 'Meal Voucher Valid',
          voucherValue: 100000,
        ),
      );
      return;
    }

    if (code.startsWith('MEAL_')) {
      emit(
        state.copyWith(
          status: QrFastScanStatus.success,
          code: code,
          message: 'Meal Voucher Recognized',
          voucherValue: 50000,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: QrFastScanStatus.failure,
        code: code,
        message: 'Invalid Voucher',
        voucherValue: null,
      ),
    );
  }

  void _onReset(
    QrFastScanReset event,
    Emitter<QrFastScanState> emit,
  ) {
    emit(const QrFastScanState.initial());
  }

  bool _isDuplicate(String code) {
    final lastScanAt = _lastScanAt;

    if (_lastCode != code || lastScanAt == null) {
      return false;
    }

    // If the same code was scanned within the duplicate window, consider it a duplicate
    return DateTime.now().difference(lastScanAt) < duplicateWindow;
  }
}