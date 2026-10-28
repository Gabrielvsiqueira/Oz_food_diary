import 'package:uuid/uuid.dart';

import 'date_only_converter.dart';

const _uuid = Uuid();

/// Namespace fixo do Oz para os IDs determinísticos (UUID v5).
const _namespace = '2a4aa349-2f3d-44bd-95a5-fc34ea0ecba4';

String newId() => _uuid.v4();

/// Registros com um por dia (peso, meta): dois aparelhos que gravam o mesmo
/// dia offline geram o mesmo ID, e o upsert cai na mesma linha.
String dailyRecordId(String userId, String kind, DateTime day) =>
    _uuid.v5(_namespace, '$userId:$kind:${const DateOnlyConverter().toSql(day)}');

/// Itens são identificados pela posição na refeição: editar a refeição
/// reaproveita as mesmas linhas em vez de criar novas.
String mealItemId(String mealId, int position) =>
    _uuid.v5(_namespace, 'meal-item:$mealId:$position');
