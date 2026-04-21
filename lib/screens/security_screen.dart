import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  String _language = 'es'; // es, en, fr
  String? _expandedSection = 'medical';

  // 🌍 Simple translator
  String t(Map<String, String> values) {
    return values[_language] ?? values['es']!;
  }

  Widget _langButton(String label, String code) {
    final selected = _language == code;

    return GestureDetector(
      onTap: () => setState(() => _language = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDC2626) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDC2626)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFDC2626),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _callEmergency() async {
    HapticFeedback.mediumImpact();

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(t({
          'es': 'Llamar al 112',
          'en': 'Call 112',
          'fr': 'Appeler le 112',
        })),
        content: Text(t({
          'es': 'Vas a llamar a emergencias. Solo si es real.',
          'en': 'You are about to call emergency services.',
          'fr': 'Vous allez appeler les urgences.',
        })),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t({'es': 'Cancelar', 'en': 'Cancel', 'fr': 'Annuler'})),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t({'es': 'Llamar', 'en': 'Call', 'fr': 'Appeler'})),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final uri = Uri.parse('tel:112');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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

        // HEADER
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t({
                  'es': 'Seguridad y Salud 🛡️',
                  'en': 'Safety & Health 🛡️',
                  'fr': 'Sécurité et Santé 🛡️',
                }),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // 🌍 LANGUAGE SWITCH
              Row(
                children: [
                  _langButton('ES', 'es'),
                  const SizedBox(width: 8),
                  _langButton('EN', 'en'),
                  const SizedBox(width: 8),
                  _langButton('FR', 'fr'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // EMERGENCY CARD
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.phone, size: 60, color: Color(0xFFDC2626)),
              const SizedBox(height: 12),
              Text(
                '112',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                ),
              ),
              Text(
                t({
                  'es': 'Emergencias Generales',
                  'en': 'Emergency Services',
                  'fr': 'Urgences Générales',
                }),
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.05),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _callEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      t({
                        'es': 'LLAMAR 112',
                        'en': 'CALL 112',
                        'fr': 'APPELER 112'
                      }),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // MEDICAL SECTION
        _buildSection(
          'medical',
          Icons.favorite,
          t({
            'es': 'Asistencia Médica',
            'en': 'Medical Assistance',
            'fr': 'Assistance Médicale',
          }),
          [
            _info(
              '🏥',
              t({
                'es': 'Urgencias gratuitas para todos',
                'en': 'Free emergency care for everyone',
                'fr': 'Urgences gratuites pour tous',
              }),
            ),
            _info(
              '🇪🇺',
              t({
                'es': 'Acceso con tarjeta europea',
                'en': 'Access with EU health card',
                'fr': 'Accès avec carte européenne',
              }),
            ),
            _info(
              '💊',
              t({
                'es': 'Farmacias de guardia 24h',
                'en': '24h pharmacies available',
                'fr': 'Pharmacies de garde 24h',
              }),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // POLICE SECTION
        _buildSection(
          'police',
          Icons.shield,
          t({
            'es': 'Cuerpos de Policía',
            'en': 'Police Forces',
            'fr': 'Forces de Police',
          }),
          [
            _info(
              'ME',
              t({
                'es': 'Mossos: Policía principal en Cataluña',
                'en': 'Mossos: Main Catalonia police',
                'fr': 'Mossos: Police principale Catalogne',
              }),
            ),
            _info(
              'GU',
              t({
                'es': 'Guàrdia Urbana: tráfico y ciudad',
                'en': 'Urban police: traffic & city rules',
                'fr': 'Police municipale: circulation',
              }),
            ),
            _info(
              'CNP',
              t({
                'es': 'Policía Nacional: documentos y fronteras',
                'en': 'National Police: documents & borders',
                'fr': 'Police nationale: documents',
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      String id, IconData icon, String title, List<Widget> items) {
    final expanded = _expandedSection == id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleSection(id),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title)),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: items),
            ),
        ],
      ),
    );
  }

  Widget _info(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
