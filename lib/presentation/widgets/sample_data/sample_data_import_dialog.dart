import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/repositories/sample_data_service.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_warning_banner.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_stats_display.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_error_display.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_action_buttons.dart';

class SampleDataImportDialog extends ConsumerStatefulWidget {
  const SampleDataImportDialog({super.key});

  @override
  ConsumerState<SampleDataImportDialog> createState() => _SampleDataImportDialogState();
}

class _SampleDataImportDialogState extends ConsumerState<SampleDataImportDialog> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSampleData = false;

  @override
  void initState() {
    super.initState();
    _checkExistingData();
  }

  // Getter pour obtenir le service via ref.read()
  SampleDataService get _sampleDataService => ref.read(sampleDataServiceProvider);

  Future<void> _checkExistingData() async {
    try {
      final hasSample = await _sampleDataService.hasSampleData();
      if (mounted) {
        setState(() {
          _hasSampleData = hasSample;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la vérification: $e';
        });
      }
    }
  }

  Future<void> _importData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _sampleDataService.resetWithSampleData();
      
      // Invalider tous les providers pour forcer le rafraîchissement
      ref.invalidate(tasksSortedByEloProvider);
      ref.invalidate(habitsWithStatsProvider);
      ref.invalidate(activeTasksProvider);
      ref.invalidate(allHabitsProvider);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Retourner true pour indiquer le succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Données d\'exemple importées avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'import: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _sampleDataService.getSampleDataStats();
    
    return AlertDialog(
      title: const Text('Importer des données d\'exemple'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_hasSampleData) ...[
            const SampleDataWarningBanner(),
            const SizedBox(height: 16),
          ],
          
          SampleDataStatsDisplay(stats: stats),
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            SampleDataErrorDisplay(errorMessage: _errorMessage!),
          ],
        ],
      ),
      actions: [
        SampleDataActionButtons(
          isLoading: _isLoading,
          onCancel: _handleCancel,
          onImport: _importData,
        ),
      ],
    );
  }
} 
