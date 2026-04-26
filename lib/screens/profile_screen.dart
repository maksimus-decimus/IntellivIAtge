import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  String _displayName = 'Viajero Explorador';
  String? _photoUrl;
  bool _hasImageError = false;
  final TextEditingController _nameController = TextEditingController();

  // Avatares predefinidos (imágenes locales)
  static const List<String> _avatarOptions = [
    'images/avatars/avatar1.jpg',
    'images/avatars/avatar2.jpg',
    'images/avatars/avatar3.jpg',
    'images/avatars/avatar4.jpg',
    'images/avatars/avatar5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserName();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recargar cuando la app vuelve a estar activa
    if (state == AppLifecycleState.resumed) {
      _loadUserName();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar datos cada vez que la pantalla se hace visible
    _loadUserName();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    super.dispose();
  }

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Cargar desde Firestore (tiene prioridad sobre Firebase Auth)
      final profile = await UserService().getUserProfile(user.uid);
      
      if (mounted) {
        setState(() {
          if (profile != null) {
            _displayName = profile.name;
            _photoUrl = profile.photoUrl;
            print('📸 Avatar cargado desde Firestore: $_photoUrl');
          } else if (user.displayName != null && user.displayName!.isNotEmpty) {
            _displayName = user.displayName!;
            _photoUrl = user.photoURL;
            print('📸 Avatar cargado desde Firebase Auth: $_photoUrl');
          }
          _hasImageError = false;
        });
      }
    }
  }

  // Helper para cargar imágenes (locales o remotas)
  Widget _buildAvatarImage(
    String imageUrl, {
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loadingBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    final isLocalAsset = !imageUrl.startsWith('http://') && !imageUrl.startsWith('https://');
    
    if (isLocalAsset) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: errorBuilder,
      );
    } else {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
      );
    }
  }

  // Auto-asignar avatar cuando falla la foto de Google
  Future<void> _autoAssignAvatar() async {
    try {
      // Usar el primer avatar como predeterminado
      final fallbackAvatar = _avatarOptions[0];
      
      // Actualizar en Firestore silenciosamente
      await UserService().createOrUpdateUserProfile(photoUrl: fallbackAvatar);

      // Actualizar UI
      if (mounted) {
        setState(() {
          _photoUrl = fallbackAvatar;
          _hasImageError = false;
        });
      }
    } catch (e) {
      print('Error auto-asignando avatar: $e');
    }
  }

  // Mostrar selector de avatares
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Elige tu Avatar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _avatarOptions.length,
                itemBuilder: (context, index) {
                  final avatarUrl = _avatarOptions[index];
                  final isSelected = _photoUrl == avatarUrl;
                  
                  return GestureDetector(
                    onTap: () => _selectAvatar(avatarUrl),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF34D399) 
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(
                          avatarUrl,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.person),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Seleccionar avatar
  Future<void> _selectAvatar(String avatarUrl) async {
    try {
      print('💾 Guardando avatar: $avatarUrl');
      // Actualizar en Firestore
      await UserService().createOrUpdateUserProfile(photoUrl: avatarUrl);

      if (!mounted) return;

      // Actualizar UI
      setState(() {
        _photoUrl = avatarUrl;
        _hasImageError = false; // Resetear flag de error
      });

      Navigator.pop(context); // Cerrar modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Avatar actualizado con éxito! ✨'),
          backgroundColor: Color(0xFF34D399),
        ),
      );
    } catch (e) {
      print('❌ Error guardando avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar avatar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _updateDisplayName() async {
    if (_nameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El nombre no puede estar vacío'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
        
        if (!mounted) return;

        setState(() {
          _displayName = _nameController.text.trim();
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Nombre actualizado con éxito! ✨'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el nombre: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showEditNameDialog() {
    _nameController.text = _displayName;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Editar Nombre',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
        ),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Tu nombre',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _updateDisplayName,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Guardar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: _photoUrl != null && !_hasImageError
                          ? ClipOval(
                              child: _buildAvatarImage(
                                _photoUrl!,
                                width: 100,
                                height: 100,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Color(0xFFF1F5F9),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  // Error de carga (429 de Google, etc.)
                                  print('Error cargando imagen: $error');
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted && !_hasImageError) {
                                      setState(() => _hasImageError = true);
                                      // Auto-asignar un avatar predefinido
                                      _autoAssignAvatar();
                                    }
                                  });
                                  // Mostrar avatar predeterminado mientras tanto
                                  return CircleAvatar(
                                    radius: 50,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    child: ClipOval(
                                      child: _buildAvatarImage(
                                        _avatarOptions[0],
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF1F5F9),
                              child: _photoUrl != null && _hasImageError
                                  ? ClipOval(
                                      child: _buildAvatarImage(
                                        _photoUrl!,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFF64748B),
                                    ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showEditNameDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🔥 Racha de 3 días',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Stats
          Row(
            children: [
              Expanded(
                child: const _StatCard(
                  icon: '🏛️',
                  value: '12',
                  label: 'Lugares\nVisitados',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const _StatCard(
                  icon: '🗺️',
                  value: '5',
                  label: 'Rutas\nCompletadas',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const _StatCard(
                  icon: '🏆',
                  value: '8',
                  label: 'Medallas\nGanadas',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Achievements
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medallas Desbloqueadas 🏅',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    const _AchievementBadge(emoji: '🏛️', label: 'Arquitecto'),
                    const _AchievementBadge(emoji: '🍽️', label: 'Foodie'),
                    const _AchievementBadge(emoji: '🗺️', label: 'Explorador'),
                    const _AchievementBadge(emoji: '🌟', label: 'VIP', isLocked: true),
                    const _AchievementBadge(emoji: '🎨', label: 'Artista', isLocked: true),
                    const _AchievementBadge(emoji: '🏖️', label: 'Beachgoer', isLocked: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Settings
          _SettingsOption(
            icon: Icons.notifications,
            title: 'Notificaciones',
            onTap: () {},
          ),
          _SettingsOption(
            icon: Icons.language,
            title: 'Idioma',
            onTap: () {},
          ),
          _SettingsOption(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            onTap: () {},
          ),
          _SettingsOption(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: widget.onLogout,
            isDestructive: true,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isLocked;

  const _AchievementBadge({
    Key? key,
    required this.emoji,
    required this.label,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.3 : 1.0,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(
                color: isLocked ? const Color(0xFFE2E8F0) : const Color(0xFFF59E0B),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                isLocked ? '🔒' : emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF64748B),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
