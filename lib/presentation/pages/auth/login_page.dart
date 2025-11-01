import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'components/login_actions.dart';
import 'components/login_error_display.dart';
import 'components/login_form_fields.dart';
import 'components/login_header.dart';

/// Page de connexion / inscription.
///
/// SRP: orchestrer les interactions d'authentification.
/// Architecture: MVVM (state avec Riverpod).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _honeypotController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;
  DateTime? _signUpStartedAt;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _honeypotController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = ref.read(authControllerProvider);

      if (_isSignUp) {
        final metadata = SignupAttemptMetadata(
          startedAt: _signUpStartedAt,
          honeypotFilled: _honeypotController.text.trim().isNotEmpty,
        );
        await authController.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          metadata: metadata,
        );
      } else {
        await authController.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // Navigation geree par authStateProvider.
    } on SignupThrottledException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Erreur: $error';
      });
      // TODO: relier a un logger centralise.
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LoginHeader(isSignUp: _isSignUp),
                    const SizedBox(height: 32),
                    LoginFormFields(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      honeypotController: _honeypotController,
                      isSignUp: _isSignUp,
                      onSubmit: _handleAuth,
                    ),
                    const SizedBox(height: 24),
                    LoginErrorDisplay(errorMessage: _errorMessage),
                    LoginActions(
                      isLoading: _isLoading,
                      isSignUp: _isSignUp,
                      onSubmit: _handleAuth,
                      onToggleMode: _toggleMode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _honeypotController.clear();
      _signUpStartedAt = _isSignUp ? DateTime.now() : null;
    });
  }
}
