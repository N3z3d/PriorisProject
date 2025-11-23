import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'components/bulk_add_header.dart';
import 'components/bulk_add_mode_tabs.dart';
import 'components/bulk_add_text_field.dart';
import 'components/bulk_add_help_message.dart';
import 'components/bulk_add_keep_open_option.dart';
import 'components/bulk_add_action_buttons.dart';

enum BulkAddMode {
  single,
  multiple,
}

class BulkAddDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(List<String>) onSubmit;

  const BulkAddDialog({
    super.key,
    this.title = '',
    this.hintText = '',
    required this.onSubmit,
  });

  factory BulkAddDialog.create({
    String title = '',
    required Function(List<String>) onItemsAdded,
  }) {
    return BulkAddDialog(
      title: title,
      onSubmit: onItemsAdded,
    );
  }

  @override
  State<BulkAddDialog> createState() => _BulkAddDialogState();
}

class _BulkAddDialogState extends State<BulkAddDialog> with TickerProviderStateMixin {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;
  BulkAddMode _currentMode = BulkAddMode.single;
  bool _keepOpen = false;
  bool _isSubmitting = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_validateInput);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentMode = BulkAddMode.values[_tabController.index];
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSubmit() {
    if (!_isValid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final text = _controller.text.trim();
    final items = _currentMode == BulkAddMode.multiple
        ? text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [text];

    if (items.isEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    widget.onSubmit(items);

    if (_keepOpen) {
      _controller.clear();
      _focusNode.requestFocus();
      // Reset submitting flag after short delay to prevent rapid re-submissions
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _buildDialogChildren(context),
      ),
    );
  }

  List<Widget> _buildDialogChildren(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dialogTitle = widget.title.isEmpty ? l10n.bulkAddDefaultTitle : widget.title;

    return [
      BulkAddHeader(
        title: dialogTitle,
        onClose: _isSubmitting ? null : () => Navigator.of(context).pop(),
      ),
      const SizedBox(height: 20),
      BulkAddModeTabs(
        controller: _tabController,
        onModeChanged: (mode) => setState(() => _currentMode = mode),
      ),
      const SizedBox(height: 20),
      BulkAddTextField(
        controller: _controller,
        focusNode: _focusNode,
        mode: _currentMode,
        hintText: _getHintText(context),
        onSubmitted: (_) => _handleSubmit(),
        enabled: !_isSubmitting,
      ),
      ..._buildHelpSection(context),
      const SizedBox(height: 20),
      if (_isSubmitting) ...[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.bulkAddSubmitting,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      BulkAddKeepOpenOption(
        value: _keepOpen,
        onChanged: _isSubmitting ? null : (value) => setState(() => _keepOpen = value ?? false),
      ),
      const SizedBox(height: 20),
      BulkAddActionButtons(
        isValid: _isValid && !_isSubmitting,
        isSubmitting: _isSubmitting,
        onCancel: _isSubmitting ? null : () => Navigator.of(context).pop(),
        onSubmit: _handleSubmit,
      ),
    ];
  }

  List<Widget> _buildHelpSection(BuildContext context) {
    if (_currentMode != BulkAddMode.multiple) {
      return const [SizedBox.shrink()];
    }
    final l10n = AppLocalizations.of(context)!;
    return [
      const SizedBox(height: 12),
      BulkAddHelpMessage(message: l10n.bulkAddHelpText),
    ];
  }

  String _getHintText(BuildContext context) {
    if (widget.hintText.isNotEmpty) {
      return widget.hintText;
    }

    final l10n = AppLocalizations.of(context)!;
    switch (_currentMode) {
      case BulkAddMode.single:
        return l10n.bulkAddSingleHint;
      case BulkAddMode.multiple:
        return l10n.bulkAddMultipleHint;
    }
  }
}
