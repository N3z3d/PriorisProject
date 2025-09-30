import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'components/bulk_add_header.dart';
import 'components/bulk_add_mode_tabs.dart';
import 'components/bulk_add_text_field.dart';
import 'components/bulk_add_help_message.dart';
import 'components/bulk_add_keep_open_option.dart';
import 'components/bulk_add_action_buttons.dart';

/// Mode d'ajout en lot
enum BulkAddMode {
  single,
  multiple,
}

/// Dialogue pour ajouter plusieurs éléments à une liste
/// 
/// Permet d'ajouter des éléments soit:
/// - Un par un (mode simple)
/// - Plusieurs à la fois (mode multiple, séparés par des retours à la ligne)
class BulkAddDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(List<String>) onSubmit;

  const BulkAddDialog({
    super.key,
    this.title = 'Ajouter des éléments',
    this.hintText = '',
    required this.onSubmit,
  });

  factory BulkAddDialog.create({
    String title = 'Ajouter des éléments',
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
    
    // Focus automatique sur le champ
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
    if (!_isValid) return;

    final text = _controller.text.trim();
    final items = _currentMode == BulkAddMode.multiple
        ? text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [text];

    if (items.isNotEmpty) {
      widget.onSubmit(items);
      
      if (_keepOpen) {
        _controller.clear();
        _focusNode.requestFocus();
      } else {
        Navigator.of(context).pop();
      }
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            BulkAddHeader(
              title: widget.title,
              onClose: () => Navigator.of(context).pop(),
            ),

            const SizedBox(height: 20),

            // Mode tabs
            BulkAddModeTabs(
              controller: _tabController,
              onModeChanged: (mode) => setState(() => _currentMode = mode),
            ),

            const SizedBox(height: 20),

            // Text field
            BulkAddTextField(
              controller: _controller,
              focusNode: _focusNode,
              mode: _currentMode,
              hintText: _getHintText(),
              onSubmitted: (_) => _handleSubmit(),
            ),

            // Help message for multiple mode
            if (_currentMode == BulkAddMode.multiple) ...[
              const SizedBox(height: 12),
              const BulkAddHelpMessage(
                message: 'Une nouvelle ligne = un nouvel élément',
              ),
            ],

            const SizedBox(height: 20),

            // Keep open option
            BulkAddKeepOpenOption(
              value: _keepOpen,
              onChanged: (value) => setState(() => _keepOpen = value ?? false),
            ),

            const SizedBox(height: 20),

            // Action buttons
            BulkAddActionButtons(
              isValid: _isValid,
              onCancel: () => Navigator.of(context).pop(),
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne le texte d'aide selon le mode et contexte
  String _getHintText() {
    if (widget.hintText.isNotEmpty) {
      return widget.hintText;
    }
    
    switch (_currentMode) {
      case BulkAddMode.single:
        return 'Ajouter un élément...';
      case BulkAddMode.multiple:
        return 'Ajouter plusieurs éléments (un par ligne)...';
    }
  }
}