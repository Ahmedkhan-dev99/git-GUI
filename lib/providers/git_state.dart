import 'package:flutter/foundation.dart';

import '../models/git_commit.dart';
import '../services/git_service.dart';

/// Central state store for the entire application.
class GitState extends ChangeNotifier {
  final GitService _git = GitService();

  // ---- Repository state ----
  String? _repoPath;
  bool _isValidRepo = false;
  bool _isLoading = false;

  // ---- Commit history ----
  List<GitCommit> _commits = [];

  // ---- Branch / status info ----
  String? _currentBranch;
  String? _headSha;
  String _statusSummary = '';

  // ---- UI feedback ----
  String? _snackbarMessage;
  bool _isOperationRunning = false;

  // ------------------------------------------------------------------
  // Getters
  // ------------------------------------------------------------------

  String? get repoPath => _repoPath;
  bool get isValidRepo => _isValidRepo;
  bool get isLoading => _isLoading;
  List<GitCommit> get commits => _commits;
  String? get currentBranch => _currentBranch;
  String? get headSha => _headSha;
  String get statusSummary => _statusSummary;
  String? get snackbarMessage => _snackbarMessage;
  bool get isOperationRunning => _isOperationRunning;
  bool get isDetached => _isValidRepo && _currentBranch == null && _repoPath != null;

  void clearSnackbar() {
    _snackbarMessage = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Folder selection
  // ------------------------------------------------------------------

  /// Loads and validates the repository at [path].
  Future<void> loadRepo(String path) async {
    _isLoading = true;
    _repoPath = path;
    _isValidRepo = false;
    _commits = [];
    _currentBranch = null;
    _headSha = null;
    _statusSummary = '';
    notifyListeners();

    _isValidRepo = await _git.isValidGitRepo(path);
    if (_isValidRepo) {
      await _refreshAll();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Clears current repo selection.
  void clearRepo() {
    _repoPath = null;
    _isValidRepo = false;
    _commits = [];
    _currentBranch = null;
    _headSha = null;
    _statusSummary = '';
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Git init
  // ------------------------------------------------------------------

  Future<void> initRepo() async {
    if (_repoPath == null) return;
    _isOperationRunning = true;
    notifyListeners();

    final result = await _git.initRepo(_repoPath!);
    _snackbarMessage = result.message;

    if (result.success) {
      _isValidRepo = true;
      await _refreshAll();
    }

    _isOperationRunning = false;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Commit
  // ------------------------------------------------------------------

  Future<void> addAndCommit(String message) async {
    if (_repoPath == null) return;
    _isOperationRunning = true;
    notifyListeners();

    final result = await _git.addAndCommit(_repoPath!, message);
    _snackbarMessage = result.message;

    if (result.success) {
      await _refreshAll();
    }

    _isOperationRunning = false;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Checkout
  // ------------------------------------------------------------------

  Future<void> checkoutCommit(String sha) async {
    if (_repoPath == null) return;
    _isOperationRunning = true;
    notifyListeners();

    final result = await _git.checkout(_repoPath!, sha);
    _snackbarMessage = result.message;

    if (result.success) {
      await _refreshAll();
    }

    _isOperationRunning = false;
    notifyListeners();
  }

  Future<void> checkoutDefaultBranch() async {
    if (_repoPath == null) return;
    _isOperationRunning = true;
    notifyListeners();

    final result = await _git.checkoutDefaultBranch(_repoPath!);
    _snackbarMessage = result.message;

    if (result.success) {
      await _refreshAll();
    }

    _isOperationRunning = false;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Internal refresh
  // ------------------------------------------------------------------

  Future<void> _refreshAll() async {
    if (_repoPath == null) return;
    final results = await Future.wait([
      _git.fetchCommits(_repoPath!),
      _git.currentBranch(_repoPath!),
      _git.statusSummary(_repoPath!),
      _git.headSha(_repoPath!),
    ]);
    _commits = results[0] as List<GitCommit>;
    _currentBranch = results[1] as String?;
    _statusSummary = results[2] as String;
    _headSha = results[3] as String?;
  }
}
