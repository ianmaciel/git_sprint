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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'settings_controller.dart';

class GitlabSettingsForm extends StatelessWidget {
  final ValueChanged<bool>? onExpansionChanged;
  final SettingsController _settingsController;
  final bool initiallyExpanded;
  const GitlabSettingsForm(this._settingsController,
      {this.initiallyExpanded = false, this.onExpansionChanged, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _settingsController.gitlabSettingsFormKey,
      child: ExpansionTile(
        onExpansionChanged: onExpansionChanged,
        // TODO remove hardcoded text
        title: const Text('GitLab settings'),
        initiallyExpanded: initiallyExpanded,
        collapsedBackgroundColor: Colors.grey[200],
        backgroundColor: Colors.grey[200],
        maintainState: true,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // TODO - translate text
                const Text('Gitlab Server Domain'),
                TextFormField(
                  controller: _settingsController.oauthServerTextController,
                ),
                const SizedBox(height: 16),
                // TODO - translate text
                const Text('Gitlab Client ID'),
                TextFormField(
                  controller: _settingsController.oauthClientIdTextController,
                ),
                const SizedBox(height: 16),
                // TODO - translate text
                const Text('Gitlab Client Secret'),
                TextFormField(
                  controller:
                      _settingsController.oauthClientSecretTextController,
                ),
                const SizedBox(height: 16),
                // TODO - translate text
                if (!kIsWeb) const Text('Callback port'),
                if (!kIsWeb)
                  TextFormField(
                    controller: _settingsController.callbackPortTextController,
                    // TODO remove hardcoded string
                    validator: (String? text) =>
                        int.tryParse(text ?? '') == null
                            ? 'Invalid port number'
                            : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
