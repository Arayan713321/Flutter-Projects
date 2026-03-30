import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  void _navigateToCreate() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondAnimation) => const TaskFormScreen(),
        transitionsBuilder: (context, animation, secondAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToEdit(Task task) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondAnimation) => TaskFormScreen(task: task),
        transitionsBuilder: (context, animation, secondAnimation, child) {
          return SlideTransition(
            position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))),
            child: child,
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Task task) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 36),
            ),
            const SizedBox(height: 24),
            const Text("Remove Assignment?", style: AppTextStyles.titleLarge),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Are you sure you want to delete '${task.title}'? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        backgroundColor: AppColors.background,
                      ),
                      child: Text("Keep it", style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text("Delete", style: AppTextStyles.buttonText.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await ref.read(tasksProvider.notifier).deleteTask(task.id);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final allTasks = tasksAsync.valueOrNull ?? [];
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(statusFilterProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final totalCount = allTasks.length;
    final doneCount = allTasks.where((t) => t.status == 'Done').length;
    final inProgressCount = allTasks.where((t) => t.status == 'In Progress').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // PREMIUM HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getGreeting(), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                            const SizedBox(height: 6),
                            const Text("My Productivity", style: AppTextStyles.headline),
                          ],
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/tasks.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SEARCH BAR - REFINED
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: "Search your tasks...",
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).state = '';
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                // STATS ROW - PREMIUM
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: _StatCard(count: totalCount, label: "Total", color: AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(count: doneCount, label: "Done", color: AppColors.success)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(count: inProgressCount, label: "Active", color: AppColors.warning)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // SECTION TITLE & FILTER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text(
                          selectedFilter == null ? "Recent Tasks" : "$selectedFilter Tasks",
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                        ),
                        const Spacer(),
                        const Icon(Icons.tune_rounded, size: 18, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // FILTER CHIPS
                SliverToBoxAdapter(
                  child: _FilterRow(
                    selected: selectedFilter,
                    onSelected: (val) {
                      ref.read(statusFilterProvider.notifier).state = val;
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // TASK LIST
                tasksAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                          const SizedBox(height: 16),
                          Text("Something went wrong: $e", style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  data: (_) {
                    if (filteredTasks.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(query: searchQuery),
                      );
                    }

                    final isSearchingOrFiltering = searchQuery.isNotEmpty || selectedFilter != null;

                    return SliverPadding(
                      padding: const EdgeInsets.only(bottom: 100),
                      sliver: SliverReorderableList(
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(task.id),
                            index: index,
                            enabled: !isSearchingOrFiltering,
                            child: _StaggeredListEntrance(
                              index: index,
                              child: Dismissible(
                                key: ValueKey("dismiss_${task.id}"),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 32),
                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF8B8B), Color(0xFFFF5252)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                                  ),
                                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 32),
                                ),
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmation(context, task);
                                },
                                child: TaskCard(
                                  task: task,
                                  allTasks: allTasks,
                                  searchQuery: searchQuery,
                                  onTap: () => _navigateToEdit(task),
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: filteredTasks.length,
                        onReorder: (oldIdx, newIdx) {
                          if (isSearchingOrFiltering) return;
                          ref.read(tasksProvider.notifier).reorderTasks(oldIdx, newIdx);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _Fab(onPressed: _navigateToCreate),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.count, required this.label, required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            builder: (context, value, _) => Text(
              value.toString(),
              style: AppTextStyles.titleLarge.copyWith(color: color, fontSize: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});
  final String? selected;
  final Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [null, 'To-Do', 'In Progress', 'Done'];
    final labels = ['All', 'To-Do', 'Progress', 'Done'];
    final icons = [Icons.apps_rounded, Icons.list_rounded, Icons.bolt_rounded, Icons.check_circle_rounded];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () => onSelected(filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected ? null : Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icons[i],
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.04),
              ),
              child: Center(
                child: Icon(
                  query.isEmpty ? Icons.auto_awesome_rounded : Icons.search_off_rounded,
                  size: 80,
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              query.isEmpty ? "All caught up" : "No results found",
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              query.isEmpty 
                  ? "You don't have any tasks right now.\nTap the button below to start."
                  : "We couldn't find any tasks matching '$query'.\nTry a different keyword.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


class _StaggeredListEntrance extends StatefulWidget {
  const _StaggeredListEntrance({required this.child, required this.index});
  final Widget child;
  final int index;

  @override
  State<_StaggeredListEntrance> createState() => _StaggeredListEntranceState();
}

class _StaggeredListEntranceState extends State<_StaggeredListEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: _opacityAnimation.value,
        child: SlideTransition(position: _offsetAnimation, child: child),
      ),
      child: widget.child,
    );
  }
}

class _Fab extends StatefulWidget {
  const _Fab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B85FF), Color(0xFF6C63FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            setState(() => _scale = 0.95);
            await Future.delayed(const Duration(milliseconds: 100));
            setState(() => _scale = 1.0);
            widget.onPressed();
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: const Text(
            "New Task",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
