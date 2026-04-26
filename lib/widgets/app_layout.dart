import 'package:flutter/material.dart';
import '../models/types.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final ScreenName currentScreen;
  final Function(ScreenName) onNavigate;
  final String? title;
  final List<ScreenName> shortcuts;
  final String? userPhotoUrl;

  const AppLayout({
    Key? key,
    required this.child,
    required this.currentScreen,
    required this.onNavigate,
    this.title,
    this.shortcuts = const [],
    this.userPhotoUrl,
  }) : super(key: key);

  String _getScreenTitle(ScreenName screen) {
    switch (screen) {
      case ScreenName.home:
        return 'Inicio';
      case ScreenName.aiGuide:
        return 'Guía IA';
      case ScreenName.attractions:
        return 'Atracciones';
      case ScreenName.map:
        return 'Rutas y Mapa';
      case ScreenName.restaurants:
        return 'Gastronomía';
      case ScreenName.transport:
        return 'Transporte';
      case ScreenName.activities:
        return 'Actividades';
      case ScreenName.trips:
        return 'Rutas y Viajes';
      case ScreenName.groups:
        return 'Mis Grupos';
      case ScreenName.translator:
        return 'Traductor';
      case ScreenName.currency:
        return 'Conversor';
      case ScreenName.security:
        return 'Seguridad';
      case ScreenName.profile:
        return 'Mi Perfil';
      case ScreenName.firstTimeGuide:
        return 'Guía Inicial';
      default:
        return 'IntellivIAtge';
    }
  }

  IconData _getScreenIcon(ScreenName screen) {
    switch (screen) {
      case ScreenName.home:
        return Icons.home;
      case ScreenName.groups:
        return Icons.groups;
      case ScreenName.aiGuide:
        return Icons.smart_toy;
      case ScreenName.trips:
        return Icons.map;
      case ScreenName.profile:
        return Icons.person;
      case ScreenName.restaurants:
        return Icons.restaurant;
      case ScreenName.attractions:
        return Icons.account_balance;
      case ScreenName.activities:
        return Icons.local_activity;
      case ScreenName.transport:
        return Icons.directions_bus;
      case ScreenName.translator:
        return Icons.translate;
      case ScreenName.currency:
        return Icons.attach_money;
      case ScreenName.security:
        return Icons.shield;
      default:
        return Icons.home;
    }
  }

  String _getScreenLabel(ScreenName screen) {
    switch (screen) {
      case ScreenName.home:
        return 'Inicio';
      case ScreenName.groups:
        return 'Grupos';
      case ScreenName.aiGuide:
        return 'Guía';
      case ScreenName.trips:
        return 'Viajes';
      case ScreenName.profile:
        return 'Perfil';
      default:
        return 'Inicio';
    }
  }

  Widget _buildUserAvatar() {
    // Helper to build image widget based on URL type
    Widget buildImage(String imageUrl) {
      final isLocalAsset = !imageUrl.startsWith('http://') && !imageUrl.startsWith('https://');
      
      if (isLocalAsset) {
        return Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            size: 24,
            color: Color(0xFF64748B),
          ),
        );
      } else {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64748B)),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            size: 24,
            color: Color(0xFF64748B),
          ),
        );
      }
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF1F5F9),
      child: userPhotoUrl != null
          ? ClipOval(child: buildImage(userPhotoUrl!))
          : const Icon(
              Icons.person,
              size: 24,
              color: Color(0xFF64748B),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHome = currentScreen == ScreenName.home;
    final isLogin = currentScreen == ScreenName.login;

    if (isLogin) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F9FF),
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isHome
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildUserAvatar(),
              )
            : IconButton(
                icon: const Text('🔙', style: TextStyle(fontSize: 24)),
                onPressed: () => onNavigate(ScreenName.home),
              ),
        title: isHome
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Hola, Viajero!',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'NIVEL 1 - TURISTA',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            : Text(
                title ?? _getScreenTitle(currentScreen),
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Text('🔥', style: TextStyle(fontSize: 16)),
                SizedBox(width: 4),
                Text(
                  '3',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: child,
      ),
      bottomNavigationBar: shortcuts.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: shortcuts.map((screen) {
                  final isActive = currentScreen == screen;
                  return _NavButton(
                    icon: _getScreenIcon(screen),
                    label: _getScreenLabel(screen),
                    isActive: isActive,
                    onTap: () => onNavigate(screen),
                  );
                }).toList(),
              ),
            )
          : null,
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDEEAF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF0EA5E9) : const Color(0xFF94A3B8),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
