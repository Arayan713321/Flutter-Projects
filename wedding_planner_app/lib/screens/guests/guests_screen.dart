import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({Key? key}) : super(key: key);

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  List<Guest> _guests = [];
  bool _isLoading = true;
  String _filterStatus = 'All';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();
  String _selectedStatus = 'Pending';
  int _selectedGuests = 1;

  @override
  void initState() {
    super.initState();
    _loadGuests();
    _initializeSampleGuests();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _initializeSampleGuests() {
    if (_guests.isEmpty) {
      _guests = [
        Guest(
          id: '1',
          name: 'Priya Sharma',
          phone: '+91 98765 43210',
          email: 'priya.sharma@email.com',
          relationship: 'Bride\'s Best Friend',
          status: 'Confirmed',
          numberOfGuests: 2,
          notes: 'Vegetarian food preference',
        ),
        Guest(
          id: '2',
          name: 'Rahul Verma',
          phone: '+91 87654 32109',
          email: 'rahul.verma@email.com',
          relationship: 'Groom\'s Cousin',
          status: 'Confirmed',
          numberOfGuests: 3,
          notes: 'Will arrive on wedding day',
        ),
        Guest(
          id: '3',
          name: 'Anita Patel',
          phone: '+91 76543 21098',
          email: 'anita.patel@email.com',
          relationship: 'Family Friend',
          status: 'Pending',
          numberOfGuests: 1,
          notes: '',
        ),
        Guest(
          id: '4',
          name: 'Vikram Singh',
          phone: '+91 65432 10987',
          email: 'vikram.singh@email.com',
          relationship: 'Groom\'s College Friend',
          status: 'Declined',
          numberOfGuests: 0,
          notes: 'Out of town for work',
        ),
        Guest(
          id: '5',
          name: 'Meera Reddy',
          phone: '+91 54321 09876',
          email: 'meera.reddy@email.com',
          relationship: 'Bride\'s Aunt',
          status: 'Confirmed',
          numberOfGuests: 4,
          notes: 'Family of 4 including kids',
        ),
      ];
      _saveGuests();
    }
  }

  Future<void> _loadGuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = prefs.getString('wedding_guests');
      if (guestsJson != null) {
        final List<dynamic> guestsList = json.decode(guestsJson);
        _guests = guestsList.map((guest) => Guest.fromJson(guest)).toList();
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveGuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final guestsJson = json.encode(_guests.map((guest) => guest.toJson()).toList());
      await prefs.setString('wedding_guests', guestsJson);
    } catch (e) {
      // Handle error
    }
  }

  void _addGuest() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _relationshipController.clear();
    _selectedStatus = 'Pending';
    _selectedGuests = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Guest'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Guest Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guest name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'RSVP Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Pending', 'Confirmed', 'Declined']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedGuests,
                        decoration: const InputDecoration(
                          labelText: 'Number of Guests',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(6, (index) => index + 1)
                            .map((count) => DropdownMenuItem(
                                  value: count,
                                  child: Text('$count'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGuests = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                final newGuest = Guest(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  phone: _phoneController.text,
                  email: _emailController.text,
                  relationship: _relationshipController.text,
                  status: _selectedStatus,
                  numberOfGuests: _selectedStatus == 'Declined' ? 0 : _selectedGuests,
                  notes: '',
                );
                setState(() {
                  _guests.add(newGuest);
                });
                _saveGuests();
                Navigator.pop(context);
              }
            },
            child: const Text('Add Guest'),
          ),
        ],
      ),
    );
  }

  void _editGuest(Guest guest) {
    _nameController.text = guest.name;
    _phoneController.text = guest.phone;
    _emailController.text = guest.email;
    _relationshipController.text = guest.relationship;
    _selectedStatus = guest.status;
    _selectedGuests = guest.numberOfGuests;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${guest.name}'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Guest Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guest name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _relationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'RSVP Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Pending', 'Confirmed', 'Declined']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedGuests,
                        decoration: const InputDecoration(
                          labelText: 'Number of Guests',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(6, (index) => index + 1)
                            .map((count) => DropdownMenuItem(
                                  value: count,
                                  child: Text('$count'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGuests = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
                setState(() {
                  guest.name = _nameController.text;
                  guest.phone = _phoneController.text;
                  guest.email = _emailController.text;
                  guest.relationship = _relationshipController.text;
                  guest.status = _selectedStatus;
                  guest.numberOfGuests = _selectedStatus == 'Declined' ? 0 : _selectedGuests;
                });
                _saveGuests();
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _deleteGuest(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest'),
        content: const Text('Are you sure you want to delete this guest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _guests.removeWhere((guest) => guest.id == id);
              });
              _saveGuests();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(Guest guest, String newStatus) {
    setState(() {
      guest.status = newStatus;
      if (newStatus == 'Declined') {
        guest.numberOfGuests = 0;
      } else if (guest.numberOfGuests == 0) {
        guest.numberOfGuests = 1;
      }
    });
    _saveGuests();
  }

  List<Guest> get _filteredGuests {
    if (_filterStatus == 'All') return _guests;
    return _guests.where((guest) => guest.status == _filterStatus).toList();
  }

  int get _totalConfirmedGuests {
    return _guests
        .where((guest) => guest.status == 'Confirmed')
        .fold(0, (sum, guest) => sum + guest.numberOfGuests);
  }

  int get _totalPendingGuests {
    return _guests
        .where((guest) => guest.status == 'Pending')
        .fold(0, (sum, guest) => sum + guest.numberOfGuests);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Declined':
        return Colors.red;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guest List',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addGuest,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Guest'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Confirmed',
                    _guests.where((g) => g.status == 'Confirmed').length.toString(),
                    _totalConfirmedGuests.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    _guests.where((g) => g.status == 'Pending').length.toString(),
                    _totalPendingGuests.toString(),
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _guests.length.toString(),
                    (_totalConfirmedGuests + _totalPendingGuests).toString(),
                    Colors.blue,
                    Icons.people,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Filter
            Row(
              children: [
                const Text('Filter by status: ', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filterStatus,
                  items: ['All', 'Confirmed', 'Pending', 'Declined']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value!;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Guest List
            Expanded(
              child: _filteredGuests.isEmpty
                  ? const Center(
                      child: Text(
                        'No guests found.\nAdd your first guest to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredGuests.length,
                      itemBuilder: (context, index) {
                        final guest = _filteredGuests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(guest.status).withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                color: _getStatusColor(guest.status),
                              ),
                            ),
                            title: Text(
                              guest.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (guest.relationship.isNotEmpty)
                                  Text(
                                    guest.relationship,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                if (guest.phone.isNotEmpty)
                                  Text(
                                    '📱 ${guest.phone}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                if (guest.email.isNotEmpty)
                                  Text(
                                    '📧 ${guest.email}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(guest.status).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getStatusColor(guest.status).withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        guest.status,
                                        style: TextStyle(
                                          color: _getStatusColor(guest.status),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '${guest.numberOfGuests} guest${guest.numberOfGuests != 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _editGuest(guest);
                                    break;
                                  case 'delete':
                                    _deleteGuest(guest.id);
                                    break;
                                  case 'confirmed':
                                    _updateStatus(guest, 'Confirmed');
                                    break;
                                  case 'pending':
                                    _updateStatus(guest, 'Pending');
                                    break;
                                  case 'declined':
                                    _updateStatus(guest, 'Declined');
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 16),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                if (guest.status != 'Confirmed')
                                  const PopupMenuItem(
                                    value: 'confirmed',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Mark Confirmed'),
                                      ],
                                    ),
                                  ),
                                if (guest.status != 'Pending')
                                  const PopupMenuItem(
                                    value: 'pending',
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule, size: 16, color: Colors.orange),
                                        SizedBox(width: 8),
                                        Text('Mark Pending'),
                                      ],
                                    ),
                                  ),
                                if (guest.status != 'Declined')
                                  const PopupMenuItem(
                                    value: 'declined',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel, size: 16, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Mark Declined'),
                                      ],
                                    ),
                                  ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, String guests, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$guests guests',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Guest {
  String id;
  String name;
  String phone;
  String email;
  String relationship;
  String status;
  int numberOfGuests;
  String notes;

  Guest({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.relationship,
    required this.status,
    required this.numberOfGuests,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'relationship': relationship,
      'status': status,
      'numberOfGuests': numberOfGuests,
      'notes': notes,
    };
  }

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      relationship: json['relationship'] ?? '',
      status: json['status'] ?? 'Pending',
      numberOfGuests: json['numberOfGuests'] ?? 1,
      notes: json['notes'] ?? '',
    );
  }
}