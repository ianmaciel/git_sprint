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

import 'dart:io';

import 'redirected_after_login_view.dart';

class AppCallbackListener {
  int port;
  AppCallbackListener(this.port);
  startServer(Function(String) callback) async {
    HttpServer server =
        await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    server.listen((HttpRequest request) async {
      if (request.uri
          .toString()
          .startsWith(RedirectedAfterLoginView.routeName)) {
        createResponse(request.response);
        await server.close();
        callback(request.uri.toString());
      }
    });
  }

  void createResponse(HttpResponse response) {
    response.statusCode = 200;
    response.headers.contentType =
        ContentType("text", "html", charset: "utf-8");
    // TODO - translate text
    response.write('''
<!DOCTYPE html>
<html>
  <title>Git Sprint Login</title>
</head>
<body>
  You have successfully logged in! <br/>You can close this window.
  <script>
    window.close();
  </script>
</body>
</html>
''');
    response.close();
  }

  String getRedirectUri() =>
      'http://localhost:$port${RedirectedAfterLoginView.routeName}';
}
