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

  // Ticket section state
  String _ticketCategory = 'tourist'; // 'tourist' | 'standard' | 'special'
  bool _showComparison = false;
  Set<String> _comparisonIds = {};

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

  // ── All ticket data ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _touristTickets = [
    {
      'id': 'hola-bcn-48',
      'name': 'Hola Barcelona 48h',
      'price': '17.50€',
      'priceValue': 17.50,
      'desc': 'Unlimited travel for 2 days including airport.',
      'badge': '⭐ Most Popular',
      'badgeColor': const Color(0xFFFEF3C7),
      'badgeFg': const Color(0xFF92400E),
      'color': const Color(0xFF0EA5E9),
      'lightColor': const Color(0xFFE0F2FE),
      'icon': '🏙️',
      'features': [
        'Metro, Bus, FGC, Tram',
        'Airport T1 & T2 included',
        'Starts on first validation',
        'No zones restriction'
      ],
      'ideal': 'Weekend trip (2 days)',
      'savingsVsSingle': '~30% vs single tickets',
    },
    {
      'id': 'hola-bcn-72',
      'name': 'Hola Barcelona 72h',
      'price': '25.50€',
      'priceValue': 25.50,
      'desc': 'Unlimited travel for 3 days including airport.',
      'badge': '🔥 Best Value',
      'badgeColor': const Color(0xFFFFEDD5),
      'badgeFg': const Color(0xFF9A3412),
      'color': const Color(0xFF6366F1),
      'lightColor': const Color(0xFFE0E7FF),
      'icon': '🗺️',
      'features': [
        'Metro, Bus, FGC, Tram',
        'Airport T1 & T2 included',
        'Valid 72h from first use',
        'Great for city explorers'
      ],
      'ideal': '3-day city break',
      'savingsVsSingle': '~40% vs single tickets',
    },
    {
      'id': 'hola-bcn-96',
      'name': 'Hola Barcelona 96h',
      'price': '33.30€',
      'priceValue': 33.30,
      'desc': 'Unlimited travel for 4 days including airport.',
      'badge': null,
      'color': const Color(0xFF8B5CF6),
      'lightColor': const Color(0xFFF3E8FF),
      'icon': '📅',
      'features': [
        'Metro, Bus, FGC, Tram',
        'Airport T1 & T2 included',
        'Valid 96h from first use',
        'Perfect for longer stays'
      ],
      'ideal': '4-day stay',
      'savingsVsSingle': '~45% vs single tickets',
    },
    {
      'id': 'hola-bcn-120',
      'name': 'Hola Barcelona 120h',
      'price': '40.80€',
      'priceValue': 40.80,
      'desc': 'Unlimited travel for 5 days including airport.',
      'badge': null,
      'color': const Color(0xFFEC4899),
      'lightColor': const Color(0xFFFCE7F3),
      'icon': '🎉',
      'features': [
        'Metro, Bus, FGC, Tram',
        'Airport T1 & T2 included',
        'Valid 120h from first use',
        'Best for 5-day holidays'
      ],
      'ideal': 'Full week trip',
      'savingsVsSingle': '~50% vs single tickets',
    },
  ];

  final List<Map<String, dynamic>> _standardTickets = [
    {
      'id': 't-casual',
      'name': 'T-Casual (10 trips)',
      'price': '12.15€',
      'priceValue': 12.15,
      'desc': 'Multi-use card for 10 one-way trips. Personal use only.',
      'badge': '🏠 Local Favourite',
      'badgeColor': const Color(0xFFD1FAE5),
      'badgeFg': const Color(0xFF065F46),
      'color': const Color(0xFF10B981),
      'lightColor': const Color(0xFFD1FAE5),
      'icon': '🎟️',
      'features': [
        '10 trips, Zone 1',
        '75-min transfer included',
        'Personal use (non-transferable)',
        'Valid on metro, bus, tram, FGC'
      ],
      'ideal': 'Short stays or locals',
      'savingsVsSingle': '52% cheaper than 10 singles',
    },
    {
      'id': 'single',
      'name': 'Billete Sencillo',
      'price': '2.55€',
      'priceValue': 2.55,
      'desc': 'Single one-way trip on metro, bus, or tram.',
      'badge': null,
      'color': const Color(0xFF64748B),
      'lightColor': const Color(0xFFF1F5F9),
      'icon': '🎫',
      'features': [
        'One trip, one zone',
        'No transfers included',
        'Valid for any line',
        'Great for one-off journeys'
      ],
      'ideal': 'Just one journey',
      'savingsVsSingle': 'No discount — pay-per-use',
    },
    {
      'id': 't-usual',
      'name': 'T-Usual (Monthly)',
      'price': '42.50€',
      'priceValue': 42.50,
      'desc': 'Unlimited monthly travel on all public transport.',
      'badge': '📆 Monthly Pass',
      'badgeColor': const Color(0xFFE0E7FF),
      'badgeFg': const Color(0xFF3730A3),
      'color': const Color(0xFF6366F1),
      'lightColor': const Color(0xFFE0E7FF),
      'icon': '🗓️',
      'features': [
        'Unlimited trips all month',
        'All zones within Barcelona',
        'Valid from 1st of month',
        'Metro, bus, FGC, tram, Rodalies'
      ],
      'ideal': 'Staying 1+ months',
      'savingsVsSingle': 'Unlimited for ~14 T-Casuals',
    },
    {
      'id': 't-dia',
      'name': 'T-Dia (Day Pass)',
      'price': '11.00€',
      'priceValue': 11.00,
      'desc': 'Unlimited travel in Zone 1 for one full calendar day.',
      'badge': null,
      'color': const Color(0xFFF59E0B),
      'lightColor': const Color(0xFFFEF3C7),
      'icon': '☀️',
      'features': [
        'Unlimited trips, 1 day',
        'Midnight to midnight',
        'Zone 1 only',
        'Good if you plan many trips'
      ],
      'ideal': '1-day intensive exploring',
      'savingsVsSingle': 'Worth it after 5 trips',
    },
  ];

  final List<Map<String, dynamic>> _specialTickets = [
    {
      'id': 'aerobus',
      'name': 'Aerobus Pass',
      'price': '6.75€',
      'priceValue': 6.75,
      'desc': 'Direct express bus between Airport T1/T2 and Plaça Catalunya.',
      'badge': '✈️ Airport Express',
      'badgeColor': const Color(0xFFE0F2FE),
      'badgeFg': const Color(0xFF075985),
      'color': const Color(0xFF0EA5E9),
      'lightColor': const Color(0xFFE0F2FE),
      'icon': '✈️',
      'features': [
        'Airport T1 & T2 direct',
        'Runs 24 hours',
        '~35 min to city centre',
        'Return ticket: 11.60€'
      ],
      'ideal': 'Fast airport transfer',
      'savingsVsSingle': 'Faster than Metro L9',
    },
    {
      'id': 'bus-turistic',
      'name': 'Bus Turístic',
      'price': '30.00€',
      'priceValue': 30.00,
      'desc': 'Hop-on/hop-off tourist bus covering all main attractions.',
      'badge': '🚌 Sightseeing',
      'badgeColor': const Color(0xFFFFEDD5),
      'badgeFg': const Color(0xFF9A3412),
      'color': const Color(0xFFEF4444),
      'lightColor': const Color(0xFFFEE2E2),
      'icon': '🚌',
      'features': [
        '3 routes: Red, Blue, Green',
        'Hop-on/hop-off',
        'Live audio guide',
        'Discounts at attractions'
      ],
      'ideal': 'First-time visitors',
      'savingsVsSingle': 'Includes attraction discounts',
    },
    {
      'id': 'funicular',
      'name': 'Funicular Montjuïc',
      'price': 'Included',
      'priceValue': 0,
      'desc': 'Funicular railway from Paral·lel metro to Montjuïc hill.',
      'badge': '🆓 Free with metro',
      'badgeColor': const Color(0xFFD1FAE5),
      'badgeFg': const Color(0xFF065F46),
      'color': const Color(0xFF10B981),
      'lightColor': const Color(0xFFD1FAE5),
      'icon': '🏰',
      'features': [
        'Free with any valid ticket',
        'From Paral·lel (L2/L3)',
        'Runs until midnight',
        'Access to castle & gardens'
      ],
      'ideal': 'Montjuïc day trip',
      'savingsVsSingle': 'No extra cost needed',
    },
    {
      'id': 'cable-car',
      'name': 'Cable Car (Aeri)',
      'price': '13.50€',
      'priceValue': 13.50,
      'desc': 'Panoramic cable car from Barceloneta beach to Montjuïc.',
      'badge': '🌊 Scenic Route',
      'badgeColor': const Color(0xFFE0F2FE),
      'badgeFg': const Color(0xFF075985),
      'color': const Color(0xFF0284C7),
      'lightColor': const Color(0xFFE0F2FE),
      'icon': '🚡',
      'features': [
        'Beach to hilltop views',
        'Panoramic gondola cabin',
        'Return ticket: 21.00€',
        'Seasonal — check schedules'
      ],
      'ideal': 'Scenic experience',
      'savingsVsSingle': 'Unique bird\'s-eye view',
    },
  ];

  List<Map<String, dynamic>> get _currentTickets {
    switch (_ticketCategory) {
      case 'tourist':
        return _touristTickets;
      case 'standard':
        return _standardTickets;
      case 'special':
        return _specialTickets;
      default:
        return _touristTickets;
    }
  }

  String _calculateTotal() {
    if (_selectedTicket == null) return '0.00€';
    final raw =
        (_selectedTicket!['price'] as String).replaceAll('€', '').trim();
    final unitPrice = double.tryParse(raw) ?? 0.0;
    final total = unitPrice * _ticketQuantity;
    return '${total.toStringAsFixed(2)}€';
  }

  void _onTabChanged(String newTab) {
    setState(() {
      _activeTab = newTab;
      _isBuying = false;
      _selectedTicket = null;
      _expandedInfo = null;
      _ticketQuantity = 1;
    });
  }

  void _toggleComparison(String id) {
    setState(() {
      if (_comparisonIds.contains(id)) {
        _comparisonIds.remove(id);
      } else if (_comparisonIds.length < 3) {
        _comparisonIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isBuying && _selectedTicket != null) {
      return _buildPurchaseScreen();
    }
    if (_showComparison && _comparisonIds.isNotEmpty) {
      return _buildComparisonScreen();
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

  // ════════════════════════════════════════════════════════════════════════════
  //  TICKETS TAB — EXPANDED
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTicketsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Smart recommender banner ────────────────────────────────────────
        _buildRecommenderBanner(),
        const SizedBox(height: 20),

        // ── Category picker ─────────────────────────────────────────────────
        _buildCategoryPicker(),
        const SizedBox(height: 20),

        // ── Comparison bar (shown when items selected) ──────────────────────
        if (_comparisonIds.isNotEmpty) ...[
          _buildComparisonBar(),
          const SizedBox(height: 12),
        ],

        // ── Section header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Text(
                _ticketCategory == 'tourist'
                    ? 'Tourist Passes'
                    : _ticketCategory == 'standard'
                        ? 'Standard Tickets'
                        : 'Special & Extras',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _comparisonIds.clear()),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Compare',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF64748B))),
                ),
              ),
            ],
          ),
        ),

        // ── Ticket cards ────────────────────────────────────────────────────
        ..._currentTickets.map((ticket) => _buildExpandedTicketCard(ticket)),

        // ── Price guide section ─────────────────────────────────────────────
        const SizedBox(height: 24),
        _buildPriceGuide(),

        // ── Where to buy ────────────────────────────────────────────────────
        const SizedBox(height: 20),
        _buildWhereToBuy(),

        // ── FAQ ─────────────────────────────────────────────────────────────
        const SizedBox(height: 20),
        _buildFAQ(),
      ],
    );
  }

  Widget _buildRecommenderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🤔', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Not sure which ticket?',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick rule of thumb:',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 8),
          _buildRuleRow('✈️', 'Arriving/leaving by airport?',
              'Hola BCN pass (includes L9)'),
          _buildRuleRow('📅', 'Staying 2–5 days?', 'Hola Barcelona 48h–120h'),
          _buildRuleRow('🏠', 'Living here short-term?', 'T-Casual (10 trips)'),
          _buildRuleRow('⚡', 'Just one journey?', 'Billete Sencillo'),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String emoji, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, height: 1.4),
                children: [
                  TextSpan(
                    text: '$question ',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: '→ $answer',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    final categories = [
      {'id': 'tourist', 'label': '🏙️ Tourist', 'sub': 'Passes'},
      {'id': 'standard', 'label': '🎟️ Standard', 'sub': 'Tickets'},
      {'id': 'special', 'label': '✨ Special', 'sub': 'Extras'},
    ];

    return Row(
      children: categories.map((cat) {
        final isActive = _ticketCategory == cat['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _ticketCategory = cat['id']!;
              _comparisonIds.clear();
            }),
            child: Container(
              margin: EdgeInsets.only(right: cat['id'] == 'special' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isActive
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    width: 2),
              ),
              child: Column(
                children: [
                  Text(cat['label']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF1E293B))),
                  Text(cat['sub']!,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: isActive
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B))),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonBar() {
    final allTickets = [
      ..._touristTickets,
      ..._standardTickets,
      ..._specialTickets
    ];
    final selected =
        allTickets.where((t) => _comparisonIds.contains(t['id'])).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Comparing:',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E40AF))),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: selected
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: (t['color'] as Color)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(t['name'],
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: t['color'] as Color)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          if (_comparisonIds.length >= 2)
            GestureDetector(
              onTap: () => setState(() => _showComparison = true),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12)),
                child: const Text('Compare →',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedTicketCard(Map<String, dynamic> ticket) {
    final inComparison = _comparisonIds.contains(ticket['id']);
    final features = ticket['features'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: inComparison
                ? (ticket['color'] as Color)
                : const Color(0xFFF1F5F9),
            width: inComparison ? 2.5 : 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ticket['color'],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: (ticket['color'] as Color)
                              .withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Center(
                      child: Text(ticket['icon'] ?? '🎟️',
                          style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ticket['badge'] != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: ticket['badgeColor'] ??
                                  const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(ticket['badge'],
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: ticket['badgeFg'] ??
                                      const Color(0xFF64748B))),
                        ),
                      Text(ticket['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Text(ticket['ideal'] ?? '',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(ticket['price'],
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1E293B))),
                    const Text('per person',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),

          // ── Features list ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: (ticket['lightColor'] as Color?) ??
                                const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 11, color: ticket['color'] as Color),
                            const SizedBox(width: 4),
                            Text(f,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: ticket['color'] as Color)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // ── Savings banner ────────────────────────────────────────────────
          if (ticket['savingsVsSingle'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0))),
                child: Row(
                  children: [
                    const Icon(Icons.savings_outlined,
                        size: 14, color: Color(0xFF16A34A)),
                    const SizedBox(width: 6),
                    Text(ticket['savingsVsSingle'],
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D))),
                  ],
                ),
              ),
            ),

          // ── Action row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Compare toggle
                GestureDetector(
                  onTap: () => _toggleComparison(ticket['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: inComparison
                            ? (ticket['color'] as Color).withValues(alpha: 0.12)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: inComparison
                            ? Border.all(
                                color: ticket['color'] as Color, width: 1.5)
                            : null),
                    child: Row(
                      children: [
                        Icon(
                            inComparison
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: inComparison
                                ? ticket['color'] as Color
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text('Compare',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: inComparison
                                    ? ticket['color'] as Color
                                    : const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Buy button
                Expanded(
                  child: GestureDetector(
                    onTap: (ticket['priceValue'] as double) == 0
                        ? null
                        : () => setState(() {
                              _selectedTicket = ticket;
                              _isBuying = true;
                            }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: (ticket['priceValue'] as double) == 0
                              ? const Color(0xFFF1F5F9)
                              : ticket['color'],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: (ticket['priceValue'] as double) == 0
                              ? null
                              : [
                                  BoxShadow(
                                      color: (ticket['color'] as Color)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3))
                                ]),
                      child: Center(
                        child: Text(
                            (ticket['priceValue'] as double) == 0
                                ? 'Free with metro ticket'
                                : 'Buy Now — ${ticket['price']}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: (ticket['priceValue'] as double) == 0
                                    ? const Color(0xFF64748B)
                                    : Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Price Guide ──────────────────────────────────────────────────────────
  Widget _buildPriceGuide() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💶', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Price at a Glance',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Single trip', '2.55€', const Color(0xFF64748B)),
          _buildPriceRow(
              'T-Casual (10 trips)', '1.22€/trip', const Color(0xFF10B981)),
          _buildPriceRow('T-Dia (day pass)', '11.00€', const Color(0xFFF59E0B)),
          _buildPriceRow('Hola BCN 48h', '17.50€', const Color(0xFF0EA5E9)),
          _buildPriceRow('Hola BCN 72h', '25.50€', const Color(0xFF6366F1)),
          _buildPriceRow('Hola BCN 96h', '33.30€', const Color(0xFF8B5CF6)),
          _buildPriceRow('Hola BCN 120h', '40.80€', const Color(0xFFEC4899)),
          _buildPriceRow(
              'T-Usual (monthly)', '42.50€', const Color(0xFF6366F1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: const Text(
                '💡 Children under 4 travel free. Reduced fare available for ages 4–12 and seniors 65+.',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569))),
          )
        ],
      ),
    );
  }

  Widget _buildPriceRow(String name, String price, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569)))),
          Text(price,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  // ── Where to Buy ─────────────────────────────────────────────────────────
  Widget _buildWhereToBuy() {
    final places = [
      {
        'icon': '🏧',
        'name': 'Station Machines',
        'desc': 'Red machines at every metro entrance. Accept card & cash.',
        'color': const Color(0xFFEF4444),
      },
      {
        'icon': '📱',
        'name': 'TMB App',
        'desc': 'Buy and store digital tickets. Works offline on metro.',
        'color': const Color(0xFF0EA5E9),
      },
      {
        'icon': '🖥️',
        'name': 'TMB Website',
        'desc': 'tmb.cat — order in advance and collect at machines.',
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': '🏪',
        'name': 'Tobacco Shops',
        'desc': 'Estancs / quioscos often sell T-Casual and single tickets.',
        'color': const Color(0xFF10B981),
      },
    ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🛍️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Where to Buy',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          ...places.map((p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: (p['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text(p['icon'] as String,
                              style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(height: 2),
                          Text(p['desc'] as String,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                  height: 1.3)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── FAQ ───────────────────────────────────────────────────────────────────
  Widget _buildFAQ() {
    final faqs = [
      {
        'q': 'Can I share a T-Casual between two people?',
        'a':
            'No — the T-Casual is personal and non-transferable. The Hola BCN passes are also personal.',
      },
      {
        'q': 'Does Hola Barcelona cover the airport?',
        'a':
            'Yes! All Hola Barcelona passes include the Metro L9 Sud to airport T1 and T2 — no extra charge.',
      },
      {
        'q': 'Is the Aerobus included in the Hola BCN pass?',
        'a':
            'No. The Aerobus is a private service and requires a separate ticket, even with a Hola BCN pass.',
      },
      {
        'q': 'Can I use contactless payment on the metro gates?',
        'a':
            'Yes — you can tap your bank card or phone directly at the gate for a single trip at 2.55€.',
      },
      {
        'q': 'What happens if my T-Casual runs out mid-journey?',
        'a':
            'You\'ll need to buy a new ticket. The gate won\'t let you through with 0 trips remaining.',
      },
    ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('❓', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('FAQ',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 16),
          ...faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(faq['q']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Text(faq['a']!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            height: 1.5)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Side-by-side Comparison Screen ──────────────────────────────────────
  Widget _buildComparisonScreen() {
    final allTickets = [
      ..._touristTickets,
      ..._standardTickets,
      ..._specialTickets
    ];
    final selected =
        allTickets.where((t) => _comparisonIds.contains(t['id'])).toList();
    final fields = ['Price', 'Ideal for', 'Savings'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showComparison = false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back,
                      size: 18, color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Comparison',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header row
                  Row(
                    children: [
                      const SizedBox(width: 80),
                      ...selected.map((t) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: t['color'],
                                  borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: [
                                  Text(t['icon'] ?? '🎟️',
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(height: 4),
                                  Text(t['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Data rows
                  _buildComparisonRow('Price',
                      selected.map((t) => t['price'] as String).toList()),
                  _buildComparisonRow(
                      'Best for',
                      selected
                          .map((t) => (t['ideal'] ?? '—') as String)
                          .toList()),
                  _buildComparisonRow(
                      'Savings',
                      selected
                          .map((t) => (t['savingsVsSingle'] ?? '—') as String)
                          .toList()),
                  const SizedBox(height: 12),
                  // Features comparison
                  ...List.generate(4, (fi) {
                    return _buildComparisonRow(
                      'Feature ${fi + 1}',
                      selected.map((t) {
                        final feats = t['features'] as List<String>;
                        return fi < feats.length ? feats[fi] : '—';
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),
                  // Buy buttons
                  Row(
                    children: [
                      const SizedBox(width: 88),
                      ...selected.map((t) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: GestureDetector(
                                onTap: (t['priceValue'] as double) == 0
                                    ? null
                                    : () => setState(() {
                                          _selectedTicket = t;
                                          _isBuying = true;
                                          _showComparison = false;
                                        }),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      color: t['color'],
                                      borderRadius: BorderRadius.circular(12)),
                                  child: const Center(
                                    child: Text('Buy',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, List<String> values) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8))),
          ),
          ...values.map((v) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(v,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B))),
                ),
              )),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  PURCHASE SCREEN
  // ════════════════════════════════════════════════════════════════════════════

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
                  child: Center(
                    child: Text(
                      _selectedTicket!['icon'] ?? '🎟️',
                      style: const TextStyle(fontSize: 30),
                    ),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Quantity selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cantidad',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B))),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_ticketQuantity > 1)
                                setState(() => _ticketQuantity--);
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
                              child: Icon(Icons.remove,
                                  size: 18,
                                  color: _ticketQuantity > 1
                                      ? Colors.white
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text('$_ticketQuantity',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E293B))),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_ticketQuantity < 10)
                                setState(() => _ticketQuantity++);
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
                              child: Icon(Icons.add,
                                  size: 18,
                                  color: _ticketQuantity < 10
                                      ? Colors.white
                                      : const Color(0xFF94A3B8)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Precio unitario',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B))),
                          Text(_selectedTicket!['price'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B))),
                        ],
                      ),
                      if (_ticketQuantity > 1) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('x$_ticketQuantity billetes',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B))),
                            const Icon(Icons.calculate_outlined,
                                size: 16, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total a pagar',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B))),
                          Text(_calculateTotal(),
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E293B))),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isBuying = false;
                            _selectedTicket = null;
                            _ticketQuantity = 1;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF64748B),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancelar',
                            style: TextStyle(fontWeight: FontWeight.w700)),
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
                                  '¡$_ticketQuantity billete(s) comprado(s)! Disponibles en tu perfil.'),
                            ),
                          );
                          setState(() {
                            _isBuying = false;
                            _selectedTicket = null;
                            _ticketQuantity = 1;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _selectedTicket!['color'],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.credit_card, size: 18),
                            SizedBox(width: 8),
                            Text('Pagar',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 16)),
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

  // ════════════════════════════════════════════════════════════════════════════
  //  ROUTES TAB (unchanged)
  // ════════════════════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════════════════════
  //  GUIDE TAB (unchanged)
  // ════════════════════════════════════════════════════════════════════════════

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
            'Encontrarás máquinas rojas en todas las estaciones de metro. Puedes cambiar el idioma a inglés o francés en la pantalla inicial.',
            style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
                fontSize: 14,
                height: 1.5)),
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
                      ' para cambiar de medio de transporte sin coste adicional.'),
            ])),
        const SizedBox(height: 12),
        const Text(
            '⚠️ No puedes salir del metro y volver a entrar con el mismo viaje.',
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
        const Text(
            'Use the Medios tab to explore all transport options in detail.',
            style: TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w500,
                fontSize: 14)),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  INFO TAB (unchanged)
  // ════════════════════════════════════════════════════════════════════════════

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
