import 'package:flutter/material.dart';
import 'package:prioris/core/exceptions/app_exception.dart';
import 'package:prioris/l10n/app_localizations.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool isNetworkError;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.isNetworkError = false,
    this.onRetry,
  });

  static Widget fromError({
    required BuildContext context,
    required Object error,
    VoidCallback? onRetry,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final appEx = error is AppException ? error : ExceptionHandler.handle(error);
    final isNetwork =
        appEx.type == ErrorType.network || appEx.type == ErrorType.timeout;
    return AppErrorWidget(
      title: isNetwork ? l10n.errorNetworkTitle : l10n.errorGenericTitle,
      message: isNetwork ? l10n.errorNetworkMessage : l10n.errorGenericMessage,
      isNetworkError: isNetwork,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}
