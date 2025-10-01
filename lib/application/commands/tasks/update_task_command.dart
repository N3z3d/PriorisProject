/// **UPDATE TASK COMMAND** - CQRS Pattern
import '../../services/application_service.dart';

class UpdateTaskCommand extends Command {
  final String taskId;
  final String? title;
  final String? description;
  final String? category;
  final DateTime? dueDate;

  UpdateTaskCommand({
    required this.taskId,
    this.title,
    this.description,
    this.category,
    this.dueDate,
  });

  @override
  void validate() {
    if (taskId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID de tâche requis',
        ['L\'identifiant de la tâche est requis'],
        operationName: 'UpdateTask',
      );
    }

    if (title != null && title!.trim().isEmpty) {
      throw BusinessValidationException(
        'Le titre ne peut pas être vide',
        ['Le titre de la tâche ne peut pas être vide'],
        operationName: 'UpdateTask',
      );
    }
  }
}