/// **GET TASKS QUERY** - CQRS Pattern
import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

class GetTasksQuery extends Query {
  final String? category;
  final bool? completed;
  final PriorityLevel? priority;
  final DateRange? dueDateRange;
  final int? limit;
  final String? searchText;

  GetTasksQuery({
    this.category,
    this.completed,
    this.priority,
    this.dueDateRange,
    this.limit,
    this.searchText,
  });

  @override
  void validate() {
    if (limit != null && limit! <= 0) {
      throw BusinessValidationException(
        'Limite invalide',
        ['La limite doit être supérieure à 0'],
        operationName: 'GetTasks',
      );
    }
  }
}