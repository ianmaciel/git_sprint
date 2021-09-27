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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:boardview/board_item.dart';
import 'package:boardview/board_view.dart';
import 'package:boardview/board_view_controller.dart';
import 'package:provider/provider.dart';

import 'add_issue_card.dart';
import 'board_column_model.dart';
import 'gitlab_controller.dart';
import 'project_selector.dart';
import 'issue_model.dart';
import '../settings/settings_view.dart';

/// Displays the issue board.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class IssueBoardView extends StatelessWidget {
  IssueBoardView({Key? key}) : super(key: key);

  static const routeName = '/board';

  final List<BoardColumnModel> _boardColumns = [
    BoardColumnModel(title: "TODO", issues: <IssueModel>[]),
    BoardColumnModel(title: "In Progress", issues: <IssueModel>[]),
    BoardColumnModel(title: "Done", issues: <IssueModel>[])
  ];

  /// Update local items.
  void onDropItem(int? listIndex, int? itemIndex, int? oldListIndex,
      int? oldItemIndex, BoardItemState state) {
    //Used to update our local item data
    var item = _boardColumns[oldListIndex!].items[oldItemIndex!];
    _boardColumns[oldListIndex].items.removeAt(oldItemIndex);
    _boardColumns[listIndex!].items.insert(itemIndex!, item);
  }

  /// Update local columns.
  void onDropList(int? listIndex, int? oldListIndex) {
    var list = _boardColumns[oldListIndex!];
    _boardColumns.removeAt(oldListIndex);
    _boardColumns.insert(listIndex!, list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.issuesBoard),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Consumer<GitlabController>(
        builder: (BuildContext context, GitlabController gitlabController,
            Widget? child) {
          if (gitlabController.issues != null) {
            // TODO: this shouldn't be hardcoded
            _boardColumns[0] = BoardColumnModel.fromGitlabIssues(
                gitlabController.issues!,
                title: 'TODO');

            _boardColumns.first.items.insert(
                0,
                AddIssueCard.buildBoardItem(context,
                    onFieldSubmitted: (String text) =>
                        gitlabController.createIssue(text)));
          }

          return Column(
            children: [
              ProjectSelector(gitlabController),
              Flexible(
                flex: 1,
                child: BoardView(
                  lists: BoardColumnModel.buildBoardList(_boardColumns),
                  boardViewController: BoardViewController(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
