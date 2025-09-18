// screens/drive_type_selector_screen.dart
import 'package:base_flutter/example/pages/drive/add_drive_page.dart';
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/pages/drive/models/drive_config_base_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'template/ali_template.dart';


class DriveTypeSelectorScreen extends StatelessWidget {
  final Function(DriveConfig) onDriveAdded;

  const DriveTypeSelectorScreen({
    super.key,
    required this.onDriveAdded,
  });

  // 所有支持的驱动器模板
  static final List<DriveConfigBaseTemplate> _supportedDrives = [
    AliyunDriveTemplate.template,
    // 这里可以添加更多驱动器模板
    // OneDriveTemplate.template,
    // GoogleDriveTemplate.template,
    // BaiduDriveTemplate.template,
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('选择驱动器类型'),
        leading: PlatformIconButton(
          icon: Icon(PlatformIcons(context).back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '添加网盘驱动器',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择你要添加的网盘类型，然后配置相关参数',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          _buildDriveList(context),
        ],
      ),
    );
  }

  Widget _buildDriveList(BuildContext context) {
    return Column(
      children: _supportedDrives.map((template) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildDriveCard(context, template),
      )).toList(),
    );
  }

  Widget _buildDriveCard(BuildContext context, DriveConfigBaseTemplate template) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onDriveSelected(context, template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: template.primaryColor?.withOpacity(0.1) ??
                      Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  template.icon,
                  size: 28,
                  color: template.primaryColor ??
                      Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                PlatformIcons(context).rightChevron,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDriveSelected(BuildContext context, DriveConfigBaseTemplate template) {
    Navigator.of(context).push(
      platformPageRoute(
        context: context,
        builder: (context) => AddDriveScreen(
          template: template,
          onSave: (config) {
            onDriveAdded(config);
            // 返回到上一页面
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}