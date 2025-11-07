import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';

/// Dialog pour la réinitialisation de mot de passe
class ForgotPasswordDialog extends ConsumerStatefulWidget {
  final Color errorColor;
  final Color successColor;
  final Color neutralColor;

  const ForgotPasswordDialog({
    super.key,
    this.errorColor = Colors.red,
    this.successColor = Colors.green,
    this.neutralColor = Colors.grey,
  });

  @override
  ConsumerState<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends ConsumerState<ForgotPasswordDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  Color _errorTone(int level) => tone(widget.errorColor, level: level);
  Color _successTone(int level) => tone(widget.successColor, level: level);
  Color _neutralTone(int level) => tone(widget.neutralColor, level: level);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider);
      await authController.resetPassword(_emailController.text.trim());
      
      setState(() {
        _emailSent = true;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _emailSent ? 'Email envoyé !' : 'Mot de passe oublié',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      content: _emailSent ? _buildSuccessContent() : _buildFormContent(),
      actions: _emailSent ? _buildSuccessActions() : _buildFormActions(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildFormContent() {
    return SizedBox(
      width: 400,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ForgotPasswordIntro(),
            const SizedBox(height: 20),
            _buildEmailField(),
            ..._buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return CommonTextField(
      controller: _emailController,
      label: 'Adresse email',
      hint: 'votre@email.com',
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email requis';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }

  List<Widget> _buildErrorMessage() {
    if (_errorMessage == null) {
      return const [];
    }

    return [
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _errorTone(50),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _errorTone(300)),
        ),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: _errorTone(700)),
          textAlign: TextAlign.center,
        ),
      ),
    ];
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.email_outlined,
          size: 64,
          color: _successTone(600),
        ),
        const SizedBox(height: 16),
        Text(
          'Un email de réinitialisation a été envoyé à :',
          style: TextStyle(
            fontSize: 14,
            color: _neutralTone(600),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text.trim(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.',
          style: TextStyle(
            fontSize: 14,
            color: _neutralTone(600),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildFormActions() {
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      CommonButton(
        onPressed: _isLoading ? null : _handleResetPassword,
        text: 'Envoyer',
        isLoading: _isLoading,
      ),
    ];
  }

  List<Widget> _buildSuccessActions() {
    return [
      CommonButton(
        onPressed: () => Navigator.of(context).pop(),
        text: 'Fermer',
      ),
    ];
  }
}

class _ForgotPasswordIntro extends StatelessWidget {
  const _ForgotPasswordIntro();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Entrez votre adresse email pour recevoir un lien de réinitialisation de votre mot de passe.',
      style: TextStyle(
        fontSize: 14,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
