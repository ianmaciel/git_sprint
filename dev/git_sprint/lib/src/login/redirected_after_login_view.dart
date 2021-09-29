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

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'login_controller.dart';
import '../board_feature/issue_board_view.dart';

class RedirectedAfterLoginView extends StatelessWidget {
  final String _path;
  const RedirectedAfterLoginView(this._path, {Key? key}) : super(key: key);

  static const routeName = '/redirected-after-login';

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(builder:
        (BuildContext context, LoginController loginController, Widget? child) {
      try {
        if (loginController.state == LoginState.unlogged) {
          loginController.requestAccessToken(loginController.parsePath(_path));
        }
        if (loginController.state == LoginState.logged) {
          redirectToRoute(context, IssueBoardView.routeName);
        }
      } catch (e) {
        // TODO: use proper feedback, tranlate, etc.
        return Text(e.toString());
      }
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    });
  }

  void redirectToRoute(BuildContext context, String route) {
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false));
  }
}
