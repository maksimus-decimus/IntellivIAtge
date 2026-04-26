import 'package:flutter/material.dart';
import '../models/types.dart';
import '../services/favorites_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

enum FavoritesTab { attractions, restaurants }

class _FavoritesScreenState extends State<FavoritesScreen> {
  FavoritesTab _activeTab = FavoritesTab.attractions;
  final FavoritesService _favoritesService = FavoritesService();
  List<Attraction> _favoriteAttractions = [];
  List<Restaurant> _favoriteRestaurants = [];
  bool _isLoadingAttractions = false;
  bool _isLoadingRestaurants = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesService.init();
    await _loadAttractions();
    await _loadRestaurants();
  }

  Future<void> _loadAttractions() async {
    setState(() => _isLoadingAttractions = true);
    final attractions = await _favoritesService.getAttractionFavorites();
    setState(() {
      _favoriteAttractions = attractions;
      _isLoadingAttractions = false;
    });
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoadingRestaurants = true);
    final restaurants = await _favoritesService.getRestaurantFavorites();
    setState(() {
      _favoriteRestaurants = restaurants;
      _isLoadingRestaurants = false;
    });
  }

  Future<void> _removeFavoriteAttraction(String id) async {
    await _favoritesService.removeAttractionFavorite(id);
    _loadAttractions();
  }

  Future<void> _removeFavoriteRestaurant(String id) async {
    await _favoritesService.removeRestaurantFavorite(id);
    _loadRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Favoritos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Tab Toggle
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = FavoritesTab.attractions),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _activeTab == FavoritesTab.attractions ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _activeTab == FavoritesTab.attractions
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Visitas 📍',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _activeTab == FavoritesTab.attractions
                              ? const Color(0xFF1E293B)
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = FavoritesTab.restaurants),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _activeTab == FavoritesTab.restaurants ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: _activeTab == FavoritesTab.restaurants
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        'Restaurantes 🍽️',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _activeTab == FavoritesTab.restaurants
                              ? const Color(0xFF1E293B)
                              : Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _activeTab == FavoritesTab.attractions
                ? _buildAttractionsList()
                : _buildRestaurantsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionsList() {
    if (_isLoadingAttractions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteAttractions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay visitas guardadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade tus lugares favoritos',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _favoriteAttractions.length,
      itemBuilder: (context, index) {
        final attraction = _favoriteAttractions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.network(
                  attraction.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeFavoriteAttraction(attraction.id),
                            child: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        attraction.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            attraction.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantsList() {
    if (_isLoadingRestaurants) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay restaurantes guardados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda tus restaurantes favoritos',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _favoriteRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _favoriteRestaurants[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: Image.network(
                  restaurant.image ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeFavoriteRestaurant(restaurant.id),
                            child: Icon(Icons.close, size: 20, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.type,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
