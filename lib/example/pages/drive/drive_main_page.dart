// 使用示例
// main_screen.dart

import 'package:base_flutter/core/storage/hive_manager.dart';
import 'package:base_flutter/example/constants/hive_boxes.dart';
import 'package:base_flutter/example/features/file/enums/file_platform.dart';
import 'package:base_flutter/example/pages/drive/add_drive_page.dart';
import 'package:base_flutter/example/pages/drive/template/ali_template.dart';
import 'package:base_flutter/example/pages/drive/drive_type_page.dart';
import 'package:base_flutter/example/features/drives/models/mount_config.dart';
import 'package:base_flutter/example/pages/drive/models/drive_config_base_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class DriveMainScreen extends StatefulWidget {
  const DriveMainScreen({super.key});

  @override
  State<DriveMainScreen> createState() => _DriveMainScreenState();
}

class _DriveMainScreenState extends State<DriveMainScreen> {
  final List<MountConfig> _drives = [];


  @override
  void initState() {
    super.initState();
    HiveManager.openBox<MountConfig>(HiveBoxes.driveConfig).then((box)=>{
      setState(() {
        _drives.clear();
        _drives.addAll(HiveManager.getAll<MountConfig>(box));
      })
    });
  }

  @override
  Widget build(BuildContext context) {

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('我的网盘'),
        trailingActions: [
          PlatformIconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDriveScreen,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_drives.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drives.length,
      itemBuilder: (context, index) {
        final drive = _drives[index];
        return _buildDriveCard(drive);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text('还没有添加任何网盘', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '点击右上角的 + 按钮添加你的第一个网盘',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          PlatformElevatedButton(
            onPressed: _showAddDriveScreen,
            child: const Text('添加网盘'),
          ),
        ],
      ),
    );
  }

  Widget _buildDriveCard(MountConfig drive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            drive.driveType.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(drive.name),
        subtitle: Text(drive.driveType.displayName),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')],
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
          onSelected: (value) {
            if (value == 'delete') {
              _deleteDrive(drive);
            } else if (value == 'edit') {
              _editDrive(drive);
            }
          },
        ),
        onTap: () => _openDrive(drive),
      ),
    );
  }


  DriveConfigBaseTemplate? getTemplate(MountConfig drive){
    DriveConfigBaseTemplate? template;
    switch (drive.driveType) {
      case FilePlatform.aliyun:
        template = AliyunDriveTemplate.template;
        break;
    // 添加其他驱动器类型的模板
      case FilePlatform.local:
      // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.baidu:
      // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.ftp:
      // TODO: Handle this case.
        throw UnimplementedError();
      case FilePlatform.other:
      // TODO: Handle this case.
        throw UnimplementedError();
    }
    return template;
  }
  void _showAddDriveScreen() {
    var template = getTemplate(MountConfig(id:'',driveType: FilePlatform.aliyun, name: "111", config: {}));
    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) => DriveTypeSelectorScreen(
          onDriveAdded: (config) {
            var name = template?.onSave(config);
            setState(() {
              _drives.add(config);
            });

            // 显示成功消息
            showPlatformDialog(
              context: context,
              builder: (context) => PlatformAlertDialog(
                title: const Text('添加成功'),
                content: Text('${config.name} 已成功添加'),
                actions: [
                  PlatformDialogAction(
                    child: const Text('确定'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _editDrive(MountConfig drive) {
    // 根据驱动器类型获取对应的模板
    DriveConfigBaseTemplate? template=getTemplate(drive);

    if (template == null) return;

    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) => AddDriveScreen(
          template: template!,
          existingConfig: drive,
          onSave: (updatedConfig) async {
            String result = await template?.onSave(updatedConfig);
            if (result.isEmpty) {//保存成功
              setState(()  {
                final index = _drives.indexWhere((d) => d.name == drive.name);
                if (index >= 0) {
                  _drives[index] = updatedConfig;
                }
              });

              showPlatformDialog(
                context: context,
                builder: (context) => PlatformAlertDialog(
                  title: const Text('保存成功'),
                  content: Text('${updatedConfig.name} 配置已更新'),
                  actions: [
                    PlatformDialogAction(
                      child: const Text('确定'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            }else{//todo 保存失败

            }
          },
        ),
      ),
    );
  }

  void _deleteDrive(MountConfig drive) {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${drive.name}" 吗？此操作不可撤销。'),
        actions: [
          PlatformDialogAction(
            child: const Text('取消'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          PlatformDialogAction(
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            // isDestructiveAction: true,
            onPressed: () {
              setState(() {
                _drives.removeWhere((d) => d.name == drive.name);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _openDrive(MountConfig drive) {
    // 打开驱动器，显示文件列表
    // 这里可以导航到文件浏览界面
    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(drive.name)),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  drive.driveType.icon,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text('打开 ${drive.name}'),
                const SizedBox(height: 8),
                Text('类型: ${drive.driveType.displayName}'),
                const SizedBox(height: 16),
                Text('配置信息:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...drive.config.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${entry.key}: ${_formatConfigValue(entry.key, entry.value)}',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatConfigValue(String key, dynamic value) {
    // 隐藏敏感信息
    if (key.contains('token') ||
        key.contains('password') ||
        key.contains('secret')) {
      return '***';
    }
    return value.toString();
  }


}

// 还需要导入相关文件
// import 'templates/aliyun_drive_template.dart';
