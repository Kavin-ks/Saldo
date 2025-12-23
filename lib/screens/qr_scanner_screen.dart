import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/qr_scanner_overlay.dart';
import 'pay_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final int userId;
  const QRScannerScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Ensure MobileScanner is configured correctly for Flutter Web
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      // Removed format restriction to support all formats including those used by GPay/Start
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    // 3. Ensure scan result is handled ONCE
    if (_isScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isScanned = true);
        HapticFeedback.mediumImpact();
        
        // Stop scanner after first success
        _controller.stop();
        
        final String scannedData = barcode.rawValue!;

        // Parse any UPI QR that starts with upi://pay
        String finalReceiverId = scannedData;
        String? finalReceiverName;
        String? txnRef;

        if (scannedData.toLowerCase().startsWith('upi://pay')) {
          try {
            final uri = Uri.parse(scannedData);
            final pa = uri.queryParameters['pa'];
            final pn = uri.queryParameters['pn'];
            final tr = uri.queryParameters['tr'] ?? uri.queryParameters['tid'];

            if (pa != null && pa.isNotEmpty) {
              finalReceiverId = pa;
            }

            if (pn != null && pn.isNotEmpty) {
              finalReceiverName = pn;
            }

            if (tr != null && tr.isNotEmpty) {
              txnRef = tr;
            }
          } catch (_) {
            // Fall back to raw data if parsing fails
          }
        }

        if (finalReceiverId.trim().isEmpty) {
          finalReceiverId = "QR_${DateTime.now().millisecondsSinceEpoch}";
        }

        // Navigate to the same Pay screen, pre-filling UPI details
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PayScreen(
              userId: widget.userId,
              initialReceiverPhone: finalReceiverId,
              initialReceiverName: finalReceiverName,
              initialNote: txnRef,
              paymentMethod: 'QR',
            ),
          ),
        );
        break; 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 2. Fix common Flutter Web QR issues (scanner widget has non-zero height & width via Stack parent)
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: const Color(0xFF5C6BC0),
                borderRadius: 20,
                borderLength: 40,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Align QR code within the frame',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
