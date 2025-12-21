
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
enum HabitType {
  @HiveField(0)
  binary, // Oui/Non
  @HiveField(1)
  quantitative // Nombre/Quantité
}

@HiveType(typeId: 4)
enum RecurrenceType {
  @HiveField(0)
  dailyInterval,
  @HiveField(1)
  weeklyDays,
  @HiveField(2)
  timesPerWeek,
  @HiveField(3)
  timesPerDay,
  
  // 🗓️ Fréquences Avancées
  @HiveField(4)
  monthly,      // Mensuelle (ex: tous les 1er du mois)
  @HiveField(5)
  monthlyDay,   // Jour spécifique du mois (ex: tous les 15)
  @HiveField(6)
  quarterly,    // Trimestrielle
  @HiveField(7)
  yearly,       // Annuelle (ex: anniversaires, bilans)
  
  // ⏰ Fréquences Temporelles
  @HiveField(8)
  hourlyInterval, // Toutes les X heures
  @HiveField(9)
  timesPerHour,   // X fois par heure
  @HiveField(10)
  weekends,       // Seulement le weekend
  @HiveField(11)
  weekdays,       // Seulement en semaine
}

@HiveType(typeId: 2)
class Habit extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  HabitType type;
  
  @HiveField(4)
  String? category;
  
  @HiveField(5)
  double? targetValue; // Pour les habitudes quantitatives
  
  @HiveField(6)
  String? unit; // Ex: "verres", "minutes", "pages"
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  Map<String, dynamic> completions; // Date -> valeur (bool ou double)

  @HiveField(9)
  RecurrenceType? recurrenceType;

  @HiveField(10)
  int? intervalDays;

  @HiveField(11)
  List<int>? weekdays;

  @HiveField(12)
  int? timesTarget;

  // Nouveaux champs pour les fréquences avancées
  @HiveField(13)
  int? monthlyDay;      // Pour monthlyDay: jour du mois (1-31)
  
  @HiveField(14)
  int? quarterMonth;    // Pour quarterly: mois du trimestre (1-3)
  
  @HiveField(15)
  int? yearlyMonth;     // Pour yearly: mois de l'année (1-12)
  
  @HiveField(16)
  int? yearlyDay;       // Pour yearly: jour du mois (1-31)
  
  @HiveField(17)
  int? hourlyInterval;  // Pour hourlyInterval: toutes les X heures

  // Propriétés UI/UX
  @HiveField(18)
  int? color; // Couleur de l'habitude (format ARGB)
  
  @HiveField(19)
  int? icon; // Code de l'icône Material Icons
  
  @HiveField(20)
  int? currentStreak; // Streak actuel calculé

  // User association fields for multi-user support
  @HiveField(21)
  String? userId; // Supabase user ID

  @HiveField(22)
  String? userEmail; // User email for reference

  // Fréquences avancées
  @HiveField(23)
  int? daysActive; // M sur N

  @HiveField(24)
  int? daysCycle; // N du cycle M/N

  @HiveField(25)
  DateTime? cycleStartDate; // date de début du cycle M/N

  @HiveField(26)
  List<int>? specificWeekdays; // jours spécifiques (0-6)

  @HiveField(27)
  DateTime? specificDate; // date unique ou première occurrence

  @HiveField(28)
  bool repeatEveryYear; // répétition annuelle

  Habit({
    String? id,
    required this.name,
    this.description,
    required this.type,
    this.category,
    this.targetValue,
    this.unit,
    DateTime? createdAt,
    Map<String, dynamic>? completions,
    this.recurrenceType,
    this.intervalDays,
    this.weekdays,
    this.timesTarget,
    this.monthlyDay,
    this.quarterMonth,
    this.yearlyMonth,
    this.yearlyDay,
    this.hourlyInterval,
    this.color = 0xFF2196F3, // Bleu par défaut
    this.icon = 0xe5ca, // Icons.check_circle par défaut
    this.currentStreak = 0, // Pas de streak initial
    this.userId,
    this.userEmail,
    this.daysActive,
    this.daysCycle,
    this.cycleStartDate,
    this.specificWeekdays,
    this.specificDate,
    this.repeatEveryYear = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       completions = completions ?? {};

  // Marquer comme fait pour aujourd'hui (binaire)
  void markCompleted(bool completed) {
    final today = _getDateKey(DateTime.now());
    completions[today] = completed;
  }

  // Enregistrer une valeur (quantitatif)
  void recordValue(double value) {
    final today = _getDateKey(DateTime.now());
    completions[today] = value;
  }

  // Vérifier si accompli aujourd'hui
  bool isCompletedToday() {
    final today = _getDateKey(DateTime.now());
    final value = completions[today];
    
    if (type == HabitType.binary) {
      return value == true;
    } else {
      return value != null && 
             targetValue != null && 
             (value as double) >= targetValue!;
    }
  }

  // Obtenir la valeur d'aujourd'hui
  dynamic getTodayValue() {
    final today = _getDateKey(DateTime.now());
    return completions[today];
  }

  // Calculer le taux de réussite (7 derniers jours)
  double getSuccessRate({int days = 7}) {
    final now = DateTime.now();
    var successfulDays = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];
      
      if (type == HabitType.binary && value == true) {
        successfulDays++;
      } else if (type == HabitType.quantitative && 
                 value != null && 
                 targetValue != null && 
                 (value as double) >= targetValue!) {
        successfulDays++;
      }
    }
    
    return successfulDays / days;
  }

  // Obtenir la série actuelle (streak)
  int getCurrentStreak() {
    final now = DateTime.now();
    var streak = 0;
    
    for (int i = 0; i < 365; i++) { // Max 1 an
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = completions[dateKey];
      
      bool isSuccess = false;
      if (type == HabitType.binary && value == true) {
        isSuccess = true;
      } else if (type == HabitType.quantitative && 
                 value != null && 
                 targetValue != null && 
                 (value as double) >= targetValue!) {
        isSuccess = true;
      }
      
      if (isSuccess) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Habit copyWith({
    String? name,
    String? description,
    HabitType? type,
    String? category,
    double? targetValue,
    String? unit,
    DateTime? createdAt,
    Map<String, dynamic>? completions,
    RecurrenceType? recurrenceType,
    int? intervalDays,
    List<int>? weekdays,
    int? timesTarget,
    int? monthlyDay,
    int? quarterMonth,
    int? yearlyMonth,
    int? yearlyDay,
    int? hourlyInterval,
    int? color,
    int? icon,
    int? currentStreak,
    String? userId,
    String? userEmail,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      completions: Map<String, dynamic>.from(completions ?? Map<String, dynamic>.from(this.completions)),
      recurrenceType: recurrenceType ?? this.recurrenceType,
      intervalDays: intervalDays ?? this.intervalDays,
      weekdays: weekdays ?? this.weekdays,
      timesTarget: timesTarget ?? this.timesTarget,
      monthlyDay: monthlyDay ?? this.monthlyDay,
      quarterMonth: quarterMonth ?? this.quarterMonth,
      yearlyMonth: yearlyMonth ?? this.yearlyMonth,
      yearlyDay: yearlyDay ?? this.yearlyDay,
      hourlyInterval: hourlyInterval ?? this.hourlyInterval,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      currentStreak: currentStreak ?? this.currentStreak,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  // Helpers pour l'UI
  Color get habitColor => color != null ? Color(color!) : Colors.blue;
  IconData get habitIcon => icon != null ? const IconData(0xe5ca, fontFamily: 'MaterialIcons') : const IconData(0xe5ca, fontFamily: 'MaterialIcons');
  int get habitCurrentStreak => currentStreak ?? 0;

  // JSON Serialization for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'category': category,
      'target_value': targetValue,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'completions': completions,
      'recurrence_type': recurrenceType?.name,
      'interval_days': intervalDays,
      'weekdays': weekdays,
      'times_target': timesTarget,
      'monthly_day': monthlyDay,
      'quarter_month': quarterMonth,
      'yearly_month': yearlyMonth,
      'yearly_day': yearlyDay,
      'hourly_interval': hourlyInterval,
      'color': color,
      'icon': icon,
      'current_streak': currentStreak,
      'user_id': userId,
      'user_email': userEmail,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: HabitType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HabitType.binary,
      ),
      category: json['category'] as String?,
      targetValue: json['target_value'] as double?,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completions: Map<String, dynamic>.from(json['completions'] as Map? ?? {}),
      recurrenceType: json['recurrence_type'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == json['recurrence_type'],
              orElse: () => RecurrenceType.dailyInterval,
            )
          : null,
      intervalDays: json['interval_days'] as int?,
      weekdays: (json['weekdays'] as List?)?.cast<int>(),
      timesTarget: json['times_target'] as int?,
      monthlyDay: json['monthly_day'] as int?,
      quarterMonth: json['quarter_month'] as int?,
      yearlyMonth: json['yearly_month'] as int?,
      yearlyDay: json['yearly_day'] as int?,
      hourlyInterval: json['hourly_interval'] as int?,
      color: json['color'] as int?,
      icon: json['icon'] as int?,
      currentStreak: json['current_streak'] as int?,
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
    );
  }

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, type: $type)';
  }
}
