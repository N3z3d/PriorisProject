/// **GET TODAYS HABITS QUERY** - CQRS Pattern
///
/// **LOT 5** : Query de lecture des habitudes du jour extraite de God Class
/// **Responsabilité unique** : Query simple sans paramètres
/// **Taille** : ~15 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Query pour récupérer les habitudes prévues pour aujourd'hui
///
/// **SRP** : Responsabilité unique de requête des habitudes journalières
/// **Simplicité** : Aucun paramètre requis, filtre automatique par date courante
class GetTodaysHabitsQuery extends Query {
  // Aucun paramètre nécessaire - filtre automatique par date courante
}