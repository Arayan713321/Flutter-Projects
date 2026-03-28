import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/task.dart';
import '../providers/draft_provider.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';

/// Formats a DateTime as "Mon, 28 Jul 2025".
String _formatDate(DateTime dt) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
}

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.todo;
  int? _blockedById;
  bool _isLoading = false;
  String? _imagePath;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    if (_isEditMode) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _dueDate = t.dueDate;
      _status = TaskStatusX.fromString(t.status);
      _blockedById = t.blockedById;
      _imagePath = t.imagePath;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final draft = await ref.read(draftProvider.notifier).loadDraft();
    if (draft != null && mounted) {
      setState(() {
        _titleController.text = draft.title;
        _descController.text = draft.description;
        _dueDate = draft.dueDate;
        _status = TaskStatusX.fromString(draft.status);
        _blockedById = draft.blockedById;
        _imagePath = draft.imagePath;
      });
    }
  }

  void _onFieldChanged() {
    if (!_isEditMode) {
      ref.read(draftProvider.notifier).saveDraft(
            TaskDraft(
              title: _titleController.text,
              description: _descController.text,
              dueDate: _dueDate,
              status: _status.label,
              blockedById: _blockedById,
              imagePath: _imagePath,
            ),
          );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Attach Image", style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    onPressed: () => Navigator.of(ctx).pop(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    onPressed: () => Navigator.of(ctx).pop(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedPath = p.join(directory.path, fileName);
      
      // Copy to app documents for persistence
      await File(pickedFile.path).copy(savedPath);
      
      setState(() => _imagePath = savedPath);
      _onFieldChanged();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _onFieldChanged();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a due date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final task = Task()
        ..title = _titleController.text.trim()
        ..description = _descController.text.trim()
        ..dueDate = _dueDate!
        ..status = _status.label
        ..blockedById = _blockedById
        ..sortOrder = _isEditMode ? widget.task!.sortOrder : now.millisecondsSinceEpoch
        ..createdAt = _isEditMode ? widget.task!.createdAt : now
        ..imagePath = _imagePath;

      if (_isEditMode) {
        task.id = widget.task!.id;
        await ref.read(tasksProvider.notifier).updateTask(task);
      } else {
        await ref.read(tasksProvider.notifier).createTask(task);
        await ref.read(draftProvider.notifier).clearDraft();
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warning),
              const SizedBox(height: 16),
              const Text("Delete Task?", style: AppTextStyles.titleLarge),
              const SizedBox(height: 8),
              const Text("This action cannot be undone.", style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop(); // Close bottom sheet
                        await ref.read(tasksProvider.notifier).deleteTask(widget.task!.id);
                        if (mounted) Navigator.of(context).pop(); // Go back to list
                      },
                      child: const Text("Delete"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(tasksProvider).valueOrNull ?? [];
    final otherTasks = _isEditMode ? allTasks.where((t) => t.id != widget.task!.id).toList() : allTasks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textPrimary),
            ),
          ),
        ),
        title: Text(_isEditMode ? 'Edit Task' : 'New Task', style: AppTextStyles.titleLarge),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TITLE", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                onChanged: (_) => _onFieldChanged(),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: "What needs to be done?",
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.textMuted),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              const Text("DESCRIPTION", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                onChanged: (_) => _onFieldChanged(),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                maxLines: 4,
                minLines: 3,
                decoration: const InputDecoration(
                  hintText: "Add details...",
                  prefixIcon: Icon(Icons.notes_rounded, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              const Text("DUE DATE", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: _dueDate != null ? Border.all(color: AppColors.primary, width: 0.5) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_rounded, color: _dueDate != null ? AppColors.primary : AppColors.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dueDate != null ? _formatDate(_dueDate!) : "Pick a due date",
                          style: _dueDate != null ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary) : AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("STATUS", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              _StatusSegmentedControl(
                selected: _status,
                onChanged: (val) {
                  setState(() => _status = val);
                  _onFieldChanged();
                },
              ),
              const SizedBox(height: 20),

              const Text("BLOCKED BY (OPTIONAL)", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _blockedById,
                items: [
                  const DropdownMenuItem(value: null, child: Text("None — not blocked")),
                  ...otherTasks.map((t) => DropdownMenuItem(value: t.id, child: Text(t.title, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (val) {
                  setState(() => _blockedById = val);
                  _onFieldChanged();
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.link_rounded, color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 20),

              const Text("ATTACHMENTS", style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              _ImageAttachmentPicker(
                imagePath: _imagePath,
                onPick: _pickImage,
                onRemove: () {
                  setState(() => _imagePath = null);
                  _onFieldChanged();
                },
              ),
              const SizedBox(height: 32),

              _SaveButton(
                isEdit: _isEditMode,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSegmentedControl extends StatelessWidget {
  const _StatusSegmentedControl({required this.selected, required this.onChanged});
  final TaskStatus selected;
  final Function(TaskStatus) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskStatus.values.map((s) {
        final isSelected = selected == s;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: s != TaskStatus.done ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? s.bgColor : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? s.color : AppColors.divider, width: 1.5),
              ),
              child: Center(
                child: Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? s.color : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isEdit, required this.isLoading, required this.onPressed});
  final bool isEdit, isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoading
            ? Container(
                key: const ValueKey("loading"),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                      SizedBox(width: 12),
                      Text("Saving...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
            : Container(
                key: const ValueKey("normal"),
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_rounded, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(isEdit ? "Update Task" : "Save Task", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }
}

class _ImageAttachmentPicker extends StatelessWidget {
  const _ImageAttachmentPicker({
    this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  final String? imagePath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (imagePath != null) {
      return Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: DecorationImage(
                image: FileImage(File(imagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.error, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_photo_alternate_rounded, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 8),
            Text("Add photo", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

