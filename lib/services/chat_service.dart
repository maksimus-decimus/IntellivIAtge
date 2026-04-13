import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart';

/// Service for handling all chat-related operations
/// 
/// This singleton service manages:
/// - Sending and receiving messages
/// - Creating and managing conversations (direct and group)
/// - Marking messages as read
/// - Typing indicators
/// - Polling for new messages
class ChatService {
  // Singleton pattern
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for real-time updates
  final _conversationsController = StreamController<List<Conversation>>.broadcast();
  final _messagesControllers = <String, StreamController<List<Message>>>{};
  
  // Polling timers
  Timer? _conversationsTimer;
  final Map<String, Timer> _messageTimers = {};

  // Cache
  List<Conversation>? _conversationsCache;
  final Map<String, List<Message>> _messagesCache = {};

  // Getters for streams
  Stream<List<Conversation>> get conversationsStream => _conversationsController.stream;
  
  Stream<List<Message>> messagesStream(String conversationId) {
    if (!_messagesControllers.containsKey(conversationId)) {
      _messagesControllers[conversationId] = StreamController<List<Message>>.broadcast();
    }
    return _messagesControllers[conversationId]!.stream;
  }

  // ============================================================================
  // CONVERSATION METHODS
  // ============================================================================

  /// Get all conversations for current user with polling
  Future<void> startConversationsPolling({Duration interval = const Duration(seconds: 10)}) async {
    // Initial load
    await _fetchConversations();
    
    // Start polling
    _conversationsTimer?.cancel();
    _conversationsTimer = Timer.periodic(interval, (_) async {
      await _fetchConversations();
    });
  }

  /// Stop polling for conversations
  void stopConversationsPolling() {
    _conversationsTimer?.cancel();
    _conversationsTimer = null;
  }

