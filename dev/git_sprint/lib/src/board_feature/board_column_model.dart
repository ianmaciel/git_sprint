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

import 'package:gitlab/gitlab.dart' as glab;
import 'package:boardview/board_item.dart';
import 'package:boardview/board_list.dart';

import 'issue_model.dart';

class BoardColumnModel {
  late String title;
  late List<IssueModel> issues;
  late bool draggable;
  OnDropList? onDropList;
  OnTapList? onTapList;
  OnStartDragList? onStartDragList;
  late List<BoardItem> items;

  BoardColumnModel({
    required this.title,
    required this.issues,
    this.draggable = true,
    this.onDropList,
    this.onTapList,
    this.onStartDragList,
  }) {
    items = IssueModel.buildBoardList(issues);
  }

  BoardColumnModel.fromGitlabIssues(
    List<glab.Issue> gitlabIssueList, {
    required this.title,
  }) {
    issues = IssueModel.buildIssuesListFromGitlab(gitlabIssueList);
    items = IssueModel.buildBoardList(issues);
    draggable = true;
  }

  BoardList buildBoardColumn() {
    return BoardList(
      onDropList: onDropList,
      onTapList: onTapList,
      onStartDragList: onStartDragList,
      headerBackgroundColor: const Color.fromARGB(255, 235, 236, 240),
      backgroundColor: const Color.fromARGB(255, 235, 236, 240),
      header: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
      items: items,
    );
  }

  static List<BoardList> buildBoardList(List<BoardColumnModel> columns) =>
      columns
          .map((BoardColumnModel column) => column.buildBoardColumn())
          .toList();
}
