import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gitsprint/src/login/login_controller.dart';

import 'package:provider/provider.dart';

import 'board_feature/gitlab_controller.dart';
import 'board_feature/issue_board_view.dart';
import 'login/login_view.dart';
import 'login/redirected_after_login_view.dart';
import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key) {
    _loginController = LoginController(settingsController);
  }

  final SettingsController settingsController;
  late final LoginController _loginController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return AnimatedBuilder(
      animation: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: <ChangeNotifierProvider<dynamic>>[
            ChangeNotifierProvider<SettingsController>.value(
                value: settingsController),
            ChangeNotifierProvider<GitlabController>(
              create: (_) =>
                  GitlabController(_loginController, settingsController),
              lazy: true,
            ),
            ChangeNotifierProvider<LoginController>.value(
                value: _loginController),
          ],
          child: MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            //restorationScopeId: 'gitsprint',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
              Locale('pt', 'BR')
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,

            initialRoute: LoginView.routeName,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: (RouteSettings routeSettings) {
              if (routeSettings.name == '/') {
                return null;
              }

              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  switch (routeSettings.name) {
                    case IssueBoardView.routeName:
                      return IssueBoardView();
                    case LoginView.routeName:
                      return const LoginView();
                    case RedirectedAfterLoginView.routeName:
                    case SampleItemDetailsView.routeName:
                      return const SampleItemDetailsView();
                    case SampleItemListView.routeName:
                      return const SampleItemListView();
                    case SettingsView.routeName:
                      return const SettingsView();
                    default:
                      if (routeSettings.name != null &&
                          routeSettings.name!
                              .startsWith(RedirectedAfterLoginView.routeName)) {
                        return RedirectedAfterLoginView(routeSettings.name!);
                      } else {
                        return const LoginView();
                      }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
