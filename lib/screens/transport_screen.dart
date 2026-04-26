import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/types.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({Key? key}) : super(key: key);

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  String _activeTab = 'guide';
  String? _expandedInfo;
  bool _isBuying = false;
  Map<String, dynamic>? _selectedTicket;
  int _ticketQuantity = 1;
  String _infoSearchQuery = '';

  // Popular destinations data
  final List<Map<String, dynamic>> _popularDestinations = [
    {
      'name': 'Sagrada Família',
      'emoji': '⛪',
      'transport': 'Metro L2/L5',
      'stop': 'Sagrada Família',
      'time': '~5 min walk',
      'color': const Color(0xFF6366F1),
      'tip': 'Buy tickets online to skip the queue.',
    },
    {
      'name': 'Park Güell',
      'emoji': '🌿',
      'transport': 'Bus 92 / 116',
      'stop': 'Ctra del Carmel',
      'time': '~10 min walk',
      'color': const Color(0xFF10B981),
      'tip': 'Book timed entry in advance — limited daily visitors.',
    },
    {
      'name': 'La Barceloneta',
      'emoji': '🏖️',
      'transport': 'Metro L4',
      'stop': 'Barceloneta',
      'time': '~8 min walk',
      'color': const Color(0xFF0EA5E9),
      'tip': 'Go early in summer — beach gets packed by 10am.',
    },
    {
      'name': 'Camp Nou',
      'emoji': '🏟️',
      'transport': 'Metro L3',
      'stop': 'Les Corts / Palau Reial',
      'time': '~12 min walk',
      'color': const Color(0xFFEC4899),
      'tip': 'Check for match days — stadium tours close early.',
    },
    {
      'name': 'La Boqueria',
      'emoji': '🛒',
      'transport': 'Metro L3',
      'stop': 'Liceu',
      'time': '~2 min walk',
      'color': const Color(0xFFF59E0B),
      'tip': 'Visit before 11am for a calmer, more local experience.',
    },
    {
      'name': 'Montjuïc',
      'emoji': '🏰',
      'transport': 'Cable car / Bus 150',
      'stop': 'Paral·lel (Metro L2/L3)',
      'time': 'Take funicular from Paral·lel',
      'color': const Color(0xFFEF4444),
      'tip': 'The funicular is included with your metro ticket.',
    },
    {
      'name': 'El Born / Gothic Quarter',
      'emoji': '🏛️',
      'transport': 'Metro L4',
      'stop': 'Jaume I',
      'time': '~3 min walk',
      'color': const Color(0xFF8B5CF6),
      'tip': 'Explore on foot — most sights are within 15 min of each other.',
    },
    {
      'name': 'Aeroport T1 / T2',
      'emoji': '✈️',
      'transport': 'Aerobus / Metro L9 Sud',
      'stop': 'Pl. Catalunya / T1 & T2',
      'time': '35–45 min from centre',
      'color': const Color(0xFF64748B),
      'tip': 'Aerobus is faster and runs 24h. Metro L9 is cheaper.',
    },
  ];

  final List<Map<String, dynamic>> _touristTickets = [
    {
      'id': 't-casual',
      'name': 'T-Casual (10 viajes)',
      'price': '12.15€',
      'desc': 'Ideal para estancias cortas. Unipersonal.',
      'color': const Color(0xFF10B981),
      'lightColor': const Color(0xFFD1FAE5),
    },
    {
      'id': 'hola-bcn-48',
      'name': 'Hola Barcelona 48h',
      'price': '17.50€',
      'desc': 'Viajes ilimitados por 2 días. Incluye aeropuerto.',
      'color': const Color(0xFF0EA5E9),
      'lightColor': const Color(0xFFE0F2FE),
    },
    {
      'id': 'hola-bcn-72',
      'name': 'Hola Barcelona 72h',
      'price': '25.50€',
      'desc': 'Viajes ilimitados por 3 días. Incluye aeropuerto.',
      'color': const Color(0xFF6366F1),
      'lightColor': const Color(0xFFE0E7FF),
    },
  ];

  // ✅ NEW: Parse price string and multiply by quantity
  String _calculateTotal() {
    if (_selectedTicket == null) return '0.00€';
    final raw =
        (_selectedTicket!['price'] as String).replaceAll('€', '').trim();
    final unitPrice = double.tryParse(raw) ?? 0.0;
    final total = unitPrice * _ticketQuantity;
    return '${total.toStringAsFixed(2)}€';
  }

  // ✅ Safe tab switcher that resets all transient state
  void _onTabChanged(String newTab) {
    setState(() {
      _activeTab = newTab;
      _isBuying = false;
      _selectedTicket = null;
      _expandedInfo = null;
      _ticketQuantity = 1; // ✅ reset quantity
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBuying && _selectedTicket != null) {
      return _buildPurchaseScreen();
    }

    return Column(
      children: [
        _buildTabs(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_activeTab == 'routes') _buildRoutesTab(),
              if (_activeTab == 'tickets') _buildTicketsTab(),
              if (_activeTab == 'guide') _buildGuideTab(),
              if (_activeTab == 'info') _buildInfoTab(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildTab('routes', 'Rutas 🗺️'),
          _buildTab('tickets', 'Billetes 🎟️'),
          _buildTab('guide', 'Guía 📖'),
          _buildTab('info', 'Medios 🚇'),
        ],
      ),
    );
  }

  Widget _buildTab(String tab, String label) {
    final isActive = _activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: isActive
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF3B82F6)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Introduce tu origen y destino para ver la mejor forma de llegar en transporte público.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    left: 14,
                    top: 24,
                    bottom: 24,
                    child: Container(width: 2, color: const Color(0xFFE2E8F0)),
                  ),
                  Column(
                    children: [
                      _buildLocationInput(
                          'Mi ubicación actual', const Color(0xFF0EA5E9)),
                      const SizedBox(height: 16),
                      _buildLocationInput(
                          '¿A dónde quieres ir?', const Color(0xFFEC4899)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Calculando la mejor ruta...')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Buscar Ruta',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput(String hint, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: dotColor, width: 4),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: Color(0xFFE2E8F0), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: dotColor, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'Recomendados para turistas',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B)),
          ),
        ),
        ..._touristTickets.map((ticket) => _buildTicketCard(ticket)),
      ],
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ticket['color'],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: (ticket['color'] as Color).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.confirmation_number,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ticket['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(ticket['desc'],
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                        height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(ticket['price'],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedTicket = ticket;
                  _isBuying = true;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Comprar',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0EA5E9))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ REPLACED: now includes quantity selector and dynamic total
  Widget _buildPurchaseScreen() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ticket icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _selectedTicket!['color'],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_selectedTicket!['color'] as Color)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedTicket!['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTicket!['desc'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ✅ Quantity selector row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cantidad',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Row(
                        children: [
                          // Minus button
                          GestureDetector(
                            onTap: () {
                              if (_ticketQuantity > 1) {
                                setState(() => _ticketQuantity--);
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _ticketQuantity > 1
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.remove,
                                size: 18,
                                color: _ticketQuantity > 1
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          // Quantity display
                          SizedBox(
                            width: 48,
                            child: Text(
                              '$_ticketQuantity',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          // Plus button
                          GestureDetector(
                            onTap: () {
                              if (_ticketQuantity < 10) {
                                setState(() => _ticketQuantity++);
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _ticketQuantity < 10
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 18,
                                color: _ticketQuantity < 10
                                    ? Colors.white
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Price breakdown
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      // Unit price row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Precio unitario',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            _selectedTicket!['price'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      // ✅ Quantity line only shown when qty > 1
                      if (_ticketQuantity > 1) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'x$_ticketQuantity billetes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const Icon(
                              Icons.calculate_outlined,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      // ✅ Dynamic total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a pagar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            _calculateTotal(), // ✅ reactive total
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isBuying = false;
                            _selectedTicket = null;
                            _ticketQuantity = 1; // ✅ reset quantity
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF64748B),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '¡$_ticketQuantity billete(s) comprado(s)! Disponibles en tu perfil.',
                              ),
                            ),
                          );
                          setState(() {
                            _isBuying = false;
                            _selectedTicket = null;
                            _ticketQuantity = 1; // ✅ reset quantity
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _selectedTicket!['color'],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.credit_card, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Pagar',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 16),
          child: Text('¿Cómo funciona el transporte?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
        ),
        _buildGuideStep1(),
        const SizedBox(height: 16),
        _buildGuideStep2(),
        const SizedBox(height: 16),
        _buildGuideStep3(),
        const SizedBox(height: 16),
        _buildGuideStep4(),
      ],
    );
  }

  Widget _buildGuideStep1() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('1',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626))))),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Comprar en las Máquinas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B)))),
        ]),
        const SizedBox(height: 12),
        const Text(
            'Encontrarás máquinas rojas en todas las estaciones de metro. Puedes cambiar el idioma a inglés o francés en la pantalla inicial. ¡Recuerda que casi todo Barcelona es Zona 1!',
            style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF334155), width: 4)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Row(children: [
                Icon(Icons.confirmation_number, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('TMB Tickets',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white))
              ]),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF475569),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('EN | ES | FR',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ]),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF475569)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('Hola BCN 48h\n(Recomendado)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)))),
              const SizedBox(width: 8),
              Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('T-Casual\n(10 viajes)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)))),
            ]),
            const SizedBox(height: 8),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Billete Sencillo (2.55€)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white))),
          ]),
        ),
        const SizedBox(height: 16),
        const Row(children: [
          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          SizedBox(width: 8),
          Expanded(
              child: Text('Aceptan tarjeta (contactless) y efectivo.',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B))))
        ]),
        const SizedBox(height: 8),
        const Row(children: [
          Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          SizedBox(width: 8),
          Expanded(
              child: Text(
                  'Los billetes turísticos (Hola BCN) son la mejor opción.',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B))))
        ]),
      ]),
    );
  }

  Widget _buildGuideStep2() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('2',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB))))),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Los Tornos (Pasadores)',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B)))),
        ]),
        const SizedBox(height: 12),
        const Text(
            'Para entrar al metro o tren, debes validar tu billete. En el bus, la validadora está justo al subir.',
            style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      border:
                          Border.all(color: const Color(0xFFFCD34D), width: 2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Container(
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(3))),
                    const Text('Billete de Cartón\n(Inserta aquí)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF92400E)))
                  ]))),
          const SizedBox(width: 12),
          Expanded(
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      border:
                          Border.all(color: const Color(0xFFBAE6FD), width: 2),
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6), shape: BoxShape.circle),
                        child: const Icon(Icons.credit_card,
                            color: Colors.white, size: 20)),
                    const Text('Contactless\n(Acerca aquí)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E40AF)))
                  ]))),
        ]),
        const SizedBox(height: 16),
        Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Column(children: [
              Text(
                  '🎫 Cartón: Introdúcelo por la ranura frontal y recógelo por arriba. ¡No lo pierdas!',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569))),
              SizedBox(height: 8),
              Text(
                  '📱 T-Mobilitat: Acércalo al lector rojo con el símbolo de WiFi.',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569))),
            ])),
      ]),
    );
  }

  Widget _buildGuideStep3() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('3',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF059669))))),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Transbordos Gratuitos',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B)))),
        ]),
        const SizedBox(height: 12),
        RichText(
            text: const TextSpan(
                style: TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.5),
                children: [
              TextSpan(text: 'Con billetes como la T-Casual, tienes '),
              TextSpan(
                  text: '1 hora y 15 minutos',
                  style: TextStyle(fontWeight: FontWeight.w900)),
              TextSpan(
                  text:
                      ' para cambiar de medio de transporte sin que te cobren un segundo viaje.'),
            ])),
        const SizedBox(height: 16),
        Stack(alignment: Alignment.center, children: [
          Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ]),
                child: const Text('🚇', style: TextStyle(fontSize: 32))),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    border:
                        Border.all(color: const Color(0xFF86EFAC), width: 2),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('75 min',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF059669)))),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ]),
                child: const Text('🚌', style: TextStyle(fontSize: 32))),
          ]),
        ]),
        const SizedBox(height: 16),
        const Text(
            '⚠️ Ojo: No puedes salir del metro y volver a entrar al metro con el mismo viaje.',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569))),
      ]),
    );
  }

  Widget _buildGuideStep4() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFFE9D5FF),
                  borderRadius: BorderRadius.circular(12)),
              child: const Center(
                  child: Text('4',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF9333EA))))),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Conoce tus opciones',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B)))),
        ]),
        const SizedBox(height: 12),
        ...AppConstants.transportOptions.map((opt) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: Text(opt.icon, style: const TextStyle(fontSize: 28))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      Expanded(
                          child: Text(opt.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B)))),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(opt.price,
                              style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A)))),
                    ]),
                    const SizedBox(height: 4),
                    Text(opt.description,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            height: 1.4)),
                    const SizedBox(height: 8),
                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFEF3C7))),
                        child: Text('💡 ${opt.tips}',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E)))),
                  ])),
            ]),
          );
        }).toList(),
      ]),
    );
  }

  Widget _buildInfoTab() {
    final query = _infoSearchQuery.toLowerCase();
    final filtered = AppConstants.transportOptions
        .where((opt) =>
            query.isEmpty ||
            opt.name.toLowerCase().contains(query) ||
            opt.description.toLowerCase().contains(query))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search bar ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: TextField(
            onChanged: (v) => setState(() => _infoSearchQuery = v),
            decoration: InputDecoration(
              hintText: 'Buscar medio de transporte...',
              hintStyle: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              prefixIcon:
                  const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
              suffixIcon: _infoSearchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () => setState(() => _infoSearchQuery = ''),
                      child: const Icon(Icons.close,
                          color: Color(0xFF94A3B8), size: 18),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),

        // ── Popular Destinations ─────────────────────────────
        if (query.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Row(children: [
              Text('📍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('Destinos Populares',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
            ]),
          ),
          SizedBox(
            height: 195,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
              itemCount: _popularDestinations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  _buildDestinationCard(_popularDestinations[i]),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // ── Transport options header ─────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(children: [
            const Text('🚇', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              query.isEmpty
                  ? 'Medios de Transporte'
                  : '${filtered.length} resultado${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B)),
            ),
          ]),
        ),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Center(
              child: Column(children: [
                Text('🔍', style: TextStyle(fontSize: 32)),
                SizedBox(height: 8),
                Text('Sin resultados',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B),
                        fontSize: 16)),
                SizedBox(height: 4),
                Text('Prueba con metro, bus, tren...',
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ]),
            ),
          )
        else
          ...filtered.map((opt) => _buildExpandableCard(opt)),
      ],
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> dest) {
    final color = dest['color'] as Color;
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(dest['emoji'],
                      style: const TextStyle(fontSize: 18))),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(dest['transport'],
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w900, color: color)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(dest['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 3),
          Row(children: [
            const Icon(Icons.place_outlined,
                size: 11, color: Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(dest['stop'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B))),
            ),
          ]),
          const SizedBox(height: 2),
          Row(children: [
            const Icon(Icons.directions_walk,
                size: 11, color: Color(0xFF94A3B8)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(dest['time'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8))),
            ),
          ]),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8)),
            child: Text('💡 ${dest['tip']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard(TransportOption opt) {
    final isExpanded = _expandedInfo == opt.id;

    // Extra detail data keyed by transport id
    final Map<String, Map<String, dynamic>> _extraDetails = {
      'metro': {
        'lines': [
          'L1',
          'L2',
          'L3',
          'L4',
          'L5',
          'L9N',
          'L9S',
          'L10N',
          'L10S',
          'L11'
        ],
        'lineColors': [
          const Color(0xFFE3000B),
          const Color(0xFF7B1FA2),
          const Color(0xFF007F41),
          const Color(0xFFFFD700),
          const Color(0xFF003F8A),
          const Color(0xFFE87722),
          const Color(0xFFE87722),
          const Color(0xFF009FE3),
          const Color(0xFF009FE3),
          const Color(0xFF009FE3),
        ],
        'hours':
            'Mon–Thu & Sun: 5am–12am\nFri: 5am–2am\nSat & eves of holidays: 24h',
        'frequency': 'Every 3–6 min (peak) / 6–10 min (off-peak)',
        'zones': 'Zone 1 covers all of Barcelona city',
      },
      'bus': {
        'lines': ['H6', 'H10', 'H16', 'V7', 'V13', 'V17', '24', 'N4'],
        'lineColors': [
          const Color(0xFF10B981),
          const Color(0xFF10B981),
          const Color(0xFF10B981),
          const Color(0xFF0EA5E9),
          const Color(0xFF0EA5E9),
          const Color(0xFF0EA5E9),
          const Color(0xFF6366F1),
          const Color(0xFF1E293B),
        ],
        'hours': 'Most lines: 5am–11pm\nNit Bus (N lines): 10:30pm–5am',
        'frequency': 'Every 6–12 min on main routes',
        'zones': 'Same zone system as metro — T-Casual valid',
      },
      'fgc': {
        'lines': ['S1', 'S2', 'S5', 'S55', 'L6', 'L7', 'R5', 'R6'],
        'lineColors': [
          const Color(0xFF8B5CF6),
          const Color(0xFF8B5CF6),
          const Color(0xFF8B5CF6),
          const Color(0xFF8B5CF6),
          const Color(0xFF8B5CF6),
          const Color(0xFF8B5CF6),
          const Color(0xFFEC4899),
          const Color(0xFFEC4899),
        ],
        'hours': 'Mon–Thu: 5am–12am\nFri–Sat: 5am–2am\nSun: 6am–12am',
        'frequency': 'Every 6–15 min depending on line',
        'zones': 'Connects to Zone 2+ suburbs (Tibidabo, Montserrat)',
      },
      'rodalies': {
        'lines': ['R1', 'R2', 'R3', 'R4', 'R7', 'R10', 'R11', 'R12'],
        'lineColors': [
          const Color(0xFFE3000B),
          const Color(0xFF007F41),
          const Color(0xFFFFD700),
          const Color(0xFF003F8A),
          const Color(0xFF6366F1),
          const Color(0xFF0EA5E9),
          const Color(0xFFEC4899),
          const Color(0xFF10B981),
        ],
        'hours': 'Approx. 5am–11:30pm (varies by line)',
        'frequency': 'Every 15–30 min',
        'zones': 'Multi-zone — check before boarding',
      },
    };

    final extra = _extraDetails[opt.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2)),
      child: Column(children: [
        InkWell(
          onTap: () =>
              setState(() => _expandedInfo = isExpanded ? null : opt.id),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(opt.icon, style: const TextStyle(fontSize: 28))),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(opt.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Row(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(opt.price,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF16A34A)))),
                      const SizedBox(width: 6),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('Ver detalles',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF3B82F6)))),
                    ]),
                  ])),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF94A3B8)),
            ]),
          ),
        ),
        if (isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Description
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(opt.description,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                          height: 1.5))),
              const SizedBox(height: 12),

              // Lines chips
              if (extra != null) ...[
                const Text('Líneas principales',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                      (extra['lines'] as List).length,
                      (i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: (extra['lineColors'] as List<Color>)[i]
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        (extra['lineColors'] as List<Color>)[i]
                                            .withValues(alpha: 0.4))),
                            child: Text(extra['lines'][i],
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: (extra['lineColors']
                                        as List<Color>)[i])),
                          )),
                ),
                const SizedBox(height: 12),

                // Hours & frequency
                Row(children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.access_time,
                                  size: 14, color: Color(0xFF6366F1)),
                              SizedBox(width: 4),
                              Text('Horario',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6366F1))),
                            ]),
                            const SizedBox(height: 6),
                            Text(extra['hours'],
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                    height: 1.5)),
                          ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              Icon(Icons.speed,
                                  size: 14, color: Color(0xFF10B981)),
                              SizedBox(width: 4),
                              Text('Frecuencia',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF10B981))),
                            ]),
                            const SizedBox(height: 6),
                            Text(extra['frequency'],
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF475569),
                                    height: 1.5)),
                          ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),

                // Zone info
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDBEAFE))),
                  child: Row(children: [
                    const Icon(Icons.map_outlined,
                        size: 14, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(extra['zones'],
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8))),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              // Tip
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('💡 ${opt.tips}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                          height: 1.5))),
            ]),
          ),
      ]),
    );
  }
}
