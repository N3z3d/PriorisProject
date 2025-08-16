import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/domain/services/ui/accessibility_service.dart';

/// Widget TextField réutilisable pour toute l'application
class CommonTextField extends StatelessWidget {
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
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              label: required ? '$label, champ obligatoire' : label,
              child: Text(
                required ? '$label *' : label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        Semantics(
          textField: true,
          label: label,
          hint: hint,
          value: controller?.text,
          enabled: !readOnly,
          child: Container(
            constraints: BoxConstraints(
              minHeight: AccessibilityService.minTouchTargetSize,
            ),
            child: TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hint,
                errorText: hasError ? errorText : null,
                border: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: hasError 
                        ? (errorBorderColor ?? AppTheme.errorColor)
                        : (borderColor ?? Colors.grey.shade300),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: hasError 
                        ? (errorBorderColor ?? AppTheme.errorColor)
                        : (borderColor ?? Colors.grey.shade300),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: hasError 
                        ? (errorBorderColor ?? AppTheme.errorColor)
                        : (focusedBorderColor ?? AppTheme.primaryColor),
                    width: 3, // Focus plus visible
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: errorBorderColor ?? AppTheme.errorColor,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadiusTokens.input,
                  borderSide: BorderSide(
                    color: errorBorderColor ?? AppTheme.errorColor,
                    width: 3,
                  ),
                ),
                contentPadding: contentPadding ?? const EdgeInsets.all(16),
                prefixIcon: prefix,
                suffixIcon: suffix,
                semanticCounterText: maxLength != null ? 'Maximum $maxLength caractères' : null,
              ),
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
              // Amélioration de l'accessibilité
              textCapitalization: keyboardType == TextInputType.emailAddress 
                  ? TextCapitalization.none 
                  : TextCapitalization.sentences,
            ),
          ),
        ),
        
        // Message d'erreur accessible
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        
        // Compteur de caractères accessible
        if (maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                '${controller?.text.length ?? 0}/$maxLength caractères',
                style: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ),
      ],
    );
  }
} 
