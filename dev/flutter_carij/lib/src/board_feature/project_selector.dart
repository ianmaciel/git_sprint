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

import 'package:gitlab/gitlab.dart';

import 'gitlab_controller.dart';

class ProjectSelector extends StatelessWidget {
  final GitlabController gitlabController;
  const ProjectSelector(this.gitlabController, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 56,
      child: Row(
        children: [
          Text(AppLocalizations.of(context)!.projects,
              style: Theme.of(context).textTheme.subtitle1),
          Container(margin: const EdgeInsets.all(8)),
          ProjectsDropdown(
            onChanged: gitlabController.onChangeSelectedProject,
            projects: gitlabController.projects,
            currentProject: gitlabController.getFirstProject(),
          )
        ],
      ),
    );
  }
}

class ProjectsDropdown extends StatelessWidget {
  final Function(Project?)? onChanged;
  final List<Project> projects;
  final Project? currentProject;
  const ProjectsDropdown({
    this.onChanged,
    required this.projects,
    this.currentProject,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Project>(
      hint: Text(AppLocalizations.of(context)!.selectProject),
      disabledHint: Text(AppLocalizations.of(context)!.noProjectAvailable),
      // Read the selected project from the controller
      value: currentProject,
      // Call the onChangeSelectedProject method any time the user selects a new project.
      onChanged: onChanged,
      items: buildDropdownMenuItems(projects),
    );
  }

  List<DropdownMenuItem<Project>>? buildDropdownMenuItems(
      List<Project> projects) {
    return projects.map<DropdownMenuItem<Project>>((Project project) {
      return DropdownMenuItem(
        value: project,
        child: Text(project.name ?? ''),
      );
    }).toList();
  }
}
