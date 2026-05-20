class ProfileSettings {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String company;
  final String timezone;
  final String language;
  final String occupation;
  final String goal;
  final String experienceLevel;
  final bool receiveNews;
  final int currentStep;
  final bool isCompleted;

  ProfileSettings({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.country = '',
    this.company = '',
    this.timezone = '(UTC -11:00) Pacific/Niue',
    this.language = 'English',
    this.occupation = '',
    this.goal = '',
    this.experienceLevel = '',
    this.receiveNews = false,
    this.currentStep = 1,
    this.isCompleted = false,
  });

  ProfileSettings copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? country,
    String? company,
    String? timezone,
    String? language,
    String? occupation,
    String? goal,
    String? experienceLevel,
    bool? receiveNews,
    int? currentStep,
    bool? isCompleted,
  }) {
    return ProfileSettings(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      country: country ?? this.country,
      company: company ?? this.company,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      occupation: occupation ?? this.occupation,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      receiveNews: receiveNews ?? this.receiveNews,
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Check validity for Step 1
  bool get isStep1Valid {
    if (firstName.trim().isEmpty) return false;
    if (lastName.trim().isEmpty) return false;
    if (email.trim().isEmpty) return false;
    // Basic email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email.trim())) return false;
    if (country.trim().isEmpty) return false;
    return true;
  }

  // Check validity for Step 2
  bool get isStep2Valid {
    if (timezone.trim().isEmpty) return false;
    if (language.trim().isEmpty) return false;
    return true;
  }

  // Read from storage Map
  factory ProfileSettings.fromMap(Map<String, dynamic> map) {
    return ProfileSettings(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      country: map['country'] ?? '',
      company: map['company'] ?? '',
      timezone: map['timezone'] ?? '(UTC -11:00) Pacific/Niue',
      language: map['language'] ?? 'English',
      occupation: map['occupation'] ?? '',
      goal: map['goal'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      receiveNews: map['receiveNews'] ?? false,
      currentStep: map['currentStep'] ?? 1,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  // Convert to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'country': country,
      'company': company,
      'timezone': timezone,
      'language': language,
      'occupation': occupation,
      'goal': goal,
      'experienceLevel': experienceLevel,
      'receiveNews': receiveNews,
      'currentStep': currentStep,
      'isCompleted': isCompleted,
    };
  }
}
