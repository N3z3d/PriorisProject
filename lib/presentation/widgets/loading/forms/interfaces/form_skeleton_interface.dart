/// **FORM SKELETON INTERFACE** - ISP Compliance
///
/// **LOT 7** : Interface pour composants formulaires spécialisés
/// **SRP** : Contrat unique pour skelettes de formulaires
abstract class IFormSkeletonComponent {
  /// Identifiant unique du type de formulaire
  String get componentId;

  /// Types de formulaires supportés par ce composant
  List<String> get supportedTypes;

  /// Variants disponibles pour ce type de formulaire
  List<String> get availableVariants;

  /// Détermine si ce composant peut gérer le type demandé
  bool canHandle(String skeletonType);

  /// Crée un skeleton de formulaire avec configuration
  Widget createSkeleton({
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });

  /// Crée un variant spécialisé du formulaire
  Widget createVariant(
    String variant, {
    double? width,
    double? height,
    Map<String, dynamic>? options,
  });
}

/// **Configuration standardisée pour tous les skelettes**
class SkeletonConfig {
  final double? width;
  final double? height;
  final Map<String, dynamic> options;
  final Duration? animationDuration;

  const SkeletonConfig({
    this.width,
    this.height,
    this.options = const {},
    this.animationDuration,
  });

  SkeletonConfig copyWith({
    double? width,
    double? height,
    Map<String, dynamic>? options,
    Duration? animationDuration,
  }) {
    return SkeletonConfig(
      width: width ?? this.width,
      height: height ?? this.height,
      options: options ?? this.options,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}