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

class OAuthModel {
  String accessToken = '';
  String tokenType = '';
  Duration expiresIn = const Duration(seconds: 0);
  String refreshToken = '';
  late DateTime createdAt = DateTime.now();
  OAuthModel({
    this.accessToken = '',
    this.tokenType = '',
    int? expiresInSeconds = 0,
    this.refreshToken = '',
    int? createdAtInTimestamp = 0,
  }) {
    expiresIn = getExpiresFromSeconds(expiresInSeconds);
    createdAt = getDatetimeFromTimestamp(createdAtInTimestamp);
  }

  DateTime get expireAt => createdAt.add(expiresIn);
  int get timestampFromCreatedAt => createdAt.millisecondsSinceEpoch ~/ 1000;
  bool get hasValidAccessToken => accessToken.isNotEmpty && hasNotExpired;
  String get bearerToken => 'Bearer $accessToken';
  bool get hasExpired => expireAt.isBefore(DateTime.now());
  bool get hasNotExpired => !hasExpired;

  static Duration getExpiresFromSeconds(int? seconds) =>
      Duration(seconds: seconds ?? 0);
  static DateTime getDatetimeFromTimestamp(int? unixTime) =>
      DateTime.fromMillisecondsSinceEpoch((unixTime ?? 0) * 1000);

  OAuthModel.fromMap(Map<String, dynamic> oauth) {
    accessToken = oauth['access_token'] ?? '';
    tokenType = oauth['token_type'] ?? '';
    expiresIn = getExpiresFromSeconds(oauth['expires_in']);
    refreshToken = oauth['refresh_token'] ?? '';
    createdAt = getDatetimeFromTimestamp(oauth['created_at']);
  }

  Map<String, dynamic> toMap() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn.inSeconds,
        'refresh_token': refreshToken,
        'created_at': timestampFromCreatedAt,
      };
}
