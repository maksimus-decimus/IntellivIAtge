import 'package:flutter/material.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String? _expandedSection = 'emergencies';

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),

        // Header Banner
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFECDD3).withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seguridad y Salud 🛡️',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Si necesitas ayuda urgentemente, llama inmediatamente a este número:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: -20,
                bottom: -20,
                child: Transform.rotate(
                  angle: 0.2,
                  child: Text(
                    '🚨',
                    style: TextStyle(
                      fontSize: 80,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 112 Emergency Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFEE2E2), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  size: 40,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '112',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Emergencias Generales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gratuito. Funciona 24/7. Atienden en múltiples idiomas (inglés, francés, alemán, etc.). Llama aquí para policía, ambulancia o bomberos.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Call 112 (use url_launcher if needed)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                  child: const Text(
                    'LLAMAR 112',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Medical Services Section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => _toggleSection('medical'),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F9FF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Asistencia Médica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Icon(
                        _expandedSection == 'medical'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF0284C7),
                      ),
                    ],
                  ),
                ),
              ),
              if (_expandedSection == 'medical')
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildMedicalItem(
                        '🏥',
                        'Urgencias Gratuitas',
                        'En España, la atención médica de urgencia vital es gratuita.',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMedicalItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      children: items
          .map(
            (e) => Row(
              children: [
                const Text('• '),
                Expanded(child: Text(e)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildPoliceCard(
    String imageUrl,
    String badge,
    String title,
    String subtitle,
    String description,
    Color borderColor,
    Color badgeBorderColor,
    Color badgeTextColor,
  ) {
    return Container();
  }
}
