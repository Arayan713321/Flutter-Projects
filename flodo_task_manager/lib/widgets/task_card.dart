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
      opacity: isBlocked ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isBlocked ? AppColors.blocked : AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          border: Border.all(
            color: isBlocked ? AppColors.divider : AppColors.cardBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isBlocked 
                  ? Colors.black.withOpacity(0.02) 
                  : AppColors.primary.withOpacity(0.08),
              blurRadius: isBlocked ? 8 : 24,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          child: Stack(
            children: [
              // Left status indicator bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: isBlocked ? AppColors.textMuted : taskStatus.color,
                  ),
                ),
              ),
              
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: AppColors.primary.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
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
                                baseStyle: AppTextStyles.titleMedium.copyWith(
                                  color: isBlocked ? AppColors.textMuted : AppColors.textPrimary,
                                  decoration: taskStatus == TaskStatus.done ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip(status: taskStatus),
                          ],
                        ),

                        // Image Row with premium framing
                        if (task.imagePath != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(task.imagePath!),
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],

                        // Blocked banner if applicable
                        if (isBlocked && blocker != null)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.error.withOpacity(0.1), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.lock_person_rounded, size: 14, color: AppColors.error),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Waiting for: ${blocker.title}",
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, letterSpacing: 0),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ROW 2: Description
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          HighlightedText(
                            text: task.description,
                            query: searchQuery,
                            baseStyle: AppTextStyles.bodyMedium.copyWith(
                              color: isBlocked ? AppColors.textMuted : AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // ROW 3: Bottom metadata row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isOverdue ? AppColors.error.withOpacity(0.1) : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: isOverdue ? AppColors.error : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(task.dueDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (task.blockedById != null && blocker != null && !isBlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.success),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Unlocked",
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
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

