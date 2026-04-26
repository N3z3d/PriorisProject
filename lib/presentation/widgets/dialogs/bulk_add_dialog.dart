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

/// Exception signalant une annulation volontaire — ne doit pas afficher d'erreur UI.
/// Étendre cette classe depuis le site d'appel pour propager le signal d'annulation.
class BulkAddCancelException implements Exception {}

/// Callback d'ajout en lot — async, reçoit les titres et un rapporteur de progression.
typedef BulkAddOnSubmit = Future<void> Function(
  List<String> items,
  void Function(int current, int total) onProgress,
);

class BulkAddDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final BulkAddOnSubmit onSubmit;

  const BulkAddDialog({
    super.key,
    this.title = '',
    this.hintText = '',
    required this.onSubmit,
  });

  factory BulkAddDialog.create({
    String title = '',
    required BulkAddOnSubmit onItemsAdded,
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
  int _processedCount = 0;
  int _totalCount = 0;
  String? _submitError;
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

  Future<void> _handleSubmit() async {
    if (!_isValid || _isSubmitting) return;

    final text = _controller.text.trim();
    final items = _currentMode == BulkAddMode.multiple
        ? text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [text];

    if (items.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _processedCount = 0;
      _totalCount = items.length;
      _submitError = null;
    });

    try {
      final submitFuture = widget.onSubmit(items, (current, total) {
        if (mounted) setState(() { _processedCount = current; _totalCount = total; });
      });

      if (_keepOpen) {
        // Keep-open mode: await both completion AND 300ms debounce to protect against rapid re-submit
        await Future.wait([
          submitFuture,
          Future.delayed(const Duration(milliseconds: 300)),
        ]);
        if (mounted) {
          setState(() { _isSubmitting = false; _processedCount = 0; _totalCount = 0; });
          _controller.clear();
          _focusNode.requestFocus();
        }
      } else {
        await submitFuture;
        if (mounted) {
          Navigator.of(context).pop(_processedCount > 0 ? _processedCount : items.length);
        }
      }
    } on BulkAddCancelException {
      if (mounted) setState(() { _isSubmitting = false; _submitError = null; });
    } catch (e) {
      if (mounted) setState(() { _isSubmitting = false; _submitError = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildDialogChildren(context),
        ),
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
      if (_isSubmitting) _buildProgressSection(l10n),
      if (_submitError != null) _buildErrorSection(l10n),
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

  Widget _buildProgressSection(AppLocalizations l10n) {
    final hasProgress = _processedCount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: hasProgress ? _processedCount / _totalCount : null,
            backgroundColor: AppTheme.surfaceColor,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              hasProgress
                  ? '$_processedCount / $_totalCount'
                  : l10n.bulkAddSubmitting,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(AppLocalizations l10n) {
    final partialInfo = _processedCount > 0
        ? ' — ${l10n.bulkAddImportSuccess(_processedCount)}'
        : '';
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        '${l10n.bulkAddImportError}$partialInfo',
        style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
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
