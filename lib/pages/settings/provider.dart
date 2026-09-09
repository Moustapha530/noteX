import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_x/pages/settings/model.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      selectedLanguage: prefs.getString('selectedLanguage') ?? 'system',
      selectedTheme: prefs.getString('selectedTheme') ?? 'system',
      syncEnabled: prefs.getBool('syncEnabled') ?? true,
      notificationsEnabled: prefs.getBool('notificationsEnabled') ?? true,
      autoSaveEnabled: prefs.getBool('autoSaveEnabled') ?? true,
    );
  }

  Future<void> updateLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
    state = state.copyWith(selectedLanguage: language);
  }

  Future<void> updateTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', theme);
    state = state.copyWith(selectedTheme: theme);
  }

  Future<void> updateFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
    state = state.copyWith(fontSize: fontSize);
  }

  Future<void> toggleSync(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncEnabled', enabled);
    state = state.copyWith(syncEnabled: enabled);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  Future<void> toggleAutoSave(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSaveEnabled', enabled);
    state = state.copyWith(autoSaveEnabled: enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});