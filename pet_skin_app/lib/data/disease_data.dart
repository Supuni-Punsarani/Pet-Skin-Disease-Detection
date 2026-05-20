import '../models/symptom_answer.dart';
import '../models/disease_result.dart';

class _DiseaseTemplate {
  final String name;
  final String description;
  // Answer codes that score for this disease (per question)
  final List<String> q1Codes; // duration
  final List<String> q2Codes; // scratching
  final List<String> q3Codes; // skin look
  final List<String> q4Codes; // smell
  final List<String> q5Codes; // environment
  final List<String> q6Codes; // behavior
  final List<String> treatments;
  final String urgency;
  final String severity;

  const _DiseaseTemplate({
    required this.name,
    required this.description,
    required this.q1Codes,
    required this.q2Codes,
    required this.q3Codes,
    required this.q4Codes,
    required this.q5Codes,
    required this.q6Codes,
    required this.treatments,
    required this.urgency,
    required this.severity,
  });
}

class DiseaseDatabase {
  static const List<_DiseaseTemplate> _diseases = [
    _DiseaseTemplate(
      name: 'Bacterial Dermatosis',
      description:
          'A bacterial skin infection caused by Staphylococcus or other bacteria. Often secondary to allergies or skin trauma. Presents as pustules, crusts, or sores.',
      q1Codes: ['B', 'C'],        // 1–2 weeks or >2 weeks
      q2Codes: ['B', 'C'],        // Mild or frequent
      q3Codes: ['A', 'E'],        // Red or bumps/scabs
      q4Codes: ['B', 'C'],        // Mild or strong smell
      q5Codes: ['A', 'B'],        // Outdoor or indoors
      q6Codes: ['B'],             // Restless
      treatments: [
        'Oral antibiotics for 3–6 weeks (as directed by vet)',
        'Antibacterial medicated shampoo 2–3 times per week',
        'Identify and treat underlying cause (allergies, parasites)',
        'Topical antibiotic cream for localized areas',
        'Follow-up culture if recurrent to identify specific bacteria',
      ],
      urgency: 'See vet within 2–3 days',
      severity: 'Moderate',
    ),
    _DiseaseTemplate(
      name: 'Demodicosis',
      description:
          'Demodectic mange caused by Demodex mites living in hair follicles. Localized forms are often mild; generalized demodicosis requires treatment.',
      q1Codes: ['C', 'D'],        // >2 weeks or seasonal
      q2Codes: ['B', 'C'],        // Mild or frequent scratching
      q3Codes: ['B', 'E'],        // Hair loss, scabs
      q4Codes: ['A'],             // No smell
      q5Codes: ['B', 'D'],        // Indoors or near other dogs
      q6Codes: ['A', 'B'],        // Normal or restless
      treatments: [
        'Topical or oral antiparasitic treatment (Fluralaner, Afoxolaner, or Ivermectin)',
        'Benzoyl peroxide shampoo to flush follicles',
        'Treat any secondary bacterial infection with antibiotics',
        'Monthly follow-up skin scrapes to confirm clearance',
        'Boost immune system — address underlying conditions',
      ],
      urgency: 'See vet within 1 week',
      severity: 'Moderate',
    ),
    _DiseaseTemplate(
      name: 'Fungal Infections',
      description:
          'Fungal skin infection which may include ringworm (dermatophytosis) or yeast overgrowth (Malassezia). Presents with itching, scaling, and hair loss.',
      q1Codes: ['B', 'C', 'D'],   // 1–2 weeks, >2 weeks, or seasonal
      q2Codes: ['C'],             // Frequent scratching/licking
      q3Codes: ['B', 'C'],        // Hair loss or Flaky/greasy/scaly
      q4Codes: ['C'],             // Strong smell
      q5Codes: ['C'],             // Damp/humid
      q6Codes: ['B', 'C'],        // Restless or uncomfortable
      treatments: [
        'Topical antifungal (miconazole, clotrimazole, or ketoconazole shampoo)',
        'Oral antifungal medication for systemic or severe cases',
        'Keep affected areas clean and dry',
        'Isolate the pet if ringworm is suspected — zoonotic risk',
        'Treatment continues 2 weeks beyond clinical resolution',
      ],
      urgency: 'See vet within 1 week',
      severity: 'Moderate',
    ),
    _DiseaseTemplate(
      name: 'Healthy',
      description:
          'No abnormal skin condition detected. Your dog\'s skin appears to be healthy. Continue regular grooming and preventive care.',
      q1Codes: ['E'],             // No problem
      q2Codes: ['A'],             // Normal scratching
      q3Codes: ['D'],             // Clean and normal
      q4Codes: ['A'],             // No smell
      q5Codes: ['A', 'B'],        // Normal
      q6Codes: ['A'],             // Acting normally
      treatments: [
        'Continue regular grooming and brushing',
        'Maintain a balanced diet with omega-3 fatty acids',
        'Keep up with flea and parasite prevention',
        'Schedule annual vet checkups for skin health monitoring',
      ],
      urgency: 'No immediate action needed',
      severity: 'None',
    ),
    _DiseaseTemplate(
      name: 'Hypersensitivity Dermatitis',
      description:
          'An allergic skin reaction (atopic dermatitis, flea allergy, or food allergy) causing intense itching, redness, and skin inflammation.',
      q1Codes: ['D'],             // Seasonal
      q2Codes: ['D'],             // Intense scratching
      q3Codes: ['A', 'E'],        // Red patches, bumps
      q4Codes: ['A', 'B'],        // No smell or mild
      q5Codes: ['C'],             // Allergens / Damp
      q6Codes: ['C'],             // Uncomfortable/irritable
      treatments: [
        'Identify and eliminate the allergen (food, fleas, environmental)',
        'Antihistamines or corticosteroids to control itching',
        'Immunotherapy (allergy shots) for long-term atopic management',
        'Monthly flea prevention for all pets in the household',
        'Hypoallergenic diet trial if food allergy is suspected',
      ],
      urgency: 'See vet this week',
      severity: 'Moderate',
    ),
    _DiseaseTemplate(
      name: 'Ringworm',
      description:
          'Ringworm (Dermatophytosis) is a contagious fungal infection affecting skin, hair, and nails. Presents as circular bald patches with scaling.',
      q1Codes: ['B', 'C'],        // 1-2 weeks or >2 weeks
      q2Codes: ['B'],             // Mild scratching
      q3Codes: ['B', 'C'],        // Hair loss or flaky
      q4Codes: ['A'],             // No smell
      q5Codes: ['D'],             // Near other animals
      q6Codes: ['A', 'B'],        // Normal or restless
      treatments: [
        'Topical antifungal treatment (clotrimazole or miconazole)',
        'Oral antifungal medication for widespread or severe cases',
        'Antifungal shampoo (lime sulfur dip or ketoconazole) twice weekly',
        'Isolate the pet — ringworm is contagious to humans and other pets',
        'Minimum 6–8 weeks of treatment; confirm clearance with fungal culture',
      ],
      urgency: 'See vet within 1 week',
      severity: 'Moderate',
    ),
  ];

