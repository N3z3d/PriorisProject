import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/pages/agents_monitoring_page.dart';
import 'package:prioris/presentation/widgets/dialogs/clear_data_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdvancedSection(context),
          const SizedBox(height: 16),
          _buildDataSection(context),
          const SizedBox(height: 16),
          _buildGeneralSection(),
          const SizedBox(height: 16),
          _buildAboutSection(),
        ],
      ),
    );
  }

  /// Construit la barre d'application
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.cardColor,
      elevation: 0,
      title: const Text(
        'Paramètres',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }

  /// Construit la section avancée
  Widget _buildAdvancedSection(BuildContext context) {
    return _buildSection(
      title: 'Avancé',
      children: [
        _buildSettingTile(
          icon: Icons.monitor_heart_outlined,
          title: 'Monitoring des Agents',
          subtitle: 'Surveillance et gestion des agents IA',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AgentsMonitoringPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Construit la section données et synchronisation
  Widget _buildDataSection(BuildContext context) {
    return _buildSection(
      title: 'Données et synchronisation',
      children: [
        _buildSettingTile(
          icon: Icons.sync_outlined,
          title: 'État de synchronisation',
          subtitle: 'Voir où sont stockées vos données',
          onTap: () => _showDevelopmentSnackBar(context),
        ),
        _buildSettingTile(
          icon: Icons.backup_outlined,
          title: 'Sauvegarde et export',
          subtitle: 'Exporter et importer vos données',
          onTap: () => _showDevelopmentSnackBar(context),
        ),
        _buildSettingTile(
          icon: Icons.storage_outlined,
          title: 'Gestion du stockage',
          subtitle: 'Contrôler où vos données sont sauvegardées',
          onTap: () => _showDevelopmentSnackBar(context),
        ),
        _buildSettingTile(
          icon: Icons.delete_sweep_outlined,
          title: 'Nettoyer les données',
          subtitle: 'Supprimer toutes vos données personnelles',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ClearDataDialog(),
            );
          },
          isDestructive: true,
        ),
      ],
    );
  }

  /// Construit la section générale
  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'Général',
      children: [
        _buildSettingTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Gérer les notifications',
          onTap: () {},
        ),
        _buildSettingTile(
          icon: Icons.palette_outlined,
          title: 'Thème',
          subtitle: 'Personnaliser l\'apparence',
          onTap: () {},
        ),
      ],
    );
  }

  /// Construit la section à propos
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'À propos',
      children: [
        _buildSettingTile(
          icon: Icons.info_outlined,
          title: 'Version',
          subtitle: '1.0.0',
          onTap: () {},
        ),
        _buildSettingTile(
          icon: Icons.help_outlined,
          title: 'Aide',
          subtitle: 'Centre d\'aide et support',
          onTap: () {},
        ),
      ],
    );
  }

  /// Affiche un SnackBar pour les fonctionnalités en développement
  void _showDevelopmentSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Page en cours de développement')),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadiusTokens.card,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive 
            ? Colors.red.withValues(alpha: 0.1)
            : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadiusTokens.button,
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textTertiary,
      ),
      onTap: onTap,
    );
  }
}