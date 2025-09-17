import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../features/file/models/file/file_item.dart';
import '../../utils/file/file_icon.dart';
import '../../utils/file/file_size_formatter.dart';
import '../../features/file/providers/file_provider.dart';

class FileListItem extends StatelessWidget {
  final FileItem file;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String)? onMenuSelected;

  const FileListItem({
    super.key,
    required this.file,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isFolder = file.isDirectory;

    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: ListTile(
        leading: isSelectionMode
            ? Checkbox(value: isSelected, onChanged: (_) => onTap?.call())
            : Icon(
                isFolder ? Icons.folder : file.ext?.iconData,
                color: isFolder
                    ? Colors.blue[700]
                    : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
        title: Text(
          file.displayName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null,
          ),
        ),
        subtitle: Row(
          children: [
            if (file.modifiedAt != null) ...[
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('MM-dd HH:mm').format(file.modifiedAt!),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            if (file.size != null && file.modifiedAt != null)
              Text(' • ', style: TextStyle(color: Colors.grey[600])),
            if (file.size != null && !isFolder) ...[
              Icon(Icons.storage, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                file.size!.formattedSize,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
            if (isFolder) ...[
              Icon(Icons.folder_open, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '文件夹',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: !isSelectionMode
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('重命名'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) async {
                  final provider = GetIt.instance<FileProvider>();

                  if (value == 'delete') {
                    provider.deleteFile(file);
                  } else if (value == 'rename') {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController(
                          text: file.filename,
                        );
                        return AlertDialog(
                          title: const Text("重命名文件"),
                          content: TextField(
                            controller: controller,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: "新文件名",
                              hintText: "请输入新文件名",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(), // 取消
                              child: const Text("取消"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(controller.text.trim()), // 确认
                              child: const Text("确定"),
                            ),
                          ],
                        );
                      },
                    );

                    if (newName != null &&
                        newName.isNotEmpty &&
                        newName != file.filename) {
                      provider.renameFile(file, newName);
                    }
                  }
                },
              )
            : null,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
