/// Model representing trend analysis results
class TrendAnalysis {
  final String direction;
  final double confidence;
  final double? prediction;
  final double? slope;

  TrendAnalysis({
    required this.direction,
    required this.confidence,
    this.prediction,
    this.slope,
  });
}
