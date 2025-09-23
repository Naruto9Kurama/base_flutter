// screens/add_drive_screen.dart
import 'package:base_flutter/example/features/drives/models/drive_config.dart';
import 'package:base_flutter/example/pages/drive/models/drive_config_base_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get_it/get_it.dart';
import 'package:base_flutter/example/features/drives/serives/drive_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class AddDriveScreen extends StatefulWidget {
  final DriveConfigBaseTemplate template;
  final Function(DriveConfig) onSave;
  final DriveConfig? existingConfig; // 用于编辑现有配置

  const AddDriveScreen({
    super.key,
    required this.template,
    required this.onSave,
    this.existingConfig,
  });

  @override
  State<AddDriveScreen> createState() => _AddDriveScreenState();
}

class _AddDriveScreenState extends State<AddDriveScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  late Map<String, dynamic> _initialValues;

  @override
  void initState() {
    super.initState();
    _initializeValues();
  }

 void _initializeValues() {
  _initialValues = {};

  for (final field in widget.template.fields) {
    if (field.defaultValue != null) {
      var value = field.defaultValue;
      // 如果是 checkbox，确保是 bool 类型
      if (field.type == DriveFieldType.checkbox) {
        if (value is String) {
          value = value.toLowerCase() == 'true';
        }
      }
      _initialValues[field.key] = value;
    }
  }

  if (widget.existingConfig != null) {
    _initialValues.addAll(widget.existingConfig!.config);
    _initialValues['name'] = widget.existingConfig!.name;
  }
}


  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(widget.existingConfig != null 
            ? '编辑${widget.template.displayName}' 
            : '添加${widget.template.displayName}'),
        leading: PlatformIconButton(
          icon: Icon(PlatformIcons(context).back),
          onPressed: () => context.pop(),
        ),
        trailingActions: [
          PlatformTextButton(
            child: Text(_isLoading ? '保存中...' : '保存'),
            onPressed: _isLoading ? null : _handleSave,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.template.primaryColor?.withOpacity(0.1) ??
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.template.primaryColor?.withOpacity(0.2) ??
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.template.icon,
              size: 32,
              color: widget.template.primaryColor ??
                  Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.template.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.template.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      initialValue: _initialValues,
      child: Column(
        children: [
          // 驱动器名称字段（必填）
          _buildNameField(),
          const SizedBox(height: 16),
          // 动态生成的配置字段
          ...widget.template.fields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildField(field),
          )),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return FutureBuilder<List<DriveConfig>>(
      future: GetIt.instance.get<DriveService>().getAllDrive(),
      builder: (context, snapshot) {
        final existingMountNames = snapshot.data?.map((e) => e.name).toSet() ?? {};
        return FormBuilderTextField(
          name: 'name',
          decoration: InputDecoration(
            labelText: '挂载目录名 *',
            hintText: '为此驱动器设置唯一挂载目录名',
            prefixIcon: Icon(PlatformIcons(context).folder),
            border: const OutlineInputBorder(),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: '请输入挂载目录名'),
            FormBuilderValidators.minLength(1, errorText: '名称不能为空'),
            (value) {
              if (value == null || value.isEmpty) return null;
              // 编辑时允许原名通过
              if (widget.existingConfig != null && value == widget.existingConfig!.name) {
                return null;
              }
              if (existingMountNames.contains(value)) {
                return '该挂载目录名已存在，请换一个';
              }
              return null;
            },
          ]),
        );
      },
    );
  }

  Widget _buildField(DriveConfigField field) {
    switch (field.type) {
      case DriveFieldType.text:
      case DriveFieldType.email:
      case DriveFieldType.url:
        return _buildTextField(field);
      case DriveFieldType.password:
        return _buildPasswordField(field);
      case DriveFieldType.number:
        return _buildNumberField(field);
      case DriveFieldType.dropdown:
        return _buildDropdownField(field);
      case DriveFieldType.checkbox:
        return _buildCheckboxField(field);
      case DriveFieldType.multiline:
        return _buildMultilineField(field);
    }
  }

  Widget _buildTextField(DriveConfigField field) {
    return FormBuilderTextField(
      name: field.key,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        hintText: field.hint,
        prefixIcon: field.icon != null ? Icon(field.icon) : null,
        border: const OutlineInputBorder(),
      ),
      validator: field.required
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '请输入${field.label}'),
              if (field.validator != null) field.validator!,
            ])
          : field.validator,
    );
  }

  Widget _buildPasswordField(DriveConfigField field) {
    return FormBuilderTextField(
      name: field.key,
      obscureText: true,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        hintText: field.hint,
        prefixIcon: field.icon != null ? Icon(field.icon) : Icon(PlatformIcons(context).add),
        border: const OutlineInputBorder(),
      ),
      validator: field.required
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '请输入${field.label}'),
              if (field.validator != null) field.validator!,
            ])
          : field.validator,
    );
  }

  Widget _buildNumberField(DriveConfigField field) {
    return FormBuilderTextField(
      name: field.key,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        hintText: field.hint,
        prefixIcon: field.icon != null ? Icon(field.icon) : null,
        border: const OutlineInputBorder(),
      ),
      validator: field.required
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '请输入${field.label}'),
              FormBuilderValidators.numeric(errorText: '请输入有效数字'),
              if (field.validator != null) field.validator!,
            ])
          : FormBuilderValidators.compose([
              FormBuilderValidators.numeric(errorText: '请输入有效数字'),
              if (field.validator != null) field.validator!,
            ]),
    );
  }

  Widget _buildDropdownField(DriveConfigField field) {
    return FormBuilderDropdown<String>(
      name: field.key,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        hintText: field.hint,
        prefixIcon: field.icon != null ? Icon(field.icon) : null,
        border: const OutlineInputBorder(),
      ),
      items: field.options?.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList() ?? [],
      validator: field.required
          ? FormBuilderValidators.required(errorText: '请选择${field.label}')
          : null,
    );
  }

  Widget _buildCheckboxField(DriveConfigField field) {
    return FormBuilderCheckbox(
      name: field.key,
      title: RichText(
        text: TextSpan(
          text: field.label,
          style: Theme.of(context).textTheme.bodyMedium,
          children: field.required ? [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ] : null,
        ),
      ),
      subtitle: field.hint != null ? Text(field.hint!) : null,
      validator: field.required
          ? FormBuilderValidators.required(errorText: '请勾选${field.label}')
          : null,
    );
  }

  Widget _buildMultilineField(DriveConfigField field) {
    return FormBuilderTextField(
      name: field.key,
      maxLines: field.maxLines ?? 3,
      minLines: field.minLines ?? 1,
      decoration: InputDecoration(
        labelText: '${field.label}${field.required ? ' *' : ''}',
        hintText: field.hint,
        prefixIcon: field.icon != null ? Icon(field.icon) : null,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: field.required
          ? FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: '请输入${field.label}'),
              if (field.validator != null) field.validator!,
            ])
          : field.validator,
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formData = _formKey.currentState!.value;
      final name = formData['name'] as String;
      final config = Map<String, dynamic>.from(formData)..remove('name');
      String key;
      if (widget.existingConfig != null) {
        key = widget.existingConfig!.key;
      } else {
        key = _randomString(16);
      }
      final driveConfig = DriveConfig(
        key: key,
        driveType: widget.template.driveType,
        name: name,
        config: config,
      );
      await widget.onSave(driveConfig);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showPlatformDialog(
          context: context,
          builder: (context) => PlatformAlertDialog(
            title: const Text('保存失败'),
            content: Text('保存配置时出现错误: $e'),
            actions: [
              PlatformDialogAction(
                child: const Text('确定'),
                onPressed: () => context.pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}