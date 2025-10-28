import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/headers/page_header.dart';

class PriorityDuelSettingsBar extends StatelessWidget {
  final DuelMode mode;
  final int cardsPerRound;
  final bool disableCardSelector;
  final bool hasAvailableLists;
  final ValueChanged<DuelMode> onModeChanged;
  final ValueChanged<int> onCardsChanged;
  final Future<void> Function() onConfigureLists;

  const PriorityDuelSettingsBar({
    super.key,
    required this.mode,
    required this.cardsPerRound,
    required this.disableCardSelector,
    required this.hasAvailableLists,
    required this.onModeChanged,
    required this.onCardsChanged,
    required this.onConfigureLists,
  });

  @override
  Widget build(BuildContext context) {
    final localized = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: localized.duelPriorityTitle,
          subtitle: localized.duelPrioritySubtitle,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: hasAvailableLists ? () => onConfigureLists() : null,
              tooltip: hasAvailableLists
                  ? localized.duelConfigureLists
                  : localized.duelNoAvailableLists,
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        _HeaderHint(text: localized.duelPriorityHint),
        const SizedBox(height: 16),
        _SettingsWrap(
          mode: mode,
          cardsPerRound: cardsPerRound,
          disableCardSelector: disableCardSelector,
          onModeChanged: onModeChanged,
          onCardsChanged: onCardsChanged,
        ),
        const SizedBox(height: 16),
        const _HeaderDivider(),
      ],
    );
  }
}

class _HeaderHint extends StatelessWidget {
  final String text;

  const _HeaderHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.9),
            letterSpacing: 0.1,
          ),
    );
  }
}

class _SettingsWrap extends StatelessWidget {
  final DuelMode mode;
  final int cardsPerRound;
  final bool disableCardSelector;
  final ValueChanged<DuelMode> onModeChanged;
  final ValueChanged<int> onCardsChanged;

  const _SettingsWrap({
    required this.mode,
    required this.cardsPerRound,
    required this.disableCardSelector,
    required this.onModeChanged,
    required this.onCardsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localized = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        _DuelSetting(
          label: localized.duelModeLabel,
          child: ToggleButtons(
            isSelected: [
              mode == DuelMode.winner,
              mode == DuelMode.ranking,
            ],
            onPressed: (index) {
              final selected = index == 0 ? DuelMode.winner : DuelMode.ranking;
              onModeChanged(selected);
            },
            borderRadius: BorderRadius.circular(20),
            constraints: const BoxConstraints(minHeight: 40, minWidth: 140),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(localized.duelModeWinner),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(localized.duelModeRanking),
              ),
            ],
          ),
        ),
        _DuelSetting(
          label: localized.duelCardsPerRoundLabel,
          child: DropdownButton<int>(
            value: cardsPerRound,
            onChanged: disableCardSelector
                ? null
                : (value) {
                    if (value != null) {
                      onCardsChanged(value);
                    }
                  },
            items: const [2, 3, 4]
                .map(
                  (value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(localized.duelCardsPerRoundOption(value)),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: 160,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _DuelSetting extends StatelessWidget {
  final String label;
  final Widget child;

  const _DuelSetting({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
