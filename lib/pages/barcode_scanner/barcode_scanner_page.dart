import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../configs/constants/app_constants.dart';
import '../../configs/strings/string_extensions.dart';
import '../../configs/theme/app_colors.dart';
import '../../services/validators.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/dialogs/barcode_input_dialog.dart';

/// Lê um código de barras pela câmera (ou digitado). Fecha retornando o
/// código. A permissão da câmera é pedida ao abrir esta tela.
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  /// Só os formatos de embalagem: evita ler QR codes e afins.
  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish(String code) {
    if (_done) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code != null && Validators.barcode(code) == null) {
        HapticFeedback.mediumImpact();
        _finish(code);
        return;
      }
    }
  }

  Future<void> _typeCode() async {
    final code = await showBarcodeInputDialog(context);
    if (code != null && mounted) _finish(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppStrings.barcodeScannerTitle),
        actions: [_TorchButton(controller: _controller)],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              overlayBuilder: (_, _) => const _ScanFrame(),
              errorBuilder: (_, error) => _ScannerError(error: error),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.barcodeScannerHint,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                  PrimaryButton(
                    label: AppStrings.barcodeTypeCode,
                    variant: PrimaryButtonVariant.secondary,
                    onPressed: _typeCode,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Some quando o aparelho não tem lanterna (ou a câmera não abriu).
class _TorchButton extends StatelessWidget {
  const _TorchButton({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, _) {
        if (!state.isRunning || state.torchState == TorchState.unavailable) {
          return const SizedBox.shrink();
        }
        final on = state.torchState == TorchState.on;
        return IconButton(
          tooltip: AppStrings.barcodeTorch,
          onPressed: controller.toggleTorch,
          icon: Icon(
            on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            color: on ? AppColors.primary : null,
          ),
        );
      },
    );
  }
}

/// Moldura que mostra onde posicionar o código.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 3),
          borderRadius: BorderRadius.circular(AppConstants.radiusXxl),
        ),
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              denied ? Icons.no_photography_outlined : Icons.videocam_off,
              size: 48,
              color: AppColors.onSurfaceSecondary,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              denied
                  ? AppStrings.barcodeCameraDenied
                  : AppStrings.barcodeCameraUnavailable,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
