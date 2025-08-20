/// Paramètres de priorisation des listes
/// 
/// Gère quelles listes participent au mode prioriser (duels ELO).
/// Permet aux utilisateurs de désactiver certaines listes
/// (ex: liste de courses) qui ne nécessitent pas de priorisation.
class ListPrioritizationSettings {
  /// IDs des listes activées. Si vide, toutes les listes sont activées.
  final Set<String> enabledListIds;

  const ListPrioritizationSettings({
    required this.enabledListIds,
  });

  /// Paramètres par défaut : toutes les listes sont activées
  factory ListPrioritizationSettings.defaultSettings() {
    return const ListPrioritizationSettings(
      enabledListIds: {},
    );
  }

  /// Indique si toutes les listes sont activées
  bool get isAllListsEnabled => enabledListIds.isEmpty;

  /// Vérifie si une liste spécifique est activée
  bool isListEnabled(String listId) {
    if (isAllListsEnabled) return true;
    return enabledListIds.contains(listId);
  }

  /// Désactive une liste spécifique
  /// 
  /// Si c'était en mode "toutes activées", passe en mode sélectif
  /// en gardant toutes sauf celle à désactiver.
  ListPrioritizationSettings disableList(String listId) {
    if (isAllListsEnabled) {
      // Mode "toutes activées" -> on ne peut pas juste ajouter la liste désactivée
      // Il faudrait connaître toutes les listes existantes
      // Pour l'instant, on crée un Set vide (aucune liste activée)
      return ListPrioritizationSettings(
        enabledListIds: <String>{}, // Aucune liste activée
      );
    }

    // Retirer la liste du Set des activées
    final updatedSet = Set<String>.from(enabledListIds);
    updatedSet.remove(listId);
    
    return ListPrioritizationSettings(
      enabledListIds: updatedSet,
    );
  }

  /// Active une liste spécifique
  ListPrioritizationSettings enableList(String listId) {
    final updatedSet = Set<String>.from(enabledListIds);
    updatedSet.add(listId);
    
    return ListPrioritizationSettings(
      enabledListIds: updatedSet,
    );
  }

  /// Filtre une liste d'IDs pour ne garder que celles activées
  List<String> filterEnabledLists(List<String> allListIds) {
    if (isAllListsEnabled) return allListIds;
    
    return allListIds.where((listId) => enabledListIds.contains(listId)).toList();
  }

  /// Méthode pour initialiser avec toutes les listes existantes activées
  factory ListPrioritizationSettings.withAllLists(List<String> allListIds) {
    return ListPrioritizationSettings(
      enabledListIds: Set<String>.from(allListIds),
    );
  }

  /// Désactive une liste en connaissant toutes les listes disponibles
  ListPrioritizationSettings disableListWithContext(String listId, List<String> allListIds) {
    if (isAllListsEnabled) {
      // Activer toutes sauf celle à désactiver
      final enabledSet = Set<String>.from(allListIds);
      enabledSet.remove(listId);
      return ListPrioritizationSettings(enabledListIds: enabledSet);
    }

    // Retirer la liste du Set des activées
    final updatedSet = Set<String>.from(enabledListIds);
    updatedSet.remove(listId);
    
    return ListPrioritizationSettings(enabledListIds: updatedSet);
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'enabledListIds': enabledListIds.toList(),
    };
  }

  /// Désérialisation JSON
  factory ListPrioritizationSettings.fromJson(Map<String, dynamic> json) {
    final enabledList = json['enabledListIds'] as List<dynamic>?;
    final enabledSet = enabledList?.map((e) => e.toString()).toSet() ?? <String>{};
    
    return ListPrioritizationSettings(
      enabledListIds: enabledSet,
    );
  }

  @override
  String toString() {
    if (isAllListsEnabled) {
      return 'ListPrioritizationSettings(all lists enabled)';
    }
    return 'ListPrioritizationSettings(${enabledListIds.length} lists enabled: ${enabledListIds.join(", ")})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListPrioritizationSettings &&
        other.enabledListIds.length == enabledListIds.length &&
        other.enabledListIds.containsAll(enabledListIds);
  }

  @override
  int get hashCode => enabledListIds.hashCode;
}