import 'package:flutter/material.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';

/// Widget TextField réutilisable pour toute l'application
class CommonTextField extends StatelessWidget {
  /// Clé appliquée directement au champ de saisie interne.
  final Key? fieldKey;

  /// Label du champ
  final String? label;

  /// Texte d'aide (hint)
  final String? hint;

  /// Contrôleur du champ
  final TextEditingController? controller;

  /// Fonction de validation
  final String? Function(String?)? validator;

  /// Type de clavier
  final TextInputType? keyboardType;

  /// Masquer le texte (mot de passe)
  final bool obscureText;

  /// Widget suffixe (icône, bouton...)
  final Widget? suffix;

  /// Widget préfixe (icône, bouton...)
  final Widget? prefix;

  /// Nombre maximum de lignes
  final int? maxLines;

  /// Nombre maximum de caractères
  final int? maxLength;

  /// Champ requis
  final bool required;

  /// Couleur de bordure
  final Color? borderColor;

  /// Couleur de bordure en focus
  final Color? focusedBorderColor;

  /// Couleur de bordure en erreur
  final Color? errorBorderColor;

  /// Rayon de bordure
  final BorderRadius? borderRadius;

  /// Padding interne
  final EdgeInsetsGeometry? contentPadding;

  /// Callback lors d'un changement de texte
  final ValueChanged<String?>? onChanged;

  /// Callback lors de la validation
  final ValueChanged<String?>? onSubmitted;

  /// Message d'erreur actuel
  final String? errorText;

  /// Indique si le champ est en lecture seule
  final bool readOnly;

  /// FocusNode personnalisé
  final FocusNode? focusNode;

  /// Actions du clavier
  final TextInputAction? textInputAction;

  /// Constructeur
  const CommonTextField({
    super.key,
    this.fieldKey,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.maxLength,
    this.required = false,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final decoration = _buildInputDecoration(hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          _TextFieldLabel(label: label!, required: required),
        _buildTextFormField(decoration),
        if (hasError)
          _TextFieldErrorMessage(errorText: errorText!),
        if (maxLength != null)
          _TextFieldCharacterCounter(
            currentLength: controller?.text.length ?? 0,
            maxLength: maxLength!,
          ),
      ],
    );
  }

  /// Construit le TextFormField avec sa configuration
  Widget _buildTextFormField(InputDecoration decoration) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: controller?.text,
      enabled: !readOnly,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AccessibilityService.minTouchTargetSize,
        ),
        child: TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          decoration: decoration,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          textInputAction: textInputAction ?? TextInputAction.next,
          autofocus: false,
          enableInteractiveSelection: true,
          autocorrect: keyboardType != TextInputType.emailAddress,
          enableSuggestions: keyboardType == TextInputType.text,
          textCapitalization: _getTextCapitalization(),
        ),
      ),
    );
  }

  /// Construit la décoration du champ de texte
  InputDecoration _buildInputDecoration(bool hasError) {
    return InputDecoration(
      hintText: hint,
      errorText: hasError ? errorText : null,
      border: _buildBorder(hasError, isEnabled: true, isFocused: false),
      enabledBorder: _buildBorder(hasError, isEnabled: true, isFocused: false),
      focusedBorder: _buildBorder(hasError, isEnabled: true, isFocused: true),
      errorBorder: _buildBorder(hasError, isEnabled: false, isFocused: false),
      focusedErrorBorder: _buildBorder(hasError, isEnabled: false, isFocused: true),
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
      prefixIcon: prefix,
      suffixIcon: suffix,
      semanticCounterText: maxLength != null ? 'Maximum $maxLength caractères' : null,
    );
  }

  /// Construit une bordure selon l'état du champ
  OutlineInputBorder _buildBorder(bool hasError, {required bool isEnabled, required bool isFocused}) {
    return OutlineInputBorder(
      borderRadius: borderRadius ?? BorderRadiusTokens.input,
      borderSide: BorderSide(
        color: _getBorderColor(hasError, isEnabled, isFocused),
        width: isFocused ? 3 : (hasError && !isEnabled ? 2 : 1),
      ),
    );
  }

  /// Détermine la couleur de bordure selon l'état
  Color _getBorderColor(bool hasError, bool isEnabled, bool isFocused) {
    if (hasError) {
      return errorBorderColor ?? AppTheme.errorColor;
    }
    if (isFocused && isEnabled) {
      return focusedBorderColor ?? AppTheme.primaryColor;
    }
    return borderColor ?? tone(Colors.grey, level: 300);
  }

  /// Détermine la capitalisation du texte
  TextCapitalization _getTextCapitalization() {
    return keyboardType == TextInputType.emailAddress
        ? TextCapitalization.none
        : TextCapitalization.sentences;
  }
}

/// Widget privé pour afficher le label du champ
class _TextFieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _TextFieldLabel({
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        label: required ? '$label, champ obligatoire' : label,
        child: Text(
          required ? '$label *' : label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Widget privé pour afficher le message d'erreur
class _TextFieldErrorMessage extends StatelessWidget {
  final String errorText;

  const _TextFieldErrorMessage({
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Semantics(
        liveRegion: true,
        child: Text(
          errorText,
          style: const TextStyle(
            color: AppTheme.errorColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Widget privé pour afficher le compteur de caractères
class _TextFieldCharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const _TextFieldCharacterCounter({
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Semantics(
        liveRegion: true,
        child: Text(
          '$currentLength/$maxLength caractères',
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
          textAlign: TextAlign.end,
        ),
      ),
    );
  }
}
