import 'package:flutter/material.dart';
import '../widgets/bouncy_button.dart';

enum ViewState { menu, faq, quiz }

class FirstTimeGuideScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstTimeGuideScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<FirstTimeGuideScreen> createState() => _FirstTimeGuideScreenState();
}

class _FirstTimeGuideScreenState extends State<FirstTimeGuideScreen> {
  ViewState _view = ViewState.menu;
  int _step = 0;
  List<int> _answers = [];
  String? _openId;

  // FAQ Data
  final List<Map<String, dynamic>> _faqs = [
    {
      'id': 'airport',
      'icon': Icons.flight,
      'iconColor': const Color(0xFF0EA5E9), // sky-500
      'bg': const Color(0xFFF0F9FF), // sky-50
      'question': '¿Cómo llego del aeropuerto al centro?',
      'answer':
          'Tienes varias opciones:\n\n**Aerobús** (€5.90 one way, €10.20 return, ~35 min): Autobús directo que conecta T1 y T2 con Plaza Catalunya. Sale cada 5-10 minutos.\n\n**Metro L9 Sud** (€5.15, ~30 min): Línea de metro que conecta el aeropuerto con varias estaciones importantes. Requiere billete especial.\n\n**Taxi** (€30-35, ~25 min): Tarifa fija desde el aeropuerto al centro de Barcelona.\n\n**Renfe R2 Nord** (€4.60, ~25 min desde T2): Conecta con Passeig de Gràcia y Arc de Triomf. Si llegas a T1, necesitas tomar un shuttle a T2.'
    },
    {
      'id': 'tickets',
      'icon': Icons.credit_card,
      'iconColor': const Color(0xFF10B981), // emerald-500
      'bg': const Color(0xFFECFDF5), // emerald-50
      'question': '¿Qué billete de transporte me conviene?',
      'answer':
          'Depende de tu estancia:\n\n**Hola Barcelona Travel Card**: Válida para 2, 3, 4 o 5 días consecutivos. Incluye transporte ilimitado (metro, bus, tram, trenes Renfe, FGC en zona 1). Precio: desde €16.30 (2 días) hasta €38 (5 días). Muy recomendable si te mueves mucho.\n\n**T-Casual** (€11.35): 10 viajes individuales en 1 hora 15 min (puedes hacer transbordos).\n\n**Billete Sencillo** (€2.40): Un solo viaje, sin trasbordos. No recomendable si vas a usar el transporte varias veces.\n\nSi te quedas más de 3 días, la **Hola Barcelona** es la mejor opción.'
    },
    {
      'id': 'machines',
      'icon': Icons.local_atm,
      'iconColor': const Color(0xFFA855F7), // purple-500
      'bg': const Color(0xFFFAF5FF), // purple-50
      'question': 'Las máquinas del metro solo aceptan tarjeta?',
      'answer':
          'Las máquinas automáticas de TMB aceptan:\n\n• **Tarjetas de crédito/débito** (Visa, Mastercard, Maestro)\n• **Efectivo** (billetes y monedas)\n• **Contactless** con tarjeta o móvil\n\n**Consejo**: Las máquinas a veces dan problemas con billetes grandes (€50). Es mejor pagar con tarjeta o llevar cambio. También puedes comprar billetes en estancos y quioscos.'
    },
    {
      'id': 'safety',
      'icon': Icons.warning,
      'iconColor': const Color(0xFFEF4444), // red-500
      'bg': const Color(0xFFFEE2E2), // red-50
      'question': 'He oído que hay muchos carteristas...',
      'answer':
          'Barcelona tiene fama de carteristas, especialmente en zonas turísticas (Ramblas, Gótico, Sagrada Família, Metro). Consejos prácticos:\n\n**En el metro y sitios concurridos**: Lleva la mochila delante, nunca la dejes abierta, no saques el móvil cerca de las puertas.\n\n**En terrazas**: No dejes el móvil en la mesa. Pon el bolso/mochila entre tus piernas o en el regazo, nunca colgado de la silla.\n\n**Técnicas comunes**: Distracciones (alguien te pregunta algo mientras otro te roba), "mancha" en tu ropa (te dicen que tienes algo y mientras limpias, te roban), grupos que te rodean en el metro.\n\nBarcelona es segura si estás atento. La mayoría de turistas no tienen problemas.'
    },
  ];

  // Quiz Questions
  final List<Map<String, dynamic>> _questions = [
    {
      'q': '¿Qué te apetece más?',
      'options': [
        {'icon': '🏛️', 'text': 'Historia y Arquitectura'},
        {'icon': '🍷', 'text': 'Gastronomía y Tapas'},
        {'icon': '🏖️', 'text': 'Playa y Relax'},
      ]
    },
    {
      'q': '¿Con quién viajas?',
      'options': [
        {'icon': '❤️', 'text': 'En pareja'},
        {'icon': '👨‍👩‍👧‍👦', 'text': 'En familia o amigos'},
        {'icon': '🎒', 'text': 'Solo/a'},
      ]
    },
    {
      'q': '¿Cuánto te gusta caminar?',
      'options': [
        {'icon': '🚶', 'text': 'Prefiero transporte'},
        {'icon': '🚶‍♂️', 'text': 'Un poco, sin pasarme'},
        {'icon': '🏃‍♂️', 'text': 'Me encanta explorar a pie'},
      ]
    },
  ];

