import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';

/// Widget affichant une liste d'insights intelligents sous forme de cartes stylées
/// [insights] : Liste de messages (String) ou d'objets {icon, message}
class SmartInsightsWidget extends StatelessWidget {
  final List<dynamic> insights;

  const SmartInsightsWidget({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Insights Intelligents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) {
            String message;
            String? icon;
            if (insight is String) {
              message = insight;
              icon = null;
            } else if (insight is Map && insight.containsKey('message')) {
              message = insight['message'] as String;
              icon = insight['icon'] as String?;
            } else {
              message = insight.toString();
              icon = null;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (icon != null) ...[
                    Text(icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
} 
