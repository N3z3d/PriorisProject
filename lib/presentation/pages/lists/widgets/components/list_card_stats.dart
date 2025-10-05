import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/lists/widgets/components/list_type_style_helper.dart';

/// Statistics component for list card
///
/// Displays item count and completion percentage.
class ListCardStats extends StatelessWidget {
  final CustomList list;
  final int completedCount;
  final int totalCount;
  final double progress;

  const ListCardStats({
    super.key,
    required this.list,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$totalCount ${totalCount <= 1 ? 'élément' : 'éléments'}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        if (totalCount > 0)
          Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: ListTypeStyleHelper.getColorForType(list.type),
            ),
          ),
      ],
    );
  }
}
