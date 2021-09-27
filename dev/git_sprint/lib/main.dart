import 'package:flutter/material.dart';

import 'src/app.dart';

import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  bool isInRelease = true;

  assert(() {
    //isInRelease = false;
    return true;
  }());

  if (isInRelease) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Configure the app tu use url strategy:
  // https://flutter.dev/docs/development/ui/navigation/url-strategies
  // This is required to configure the redirect_uri from Gitlab login;
  configureApp();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
