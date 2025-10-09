import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/services/focus_management_service.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final double? maxWidth;
  final FocusNode? focusNode;
  final VoidCallback? onClose;

  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.barrierDismissible = true,
    this.maxWidth,
    this.focusNode,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: FocusTraversalGroup(
        child: Focus(
          autofocus: true,
          focusNode: focusNode,
          onKeyEvent: (node, event) => _handleKeyEvent(context, event),
          child: _buildAlertDialog(context),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(BuildContext context, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape &&
        barrierDismissible) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Semantics(
        header: true,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      content: _buildContent(),
      actions: _buildActions(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusTokens.modal),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    );
  }

  Widget _buildContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 400),
      child: Semantics(
        container: true,
        child: content,
      ),
    );
  }

  List<Widget>? _buildActions() {
    if (actions == null) {
      return null;
    }
    return [
      Semantics(
        container: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions!,
        ),
      ),
    ];
  }

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    double? maxWidth,
    VoidCallback? onClose,
  }) {
    final focusService = FocusManagementService();
    final accessibilityService = AccessibilityService();

    focusService.savePreviousFocus(context);
    accessibilityService.announceToScreenReader('Dialog ouvert: $title');

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      builder: (ctx) => CommonDialog(
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
        maxWidth: maxWidth,
        onClose: onClose,
      ),
    ).then((result) {
      focusService.restorePreviousFocus();
      accessibilityService.announceToScreenReader('Dialog ferme');
      if (onClose != null) {
        onClose();
      }
      return result;
    });
  }
}
