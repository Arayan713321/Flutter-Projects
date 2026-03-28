import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/task.dart';
import 'isar_provider.dart';

// ─── Search & Filter Providers ────────────────────────────────────────────────
final searchQueryProvider = StateProvider<String>((ref) => '');
final statusFilterProvider = StateProvider<String?>((ref) => null);

// ─── Tasks Notifier ───────────────────────────────────────────────────────────
class TasksNotifier extends AsyncNotifier<List<Task>> {
  late Isar _isar;

  @override
  Future<List<Task>> build() async {
    _isar = await ref.watch(isarProvider.future);
    return _loadFromDb();
  }

  Future<List<Task>> _loadFromDb() {
    return _isar.tasks.where().sortBySortOrder().findAll();
  }

  Future<void> loadTasks() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadFromDb);
  }

  Future<void> createTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
    state = await AsyncValue.guard(_loadFromDb);
  }

  Future<void> updateTask(Task task) async {
    await Future.delayed(const Duration(seconds: 2));
    await _isar.writeTxn(() async {
      await _isar.tasks.put(task);
    });
    state = await AsyncValue.guard(_loadFromDb);
  }

  Future<void> deleteTask(int id) async {
    await _isar.writeTxn(() async {
      // Clear blockedById references pointing to deleted task
      final dependents = await _isar.tasks
          .filter()
          .blockedByIdEqualTo(id)
          .findAll();
      for (final dep in dependents) {
        dep.blockedById = null;
        await _isar.tasks.put(dep);
      }
      await _isar.tasks.delete(id);
    });
    state = await AsyncValue.guard(_loadFromDb);
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final tasks = state.valueOrNull;
    if (tasks == null) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final movedTask = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, movedTask);

    // Update sortOrder for all tasks to persist the new order
    await _isar.writeTxn(() async {
      for (int i = 0; i < tasks.length; i++) {
        tasks[i].sortOrder = i;
        await _isar.tasks.put(tasks[i]);
      }
    });

    state = AsyncValue.data(List.from(tasks));
  }

  Task? getTaskById(int id) {
    final tasks = state.valueOrNull;
    if (tasks == null) return null;
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

// ─── Filtered Tasks Provider ──────────────────────────────────────────────────
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasksAsync = ref.watch(tasksProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final statusFilter = ref.watch(statusFilterProvider);

  return tasksAsync.when(
    data: (tasks) {
      var result = tasks;

      if (statusFilter != null && statusFilter.isNotEmpty) {
        result = result.where((t) => t.status == statusFilter).toList();
      }

      if (query.isNotEmpty) {
        result = result
            .where((t) =>
                t.title.toLowerCase().contains(query) ||
                t.description.toLowerCase().contains(query))
            .toList();
      }

      return result;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
