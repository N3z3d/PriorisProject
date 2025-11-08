import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  final list = CustomList(
    id: 'abc',
    name: 'Test',
    type: ListType.CUSTOM,
    createdAt: DateTime.parse('2023-01-01T10:00:00Z'),
    updatedAt: DateTime.parse('2023-01-01T11:00:00Z'),
  );
  final json = list.toJson();
  print(json.keys.toList());
  print(json);
}

