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

import 'package:boardview/board_item.dart';
import 'package:boardview/board_view.dart';
import 'package:boardview/board_view_controller.dart';

import 'board_column_model.dart';
import 'issue_model.dart';
import 'issue_type_model.dart';

/// Displays the issue board.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class IssueBoardView extends StatelessWidget {
  IssueBoardView({Key? key}) : super(key: key);

  static const routeName = '/board';

  static final List<IssueModel> _todoList = <IssueModel>[
    IssueModel(
      id: 1,
      title: 'Add Firebase login',
      type: IssueTypeModel.task,
    ),
    IssueModel(
      id: 2,
      title: 'Load issues from firebase',
      type: IssueTypeModel.task,
    ),
    IssueModel(
      id: 3,
      title: 'Save issues on firebase',
      type: IssueTypeModel.task,
    ),
    IssueModel(
      id: 4,
      title: 'Create method to add new issues',
      type: IssueTypeModel.task,
    ),
    IssueModel(
      id: 5,
      title: 'Create a backlog screen',
      type: IssueTypeModel.task,
    ),
  ];

  final List<BoardColumnModel> _boardColumns = [
    BoardColumnModel(title: "TODO", issues: _todoList),
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
        title: const Text('Issues Board'),
      ),
      body: BoardView(
        lists: BoardColumnModel.buildBoardList(_boardColumns),
        boardViewController: BoardViewController(),
      ),
    );
  }
}
