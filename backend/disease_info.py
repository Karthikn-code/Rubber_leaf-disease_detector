"""
Rubber Tree Disease Knowledge Base
Maps model prediction classes to full scientific disease information.

Dataset classes trained:
  - Anthracnose     → Colletotrichum Leaf Disease (Colletotrichum gloeosporioides)
  - Leaf_Spot       → Corynespora Leaf Fall       (Corynespora cassiicola)
  - Dry_Leaf        → Phytophthora Bark Rot        (drought/fungal stress complex)
  - Healthy         → No disease detected
"""

DISEASE_DATABASE = {
    "Anthracnose": {
        "scientific_name": "Colletotrichum gloeosporioides",
        "common_name": "Colletotrichum Leaf Disease / Anthracnose",
        "severity_level": "High",
        "severity_color": "RED",
        "symptoms": [
            "Dark brown to black necrotic lesions on leaf margins",
            "Sunken lesions with yellow halo rings",
            "Premature defoliation of young leaves",
            "Pink-orange spore masses (acervuli) in humid conditions",
            "Die-back of tender shoots in severe cases"
        ],
        "causes": "Fungal pathogen Colletotrichum gloeosporioides, spread by wind-borne spores and rain splash.",
        "favorable_conditions": "High humidity (>80%), temperatures 25-28°C, frequent rainfall.",
        "treatment": [
            "Apply copper-based fungicide (Bordeaux mixture 1%) at 2-week intervals",
            "Spray Mancozeb (0.2%) or Carbendazim (0.1%) on affected areas",
            "Remove and burn infected leaves immediately",
            "Reduce canopy density to improve air circulation"
        ],
        "prevention": [
            "Plant resistant rubber clones (RRIM 600, GT 1)",
            "Avoid overhead irrigation; use drip irrigation",
            "Apply prophylactic fungicide sprays before rainy season",
            "Maintain field sanitation — remove fallen leaves"
        ],
        "economic_impact": "Can cause 20-40% yield reduction if untreated during outbreak season.",
        "urgency": "Act within 48-72 hours of detection"
    },

    "Leaf_Spot": {
        "scientific_name": "Corynespora cassiicola",
        "common_name": "Corynespora Leaf Fall Disease",
        "severity_level": "Critical",
        "severity_color": "RED",
        "symptoms": [
            "Characteristic 'fish-bone' or 'herringbone' lesion pattern",
            "Large brown irregular spots with yellow borders",
            "Massive premature defoliation (complete leaf fall)",
            "Grayish fungal sporulation on lesion surface",
            "Repeated defoliation leading to branch die-back"
        ],
        "causes": "Fungal pathogen Corynespora cassiicola, extremely aggressive in susceptible clones.",
        "favorable_conditions": "Temperatures 25-32°C, high relative humidity, wet weather.",
        "treatment": [
            "Spray Hexaconazole (0.1%) or Propiconazole every 10 days",
            "Apply systemic fungicide (Trifloxystrobin + Tebuconazole)",
            "Trunk injection of fungicides for severe cases",
            "Remove all fallen infected leaves from field"
        ],
        "prevention": [
            "Plant Corynespora-resistant clones (RRIM 703, PB 235)",
            "Apply preventive fungicide sprays in high-risk seasons",
            "Monitor field fortnightly during monsoon",
            "Avoid monoculture planting in disease-endemic zones"
        ],
        "economic_impact": "One of the most devastating rubber diseases — can cause up to 60% yield loss.",
        "urgency": "Immediate action required — spread is rapid"
    },

    "Dry_Leaf": {
        "scientific_name": "Phytophthora meadii / Water stress complex",
        "common_name": "Phytophthora Bark Rot / Dry Leaf Syndrome",
        "severity_level": "Medium",
        "severity_color": "ORANGE",
        "symptoms": [
            "Yellowing and drying of leaf edges (margin scorch)",
            "Brown papery texture of affected leaves",
            "Dark water-soaked lesions on bark near soil level",
            "Latex exudation / bleeding from bark",
            "Generalized wilting and canopy thinning"
        ],
        "causes": "Combination of Phytophthora spp. infection, drought stress, and nutrient deficiency.",
        "favorable_conditions": "Waterlogged soils, excessive tapping, poorly drained fields.",
        "treatment": [
            "Apply Metalaxyl or Fosetyl-Al (Aliette) to soil and bark",
            "Paint trunk with Bordeaux paste (10%) on lesion areas",
            "Irrigate field if drought-related; improve drainage if waterlogged",
            "Apply balanced NPK fertilizer (12:6:20) to recover nutrition"
        ],
        "prevention": [
            "Ensure proper field drainage before planting",
            "Avoid wounding during tapping — use sharp clean knives",
            "Apply bark protectants annually during rainy season",
            "Reduce tapping frequency on stressed trees"
        ],
        "economic_impact": "Persistent infection can kill tapping panels, reducing latex yields by 30-50%.",
        "urgency": "Monitor for 1 week; apply treatment if not improving"
    },

    "Healthy": {
        "scientific_name": "N/A",
        "common_name": "Healthy Rubber Leaf",
        "severity_level": "None",
        "severity_color": "GREEN",
        "symptoms": [
            "Uniform dark green leaf color",
            "No visible lesions, spots, or discoloration",
            "Firm leaf texture",
            "Normal leaf size and shape"
        ],
        "causes": "No disease detected.",
        "favorable_conditions": "N/A",
        "treatment": [
            "No treatment required",
            "Continue regular crop maintenance schedule"
        ],
        "prevention": [
            "Maintain regular scouting (fortnightly observation)",
            "Keep field records of any changes in leaf color or texture",
            "Apply scheduled fertilization as per crop calendar",
            "Ensure proper canopy management and pruning"
        ],
        "economic_impact": "No impact — tree is in healthy condition.",
        "urgency": "No action required"
    }
}


def get_disease_info(label: str) -> dict:
    """Return full disease information for a predicted class label."""
    return DISEASE_DATABASE.get(label, {
        "common_name": label,
        "severity_level": "Unknown",
        "severity_color": "GREY",
        "symptoms": [],
        "treatment": ["Consult a local agricultural extension officer"],
        "prevention": [],
        "urgency": "Consult expert",
        "economic_impact": "Unknown"
    })
