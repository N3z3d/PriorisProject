import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Header component for Habits page following SRP
/// Responsible only for rendering the header UI
class HabitsHeader extends StatelessWidget {
  final TabController tabController;

  const HabitsHeader({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildHeaderDecoration(),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTitleSection(),
            _buildTabSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 16),
          _buildTitleContent(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.psychology_outlined,
        color: AppTheme.primaryColor,
        size: 24,
      ),
    );
  }

  Widget _buildTitleContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes Habitudes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Construisez votre meilleure version',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: _buildTabDecoration(),
      child: TabBar(
        controller: tabController,
        indicator: _buildTabIndicator(),
        indicatorPadding: const EdgeInsets.all(2),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.play_circle_outline, size: 20),
            text: 'Actives',
          ),
          Tab(
            icon: Icon(Icons.check_circle_outline, size: 20),
            text: 'Complétées',
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      color: AppTheme.subtleBackgroundColor,
      border: const Border(
        bottom: BorderSide(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  BoxDecoration _buildTabDecoration() {
    return BoxDecoration(
      color: AppTheme.cleanSurfaceColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.grey200,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration _buildTabIndicator() {
    return BoxDecoration(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
