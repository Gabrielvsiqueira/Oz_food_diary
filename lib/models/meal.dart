import 'enums/meal_type.dart';
import 'meal_item.dart';

class Meal {
  Meal({
    required this.id,
    required this.type,
    required List<MealItem> items,
    required this.createdAt,
    this.photoPath,
  }) : items = List.unmodifiable(items);

  final String id;
  final MealType type;
  final List<MealItem> items;
  final DateTime createdAt;

  /// Foto opcional, só deste aparelho (caminho do arquivo).
  final String? photoPath;

  int get calories => items.fold(0.0, (sum, i) => sum + i.calories).round();
  double get carbsG => items.fold(0, (sum, i) => sum + i.carbsG);
  double get proteinG => items.fold(0, (sum, i) => sum + i.proteinG);
  double get fatG => items.fold(0, (sum, i) => sum + i.fatG);

  String get summary => items.map((i) => i.food.name).join(', ');

  Meal copyWith({MealType? type, List<MealItem>? items}) => Meal(
    id: id,
    type: type ?? this.type,
    items: items ?? this.items,
    createdAt: createdAt,
    photoPath: photoPath,
  );

  /// Troca ou remove ([path] nulo) a foto.
  Meal withPhoto(String? path) => Meal(
    id: id,
    type: type,
    items: items,
    createdAt: createdAt,
    photoPath: path,
  );
}
