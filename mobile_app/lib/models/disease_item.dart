import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class DiseaseItem {
  final String name, classLabel, severity, emoji, scientificName;
  final Color color;
  final List<String> symptoms, treatment, prevention;
  final String rootCause, economicImpact;

  const DiseaseItem({
    required this.name, required this.classLabel, required this.severity,
    required this.emoji, required this.scientificName, required this.color,
    required this.symptoms, required this.treatment, required this.prevention,
    required this.rootCause, required this.economicImpact,
  });

  Map<String, dynamic> toMap() => {
    'common_name': name,
    'scientific_name': scientificName,
    'severity_level': severity,
    'severity_color': color == Colors.red ? 'RED' : (color == Colors.orange ? 'ORANGE' : 'GREEN'),
    'symptoms': symptoms,
    'causes': rootCause,
    'treatment': treatment,
    'prevention': prevention,
    'economic_impact': economicImpact,
    'urgency': severity == 'Critical' ? 'Immediate attention' : (severity == 'High' ? 'Treat immediately' : 'Monitor closely'),
  };

  static final List<DiseaseItem> all = [
    const DiseaseItem(
      name: 'Colletotrichum Leaf Disease',
      classLabel: 'Anthracnose',
      scientificName: 'Colletotrichum gloeosporioides',
      severity: 'High',
      color: kRed,
      emoji: '🍂',
      symptoms: [
        'Dark brown to black necrotic lesions on leaf margins',
        'Sunken lesions with yellow halo rings',
        'Premature defoliation of young leaves',
        'Pink-orange spore masses in humid conditions',
        'Die-back of tender shoots in severe cases'
      ],
      rootCause: 'Fungal pathogen spread by wind-borne spores and rain splash.',
      treatment: [
        'Apply copper-based fungicide at 2-week intervals',
        'Spray Mancozeb (0.2%) or Carbendazim (0.1%) on affected areas',
        'Remove and burn infected leaves immediately',
        'Reduce canopy density to improve air circulation'
      ],
      prevention: [
        'Plant resistant rubber clones (RRIM 600, GT 1)',
        'Avoid overhead irrigation; use drip irrigation',
        'Apply prophylactic fungicide sprays before rainy season',
        'Maintain field sanitation — remove fallen leaves'
      ],
      economicImpact: 'Can cause 20-40% yield reduction if untreated during outbreak season.',
    ),
    const DiseaseItem(
      name: 'Corynespora Leaf Fall',
      classLabel: 'Leaf_Spot',
      scientificName: 'Corynespora cassiicola',
      severity: 'Critical',
      color: kPurple,
      emoji: '🌀',
      symptoms: [
        "Characteristic 'fish-bone' or 'herringbone' lesion pattern",
        'Large brown irregular spots with yellow borders',
        'Massive premature defoliation (complete leaf fall)',
        'Grayish fungal sporulation on lesion surface',
        'Repeated defoliation leading to branch die-back'
      ],
      rootCause: 'Aggressive fungal pathogen, extremely active in susceptible clones.',
      treatment: [
        'Spray Hexaconazole (0.1%) or Propiconazole every 10 days',
        'Apply systemic fungicide (Trifloxystrobin + Tebuconazole)',
        'Trunk injection of fungicides for severe cases',
        'Remove all fallen infected leaves from field'
      ],
      prevention: [
        'Plant Corynespora-resistant clones (RRIM 703, PB 235)',
        'Apply preventive fungicide sprays in high-risk seasons',
        'Monitor field fortnightly during monsoon',
        'Avoid monoculture planting in disease-endemic zones'
      ],
      economicImpact: 'One of the most devastating diseases — can cause up to 60% yield loss.',
    ),
    const DiseaseItem(
      name: 'Phytophthora Bark Rot',
      classLabel: 'Dry_Leaf',
      scientificName: 'Phytophthora meadii',
      severity: 'Medium',
      color: kOrange,
      emoji: '🪵',
      symptoms: [
        'Yellowing and drying of leaf edges (margin scorch)',
        'Brown papery texture of affected leaves',
        'Dark water-soaked lesions on bark near soil level',
        'Latex exudation / bleeding from bark',
        'Generalized wilting and canopy thinning'
      ],
      rootCause: 'Combination of Phytophthora infection, drought stress, and nutrient deficiency.',
      treatment: [
        'Apply Metalaxyl or Fosetyl-Al to soil and bark',
        'Paint trunk with Bordeaux paste (10%) on lesion areas',
        'Irrigate field if drought-related; improve drainage if waterlogged',
        'Apply balanced NPK fertilizer (12:6:20) to recover nutrition'
      ],
      prevention: [
        'Ensure proper field drainage before planting',
        'Avoid wounding during tapping — use sharp clean knives',
        'Apply bark protectants annually during rainy season',
        'Reduce tapping frequency on stressed trees'
      ],
      economicImpact: 'Persistent infection can kill tapping panels, reducing latex yields by 30-50%.',
    ),
    const DiseaseItem(
      name: 'Healthy Leaf',
      classLabel: 'Healthy',
      scientificName: 'N/A',
      severity: 'None',
      color: kGreen,
      emoji: '✅',
      symptoms: [
        'Uniform dark green leaf color',
        'No visible lesions, spots, or discoloration',
        'Firm leaf texture',
        'Normal leaf size and shape'
      ],
      rootCause: 'No disease detected.',
      treatment: [
        'No treatment required',
        'Continue regular crop maintenance schedule'
      ],
      prevention: [
        'Maintain regular scouting (fortnightly observation)',
        'Keep field records of any changes in leaf color or texture',
        'Apply scheduled fertilization as per crop calendar',
        'Ensure proper canopy management and pruning'
      ],
      economicImpact: 'No impact — tree is in healthy condition.',
    ),
  ];
}
