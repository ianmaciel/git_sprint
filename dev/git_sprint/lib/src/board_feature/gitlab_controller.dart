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

import 'package:gitlab/gitlab.dart';
import 'package:gitsprint/src/settings/settings_controller.dart';

import 'gitlab_service.dart';
import '../login/login_controller.dart';
import '../login/oauth_model.dart';

class GitlabController extends ChangeNotifier {
  final LoginController _loginController;
  final SettingsController _settingsController;
  SettingsController get settingsController => _settingsController;
  final GitlabService _gitlabService = GitlabService();
  GitlabController(this._loginController, this._settingsController) {
    init();
  }

  int? _projectId;
  int? get projectId => _projectId;
  OAuthModel get oauth => _loginController.oauth;
  GitLab? gitlab;
  late ProjectsApi gitlabProject;
  List<Project> projects = <Project>[];
  List<Issue>? issues;
  String get serverDomain => _settingsController.oauthServerDomain;
  String get clientId => _settingsController.oauthClientId;
  String get clientSecret => _settingsController.oauthClientSecret;

  /// Load the gitlab data from local storage.
  Future<void> init() async {
    if (!_loginController.initialized) {
      await _loginController.init();
    }
    _projectId = await _gitlabService.projectId();

    if (oauth.hasValidAccessToken) {
      gitlab = GitLab(oauth.bearerToken, tokenHeaderKey: 'Authorization');
      gitlabProject = gitlab!.project(projectId);
      await loadUserProjects();
    }

    if (gitlab != null && projectId != null) {
      if (gitlabProject.id != null) {
        await loadIssues();
      }
    }

    // Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the gitlab project id.
  Future<void> updateProjectId(int? newProjectId) async {
    if (newProjectId == null) {
      return;
    }

    // Dot not perform any work if new and old project id are identical
    if (newProjectId == _projectId) return;

    // Otherwise, store the new project id in memory
    _projectId = newProjectId;

    // Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _gitlabService.updateProjectId(newProjectId);
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
      updateProjectId(project.id);
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
