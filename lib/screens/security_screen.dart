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
            color: const Color(0xFFEF4444), // red-500
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFECDD3).withOpacity(0.5), // red-200
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
            border: Border.all(color: const Color(0xFFFEE2E2), width: 2), // red-100
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
                  color: Color(0xFFFEE2E2), // red-100
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone,
                  size: 40,
                  color: Color(0xFFDC2626), // red-600
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '112',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626), // red-600
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Emergencias Generales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569), // slate-700
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Gratuito. Funciona 24/7. Atienden en múltiples idiomas (inglés, francés, alemán, etc.). Llama aquí para policía, ambulancia o bomberos.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B), // slate-500
                ),
                textAlign: TextAlign.center,
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
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2), // slate-100
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F9FF), // sky-50
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9), // sky-500
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
                            color: Color(0xFF1E293B), // slate-800
                          ),
                        ),
                      ),
                      Icon(
                        _expandedSection == 'medical'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF0284C7), // sky-600
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
                        'En España, la atención médica de urgencia vital está garantizada y es gratuita para cualquier persona, independientemente de su nacionalidad o situación legal.',
                      ),
                      const SizedBox(height: 16),
                      _buildMedicalItem(
                        '🇪🇺',
                        'Ciudadanos Europeos',
                        'Si tienes la Tarjeta Sanitaria Europea (TSE), tienes derecho a recibir atención médica en las mismas condiciones que los residentes españoles en los centros de salud públicos (CAP).',
                      ),
                      const SizedBox(height: 16),
                      _buildMedicalItem(
                        '💊',
                        'Farmacias',
                        'Busca la cruz verde parpadeante. Siempre hay farmacias de guardia abiertas las 24 horas.',
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Incidents Section
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
                onTap: () => _toggleSection('incidents'),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFBEB), // amber-50
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B), // amber-500
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Qué hacer en caso de...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Icon(
                        _expandedSection == 'incidents'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFFD97706), // amber-600
                      ),
                    ],
                  ),
                ),
              ),
              if (_expandedSection == 'incidents')
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🏃‍♂️',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Robo o Hurto',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBulletList([
                        'Barcelona tiene un problema conocido con los carteristas (especialmente en Metro y Las Ramblas).',
                        'Si te roban sin violencia, acude a una comisaría de los Mossos d\'Esquadra para poner una denuncia (necesaria para el seguro).',
                        'Cancela tus tarjetas bancarias inmediatamente.',
                        'Si te roban el pasaporte, contacta con tu embajada o consulado.',
                      ]),
                      const SizedBox(height: 20),
                      Container(height: 1, color: const Color(0xFFF1F5F9)),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '👊',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Agresión o Peligro Inminente',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBulletList([
                        'Llama inmediatamente al 112.',
                        'Busca un lugar seguro o entra en un comercio abierto y pide ayuda.',
                        'Si necesitas atención médica, la ambulancia te llevará al hospital y la policía acudirá allí.',
                      ]),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Police Forces Section
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
                onTap: () => _toggleSection('police'),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF), // indigo-50
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1), // indigo-500
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cuerpos de Policía',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Icon(
                        _expandedSection == 'police'
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: const Color(0xFF4F46E5), // indigo-600
                      ),
                    ],
                  ),
                ),
              ),
              if (_expandedSection == 'police')
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'En Barcelona verás diferentes uniformes policiales. Cada uno tiene sus funciones:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Mossos d'Esquadra
                      _buildPoliceCard(
                        'https://picsum.photos/seed/mossos/400/200',
                        'ME',
                        'Mossos d\'Esquadra',
                        'Policía Autonómica (Cataluña)',
                        'Son la policía principal en Barcelona. Se encargan de la seguridad ciudadana, orden público y de investigar delitos (robos, agresiones). Acude a ellos para poner denuncias.',
                        const Color(0xFF3B82F6), // blue-500
                        const Color(0xFF3B82F6),
                        const Color(0xFF1E40AF), // blue-700
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Guàrdia Urbana
                      _buildPoliceCard(
                        'https://picsum.photos/seed/guardiaurbana/400/200',
                        'GU',
                        'Guàrdia Urbana',
                        'Policía Local (Ayuntamiento)',
                        'Gestionan el tráfico, accidentes urbanos, ordenanzas cívicas (ruido, venta ambulante) y seguridad en las calles.',
                        const Color(0xFF38BDF8), // sky-400
                        const Color(0xFF0284C7),
                        const Color(0xFF0369A1), // sky-700
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Policía Nacional
                      _buildPoliceCard(
                        'https://picsum.photos/seed/policianacional/400/200',
                        'CNP',
                        'Policía Nacional',
                        'Cuerpo Nacional',
                        'En Cataluña se encargan principalmente de extranjería (visados, NIE), expedición de DNI/Pasaportes, control de fronteras y terrorismo.',
                        const Color(0xFF475569), // slate-600
                        const Color(0xFF64748B),
                        const Color(0xFF475569), // slate-700
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Guardia Civil
                      _buildPoliceCard(
                        'https://picsum.photos/seed/guardiacivil/400/200',
                        'GC',
                        'Guardia Civil',
                        'Cuerpo Nacional (Militar)',
                        'En Barcelona los verás principalmente en el Aeropuerto, el Puerto, control de aduanas y protección de la naturaleza (SEPRONA).',
                        const Color(0xFF16A34A), // green-600
                        const Color(0xFF15803D),
                        const Color(0xFF166534), // green-700
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
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // slate-50
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 128,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0), // slate-200
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE2E8F0),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeBorderColor.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: borderColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
