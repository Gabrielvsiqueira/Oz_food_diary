import 'dart:io';

/// Pasta das fotos das refeições, dentro dos documentos do app (some se o
/// app for desinstalado e não aparece na galeria).
class MealPhotoStorage {
  const MealPhotoStorage(this.directory);

  final Directory directory;

  String pathOf(String fileName) => '${directory.path}/$fileName';

  /// Arquivo que já está guardado aqui (e não uma foto recém-escolhida).
  bool isStored(String path) => File(path).parent.path == directory.path;

  /// Copia a foto escolhida (que o seletor deixa numa pasta temporária) e
  /// devolve o nome do arquivo guardado.
  Future<String> keep(String sourcePath, {required String mealId}) async {
    await directory.create(recursive: true);
    final extension = sourcePath.contains('.')
        ? sourcePath.substring(sourcePath.lastIndexOf('.')).toLowerCase()
        : '.jpg';
    // O horário no nome evita que a tela mostre a foto antiga em cache.
    final fileName =
        '$mealId-${DateTime.now().millisecondsSinceEpoch}$extension';
    await File(sourcePath).copy(pathOf(fileName));
    return fileName;
  }

  Future<void> delete(String fileName) async {
    final file = File(pathOf(fileName));
    if (await file.exists()) await file.delete();
  }

  /// Apaga os arquivos que não estão em [keep] (fotos de refeições que
  /// sumiram, ou que sobraram de uma gravação interrompida).
  Future<void> prune(Set<String> keep) async {
    if (!await directory.exists()) return;
    await for (final entity in directory.list()) {
      final name = entity.uri.pathSegments.last;
      if (entity is File && !keep.contains(name)) await entity.delete();
    }
  }

  Future<void> deleteAll() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  }
}
