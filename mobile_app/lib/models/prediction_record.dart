
class PredictionRecord {
  final String imagePath, label, commonName, severity, urgency;
  final double confidence;
  final DateTime timestamp;
  final Map<String, double> allScores;
  final double? latitude;
  final double? longitude;

  PredictionRecord({
    required this.imagePath, required this.label,
    required this.commonName, required this.confidence,
    required this.severity, required this.urgency,
    required this.timestamp, required this.allScores,
    this.latitude, this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'imagePath': imagePath, 'label': label, 'commonName': commonName,
    'severity': severity, 'urgency': urgency, 'confidence': confidence,
    'timestamp': timestamp.toIso8601String(), 'allScores': allScores,
    'latitude': latitude, 'longitude': longitude,
  };

  factory PredictionRecord.fromMap(Map<String, dynamic> m) => PredictionRecord(
    imagePath: m['imagePath'] ?? '',
    label: m['label'] ?? '',
    commonName: m['commonName'] ?? '',
    severity: m['severity'] ?? '',
    urgency: m['urgency'] ?? '',
    confidence: (m['confidence'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
    allScores: (m['allScores'] as Map?)?.cast<String, num>().map((k, v) => MapEntry(k, v.toDouble())) ?? {},
    latitude: (m['latitude'] as num?)?.toDouble(),
    longitude: (m['longitude'] as num?)?.toDouble(),
  );
}
