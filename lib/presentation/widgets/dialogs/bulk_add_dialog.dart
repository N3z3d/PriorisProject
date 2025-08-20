import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';

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
      backgroundColor: Colors.transparent,
      child: Glassmorphism.glassCard(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header avec titre
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Onglets pour choisir le mode
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Simple'),
                    Tab(text: 'Multiple'),
                  ],
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Champ de saisie
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: _currentMode == BulkAddMode.multiple ? 6 : 1,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor.withValues(alpha: 0.3),
                ),
                textInputAction: _currentMode == BulkAddMode.single 
                    ? TextInputAction.done 
                    : TextInputAction.newline,
                onSubmitted: _currentMode == BulkAddMode.single 
                    ? (_) => _handleSubmit() 
                    : null,
              ),
              
              if (_currentMode == BulkAddMode.multiple) ...[
                const SizedBox(height: 8),
                Text(
                  'Séparez chaque élément par une nouvelle ligne',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
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
              
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isValid ? _handleSubmit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ajouter',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
        return 'Ex: Terminer rapport projet';
      case BulkAddMode.multiple:
        return '''Ex: Terminer rapport projet
Préparer présentation client
Réviser documentation technique''';
    }
  }
}