  static DiseaseResult diagnose(SymptomAnswers answers, String petType) {
    int bestScore = -1;
    _DiseaseTemplate bestDisease = _diseases.last; // default: Healthy

    for (final disease in _diseases) {
      int score = 0;
      if (answers.q1Duration != null &&
          disease.q1Codes.contains(answers.q1Duration)) { score += 2; }
      if (answers.q2Scratching != null &&
          disease.q2Codes.contains(answers.q2Scratching)) { score += 3; }
      if (answers.q3SkinLook != null &&
          disease.q3Codes.contains(answers.q3SkinLook)) { score += 3; }
      if (answers.q4Smell != null &&
          disease.q4Codes.contains(answers.q4Smell)) { score += 2; }
      if (answers.q5Environment != null &&
          disease.q5Codes.contains(answers.q5Environment)) { score += 1; }
      if (answers.q6Behavior != null &&
          disease.q6Codes.contains(answers.q6Behavior)) { score += 1; }

      if (score > bestScore) {
        bestScore = score;
        bestDisease = disease;
      }
    }

    // Confidence: 50–95% based on score (max possible = 12)
    final confidence = ((50 + (bestScore * 3).clamp(0, 45)) / 100.0);

    final matched = <String>[];
    if (answers.q1Duration != null) matched.add('Duration: ${_q1Label(answers.q1Duration!)}');
    if (answers.q2Scratching != null) matched.add('Scratching: ${_q2Label(answers.q2Scratching!)}');
    if (answers.q3SkinLook != null) matched.add('Skin: ${_q3Label(answers.q3SkinLook!)}');
    if (answers.q4Smell != null) matched.add('Smell: ${_q4Label(answers.q4Smell!)}');

    return DiseaseResult(
      diseaseName: bestDisease.name,
      confidence: confidence,
      severity: bestDisease.severity,
      petType: petType,
      dateTime: DateTime.now(),
      matchedSymptoms: matched,
      treatments: bestDisease.treatments,
      description: bestDisease.description,
      urgency: bestDisease.urgency,
    );
  }

  static String _q1Label(String code) {
    const m = {'A': '<1 week', 'B': '1–2 weeks', 'C': '>2 weeks', 'D': 'Seasonal', 'E': 'No problem'};
    return m[code] ?? code;
  }

  static String _q2Label(String code) {
    const m = {'A': 'Normal', 'B': 'Mild', 'C': 'Frequent', 'D': 'Intense'};
    return m[code] ?? code;
  }

  static String _q3Label(String code) {
    const m = {'A': 'Red patches', 'B': 'Hair loss', 'C': 'Flaky/scaly', 'D': 'Clean/normal', 'E': 'Bumps/scabs'};
    return m[code] ?? code;
  }

  static String _q4Label(String code) {
    const m = {'A': 'No smell', 'B': 'Mild smell', 'C': 'Strong smell'};
    return m[code] ?? code;
  }
}
