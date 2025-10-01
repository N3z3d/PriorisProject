import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';

/// Service spécialisé pour les squelettes de pages standard
///
/// Respecte le Single Responsibility Principle en ne gérant que
/// les layouts de pages (profile, detail, settings)
class PageSkeletonService {
  static const String serviceId = 'page_skeleton_service';

  static const List<String> supportedTypes = [
    'profile_page',
    'detail_page',
    'settings_page',
    'list_page',
  ];

  static bool canHandle(String skeletonType) {
    return supportedTypes.contains(skeletonType) ||
           skeletonType.endsWith('_page');
  }

  static Widget createPage({
    required String pageType,
    String variant = 'standard',
    Map<String, dynamic>? options,
  }) {
    switch (pageType) {
      case 'profile_page':
        return _createProfilePage(variant, options);
      case 'detail_page':
        return _createDetailPage(variant, options);
      case 'settings_page':
        return _createSettingsPage(variant, options);
      case 'list_page':
        return _createListPage(variant, options);
      default:
        return _createGenericPage(options);
    }
  }

  static Widget _createProfilePage(String variant, Map<String, dynamic>? options) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 24,
            children: [
              _createProfileHeader(),
              _createProfileStats(),
              _createProfileSections(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _createDetailPage(String variant, Map<String, dynamic>? options) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 20,
            children: [
              _createDetailHeader(),
              _createDetailContent(),
              _createDetailActions(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _createSettingsPage(String variant, Map<String, dynamic>? options) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 16,
            children: [
              _createSettingsHeader(),
              ...List.generate(6, (index) => _createSettingsSection()),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _createListPage(String variant, Map<String, dynamic>? options) {
    final itemCount = options?['itemCount'] ?? 8;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 16,
            children: [
              _createListHeader(),
              ...List.generate(itemCount, (index) => _createListItem()),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _createGenericPage(Map<String, dynamic>? options) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            spacing: 20,
            children: [
              SkeletonText(width: 200, height: 24, style: SkeletonTextStyle.bold),
              SkeletonCard(
                padding: const EdgeInsets.all(16),
                child: SkeletonText(width: double.infinity, height: 100),
              ),
              SkeletonButton(width: double.infinity, height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // === COMPOSANTS PROFILE ===

  static Widget _createProfileHeader() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: [
        SkeletonAvatar(size: 80),
        SkeletonText(width: 150, height: 20, style: SkeletonTextStyle.bold),
        SkeletonText(width: 100, height: 14),
      ],
    );
  }

  static Widget _createProfileStats() {
    return SkeletonLayoutBuilder.horizontal(
      spacing: 20,
      children: List.generate(3, (index) =>
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            spacing: 8,
            children: [
              SkeletonText(width: 60, height: 18, style: SkeletonTextStyle.bold),
              SkeletonText(width: 40, height: 12),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _createProfileSections() {
    return SkeletonLayoutBuilder.vertical(
      spacing: 16,
      children: List.generate(4, (index) =>
        SkeletonCard(
          padding: const EdgeInsets.all(16),
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              SkeletonText(width: 120, height: 16, style: SkeletonTextStyle.bold),
              SkeletonText(width: double.infinity, height: 14),
              SkeletonText(width: 200, height: 14),
            ],
          ),
        ),
      ),
    );
  }

  // === COMPOSANTS DETAIL ===

  static Widget _createDetailHeader() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        SkeletonButton(width: 40, height: 40),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonText(width: double.infinity, height: 20, style: SkeletonTextStyle.bold),
        ),
      ],
    );
  }

  static Widget _createDetailContent() {
    return SkeletonCard(
      padding: const EdgeInsets.all(20),
      child: SkeletonLayoutBuilder.vertical(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SkeletonText(width: double.infinity, height: 16),
          SkeletonText(width: double.infinity, height: 16),
          SkeletonText(width: 250, height: 16),
          const SizedBox(height: 16),
          SkeletonChart(height: 150, type: SkeletonChartType.bar),
        ],
      ),
    );
  }

  static Widget _createDetailActions() {
    return SkeletonLayoutBuilder.horizontal(
      spacing: 12,
      children: [
        Expanded(child: SkeletonButton(height: 48)),
        Expanded(child: SkeletonButton(height: 48)),
      ],
    );
  }

  // === COMPOSANTS SETTINGS ===

  static Widget _createSettingsHeader() {
    return SkeletonText(width: 120, height: 24, style: SkeletonTextStyle.bold);
  }

  static Widget _createSettingsSection() {
    return SkeletonCard(
      padding: const EdgeInsets.all(16),
      child: SkeletonLayoutBuilder.horizontal(
        children: [
        SkeletonIcon(size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: SkeletonLayoutBuilder.vertical(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              SkeletonText(width: 140, height: 16),
              SkeletonText(width: 200, height: 12),
            ],
          ),
        ),
        SkeletonIcon(size: 16),
        ],
      ),
    );
  }

  // === COMPOSANTS LIST ===

  static Widget _createListHeader() {
    return SkeletonLayoutBuilder.horizontal(
      children: [
        Expanded(
          child: SkeletonText(width: double.infinity, height: 20, style: SkeletonTextStyle.bold),
        ),
        SkeletonButton(width: 80, height: 32),
      ],
    );
  }

  static Widget _createListItem() {
    return SkeletonCard(
      padding: const EdgeInsets.all(12),
      child: SkeletonLayoutBuilder.horizontal(
        children: [
          SkeletonAvatar(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: SkeletonLayoutBuilder.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                SkeletonText(width: double.infinity, height: 14),
                SkeletonText(width: 150, height: 12),
              ],
            ),
          ),
          SkeletonIcon(size: 20),
        ],
      ),
    );
  }
}