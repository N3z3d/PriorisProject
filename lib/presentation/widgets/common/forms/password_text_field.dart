import 'package:flutter/material.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';

/// Widget TextField spécialisé pour les mots de passe avec bouton œil
class PasswordTextField extends StatefulWidget {
  /// Label du champ
  final String? label;

  /// Texte d'aide (hint)
  final String? hint;

  /// Contrôleur du champ
  final TextEditingController? controller;

  /// Fonction de validation
  final String? Function(String?)? validator;

  /// Champ requis
  final bool required;

  /// Callback lors d'un changement de texte
  final ValueChanged<String?>? onChanged;

  /// Callback lors de la validation
  final ValueChanged<String?>? onSubmitted;

  /// Message d'erreur actuel
  final String? errorText;

  /// FocusNode personnalisé
  final FocusNode? focusNode;

  /// Actions du clavier
  final TextInputAction? textInputAction;

  /// Couleur de base pour l'icône d'affichage
  final Color toggleColor;

  /// Constructeur
  const PasswordTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.required = false,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.toggleColor = Colors.grey,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      required: widget.required,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      errorText: widget.errorText,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      suffix: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: tone(widget.toggleColor, level: 600),
          semanticLabel: _obscureText ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
        ),
        onPressed: _toggleVisibility,
        tooltip: _obscureText ? 'Afficher le mot de passe' : 'Masquer le mot de passe',
      ),
    );
  }
}
