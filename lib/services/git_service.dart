import 'dart:io';

import '../models/git_commit.dart';

/// Result of a Git operation, carrying optional success/error information.
class GitResult {
  final bool success;
  final String message;
  final String? errorOutput;

  const GitResult({required this.success, required this.message, this.errorOutput});
}

/// Service layer that wraps `Process.run` for all supported Git commands.
class GitService {
  /// Runs [executable] with [arguments] inside [workingDir].
  /// Returns the raw [ProcessResult].
  Future<ProcessResult> _exec(
    String executable,
    List<String> arguments,
    String workingDir,
  ) async {
    return Process.run(
      executable,
      arguments,
      workingDirectory: workingDir,
      runInShell: Platform.isWindows,
    );
  }

  // ------------------------------------------------------------------
  // Repository validation
  // ------------------------------------------------------------------

  /// Returns `true` when [directory] is inside a valid Git repository.
  Future<bool> isValidGitRepo(String directory) async {
    try {
      final result = await _exec('git', ['status'], directory);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Runs `git init` in [directory].
  Future<GitResult> initRepo(String directory) async {
    try {
      final result = await _exec('git', ['init'], directory);
      if (result.exitCode == 0) {
        return const GitResult(success: true, message: 'Repository initialized successfully.');
      }
      return GitResult(success: false, message: 'git init failed.', errorOutput: result.stderr.toString());
    } catch (e) {
      return GitResult(success: false, message: 'Could not run git init.', errorOutput: e.toString());
    }
  }

  // ------------------------------------------------------------------
  // Commit history
  // ------------------------------------------------------------------

  /// Fetches the commit log (`git log --oneline`) and returns a parsed list.
  Future<List<GitCommit>> fetchCommits(String directory) async {
    try {
      final result = await _exec('git', ['log', '--oneline'], directory);
      if (result.exitCode != 0) return [];
      final output = result.stdout.toString().trim();
      if (output.isEmpty) return [];
      return output.split('\n').where((l) => l.trim().isNotEmpty).map(GitCommit.fromLine).toList();
    } catch (_) {
      return [];
    }
  }

  // ------------------------------------------------------------------
  // Status helpers
  // ------------------------------------------------------------------

  /// Returns the current branch name, or `null` if detached / error.
  Future<String?> currentBranch(String directory) async {
    try {
      final result = await _exec('git', ['branch', '--show-current'], directory);
      if (result.exitCode != 0) return null;
      final branch = result.stdout.toString().trim();
      return branch.isEmpty ? null : branch;
    } catch (_) {
      return null;
    }
  }

  /// Returns the short SHA of the current HEAD commit.
  Future<String?> headSha(String directory) async {
    try {
      final result = await _exec('git', ['rev-parse', '--short', 'HEAD'], directory);
      if (result.exitCode != 0) return null;
      final sha = result.stdout.toString().trim();
      return sha.isEmpty ? null : sha;
    } catch (_) {
      return null;
    }
  }

  /// Returns a human-readable short status summary.
  Future<String> statusSummary(String directory) async {
    try {
      final result = await _exec('git', ['status', '--short'], directory);
      if (result.exitCode != 0) return 'Unable to read status.';
      final lines = result.stdout.toString().trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
      if (lines.isEmpty) return 'Working tree clean';
      return '${lines.length} changed file${lines.length == 1 ? '' : 's'}';
    } catch (_) {
      return 'Unable to read status.';
    }
  }

  // ------------------------------------------------------------------
  // Add & Commit
  // ------------------------------------------------------------------

  /// Stages all changes and creates a commit with [message].
  Future<GitResult> addAndCommit(String directory, String message) async {
    try {
      // Step 1 – stage everything
      final addResult = await _exec('git', ['add', '.'], directory);
      if (addResult.exitCode != 0) {
        return GitResult(
          success: false,
          message: 'Staging failed.',
          errorOutput: addResult.stderr.toString(),
        );
      }

      // Step 2 – commit
      final commitResult = await _exec('git', ['commit', '-m', message], directory);
      if (commitResult.exitCode == 0) {
        return GitResult(success: true, message: 'Commit created successfully.');
      }

      final stderr = commitResult.stderr.toString().trim();
      // "nothing to commit" is not a hard error but should be surfaced.
      if (stderr.contains('nothing to commit') || commitResult.stdout.toString().contains('nothing to commit')) {
        return const GitResult(success: false, message: 'Nothing to commit – working tree is clean.');
      }

      return GitResult(success: false, message: 'Commit failed.', errorOutput: stderr);
    } catch (e) {
      return GitResult(success: false, message: 'An unexpected error occurred.', errorOutput: e.toString());
    }
  }

  // ------------------------------------------------------------------
  // Checkout
  // ------------------------------------------------------------------

  /// Checks out a specific [commitSha].
  Future<GitResult> checkout(String directory, String commitSha) async {
    try {
      final result = await _exec('git', ['checkout', commitSha], directory);
      if (result.exitCode == 0) {
        return GitResult(success: true, message: 'Checked out $commitSha.');
      }
      return GitResult(success: false, message: 'Checkout failed.', errorOutput: result.stderr.toString());
    } catch (e) {
      return GitResult(success: false, message: 'Could not run git checkout.', errorOutput: e.toString());
    }
  }

  /// Attempts to return to the default branch (`main` or `master`).
  Future<GitResult> checkoutDefaultBranch(String directory) async {
    for (final branch in ['main', 'master']) {
      final result = await _exec('git', ['checkout', branch], directory);
      if (result.exitCode == 0) {
        return GitResult(success: true, message: 'Returned to $branch.');
      }
    }
    return const GitResult(success: false, message: 'Could not find main or master branch.');
  }
}
