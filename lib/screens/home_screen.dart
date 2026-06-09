import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/git_state.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/commit_form.dart';
import '../widgets/commit_card.dart';
import '../widgets/empty_state.dart';

/// Root screen — top nav bar + split-panel main content.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickAndLoad(BuildContext context) async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select a Git Repository Folder',
    );
    if (path != null && context.mounted) {
      await context.read<GitState>().loadRepo(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      body: Consumer<GitState>(
        builder: (context, state, _) {
          // Snackbar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg = state.snackbarMessage;
            if (msg != null) {
              state.clearSnackbar();
              final isError = msg.toLowerCase().contains('fail') ||
                  msg.toLowerCase().contains('error') ||
                  msg.toLowerCase().contains('nothing to commit') ||
                  msg.toLowerCase().contains('could not');
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                          color: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(msg)),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1A1A1F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(12),
                    duration: const Duration(seconds: 3),
                  ),
                );
            }
          });

          return Column(
            children: [
              // ── Top Navigation Bar ──
              TopNavBar(
                repoPath: state.repoPath,
                isValidRepo: state.isValidRepo,
                currentBranch: state.currentBranch,
                statusSummary: state.statusSummary,
                isDetached: state.isDetached,
                onPickFolder: () => _pickAndLoad(context),
                onClearRepo: state.clearRepo,
                onCheckoutDefault: state.checkoutDefaultBranch,
              ),

              // ── Main Content ──
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF97316)))
                    : state.repoPath == null || !state.isValidRepo
                        ? EmptyState(
                            repoPath: state.repoPath,
                            isBusy: state.isOperationRunning,
                            onPickFolder: () => _pickAndLoad(context),
                            onInitRepo: state.initRepo,
                          )
                        : _RepoContent(state: state),
              ),

              // ── Footer ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF141416),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2A2A32), width: 1),
                  ),
                ),
                child: Text(
                  'All Copyright \u00a9 2026 \u2014 Developed by AhmedKhan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Split-panel layout: timeline history (left) + commit panel (right).
class _RepoContent extends StatelessWidget {
  final GitState state;

  const _RepoContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left: Commit Timeline ──
          Expanded(
            flex: 6,
            child: _TimelinePanel(state: state),
          ),
          const SizedBox(width: 20),

          // ── Right: Commit Form & Info ──
          Expanded(
            flex: 4,
            child: _ActionPanel(state: state),
          ),
        ],
      ),
    );
  }
}

/// Left panel — scrollable timeline of commits.
class _TimelinePanel extends StatelessWidget {
  final GitState state;

  const _TimelinePanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, color: const Color(0xFFF97316), size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Commit History',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${state.commits.length}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A32)),

          // List
          Expanded(
            child: state.commits.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded, color: Colors.white.withValues(alpha: 0.08), size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'No commits yet',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: state.commits.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemBuilder: (context, index) {
                      final commit = state.commits[index];
                      final isHead = state.headSha != null && commit.sha == state.headSha;
                      return CommitCard(
                        commit: commit,
                        isCurrentHead: isHead,
                        isFirst: index == 0,
                        isLast: index == state.commits.length - 1,
                        onCheckout: () => state.checkoutCommit(commit.sha),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Right panel — commit form + quick actions.
class _ActionPanel extends StatelessWidget {
  final GitState state;

  const _ActionPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Commit form
        CommitForm(
          isBusy: state.isOperationRunning,
          onCommit: state.addAndCommit,
        ),

        const SizedBox(height: 16),

        // Repo info card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REPOSITORY',
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Text(
                state.repoPath ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, height: 1.5),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.fork_right_rounded,
                label: 'Branch',
                value: state.isDetached ? 'DETACHED' : (state.currentBranch ?? '—'),
                color: state.isDetached ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
              ),
              const SizedBox(height: 8),
              _InfoTile(
                icon: Icons.edit_note_rounded,
                label: 'Status',
                value: state.statusSummary.isEmpty ? '…' : state.statusSummary,
                color: Colors.white54,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Return to main button (if detached)
        if (state.isDetached)
          _DangerButton(
            label: 'Return to Main/Master',
            onTap: state.checkoutDefaultBranch,
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 14),
        const SizedBox(width: 8),
        Text('$label:', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DangerButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onTap;

  const _DangerButton({required this.label, required this.onTap});

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _hovering = false;
  static const danger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => widget.onTap(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: _hovering ? danger.withValues(alpha: 0.15) : danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: danger.withValues(alpha: _hovering ? 0.5 : 0.2)),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.undo_rounded, color: danger, size: 16),
              const SizedBox(width: 6),
              Text(widget.label, style: TextStyle(color: danger, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
