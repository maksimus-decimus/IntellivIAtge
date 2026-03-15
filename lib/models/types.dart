import 'package:flutter/material.dart';

enum ScreenName {
  login,
  home,
  map,
  aiGuide,
  attractions,
  restaurants,
  activities,
  transport,
  trips,
  groups,
  translator,
  currency,
  security,
  profile,
  firstTimeGuide
}

class Attraction {
  final String id;
  final String name;
  final String category;
  final String image;
  final double rating;
  final String description;

  Attraction({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.rating,
    required this.description,
  });
}

class MenuItem {
  final ScreenName id;
  final String label;
  final IconData icon;
  final Color color;
  final Color shadowColor;

  MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.shadowColor,
  });
}

class ChatMessage {
  final String id;
  final String role; // 'user' or 'model'
  final String text;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
  });
}

class TransportOption {
  final String id;
  final String type;
  final String name;
  final String price;
  final String description;
  final String tips;
  final String icon;

  TransportOption({
    required this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.description,
    required this.tips,
    required this.icon,
  });
}

class Dish {
  final String id;
  final String name;
  final String description;
  final String image;
  final bool isVegetarian;
  final bool? isSpicy;
  final String? photoUrl;
  final List<Review> reviews;
  final List<RecommendedRestaurant> recommendedRestaurants;

  Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.isVegetarian,
    this.isSpicy,
    this.photoUrl,
    required this.reviews,
    required this.recommendedRestaurants,
  });
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String? image;
  final double rating;
  final String averagePrice;
  final List<String> specialties;
  final String address;
  final String type;
  final String priceLevel;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.rating,
    required this.averagePrice,
    required this.specialties,
    required this.address,
    required this.type,
    required this.priceLevel,
  });
}

class Review {
  final String user;
  final String comment;
  final int rating;

  Review({
    required this.user,
    required this.comment,
    required this.rating,
  });
}

class RecommendedRestaurant {
  final String name;
  final String address;
  final double rating;

  RecommendedRestaurant({
    required this.name,
    required this.address,
    required this.rating,
  });
}

class CommunityPost {
  final int id;
  final String user;
  final String handle;
  final String avatar;
  final String place;
  final int rating;
  final String comment;
  final String time;

  CommunityPost({
    required this.id,
    required this.user,
    required this.handle,
    required this.avatar,
    required this.place,
    required this.rating,
    required this.comment,
    required this.time,
  });
}
