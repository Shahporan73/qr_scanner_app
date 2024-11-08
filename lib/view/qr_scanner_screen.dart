import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'result_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcodeCapture) {
              final String? code = barcodeCapture.barcodes.first.rawValue;

              if (code != null && code != _lastScannedCode) {
                // Update the last scanned code to avoid duplicate scans
                _lastScannedCode = code;
                _handleScannedCode(code);
              }
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: 0, left: 0, child: buildCorner()),
                      Positioned(top: 0, right: 0, child: buildCorner(isTopRight: true)),
                      Positioned(bottom: 0, left: 0, child: buildCorner(isBottomLeft: true)),
                      Positioned(bottom: 0, right: 0, child: buildCorner(isBottomRight: true)),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: Opacity(
                            opacity: 0.5,
                            child: Container(
                              height: 4,
                              color: Colors.green.withOpacity(
                                  (1 - _animationController.value).abs()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleScannedCode(String code) {
    String? password;
    bool isLink = Uri.tryParse(code)?.hasAbsolutePath ?? false;

    // Check if the scanned code is in the Wi-Fi format
    if (code.startsWith('WIFI:')) {
      // Extract the password part
      final RegExp passwordPattern = RegExp(r'P:([^;]+);');
      final match = passwordPattern.firstMatch(code);
      if (match != null) {
        password = match.group(1);
      }
    }

    // If the code doesn't match the Wi-Fi format or has no password, display the full code
    final displayText = password ?? code;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResultScreen(code: displayText, isLink: isLink),
    )).then((_) {
      // Reset to allow scanning of new codes
      setState(() {
        _lastScannedCode = null;
      });
    });
  }

  Widget buildCorner({
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: isBottomLeft || isBottomRight
              ? BorderSide.none
              : BorderSide(color: Colors.green, width: 4),
          left: isTopRight || isBottomRight
              ? BorderSide.none
              : BorderSide(color: Colors.green, width: 4),
          right: isTopRight || isBottomRight
              ? BorderSide(color: Colors.green, width: 4)
              : BorderSide.none,
          bottom: isBottomLeft || isBottomRight
              ? BorderSide(color: Colors.green, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
