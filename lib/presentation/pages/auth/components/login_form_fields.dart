import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/presentation/widgets/common/forms/password_text_field.dart';
import 'package:prioris/presentation/validators/form_validators.dart';

/// Widget contenant les champs de formulaire de connexion
///
/// **SRP** : Gère uniquement l'affichage des champs email/password
class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUp;
  final VoidCallback onSubmit;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonTextField(
          controller: emailController,
          label: 'Email',
          hint: 'votre@email.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => onSubmit(),
          validator: FormValidators.email,
        ),
        const SizedBox(height: 16),
        PasswordTextField(
          controller: passwordController,
          label: 'Mot de passe',
          hint: '••••••••',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          validator: (value) => isSignUp
              ? FormValidators.password(value, minLength: 6)
              : FormValidators.password(value),
        ),
      ],
    );
  }
}
