import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async {
    const defaultTheme = ThemeMode.system;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('userTheme') ?? defaultTheme.index;

    // Make sure it is a valid theme.
    if (index >= ThemeMode.values.length) {
      await updateThemeMode(defaultTheme);
      index = ThemeMode.system.index;
    }

    return ThemeMode.values.elementAt(index);
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userTheme', theme.index);
  }

  /// Loads the gitlab user's token.
  ///
  /// TODO double check if the token can be saved on shared-preferences.
  /// It might be necessary to use flutter_secure_storage instead.
  Future<String> gitlabToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('gitlabToken') ?? '';
  }

  /// Persists the gitlab user's token.
  ///
  /// TODO double check if the token can be saved on shared-preferences.
  /// It might be necessary to use flutter_secure_storage instead.
  Future<void> updateGitlabToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('gitlabToken', token);
  }

  /// Loads the gitlab projectId.
  Future<int?> gitlabProjectId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('gitlabProjectId');
  }

  /// Persists the gitlab user's token.
  Future<void> updateGitlabProjectId(int projectId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gitlabProjectId', projectId);
  }
}
