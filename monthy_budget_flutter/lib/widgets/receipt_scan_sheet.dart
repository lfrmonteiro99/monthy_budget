import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/parsed_receipt.dart';
import '../services/analytics_service.dart';
import '../services/receipt_scan_service.dart';
import '../theme/app_colors.dart';
import '../utils/atcud_parser.dart';
import 'calm/calm.dart';

enum _ScanMode { qr, photo }

/// Modal bottom sheet for scanning receipts via QR code or photo OCR.
///
/// Returns a [ParsedReceipt] on success, or null if dismissed.
class ReceiptScanSheet extends StatefulWidget {
  const ReceiptScanSheet({super.key});

  /// Show as a modal bottom sheet and return the parsed receipt or null.
  static Future<ParsedReceipt?> show(BuildContext context) {
    return CalmBottomSheet.show<ParsedReceipt>(
      context,
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

  MobileScannerController? _qrController;

  // In-app camera for photo mode
  CameraController? _photoCameraController;
  bool _photoCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initQrCamera();
  }

  void _initQrCamera() {
    _qrController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  Future<void> _initPhotoCamera() async {
    if (_photoCameraController != null) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() => _error = S.of(context).receiptScanFailed);
        }
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (mounted) {
        setState(() {
          _photoCameraController = controller;
          _photoCameraReady = true;
        });
      } else {
        controller.dispose();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = S.of(context).receiptScanFailed);
      }
    }
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _photoCameraController?.dispose();
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
    unawaited(
      AnalyticsService.instance.trackEvent(
        'receipt_scanned',
        properties: {
          'source': 'qr',
          'line_item_count': receipt.lineItems.length,
          'has_line_items': receipt.hasLineItems,
          'total_amount': receipt.totalAmount,
        },
      ),
    );
    Navigator.of(context).pop(receipt);
  }

  Future<void> _onCapturePhoto() async {
    final controller = _photoCameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (_processing) return;

    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final image = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizer = TextRecognizer();
      try {
        final recognised = await recognizer.processImage(inputImage);
        final lines = recognised.blocks
            .expand((b) => b.lines)
            .map((l) => l.text)
            .toList();

        final receipt = ReceiptScanService.processOcrText(textLines: lines);
        if (receipt != null && mounted) {
          unawaited(
            AnalyticsService.instance.trackEvent(
              'receipt_scanned',
              properties: {
                'source': 'photo',
                'line_item_count': receipt.lineItems.length,
                'has_line_items': receipt.hasLineItems,
                'total_amount': receipt.totalAmount,
              },
            ),
          );
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
    if (mode == _ScanMode.photo) {
      _initPhotoCamera();
    }
  }

  String _hintText(S l10n) {
    if (_error != null) return _error!;
    if (_processing) return l10n.receiptScanProcessing;
    if (_mode == _ScanMode.photo) return l10n.receiptScanPhotoHint;
    return l10n.receiptScanHint;
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
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
              _hintText(l10n),
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
            controller: _qrController!,
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
              l10n.receiptScanProcessing,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      );
    }

    if (!_photoCameraReady || _photoCameraController == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary(context)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Live camera preview
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _photoCameraController!.value.previewSize?.height ?? 1,
                  height: _photoCameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_photoCameraController!),
                ),
              ),
            ),
            // Capture button
            Positioned(
              bottom: 20,
              child: GestureDetector(
                onTap: _onCapturePhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
