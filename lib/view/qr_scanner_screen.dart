// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as mobile_scanner;
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
  final ImagePicker _picker = ImagePicker();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final mobile_scanner.MobileScannerController _cameraController =
  mobile_scanner.MobileScannerController();
  bool _isBackCamera = true;
  double _scaleFactor = 1.0; // Simulated zoom level

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
    _barcodeScanner.close();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndScan() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final File imageFile = File(pickedImage.path);
      try {
        final inputImage = InputImage.fromFile(imageFile);
        final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty) {
          final String code = barcodes.first.rawValue ?? '';
          _handleScannedCode(code);
        } else {
          _showError("No QR code found in the image.");
        }
      } catch (e) {
        _showError("Failed to scan QR code from image.");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleScannedCode(String code) {
    String? password;
    bool isLink = Uri.tryParse(code)?.hasAbsolutePath ?? false;

    if (code.startsWith('WIFI:')) {
      final RegExp passwordPattern = RegExp(r'P:([^;]+);');
      final match = passwordPattern.firstMatch(code);
      if (match != null) {
        password = match.group(1);
      }
    }

    final displayText = password ?? code;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ResultScreen(code: displayText, isLink: isLink),
    )).then((_) {
      setState(() {
        _lastScannedCode = null;
      });
    });
  }

  // Toggle between front and back cameras
  void _switchCamera() {
    setState(() {
      _isBackCamera = !_isBackCamera;
      _cameraController.switchCamera();
    });
  }

  // Increase simulated zoom level
  void _zoomIn() {
    setState(() {
      _scaleFactor = (_scaleFactor + 0.1).clamp(1.0, 3.0); // Limit scale factor between 1.0 and 3.0
    });
  }

  // Decrease simulated zoom level
  void _zoomOut() {
    setState(() {
      _scaleFactor = (_scaleFactor - 0.1).clamp(1.0, 3.0); // Limit scale factor between 1.0 and 3.0
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The camera scanner with simulated zoom
          Transform.scale(
            scale: _scaleFactor,
            child: mobile_scanner.MobileScanner(
              controller: _cameraController,
              onDetect: (barcodeCapture) {
                final String? code = barcodeCapture.barcodes.first.rawValue;
                if (code != null && code != _lastScannedCode) {
                  _lastScannedCode = code;
                  _handleScannedCode(code);
                }
              },
            ),
          ),

          // Positioning the camera switch and gallery icons
          Positioned(
            top: 30,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _pickImageAndScan,
                  icon: Icon(Icons.image, color: Colors.white, size: 32),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _switchCamera,
                  icon: Image.asset(
                    'assets/images/arrow.png',
                    width: 32,
                    height: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Zoom in and zoom out buttons with LinearProgressIndicator
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _zoomOut,
                  icon: Image.asset('assets/images/magnifying-glass.png', width: 18, height: 18, color: Colors.white),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_scaleFactor - 1) / 2, // Maps _scaleFactor (1.0 to 3.0) to progress range (0.0 to 1.0)
                    backgroundColor: Colors.white.withOpacity(0.3),
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _zoomIn,
                  icon: Image.asset('assets/images/zoom-in.png', width: 18, height: 18, color: Colors.white),
                ),
              ],
            ),
          ),

          // Overlay box with animated scan line
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
}
