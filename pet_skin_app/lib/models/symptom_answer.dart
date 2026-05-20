/// Holds the single-letter answer codes (A, B, C, D, E) for each
/// of the 6 symptom questions asked during diagnosis.
class SymptomAnswers {
  /// Q1: How long has the skin problem been present?
  /// A=<1 week, B=1-2 weeks, C=>2 weeks, D=Seasonal, E=No problem
  String? q1Duration;

  /// Q2: Is your dog scratching or licking the affected area?
  /// A=Normal, B=Mild, C=Frequent, D=Intense
  String? q2Scratching;

  /// Q3: What does the affected skin look like?
  /// A=Red patches, B=Hair loss, C=Flaky/scaly, D=Clean/normal, E=Bumps/scabs
  String? q3SkinLook;

  /// Q4: Is there any unusual smell from the skin?
  /// A=No smell, B=Mild smell, C=Strong smell
  String? q4Smell;

  /// Q5: Any recent environmental contact?
  /// A=Normal outdoor, B=Mostly indoors, C=Damp/humid, D=Near other dogs
  String? q5Environment;

  /// Q6: Has your dog's behavior changed?
  /// A=Normal, B=Restless, C=Uncomfortable/irritable
  String? q6Behavior;

  SymptomAnswers copyWith({
    String? q1Duration,
    String? q2Scratching,
    String? q3SkinLook,
    String? q4Smell,
    String? q5Environment,
    String? q6Behavior,
  }) {
    return SymptomAnswers()
      ..q1Duration = q1Duration ?? this.q1Duration
      ..q2Scratching = q2Scratching ?? this.q2Scratching
      ..q3SkinLook = q3SkinLook ?? this.q3SkinLook
      ..q4Smell = q4Smell ?? this.q4Smell
      ..q5Environment = q5Environment ?? this.q5Environment
      ..q6Behavior = q6Behavior ?? this.q6Behavior;
  }

  Map<String, dynamic> toMap() => {
    'q1Duration': q1Duration,
    'q2Scratching': q2Scratching,
    'q3SkinLook': q3SkinLook,
    'q4Smell': q4Smell,
    'q5Environment': q5Environment,
    'q6Behavior': q6Behavior,
  };
}
