/// **GET TASK QUERY** - CQRS Pattern
import '../../services/application_service.dart';

class GetTaskQuery extends Query {
  final String taskId;

  GetTaskQuery({required this.taskId});

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'GetTask',
      );
    }
  }
}