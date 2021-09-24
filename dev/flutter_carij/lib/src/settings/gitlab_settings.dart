// MIT License

// Copyright (c) 2021 Anonymized Developer

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

import '../board_feature/gitlab_controller.dart';

class GitlabSettings extends StatelessWidget {
  GitlabSettings({Key? key}) : super(key: key);

  final TextEditingController controllerToken = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Consumer<GitlabController>(builder:
        (BuildContext context, GitlabController gitlabProvider, Widget? child) {
      controllerToken.text = gitlabProvider.token;
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text('Gitlab Token'),
                  TextFormField(
                    onChanged: gitlabProvider.setToken,
                    controller: controllerToken,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: () {
              gitlabProvider.init(token: controllerToken.text);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }
}
