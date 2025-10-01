/// DUPLICATION ELIMINATION - Text Controller Mixin
///
/// Eliminates repeated TextEditingController patterns across the codebase.
/// This mixin provides common controller management functionality.

import 'package:flutter/material.dart';

/// Text Controller Management Mixin
///
/// Provides standardized text controller lifecycle management.
/// Eliminates duplication of controller initialization, disposal, and common operations.
mixin TextControllerMixin<T extends StatefulWidget> on State<T> {
  final Map<String, TextEditingController> _controllers = {};

  /// Creates or retrieves a text controller with optional initial value
  TextEditingController getController(String key, [String? initialValue]) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue ?? '');
    }
    return _controllers[key]!;
  }

  /// Updates controller text
  void updateController(String key, String text) {
    if (_controllers.containsKey(key)) {
      _controllers[key]!.text = text;
    }
  }

  /// Clears controller text
  void clearController(String key) {
    if (_controllers.containsKey(key)) {
      _controllers[key]!.clear();
    }
  }

  /// Clears all controllers
  void clearAllControllers() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
  }

  /// Gets current text from controller
  String getControllerText(String key) {
    return _controllers[key]?.text ?? '';
  }

  /// Checks if controller is empty
  bool isControllerEmpty(String key) {
    return _controllers[key]?.text.trim().isEmpty ?? true;
  }

  /// Validates multiple controllers at once
  bool validateControllers(Map<String, String Function(String)> validators) {
    for (final entry in validators.entries) {
      final text = getControllerText(entry.key);
      final error = entry.value(text);
      if (error.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Auto-dispose all controllers
  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  /// Common validation functions
  static String validateRequired(String value, [String? fieldName]) {
    if (value.trim().isEmpty) {
      return '${fieldName ?? 'Ce champ'} est requis';
    }
    return '';
  }

  static String validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email requis';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email invalide';
    }
    return '';
  }

  static String validatePassword(String value) {
    if (value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Au moins 6 caractères requis';
    return '';
  }

  static String validateMaxLength(String value, int maxLength, [String? fieldName]) {
    if (value.length > maxLength) {
      return '${fieldName ?? 'Ce champ'} ne peut dépasser $maxLength caractères';
    }
    return '';
  }
}

/// Form Controller Helper
/// Pre-configured controller sets for common forms
mixin FormControllerMixin<T extends StatefulWidget> on State<T> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Validates auth form
  bool validateAuthForm() {
    return emailController.text.trim().isNotEmpty &&
           passwordController.text.isNotEmpty;
  }

  /// Clears auth form
  void clearAuthForm() {
    emailController.clear();
    passwordController.clear();
  }
}