import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart';

/// Service for user management operations
/// 
/// Handles:
/// - User profile management
/// - User search by email/name
/// - Friend requests
/// - User presence (online/offline status)
class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================================
  // USER PROFILE METHODS
  // ============================================================================

  /// Create or update user profile in Firestore
  /// Call this after user registration or login
  Future<void> createOrUpdateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final profile = UserProfile(
        id: user.uid,
        name: displayName ?? user.displayName ?? 'Usuario',
        email: user.email ?? '',
        photoUrl: photoUrl ?? user.photoURL,
        status: 'online',
        lastSeen: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user profile: $e');
    }
  }

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      return UserProfile.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Get multiple user profiles at once
  Future<List<UserProfile>> getUserProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    try {
      final profiles = <UserProfile>[];
      
      // Firestore has a limit of 10 items for 'in' queries
      // So we batch the requests
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        profiles.addAll(
          snapshot.docs.map((doc) => UserProfile.fromMap({...doc.data(), 'id': doc.id}))
        );
      }

      return profiles;
    } catch (e) {
      print('Error getting user profiles: $e');
      return [];
    }
  }

  /// Update current user's display name
  Future<bool> updateDisplayName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.updateDisplayName(newName);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'name': newName});

      return true;
    } catch (e) {
      print('Error updating display name: $e');
      return false;
    }
  }

  /// Update current user's photo URL
  Future<bool> updatePhotoUrl(String newPhotoUrl) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.updatePhotoURL(newPhotoUrl);
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'photoUrl': newPhotoUrl});

      return true;
    } catch (e) {
      print('Error updating photo URL: $e');
      return false;
    }
  }

  /// Update user status (online/offline)
  Future<void> updateUserStatus(String status) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'status': status,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  /// Set user as online
  Future<void> setOnline() async {
    await updateUserStatus('online');
  }

  /// Set user as offline
  Future<void> setOffline() async {
    await updateUserStatus('offline');
  }

  // ============================================================================
  // USER SEARCH METHODS
  // ============================================================================

  /// Search users by email (prefix match)
  /// Note: For production, consider using Algolia or similar for full-text search
  Future<List<UserProfile>> searchUsersByEmail(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final userId = _auth.currentUser?.uid;
      final lowerQuery = query.toLowerCase().trim();

      // Get all users (limited for performance)
      // We do local filtering because Firestore doesn't support contains queries
      final snapshot = await _firestore
          .collection('users')
          .limit(100)
          .get();

      final results = snapshot.docs
          .map((doc) => UserProfile.fromMap({...doc.data(), 'id': doc.id}))
          .where((profile) => 
              profile.id != userId && // Exclude current user
              profile.email.toLowerCase().contains(lowerQuery)) // Match anywhere in email
          .take(20) // Limit results
          .toList();

      return results;
    } catch (e) {
      print('Error searching users by email: $e');
      return [];
    }
  }

  /// Search users by name (contains - local filtering)
  /// For better performance, use a search service like Algolia
  Future<List<UserProfile>> searchUsersByName(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final userId = _auth.currentUser?.uid;
      final lowerQuery = query.toLowerCase().trim();

      // Get all users (limited for performance)
      // In production, use a proper search service
      final snapshot = await _firestore
          .collection('users')
          .limit(100)
          .get();

      final results = snapshot.docs
          .map((doc) => UserProfile.fromMap({...doc.data(), 'id': doc.id}))
          .where((profile) => 
              profile.id != userId &&
              profile.name.toLowerCase().contains(lowerQuery))
          .toList();

      return results;
    } catch (e) {
      print('Error searching users by name: $e');
      return [];
    }
  }

  /// Get suggested friends (users not yet connected)
  /// Simple implementation - could be enhanced with mutual friends, location, etc.
  Future<List<UserProfile>> getSuggestedFriends({int limit = 10}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Get random users (simplified suggestion algorithm)
      final snapshot = await _firestore
          .collection('users')
          .limit(limit * 2) // Get extra to filter
          .get();

      final suggestions = snapshot.docs
          .map((doc) => UserProfile.fromMap({...doc.data(), 'id': doc.id}))
          .where((profile) => profile.id != userId)
          .take(limit)
          .toList();

      return suggestions;
    } catch (e) {
      print('Error getting suggested friends: $e');
      return [];
    }
  }

  // ============================================================================
  // FRIEND REQUEST METHODS
  // ============================================================================

  /// Send a friend request
  Future<FriendRequest?> sendFriendRequest(String toUserId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // Check if request already exists
      final existing = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: userId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existing.docs.isNotEmpty) {
        // Request already exists
        return FriendRequest.fromMap({
          ...existing.docs.first.data(),
          'id': existing.docs.first.id
        });
      }

      final request = FriendRequest(
        id: '',
        fromUserId: userId,
        toUserId: toUserId,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('friendRequests')
          .add(request.toMap());

      return request.copyWith(id: docRef.id);
    } catch (e) {
      print('Error sending friend request: $e');
      return null;
    }
  }

  /// Get pending friend requests for current user
  Future<List<FriendRequest>> getPendingFriendRequests() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('friendRequests')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          // .orderBy('createdAt', descending: true) // Commented out - requires index
          .get();

      final requests = snapshot.docs
          .map((doc) => FriendRequest.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort locally instead
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests;
    } catch (e) {
      print('Error getting pending friend requests: $e');
      return [];
    }
  }

  /// Get sent friend requests (requests current user sent)
  Future<List<FriendRequest>> getSentFriendRequests() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          // .orderBy('createdAt', descending: true) // Commented out - requires index
          .get();

      final requests = snapshot.docs
          .map((doc) => FriendRequest.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort locally instead
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests;
    } catch (e) {
      print('Error getting sent friend requests: $e');
      return [];
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final docRef = _firestore.collection('friendRequests').doc(requestId);
      
      await docRef.update({
        'status': 'accepted',
      });

      return true;
    } catch (e) {
      print('Error accepting friend request: $e');
      return false;
    }
  }

  /// Reject a friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      final docRef = _firestore.collection('friendRequests').doc(requestId);
      
      await docRef.update({
        'status': 'rejected',
      });

      return true;
    } catch (e) {
      print('Error rejecting friend request: $e');
      return false;
    }
  }

  /// Cancel a sent friend request
  Future<bool> cancelFriendRequest(String requestId) async {
    try {
      await _firestore
          .collection('friendRequests')
          .doc(requestId)
          .delete();

      return true;
    } catch (e) {
      print('Error canceling friend request: $e');
      return false;
    }
  }

  /// Get user's friends (users with accepted friend requests)
  /// Note: This is a simplified implementation
  /// In production, maintain a separate 'friends' subcollection for each user
  Future<List<UserProfile>> getFriends() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Get requests where current user is sender and status is accepted
      final sentRequests = await _firestore
          .collection('friendRequests')
          .where('fromUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Get requests where current user is recipient and status is accepted
      final receivedRequests = await _firestore
          .collection('friendRequests')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'accepted')
          .get();

      // Collect friend IDs
      final friendIds = <String>{};
      
      for (var doc in sentRequests.docs) {
        friendIds.add(doc.data()['toUserId']);
      }
      
      for (var doc in receivedRequests.docs) {
        friendIds.add(doc.data()['fromUserId']);
      }

      if (friendIds.isEmpty) return [];

      // Get friend profiles
      return await getUserProfiles(friendIds.toList());
    } catch (e) {
      print('Error getting friends: $e');
      return [];
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Initialize user profile after authentication
  /// Call this after successful login/registration
  Future<void> initializeUserAfterAuth() async {
    await createOrUpdateUserProfile();
    await setOnline();
  }

  /// Cleanup when user logs out
  Future<void> cleanupOnLogout() async {
    await setOffline();
  }
}

/// Extension for FriendRequest to add copyWith method
extension FriendRequestExtension on FriendRequest {
  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    FriendRequestStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
