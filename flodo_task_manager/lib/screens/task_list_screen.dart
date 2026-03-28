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
      backgroundColor: const Color(0xFFF4F5FA),
      body: SafeArea(
        child: Stack(
          children: [
            // Top glow decoration
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: 60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            CustomScrollView(
              slivers: [
                // HEADER SECTION
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_getGreeting(), style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 4),
                            const Text("My Tasks", style: AppTextStyles.headline),
                          ],
                        ),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/tasks.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.task_alt_rounded, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
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
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // STATS ROW
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(child: _StatCard(count: totalCount, label: "Total", color: AppColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(count: doneCount, label: "Done", color: AppColors.success)),
                        const SizedBox(width: 10),
                        Expanded(child: _StatCard(count: inProgressCount, label: "In Progress", color: AppColors.warning)),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // FILTER CHIPS ROW
                SliverToBoxAdapter(
                  child: _FilterRow(
                    selected: selectedFilter,
                    onSelected: (val) {
                      ref.read(statusFilterProvider.notifier).state = val;
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // TASK LIST
                tasksAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text("Error: $e")),
                  ),
                  data: (_) {
                    if (filteredTasks.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      );
                    }

                    final isSearchingOrFiltering = searchQuery.isNotEmpty || selectedFilter != null;

                    return SliverReorderableList(
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
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.redAccent, Colors.red],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                              ),
                              confirmDismiss: (direction) async {
                                final messenger = ScaffoldMessenger.of(context);
                                final deletedTask = task;
                                
                                await ref.read(tasksProvider.notifier).deleteTask(task.id);
                                
                                messenger.hideCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: const Text("Task deleted"),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      onPressed: () {
                                        ref.read(tasksProvider.notifier).createTask(deletedTask);
                                      },
                                    ),
                                  ),
                                );
                                return true;
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
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: count),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              value.toString(),
              style: AppTextStyles.titleLarge.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall),
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
    final labels = ['All', '📋 To-Do', '⚡ In Progress', '✅ Done'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: EdgeInsets.only(right: i == filters.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onSelected(filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected ? null : Border.all(color: AppColors.divider),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8)]
                      : null,
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
              child: Center(
                child: Image.asset(
                  'assets/tasks.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.task_alt_rounded, size: 60, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("No tasks yet", style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            const Text(
              "Tap + to create your first task",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
