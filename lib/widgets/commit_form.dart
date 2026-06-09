import 'package:flutter/material.dart';

/// Compact commit form for the right panel.
class CommitForm extends StatefulWidget {
  final bool isBusy;
  final Future<void> Function(String message) onCommit;

  const CommitForm({super.key, required this.isBusy, required this.onCommit});

  @override
  State<CommitForm> createState() => _CommitFormState();
}

class _CommitFormState extends State<CommitForm> {
  final _controller = TextEditingController();
  bool _hovering = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;
    await widget.onCommit(msg);
    if (mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF97316);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.commit_rounded, color: accent, size: 14),
              ),
              const SizedBox(width: 8),
              const Text(
                'New Save Point',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            enabled: !widget.isBusy,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Describe your changes…',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.22), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0F0F11),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: accent, width: 1.5),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 10),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTap: widget.isBusy ? null : _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: widget.isBusy
                      ? accent.withValues(alpha: 0.25)
                      : _hovering ? const Color(0xFFEA580C) : accent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: _hovering ? 0.3 : 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: widget.isBusy
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.save_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'Commit',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
