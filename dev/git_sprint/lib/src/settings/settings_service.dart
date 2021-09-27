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

  /// Loads the oauth callback port used by apps (not web).
  Future<int?> oauthCallbackPort() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('oauthCallbackPort');
  }

  /// Persists the oauth callback port used by apps (not web).
  Future<void> updateOAuthCallbackPort(int oauthCallbackPort) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('oauthCallbackPort', oauthCallbackPort);
  }

  /// Loads the oauth server domain.
  Future<String?> oauthServerDomain() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oauthServerDomain');
  }

  /// Persists the oauth server domain.
  Future<void> updateOAuthServerDomain(String domain) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthServerDomain', domain);
  }

  /// Loads the oauth server domain.
  Future<String?> oauthServerClientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oauthClientId');
  }

  /// Persists the oauth server domain.
  Future<void> updateOAuthClientId(String clientId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthClientId', clientId);
  }

  /// Loads the oauth server domain.
  Future<String?> oauthServerClientSecret() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oauthClientSecret');
  }

  /// Persists the oauth server domain.
  Future<void> updateOAuthClientSecret(String clientSecret) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthClientSecret', clientSecret);
  }
}
