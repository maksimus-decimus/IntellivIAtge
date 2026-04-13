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

// ============================================================================
// CHAT SYSTEM MODELS
// ============================================================================

/// User profile for chat system
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String status; // "online" | "offline"
  final DateTime? lastSeen;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.status = 'offline',
    this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'status': status,
      'lastSeen': lastSeen?.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      status: map['status'] ?? 'offline',
      lastSeen: map['lastSeen'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeen']) 
          : null,
    );
  }
}

/// Message status enum
enum MessageStatus { sent, delivered, read }

/// Location data for messages
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      address: map['address'],
    );
  }
}

/// Individual message in a conversation
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final LocationData? locationData;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.text,
    this.imageUrl,
    this.locationData,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'locationData': locationData?.toMap(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'],
      imageUrl: map['imageUrl'],
      locationData: map['locationData'] != null 
          ? LocationData.fromMap(map['locationData']) 
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      status: _parseMessageStatus(map['status']),
    );
  }

  static MessageStatus _parseMessageStatus(String? status) {
    switch (status) {
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    String? imageUrl,
    LocationData? locationData,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      locationData: locationData ?? this.locationData,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

/// Group metadata for group conversations
class GroupMetadata {
  final String name;
  final String? imageUrl;
  final List<String> adminIds;
  final String createdBy;
  final DateTime createdAt;

  GroupMetadata({
    required this.name,
    this.imageUrl,
    required this.adminIds,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'adminIds': adminIds,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory GroupMetadata.fromMap(Map<String, dynamic> map) {
    return GroupMetadata(
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      adminIds: List<String>.from(map['adminIds'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }
}

/// Conversation (direct or group chat)
class Conversation {
  final String id;
  final String type; // "direct" | "group"
  final List<String> participantIds;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCounts; // userId -> count
  final GroupMetadata? groupMetadata;

  Conversation({
    required this.id,
    required this.type,
    required this.participantIds,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCounts = const {},
    this.groupMetadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'unreadCounts': unreadCounts,
      'groupMetadata': groupMetadata?.toMap(),
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      type: map['type'] ?? 'direct',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      groupMetadata: map['groupMetadata'] != null
          ? GroupMetadata.fromMap(map['groupMetadata'])
          : null,
    );
  }

  Conversation copyWith({
    String? id,
    String? type,
    List<String>? participantIds,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
    GroupMetadata? groupMetadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      groupMetadata: groupMetadata ?? this.groupMetadata,
    );
  }
}

/// Friend request status
enum FriendRequestStatus { pending, accepted, rejected }

/// Friend request model
class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      status: _parseFriendRequestStatus(map['status']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  static FriendRequestStatus _parseFriendRequestStatus(String? status) {
    switch (status) {
      case 'accepted':
        return FriendRequestStatus.accepted;
      case 'rejected':
        return FriendRequestStatus.rejected;
      default:
        return FriendRequestStatus.pending;
    }
  }
}
