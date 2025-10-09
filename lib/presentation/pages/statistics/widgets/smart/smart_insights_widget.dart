import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/displays/premium_card.dart';

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
            'Insights intelligents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...insights.map(_buildInsightRow),
        ],
      ),
    );
  }

  Widget _buildInsightRow(dynamic insight) {
    final parsed = _parseInsight(insight);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBullet(),
          if (parsed.icon != null) ...[
            Text(parsed.icon!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              parsed.message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet() {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(top: 6, right: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        shape: BoxShape.circle,
      ),
    );
  }

  _InsightData _parseInsight(dynamic insight) {
    if (insight is String) {
      return _InsightData(message: insight);
    }
    if (insight is Map && insight['message'] != null) {
      return _InsightData(
        message: insight['message'] as String,
        icon: insight['icon'] as String?,
      );
    }
    return _InsightData(message: insight.toString());
  }
}

class _InsightData {
  final String message;
  final String? icon;

  const _InsightData({required this.message, this.icon});
}
