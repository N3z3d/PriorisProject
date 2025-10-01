// Usage Example: RefactoredFormSkeletonSystem
// Demonstrates API compatibility and new extension capabilities

import 'package:flutter/material.dart';
import 'form_skeleton_system_exports.dart';

void main() {
  runApp(const FormSkeletonExampleApp());
}

class FormSkeletonExampleApp extends StatelessWidget {
  const FormSkeletonExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Skeleton System Demo',
      home: const FormSkeletonDemoPage(),
    );
  }
}

class FormSkeletonDemoPage extends StatefulWidget {
  const FormSkeletonDemoPage({super.key});

  @override
  State<FormSkeletonDemoPage> createState() => _FormSkeletonDemoPageState();
}

class _FormSkeletonDemoPageState extends State<FormSkeletonDemoPage> {
  final RefactoredFormSkeletonSystem _skeletonSystem = RefactoredFormSkeletonSystem();
  String _currentVariant = 'standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Skeleton System Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Variant Selector
          _buildVariantSelector(),

          // Form Skeleton Display
          Expanded(
            child: _buildFormSkeletonDisplay(),
          ),

          // System Information
          _buildSystemInfo(),
        ],
      ),
    );
  }

  Widget _buildVariantSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Select Form Skeleton Variant:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _skeletonSystem.availableVariants.map((variant) {
              return ChoiceChip(
                label: Text(variant.toUpperCase()),
                selected: _currentVariant == variant,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _currentVariant = variant;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSkeletonDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _buildCurrentFormSkeleton(),
        ),
      ),
    );
  }

  Widget _buildCurrentFormSkeleton() {
    // Demonstrate different configurations for each variant
    switch (_currentVariant) {
      case 'standard':
        return _skeletonSystem.createVariant(
          'standard',
          width: 400,
          options: {
            'fieldCount': 4,
            'showTitle': true,
            'showSubmitButton': true,
            'showCancelButton': true,
          },
        );

      case 'compact':
        return _skeletonSystem.createVariant(
          'compact',
          width: 400,
          options: {
            'fieldCount': 3,
            'showSubmitButton': true,
          },
        );

      case 'detailed':
        return _skeletonSystem.createVariant(
          'detailed',
          width: 400,
          options: {
            'fieldCount': 5,
            'showDescription': true,
          },
        );

      case 'wizard':
        return _skeletonSystem.createVariant(
          'wizard',
          width: 400,
          height: 500,
          options: {
            'stepCount': 4,
            'currentStep': 1,
            'fieldsPerStep': 3,
          },
        );

      case 'survey':
        return _skeletonSystem.createVariant(
          'survey',
          width: 400,
          options: {
            'questionCount': 3,
          },
        );

      case 'search':
        return _skeletonSystem.createVariant(
          'search',
          width: 400,
          options: {
            'showFilters': true,
            'filterCount': 4,
          },
        );

      case 'login':
        return _skeletonSystem.createVariant(
          'login',
          width: 400,
          height: 600,
          options: {
            'showSocialLogin': true,
            'showForgotPassword': true,
            'showSignUp': true,
          },
        );

      default:
        return _skeletonSystem.createSkeleton();
    }
  }

  Widget _buildSystemInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System ID: ${_skeletonSystem.systemId}'),
          const SizedBox(height: 4),
          Text('Supported Types: ${_skeletonSystem.supportedTypes.length}'),
          const SizedBox(height: 4),
          Text('Available Variants: ${_skeletonSystem.availableVariants.join(', ')}'),
          const SizedBox(height: 4),
          Text('Registered Factories: ${_skeletonSystem.getRegisteredVariants().length}'),
        ],
      ),
    );
  }
}

// Example of extending the system with a custom factory
class CustomFormSkeletonFactory extends BaseFormSkeletonFactory {
  @override
  Widget create(FormSkeletonConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Custom Form Skeleton',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(config.fieldCount, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Extension usage example
void demonstrateExtension() {
  final system = RefactoredFormSkeletonSystem();

  // Register custom factory
  system.registerFactory('custom', CustomFormSkeletonFactory());

  // Use custom factory
  final customWidget = system.createVariant('custom', options: {'fieldCount': 3});

  // Check if factory is registered
  final hasCustomFactory = system.hasFactory('custom');
  print('Custom factory registered: $hasCustomFactory');

  // Get all registered variants
  final variants = system.getRegisteredVariants();
  print('All variants: $variants');
}