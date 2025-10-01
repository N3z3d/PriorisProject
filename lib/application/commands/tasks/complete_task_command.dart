/// **COMPLETE TASK COMMAND** - CQRS Pattern
import '../../services/application_service.dart';

class CompleteTaskCommand extends Command {
  final String taskId;
  final DateTime? completedAt;

  CompleteTaskCommand({
    required this.taskId,
    this.completedAt,
  });

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'CompleteTask',
      );
    }
  }
}