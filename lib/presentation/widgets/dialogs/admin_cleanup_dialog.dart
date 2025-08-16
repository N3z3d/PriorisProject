import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/infrastructure/services/admin_service.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Dialog d'administration pour nettoyer TOUTES les données
class AdminCleanupDialog extends ConsumerStatefulWidget {
  const AdminCleanupDialog({super.key});

  @override
  ConsumerState<AdminCleanupDialog> createState() => _AdminCleanupDialogState();
}

class _AdminCleanupDialogState extends ConsumerState<AdminCleanupDialog> {
  final _adminService = AdminService.instance;
  
  bool _isLoading = false;
  bool _isLoadingStats = true;
  bool _dataCleared = false;
  String? _errorMessage;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _adminService.getGlobalStats();
      final breakdown = await _adminService.getUserBreakdown();
      
      setState(() {
        _stats = {
          ...stats,
          'breakdown': breakdown['breakdown'],
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _handleClearAllData() async {
    // Double confirmation pour cette action critique
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ CONFIRMATION CRITIQUE'),
        content: const Text(
          'Vous êtes sur le point de supprimer TOUTES les données de TOUS les utilisateurs.\n\n'
          'Cette action est IRRÉVERSIBLE.\n\n'
          'Voulez-vous vraiment continuer ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('OUI, TOUT SUPPRIMER'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _adminService.clearAllData();
      
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _dataCleared ? '🗑️ Base nettoyée !' : '🛠️ Administration - Nettoyage Global',
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
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoadingStats)
            const Center(child: CircularProgressIndicator())
          else if (_stats != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'État actuel de la base de données :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStatRow('👥 Utilisateurs total', _stats!['totalUsers']),
                  _buildStatRow('📋 Listes total', _stats!['totalLists']),
                  _buildStatRow('✅ Éléments total', _stats!['totalItems']),
                  _buildStatRow('📈 Habitudes total', _stats!['totalHabits']),
                  
                  if (_stats!['userEmails'] != null && (_stats!['userEmails'] as List).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Utilisateurs détectés :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...((_stats!['userEmails'] as List<String>).map((email) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text(
                          '• $email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      )
                    )),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        '⚠️ ZONE DE DANGER EXTRÊME',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🔥 Cette action supprimera TOUTES les données de TOUS les utilisateurs de la base de données Supabase.\n\n'
                    '💀 Cette action est IRRÉVERSIBLE.\n\n'
                    '🧹 Utilisez ceci uniquement pour remettre la base à zéro pour les tests.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value > 0 ? Colors.orange.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value > 0 ? Colors.orange.shade300 : Colors.green.shade300,
              ),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value > 0 ? Colors.orange.shade700 : Colors.green.shade700,
              ),
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
          Icons.delete_forever,
          size: 64,
          color: Colors.green.shade600,
        ),
        const SizedBox(height: 16),
        const Text(
          '🧹 Toutes les données ont été supprimées avec succès !',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'La base de données est maintenant vide et prête pour de nouveaux utilisateurs.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildFormActions() {
    final hasData = _stats != null && 
        (_stats!['totalUsers'] > 0 || _stats!['totalLists'] > 0 || 
         _stats!['totalItems'] > 0 || _stats!['totalHabits'] > 0);

    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Fermer'),
      ),
      if (hasData)
        ElevatedButton(
          onPressed: _isLoading ? null : _handleClearAllData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
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
            : const Text('🔥 TOUT SUPPRIMER'),
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