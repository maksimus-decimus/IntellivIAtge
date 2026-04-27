import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/types.dart';
import '../services/favorites_service.dart';
import '../widgets/add_to_agenda_dialog.dart';
import '../widgets/attraction_details_modal.dart';

class AttractionsScreen extends StatefulWidget {
  const AttractionsScreen({Key? key}) : super(key: key);

  @override
  State<AttractionsScreen> createState() => _AttractionsScreenState();
}

class _AttractionsScreenState extends State<AttractionsScreen> {
  String? _selectedCategory;
  final FavoritesService _favoritesService = FavoritesService();
  Set<String> _favoriteIds = {};
  
  List<Attraction> get _filteredAttractions {
    if (_selectedCategory == null) {
      return AppConstants.barcelonaAttractions;
    }
    return AppConstants.barcelonaAttractions
        .where((attraction) => attraction.category == _selectedCategory)
        .toList();
  }
  
  List<String> get _categories {
    return AppConstants.barcelonaAttractions
        .map((attraction) => attraction.category)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesService.init();
    final favorites = await _favoritesService.getAttractionFavorites();
    setState(() {
      _favoriteIds = favorites.map((fav) => fav.id).toSet();
    });
  }

  Future<void> _toggleFavorite(Attraction attraction) async {
    final isFavorite = _favoriteIds.contains(attraction.id);
    
    if (isFavorite) {
      await _favoritesService.removeAttractionFavorite(attraction.id);
    } else {
      await _favoritesService.addAttractionFavorite(attraction);
    }
    
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter Chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // "Todo" chip
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Todo'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFFFBBF24),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedCategory == null ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
                // Category chips
                ..._categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFFFBBF24),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _selectedCategory == category ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        // Attractions List
        Expanded(
          child: _filteredAttractions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay atracciones en esta categoría',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _filteredAttractions.length,
                  itemBuilder: (context, index) {
                    final attraction = _filteredAttractions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with Favorite Button
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                child: Image.network(
                                  attraction.image,
                                  height: 240,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(Icons.image, size: 64, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Favorite Button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () => _toggleFavorite(attraction),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      _favoriteIds.contains(attraction.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _favoriteIds.contains(attraction.id)
                                          ? const Color(0xFFEF4444)
                                          : Colors.grey[600],
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        attraction.name,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1E293B),
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: Color(0xFFFBBF24),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            attraction.rating.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1E293B),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF8FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    attraction.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0EA5E9),
                                      fontSize: 11,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  attraction.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    height: 1.5,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(24),
                                              ),
                                            ),
                                            builder: (context) => AttractionDetailsModal(
                                              attraction: attraction,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 11),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0F9FF),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFE0F2FE), width: 1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Ver ubicación',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AddToAgendaDialog(
                                              itemName: attraction.name,
                                              itemType: 'attraction',
                                              attraction: attraction,
                                              onSuccess: () {
                                                // Refresh or show success message
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 11),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFCE7F3),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFFFBBE1), width: 1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_today, size: 16, color: Colors.pink[600]),
                                              const SizedBox(width: 6),
                                              Text(
                                                'A la agenda',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.pink[600],
                                                ),
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
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

