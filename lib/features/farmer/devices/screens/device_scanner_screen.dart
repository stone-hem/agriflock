import 'dart:async';

import 'package:agriflock/core/utils/refresh_bus.dart';
import 'package:agriflock/features/farmer/devices/repository/devices_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  State<DeviceScannerScreen> createState() => _DeviceScannerScreenState();
}

class _DeviceScannerScreenState extends State<DeviceScannerScreen> {
  final DevicesRepository _repository = DevicesRepository();
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  bool _scanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _isProcessing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _scanned = true;
    });

    await _scannerController.stop();

    final result = await _repository.scanDevice(code);

    if (!mounted) return;

    result.when(
      success: (_) {
        RefreshBus.instance.fire(RefreshEvent.deviceScanned);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device scanned and submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
      failure: (message, ignored, statusCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty ? message : 'Failed to submit scanned device'),
            backgroundColor: Colors.red,
          ),
        );
        // Allow re-scan after failure
        setState(() {
          _isProcessing = false;
          _scanned = false;
        });
        _scannerController.start();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Scan Device', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _scannerController.toggleTorch(),
            tooltip: 'Toggle torch',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Overlay with scan window
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Bottom hint
          Positioned(
            left: 0,
            right: 0,
            bottom: 60,
            child: Column(
              children: [
                if (_isProcessing)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  const Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white70, size: 36),
                const SizedBox(height: 12),
                Text(
                  _isProcessing
                      ? 'Submitting device...'
                      : 'Point the camera at the device QR code or barcode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const windowSize = 240.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rect = Rect.fromCenter(
        center: Offset(cx, cy), width: windowSize, height: windowSize);

    final dimPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dim everything outside the scan window
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12))),
      ),
      dimPaint,
    );

    // Corner brackets
    const bracketLen = 28.0;
    const bracketThick = 3.0;
    final bracketPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = bracketThick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // top-left
      [Offset(rect.left, rect.top + bracketLen), rect.topLeft,
        Offset(rect.left + bracketLen, rect.top)],
      // top-right
      [Offset(rect.right - bracketLen, rect.top), rect.topRight,
        Offset(rect.right, rect.top + bracketLen)],
      // bottom-left
      [Offset(rect.left, rect.bottom - bracketLen), rect.bottomLeft,
        Offset(rect.left + bracketLen, rect.bottom)],
      // bottom-right
      [Offset(rect.right - bracketLen, rect.bottom), rect.bottomRight,
        Offset(rect.right, rect.bottom - bracketLen)],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, bracketPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
