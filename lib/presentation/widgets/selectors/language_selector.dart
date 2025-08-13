import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/domain/services/core/language_service.dart';

/// Widget de sélection de langue
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);
    final languageService = ref.read(languageServiceProvider);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.language, size: 24),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.language ?? 'Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...supportedLanguages.map((languageInfo) => _buildLanguageOption(
              context,
              ref,
              languageInfo,
              currentLocale,
              languageService,
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    LanguageInfo languageInfo,
    Locale currentLocale,
    LanguageService languageService,
  ) {
    final isSelected = languageInfo.locale.languageCode == currentLocale.languageCode;
    
    return InkWell(
      onTap: () async {
        await languageService.setLocale(languageInfo.locale);
        ref.read(currentLocaleProvider.notifier).state = languageInfo.locale;
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)?.language ?? 'Language'} changed to ${languageInfo.displayName}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
          border: isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
        ),
        child: Row(
          children: [
            Text(
              languageInfo.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                languageInfo.displayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Widget de sélection de langue compact (pour les paramètres)
class CompactLanguageSelector extends ConsumerWidget {
  const CompactLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(currentLocaleProvider);
    final supportedLanguages = ref.watch(supportedLanguagesProvider);
    final languageService = ref.read(languageServiceProvider);
    
    final currentLanguage = supportedLanguages.firstWhere(
      (lang) => lang.locale.languageCode == currentLocale.languageCode,
      orElse: () => supportedLanguages.first,
    );
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
      subtitle: Text('${currentLanguage.flag} ${currentLanguage.displayName}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLanguageDialog(context, ref, languageService),
    );
  }
  
  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    LanguageService languageService,
  ) {
    final supportedLanguages = ref.read(supportedLanguagesProvider);
    final currentLocale = ref.read(currentLocaleProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.language ?? 'Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLanguages.map((languageInfo) {
              final isSelected = languageInfo.locale.languageCode == currentLocale.languageCode;
              
              return ListTile(
                leading: Text(
                  languageInfo.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                title: Text(languageInfo.displayName),
                trailing: isSelected 
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
                onTap: () async {
                  await languageService.setLocale(languageInfo.locale);
                  ref.read(currentLocaleProvider.notifier).state = languageInfo.locale;
                  
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)?.language ?? 'Language'} changed to ${languageInfo.displayName}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
} 
