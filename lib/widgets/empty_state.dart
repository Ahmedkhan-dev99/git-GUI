import 'package:flutter/material.dart';

/// Displayed when no folder is selected or the folder is not a Git repo.
class EmptyState extends StatefulWidget {
  final String? repoPath;
  final bool isBusy;
  final VoidCallback onPickFolder;
  final VoidCallback onInitRepo;

  const EmptyState({
    super.key,
    required this.repoPath,
    required this.isBusy,
    required this.onPickFolder,
    required this.onInitRepo,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  @override
  Widget build(BuildContext context) {
    final hasPath = widget.repoPath != null;
    const accent = Color(0xFFF97316);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon container
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.1)),
              ),
              child: Icon(
                hasPath ? Icons.warning_amber_rounded : Icons.folder_off_rounded,
                color: accent.withValues(alpha: 0.6),
                size: 36,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              hasPath ? 'Not a Git Repository' : 'Welcome to GitGUI',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasPath
                  ? 'This folder doesn\'t contain a Git repository.\nInitialize one to start tracking your changes.'
                  : 'Open a folder to manage your Git repository\nwith a beautiful, offline desktop experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            if (!hasPath)
              _PrimaryButton(
                icon: Icons.folder_open_rounded,
                label: 'Open Folder',
                onTap: widget.onPickFolder,
                isBusy: widget.isBusy,
              ),

            if (hasPath) ...[
              _PrimaryButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Initialize Git Repository',
                onTap: widget.onInitRepo,
                isBusy: widget.isBusy,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: widget.onPickFolder,
                child: Text(
                  'Choose a different folder',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isBusy;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isBusy,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovering = false;
  static const accent = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.isBusy ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isBusy
                ? accent.withValues(alpha: 0.2)
                : _hovering ? const Color(0xFFEA580C) : accent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: _hovering ? 0.4 : 0.2),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: widget.isBusy
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.5), size: 11),
                  ],
                ),
        ),
      ),
    );
  }
}
