import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/presentation/pages/lists/widgets/components/list_type_style_helper.dart';

/// Progress bar component for list card
///
/// Displays visual progress indicator for list completion.
class ListCardProgress extends StatelessWidget {
  final ListType listType;
  final double progress;

  const ListCardProgress({
    super.key,
    required this.listType,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation<Color>(
        ListTypeStyleHelper.getColorForType(listType),
      ),
    );
  }
}
