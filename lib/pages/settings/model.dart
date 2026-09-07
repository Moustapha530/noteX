
class SettingsState {
  final String selectedLanguage;
  final String selectedTheme;
  final bool syncEnabled;
  final bool notificationsEnabled;
  final bool autoSaveEnabled;

  SettingsState({
    this.selectedLanguage = 'system',
    this.selectedTheme = 'system',
    this.syncEnabled = true,
    this.notificationsEnabled = true,
    this.autoSaveEnabled = true,
  });

  SettingsState copyWith({
    String? selectedLanguage,
    String? selectedTheme,
    bool? syncEnabled,
    bool? notificationsEnabled,
    bool? autoSaveEnabled,
  }) {
    return SettingsState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }
}