import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

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
              // Header simplifié
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    color: AppTheme.textSecondary,
                    splashRadius: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Onglets redesignés plus élégants
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      height: 36,
                      child: Text('Un élément', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    Tab(
                      height: 36,
                      child: Text('Plusieurs éléments', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Champ de saisie redesigné
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _focusNode.hasFocus 
                        ? AppTheme.primaryColor 
                        : AppTheme.surfaceColor.withValues(alpha: 0.5),
                    width: _focusNode.hasFocus ? 2 : 1,
                  ),
                  color: AppTheme.surfaceColor.withValues(alpha: 0.2),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: _currentMode == BulkAddMode.multiple ? 5 : 1,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  textInputAction: _currentMode == BulkAddMode.single 
                      ? TextInputAction.done 
                      : TextInputAction.newline,
                  onSubmitted: _currentMode == BulkAddMode.single 
                      ? (_) => _handleSubmit() 
                      : null,
                ),
              ),
              
              if (_currentMode == BulkAddMode.multiple) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Une nouvelle ligne = un nouvel élément',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Option "Garder ouvert"
              Row(
                children: [
                  Checkbox(
                    value: _keepOpen,
                    onChanged: (value) {
                      setState(() {
                        _keepOpen = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Garder ouvert après ajout',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Boutons d'action redesignés
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isValid ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid ? AppTheme.primaryColor : AppTheme.textSecondary.withValues(alpha: 0.3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _isValid ? 2 : 0,
                        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
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