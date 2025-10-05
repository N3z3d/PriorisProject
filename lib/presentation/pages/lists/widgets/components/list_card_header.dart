import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/lists/widgets/components/list_type_style_helper.dart';

/// Header component for list card
///
/// Displays the list icon, name, and optional description.
class ListCardHeader extends StatelessWidget {
  final CustomList list;

  const ListCardHeader({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          ListTypeStyleHelper.getIconForType(list.type),
          color: ListTypeStyleHelper.getColorForType(list.type),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                list.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (list.description?.isNotEmpty == true)
                Text(
                  list.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
