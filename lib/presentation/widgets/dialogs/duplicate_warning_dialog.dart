import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';

enum DuplicateChoice { cancel, skipDuplicates, addAll }

class DuplicateWarningDialog extends StatelessWidget {
  final List<String> duplicateTitles;
  final int totalCount;

  const DuplicateWarningDialog({
    super.key,
    required this.duplicateTitles,
    required this.totalCount,
  })  : assert(duplicateTitles.length > 0, 'duplicateTitles must not be empty'),
        assert(
          duplicateTitles.length <= totalCount,
          'duplicateTitles.length must not exceed totalCount',
        );

  int get _uniqueCount => totalCount - duplicateTitles.length;
  bool get _isSingleAdd => totalCount == 1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.duplicateWarningTitle),
      content: _buildContent(l10n),
      actions: _buildActions(context, l10n),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_isSingleAdd) {
      return Text(l10n.duplicateWarningSingle(duplicateTitles.first));
    }
    return Text(
      l10n.duplicateWarningMultiple(duplicateTitles.length, totalCount),
    );
  }

  List<Widget> _buildActions(BuildContext context, AppLocalizations l10n) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(DuplicateChoice.cancel),
        child: Text(l10n.cancel),
      ),
      if (!_isSingleAdd && _uniqueCount > 0)
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DuplicateChoice.skipDuplicates),
          child: Text(l10n.duplicateWarningSkipAction(_uniqueCount)),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(DuplicateChoice.addAll),
        child: Text(
          _isSingleAdd
              ? l10n.duplicateWarningAddAllSingle
              : l10n.duplicateWarningAddAllBulk(totalCount),
        ),
      ),
    ];
  }
}
