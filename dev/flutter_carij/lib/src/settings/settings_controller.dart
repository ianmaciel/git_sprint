import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make prerences a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late String _gitlabToken;
  int? _gitlabProjectId;

  // Allow Widgets to read the user's preferences.
  ThemeMode get themeMode => _themeMode;
  String get gitlabToken => _gitlabToken;
  int? get gitlabProjectId => _gitlabProjectId;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _gitlabToken = await _settingsService.gitlabToken();
    _gitlabProjectId = await _settingsService.gitlabProjectId();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Dot not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new theme mode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  /// Update and persist the gitlab access token.
  Future<void> updateGitlabToken(String newToken) async {
    // Dot not perform any work if new and old token are identical
    if (newToken == _gitlabToken) return;

    // Otherwise, store the new token mode in memory
    _gitlabToken = newToken;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateGitlabToken(newToken);
  }

  /// Update and persist the gitlab project id.
  Future<void> updateGitlabProjectId(int? newProjectId) async {
    if (newProjectId == null) {
      return;
    }

    // Dot not perform any work if new and old token are identical
    if (newProjectId == _gitlabProjectId) return;

    // Otherwise, store the new token mode in memory
    _gitlabProjectId = newProjectId;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateGitlabProjectId(newProjectId);
  }
}
