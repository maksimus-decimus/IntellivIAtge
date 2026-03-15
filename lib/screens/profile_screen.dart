import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://picsum.photos/100/100?random=100'),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Viajero Explorador',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
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
            onTap: onLogout,
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