  /// Fetch conversations from Firestore
  Future<void> _fetchConversations() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: userId)
          // .orderBy('lastMessageTime', descending: true) // Commented out - requires composite index
          .get();

      final conversations = snapshot.docs
          .map((doc) => Conversation.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort locally instead of using orderBy
      conversations.sort((a, b) {
        final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      _conversationsCache = conversations;
      _conversationsController.add(conversations);
    } catch (e) {
      print('Error fetching conversations: $e');
    }
  }

  /// Get conversations synchronously from cache
  List<Conversation> getConversations() {
    return _conversationsCache ?? [];
  }

  /// Create a direct (1-1) conversation
  Future<Conversation?> createDirectConversation(String otherUserId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // Check if conversation already exists
      final existing = await _firestore
          .collection('conversations')
          .where('type', isEqualTo: 'direct')
          .where('participantIds', arrayContains: userId)
          .get();

      for (var doc in existing.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participantIds'] ?? []);
        if (participants.contains(otherUserId) && participants.length == 2) {
          // Conversation already exists
          return Conversation.fromMap({...data, 'id': doc.id});
        }
      }

      // Create new conversation
      final conversation = Conversation(
        id: '', // Will be set by Firestore
        type: 'direct',
        participantIds: [userId, otherUserId],
        unreadCounts: {userId: 0, otherUserId: 0},
      );

      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toMap());

      final created = conversation.copyWith(id: docRef.id);
      
      // Refresh conversations
      await _fetchConversations();
      
      return created;
    } catch (e) {
      print('Error creating direct conversation: $e');
      return null;
    }
  }

  /// Create a group conversation
  Future<Conversation?> createGroupConversation({
    required String name,
    required List<String> participantIds,
    String? imageUrl,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // Ensure current user is in participants
      if (!participantIds.contains(userId)) {
        participantIds.add(userId);
      }

      final groupMetadata = GroupMetadata(
        name: name,
        imageUrl: imageUrl,
        adminIds: [userId], // Creator is admin
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      final unreadCounts = <String, int>{};
      for (var id in participantIds) {
        unreadCounts[id] = 0;
      }

      final conversation = Conversation(
        id: '',
        type: 'group',
        participantIds: participantIds,
        groupMetadata: groupMetadata,
        unreadCounts: unreadCounts,
      );

      final docRef = await _firestore
          .collection('conversations')
          .add(conversation.toMap());

      final created = conversation.copyWith(id: docRef.id);
      
      // Refresh conversations
      await _fetchConversations();
      
      return created;
    } catch (e) {
      print('Error creating group conversation: $e');
      return null;
    }
  }

  /// Add members to a group (admin only)
  Future<bool> addGroupMembers(String conversationId, List<String> newMemberIds) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docRef = _firestore.collection('conversations').doc(conversationId);
      final doc = await docRef.get();
      
      if (!doc.exists) return false;

      final conversation = Conversation.fromMap({...doc.data()!, 'id': doc.id});
      
      // Check if user is admin
      if (conversation.groupMetadata == null || 
          !conversation.groupMetadata!.adminIds.contains(userId)) {
        print('User is not admin');
        return false;
      }

      // Add new members
      final updatedParticipants = [...conversation.participantIds];
      final updatedUnreadCounts = Map<String, int>.from(conversation.unreadCounts);
      
      for (var memberId in newMemberIds) {
        if (!updatedParticipants.contains(memberId)) {
          updatedParticipants.add(memberId);
          updatedUnreadCounts[memberId] = 0;
        }
      }

      await docRef.update({
        'participantIds': updatedParticipants,
        'unreadCounts': updatedUnreadCounts,
      });

      // Refresh conversations
      await _fetchConversations();
      
      return true;
    } catch (e) {
      print('Error adding group members: $e');
      return false;
    }
  }

  /// Remove member from group (admin only)
  Future<bool> removeGroupMember(String conversationId, String memberId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final docRef = _firestore.collection('conversations').doc(conversationId);
      final doc = await docRef.get();
      
      if (!doc.exists) return false;

      final conversation = Conversation.fromMap({...doc.data()!, 'id': doc.id});
      
      // Check if user is admin
      if (conversation.groupMetadata == null || 
          !conversation.groupMetadata!.adminIds.contains(userId)) {
        print('User is not admin');
        return false;
      }

      // Remove member
      final updatedParticipants = conversation.participantIds
          .where((id) => id != memberId)
          .toList();
      final updatedUnreadCounts = Map<String, int>.from(conversation.unreadCounts);
      updatedUnreadCounts.remove(memberId);

      await docRef.update({
        'participantIds': updatedParticipants,
        'unreadCounts': updatedUnreadCounts,
      });

      // Refresh conversations
      await _fetchConversations();
      
      return true;
    } catch (e) {
      print('Error removing group member: $e');
      return false;
    }
  }

  /// Leave a group conversation
  Future<bool> leaveGroup(String conversationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      return await removeGroupMember(conversationId, userId);
    } catch (e) {
      print('Error leaving group: $e');
      return false;
    }
  }

  // ============================================================================
  // MESSAGE METHODS
  // ============================================================================

  /// Start polling for messages in a conversation
  Future<void> startMessagesPolling(
    String conversationId, {
    Duration interval = const Duration(seconds: 5),
  }) async {
    // Initial load
    await _fetchMessages(conversationId);
    
    // Start polling
    _messageTimers[conversationId]?.cancel();
    _messageTimers[conversationId] = Timer.periodic(interval, (_) async {
      await _fetchMessages(conversationId);
    });
  }

  /// Stop polling for messages in a conversation
  void stopMessagesPolling(String conversationId) {
    _messageTimers[conversationId]?.cancel();
    _messageTimers.remove(conversationId);
  }

  /// Fetch messages from Firestore
  Future<void> _fetchMessages(String conversationId, {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          // .orderBy('timestamp', descending: true) // Commented out - requires composite index
          .limit(limit)
          .get();

      final messages = snapshot.docs
          .map((doc) => Message.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort locally instead
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Reverse to show oldest first
      final sortedMessages = messages.reversed.toList();

      _messagesCache[conversationId] = sortedMessages;
      
      if (_messagesControllers.containsKey(conversationId)) {
        _messagesControllers[conversationId]!.add(sortedMessages);
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  /// Get messages synchronously from cache
  List<Message> getMessages(String conversationId) {
    return _messagesCache[conversationId] ?? [];
  }

  /// Send a text message
  Future<Message?> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    return await _sendMessageInternal(
      conversationId: conversationId,
      text: text,
    );
  }

  /// Send an image message
  Future<Message?> sendImageMessage({
    required String conversationId,
    required String imageUrl,
  }) async {
    return await _sendMessageInternal(
      conversationId: conversationId,
      imageUrl: imageUrl,
    );
  }

  /// Send a location message
  Future<Message?> sendLocationMessage({
    required String conversationId,
    required LocationData locationData,
  }) async {
    return await _sendMessageInternal(
      conversationId: conversationId,
      locationData: locationData,
    );
  }

  /// Internal method to send a message
  Future<Message?> _sendMessageInternal({
    required String conversationId,
    String? text,
    String? imageUrl,
    LocationData? locationData,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final now = DateTime.now();
      
      final message = Message(
        id: '',
        conversationId: conversationId,
        senderId: userId,
        text: text,
        imageUrl: imageUrl,
        locationData: locationData,
        timestamp: now,
        status: MessageStatus.sent,
      );

      // Add message to Firestore
      final docRef = await _firestore
          .collection('messages')
          .add(message.toMap());

      final sent = message.copyWith(id: docRef.id);

      // Update conversation's lastMessage and lastMessageTime
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final conversationDoc = await conversationRef.get();
      
      if (conversationDoc.exists) {
        final conversation = Conversation.fromMap({
          ...conversationDoc.data()!,
          'id': conversationDoc.id
        });
        
        // Increment unread counts for all participants except sender
        final updatedUnreadCounts = Map<String, int>.from(conversation.unreadCounts);
        for (var participantId in conversation.participantIds) {
          if (participantId != userId) {
            updatedUnreadCounts[participantId] = (updatedUnreadCounts[participantId] ?? 0) + 1;
          }
        }

        String lastMessageText = text ?? '';
        if (imageUrl != null) lastMessageText = '📷 Imagen';
        if (locationData != null) lastMessageText = '📍 Ubicación';

        await conversationRef.update({
          'lastMessage': lastMessageText,
          'lastMessageTime': now.millisecondsSinceEpoch,
          'unreadCounts': updatedUnreadCounts,
        });
      }

      // Refresh messages and conversations
      await _fetchMessages(conversationId);
      await _fetchConversations();
      
      return sent;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Mark messages as read in a conversation
  Future<void> markAsRead(String conversationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Reset unread count for current user
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final doc = await conversationRef.get();
      
      if (!doc.exists) return;

      final conversation = Conversation.fromMap({...doc.data()!, 'id': doc.id});
      final updatedUnreadCounts = Map<String, int>.from(conversation.unreadCounts);
      updatedUnreadCounts[userId] = 0;

      await conversationRef.update({
        'unreadCounts': updatedUnreadCounts,
      });

      // Update message statuses to read for messages sent by others
      final messages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('senderId', isNotEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'status': 'read'});
      }
      await batch.commit();

      // Refresh
      await _fetchConversations();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // ============================================================================
  // TYPING INDICATOR
  // ============================================================================

  /// Update typing status
  Future<void> updateTypingStatus(String conversationId, bool isTyping) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final typingRef = _firestore
          .collection('typing')
          .doc(conversationId)
          .collection('users')
          .doc(userId);

      if (isTyping) {
        await typingRef.set({
          'isTyping': true,
          'lastUpdate': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        await typingRef.delete();
      }
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  /// Check if other users are typing
  Stream<bool> getTypingStatus(String conversationId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('typing')
        .doc(conversationId)
        .collection('users')
        .snapshots()
        .map((snapshot) {
      // Check if anyone except current user is typing
      for (var doc in snapshot.docs) {
        if (doc.id != userId && doc.data()['isTyping'] == true) {
          return true;
        }
      }
      return false;
    });
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Dispose all resources
  void dispose() {
    _conversationsTimer?.cancel();
    for (var timer in _messageTimers.values) {
      timer.cancel();
    }
    _conversationsController.close();
    for (var controller in _messagesControllers.values) {
      controller.close();
    }
  }
}
