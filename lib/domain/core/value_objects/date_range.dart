/// Value Object représentant une plage de dates
/// 
/// Utilisé pour définir des périodes de temps dans les habitudes,
/// les statistiques et les filtres temporels.
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange._({
    required this.start,
    required this.end,
  });

  /// Crée une plage de dates avec validation
  factory DateRange.create({
    required DateTime start,
    required DateTime end,
  }) {
    if (end.isBefore(start)) {
      throw ArgumentError('La date de fin ne peut pas être antérieure à la date de début');
    }

    return DateRange._(start: start, end: end);
  }

  /// Crée une plage pour aujourd'hui
  factory DateRange.today() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return DateRange._(start: today, end: tomorrow);
  }

  /// Crée une plage pour cette semaine (lundi à dimanche)
  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final mondayOffset = (now.weekday - 1) % 7;
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: mondayOffset));
    final sunday = monday.add(const Duration(days: 7));
    
    return DateRange._(start: monday, end: sunday);
  }

  /// Crée une plage pour ce mois
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return DateRange._(start: firstDay, end: nextMonth);
  }

  /// Crée une plage pour cette année
  factory DateRange.thisYear() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final nextYear = DateTime(now.year + 1, 1, 1);
    
    return DateRange._(start: firstDay, end: nextYear);
  }

  /// Crée une plage pour les N derniers jours
  factory DateRange.lastDays(int days) {
    if (days <= 0) {
      throw ArgumentError('Le nombre de jours doit être positif');
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: days - 1));
    final end = today.add(const Duration(days: 1));
    
    return DateRange._(start: start, end: end);
  }

  /// Crée une plage pour les N dernières semaines
  factory DateRange.lastWeeks(int weeks) {
    if (weeks <= 0) {
      throw ArgumentError('Le nombre de semaines doit être positif');
    }

    final now = DateTime.now();
    final mondayOffset = (now.weekday - 1) % 7;
    final thisMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: mondayOffset));
    final start = thisMonday.subtract(Duration(days: (weeks - 1) * 7));
    final end = thisMonday.add(const Duration(days: 7));
    
    return DateRange._(start: start, end: end);
  }

  /// Crée une plage pour les N derniers mois
  factory DateRange.lastMonths(int months) {
    if (months <= 0) {
      throw ArgumentError('Le nombre de mois doit être positif');
    }

    final now = DateTime.now();
    final start = DateTime(now.year, now.month - months + 1, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    
    return DateRange._(start: start, end: end);
  }

  /// Durée en jours de la plage
  int get durationInDays {
    return end.difference(start).inDays;
  }

  /// Durée en heures de la plage
  int get durationInHours {
    return end.difference(start).inHours;
  }

  /// Vérifie si une date est dans la plage
  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
           date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end);
  }

  /// Vérifie si cette plage chevauche avec une autre
  bool overlapsWith(DateRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  /// Vérifie si cette plage englobe complètement une autre
  bool encompasses(DateRange other) {
    return start.isBefore(other.start) && end.isAfter(other.end) ||
           start.isAtSameMomentAs(other.start) && end.isAtSameMomentAs(other.end);
  }

  /// Retourne l'intersection avec une autre plage
  DateRange? intersectionWith(DateRange other) {
    if (!overlapsWith(other)) return null;

    final intersectionStart = start.isAfter(other.start) ? start : other.start;
    final intersectionEnd = end.isBefore(other.end) ? end : other.end;

    return DateRange.create(start: intersectionStart, end: intersectionEnd);
  }

  /// Retourne l'union avec une autre plage
  DateRange unionWith(DateRange other) {
    final unionStart = start.isBefore(other.start) ? start : other.start;
    final unionEnd = end.isAfter(other.end) ? end : other.end;

    return DateRange.create(start: unionStart, end: unionEnd);
  }

  /// Étend la plage de N jours
  DateRange extendByDays(int days) {
    return DateRange.create(
      start: start,
      end: end.add(Duration(days: days)),
    );
  }

  /// Décale la plage de N jours
  DateRange shiftByDays(int days) {
    final duration = Duration(days: days);
    return DateRange.create(
      start: start.add(duration),
      end: end.add(duration),
    );
  }

  /// Génère une liste de dates dans la plage
  List<DateTime> generateDates() {
    final dates = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Retourne le libellé de la plage
  String get label {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (durationInDays == 1 && contains(todayDate)) {
      return 'Aujourd\'hui';
    } else if (durationInDays == 7) {
      return 'Cette semaine';
    } else if (start.month == end.subtract(const Duration(days: 1)).month) {
      return 'Ce mois';
    } else if (durationInDays > 300) {
      return 'Cette année';
    } else {
      return '$durationInDays jours';
    }
  }

  /// Formate la plage pour l'affichage
  String format({String separator = ' - '}) {
    final startStr = '${start.day}/${start.month}/${start.year}';
    final endStr = '${end.day}/${end.month}/${end.year}';
    return '$startStr$separator$endStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() {
    return 'DateRange(${start.toIso8601String()} - ${end.toIso8601String()})';
  }

  /// Sérialisation JSON
  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };

  /// Désérialisation JSON
  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange.create(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );
  }
}

/// Énumération des types de plages prédéfinies
enum DateRangeType {
  today('Aujourd\'hui'),
  thisWeek('Cette semaine'),
  thisMonth('Ce mois'),
  thisYear('Cette année'),
  last7Days('7 derniers jours'),
  last30Days('30 derniers jours'),
  last90Days('90 derniers jours'),
  custom('Personnalisée');

  const DateRangeType(this.label);

  final String label;

  /// Crée une plage de dates basée sur le type
  DateRange createRange() {
    switch (this) {
      case DateRangeType.today:
        return DateRange.today();
      case DateRangeType.thisWeek:
        return DateRange.thisWeek();
      case DateRangeType.thisMonth:
        return DateRange.thisMonth();
      case DateRangeType.thisYear:
        return DateRange.thisYear();
      case DateRangeType.last7Days:
        return DateRange.lastDays(7);
      case DateRangeType.last30Days:
        return DateRange.lastDays(30);
      case DateRangeType.last90Days:
        return DateRange.lastDays(90);
      case DateRangeType.custom:
        throw ArgumentError('Une plage personnalisée doit être créée manuellement');
    }
  }
}