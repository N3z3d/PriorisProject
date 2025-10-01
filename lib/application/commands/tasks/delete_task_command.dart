/// **DELETE TASK COMMAND** - CQRS Pattern
import '../../services/application_service.dart';

class DeleteTaskCommand extends Command {
  final String taskId;

  DeleteTaskCommand({required this.taskId});

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'DeleteTask',
      );
    }
  }
}