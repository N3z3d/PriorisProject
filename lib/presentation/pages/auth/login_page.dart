import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/infrastructure/security/signup_guard.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'components/login_actions.dart';
import 'components/login_error_display.dart';
import 'components/login_form_fields.dart';
import 'components/login_header.dart';

/// Page de connexion / inscription.
///
/// SRP: orchestrer les interactions d'authentification.
/// Architecture: MVVM (state avec Riverpod).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({
    super.key,
    this.initialErrorMessage,
  });

  final String? initialErrorMessage;

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
  bool _showsInformationalMessage = false;
  String? _errorMessage;
  DateTime? _signUpStartedAt;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.initialErrorMessage;
    if (ref.read(callbackWithoutSessionProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final message = AppLocalizations.of(context)?.authCallbackExpiredMessage ??
            'Votre lien de connexion est expiré ou a été ouvert depuis un autre navigateur. Veuillez vous connecter.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
          ),
        );
      });
    }
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldSyncExternalError =
        widget.initialErrorMessage != oldWidget.initialErrorMessage &&
            !_isLoading &&
            (_errorMessage == null ||
                _errorMessage == oldWidget.initialErrorMessage);

    if (shouldSyncExternalError) {
      setState(() {
        _errorMessage = widget.initialErrorMessage;
        _showsInformationalMessage = false;
      });
    }
  }

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
      _showsInformationalMessage = false;
    });

    try {
      final authController = ref.read(authControllerProvider);

      if (_isSignUp) {
        final metadata = SignupAttemptMetadata(
          startedAt: _signUpStartedAt,
          honeypotFilled: _honeypotController.text.trim().isNotEmpty,
        );
        final response = await authController.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          metadata: metadata,
        );

        if (_requiresEmailConfirmation(response)) {
          _showPendingConfirmationFeedback(
            email: response.user?.email ?? _emailController.text.trim(),
          );
        }
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
        _showsInformationalMessage = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error is AppException
            ? _resolveErrorMessage(error)
            : 'Erreur: $error';
        _showsInformationalMessage = false;
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

  bool _requiresEmailConfirmation(AuthResponse response) {
    return response.session == null;
  }

  void _showPendingConfirmationFeedback({required String email}) {
    final l10n = AppLocalizations.of(context);
    final title =
        l10n?.authPendingConfirmationTitle ?? 'Confirmation requise';
    final message = l10n?.authPendingConfirmationMessage(email) ??
        'Confirmez votre adresse email pour terminer l\'inscription.';

    _passwordController.clear();
    _honeypotController.clear();

    setState(() {
      _isSignUp = false;
      _signUpStartedAt = null;
      _showsInformationalMessage = true;
      _errorMessage = '$title\n$message';
    });
  }

  String _resolveErrorMessage(AppException error) {
    final l10n = AppLocalizations.of(context);
    final messageKey = error.metadata?['messageKey'];

    switch (messageKey) {
      case 'authOfflineSignInError':
        return l10n?.authOfflineSignInError ?? error.displayMessage;
      case 'authOfflineSignUpError':
        return l10n?.authOfflineSignUpError ?? error.displayMessage;
      default:
        return error.displayMessage;
    }
  }

  Color _messageColor() {
    return _showsInformationalMessage ? AppTheme.primaryColor : Colors.red;
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
                    LoginErrorDisplay(
                      errorMessage: _errorMessage,
                      errorColor: _messageColor(),
                    ),
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
      _showsInformationalMessage = false;
      _honeypotController.clear();
      _signUpStartedAt = _isSignUp ? DateTime.now() : null;
    });
  }
}
