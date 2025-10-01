import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/list_selection_dialog.dart';
import 'package:prioris/presentation/widgets/dialogs/task_edit_dialog.dart';
import '../../lists/controllers/lists_controller.dart';
import '../../../../infrastructure/services/logger_service.dart';
import 'duel_business_logic_service.dart';

/// Service spécialisé pour les interactions utilisateur du duel - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour les dialogues et notifications
/// - OCP: Extensible via factory methods pour différents types d'interactions
/// - LSP: Compatible avec les interfaces d'interaction utilisateur
/// - ISP: Interface focalisée sur les interactions uniquement
/// - DIP: Dépend des abstractions des dialogues et services
///
/// Features:
/// - Gestion des dialogues d'édition de tâches
/// - Dialogues de sélection et configuration des listes
/// - Notifications et SnackBars contextuelles
/// - Gestion d'erreurs utilisateur-friendly
/// - Navigation et actions utilisateur
///
/// CONSTRAINTS: <200 lignes
class DuelInteractionService {
  final BuildContext _context;
  final Ref _ref;

  DuelInteractionService(this._context, this._ref);

  /// Affiche le dialogue d'édition de tâche
  Future<void> showTaskEditDialog({
    required Task task,
    required Future<void> Function(Task updatedTask) onTaskUpdated,
  }) async {
    LoggerService.instance.info(
      'Ouverture dialogue édition: "${task.title}"',
      context: 'DuelInteractionService',
    );

    await showDialog(
      context: _context,
      builder: (context) => TaskEditDialog(
        initialTask: task,
        onSubmit: (updatedTask) async {
          await _handleTaskUpdateWithFeedback(updatedTask, onTaskUpdated);
        },
      ),
    );
  }

  /// Affiche le dialogue de sélection des listes
  Future<void> showListSelectionDialog({
    required ListPrioritizationSettings currentSettings,
    required Function(ListPrioritizationSettings) onSettingsChanged,
  }) async {
    LoggerService.instance.info(
      'Ouverture dialogue sélection listes',
      context: 'DuelInteractionService',
    );

    try {
      // SOLID SRP: Gestion du chargement des listes
      await _ensureListsAreLoaded();

      final listsState = _ref.read(listsControllerProvider);

      // SOLID SRP: Validation des données avant affichage
      if (!_validateListsData(listsState)) return;

      // Transformation des données pour le dialogue
      final availableLists = _transformListsForDialog(listsState.lists);

      await showListSelectionDialog(
        _context,
        currentSettings: currentSettings,
        availableLists: availableLists,
        onSettingsChanged: onSettingsChanged,
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur dialogue sélection listes: $e',
        context: 'DuelInteractionService',
        error: e,
      );
      _showErrorSnackBar('Erreur lors de l\'ouverture des paramètres de listes');
    }
  }

  /// Affiche le résultat d'un duel avec animation
  void showDuelResult(DuelResult result) {
    LoggerService.instance.info(
      'Affichage résultat duel: "${result.winner.title}" > "${result.loser.title}"',
      context: 'DuelInteractionService',
    );

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(
          '"${result.winner.title}" prioritaire sur "${result.loser.title}"',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.secondaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche la tâche sélectionnée aléatoirement
  void showRandomTaskSelected(Task selectedTask) {
    LoggerService.instance.info(
      'Affichage tâche aléatoire: "${selectedTask.title}"',
      context: 'DuelInteractionService',
    );

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎲 Tâche sélectionnée aléatoirement :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(selectedTask.title),
            if (selectedTask.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 2),
              Text(
                selectedTask.description!,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ],
        ),
        backgroundColor: Theme.of(_context).primaryColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Terminer',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Intégrer avec la logique de complétion des tâches
            LoggerService.instance.debug(
              'Action terminer tâche aléatoire',
              context: 'DuelInteractionService',
            );
          },
        ),
      ),
    );
  }

  /// Affiche une notification de succès
  void showSuccessMessage(String message) {
    _showSnackBar(message, Colors.green, Icons.check_circle);
  }

  /// Affiche une notification d'erreur
  void showErrorMessage(String message) {
    _showErrorSnackBar(message);
  }

  /// Affiche un message d'information
  void showInfoMessage(String message) {
    _showSnackBar(message, Theme.of(_context).primaryColor, Icons.info);
  }

  // === PRIVATE HELPER METHODS ===

  /// Gère la mise à jour de tâche avec feedback utilisateur
  Future<void> _handleTaskUpdateWithFeedback(
    Task updatedTask,
    Future<void> Function(Task) onTaskUpdated,
  ) async {
    try {
      await onTaskUpdated(updatedTask);

      _showSnackBar(
        'Tâche "${updatedTask.title}" mise à jour avec succès',
        Colors.green,
        Icons.check_circle,
      );

      LoggerService.instance.info(
        'Tâche mise à jour avec succès: "${updatedTask.title}"',
        context: 'DuelInteractionService',
      );
    } catch (e) {
      LoggerService.instance.error(
        'Erreur mise à jour tâche: $e',
        context: 'DuelInteractionService',
        error: e,
      );
      _showErrorSnackBar('Erreur lors de la mise à jour: $e');
    }
  }

  /// Ensure les listes sont chargées avec feedback
  Future<void> _ensureListsAreLoaded() async {
    final listsState = _ref.read(listsControllerProvider);

    if (listsState.lists.isEmpty && !listsState.isLoading) {
      _showLoadingMessage('Chargement des listes...');
      await _ref.read(listsControllerProvider.notifier).loadLists();
    }
  }

  /// Valide les données des listes avant utilisation
  bool _validateListsData(dynamic listsState) {
    if (listsState.error != null) {
      _showErrorSnackBar('Erreur lors du chargement des listes: ${listsState.error}');
      return false;
    }

    if (listsState.lists.isEmpty) {
      _showNoListsDialog();
      return false;
    }

    return true;
  }

  /// Transforme les listes pour le dialogue
  List<Map<String, String>> _transformListsForDialog(dynamic lists) {
    return lists.map<Map<String, String>>((list) => {
      'id': list.id,
      'title': list.name,
    }).toList();
  }

  /// Affiche un message de chargement
  void _showLoadingMessage(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Affiche le dialogue "Aucune liste disponible"
  void _showNoListsDialog() {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.list_alt_outlined,
          size: 48,
          color: Theme.of(_context).colorScheme.primary,
        ),
        title: const Text('Aucune liste disponible'),
        content: const Text(
          'Vous devez d\'abord créer des listes pour pouvoir les sélectionner dans le mode priorisation.\n\n'
          'Rendez-vous dans l\'onglet "Listes" pour créer votre première liste.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showInfoMessage('Naviguez vers l\'onglet "Listes" pour créer vos listes');
            },
            child: const Text('Aller aux listes'),
          ),
        ],
      ),
    );
  }

  /// Méthode générique pour afficher des SnackBars
  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Méthode spécialisée pour les erreurs
  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red, Icons.error);
  }
}