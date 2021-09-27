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

import 'package:flutter/foundation.dart';
import 'package:gitsprint/src/settings/settings_controller.dart';

import 'package:gitlab/gitlab.dart';

class GitlabController extends ChangeNotifier {
  final SettingsController _settingsController;
  GitLab? gitlab;
  late ProjectsApi gitlabProject;
  List<Project> projects = <Project>[];
  List<Issue>? issues;
  String get token => _settingsController.gitlabToken;
  int? get projectId => _settingsController.gitlabProjectId;
  GitlabController(this._settingsController) {
    init();
  }

  void setProjetId(String newProjectId) =>
      _settingsController.updateGitlabProjectId(int.tryParse(newProjectId));
  void setToken(String newToken) =>
      _settingsController.updateGitlabToken(newToken);

  void init({String? token, String? projectId}) async {
    if (token != null) {
      setToken(token);
    }
    if (projectId != null) {
      setProjetId(projectId);
    }

    if (this.token.isNotEmpty) {
      gitlab = GitLab(this.token);
      gitlabProject = gitlab!.project(this.projectId);
      await loadUserProjects();
    }

    if (gitlab != null && this.projectId != null) {
      if (gitlabProject.id != null) {
        await loadIssues();
      }
    }
  }

  Future<void> loadIssues() async {
    issues = await gitlabProject.issues.list(page: 0, perPage: 30);
    notifyListeners();
  }

  Future<void> loadUserProjects() async {
    projects = await gitlabProject.list(
      archived: false,
      minAccessLevel: ProjectMinAccessLevel.guest,
      page: 0,
      perPage: 30,
    );
    notifyListeners();
  }

  void createIssue(String title) async {
    Issue created = await gitlabProject.issues.add(title);
    issues!.add(created);
    notifyListeners();
  }

  void onChangeSelectedProject(Project? project) {
    if (project != null) {
      gitlabProject.id = project.id;
      _settingsController.updateGitlabProjectId(project.id);
      loadIssues();
    }
  }

  /// Get the selected project.
  Project? getProject() {
    if (projects.isNotEmpty) {
      if (projectId != null) {
        return projects.where((project) => project.id == projectId).first;
      }
    }
  }

  /// Get the selected project or the first one.
  Project? getFirstProject() {
    if (projects.isNotEmpty) {
      return getProject() ?? projects.first;
    }
  }
}
