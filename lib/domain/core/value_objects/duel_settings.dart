/// Duel configuration options persisted for the Priorisé experience.
///
/// Applies SRP by encapsulating duel-related preferences.
enum DuelMode {
  /// Classic 1v1 duel where the user selects a single winner.
  winner,

  /// Ranking mode where all presented cards are ordered in a round.
  ranking,
}

class DuelSettings {
  static const int minCardsPerRound = 2;
  static const int maxCardsPerRound = 4;

  final DuelMode mode;
  final int cardsPerRound;
  final bool hideEloScores;

  const DuelSettings({
    required this.mode,
    required this.cardsPerRound,
    required this.hideEloScores,
  });

  const DuelSettings.defaults()
      : this(
          mode: DuelMode.winner,
          cardsPerRound: minCardsPerRound,
          hideEloScores: true,
        );

  DuelSettings copyWith({
    DuelMode? mode,
    int? cardsPerRound,
    bool? hideEloScores,
  }) {
    return DuelSettings(
      mode: mode ?? this.mode,
      cardsPerRound: _normalizeCards(cardsPerRound ?? this.cardsPerRound),
      hideEloScores: hideEloScores ?? this.hideEloScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'cardsPerRound': cardsPerRound,
      'hideEloScores': hideEloScores,
    };
  }

  factory DuelSettings.fromJson(Map<String, dynamic> json) {
    final rawMode = json['mode'] as String?;
    final parsedMode = DuelMode.values.firstWhere(
      (value) => value.name == rawMode,
      orElse: () => DuelMode.winner,
    );
    final rawCards = json['cardsPerRound'] as int? ?? minCardsPerRound;
    final hideElo = json['hideEloScores'] as bool? ?? true;

    return DuelSettings(
      mode: parsedMode,
      cardsPerRound: _normalizeCards(rawCards),
      hideEloScores: hideElo,
    );
  }

  static int _normalizeCards(int value) {
    if (value < minCardsPerRound) {
      return minCardsPerRound;
    }
    if (value > maxCardsPerRound) {
      return maxCardsPerRound;
    }
    return value;
  }

  @override
  String toString() {
    return 'DuelSettings(mode: $mode, cardsPerRound: $cardsPerRound, hideEloScores: $hideEloScores)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DuelSettings &&
        other.mode == mode &&
        other.cardsPerRound == cardsPerRound &&
        other.hideEloScores == hideEloScores;
  }

  @override
  int get hashCode => Object.hash(mode, cardsPerRound, hideEloScores);
}
