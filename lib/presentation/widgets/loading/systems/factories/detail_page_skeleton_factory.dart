import 'package:flutter/material.dart';
import 'package:prioris/presentation/widgets/loading/components/skeleton_components.dart';
import 'package:prioris/presentation/widgets/loading/interfaces/skeleton_system_interface.dart';
import '../interfaces/page_skeleton_factory.dart';

/// Factory for detail page skeletons
/// Single Responsibility: Creates detail-specific skeleton layouts
class DetailPageSkeletonFactory implements IPageSkeletonFactory {
  @override
  List<String> get supportedPageTypes => [
    'detail_page',
    'details',
    'item_detail',
    'view_detail',
  ];

  @override
  bool canHandlePageType(String pageType) {
    return supportedPageTypes.contains(pageType) ||
           pageType.contains('detail') ||
           pageType.contains('view');
  }

  @override
  Widget createPageSkeleton(String pageType, SkeletonConfig config) {
    return _createDetailPage(config);
  }

  Widget _createDetailPage(SkeletonConfig config) {
    final showHeader = config.options['showHeader'] ?? true;
    final showImage = config.options['showImage'] ?? true;
    final showContent = config.options['showContent'] ?? true;
    final showActions = config.options['showActions'] ?? true;
    final showRelated = config.options['showRelated'] ?? true;

    return Container(
      width: config.width,
      height: config.height ?? 800,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _buildDetailHeader(),
            if (showImage) _buildHeroImage(),
            if (showContent) _buildMainContent(),
            if (showActions) _buildActionButtons(),
            if (showRelated) _buildRelatedItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SkeletonContainer(width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLine(width: 200, height: 24),
                SizedBox(height: 8),
                SkeletonLine(width: 120, height: 16),
              ],
            ),
          ),
          const SkeletonContainer(width: 32, height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SkeletonContainer(width: 80, height: 80),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 250, height: 28),
          const SizedBox(height: 12),
          const SkeletonLine(width: 180, height: 16),
          const SizedBox(height: 20),
          ...List.generate(6, (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: SkeletonLine(
              width: index % 2 == 0 ? 300 : 240,
              height: 16,
            ),
          )),
          const SizedBox(height: 20),
          _buildMetaInfo(),
        ],
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLine(width: 100, height: 16),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetaItem()),
            const SizedBox(width: 16),
            Expanded(child: _buildMetaItem()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetaItem()),
            const SizedBox(width: 16),
            Expanded(child: _buildMetaItem()),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonLine(width: 60, height: 12),
          SizedBox(height: 4),
          SkeletonLine(width: 80, height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(child: _buildPrimaryButton()),
          const SizedBox(width: 12),
          Expanded(child: _buildSecondaryButton()),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: SkeletonLine(width: 100, height: 16),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: SkeletonLine(width: 80, height: 16),
      ),
    );
  }

  Widget _buildRelatedItems() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 140, height: 18),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, index) => _buildRelatedItem(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedItem() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 90, height: 14),
                SizedBox(height: 4),
                SkeletonLine(width: 70, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}