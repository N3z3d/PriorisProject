/// **DUEL TASKS COMMAND** - CQRS Pattern
import '../../services/application_service.dart';

class DuelTasksCommand extends Command {
  final String task1Id;
  final String task2Id;

  DuelTasksCommand({
    required this.task1Id,
    required this.task2Id,
  });

  @override
  void validate() {
    if (task1Id.trim().isEmpty || task2Id.trim().isEmpty) {
      throw BusinessValidationException(
        'IDs de tâches requis',
        ['Les identifiants des deux tâches sont requis'],
        operationName: 'DuelTasks',
      );
    }

    if (task1Id == task2Id) {
      throw BusinessValidationException(
        'Tâches identiques',
        ['Une tâche ne peut pas se battre contre elle-même'],
        operationName: 'DuelTasks',
      );
    }
  }
}