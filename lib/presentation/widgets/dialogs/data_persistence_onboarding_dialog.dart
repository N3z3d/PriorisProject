import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/theme/border_radius_tokens.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/widgets/dialogs/components/onboarding_components_export.dart';

/// Dialog explaining data persistence behavior to new users
/// Refactored to comply with SOLID principles and 50-line method limit
class DataPersistenceOnboardingDialog extends ConsumerWidget {
  const DataPersistenceOnboardingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusTokens.modal,
      ),
      title: const OnboardingDialogHeader(),
      content: _buildContent(),
      actions: [
        CommonButton(
          onPressed: () {
            Navigator.of(context).pop();
            _markOnboardingCompleted();
          },
          text: 'Compris !',
          type: ButtonType.primary,
        ),
      ],
    );
  }

  /// Builds the main content section with features list and info box
  Widget _buildContent() {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          OnboardingFeaturesList(),
          SizedBox(height: 24),
          OnboardingInfoBox(),
        ],
      ),
    );
  }

  /// Marks the onboarding as completed to prevent showing again
  void _markOnboardingCompleted() {
    // TODO: Store in shared preferences that onboarding is completed
    // This prevents showing the dialog again
  }
}