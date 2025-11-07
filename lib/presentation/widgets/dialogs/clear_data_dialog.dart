import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/infrastructure/services/user_data_service.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

/// Dialog pour nettoyer les données utilisateur
class ClearDataDialog extends ConsumerStatefulWidget {
  final Color dangerColor;
  final Color warningColor;
  final Color successColor;
  final Color neutralColor;

  const ClearDataDialog({
    super.key,
    this.dangerColor = Colors.red,
    this.warningColor = Colors.orange,
    this.successColor = Colors.green,
    this.neutralColor = Colors.grey,
  });

  @override
  ConsumerState<ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends ConsumerState<ClearDataDialog> {
  final _userDataService = UserDataService.instance;
  
  bool _isLoading = false;
  bool _isLoadingStats = true;
  bool _dataCleared = false;
  String? _errorMessage;
  Map<String, int>? _stats;
  Map<String, dynamic>? _integrity;

  Color _dangerTone(int level) => tone(widget.dangerColor, level: level);
  Color _warningTone(int level) => tone(widget.warningColor, level: level);
  Color _successTone(int level) => tone(widget.successColor, level: level);
  Color _neutralTone(int level) => tone(widget.neutralColor, level: level);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _userDataService.getUserDataStats();
      final integrity = await _userDataService.checkDataIntegrity();
      
      setState(() {
        _stats = stats;
        _integrity = integrity;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _handleClearData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _userDataService.softDeleteAllUserData();
      
      setState(() {
        _dataCleared = true;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCleanOrphans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _userDataService.cleanOrphanData();
      await _loadStats(); // Recharger les stats
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _dataCleared ? 'Données supprimées !' : 'Nettoyer les données',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      content: _dataCleared ? _buildSuccessContent() : _buildFormContent(),
      actions: _dataCleared ? _buildSuccessActions() : _buildFormActions(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildFormContent() {
    return SizedBox(
      width: 450,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoadingStats)
            const Center(child: CircularProgressIndicator())
          else if (_stats != null) ...[
            _buildStatsHeader(),
            const SizedBox(height: 12),
            _buildStatsSection(),
            if (_integrity != null && _integrity!['orphanItems'] > 0) ...[
              const SizedBox(height: 16),
              _buildOrphanDataSection(),
            ],
            const SizedBox(height: 20),
            _buildDangerZoneSection(),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return const Text(
      'État actuel de vos données :',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        _buildStatCard('Listes personnalisées', _stats!['lists']!, Icons.list_alt),
        _buildStatCard('Éléments de liste', _stats!['items']!, Icons.check_circle_outline),
        _buildStatCard('Habitudes', _stats!['habits']!, Icons.track_changes),
      ],
    );
  }

  Widget _buildOrphanDataSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _warningTone(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _warningTone(300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrphanDataHeader(),
          const SizedBox(height: 8),
          CommonButton(
            onPressed: _isLoading ? null : _handleCleanOrphans,
            text: 'Nettoyer les données orphelines',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildOrphanDataHeader() {
    return Row(
      children: [
        Icon(Icons.warning, color: _warningTone(600), size: 20),
        const SizedBox(width: 8),
        Text(
          '${_integrity!['orphanItems']} données orphelines détectées',
          style: TextStyle(
            color: _warningTone(700),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dangerTone(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _dangerTone(300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDangerZoneHeader(),
          const SizedBox(height: 8),
          _buildDangerZoneMessage(),
        ],
      ),
    );
  }

  Widget _buildDangerZoneHeader() {
    return Row(
      children: [
        Icon(Icons.warning, color: _dangerTone(600)),
        const SizedBox(width: 8),
        Text(
          'Zone de danger',
          style: TextStyle(
            color: _dangerTone(700),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneMessage() {
    return Text(
      'Cette action supprimera TOUTES vos données (listes, éléments, habitudes). Cette action est irréversible.',
      style: TextStyle(
        color: _dangerTone(700),
        fontSize: 14,
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _dangerTone(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _dangerTone(300)),
      ),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: _dangerTone(700)),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _neutralTone(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _neutralTone(200)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.delete_sweep,
          size: 64,
          color: _successTone(600),
        ),
        const SizedBox(height: 16),
        const Text(
          'Toutes vos données ont été supprimées avec succès.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Vous pouvez maintenant recommencer avec une ardoise vierge.',
          style: TextStyle(
            fontSize: 14,
            color: _neutralTone(600),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildFormActions() {
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      if (_stats != null && (_stats!['lists']! > 0 || _stats!['items']! > 0 || _stats!['habits']! > 0))
        ElevatedButton(
          onPressed: _isLoading ? null : _handleClearData,
          style: ElevatedButton.styleFrom(
            backgroundColor: _dangerTone(600),
            foregroundColor: Colors.white,
          ),
          child: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Tout supprimer'),
        ),
    ];
  }

  List<Widget> _buildSuccessActions() {
    return [
      CommonButton(
        onPressed: () => Navigator.of(context).pop(),
        text: 'Fermer',
      ),
    ];
  }
}
