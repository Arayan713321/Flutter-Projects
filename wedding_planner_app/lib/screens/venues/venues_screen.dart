import 'package:flutter/material.dart';

class VenuesScreen extends StatefulWidget {
  const VenuesScreen({Key? key}) : super(key: key);

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  List<Venue> _allVenues = [];
  List<Venue> _filteredVenues = [];
  RangeValues _budgetRange = const RangeValues(50000, 500000);
  RangeValues _capacityRange = const RangeValues(50, 500);
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _initializeVenues();
    _applyFilters();
  }

  void _initializeVenues() {
    _allVenues = [
      Venue(
        id: '1',
        name: 'Taj Palace Hotel',
        location: 'Mumbai, Maharashtra',
        priceRange: '₹2,00,000 - ₹5,00,000',
        minPrice: 200000,
        maxPrice: 500000,
        capacity: '200-400 guests',
        minCapacity: 200,
        maxCapacity: 400,
        category: 'Luxury Hotel',
        description:
            'Elegant 5-star hotel with stunning city views and world-class amenities.',
        imageUrl: '🏨',
        rating: 4.8,
        features: ['Parking', 'Catering', 'Decoration', 'Photography'],
      ),
      Venue(
        id: '2',
        name: 'Garden Palace Resort',
        location: 'Pune, Maharashtra',
        priceRange: '₹1,50,000 - ₹3,50,000',
        minPrice: 150000,
        maxPrice: 350000,
        capacity: '150-300 guests',
        minCapacity: 150,
        maxCapacity: 300,
        category: 'Resort',
        description:
            'Beautiful garden resort with outdoor and indoor wedding spaces.',
        imageUrl: '🌺',
        rating: 4.6,
        features: ['Garden', 'Pool', 'Catering', 'Accommodation'],
      ),
      Venue(
        id: '3',
        name: 'Royal Banquet Hall',
        location: 'Delhi, NCR',
        priceRange: '₹1,00,000 - ₹2,50,000',
        minPrice: 100000,
        maxPrice: 250000,
        capacity: '100-250 guests',
        minCapacity: 100,
        maxCapacity: 250,
        category: 'Banquet Hall',
        description:
            'Traditional banquet hall with modern amenities and excellent service.',
        imageUrl: '🏛️',
        rating: 4.4,
        features: ['Sound System', 'Lighting', 'Catering', 'Decoration'],
      ),
      Venue(
        id: '4',
        name: 'Beachfront Villa',
        location: 'Goa',
        priceRange: '₹3,00,000 - ₹6,00,000',
        minPrice: 300000,
        maxPrice: 600000,
        capacity: '80-150 guests',
        minCapacity: 80,
        maxCapacity: 150,
        category: 'Beach Resort',
        description:
            'Exclusive beachfront villa with private beach access and stunning ocean views.',
        imageUrl: '🏖️',
        rating: 4.9,
        features: ['Private Beach', 'Villa', 'Catering', 'Water Sports'],
      ),
      Venue(
        id: '5',
        name: 'Heritage Palace',
        location: 'Jaipur, Rajasthan',
        priceRange: '₹4,00,000 - ₹8,00,000',
        minPrice: 400000,
        maxPrice: 800000,
        capacity: '300-600 guests',
        minCapacity: 300,
        maxCapacity: 600,
        category: 'Heritage',
        description:
            'Magnificent heritage palace with royal architecture and traditional charm.',
        imageUrl: '👑',
        rating: 4.7,
        features: ['Heritage', 'Royal', 'Traditional', 'Luxury'],
      ),
      Venue(
        id: '6',
        name: 'Modern Convention Center',
        location: 'Bangalore, Karnataka',
        priceRange: '₹80,000 - ₹2,00,000',
        minPrice: 80000,
        maxPrice: 200000,
        capacity: '200-500 guests',
        minCapacity: 200,
        maxCapacity: 500,
        category: 'Convention Center',
        description:
            'State-of-the-art convention center with modern technology and flexible spaces.',
        imageUrl: '🏢',
        rating: 4.3,
        features: ['Technology', 'Flexible Space', 'Parking', 'Catering'],
      ),
      Venue(
        id: '7',
        name: 'Hill Station Resort',
        location: 'Shimla, Himachal Pradesh',
        priceRange: '₹1,20,000 - ₹3,00,000',
        minPrice: 120000,
        maxPrice: 300000,
        capacity: '100-200 guests',
        minCapacity: 100,
        maxCapacity: 200,
        category: 'Hill Station',
        description:
            'Scenic hill station resort with panoramic mountain views and cool climate.',
        imageUrl: '⛰️',
        rating: 4.5,
        features: ['Mountain View', 'Cool Climate', 'Adventure', 'Nature'],
      ),
      Venue(
        id: '8',
        name: 'Farmhouse Wedding Venue',
        location: 'Gurgaon, Haryana',
        priceRange: '₹60,000 - ₹1,80,000',
        minPrice: 60000,
        maxPrice: 180000,
        capacity: '80-200 guests',
        minCapacity: 80,
        maxCapacity: 200,
        category: 'Farmhouse',
        description:
            'Rustic farmhouse with open spaces, perfect for outdoor weddings.',
        imageUrl: '🌾',
        rating: 4.2,
        features: ['Open Space', 'Nature', 'Rustic', 'Affordable'],
      ),
    ];
  }

  void _applyFilters() {
    setState(() {
      _filteredVenues = _allVenues.where((venue) {
        final budgetMatch = venue.maxPrice >= _budgetRange.start &&
            venue.minPrice <= _budgetRange.end;
        final capacityMatch = venue.maxCapacity >= _capacityRange.start &&
            venue.minCapacity <= _capacityRange.end;
        final categoryMatch =
            _selectedCategory == 'All' || venue.category == _selectedCategory;

        return budgetMatch && capacityMatch && categoryMatch;
      }).toList();
    });
  }

  List<String> get _categories {
    final categories = _allVenues.map((v) => v.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wedding Venues',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // Budget Range
                    const Text('Budget Range (₹)',
                        style: TextStyle(fontSize: 14)),
                    RangeSlider(
                      values: _budgetRange,
                      min: 50000,
                      max: 800000,
                      divisions: 15,
                      labels: RangeLabels(
                        '₹${(_budgetRange.start / 1000).round()}K',
                        '₹${(_budgetRange.end / 1000).round()}K',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _budgetRange = values;
                        });
                        _applyFilters();
                      },
                    ),

                    // Capacity Range
                    const Text('Capacity Range (guests)',
                        style: TextStyle(fontSize: 14)),
                    RangeSlider(
                      values: _capacityRange,
                      min: 50,
                      max: 600,
                      divisions: 11,
                      labels: RangeLabels(
                        '${_capacityRange.start.round()}',
                        '${_capacityRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _capacityRange = values;
                        });
                        _applyFilters();
                      },
                    ),

                    // Category Filter
                    const Text('Category', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results count
            Text(
              '${_filteredVenues.length} venues found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // Venues List
            Expanded(
              child: _filteredVenues.isEmpty
                  ? const Center(
                      child: Text(
                        'No venues match your criteria.\nTry adjusting the filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredVenues.length,
                      itemBuilder: (context, index) {
                        final venue = _filteredVenues[index];
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
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          venue.imageUrl,
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            venue.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                venue.location,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              venue.rating.toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            venue.category,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  venue.description,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoChip(
                                        Icons.people,
                                        venue.capacity,
                                        Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildInfoChip(
                                        Icons.account_balance_wallet,
                                        venue.priceRange,
                                        Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: venue.features
                                      .map((feature) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              feature,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Show venue details or contact info
                                      _showVenueDetails(venue);
                                    },
                                    child: const Text('View Details'),
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

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showVenueDetails(Venue venue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(venue.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${venue.location}'),
            Text('Category: ${venue.category}'),
            Text('Capacity: ${venue.capacity}'),
            Text('Price Range: ${venue.priceRange}'),
            Text('Rating: ${venue.rating}/5'),
            const SizedBox(height: 16),
            const Text('Features:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...venue.features.map((feature) => Text('• $feature')),
            const SizedBox(height: 16),
            const Text(
              'Contact the venue directly for booking and more information.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class Venue {
  final String id;
  final String name;
  final String location;
  final String priceRange;
  final int minPrice;
  final int maxPrice;
  final String capacity;
  final int minCapacity;
  final int maxCapacity;
  final String category;
  final String description;
  final String imageUrl;
  final double rating;
  final List<String> features;

  Venue({
    required this.id,
    required this.name,
    required this.location,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.capacity,
    required this.minCapacity,
    required this.maxCapacity,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.features,
  });
}
