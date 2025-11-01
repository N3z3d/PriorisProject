import 'package:flutter/material.dart';
import 'package:prioris/domain/core/value_objects/duel_settings.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class PriorityDuelActionBar extends StatelessWidget {
  final DuelMode mode;
  final Future<void> Function() onSubmitRanking;

  const PriorityDuelActionBar({
    super.key,
    required this.mode,
    required this.onSubmitRanking,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = _buildButtons(context);
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

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
    final buttons = <Widget>[];

    if (mode == DuelMode.ranking) {
      buttons.add(
        _PremiumSubmitButton(
          onPressed: () => onSubmitRanking(),
          label: localized.duelSubmitRanking,
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

/// Premium Submit button with gradient background and enhanced styling
class _PremiumSubmitButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const _PremiumSubmitButton({
    required this.onPressed,
    required this.label,
  });

  @override
  State<_PremiumSubmitButton> createState() => _PremiumSubmitButtonState();
}

class _PremiumSubmitButtonState extends State<_PremiumSubmitButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: _isHovered ? 0.4 : 0.25),
              blurRadius: _isHovered ? 16 : 12,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


