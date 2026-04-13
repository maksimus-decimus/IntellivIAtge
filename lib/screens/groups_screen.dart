import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart' as types;
import '../services/chat_service.dart';
import '../services/user_service.dart';

enum GroupTab { chats, groups, friends }

enum GroupView { list, chat, createGroup, addFriend }

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  GroupTab _activeTab = GroupTab.chats;
  GroupView _activeView = GroupView.list;
  String? _selectedConversationId;
  String _searchQuery = '';
  bool _showAttachments = false;
  bool _isLoadingConversations = true;

  // Services
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  // Data from Firebase
  List<types.Conversation> _conversations = [];
  List<types.Message> _messages = [];
  List<types.UserProfile> _searchResults = [];
  List<types.UserProfile> _friends = [];
  List<types.FriendRequest> _pendingRequests = [];
  Set<String> _selectedFriendIds = {};

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _groupNameController.dispose();
    _chatService.stopConversationsPolling();
    if (_selectedConversationId != null) {
      _chatService.stopMessagesPolling(_selectedConversationId!);
    }
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // Initialize user profile if needed
    await _userService.initializeUserAfterAuth();
    
    // Start polling for conversations
    await _chatService.startConversationsPolling();
    
    // Listen to conversation updates
    _chatService.conversationsStream.listen((conversations) {
      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoadingConversations = false;
        });
        print('📨 Conversations updated: ${conversations.length} conversations loaded');
        for (var conv in conversations) {
          print('  - ${conv.id}: ${conv.type} (${conv.participantIds.length} participants)');
        }
      }
    });
    
    // Load friends
    final friends = await _userService.getFriends();
    if (mounted) {
      setState(() {
        _friends = friends;
      });
    }

    // Load pending friend requests
    final pendingRequests = await _userService.getPendingFriendRequests();
    if (mounted) {
      setState(() {
        _pendingRequests = pendingRequests;
      });
    }
  }

  Future<void> _loadMessages(String conversationId) async {
    await _chatService.startMessagesPolling(conversationId);
    
    _chatService.messagesStream(conversationId).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }
    });
    
    // Mark as read when opening chat
    await _chatService.markAsRead(conversationId);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedConversationId == null) return;

    _messageController.clear();
    setState(() => _showAttachments = false);

    await _chatService.sendMessage(
      conversationId: _selectedConversationId!,
      text: text,
    );
  }

  types.Conversation? get _activeConversation {
    if (_selectedConversationId == null) return null;
    try {
      return _conversations.firstWhere(
        (c) => c.id == _selectedConversationId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _searchFriends(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    final results = await _userService.searchUsersByEmail(query);
    setState(() => _searchResults = results);
  }

  Future<void> _sendFriendRequest(String userId) async {
    await _userService.sendFriendRequest(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud de amistad enviada')),
    );
  }

  Future<void> _acceptFriendRequest(types.FriendRequest request) async {
    final success = await _userService.acceptFriendRequest(request.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud aceptada'), backgroundColor: Colors.green),
      );
      // Reload friends and pending requests
      final friends = await _userService.getFriends();
      final pendingRequests = await _userService.getPendingFriendRequests();
      if (mounted) {
        setState(() {
          _friends = friends;
          _pendingRequests = pendingRequests;
        });
      }
    }
  }

  Future<void> _rejectFriendRequest(types.FriendRequest request) async {
    final success = await _userService.rejectFriendRequest(request.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud rechazada')),
      );
      // Reload pending requests
      final pendingRequests = await _userService.getPendingFriendRequests();
      if (mounted) {
        setState(() {
          _pendingRequests = pendingRequests;
        });
      }
    }
  }

  // --- ADD FRIEND VIEW ---
  Widget _buildAddFriendView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => setState(() => _activeView = GroupView.list),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Añadir Amigo',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchFriends,
                    decoration: InputDecoration(
                      hintText: 'Buscar por email...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Search results or Suggestions
                if (_searchResults.isNotEmpty) ...[
                  Text(
                    'RESULTADOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._searchResults.map((user) => _buildSearchResultCard(user)).toList(),
                ] else ...[
                  Text(
                    'SUGERENCIAS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[400],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Busca usuarios por email',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CREATE GROUP VIEW ---
  Widget _buildCreateGroupView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => setState(() => _activeView = GroupView.list),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nuevo Grupo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_groupNameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un nombre para el grupo'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      if (_selectedFriendIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selecciona al menos un amigo'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final conversation = await _chatService.createGroupConversation(
                        name: _groupNameController.text.trim(),
                        participantIds: _selectedFriendIds.toList(),
                      );

                      if (conversation != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Grupo creado!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        setState(() {
                          _activeView = GroupView.list;
                          _activeTab = GroupTab.groups;
                          _groupNameController.clear();
                          _selectedFriendIds.clear();
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                    child: const Text(
                      'Crear',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Group Image and Name
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: Colors.indigo[100],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt, size: 32, color: Colors.indigo[400]),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!, width: 2),
                      ),
                      child: TextField(
                        controller: _groupNameController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Nombre del grupo',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Add Friends
                const Text(
                  'Añadir Amigos',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Search Friends
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar en mis amigos...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  ),
                ),

                // Friends List
                ..._friends.map((friend) {
                  final isSelected = _selectedFriendIds.contains(friend.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.indigo[100],
                          child: Text(
                            friend.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                friend.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                friend.email,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedFriendIds.add(friend.id);
                              } else {
                                _selectedFriendIds.remove(friend.id);
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          activeColor: Colors.indigo,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CHAT VIEW ---
  Widget _buildChatView() {
    if (_selectedConversationId == null) return const SizedBox.shrink();

    final conversation = _activeConversation;
    if (conversation == null) return const SizedBox.shrink();

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    // Get conversation name and other user ID
    String conversationName = 'Chat';
    String? otherUserId;
    
    if (conversation.type == 'group') {
      conversationName = conversation.groupMetadata?.name ?? 'Grupo';
    } else {
      // For 1-1 chats, get the other user's ID
      otherUserId = conversation.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        _chatService.stopMessagesPolling(_selectedConversationId!);
                        setState(() {
                          _selectedConversationId = null;
                          _activeView = GroupView.list;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar - show user initial for 1-1, group initial for groups
                  if (otherUserId != null && otherUserId.isNotEmpty)
                    FutureBuilder<types.UserProfile?>(
                      future: _userService.getUserProfile(otherUserId),
                      builder: (context, snapshot) {
                        final userName = snapshot.data?.name ?? 'U';
                        return CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.indigo,
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    )
                  else
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.indigo,
                      child: Text(
                        conversationName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show user name for 1-1 chats, group name for groups
                        if (otherUserId != null && otherUserId.isNotEmpty)
                          FutureBuilder<types.UserProfile?>(
                            future: _userService.getUserProfile(otherUserId),
                            builder: (context, snapshot) {
                              final userName = snapshot.data?.name ?? 'Usuario';
                              return Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            conversationName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        Text(
                          conversation.type == 'group' 
                            ? '${conversation.participantIds.length} miembros'
                            : 'Activo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: _messages.isEmpty
              ? Center(
                  child: Text(
                    'No hay mensajes aún',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    final isMe = message.senderId == currentUserId;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.indigo : Colors.white,
                            border: isMe ? null : Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isMe ? 16 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isMe ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(message.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isMe ? Colors.indigo[200] : Colors.grey[400],
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    _buildMessageStatus(message.status),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),

          // Typing indicator
          StreamBuilder<bool>(
            stream: _chatService.getTypingStatus(_selectedConversationId!),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '... está escribiendo',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input Area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              top: false,
              child: Stack(
                children: [
                  if (_showAttachments)
                    Positioned(
                      bottom: 60,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildAttachmentButton(Icons.camera_alt, 'Cámara'),
                            const SizedBox(width: 8),
                            _buildAttachmentButton(Icons.image, 'Galería'),
                            const SizedBox(width: 8),
                            _buildAttachmentButton(Icons.location_on, 'Ubicación'),
                          ],
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: _showAttachments ? Colors.indigo : Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() => _showAttachments = !_showAttachments);
                        },
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: TextField(
                            controller: _messageController,
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                _chatService.updateTypingStatus(_selectedConversationId!, true);
                                // Stop typing after 2 seconds of inactivity
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (_messageController.text == text) {
                                    _chatService.updateTypingStatus(_selectedConversationId!, false);
                                  }
                                });
                              }
                            },
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Escribe un mensaje...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[400],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.send, size: 18, color: Colors.white),
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
  }

  Widget _buildAttachmentButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label seleccionado')),
        );
        setState(() => _showAttachments = false);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Colors.indigo),
      ),
    );
  }

  // --- MAIN LIST VIEW ---
  @override
  Widget build(BuildContext context) {
    if (_activeView == GroupView.chat) {
      return _buildChatView();
    }

    if (_activeView == GroupView.createGroup) {
      return _buildCreateGroupView();
    }

    if (_activeView == GroupView.addFriend) {
      return _buildAddFriendView();
    }

    // Filter conversations based on tab and search
    final filteredConversations = _conversations.where((conversation) {
      final conversationName = conversation.type == 'group'
          ? (conversation.groupMetadata?.name ?? 'Grupo')
          : 'Usuario'; // TODO: Fetch from UserService
      final matchesSearch = conversationName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_activeTab == GroupTab.groups) return conversation.type == 'group' && matchesSearch;
      if (_activeTab == GroupTab.chats) return matchesSearch;
      return false;
    }).toList();

    final filteredFriends = _friends.where((friend) {
      return friend.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          friend.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // Search and Action Button
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 2),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar chats, grupos o amigos...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_activeTab == GroupTab.friends) {
                        _activeView = GroupView.addFriend;
                      } else {
                        _activeView = GroupView.createGroup;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _activeTab == GroupTab.friends ? Colors.green : Colors.indigo,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_activeTab == GroupTab.friends ? Colors.green : Colors.indigo).withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _activeTab == GroupTab.friends ? Icons.person_add : Icons.add,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildTab('Chats', GroupTab.chats),
                  _buildTab('Grupos', GroupTab.groups),
                  _buildTab('Amigos', GroupTab.friends),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pending Friend Requests (only in Friends tab)
            if (_activeTab == GroupTab.friends && _pendingRequests.isNotEmpty) ...[
              Text(
                'SOLICITUDES PENDIENTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange[400],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ..._pendingRequests.map((request) => _buildFriendRequestCard(request)).toList(),
              const SizedBox(height: 24),
              Text(
                'MIS AMIGOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[400],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Content
            if (_activeTab == GroupTab.friends)
              ...filteredFriends.map((friend) => _buildFriendCard(friend)).toList()
            else
              ...filteredConversations.map((conversation) => _buildChatCard(conversation)).toList(),

            // Empty state
            if (_activeTab == GroupTab.friends && filteredFriends.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people, size: 40, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no tienes amigos añadidos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _activeView = GroupView.addFriend),
                      child: const Text(
                        'AÑADIR MI PRIMER AMIGO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Loading indicator for Chats
            if (_activeTab == GroupTab.chats && _isLoadingConversations && filteredConversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    _buildLoadingDots(),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando conversaciones...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Empty state for Chats
            if (_activeTab == GroupTab.chats && !_isLoadingConversations && filteredConversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.chat_bubble_outline, size: 40, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay conversaciones aún',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Añade amigos y empieza a chatear',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

            // Loading indicator for Groups
            if (_activeTab == GroupTab.groups && _isLoadingConversations && filteredConversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    _buildLoadingDots(),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando grupos...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

            // Empty state for Groups
            if (_activeTab == GroupTab.groups && !_isLoadingConversations && filteredConversations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.group_outlined, size: 40, color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes grupos aún',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() => _activeView = GroupView.createGroup),
                      child: const Text(
                        'CREAR MI PRIMER GRUPO',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.indigo,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, GroupTab tab) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
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
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.indigo : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendCard(types.UserProfile friend) {
    return GestureDetector(
      onTap: () async {
        // Create or get existing conversation
        final conversation = await _chatService.createDirectConversation(friend.id);
        if (conversation != null) {
          setState(() {
            _selectedConversationId = conversation.id;
            _activeView = GroupView.chat;
            _activeTab = GroupTab.chats;
          });
          _loadMessages(conversation.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!, width: 2),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.indigo[100],
                  child: Text(
                    friend.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: friend.status == 'online' ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    friend.email,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.chat, size: 18, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(types.Conversation conversation) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final unreadCount = conversation.unreadCounts[currentUserId] ?? 0;
    
    String conversationName = 'Chat';
    String? otherUserId;
    
    if (conversation.type == 'group') {
      conversationName = conversation.groupMetadata?.name ?? 'Grupo';
    } else {
      // For 1-1 chats, get the other user's ID
      otherUserId = conversation.participantIds.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedConversationId = conversation.id;
          _activeView = GroupView.chat;
        });
        _loadMessages(conversation.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[100]!, width: 2),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                // Avatar - show user initial for 1-1, group initial for groups
                if (otherUserId != null && otherUserId.isNotEmpty)
                  FutureBuilder<types.UserProfile?>(
                    future: _userService.getUserProfile(otherUserId),
                    builder: (context, snapshot) {
                      final userName = snapshot.data?.name ?? 'U';
                      return CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.indigo,
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      );
                    },
                  )
                else
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.indigo,
                    child: Text(
                      conversationName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                if (conversation.type == 'group')
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.people, size: 12, color: Colors.indigo),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: otherUserId != null && otherUserId.isNotEmpty
                          ? FutureBuilder<types.UserProfile?>(
                              future: _userService.getUserProfile(otherUserId),
                              builder: (context, snapshot) {
                                final userName = snapshot.data?.name ?? 'Usuario';
                                return Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            )
                          : Text(
                              conversationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.lastMessageTime != null
                            ? _formatTime(conversation.lastMessageTime!)
                            : '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage ?? 'Sin mensajes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                      color: unreadCount > 0 ? const Color(0xFF334155) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.indigo,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFriendRequestCard(types.FriendRequest request) {
    return FutureBuilder<types.UserProfile?>(
      future: _userService.getUserProfile(request.fromUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.orange[100]!, width: 2),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange[100]!, width: 2),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange[100],
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _acceptFriendRequest(request),
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    tooltip: 'Aceptar',
                  ),
                  IconButton(
                    onPressed: () => _rejectFriendRequest(request),
                    icon: Icon(Icons.cancel, color: Colors.grey[400]),
                    tooltip: 'Rechazar',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResultCard(types.UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo[100],
            child: Text(
              user.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _sendFriendRequest(user.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Añadir',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return days[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  Widget _buildMessageStatus(types.MessageStatus status) {
    switch (status) {
      case types.MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: Colors.indigo[200]);
      case types.MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 14, color: Colors.indigo[200]),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Icon(Icons.check, size: 14, color: Colors.indigo[200]),
            ),
          ],
        );
      case types.MessageStatus.read:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 14, color: Colors.lightBlueAccent),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: const Icon(Icons.check, size: 14, color: Colors.lightBlueAccent),
            ),
          ],
        );
    }
  }

  Widget _buildLoadingDots() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final animValue = (value - delay).clamp(0.0, 1.0);
            final opacity = (animValue < 0.5)
                ? animValue * 2
                : (1.0 - animValue) * 2;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) setState(() {});
      },
    );
  }
}
