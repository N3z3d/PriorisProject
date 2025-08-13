import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../sample_data.dart';
import 'habit_repository.dart';
import 'task_repository.dart';
import 'custom_list_repository.dart';
import '../providers/repository_providers.dart';
import '../../domain/services/core/interfaces/data_import_interface.dart';

/// Service d'import de données respectant le principe Single Responsibility
/// 
/// Se concentre uniquement sur l'import des données d'exemple.
class SampleDataImportService implements DataImportInterface {
  final HabitRepository _habitRepository;
  final TaskRepository _taskRepository;
  final CustomListRepository _customListRepository;

  SampleDataImportService(
    this._habitRepository,
    this._taskRepository, 
    this._customListRepository,
  );

  @override
  Future<bool> importSampleData() async {
    try {
      final habits = SampleData.getSampleHabits();
      final tasks = SampleData.getSampleTasks();
      final lists = SampleData.getSampleLists();
      
      // Sauvegarder les habitudes
      for (final habit in habits) {
        await _habitRepository.saveHabit(habit);
      }
      
      // Sauvegarder les tâches
      for (final task in tasks) {
        await _taskRepository.saveTask(task);
      }
      
      // Sauvegarder les listes personnalisées
      for (final list in lists) {
        await _customListRepository.saveList(list);
      }
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'import des données d\'exemple: $e');
      return false;
    }
  }

  @override
  Future<void> importAllSampleData() async {
    await importSampleData();
  }
}

/// Service de gestion des données respectant le principe Single Responsibility
/// 
/// Se concentre uniquement sur le nettoyage et la réinitialisation.
class SampleDataManagementService implements DataManagementInterface {
  final HabitRepository _habitRepository;
  final TaskRepository _taskRepository;
  final CustomListRepository _customListRepository;
  final DataImportInterface _importService;

  SampleDataManagementService(
    this._habitRepository,
    this._taskRepository,
    this._customListRepository,
    this._importService,
  );

  @override
  Future<void> clearAllData() async {
    await _habitRepository.clearAllHabits();
    await _taskRepository.clearAllTasks();
    await _customListRepository.clearAllLists();
  }

  @override
  Future<void> resetWithSampleData() async {
    await clearAllData();
    await _importService.importAllSampleData();
  }
}

/// Service d'information sur les données respectant le principe Single Responsibility
/// 
/// Se concentre uniquement sur les informations et statistiques.
class SampleDataInfoService implements DataInfoInterface {
  final HabitRepository _habitRepository;
  final TaskRepository _taskRepository;
  final CustomListRepository _customListRepository;

  SampleDataInfoService(
    this._habitRepository,
    this._taskRepository,
    this._customListRepository,
  );

  @override
  Future<bool> hasSampleData() async {
    final habits = await _habitRepository.getAllHabits();
    final tasks = await _taskRepository.getAllTasks();
    final lists = await _customListRepository.getAllLists();
    
    return habits.isNotEmpty || tasks.isNotEmpty || lists.isNotEmpty;
  }

  @override
  Map<String, int> getSampleDataStats() {
    final habitsCount = SampleData.getSampleHabits().length;
    final tasksCount = SampleData.getSampleTasks().length;
    final listsCount = SampleData.getSampleLists().length;
    
    return {
      'habits': habitsCount,
      'tasks': tasksCount,
      'lists': listsCount,
      'total': habitsCount + tasksCount + listsCount,
    };
  }
}

/// Service composite pour les données d'exemple
/// 
/// Combine les différents services spécialisés tout en respectant
/// le principe de composition over inheritance.
class SampleDataService {
  final DataImportInterface _importService;
  final DataManagementInterface _managementService;
  final DataInfoInterface _infoService;

  SampleDataService(
    this._importService,
    this._managementService,
    this._infoService,
  );

  // Délégation vers les services spécialisés
  Future<bool> importSampleData() => _importService.importSampleData();
  Future<void> importAllSampleData() => _importService.importAllSampleData();
  
  Future<void> clearAllData() => _managementService.clearAllData();
  Future<void> resetWithSampleData() => _managementService.resetWithSampleData();
  
  Future<bool> hasSampleData() => _infoService.hasSampleData();
  Map<String, int> getSampleDataStats() => _infoService.getSampleDataStats();
}

// Providers pour les services spécialisés
final sampleDataImportServiceProvider = Provider<SampleDataImportService>((ref) {
  return SampleDataImportService(
    ref.read(habitRepositoryProvider),
    ref.read(taskRepositoryProvider),
    ref.read(customListRepositoryProvider),
  );
});

final sampleDataInfoServiceProvider = Provider<SampleDataInfoService>((ref) {
  return SampleDataInfoService(
    ref.read(habitRepositoryProvider),
    ref.read(taskRepositoryProvider),
    ref.read(customListRepositoryProvider),
  );
});

final sampleDataManagementServiceProvider = Provider<SampleDataManagementService>((ref) {
  return SampleDataManagementService(
    ref.read(habitRepositoryProvider),
    ref.read(taskRepositoryProvider),
    ref.read(customListRepositoryProvider),
    ref.read(sampleDataImportServiceProvider),
  );
});

/// Provider pour le service de données d'exemple (service composite)
final sampleDataServiceProvider = Provider<SampleDataService>((ref) {
  return SampleDataService(
    ref.read(sampleDataImportServiceProvider),
    ref.read(sampleDataManagementServiceProvider),
    ref.read(sampleDataInfoServiceProvider),
  );
}); 
