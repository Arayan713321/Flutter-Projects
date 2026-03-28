import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../utils/constants.dart';

part 'task.g.dart';

// ─── Isar Collection ──────────────────────────────────────────────────────────
@Collection()
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  late String description;
  late DateTime dueDate;

  /// "To-Do" | "In Progress" | "Done"
  late String status;

  /// ID of the task that blocks this one (nullable)
  int? blockedById;

  /// Used for manual reordering; defaults to ms since epoch at creation time
  late int sortOrder;

  late DateTime createdAt;

  /// Local path to an attached image (if any)
  String? imagePath;
}

// ─── TaskStatus enum ──────────────────────────────────────────────────────────
enum TaskStatus { todo, inProgress, done }

// ─── TaskStatus extension ─────────────────────────────────────────────────────
extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.neutral;
      case TaskStatus.inProgress:
        return AppColors.warning;
      case TaskStatus.done:
        return AppColors.success;
    }
  }

  Color get bgColor {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.todoChipBg;
      case TaskStatus.inProgress:
        return AppColors.inProgressChipBg;
      case TaskStatus.done:
        return AppColors.doneChipBg;
    }
  }

  static TaskStatus fromString(String s) {
    switch (s) {
      case 'In Progress':
        return TaskStatus.inProgress;
      case 'Done':
        return TaskStatus.done;
      case 'To-Do':
      default:
        return TaskStatus.todo;
    }
  }
}
