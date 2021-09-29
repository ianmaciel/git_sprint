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

import 'package:shared_preferences/shared_preferences.dart';

import 'oauth_model.dart';

/// A service that stores and retrieves login data.
class LoginService {
  /// Loads the user's access_token.
  Future<OAuthModel> accessToken() async {
    // Double check if the token can be saved on shared-preferences (local
    // storage).
    //
    // It might be necessary to use cookies instead.
    // According to this discussion, both has vulnerabilities but local storage
    // will be safe it the domain is safe (can only be accessed by domain).
    // https://stackoverflow.com/questions/44133536/is-it-safe-to-store-a-jwt-in-localstorage-with-reactjs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    OAuthModel oauth = OAuthModel(
      accessToken: prefs.getString('accessToken') ?? '',
      tokenType: prefs.getString('tokenType') ?? '',
      expiresInSeconds: prefs.getInt('expiresIn'),
      refreshToken: prefs.getString('refreshToken') ?? '',
      createdAtInTimestamp: prefs.getInt('createdAt'),
    );
    return oauth;
  }

  /// Persists the user's access_token.
  Future<void> updateAccessToken(OAuthModel oauth) async {
    // Double check if the token can be saved on shared-preferences (local
    // storage).
    //
    // It might be necessary to use cookies instead.
    // According to this discussion, both has vulnerabilities but local storage
    // will be safe it the domain is safe (can only be accessed by domain).
    // https://stackoverflow.com/questions/44133536/is-it-safe-to-store-a-jwt-in-localstorage-with-reactjs
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', oauth.accessToken);
    await prefs.setString('tokenType', oauth.tokenType);
    await prefs.setInt('expiresIn', oauth.expiresIn.inSeconds);
    await prefs.setString('refreshToken', oauth.refreshToken);
    await prefs.setInt('createdAt', oauth.timestampFromCreatedAt);
  }

  /// Loads the the last OAuth state.
  Future<String> oauthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('oauthState') ?? '';
  }

  /// Persists the user's access_token.
  Future<void> updateOAuthState(String oauthState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('oauthState', oauthState);
  }
}
