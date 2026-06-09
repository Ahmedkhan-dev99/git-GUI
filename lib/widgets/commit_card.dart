import 'package:flutter/material.dart';

import '../models/git_commit.dart';

/// Timeline-style commit card with a vertical line and dot indicator.
class CommitCard extends StatefulWidget {
  final GitCommit commit;
  final bool isCurrentHead;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onCheckout;

  const CommitCard({
    super.key,
    required this.commit,
    required this.isCurrentHead,
    required this.isFirst,
    required this.isLast,
    required this.onCheckout,
  });

  @override
  State<CommitCard> createState() => _CommitCardState();
}

class _CommitCardState extends State<CommitCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headColor = Color(0xFF22C55E);
    const accent = Color(0xFFF97316);
    final isHead = widget.isCurrentHead;
    final dotColor = isHead ? headColor : accent.withValues(alpha: 0.5);

    return MouseRegion(
      cursor: isHead ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline column ──
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  // Top line
                  Expanded(
                    flex: widget.isFirst ? 0 : 1,
                    child: widget.isFirst
                        ? const SizedBox.shrink()
                        : Container(width: 2, color: const Color(0xFF2A2A32)),
                  ),
                  // Dot
                  Container(
                    width: isHead ? 14 : 10,
                    height: isHead ? 14 : 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: isHead
                          ? [
                              BoxShadow(
                                color: headColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                      border: isHead
                          ? Border.all(color: headColor.withValues(alpha: 0.6), width: 2)
                          : null,
                    ),
                  ),
                  // Bottom line
                  Expanded(
                    flex: widget.isLast ? 0 : 1,
                    child: widget.isLast
                        ? const SizedBox.shrink()
                        : Container(width: 2, color: const Color(0xFF2A2A32)),
                  ),
                ],
              ),
            ),

            // ── Card content ──
            Expanded(
              child: GestureDetector(
                onTap: isHead ? null : widget.onCheckout,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(
                    top: widget.isFirst ? 0 : 4,
                    bottom: widget.isLast ? 0 : 4,
                    right: 4,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isHead
                        ? headColor.withValues(alpha: 0.06)
                        : _hovering
                            ? const Color(0xFF1E1E24)
                            : const Color(0xFF1A1A1F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: isHead ? 1.5 : 1,
                      color: isHead
                          ? headColor.withValues(alpha: 0.4)
                          : _hovering
                              ? accent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      // SHA
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (isHead ? headColor : accent).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          widget.commit.sha,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isHead ? headColor : const Color(0xFFFB923C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Message
                      Expanded(
                        child: Text(
                          widget.commit.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isHead ? Colors.white : Colors.white.withValues(alpha: 0.85),
                            fontWeight: isHead ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      // Action
                      if (isHead)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: headColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: headColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: headColor, size: 11),
                              const SizedBox(width: 4),
                              Text('YOU ARE HERE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: headColor, letterSpacing: 0.6)),
                            ],
                          ),
                        )
                      else
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _hovering ? 1.0 : 0.3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: _hovering ? 0.15 : 0.05),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: accent.withValues(alpha: _hovering ? 0.4 : 0.1)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 12, color: accent),
                                const SizedBox(width: 4),
                                Text('Checkout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFFB923C))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
