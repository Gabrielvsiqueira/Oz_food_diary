import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Falhas ao escolher a foto. A mensagem exibida fica na camada de View.
sealed class PhotoPickerFailure implements Exception {
  const PhotoPickerFailure();
}

/// O usuário negou (ou o aparelho restringe) o acesso à câmera ou às fotos.
class PhotoAccessDeniedFailure extends PhotoPickerFailure {
  const PhotoAccessDeniedFailure();
}

/// Sem câmera (simulador do iOS) ou outro erro do sistema.
class PhotoUnavailableFailure extends PhotoPickerFailure {
  const PhotoUnavailableFailure([this.cause]);
  final Object? cause;

  @override
  String toString() => 'PhotoUnavailableFailure($cause)';
}

/// Abre a câmera ou a galeria do aparelho (telas nativas do sistema) e
/// devolve o caminho da foto, ou `null` se o usuário cancelar.
class PhotoPicker {
  PhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Reduz a foto: o suficiente para a tela, sem ocupar muito espaço.
  static const _maxSide = 1600.0;
  static const _quality = 80;

  Future<String?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          PhotoSource.camera => ImageSource.camera,
          PhotoSource.gallery => ImageSource.gallery,
        },
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      return file?.path;
    } on PlatformException catch (e) {
      throw switch (e.code) {
        'camera_access_denied' ||
        'camera_access_restricted' ||
        'photo_access_denied' ||
        'photo_access_restricted' => const PhotoAccessDeniedFailure(),
        _ => PhotoUnavailableFailure(e),
      };
    }
  }
}
