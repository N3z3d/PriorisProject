import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/theme/glassmorphism.dart';

/// Mode d'ajout en masse
enum BulkAddMode {
  single,     // Ajout simple avec possibilité de continuer
  multiline,  // Ajout par lignes multiples
}

/// Dialog pour ajout en masse d'éléments avec design glassmorphisme
class BulkAddDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(List<String>) onSubmit;
  
  const BulkAddDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.onSubmit,
  });

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

  void _validateInput() {
    setState(() {
      _isValid = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_isValid) return;

    final text = _controller.text.trim();
    List<String> items = [];

    switch (_currentMode) {
      case BulkAddMode.single:
        items = [text];
        break;
      case BulkAddMode.multiline:
        items = _parseMultilineText(text);
        break;
    }

    // Filtrer les éléments vides
    items = items.where((item) => item.isNotEmpty).toList();
    
    if (items.isNotEmpty) {
      widget.onSubmit(items);
      
      if (_currentMode == BulkAddMode.single && _keepOpen) {
        // Mode ajout rapide successif
        _controller.clear();
        _focusNode.requestFocus();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  List<String> _parseMultilineText(String text) {
    // Analyser le texte pour détecter différents formats
    final lines = text.split('\n');
    List<String> items = [];

    for (String line in lines) {
      String cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;

      // Supprimer les puces communes
      cleanLine = cleanLine.replaceFirst(RegExp(r'^[-•*]\s*'), '');
      cleanLine = cleanLine.replaceFirst(RegExp(r'^\d+\.\s*'), '');
      
      items.add(cleanLine);
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Glassmorphism.glassCard(
        borderRadius: BorderRadiusTokens.modal,
        blur: 20.0,
        opacity: 0.15,
        width: MediaQuery.of(context).size.width * 0.9,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTabs(),
              Expanded(
                child: _buildContent(),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (_currentMode == BulkAddMode.single)
            _buildKeepOpenToggle(),
        ],
      ),
    );
  }

  Widget _buildKeepOpenToggle() {
    return Glassmorphism.glassCard(
      blur: 10.0,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadiusTokens.radiusMd,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ajout rapide',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: _keepOpen,
            onChanged: (value) => setState(() => _keepOpen = value),
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Glassmorphism.glassCard(
      blur: 8.0,
      opacity: 0.08,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.add_circle_outline),
            text: 'Simple',
          ),
          Tab(
            icon: Icon(Icons.format_list_bulleted),
            text: 'Multiple',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildSingleAddMode(),
          _buildMultilineMode(),
        ],
      ),
    );
  }

  Widget _buildSingleAddMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _keepOpen 
            ? 'Ajout rapide successif - Le dialogue reste ouvert après chaque ajout'
            : 'Ajout d\'un seul élément',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Glassmorphism.glassCard(
          blur: 6.0,
          opacity: 0.05,
          borderRadius: BorderRadiusTokens.input,
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
              border: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadiusTokens.input,
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: AppTheme.textSecondary,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
      ],
    );
  }

  Widget _buildMultilineMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajout multiple - Une ligne = un élément\nSupporte les puces (-, •, *) et numérotation',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Glassmorphism.glassCard(
            blur: 6.0,
            opacity: 0.05,
            borderRadius: BorderRadiusTokens.input,
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Pain\nLait\nŒufs\n...',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadiusTokens.input,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.all(16),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Glassmorphism.glassCard(
          blur: 4.0,
          opacity: 0.03,
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadiusTokens.radiusSm,
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.accentSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Astuce: Collez du texte depuis n\'importe où, les puces seront supprimées automatiquement',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildCancelButton(),
          const SizedBox(width: 12),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Glassmorphism.glassButton(
      onPressed: _handleCancel,
      color: AppTheme.textSecondary,
      blur: 8.0,
      opacity: 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      borderRadius: BorderRadiusTokens.button,
      child: const Text(
        'Annuler',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _isValid;
    
    return Glassmorphism.glassButton(
      onPressed: isEnabled ? _handleSubmit : _handleDisabledSubmit,
      color: isEnabled ? AppTheme.primaryColor : AppTheme.textSecondary.withValues(alpha: 0.3),
      blur: 12.0,
      opacity: isEnabled ? 0.9 : 0.1,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      borderRadius: BorderRadiusTokens.button,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCurrentActionIcon(),
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            _getCurrentActionText(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDisabledSubmit() {
    // Ne rien faire si le bouton est désactivé
  }

  IconData _getCurrentActionIcon() {
    switch (_currentMode) {
      case BulkAddMode.single:
        return _keepOpen ? Icons.add_circle : Icons.add;
      case BulkAddMode.multiline:
        return Icons.playlist_add;
    }
  }

  String _getCurrentActionText() {
    switch (_currentMode) {
      case BulkAddMode.single:
        return _keepOpen ? 'Ajouter et continuer' : 'Ajouter';
      case BulkAddMode.multiline:
        return 'Ajouter tout';
    }
  }
}