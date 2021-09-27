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
import 'sign_in_with_gitlab.dart';
import '../board_feature/issue_board_view.dart';
import '../settings/gitlab_settings_form.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  static const routeName = '/login';

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool showApplyButton = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Consumer<LoginController>(builder: (BuildContext context,
              LoginController loginController, Widget? child) {
            switch (loginController.state) {
              case LoginState.loading:
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              case LoginState.logged:
                redirectToRoute(context, IssueBoardView.routeName);
                break;
              case LoginState.unlogged:
                try {
                  return Center(
                    child: SizedBox(
                      height: 500,
                      width: 800,
                      child: Column(
                        children: [
                          SignInWitGitlab(
                              onPressed: loginController.startLogin),
                          const SizedBox(height: 16),
                          GitlabSettingsForm(loginController.settingsController,
                              onExpansionChanged: onExpansionChanged),
                          const SizedBox(height: 16),
                          if (showApplyButton)
                            ElevatedButton(
                              onPressed: loginController
                                  .settingsController.applySettings,
                              // TODO translate text
                              child: const Text('Apply Settings'),
                            ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  // TODO remove hardcoded text
                  Text(e.toString());
                }
            }
            return Container();
          }),
        ),
      );

  void onExpansionChanged(bool expanded) => setState(() {
        showApplyButton = expanded;
      });

  void redirectToRoute(BuildContext context, String route) {
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false));
  }
}
