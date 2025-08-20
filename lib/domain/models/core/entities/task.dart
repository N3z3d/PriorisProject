import 'dart:math';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  double eloScore;
  
  @HiveField(4)
  bool isCompleted;
  
  @HiveField(5)
  late DateTime createdAt;
  
  @HiveField(6)
  DateTime? completedAt;
  
  @HiveField(7)
  String? category;
  
  @HiveField(8)
  DateTime? dueDate;

  @HiveField(9)
  List<String> tags;

  @HiveField(10)
  int priority;

  @HiveField(11)
  late DateTime updatedAt;

  @HiveField(12)
  DateTime? lastChosenAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.eloScore = 1200.0, // Score Elo initial standard
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.category,
    this.dueDate,
    this.tags = const [],
    this.priority = 0,
    DateTime? updatedAt,
    this.lastChosenAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Calcul de la probabilité de victoire selon Elo
  double calculateWinProbability(Task opponent) {
    return 1.0 / (1.0 + pow(10.0, (opponent.eloScore - eloScore) / 400.0));
  }

  // Mise à jour du score Elo après un duel
  void updateEloScore(Task opponent, bool won, {double kFactor = 32.0}) {
    final expectedScore = calculateWinProbability(opponent);
    final actualScore = won ? 1.0 : 0.0;
    eloScore += kFactor * (actualScore - expectedScore);
  }

  Task copyWith({
    String? title,
    String? description,
    double? eloScore,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    DateTime? dueDate,
    List<String>? tags,
    int? priority,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      eloScore: eloScore ?? this.eloScore,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, eloScore: ${eloScore.toStringAsFixed(0)})';
  }
} 
