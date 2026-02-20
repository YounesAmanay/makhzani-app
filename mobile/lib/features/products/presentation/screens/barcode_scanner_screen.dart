/// Barcode Scanner Screen
///
/// Full-screen camera scanner. Returns a BarcodeResult? to the caller
/// via Navigator.pop(context, result).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/products_provider.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _isProcessing = false;
  bool _torchOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(String rawBarcode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    // Haptic feedback on detection
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator) Vibration.vibrate(duration: 60);

    try {
      final repository = ref.read(productsRepositoryProvider);
      final result = await repository.lookupBarcode(rawBarcode);

      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pop(result);
      } else {
        _showNotFoundSheet(rawBarcode);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_network),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showNotFoundSheet(String barcode) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppDimensions.marginMedium),

                Text(
                  context.l10n.products_notFound,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  context.l10n.products_notFoundMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.marginXLarge),

                // Enter manually — returns null, caller shows manual form
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // close sheet
                      Navigator.of(context).pop(null); // close scanner
                    },
                    child: Text(context.l10n.products_enterManually),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),

                // Scan again — dismiss sheet, reset processing flag
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (mounted) setState(() => _isProcessing = false);
                    },
                    child: Text(context.l10n.products_scanAgain),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // If user dismissed sheet by swiping, reset processing so scan works again
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: context.l10n.common_close,
          onPressed: () => Navigator.of(context).pop(null),
        ),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: context.l10n.products_toggleTorch,
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcode = capture.barcodes.firstOrNull?.rawValue;
              if (barcode != null && barcode.isNotEmpty) {
                _onBarcodeDetected(barcode);
              }
            },
          ),

          // Viewfinder overlay
          _buildViewfinderOverlay(),

          // Loading overlay (shown during API call)
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildViewfinderOverlay() {
    return Column(
      children: [
        // Dark top area
        Expanded(
          flex: 2,
          child: Container(color: Colors.black54),
        ),

        // Middle row: dark sides + transparent center
        Row(
          children: [
            Container(width: 48, color: Colors.black54),
            Expanded(
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Stack(
                  children: [
                    // Corner accents
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),

                    // Laser scan line
                    _buildScanLine(),
                  ],
                ),
              ),
            ),
            Container(width: 48, color: Colors.black54),
          ],
        ),

        // Dark bottom area + hint text
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black54,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.marginLarge),
                Text(
                  context.l10n.products_scanBarcode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginXSmall),
                Text(
                  context.l10n.products_scanSubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const size = 20.0;
    const thickness = 3.0;
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CornerPainter(
            isTop: isTop,
            isLeft: isLeft,
            thickness: thickness,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildScanLine() {
    return _ScanLineWidget();
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppDimensions.marginMedium),
                Text(
                  context.l10n.products_lookingUp,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated scan line
// ---------------------------------------------------------------------------

class _ScanLineWidget extends StatefulWidget {
  @override
  State<_ScanLineWidget> createState() => _ScanLineWidgetState();
}

class _ScanLineWidgetState extends State<_ScanLineWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * 220,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.primary.withValues(alpha: 0.8),
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Corner accent painter
// ---------------------------------------------------------------------------

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final double thickness;
  final Color color;

  _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.thickness,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop ? 0.0 : size.height;
    final dx = isLeft ? size.width : -size.width;
    final dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color || old.thickness != thickness;
}