  void _handleAnswer(int answerIndex) {
    setState(() {
      _answers.add(answerIndex);
      if (_step < _questions.length - 1) {
        _step++;
      } else {
        _step++;
      }
    });
  }

  String _getResultTitle() {
    if (_answers.isEmpty) return '';
    switch (_answers[0]) {
      case 0:
        return 'Ruta Gótica';
      case 1:
        return 'Ruta de Tapas';
      case 2:
        return 'La Barceloneta';
      default:
        return 'Explora Barcelona';
    }
  }

  String _getResultEmoji() {
    if (_answers.isEmpty) return '🗺️';
    switch (_answers[0]) {
      case 0:
        return '🏛️';
      case 1:
        return '🍷';
      case 2:
        return '🏖️';
      default:
        return '🗺️';
    }
  }

  String _getResultDescription() {
    if (_answers.isEmpty) return '';
    switch (_answers[0]) {
      case 0:
        return 'Te recomendamos explorar la Catedral, el Born y el Barrio Gótico. Perfecto para amantes de la historia.';
      case 1:
        return 'Tu ruta perfecta: Mercado de la Boquería, bares de tapas en El Raval y Gràcia. ¡A disfrutar!';
      case 2:
        return 'Playa, paseo marítimo y chiringuitos. El plan perfecto para relajarse junto al mar.';
      default:
        return '';
    }
  }

  Widget _buildMenuView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF), // indigo-100
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '👋',
              style: TextStyle(fontSize: 48),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '¡Hola! Soy GaudíBot',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Tu asistente personal para Barcelona',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        _buildMenuCard(
          Icons.auto_awesome,
          'Ayúdame a empezar',
          'Responde 3 preguntas y te recomendaré tu ruta perfecta',
          const Color(0xFF0EA5E9), // sky-500
          const Color(0xFFF0F9FF), // sky-50
          () => setState(() {
            _view = ViewState.quiz;
            _step = 0;
            _answers = [];
          }),
        ),
        const SizedBox(height: 16),
        _buildMenuCard(
          Icons.help_outline,
          'Preguntas Frecuentes',
          'Aeropuerto, transporte, seguridad y más',
          const Color(0xFFF59E0B), // amber-500
          const Color(0xFFFEF3C7), // amber-100
          () => setState(() => _view = ViewState.faq),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: widget.onComplete,
          child: const Text(
            'Saltar introducción →',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String subtitle,
      Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _view = ViewState.menu),
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xFF1E293B),
            ),
            const Expanded(
              child: Text(
                'Preguntas Frecuentes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ..._faqs.map((faq) => _buildFaqItem(faq)).toList(),
      ],
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    final bool isOpen = _openId == faq['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: faq['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (faq['iconColor'] as Color).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              _openId = isOpen ? null : faq['id'];
            }),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (faq['iconColor'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      faq['icon'],
                      color: faq['iconColor'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Icon(
                    isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: faq['iconColor'],
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildFormattedAnswer(faq['answer']),
            ),
        ],
      ),
    );
  }

  Widget _buildFormattedAnswer(String answer) {
    final parts = answer.split('**');
    final List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Normal text
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF475569),
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ));
      } else {
        // Bold text
        spans.add(TextSpan(
          text: parts[i],
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Widget _buildQuizView() {
    if (_step >= _questions.length) {
      return _buildQuizResult();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (_step > 0) {
                  _step--;
                  _answers.removeLast();
                } else {
                  _view = ViewState.menu;
                }
              }),
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xFF1E293B),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_questions.length, (i) {
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? const Color(0xFF0EA5E9)
                          : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 48),
        Text(
          _questions[_step]['q'],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...List.generate(
          (_questions[_step]['options'] as List).length,
          (i) {
            final option = _questions[_step]['options'][i];
            return _buildQuizOption(option['icon'], option['text'], i);
          },
        ),
      ],
    );
  }

  Widget _buildQuizOption(String emoji, String text, int index) {
    return GestureDetector(
      onTap: () => _handleAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResult() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getResultEmoji(),
              style: const TextStyle(fontSize: 56),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '¡Perfecto!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getResultTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0EA5E9),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _getResultDescription(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        BouncyButton(
          onPressed: widget.onComplete,
          fullWidth: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('¡Empezar a Explorar!'),
              SizedBox(width: 8),
              Text('🚀', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _view = ViewState.menu),
          child: const Text(
            'Volver al Menú',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: () {
            switch (_view) {
              case ViewState.menu:
                return _buildMenuView();
              case ViewState.faq:
                return _buildFaqView();
              case ViewState.quiz:
                return _buildQuizView();
            }
          }(),
        ),
      ),
    );
  }
}
