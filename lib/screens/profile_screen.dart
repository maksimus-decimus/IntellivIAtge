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
  
  // Preferencias de notificaciones
  bool _notifTrips = true;
  bool _notifInvitations = true;
  bool _notifReminders = true;
  
  // Idioma seleccionado
  String _selectedLanguage = 'Español';

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

  // Mostrar configuración de notificaciones
  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configura qué notificaciones deseas recibir',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text(
                  'Nuevos viajes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Cuando se crea o actualiza un viaje'),
                value: _notifTrips,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) {
                  setModalState(() => _notifTrips = val);
                  setState(() => _notifTrips = val);
                },
              ),
              SwitchListTile(
                title: const Text(
                  'Invitaciones',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Cuando te invitan a un viaje o grupo'),
                value: _notifInvitations,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) {
                  setModalState(() => _notifInvitations = val);
                  setState(() => _notifInvitations = val);
                },
              ),
              SwitchListTile(
                title: const Text(
                  'Recordatorios',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Recordatorios de viajes próximos'),
                value: _notifReminders,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) {
                  setModalState(() => _notifReminders = val);
                  setState(() => _notifReminders = val);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Mostrar selector de idioma
  void _showLanguageSelector() {
    final languages = ['Español', 'English', 'Català', 'Français', 'Deutsch', 'Italiano'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Idioma',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige el idioma de la aplicación',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
            ...languages.map((lang) => RadioListTile<String>(
              title: Text(
                lang,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              value: lang,
              groupValue: _selectedLanguage,
              activeColor: const Color(0xFF6366F1),
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Idioma cambiado a $val'),
                    backgroundColor: const Color(0xFF34D399),
                  ),
                );
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Mostrar información de una estadística
  void _showStatInfo(String title, String icon, String description, List<String> tips) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cómo incrementar:',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓ ', style: TextStyle(color: Color(0xFF34D399), fontSize: 16)),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendido',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar información de una medalla
  void _showAchievementInfo(String title, String icon, String description, String requirement, bool isLocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(
              isLocked ? '🔒' : icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (!isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Desbloqueada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLocked ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLocked ? const Color(0xFFF59E0B) : const Color(0xFF34D399),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline : Icons.check_circle,
                    color: isLocked ? const Color(0xFFF59E0B) : const Color(0xFF34D399),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLocked ? requirement : '¡Completado! $requirement',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLocked ? const Color(0xFF92400E) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar ayuda y soporte
  void _showHelpAndSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 12),
            Text(
              'Ayuda y Soporte',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const _HelpSection(
                icon: Icons.email,
                title: 'Contacto',
                description: 'soporte@intelliviatge.com',
              ),
              const SizedBox(height: 16),
              const _HelpSection(
                icon: Icons.phone,
                title: 'Teléfono',
                description: '+34 900 123 456',
              ),
              const SizedBox(height: 16),
              const _HelpSection(
                icon: Icons.schedule,
                title: 'Horario',
                description: 'Lunes a Viernes\n9:00 - 18:00',
              ),
              const SizedBox(height: 24),
              const Text(
                'Preguntas Frecuentes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const _FAQItem(
                question: '¿Cómo creo un viaje?',
                answer: 'Ve a la sección "Rutas y Viajes" y pulsa el botón "+" en la esquina superior derecha.',
              ),
              const _FAQItem(
                question: '¿Cómo invito amigos?',
                answer: 'Abre un viaje y pulsa "Invitar Amigo". Busca por email y envía la invitación.',
              ),
              const _FAQItem(
                question: '¿Puedo cambiar mi avatar?',
                answer: 'Sí, toca tu foto de perfil para elegir un nuevo avatar.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
              ),
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
                child: _StatCard(
                  icon: '🏛️',
                  value: '12',
                  label: 'Lugares\nVisitados',
                  onTap: () => _showStatInfo(
                    'Lugares Visitados',
                    '🏛️',
                    'Esta estadística muestra el número total de lugares y atracciones que has visitado durante tus viajes.',
                    [
                      'Visita museos, monumentos y lugares históricos',
                      'Explora atracciones turísticas en tus destinos',
                      'Marca lugares como visitados en tus rutas',
                      'Registra tus experiencias en cada ubicación',
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: '🗺️',
                  value: '5',
                  label: 'Rutas\nCompletadas',
                  onTap: () => _showStatInfo(
                    'Rutas Completadas',
                    '🗺️',
                    'Número de rutas de viaje que has completado exitosamente de principio a fin.',
                    [
                      'Planifica rutas completas con múltiples paradas',
                      'Completa todos los lugares de una ruta',
                      'Cierra y finaliza viajes activos',
                      'Documenta tus experiencias al terminar',
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: '🏆',
                  value: '8',
                  label: 'Medallas\nGanadas',
                  onTap: () => _showStatInfo(
                    'Medallas Ganadas',
                    '🏆',
                    'Total de medallas y logros que has desbloqueado al completar desafíos especiales.',
                    [
                      'Completa objetivos específicos de viaje',
                      'Desbloquea logros temáticos (foodie, arquitecto, etc.)',
                      'Alcanza hitos de viajes completados',
                      'Participa en eventos especiales de la app',
                    ],
                  ),
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
                    _AchievementBadge(
                      emoji: '🏛️',
                      label: 'Arquitecto',
                      description: 'Maestro de la arquitectura y la historia',
                      requirement: 'Visita 10 monumentos históricos o edificios arquitectónicos',
                      isLocked: false,
                      onTap: () => _showAchievementInfo(
                        'Arquitecto',
                        '🏛️',
                        'Maestro de la arquitectura y la historia',
                        'Visita 10 monumentos históricos o edificios arquitectónicos',
                        false,
                      ),
                    ),
                    _AchievementBadge(
                      emoji: '🍽️',
                      label: 'Foodie',
                      description: 'Amante de la gastronomía local',
                      requirement: 'Prueba 15 restaurantes diferentes',
                      isLocked: false,
                      onTap: () => _showAchievementInfo(
                        'Foodie',
                        '🍽️',
                        'Amante de la gastronomía local',
                        'Prueba 15 restaurantes diferentes',
                        false,
                      ),
                    ),
                    _AchievementBadge(
                      emoji: '🗺️',
                      label: 'Explorador',
                      description: 'Aventurero incansable',
                      requirement: 'Completa 5 rutas de viaje',
                      isLocked: false,
                      onTap: () => _showAchievementInfo(
                        'Explorador',
                        '🗺️',
                        'Aventurero incansable',
                        'Completa 5 rutas de viaje',
                        false,
                      ),
                    ),
                    _AchievementBadge(
                      emoji: '🌟',
                      label: 'VIP',
                      description: 'Viajero de élite con experiencia premium',
                      requirement: 'Alcanza 50 lugares visitados',
                      isLocked: true,
                      onTap: () => _showAchievementInfo(
                        'VIP',
                        '🌟',
                        'Viajero de élite con experiencia premium',
                        'Alcanza 50 lugares visitados',
                        true,
                      ),
                    ),
                    _AchievementBadge(
                      emoji: '🎨',
                      label: 'Artista',
                      description: 'Conocedor del arte y la cultura',
                      requirement: 'Visita 8 museos o galerías de arte',
                      isLocked: true,
                      onTap: () => _showAchievementInfo(
                        'Artista',
                        '🎨',
                        'Conocedor del arte y la cultura',
                        'Visita 8 museos o galerías de arte',
                        true,
                      ),
                    ),
                    _AchievementBadge(
                      emoji: '🏖️',
                      label: 'Beachgoer',
                      description: 'Amante de las playas y el sol',
                      requirement: 'Visita 5 destinos de playa',
                      isLocked: true,
                      onTap: () => _showAchievementInfo(
                        'Beachgoer',
                        '🏖️',
                        'Amante de las playas y el sol',
                        'Visita 5 destinos de playa',
                        true,
                      ),
                    ),
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
            onTap: _showNotificationSettings,
          ),
          _SettingsOption(
            icon: Icons.language,
            title: 'Idioma',
            onTap: _showLanguageSelector,
          ),
          _SettingsOption(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            onTap: _showHelpAndSupport,
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
  final VoidCallback? onTap;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            if (onTap != null) ..[
              const SizedBox(height: 4),
              const Icon(
                Icons.info_outline,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final String emoji;
  final String label;
  final String description;
  final String requirement;
  final bool isLocked;
  final VoidCallback? onTap;

  const _AchievementBadge({
    Key? key,
    required this.emoji,
    required this.label,
    required this.description,
    required this.requirement,
    this.isLocked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
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

// Widget helper para mostrar información de contacto
class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpSection({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget helper para preguntas frecuentes
class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❓ $question',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
