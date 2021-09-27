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

import 'issue_type_model.dart';

class IssueModel {
  late int id;
  late String title;
  late IssueTypeModel type;
  late String description;
  glab.Issue? gitlabIssue;
  IssueModel({
    required this.id,
    required this.title,
    required this.type,
    this.description = '',
  });

  IssueModel.fromGitlabIssue(this.gitlabIssue) {
    id = gitlabIssue!.id!;
    title = gitlabIssue!.title!;
    type = IssueTypeModel.task;
    description = gitlabIssue!.description ?? '';
  }

  BoardItem buildBoardItem() {
    return BoardItem(
      item: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title),
        ),
      ),
    );
  }

  static List<BoardItem> buildBoardList(List<IssueModel> issues) =>
      issues.map((IssueModel issue) => issue.buildBoardItem()).toList();

  static List<IssueModel> buildIssuesListFromGitlab(List<glab.Issue> issues) =>
      issues
          .map((glab.Issue issue) => IssueModel.fromGitlabIssue(issue))
          .toList();
}
