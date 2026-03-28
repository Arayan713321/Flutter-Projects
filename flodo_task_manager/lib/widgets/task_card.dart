import 'dart:io';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import 'highlighted_text.dart';

/// Formats a DateTime as "Mon, 28 Jul 2025".
String _formatDate(DateTime dt) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  try {
    return '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return dt.toIso8601String();
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.allTasks,
    required this.searchQuery,
    required this.onTap,
  });

  final Task task;
  final List<Task> allTasks;
  final String searchQuery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // ── Blocked logic ──────────────────────────────────────────────────────────
    Task? blocker;
    if (task.blockedById != null) {
      try {
        blocker = allTasks.firstWhere((t) => t.id == task.blockedById);
      } catch (_) {
        blocker = null;
      }
    }

    final isBlocked =
        blocker != null && blocker.status != TaskStatus.done.label;

    final now = DateTime.now();
    final isOverdue = task.dueDate.isBefore(
      DateTime(now.year, now.month, now.day),
    );

    final taskStatus = TaskStatusX.fromString(task.status);

    // ── Assemble card ──────────────────────────────────────────────────────────
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isBlocked ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        decoration: BoxDecoration(
          color: isBlocked ? AppColors.blocked : AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isBlocked
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: AppColors.primaryLight,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ROW 1: Title + Status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: HighlightedText(
                          text: task.title,
                          query: searchQuery,
                          baseStyle: AppTextStyles.titleMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: taskStatus),
                    ],
                  ),

                  // Image Row
                  if (task.imagePath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(task.imagePath!),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ],

                  // Blocked banner if applicable
                  if (isBlocked && blocker != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_rounded, size: 12, color: AppColors.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Blocked by: ${blocker.title}",
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ROW 2: Description
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    HighlightedText(
                      text: task.description,
                      query: searchQuery,
                      baseStyle: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const Divider(),

                  // ROW 3: Bottom metadata row
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: isOverdue ? AppColors.error : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(task.dueDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue ? AppColors.error : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (task.blockedById != null && blocker != null && !isBlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_open_rounded,
                                size: 11,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "Unblocked",
                                style: AppTextStyles.labelSmall.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: AppTextStyles.labelSmall.copyWith(color: status.color),
          ),
        ],
      ),
    );
  }
}
