import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Header widget for the list detail page.
///
/// Shows quick statistics about the list along with a progress indicator.
class ListDetailHeader extends StatelessWidget {
  final CustomList list;

  const ListDetailHeader({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor,
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: _buildListStats(),
    );
  }

  Widget _buildListStats() {
    final metrics = _ListProgressMetrics.fromList(list);

    return Column(
      children: [
        _buildHeader(metrics),
        const SizedBox(height: 16),
        _buildProgressBar(metrics.progress),
        const SizedBox(height: 8),
        _buildProgressLabel(metrics.progress),
      ],
    );
  }

  Widget _buildHeader(_ListProgressMetrics metrics) {
    return Row(
      children: [
        Icon(
          Icons.list_alt,
          color: AppTheme.primaryColor,
          size: 32,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                list.type.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metrics.completionLabel,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        CircularProgressIndicator(
          value: metrics.progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
          strokeWidth: 6,
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
      ),
    );
  }

  Widget _buildProgressLabel(double progress) {
    return Text(
      '${(progress * 100).toStringAsFixed(1)}% complete',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
    );
  }
}

class _ListProgressMetrics {
  final int completed;
  final int total;

  const _ListProgressMetrics({required this.completed, required this.total});

  double get progress => total > 0 ? completed / total : 0.0;

  String get completionLabel => '$completed of $total items done';

  factory _ListProgressMetrics.fromList(CustomList list) {
    final completedItems = list.items.where((item) => item.isCompleted).length;
    return _ListProgressMetrics(completed: completedItems, total: list.items.length);
  }
}
