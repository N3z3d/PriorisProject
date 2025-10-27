import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitsHeader extends StatelessWidget {
  const HabitsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildHeaderDecoration(),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 16),
              _buildTitleContent(),
            ],
          ),
        ),
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
            'Mes habitudes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Suivez vos progr\u00e8s au quotidien',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
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
}
