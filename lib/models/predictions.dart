class Predictions {
  List<dynamic> predictions;

  Predictions({
    required this.predictions,
  });

  factory Predictions.fromJson(Map<String, dynamic> json) {
    return Predictions(
      predictions: json["predictions"],
    );
  }
}