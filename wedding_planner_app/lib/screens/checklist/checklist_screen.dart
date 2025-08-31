import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with TickerProviderStateMixin {
  List<ChecklistItem> _items = [];
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Medium';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _loadItems();
    _initializeDefaultItems();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _initializeDefaultItems() {
    if (_items.isEmpty) {
      _items = [
        ChecklistItem(
          id: '1',
          title: 'Book Wedding Venue',
          description: 'Research and book the perfect wedding venue',
          isCompleted: false,
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          category: 'Venue',
        ),
        ChecklistItem(
          id: '2',
          title: 'Hire Photographer',
          description: 'Book wedding photographer and videographer',
          isCompleted: false,
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(days: 25)),
          category: 'Photography',
        ),
        ChecklistItem(
          id: '3',
          title: 'Catering Services',
          description: 'Finalize menu and book catering services',
          isCompleted: false,
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(days: 20)),
          category: 'Food',
        ),
        ChecklistItem(
          id: '4',
          title: 'Mehendi Ceremony',
          description: 'Plan mehendi ceremony and book artist',
          isCompleted: false,
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(days: 15)),
          category: 'Ceremony',
        ),
        ChecklistItem(
          id: '5',
          title: 'Sangeet Night',
          description: 'Organize sangeet night entertainment',
          isCompleted: false,
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(days: 10)),
          category: 'Entertainment',
        ),
        ChecklistItem(
          id: '6',
          title: 'Honeymoon Booking',
          description: 'Book flights and hotels for honeymoon',
          isCompleted: false,
          priority: 'Low',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          category: 'Travel',
        ),
      ];
      _saveItems();
    }
  }

  Future<void> _loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString('checklist_items');
      if (itemsJson != null) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        _items = itemsList.map((item) => ChecklistItem.fromJson(item)).toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson =
          json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('checklist_items', itemsJson);
    } catch (e) {
      // Handle error
    }
  }

  void _toggleItem(String id) {
    setState(() {
      final item = _items.firstWhere((item) => item.id == id);
      item.isCompleted = !item.isCompleted;
    });
    _saveItems();
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
    });
    _saveItems();
  }

  void _showAddDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _dueDate = null;
    _priority = 'Medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add_task, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Add New Task'),
          ],
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.priority_high),
                      ),
                      items: ['Low', 'Medium', 'High']
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _dueDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              _dueDate == null
                                  ? 'Set Due Date'
                                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newItem = ChecklistItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  isCompleted: false,
                  priority: _priority,
                  dueDate: _dueDate,
                  category: 'Custom',
                );
                setState(() {
                  _items.add(newItem);
                });
                _saveItems();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with animations
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wedding Checklist',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${_items.where((item) => item.isCompleted).length} of ${_items.length} completed',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: ElevatedButton.icon(
                              onPressed: _showAddDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Task'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: Colors.blue.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Progress indicator
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.purple.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${((_items.where((item) => item.isCompleted).length / _items.length) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _items.isEmpty
                              ? 0
                              : _items
                                      .where((item) => item.isCompleted)
                                      .length /
                                  _items.length,
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.blue),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Tasks list
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checklist_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet. Add your first wedding task!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return AnimatedBuilder(
                          animation: _fadeAnimation,
                          builder: (context, child) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: _buildTaskCard(item),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(ChecklistItem item) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              item.isCompleted
                  ? Colors.green.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: item.isCompleted ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: item.isCompleted ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: item.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          title: Text(
            item.title,
            style: TextStyle(
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: item.isCompleted ? Colors.grey[600] : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(item.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _getPriorityColor(item.priority).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.priority,
                      style: TextStyle(
                        color: _getPriorityColor(item.priority),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (item.dueDate != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.blue[600],
                  size: 20,
                ),
                onPressed: () {
                  // Edit functionality
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[400],
                  size: 20,
                ),
                onPressed: () => _deleteItem(item.id),
              ),
            ],
          ),
          onTap: () => _toggleItem(item.id),
        ),
      ),
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final String priority;
  final DateTime? dueDate;
  final String category;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.priority,
    this.dueDate,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'category': category,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      priority: json['priority'],
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'])
          : null,
      category: json['category'],
    );
  }
}
