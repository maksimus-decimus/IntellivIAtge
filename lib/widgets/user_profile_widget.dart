import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class UserProfileWidget extends StatefulWidget {
  final String userId;

  const UserProfileWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends State<UserProfileWidget> {
  late final FirebaseService _firebaseService;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _firebaseService.getCurrentUser();
      
      if (mounted) {
        setState(() {
          // Crear datos de perfil basados en Firebase Auth
          _profileData = {
            'name': user?.email?.split('@')[0] ?? 'Usuario',
            'email': user?.email ?? '',
            'level': 1,
            'level_name': 'TURISTA',
            'points': 0,
            'avatar_url': null,
          };
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar perfil: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Color(0xFFDC2626)),
        ),
      );
    }

    if (_profileData == null) {
      return const Center(
        child: Text('Perfil no encontrado'),
      );
    }

    final name = _profileData!['name'] ?? 'Usuario';
    final level = _profileData!['level'] ?? 1;
    final levelName = _profileData!['level_name'] ?? 'TURISTA';
    final points = _profileData!['points'] ?? 0;
    final avatarUrl = _profileData!['avatar_url'] as String?;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF0EA5E9),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0EA5E9),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE0F2FE),
                              child: const Center(
                                child: Text(
                                  '👤',
                                  style: TextStyle(fontSize: 48),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFFE0F2FE),
                          child: const Center(
                            child: Text(
                              '👤',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Nombre
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              // Nivel y puntos
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEAF6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$levelName - NIVEL $level',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0EA5E9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🔥 $points puntos',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Progreso de nivel
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (points % 100) / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0EA5E9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(points % 100).toStringAsFixed(0)}/100 puntos para el próximo nivel',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
