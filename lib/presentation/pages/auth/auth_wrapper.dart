import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/auth_providers.dart';
import 'package:prioris/presentation/pages/auth/login_page.dart';
import 'package:prioris/presentation/pages/home_page.dart';

/// Wrapper qui gère la navigation entre login et app principale
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUIState = ref.watch(authUIStateProvider);
    
    switch (authUIState) {
      case AuthUIState.loading:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
        
      case AuthUIState.signedIn:
        return const HomePage();
        
      case AuthUIState.signedOut:
      case AuthUIState.error:
        return const LoginPage();
    }
  }
}