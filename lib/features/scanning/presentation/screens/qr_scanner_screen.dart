import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/routes.dart';
import '../../../../app/design_tokens.dart';
import '../../../../core/widgets/afya_app_bar.dart';
import '../../../../shared/providers/scan_provider.dart';
import '../../data/models/scan_result.dart';
import '../widgets/scanner_frame_overlay.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (_processing) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;
    if (rawValue == null) return;

    setState(() => _processing = true);
    await _controller.stop();

    final repository = ref.read(scanRepositoryProvider);
    final result = await repository.validate(rawValue);

    if (!mounted) return;
    _routeFromResult(result);
  }

  Future<void> _routeFromResult(ScanResult result) async {
    switch (result.status) {
      case ScanStatus.valid:
        await context.push(AppRoutes.scanSuccess,
            extra: result.bookingReference);
        break;
      case ScanStatus.invalid:
        await context.push(AppRoutes.invalidQr);
        break;
      case ScanStatus.expired:
        await context.push(AppRoutes.invalidQr, extra: 'expired');
        break;
      case ScanStatus.alreadyProcessed:
        await context.push(AppRoutes.alreadyProcessed,
            extra: result.bookingReference);
        break;
    }
    // Returning from any result screen re-arms the scanner instead of
    // leaving a frozen black preview (previously _processing stayed true).
    if (!mounted) return;
    await _resetForNextScan();
  }

  Future<void> _resetForNextScan() async {
    setState(() => _processing = false);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AfyaAppBar(
        title: 'Scan Traveller QR',
        subtitle: 'Align the QR within the frame',
        dark: true,
        showSyncStatus: false,
        actions: [
          IconButton(
            tooltip: 'Torch',
            icon: Icon(_torchOn
                ? Icons.flash_on_outlined
                : Icons.flash_off_outlined),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          IconButton(
            tooltip: 'Manual entry',
            icon: const Icon(Icons.keyboard_outlined),
            onPressed: () => context.push(AppRoutes.manualEntry),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleDetection,
          ),
          const ScannerFrameOverlay(),
          Positioned(
            left: 0,
            right: 0,
            top: 300,
            child: Text(
              'Align the traveller\'s QR code within the frame',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xl,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => context.push(AppRoutes.manualEntry),
              child: const Text('Enter Booking Reference Manually'),
            ),
          ),
        ],
      ),
    );
  }
}