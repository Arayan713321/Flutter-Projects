import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

/// Singleton Isar instance — opened once, shared across the app.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isEmpty) {
    return await Isar.open(
      [TaskSchema],
      directory: dir.path,
    );
  }
  return Isar.getInstance()!;
});
