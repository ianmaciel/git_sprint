import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  int _oauthCallbackPort = 27549;
  int get oauthCallbackPort => _oauthCallbackPort;
  String _oauthServerDomain = '';
  String get oauthServerDomain => _oauthServerDomain;
  String _oauthClientId = '';
  String get oauthClientId => _oauthClientId;
  String _oauthClientSecret = '';
  String get oauthClientSecret => _oauthClientSecret;

  // Allow Widgets to read the user's preferences.
  ThemeMode get themeMode => _themeMode;

  // Forms Keys and Controllers
  final GlobalKey<FormState> gitlabSettingsFormKey = GlobalKey<FormState>();
  final TextEditingController callbackPortTextController =
      TextEditingController(text: '27549');
  final TextEditingController oauthServerTextController =
      TextEditingController(text: 'https://gitlab.com');
  final TextEditingController oauthClientIdTextController =
      TextEditingController(text: '');
  final TextEditingController oauthClientSecretTextController =
      TextEditingController(text: '');

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _oauthCallbackPort = await _settingsService.oauthCallbackPort() ?? 27549;
    _oauthServerDomain =
        await _settingsService.oauthServerDomain() ?? 'https://gitlab.com';
    _oauthClientId = await _settingsService.oauthServerClientId() ?? '';
    _oauthClientSecret = await _settingsService.oauthServerClientSecret() ?? '';

    callbackPortTextController.text = _oauthCallbackPort.toString();
    oauthServerTextController.text = _oauthServerDomain;
    oauthClientIdTextController.text = _oauthClientId;
    oauthClientSecretTextController.text = _oauthClientSecret;

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  bool _validateFormFields() {
    return gitlabSettingsFormKey.currentState == null
        ? false
        : gitlabSettingsFormKey.currentState!.validate();
  }

  void applySettings() {
    if (_validateFormFields()) {
      int? port = int.tryParse(callbackPortTextController.text);
      if (port != null) updateOAuthCallbackPort(port);
      updateOAuthClientId(oauthClientIdTextController.text);
      updateOAuthClientSecret(oauthClientSecretTextController.text);
      updateOAuthServerDomain(oauthServerTextController.text);

      notifyListeners();
    }
  }

  bool canStartLogin() {
    try {
      Uri.parse(_oauthServerDomain);
    } catch (_) {
      return false;
    }

    return _oauthClientId.isNotEmpty &&
        _oauthClientSecret.isNotEmpty &&
        _oauthServerDomain.isNotEmpty;
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

  /// Update and persist the gitlab project id.
  Future<void> updateOAuthCallbackPort(int? newOauthCallbackPort) async {
    if (newOauthCallbackPort == null) {
      return;
    }

    // Dot not perform any work if new and old are identical
    if (newOauthCallbackPort == _oauthCallbackPort) return;

    // Otherwise, save.
    _oauthCallbackPort = newOauthCallbackPort;

    // Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateOAuthCallbackPort(newOauthCallbackPort);
  }

  /// Update and persist the gitlab project id.
  Future<void> updateOAuthServerDomain(String? newDomain) async {
    if (newDomain == null) {
      return;
    }

    // Dot not perform any work if new and old are identical
    if (newDomain == _oauthServerDomain) return;

    // Otherwise, save.
    _oauthServerDomain = newDomain;

    // Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateOAuthServerDomain(newDomain);
  }

  /// Update and persist the gitlab project id.
  Future<void> updateOAuthClientId(String? newClientId) async {
    if (newClientId == null) {
      return;
    }

    // Dot not perform any work if new and old are identical
    if (newClientId == _oauthClientId) return;

    // Otherwise, save.
    _oauthClientId = newClientId;

    // Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateOAuthClientId(newClientId);
  }

  /// Update and persist the oauth client secret.
  Future<void> updateOAuthClientSecret(String? newOAuthClientSecret) async {
    if (newOAuthClientSecret == null) {
      return;
    }

    // Dot not perform any work if new and old are identical
    if (newOAuthClientSecret == _oauthClientSecret) return;

    // Otherwise, save.
    _oauthClientSecret = newOAuthClientSecret;

    // Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateOAuthClientSecret(newOAuthClientSecret);
  }
}
