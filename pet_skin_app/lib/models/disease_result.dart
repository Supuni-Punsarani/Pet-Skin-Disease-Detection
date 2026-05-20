class DiseaseResult {
  final String diseaseName;
  final double confidence;
  final String severity; // Mild / Moderate / Severe / None
  final String petType;
  final DateTime dateTime;
  final List<String> matchedSymptoms;
  final List<String> treatments;
  final String description;
  final String urgency;

  DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.petType,
    required this.dateTime,
    required this.matchedSymptoms,
    required this.treatments,
    required this.description,
    required this.urgency,
  });

  /// Create a [DiseaseResult] from the JSON response returned by the FastAPI backend.
  factory DiseaseResult.fromJson(
    Map<String, dynamic> json, {
    required String petType,
  }) {
    return DiseaseResult(
      diseaseName: json['disease'] as String? ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: json['severity'] as String? ?? 'Unknown',
      urgency: json['urgency'] as String? ?? '',
      description: json['description'] as String? ?? '',
      treatments: List<String>.from(json['treatments'] as List? ?? []),
      matchedSymptoms:
          List<String>.from(json['matched_symptoms'] as List? ?? []),
      petType: petType,
      dateTime: DateTime.now(),
    );
  }
}
