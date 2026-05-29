import 'package:equatable/equatable.dart';

enum QrFastScanStatus {
  idle,
  processing,
  success,
  failure,
}

class QrFastScanState extends Equatable {
  final QrFastScanStatus status;
  final String? code;
  final String? message;
  final int? voucherValue;

  const QrFastScanState({
    required this.status,
    this.code,
    this.message,
    this.voucherValue,
  });

  const QrFastScanState.initial()
      : status = QrFastScanStatus.idle,
        code = null,
        message = null,
        voucherValue = null;

  QrFastScanState copyWith({
    QrFastScanStatus? status,
    String? code,
    String? message,
    int? voucherValue,
  }) {
    return QrFastScanState(
      status: status ?? this.status,
      code: code ?? this.code,
      message: message ?? this.message,
      voucherValue: voucherValue ?? this.voucherValue,
    );
  }

  @override
  List<Object?> get props => [
        status,
        code,
        message,
        voucherValue,
      ];
}