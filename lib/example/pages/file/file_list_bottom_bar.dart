import 'package:flutter/material.dart';

class FileListBottomBar extends StatelessWidget {
  final bool hasSelection;
  final VoidCallback? onCopy;
  final VoidCallback? onMove;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const FileListBottomBar({
    super.key,
    required this.hasSelection,
    this.onCopy,
    this.onMove,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAction(icon: Icons.copy, label: '复制', onPressed: onCopy),
              _buildAction(icon: Icons.drive_file_move, label: '移动', onPressed: onMove),
              _buildAction(icon: Icons.share, label: '分享', onPressed: onShare),
              _buildAction(icon: Icons.delete, label: '删除', onPressed: onDelete, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final isEnabled = onPressed != null;
    final color = isDestructive ? Colors.red : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, color: isEnabled ? color : Colors.grey), onPressed: onPressed),
        Text(label, style: TextStyle(fontSize: 12, color: isEnabled ? color : Colors.grey)),
      ],
    );
  }
}
