import 'dart:async';

import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

class ToptCard extends StatefulWidget {
  const ToptCard({super.key});

  @override
  State<ToptCard> createState() => _ToptCardState();
}

class _ToptCardState extends State<ToptCard> {
  // maybe should be generated per user and stored securely, but for demo purpose it's hardcoded :3
  static const String secret = 'HELLO3SECRET3KEY';

  Timer? _timer;
  String otpCode = '';
  int secondsLeft = 30;

  @override
  void initState() {
    super.initState();
    _generateOtp();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _generateOtp();
    });
  }

  void _generateOtp() {
    final now = DateTime.now().millisecondsSinceEpoch;

    final currentOtp = OTP.generateTOTPCodeString(
      secret,
      now,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final currentSeconds = DateTime.now().second;
    final remaining = 30 - (currentSeconds % 30);

    if (!mounted) return; // prevent setState if widget is disposed :))

    setState(() {
      otpCode = currentOtp;
      secondsLeft = remaining;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get progress => secondsLeft / 30;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Transaction OTP',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            Text(
              otpCode,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),

            const SizedBox(height: 8),

            Text(
              'Expires in ${secondsLeft}s',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
