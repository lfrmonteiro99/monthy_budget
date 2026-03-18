import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/parsed_receipt.dart';
import '../services/receipt_scan_service.dart';
import '../theme/app_colors.dart';
import '../utils/atcud_parser.dart';

enum _ScanMode { qr, photo }

/// Modal bottom sheet for scanning receipts via QR code or photo OCR.
///
/// Returns a [ParsedReceipt] on success, or null if dismissed.
class ReceiptScanSheet extends StatefulWidget {
  const ReceiptScanSheet({super.key});

  /// Show as a modal bottom sheet and return the parsed receipt or null.
  static Future<ParsedReceipt?> show(BuildContext context) {
    return showModalBottomSheet<ParsedReceipt>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReceiptScanSheet(),
    );
  }

  @override
  State<ReceiptScanSheet> createState() => _ReceiptScanSheetState();
}

class _ReceiptScanSheetState extends State<ReceiptScanSheet> {
  _ScanMode _mode = _ScanMode.qr;
  bool _scanned = false;
  bool _processing = false;
  String? _error;

  MobileScannerController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _onQrDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    if (!AtcudParser.isAtcudQrCode(code)) return;

    final receipt = AtcudParser.parse(code);
    if (receipt == null) return;

    _scanned = true;
    Navigator.of(context).pop(receipt);
  }

  Future<void> _onTakePhoto() async {
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        if (!mounted) return;
        setState(() => _processing = false);
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final recognizer = TextRecognizer();
      try {
        final recognised = await recognizer.processImage(inputImage);
        final lines =
            recognised.blocks.expand((b) => b.lines).map((l) => l.text).toList();

        final receipt = ReceiptScanService.processOcrText(textLines: lines);
        if (receipt != null && mounted) {
          Navigator.of(context).pop(receipt);
          return;
        }

        if (mounted) {
          setState(() {
            _error = S.of(context).receiptScanFailed;
            _processing = false;
          });
        }
      } finally {
        await recognizer.close();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = S.of(context).receiptScanFailed;
          _processing = false;
        });
      }
    }
  }

  void _onModeChanged(_ScanMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _error = null;
      _scanned = false;
    });
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
          // Drag handle
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
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.receiptScanTitle,
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
          // Mode toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<_ScanMode>(
              segments: [
                ButtonSegment(
                  value: _ScanMode.qr,
                  label: Text(l10n.receiptScanQrMode),
                  icon: const Icon(Icons.qr_code, size: 18),
                ),
                ButtonSegment(
                  value: _ScanMode.photo,
                  label: Text(l10n.receiptScanPhotoMode),
                  icon: const Icon(Icons.camera_alt, size: 18),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => _onModeChanged(s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primary(context);
                  }
                  return AppColors.surface(context);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.onPrimary(context);
                  }
                  return AppColors.textSecondary(context);
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Content area
          Expanded(child: _buildContent(l10n)),
          // Hint / error
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              _error ?? l10n.receiptScanHint,
              style: TextStyle(
                fontSize: 13,
                color: _error != null
                    ? AppColors.error(context)
                    : AppColors.textMuted(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(S l10n) {
    if (_mode == _ScanMode.qr) {
      return _buildQrMode();
    }
    return _buildPhotoMode(l10n);
  }

  Widget _buildQrMode() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: MobileScanner(
            controller: _cameraController!,
            onDetect: _onQrDetect,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoMode(S l10n) {
    if (_processing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary(context)),
            const SizedBox(height: 16),
            Text(
              l10n.receiptScanHint,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _onTakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: Text(l10n.receiptScanPhotoMode),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                foregroundColor: AppColors.onPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
