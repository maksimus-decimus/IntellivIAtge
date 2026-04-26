import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/types.dart';

class FavoritesService {
  static const String _attractionsKey = 'favorite_attractions';
  static const String _restaurantsKey = 'favorite_restaurants';
  
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ATTRACTIONS
  Future<bool> addAttractionFavorite(Attraction attraction) async {
    try {
      final favorites = await getAttractionFavorites();
      
      // Evitar duplicados
      if (favorites.any((fav) => fav.id == attraction.id)) {
        return false;
      }
      
      favorites.add(attraction);
      final jsonList = favorites.map((fav) => _attractionToJson(fav)).toList();
      await _prefs.setString(_attractionsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error adding attraction favorite: $e');
      return false;
    }
  }
  
  Future<bool> removeAttractionFavorite(String attractionId) async {
    try {
      final favorites = await getAttractionFavorites();
      favorites.removeWhere((fav) => fav.id == attractionId);
      final jsonList = favorites.map((fav) => _attractionToJson(fav)).toList();
      await _prefs.setString(_attractionsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error removing attraction favorite: $e');
      return false;
    }
  }
  
  Future<List<Attraction>> getAttractionFavorites() async {
    try {
      final jsonString = _prefs.getString(_attractionsKey) ?? '[]';
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _jsonToAttraction(json)).toList();
    } catch (e) {
      print('Error getting attraction favorites: $e');
      return [];
    }
  }
  
  Future<bool> isAttractionFavorite(String attractionId) async {
    final favorites = await getAttractionFavorites();
    return favorites.any((fav) => fav.id == attractionId);
  }
  
  // RESTAURANTS
  Future<bool> addRestaurantFavorite(Restaurant restaurant) async {
    try {
      final favorites = await getRestaurantFavorites();
      
      // Evitar duplicados
      if (favorites.any((fav) => fav.id == restaurant.id)) {
        return false;
      }
      
      favorites.add(restaurant);
      final jsonList = favorites.map((fav) => _restaurantToJson(fav)).toList();
      await _prefs.setString(_restaurantsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error adding restaurant favorite: $e');
      return false;
    }
  }
  
  Future<bool> removeRestaurantFavorite(String restaurantId) async {
    try {
      final favorites = await getRestaurantFavorites();
      favorites.removeWhere((fav) => fav.id == restaurantId);
      final jsonList = favorites.map((fav) => _restaurantToJson(fav)).toList();
      await _prefs.setString(_restaurantsKey, jsonEncode(jsonList));
      return true;
    } catch (e) {
      print('Error removing restaurant favorite: $e');
      return false;
    }
  }
  
  Future<List<Restaurant>> getRestaurantFavorites() async {
    try {
      final jsonString = _prefs.getString(_restaurantsKey) ?? '[]';
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _jsonToRestaurant(json)).toList();
    } catch (e) {
      print('Error getting restaurant favorites: $e');
      return [];
    }
  }
  
  Future<bool> isRestaurantFavorite(String restaurantId) async {
    final favorites = await getRestaurantFavorites();
    return favorites.any((fav) => fav.id == restaurantId);
  }
  
  // SERIALIZATION - Attractions
  Map<String, dynamic> _attractionToJson(Attraction attraction) {
    return {
      'id': attraction.id,
      'name': attraction.name,
      'category': attraction.category,
      'image': attraction.image,
      'rating': attraction.rating,
      'description': attraction.description,
    };
  }
  
  Attraction _jsonToAttraction(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: (json['rating'] as num).toDouble(),
      description: json['description'] as String,
    );
  }
  
  // SERIALIZATION - Restaurants
  Map<String, dynamic> _restaurantToJson(Restaurant restaurant) {
    return {
      'id': restaurant.id,
      'name': restaurant.name,
      'description': restaurant.description,
      'image': restaurant.image,
      'rating': restaurant.rating,
      'averagePrice': restaurant.averagePrice,
      'specialties': restaurant.specialties,
      'address': restaurant.address,
      'type': restaurant.type,
      'priceLevel': restaurant.priceLevel,
    };
  }
  
  Restaurant _jsonToRestaurant(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      rating: (json['rating'] as num).toDouble(),
      averagePrice: json['averagePrice'] as String,
      specialties: List<String>.from(json['specialties'] as List),
      address: json['address'] as String,
      type: json['type'] as String,
      priceLevel: json['priceLevel'] as String,
    );
  }
  
  // Clear all
  Future<void> clearAll() async {
    await _prefs.remove(_attractionsKey);
    await _prefs.remove(_restaurantsKey);
  }
}
