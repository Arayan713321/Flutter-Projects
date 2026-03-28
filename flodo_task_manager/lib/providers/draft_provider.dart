import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── TaskDraft Model ──────────────────────────────────────────────────────────
class TaskDraft {
  final String title;
  final String description;
  final DateTime? dueDate;
  final String status;
  final int? blockedById;
  final String? imagePath;

  const TaskDraft({
    required this.title,
    required this.description,
    this.dueDate,
    required this.status,
    this.blockedById,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'status': status,
        'blockedById': blockedById,
        'imagePath': imagePath,
      };

  factory TaskDraft.fromJson(Map<String, dynamic> json) {
    return TaskDraft(
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      status: (json['status'] as String?) ?? 'To-Do',
      blockedById: json['blockedById'] as int?,
      imagePath: json['imagePath'] as String?,
    );
  }
}

// ─── Draft Notifier ───────────────────────────────────────────────────────────
const _kDraftKey = 'flodo_task_draft';

class DraftNotifier extends Notifier<TaskDraft?> {
  @override
  TaskDraft? build() {
    // Load draft asynchronously; start with null
    _loadDraft();
    return null;
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDraftKey);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        state = TaskDraft.fromJson(json);
      } catch (_) {
        state = null;
      }
    }
  }

  Future<void> saveDraft(TaskDraft draft) async {
    state = draft;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDraftKey, jsonEncode(draft.toJson()));
  }

  Future<TaskDraft?> loadDraft() async {
    await _loadDraft();
    return state;
  }

  Future<void> clearDraft() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDraftKey);
  }
}

final draftProvider = NotifierProvider<DraftNotifier, TaskDraft?>(
  DraftNotifier.new,
);
