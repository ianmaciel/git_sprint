// MIT License

// Copyright (c) 2021 Ian Koerich Maciel

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:convert';
import 'dart:io';

import 'app_callback_listener.dart'
    if (dart.library.js) 'app_callback_listener_mock_for_web.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'login_service.dart';
import 'oauth_model.dart';
import 'redirected_after_login_view.dart';
import '../settings/settings_controller.dart';

enum LoginState { loading, logged, unlogged }

class LoginController with ChangeNotifier {
  final SettingsController _settingsController;
  SettingsController get settingsController => _settingsController;
  LoginController(this._settingsController) {
    init();
  }

  final LoginService _loginService = LoginService();
  bool initialized = false;
  late OAuthModel _oauth;
  OAuthModel get oauth => _oauth;
  LoginState state = LoginState.loading;
  String get oauthServerDomain => _settingsController.oauthServerDomain;
  String get oauthClientId => _settingsController.oauthClientId;
  String get oauthClientSecret => _settingsController.oauthClientSecret;
  int get callbackPort => _settingsController.oauthCallbackPort;

  /// Load the login data from the LoginService.
  Future<void> init() async {
    _oauth = await _loginService.accessToken();
    if (_oauth.hasValidAccessToken) {
      state = LoginState.logged;
    } else {
      state = LoginState.unlogged;
    }

    // Inform listeners a change has occurred.
    notifyListeners();

    initialized = true;
  }

  void startLogin() async {
    // Use the PKCE - Proof Key for Code Exchange
    // https://docs.gitlab.com/ee/api/oauth2.html#authorization-code-with-proof-key-for-code-exchange-pkce
    String oauthState = _getRandomString(32);
    await _loginService.updateOAuthState(oauthState);

    // If not on web, setup and start the callback server.
    AppCallbackListener callbackListener =
        AppCallbackListener(_settingsController.oauthCallbackPort);
    if (!kIsWeb) {
      callbackListener.startServer(httpRedirectCallback);
    }

    String redirectUri = callbackListener.getRedirectUri();
    String clientId = oauthClientId;
    // Scopes: api, read_user, read_api, read_repository, write_repository
    String scope = 'read_user+profile+api';
    String url =
        '$oauthServerDomain/oauth/authorize?client_id=$clientId&redirect_uri=${Uri.encodeComponent(redirectUri)}&response_type=code&state=$oauthState&scope=$scope';
    _launchUrl(url);
  }

  /// Parse uri path to decode oauth parameters.
  Map<String, String> parsePath(String path) {
    Map<String, String> parameters = {};

    String encodedParameters =
        path.replaceFirst('${RedirectedAfterLoginView.routeName}?', '');
    encodedParameters.split('&').forEach((String parameter) {
      List<String> splitted = parameter.split('=');
      parameters.addAll({splitted[0]: splitted[1]});
    });
    return parameters;
  }

  /// Receive a callback from HttpServer receive the oauth redirect.
  ///
  /// Useful only for installed apps, not for web.
  void httpRedirectCallback(
    String path,
  ) {
    requestAccessToken(parsePath(path));
  }

  Future<void> requestAccessToken(Map<String, String> data,
      {int? oauthPort}) async {
    String oauthState = await _loginService.oauthState();
    if (data['state'] == oauthState) {
      Uri uri = Uri.parse('$oauthServerDomain/oauth/token');

      http.Client client = http.Client();
      http.Response response = await client.post(uri, body: <String, String>{
        'client_id': oauthClientId,
        'client_secret': oauthClientSecret,
        'code': data['code'] ?? '',
        'grant_type': 'authorization_code',
        'redirect_uri':
            AppCallbackListener(_settingsController.oauthCallbackPort)
                .getRedirectUri(),
      });

      // TODO check response.
      // TODO Invalidade oauth saved on error.

      if (response.statusCode < 200 || response.statusCode >= 300) {
        // Invalidade access token.
        _loginService.updateAccessToken(OAuthModel());
        throw Exception(
            'Could not login. response = ${response.statusCode}, ${response.body}');
      }

      Map<String, dynamic> oauthMap = jsonDecode(response.body);
      OAuthModel newOauth = OAuthModel.fromMap(oauthMap);
      if (newOauth.hasValidAccessToken) {
        // Dot not perform any work if new and old ThemeMode are identical
        if (identical(newOauth, _oauth)) return;

        _oauth = newOauth;
        _loginService.updateAccessToken(_oauth);
        state = LoginState.logged;
        notifyListeners();
      } else {
        if (newOauth.hasExpired) {
          refreshToken(uri, newOauth.refreshToken);
        } else {
          throw Exception(
              'Invalid access token. hasValidAccessToken: ${newOauth.hasValidAccessToken}, access_token = ${newOauth.accessToken}, token_type: ${newOauth.tokenType}, expireAt: ${newOauth.expireAt.toIso8601String()}');
        }
      }
    } else {
      throw Exception(
          'Could not login. Invalid state. expected state = $oauthState, received state: ${data['state']}');
    }
  }

  Future<void> refreshToken(Uri uri, String refreshToken) async {
    http.Client client = http.Client();
    http.Response response = await client.post(uri, body: <String, String>{
      'client_id': oauthClientId,
      'client_secret': oauthClientSecret,
      'refresh_token': refreshToken,
      'grant_type': 'refresh_token',
      'redirect_uri': AppCallbackListener(_settingsController.oauthCallbackPort)
          .getRedirectUri(),
    });

    // TODO check response.
    // TODO Invalidade oauth saved on error.

    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Invalidade access token.
      _loginService.updateAccessToken(OAuthModel());
      throw Exception(
          'Could not refresh token. response = ${response.statusCode}, ${response.body}');
    }

    Map<String, dynamic> oauthMap = jsonDecode(response.body);
    OAuthModel newOauth = OAuthModel.fromMap(oauthMap);
    if (newOauth.hasValidAccessToken) {
      // Dot not perform any work if new and old ThemeMode are identical
      if (identical(newOauth, _oauth)) return;

      _oauth = newOauth;
      _loginService.updateAccessToken(_oauth);
      state = LoginState.logged;
      notifyListeners();
    } else {
      throw Exception(
          'Invalid access token. hasValidAccessToken: ${newOauth.hasValidAccessToken}, access_token = ${newOauth.accessToken}, token_type: ${newOauth.tokenType}, expireAt: ${newOauth.expireAt.toIso8601String()}');
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // can't launch url, there is some error
      throw "Could not launch $url";
    }
  }

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();
  String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
