import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

class SampleData {
  // Habitudes d'exemple
  static List<Habit> getSampleHabits() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    
    return [
      // Habitudes binaires (Oui/Non)
      Habit(
        name: 'Méditation matinale',
        description: 'Méditer 10 minutes chaque matin',
        type: HabitType.binary,
        category: 'Bien-être',
        createdAt: now.subtract(const Duration(days: 30)),
        completions: {
          _getDateKey(now): true,
          _getDateKey(yesterday): true,
          _getDateKey(twoDaysAgo): false,
        },
      ),
      Habit(
        name: 'Lecture quotidienne',
        description: 'Lire au moins 20 pages par jour',
        type: HabitType.binary,
        category: 'Développement personnel',
        createdAt: now.subtract(const Duration(days: 25)),
        completions: {
          _getDateKey(now): false,
          _getDateKey(yesterday): true,
          _getDateKey(twoDaysAgo): true,
        },
      ),
      Habit(
        name: 'Exercice physique',
        description: 'Faire au moins 30 minutes d\'activité physique',
        type: HabitType.binary,
        category: 'Santé',
        createdAt: now.subtract(const Duration(days: 20)),
        completions: {
          _getDateKey(now): true,
          _getDateKey(yesterday): false,
          _getDateKey(twoDaysAgo): true,
        },
      ),
      Habit(
        name: 'Boire 2L d\'eau',
        description: 'Consommer au moins 2 litres d\'eau par jour',
        type: HabitType.binary,
        category: 'Santé',
        createdAt: now.subtract(const Duration(days: 15)),
        completions: {
          _getDateKey(now): true,
          _getDateKey(yesterday): true,
          _getDateKey(twoDaysAgo): false,
        },
      ),
      Habit(
        name: 'Gratitude journalière',
        description: 'Noter 3 choses pour lesquelles je suis reconnaissant',
        type: HabitType.binary,
        category: 'Bien-être',
        createdAt: now.subtract(const Duration(days: 12)),
        completions: {
          _getDateKey(now): false,
          _getDateKey(yesterday): true,
          _getDateKey(twoDaysAgo): true,
        },
      ),

      // Habitudes quantitatives
      Habit(
        name: 'Pompes',
        description: 'Faire des pompes quotidiennement',
        type: HabitType.quantitative,
        category: 'Sport',
        targetValue: 20,
        unit: 'répétitions',
        createdAt: now.subtract(const Duration(days: 18)),
        completions: {
          _getDateKey(now): 15.0,
          _getDateKey(yesterday): 20.0,
          _getDateKey(twoDaysAgo): 18.0,
        },
      ),
      Habit(
        name: 'Temps d\'écran',
        description: 'Limiter le temps d\'écran récréatif',
        type: HabitType.quantitative,
        category: 'Digital detox',
        targetValue: 2,
        unit: 'heures',
        createdAt: now.subtract(const Duration(days: 22)),
        completions: {
          _getDateKey(now): 1.5,
          _getDateKey(yesterday): 3.0,
          _getDateKey(twoDaysAgo): 2.5,
        },
      ),
      Habit(
        name: 'Pas quotidiens',
        description: 'Marcher au moins 8000 pas par jour',
        type: HabitType.quantitative,
        category: 'Santé',
        targetValue: 8000,
        unit: 'pas',
        createdAt: now.subtract(const Duration(days: 35)),
        completions: {
          _getDateKey(now): 9500.0,
          _getDateKey(yesterday): 7200.0,
          _getDateKey(twoDaysAgo): 8800.0,
        },
      ),
      Habit(
        name: 'Sommeil',
        description: 'Dormir au moins 7 heures par nuit',
        type: HabitType.quantitative,
        category: 'Santé',
        targetValue: 7,
        unit: 'heures',
        createdAt: now.subtract(const Duration(days: 40)),
        completions: {
          _getDateKey(now): 6.5,
          _getDateKey(yesterday): 7.5,
          _getDateKey(twoDaysAgo): 8.0,
        },
      ),
      Habit(
        name: 'Apprentissage langues',
        description: 'Étudier une langue étrangère',
        type: HabitType.quantitative,
        category: 'Développement personnel',
        targetValue: 30,
        unit: 'minutes',
        createdAt: now.subtract(const Duration(days: 28)),
        completions: {
          _getDateKey(now): 25.0,
          _getDateKey(yesterday): 35.0,
          _getDateKey(twoDaysAgo): 0.0,
        },
      ),
    ];
  }

  // Tâches d'exemple
  static List<Task> getSampleTasks() {
    final now = DateTime.now();
    
    return [
      // Tâches professionnelles
      Task(
        title: 'Finaliser le rapport trimestriel',
        description: 'Compiler les données et rédiger les conclusions',
        category: 'Travail',
        eloScore: 1500.0,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Task(
        title: 'Préparer la présentation client',
        description: 'Créer les slides et répéter la présentation',
        category: 'Travail',
        eloScore: 1450.0,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Task(
        title: 'Révision du code de l\'équipe',
        description: 'Examiner les pull requests en attente',
        category: 'Travail',
        eloScore: 1380.0,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        title: 'Planifier le sprint suivant',
        description: 'Organiser les user stories et estimer les tâches',
        category: 'Travail',
        eloScore: 1320.0,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        title: 'Formation sur les nouvelles technologies',
        description: 'Suivre le cours en ligne sur React Native',
        category: 'Travail',
        eloScore: 1250.0,
        dueDate: now.add(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      // Tâches personnelles - Administratif
      Task(
        title: 'Renouveler l\'assurance auto',
        description: 'Comparer les offres et souscrire une nouvelle assurance',
        category: 'Administratif',
        eloScore: 1400.0,
        dueDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Task(
        title: 'Déclarer les revenus',
        description: 'Remplir la déclaration d\'impôts en ligne',
        category: 'Administratif',
        eloScore: 1480.0,
        dueDate: now.add(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Task(
        title: 'Rendez-vous chez le dentiste',
        description: 'Prendre rendez-vous pour le contrôle annuel',
        category: 'Santé',
        eloScore: 1300.0,
        dueDate: now.add(const Duration(days: 12)),
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Tâches domestiques
      Task(
        title: 'Réparer la fuite du robinet',
        description: 'Changer le joint ou appeler un plombier',
        category: 'Maison',
        eloScore: 1350.0,
        dueDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Task(
        title: 'Organiser l\'anniversaire de maman',
        description: 'Réserver le restaurant et inviter la famille',
        category: 'Famille',
        eloScore: 1420.0,
        dueDate: now.add(const Duration(days: 18)),
        createdAt: now.subtract(const Duration(days: 12)),
      ),

      // Tâches de développement personnel
      Task(
        title: 'Lire "Atomic Habits"',
        description: 'Terminer la lecture du livre de James Clear',
        category: 'Développement personnel',
        eloScore: 1190.0,
        dueDate: now.add(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Task(
        title: 'Apprendre 50 mots d\'espagnol',
        description: 'Utiliser Duolingo et Anki pour mémoriser',
        category: 'Développement personnel',
        eloScore: 1160.0,
        dueDate: now.add(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      Task(
        title: 'Méditation de 20 minutes',
        description: 'Session de méditation prolongée ce weekend',
        category: 'Bien-être',
        eloScore: 1140.0,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        title: 'Écrire dans mon journal',
        description: 'Rattraper les 3 derniers jours d\'écriture',
        category: 'Bien-être',
        eloScore: 1120.0,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Tâches créatives
      Task(
        title: 'Terminer la peinture du salon',
        description: 'Finir la deuxième couche et ranger le matériel',
        category: 'Maison',
        eloScore: 1380.0,
        dueDate: now.add(const Duration(days: 6)),
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Task(
        title: 'Composer une nouvelle chanson',
        description: 'Travailler sur les paroles et la mélodie',
        category: 'Créativité',
        eloScore: 1200.0,
        dueDate: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Task(
        title: 'Photographier le coucher de soleil',
        description: 'Sortir avec l\'appareil photo ce weekend',
        category: 'Créativité',
        eloScore: 1080.0,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),

      // Tâches sociales
      Task(
        title: 'Appeler grand-mère',
        description: 'Prendre des nouvelles et organiser une visite',
        category: 'Famille',
        eloScore: 1300.0,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Task(
        title: 'Organiser une soirée jeux',
        description: 'Inviter les amis pour samedi soir',
        category: 'Social',
        eloScore: 1240.0,
        dueDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        title: 'Répondre aux emails personnels',
        description: 'Traiter la boîte mail en retard',
        category: 'Communication',
        eloScore: 1090.0,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Tâches de fitness
      Task(
        title: 'Courir 5km',
        description: 'Sortie running dans le parc',
        category: 'Sport',
        eloScore: 1170.0,
        dueDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        title: 'Séance de musculation',
        description: 'Entraînement haut du corps à la salle',
        category: 'Sport',
        eloScore: 1210.0,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        title: 'Cours de yoga',
        description: 'Participer au cours du jeudi soir',
        category: 'Sport',
        eloScore: 1130.0,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Tâches de shopping/courses
      Task(
        title: 'Courses de la semaine',
        description: 'Acheter fruits, légumes et produits de base',
        category: 'Courses',
        eloScore: 1060.0,
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        title: 'Acheter un cadeau pour Paul',
        description: 'Trouver quelque chose pour son anniversaire',
        category: 'Courses',
        eloScore: 1200.0,
        dueDate: now.add(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Task(
        title: 'Renouveler la garde-robe',
        description: 'Acheter des vêtements pour l\'automne',
        category: 'Courses',
        eloScore: 1180.0,
        dueDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      // Tâches de nettoyage/organisation
      Task(
        title: 'Grand ménage de printemps',
        description: 'Nettoyer toute la maison de fond en comble',
        category: 'Maison',
        eloScore: 1420.0,
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Task(
        title: 'Trier les affaires du grenier',
        description: 'Faire le tri et donner ce qui ne sert plus',
        category: 'Maison',
        eloScore: 1350.0,
        dueDate: now.add(const Duration(days: 21)),
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      Task(
        title: 'Organiser le bureau',
        description: 'Ranger et optimiser l\'espace de travail',
        category: 'Maison',
        eloScore: 1150.0,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),

      // Tâches financières
      Task(
        title: 'Faire les comptes du mois',
        description: 'Vérifier les dépenses et mettre à jour le budget',
        category: 'Finances',
        eloScore: 1280.0,
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        title: 'Investir dans un PEA',
        description: 'Rechercher et choisir les ETF à acheter',
        category: 'Finances',
        eloScore: 1400.0,
        dueDate: now.add(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Task(
        title: 'Négocier le forfait téléphone',
        description: 'Appeler l\'opérateur pour réduire la facture',
        category: 'Finances',
        eloScore: 1120.0,
        dueDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  // Listes personnalisées d'exemple
  static List<CustomList> getSampleLists() {
    final now = DateTime.now();
    
    return [
      // Liste de courses
      CustomList(
        id: 'sample_1',
        name: 'Courses de la semaine',
        type: ListType.SHOPPING,
        description: 'Liste des courses alimentaires et produits ménagers',
        items: [
          ListItem(
            id: 'item_1',
            title: 'Pain complet',
            category: 'Boulangerie',
            eloScore: 1450.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 2)),
            listId: 'sample_1',
          ),
          ListItem(
            id: 'item_2',
            title: 'Lait bio 1L',
            category: 'Produits laitiers',
            eloScore: 1420.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 2)),
            listId: 'sample_1',
          ),
          ListItem(
            id: 'item_3',
            title: 'Pommes golden (1kg)',
            category: 'Fruits',
            eloScore: 1300.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 1)),
            listId: 'sample_1',
          ),
          ListItem(
            id: 'item_4',
            title: 'Brocolis frais',
            category: 'Légumes',
            eloScore: 1280.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 12)),
            listId: 'sample_1',
          ),
          ListItem(
            id: 'item_5',
            title: 'Pâtes complètes',
            category: 'Féculents',
            eloScore: 1150.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(hours: 6)),
            listId: 'sample_1',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),

      // Liste de voyage
      CustomList(
        id: 'sample_2',
        name: 'Voyage à Tokyo',
        type: ListType.TRAVEL,
        description: 'Préparatifs pour le voyage au Japon en avril',
        items: [
          ListItem(
            id: 'item_6',
            title: 'Réserver les billets d\'avion',
            category: 'Transport',
            eloScore: 1580.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 30)),
            listId: 'sample_2',
          ),
          ListItem(
            id: 'item_7',
            title: 'Réserver l\'hôtel à Shibuya',
            category: 'Hébergement',
            eloScore: 1550.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 25)),
            listId: 'sample_2',
          ),
          ListItem(
            id: 'item_8',
            title: 'Demander un visa touristique',
            category: 'Administratif',
            eloScore: 1380.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 20)),
            listId: 'sample_2',
          ),
          ListItem(
            id: 'item_9',
            title: 'Acheter un guide de conversation',
            category: 'Préparation',
            eloScore: 1250.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 15)),
            listId: 'sample_2',
          ),
          ListItem(
            id: 'item_10',
            title: 'Télécharger l\'app Google Translate',
            category: 'Applications',
            eloScore: 1220.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 10)),
            listId: 'sample_2',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),

      // Liste de films
      CustomList(
        id: 'sample_3',
        name: 'Films à regarder',
        type: ListType.MOVIES,
        description: 'Ma liste de films recommandés et classiques à découvrir',
        items: [
          ListItem(
            id: 'item_11',
            title: 'Oppenheimer (2023)',
            category: 'Biographie',
            eloScore: 1480.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 14)),
            listId: 'sample_3',
          ),
          ListItem(
            id: 'item_12',
            title: 'Everything Everywhere All at Once',
            category: 'Science-fiction',
            eloScore: 1450.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 12)),
            listId: 'sample_3',
          ),
          ListItem(
            id: 'item_13',
            title: 'Spirited Away (Le Voyage de Chihiro)',
            category: 'Animation',
            eloScore: 1320.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 8)),
            listId: 'sample_3',
          ),
          ListItem(
            id: 'item_14',
            title: 'The Grand Budapest Hotel',
            category: 'Comédie',
            eloScore: 1280.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 5)),
            listId: 'sample_3',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),

      // Liste de livres
      CustomList(
        id: 'sample_4',
        name: 'Livres de développement personnel',
        type: ListType.BOOKS,
        description: 'Collection de livres pour améliorer ma productivité et mon bien-être',
        items: [
          ListItem(
            id: 'item_15',
            title: 'Atomic Habits - James Clear',
            category: 'Productivité',
            eloScore: 1520.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 45)),
            listId: 'sample_4',
          ),
          ListItem(
            id: 'item_16',
            title: 'Deep Work - Cal Newport',
            category: 'Productivité',
            eloScore: 1400.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 30)),
            listId: 'sample_4',
          ),
          ListItem(
            id: 'item_17',
            title: 'The Power of Now - Eckhart Tolle',
            category: 'Spiritualité',
            eloScore: 1310.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 20)),
            listId: 'sample_4',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),

      // Liste de restaurants
      CustomList(
        id: 'sample_5',
        name: 'Restaurants à tester',
        type: ListType.RESTAURANTS,
        description: 'Nouvelles adresses recommandées par les amis',
        items: [
          ListItem(
            id: 'item_18',
            title: 'Le Comptoir du Relais',
            category: 'Bistrot français',
            eloScore: 1430.0,
            isCompleted: true,
            createdAt: now.subtract(const Duration(days: 10)),
            listId: 'sample_5',
          ),
          ListItem(
            id: 'item_19',
            title: 'Sushi Masa',
            category: 'Japonais',
            eloScore: 1380.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 7)),
            listId: 'sample_5',
          ),
          ListItem(
            id: 'item_20',
            title: 'Pizza Gigi',
            category: 'Italien',
            eloScore: 1290.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 3)),
            listId: 'sample_5',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),

      // Liste de projets
      CustomList(
        id: 'sample_6',
        name: 'Projets personnels 2024',
        type: ListType.PROJECTS,
        description: 'Mes objectifs et projets pour cette année',
        items: [
          ListItem(
            id: 'item_21',
            title: 'Créer une application mobile',
            category: 'Technologie',
            eloScore: 1500.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 60)),
            listId: 'sample_6',
          ),
          ListItem(
            id: 'item_22',
            title: 'Apprendre la guitare',
            category: 'Musique',
            eloScore: 1330.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 50)),
            listId: 'sample_6',
          ),
          ListItem(
            id: 'item_23',
            title: 'Rénover la salle de bain',
            category: 'Maison',
            eloScore: 1350.0,
            isCompleted: false,
            createdAt: now.subtract(const Duration(days: 40)),
            listId: 'sample_6',
          ),
        ],
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now.subtract(const Duration(days: 40)),
      ),
    ];
  }

  // Fonction utilitaire pour formater les dates
  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 
