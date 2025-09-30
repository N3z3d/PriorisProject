import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/dialogs/bulk_add_dialog.dart';

/// Mode selection tabs component for BulkAddDialog
///
/// **SRP**: Only responsible for rendering mode tabs and notifying changes
/// **Size**: < 50 lines (constraint respected)
class BulkAddModeTabs extends StatelessWidget {
  final TabController? controller;
  final Function(BulkAddMode) onModeChanged;

  const BulkAddModeTabs({
    super.key,
    this.controller,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: controller,
        onTap: (index) => onModeChanged(BulkAddMode.values[index]),
        tabs: const [
          Tab(
            height: 36,
            child: Text('Un élément', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Tab(
            height: 36,
            child: Text('Plusieurs éléments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        indicator: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }
}