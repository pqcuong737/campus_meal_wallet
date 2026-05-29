import 'package:equatable/equatable.dart';

abstract class QrFastScanEvent extends Equatable {
  const QrFastScanEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeDetected extends QrFastScanEvent {
  final String code;

  const QrCodeDetected(this.code);

  @override
  List<Object?> get props => [code];
}

class QrFastScanReset extends QrFastScanEvent {
  const QrFastScanReset();
}