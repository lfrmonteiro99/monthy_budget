import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// Bottom sheet that opens the camera for barcode scanning.
///
/// Returns the scanned barcode string via [Navigator.pop] or null if dismissed.
class BarcodeScanSheet extends StatefulWidget {
  const BarcodeScanSheet({super.key});

  /// Show as a modal bottom sheet and return the scanned barcode or null.
  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BarcodeScanSheet(),
    );
  }

  @override
  State<BarcodeScanSheet> createState() => _BarcodeScanSheetState();
}

class _BarcodeScanSheetState extends State<BarcodeScanSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    _scanned = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMuted(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.barcodeScanTitle,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.barcodeScanHint,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
