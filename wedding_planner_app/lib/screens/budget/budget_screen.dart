import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();
  double _totalBudget = 0;
  List<BudgetCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudget();
    _initializeDefaultCategories();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _initializeDefaultCategories() {
    if (_categories.isEmpty) {
      _categories = [
        BudgetCategory(
          id: '1',
          name: 'Venue & Catering',
          percentage: 40,
          color: Colors.blue,
          icon: Icons.place,
          description: 'Wedding venue, catering services, and food',
        ),
        BudgetCategory(
          id: '2',
          name: 'Photography & Videography',
          percentage: 15,
          color: Colors.purple,
          icon: Icons.camera_alt,
          description: 'Professional photos and videos',
        ),
        BudgetCategory(
          id: '3',
          name: 'Decoration & Flowers',
          percentage: 12,
          color: Colors.pink,
          icon: Icons.local_florist,
          description: 'Wedding decor, floral arrangements',
        ),
        BudgetCategory(
          id: '4',
          name: 'Attire & Jewelry',
          percentage: 10,
          color: Colors.orange,
          icon: Icons.checkroom,
          description: 'Bridal and groom attire, jewelry',
        ),
        BudgetCategory(
          id: '5',
          name: 'Entertainment',
          percentage: 8,
          color: Colors.green,
          icon: Icons.music_note,
          description: 'Music, dance, and entertainment',
        ),
        BudgetCategory(
          id: '6',
          name: 'Transportation',
          percentage: 5,
          color: Colors.red,
          icon: Icons.directions_car,
          description: 'Vehicle rentals and transportation',
        ),
        BudgetCategory(
          id: '7',
          name: 'Invitations & Stationery',
          percentage: 3,
          color: Colors.teal,
          icon: Icons.mail,
          description: 'Wedding cards and stationery',
        ),
        BudgetCategory(
          id: '8',
          name: 'Miscellaneous',
          percentage: 7,
          color: Colors.grey,
          icon: Icons.more_horiz,
          description: 'Other expenses and contingencies',
        ),
      ];
      _saveBudget();
    }
  }

  Future<void> _loadBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetJson = prefs.getString('wedding_budget');
      if (budgetJson != null) {
        final budgetData = json.decode(budgetJson);
        setState(() {
          _totalBudget = (budgetData['totalBudget'] ?? 0).toDouble();
          if (budgetData['categories'] != null) {
            _categories = (budgetData['categories'] as List)
                .map((cat) => BudgetCategory.fromJson(cat))
                .toList();
          }
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetData = {
        'totalBudget': _totalBudget,
        'categories': _categories.map((cat) => cat.toJson()).toList(),
      };
      await prefs.setString('wedding_budget', json.encode(budgetData));
    } catch (e) {
      // Handle error
    }
  }

  void _setBudget() {
    final budget = double.tryParse(_budgetController.text);
    if (budget != null && budget > 0) {
      setState(() {
        _totalBudget = budget;
      });
      _saveBudget();
      _budgetController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget set to ₹${_totalBudget.toStringAsFixed(0)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
    }
  }

  void _editCategory(BudgetCategory category) {
    final nameController = TextEditingController(text: category.name);
    final percentageController = TextEditingController(text: category.percentage.toString());
    final descriptionController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${category.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: percentageController,
              decoration: const InputDecoration(
                labelText: 'Percentage (%)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final percentage = double.tryParse(percentageController.text);
              if (percentage != null && percentage > 0 && percentage <= 100) {
                setState(() {
                  category.name = nameController.text;
                  category.percentage = percentage;
                  category.description = descriptionController.text;
                });
                _saveBudget();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid percentage (1-100)')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double _getCategoryAmount(double percentage) {
    return (_totalBudget * percentage) / 100;
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
            Text(
              'Wedding Budget',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Budget Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Your Total Budget',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _budgetController,
                            decoration: const InputDecoration(
                              labelText: 'Budget Amount (₹)',
                              border: OutlineInputBorder(),
                              prefixText: '₹',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _setBudget,
                          child: const Text('Set Budget'),
                        ),
                      ],
                    ),
                    if (_totalBudget > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Budget',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹${_totalBudget.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_totalBudget > 0) ...[
              const SizedBox(height: 16),
              
              // Budget Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Total: ₹${_totalBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final amount = _getCategoryAmount(category.percentage);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        category.description,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editCategory(category),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Percentage',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${category.percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: category.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '₹${amount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            LinearProgressIndicator(
                              value: category.percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(category.color),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_totalBudget == 0) ...[
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Set your wedding budget to get started!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll help you allocate your budget across different categories.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BudgetCategory {
  String id;
  String name;
  double percentage;
  Color color;
  IconData icon;
  String description;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.percentage,
    required this.color,
    required this.icon,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'percentage': percentage,
      'color': color.value,
      'icon': icon.codePoint,
      'description': description,
    };
  }

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id'],
      name: json['name'],
      percentage: (json['percentage'] ?? 0).toDouble(),
      color: Color(json['color'] ?? Colors.grey.value),
      icon: IconData(json['icon'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      description: json['description'] ?? '',
    );
  }
}