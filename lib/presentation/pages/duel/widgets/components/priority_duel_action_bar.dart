import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class PriorityDuelActionBar extends StatelessWidget {
  final bool hideEloScores;
  final DuelMode mode;
  final Future<void> Function() onSkip;
  final Future<void> Function() onRandom;
  final Future<void> Function() onToggleElo;
  final Future<void> Function() onSubmitRanking;

  const PriorityDuelActionBar({
    super.key,
    required this.hideEloScores,
    required this.mode,
    required this.onSkip,
    required this.onRandom,
    required this.onToggleElo,
    required this.onSubmitRanking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 28,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.7),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttons = _buildButtons(context);
          final isVertical = constraints.maxWidth < 520;
          if (isVertical) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: _withSpacing(buttons, const SizedBox(height: 12)),
            );
          }
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: buttons,
          );
        },
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final localized = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final buttons = <Widget>[
      TextButton(
        onPressed: () => onSkip(),
        child: Text(localized.duelSkipAction),
      ),
      OutlinedButton.icon(
        onPressed: () => onRandom(),
        icon: const Icon(Icons.shuffle_rounded, size: 20),
        label: Text(localized.duelRandomAction),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
        ),
      ),
      TextButton.icon(
        onPressed: () => onToggleElo(),
        icon: Icon(
          hideEloScores
              ? Icons.visibility_rounded
              : Icons.visibility_off_rounded,
        ),
        label: Text(
          hideEloScores ? localized.duelShowElo : localized.duelHideElo,
        ),
      ),
    ];

    if (mode == DuelMode.ranking) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => onSubmitRanking(),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(localized.duelSubmitRanking),
        ),
      );
    }

    return buttons;
  }

  List<Widget> _withSpacing(List<Widget> children, Widget spacer) {
    final result = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      result.add(children[index]);
      if (index < children.length - 1) {
        result.add(spacer);
      }
    }
    return result;
  }
}
