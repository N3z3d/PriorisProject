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
  final bool hideEloScores;
  final ValueChanged<DuelMode> onModeChanged;
  final ValueChanged<int> onCardsChanged;
  final Future<void> Function() onConfigureLists;
  final Future<void> Function() onToggleElo;

  const PriorityDuelSettingsBar({
    super.key,
    required this.mode,
    required this.cardsPerRound,
    required this.disableCardSelector,
    required this.hasAvailableLists,
    required this.hideEloScores,
    required this.onModeChanged,
    required this.onCardsChanged,
    required this.onConfigureLists,
    required this.onToggleElo,
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
              onPressed: () => onToggleElo(),
              tooltip: hideEloScores ? localized.duelShowElo : localized.duelHideElo,
              icon: Icon(
                hideEloScores
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
            ),
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
      spacing: 20,
      runSpacing: 20,
      children: [
        _DuelSetting(
          label: localized.duelModeLabel,
          child: _PremiumToggleButtons(
            mode: mode,
            onModeChanged: onModeChanged,
            localized: localized,
          ),
        ),
        _DuelSetting(
          label: localized.duelCardsPerRoundLabel,
          child: _PremiumCardSelector(
            cardsPerRound: cardsPerRound,
            disabled: disableCardSelector,
            onCardsChanged: onCardsChanged,
            localized: localized,
          ),
        ),
      ],
    );
  }
}

/// Premium toggle buttons with smooth animations and gradient effects
class _PremiumToggleButtons extends StatelessWidget {
  final DuelMode mode;
  final ValueChanged<DuelMode> onModeChanged;
  final AppLocalizations localized;

  const _PremiumToggleButtons({
    required this.mode,
    required this.onModeChanged,
    required this.localized,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: localized.duelModeWinner,
            icon: Icons.emoji_events_rounded,
            isSelected: mode == DuelMode.winner,
            onTap: () => onModeChanged(DuelMode.winner),
          ),
          const SizedBox(width: 4),
          _ToggleOption(
            label: localized.duelModeRanking,
            icon: Icons.format_list_numbered_rounded,
            isSelected: mode == DuelMode.ranking,
            onTap: () => onModeChanged(DuelMode.ranking),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ToggleOption> createState() => _ToggleOptionState();
}

class _ToggleOptionState extends State<_ToggleOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.9),
                    ],
                  )
                : null,
            color: widget.isSelected
                ? null
                : (_isHovered
                    ? AppTheme.grey200
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: widget.isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium card selector with visual card representations
class _PremiumCardSelector extends StatelessWidget {
  final int cardsPerRound;
  final bool disabled;
  final ValueChanged<int> onCardsChanged;
  final AppLocalizations localized;

  const _PremiumCardSelector({
    required this.cardsPerRound,
    required this.disabled,
    required this.onCardsChanged,
    required this.localized,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: disabled ? AppTheme.grey100.withValues(alpha: 0.5) : AppTheme.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [2, 3, 4]
            .map(
              (value) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _CardCountOption(
                  count: value,
                  isSelected: cardsPerRound == value,
                  isDisabled: disabled,
                  onTap: disabled ? null : () => onCardsChanged(value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CardCountOption extends StatefulWidget {
  final int count;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _CardCountOption({
    required this.count,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  State<_CardCountOption> createState() => _CardCountOptionState();
}

class _CardCountOptionState extends State<_CardCountOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected && !widget.isDisabled
                ? LinearGradient(
                    colors: [
                      AppTheme.accentColor,
                      AppTheme.accentColor.withValues(alpha: 0.9),
                    ],
                  )
                : null,
            color: widget.isSelected
                ? null
                : (_isHovered && !widget.isDisabled
                    ? AppTheme.grey200
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isSelected && !widget.isDisabled
                ? [
                    BoxShadow(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Visual representation of cards
              ...List.generate(
                widget.count,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.count - 1 ? 2 : 8,
                  ),
                  child: Container(
                    width: 8,
                    height: 12,
                    decoration: BoxDecoration(
                      color: widget.isSelected && !widget.isDisabled
                          ? Colors.white.withValues(alpha: 0.9)
                          : AppTheme.primaryColor.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: widget.isSelected && !widget.isDisabled
                            ? Colors.white
                            : AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                widget.count.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.isSelected && !widget.isDisabled
                          ? Colors.white
                          : (widget.isDisabled
                              ? AppTheme.textMuted
                              : AppTheme.textSecondary),
                    ),
              ),
            ],
          ),
        ),
      ),
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
