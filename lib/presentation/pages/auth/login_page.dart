import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/common/forms/password_text_field.dart';
import 'package:prioris/presentation/widgets/dialogs/forgot_password_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isSignUp = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        await authController.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await authController.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      
      // Navigation sera gérée par le provider authStateProvider
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
      });
      print('AUTH ERROR: $e'); // Debug
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    // Logo/Title
                    Icon(
                      Icons.checklist_rtl,
                      size: 64,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Prioris',
                      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      _isSignUp ? 'Créer un compte' : 'Connectez-vous',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Email Field
                    CommonTextField(
                      controller: _emailController,
                      label: 'Email',
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
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password Field
                    PasswordTextField(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      hint: '••••••••',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Mot de passe requis';
                        }
                        if (_isSignUp && value.length < 6) {
                          return 'Au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Error Message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Submit Button
                    CommonButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      text: _isLoading 
                        ? 'Chargement...'
                        : (_isSignUp ? 'Créer le compte' : 'Se connecter'),
                      isLoading: _isLoading,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Toggle Sign Up/Sign In
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isSignUp 
                          ? 'Déjà un compte ? Se connecter'
                          : 'Pas de compte ? Créer un compte',
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Forgot Password (only in sign in mode)
                    if (!_isSignUp)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ForgotPasswordDialog(),
                          );
                        },
                        child: const Text('Mot de passe oublié ?'),
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
}