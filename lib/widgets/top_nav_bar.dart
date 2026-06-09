import 'package:flutter/material.dart';

/// Horizontal top navigation bar — replaces the old sidebar.
class TopNavBar extends StatelessWidget {
  final String? repoPath;
  final bool isValidRepo;
  final String? currentBranch;
  final String statusSummary;
  final bool isDetached;
  final VoidCallback onPickFolder;
  final VoidCallback onClearRepo;
  final VoidCallback onCheckoutDefault;

  const TopNavBar({
    super.key,
    required this.repoPath,
    required this.isValidRepo,
    required this.currentBranch,
    required this.statusSummary,
    required this.isDetached,
    required this.onPickFolder,
    required this.onClearRepo,
    required this.onCheckoutDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2A2A32), width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Branding ──
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.merge_type_rounded, color: Color(0xFFF97316), size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            'GitGUI',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(width: 24),
          Container(width: 1, height: 24, color: const Color(0xFF2A2A32)),
          const SizedBox(width: 24),

          // ── Folder picker ──
          if (repoPath != null)
            _NavButton(
              icon: Icons.folder_outlined,
              label:  _shortPath(repoPath!),
              onTap: onPickFolder,
              prominent: repoPath == null,
            ),
          
          const Spacer(),

          // ── Branch & Status chips ──
          if (isValidRepo) ...[
            _Chip(
              icon: Icons.fork_right_rounded,
              label: isDetached ? 'DETACHED' : (currentBranch ?? '—'),
              color: isDetached ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
            ),
            const SizedBox(width: 8),
            _Chip(
              icon: Icons.edit_note_rounded,
              label: statusSummary.isEmpty ? '…' : statusSummary,
              color: Colors.white54,
            ),
            if (isDetached) ...[
              const SizedBox(width: 8),
              _NavButton(
                icon: Icons.undo_rounded,
                label: 'Return to Main',
                onTap: onCheckoutDefault,
                color: const Color(0xFFEF4444),
              ),
            ],
            const SizedBox(width: 12),
          ],

          if (repoPath != null)
            _IconButton(
              icon: Icons.close_rounded,
              tooltip: 'Close Repository',
              onTap: onClearRepo,
            ),
        ],
      ),
    );
  }

  String _shortPath(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    if (parts.length <= 3) return path;
    return '…/${parts.sublist(parts.length - 2).join('/')}';
  }
}

// ── Private helpers ──────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool prominent;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.prominent = false,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final base = widget.color ?? const Color(0xFFF97316);
    if (widget.prominent) {
      // Solid filled CTA
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _hovering ? const Color(0xFFEA580C) : base,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: base.withValues(alpha: _hovering ? 0.4 : 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.6), size: 10),
              ],
            ),
          ),
        ),
      );
    }
    // Subtle outlined
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovering ? base.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: _hovering ? base.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: base, size: 14),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text(
                  widget.label,
                  style: TextStyle(color: base, fontWeight: FontWeight.w600, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11)),
        ],
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovering ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(widget.icon, color: Colors.white38, size: 16),
          ),
        ),
      ),
    );
  }
}
