/// Represents a single Git commit parsed from `git log --oneline`.
class GitCommit {
  final String sha;
  final String message;

  const GitCommit({required this.sha, required this.message});

  /// Parses a single line from `git log --oneline`.
  /// Expected format: `short_sha commit_message`
  factory GitCommit.fromLine(String line) {
    final trimmed = line.trim();
    final spaceIndex = trimmed.indexOf(' ');
    if (spaceIndex == -1) {
      return GitCommit(sha: trimmed, message: '(no message)');
    }
    return GitCommit(
      sha: trimmed.substring(0, spaceIndex),
      message: trimmed.substring(spaceIndex + 1),
    );
  }

  @override
  String toString() => 'GitCommit(sha: $sha, message: $message)';
}
