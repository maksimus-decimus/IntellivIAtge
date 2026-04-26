import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/app_constants.dart';
import '../models/types.dart';
import 'dart:ui' as ui;

// ─────────────────────────────────────────────────────────────────────────────
//  Custom Painters (used by the routes map UI)
// ─────────────────────────────────────────────────────────────────────────────

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashHeight = 6.0;
    const dashGap = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TransportScreen
// ─────────────────────────────────────────────────────────────────────────────

class TransportScreen extends StatefulWidget {
  const TransportScreen({Key? key}) : super(key: key);

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  // ── General tab state ──────────────────────────────────────────────────────
  String _activeTab = 'guide';
  String? _expandedInfo;
  bool _isBuying = false;
  Map<String, dynamic>? _selectedTicket;
  int _ticketQuantity = 1;
  String _infoSearchQuery = '';

  // ── Ticket section state ───────────────────────────────────────────────────
  String _ticketCategory = 'tourist';
  bool _showComparison = false;
  Set<String> _comparisonIds = {};

  // ── Routes / Map state ─────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  LatLng? _destinationLocation;
  String _originText = '';
  String _destinationText = '';
  bool _isLocating = false;
  bool _mapExpanded = false;
  String? _selectedMode;
  int _routeTabIndex = 0; // 0=search, 1=nearby, 2=saved

  // ── Line color lookup ──────────────────────────────────────────────────────
  static const Map<String, Color> _lineColors = {
    'L1': Color(0xFFE3000B),
    'L2': Color(0xFF7B1FA2),
    'L3': Color(0xFF007F41),
    'L4': Color(0xFFFFD700),
    'L5': Color(0xFF003F8A),
    'L9S': Color(0xFFE87722),
    'L10N': Color(0xFF009FE3),
    'H6': Color(0xFF10B981),
    'H10': Color(0xFF10B981),
    '24': Color(0xFF6366F1),
    'N4': Color(0xFF1E293B),
    'R1': Color(0xFFE3000B),
    'R2': Color(0xFF007F41),
  };

  // ── Nearby stops ───────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _nearbyStops = [
    {
      'name': 'Passeig de Gràcia',
      'lines': ['L2', 'L3', 'L4'],
      'dist': '180m',
      'emoji': '🚇',
      'lat': 41.3916,
      'lng': 2.1650,
    },
    {
      'name': 'Diagonal',
      'lines': ['L3', 'L5'],
      'dist': '420m',
      'emoji': '🚇',
      'lat': 41.3936,
      'lng': 2.1622,
    },
    {
      'name': 'Gràcia Bus Stop',
      'lines': ['H6', '24'],
      'dist': '95m',
      'emoji': '🚌',
      'lat': 41.3918,
      'lng': 2.1660,
    },
    {
      'name': 'Verdaguer',
      'lines': ['L4', 'L5'],
      'dist': '610m',
      'emoji': '🚇',
      'lat': 41.3958,
      'lng': 2.1639,
    },
  ];

  // ── Saved routes ───────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _savedRoutes = [
    {
      'from': 'Home',
      'to': 'Sagrada Família',
      'mode': 'metro',
      'time': '12 min',
      'emoji': '⛪',
      'destLat': 41.4036,
      'destLng': 2.1744,
    },
    {
      'from': 'Hotel Arts',
      'to': 'Camp Nou',
      'mode': 'bus',
      'time': '28 min',
      'emoji': '🏟️',
      'destLat': 41.3809,
      'destLng': 2.1228,
    },
  ];

  // ── Metro stations for map markers ─────────────────────────────────────────
  static const List<Map<String, dynamic>> _metroStations = [
    {'name': 'Passeig de Gràcia', 'lat': 41.3916, 'lng': 2.1650, 'line': 'L3'},
    {'name': 'Diagonal', 'lat': 41.3936, 'lng': 2.1622, 'line': 'L5'},
    {'name': 'Sagrada Família', 'lat': 41.4036, 'lng': 2.1744, 'line': 'L5'},
    {'name': 'Barceloneta', 'lat': 41.3806, 'lng': 2.1873, 'line': 'L4'},
    {'name': 'Liceu', 'lat': 41.3818, 'lng': 2.1730, 'line': 'L3'},
    {'name': 'Universitat', 'lat': 41.3872, 'lng': 2.1639, 'line': 'L1'},
    {'name': 'Verdaguer', 'lat': 41.3958, 'lng': 2.1639, 'line': 'L4'},
    {'name': 'Paral·lel', 'lat': 41.3759, 'lng': 2.1668, 'line': 'L2'},
    {'name': 'Jaume I', 'lat': 41.3832, 'lng': 2.1776, 'line': 'L4'},
    {'name': 'Catalunya', 'lat': 41.3871, 'lng': 2.1700, 'line': 'L1'},
  ];

  // ── Popular destinations ───────────────────────────────────────────────────
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

  // ── Ticket data ────────────────────────────────────────────────────────────
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
      'savingsVsSingle': "Unique bird's-eye view",
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

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _calculateTotal() {
    if (_selectedTicket == null) return '0.00€';
    final raw =
        (_selectedTicket!['price'] as String).replaceAll('€', '').trim();
    final unitPrice = double.tryParse(raw) ?? 0.0;
    return '${(unitPrice * _ticketQuantity).toStringAsFixed(2)}€';
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

  // ════════════════════════════════════════════════════════════════════════════
  //  MAP / LOCATION HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> _locateUser() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied)
          throw Exception('Permission denied');
      }
      if (permission == LocationPermission.deniedForever)
        throw Exception('Permission permanently denied');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLocating = false;
      });
      _mapController.move(_userLocation!, 15);
    } catch (_) {
      // Fallback to Barcelona city centre for demo
      setState(() {
        _userLocation = const LatLng(41.3851, 2.1734);
        _isLocating = false;
      });
      _mapController.move(const LatLng(41.3851, 2.1734), 15);
    }
  }

  void _searchRoute() {
    if (_destinationLocation == null) {
      setState(() => _destinationLocation = const LatLng(41.4036, 2.1744));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.route, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Calculando la mejor ruta...'),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<Marker> _buildMetroMarkers() {
    return _metroStations.map((s) {
      final color = _lineColors[s['line'] as String] ?? const Color(0xFF6366F1);
      return Marker(
        point: LatLng(s['lat'] as double, s['lng'] as double),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${s['name']} — ${s['line']}'),
                backgroundColor: color,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.45), blurRadius: 6)
                  ],
                ),
                child: Center(
                  child: Text(
                    (s['line'] as String).replaceAll('L', ''),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              Container(width: 2, height: 6, color: color),
            ],
          ),
        ),
      );
    }).toList();
  }

  Marker _buildUserMarker() {
    return Marker(
      point: _userLocation!,
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.5),
                    blurRadius: 8)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildDestinationMarker() {
    return Marker(
      point: _destinationLocation!,
      width: 40,
      height: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFEC4899).withOpacity(0.5),
                    blurRadius: 8)
              ],
            ),
            child: const Icon(Icons.place, color: Colors.white, size: 18),
          ),
          CustomPaint(
            painter: const _TrianglePainter(color: Color(0xFFEC4899)),
            size: const Size(12, 8),
          ),
        ],
      ),
    );
  }

  List<LatLng> _buildRoutePath(LatLng origin, LatLng dest) {
    final mid = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2 + 0.003,
    );
    return [origin, mid, dest];
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isBuying && _selectedTicket != null) return _buildPurchaseScreen();
    if (_showComparison && _comparisonIds.isNotEmpty)
      return _buildComparisonScreen();

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

  // ── Tab bar ────────────────────────────────────────────────────────────────
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
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
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
  //  ROUTES TAB — Enhanced with flutter_map
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildRoutesTab() {
    return Column(
      children: [
        _buildRouteSubTabs(),
        const SizedBox(height: 16),
        if (_routeTabIndex == 0) _buildRouteSearch(),
        if (_routeTabIndex == 1) _buildNearbyStops(),
        if (_routeTabIndex == 2) _buildSavedRoutes(),
      ],
    );
  }

  // ── Sub-tab bar ────────────────────────────────────────────────────────────
  Widget _buildRouteSubTabs() {
    final tabs = [
      {'label': '🔍 Buscar', 'idx': 0},
      {'label': '📍 Cercanos', 'idx': 1},
      {'label': '⭐ Guardados', 'idx': 2},
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: tabs.map((t) {
          final active = _routeTabIndex == t['idx'];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _routeTabIndex = t['idx'] as int),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    t['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: active
                          ? const Color(0xFF1E293B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Search sub-tab ─────────────────────────────────────────────────────────
  Widget _buildRouteSearch() {
    return Column(
      children: [
        // Input card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Origin + destination inputs
              Stack(
                children: [
                  Positioned(
                    left: 15,
                    top: 36,
                    bottom: 36,
                    child: CustomPaint(
                      painter:
                          const _DashedLinePainter(color: Color(0xFFCBD5E1)),
                      size: const Size(2, double.infinity),
                    ),
                  ),
                  Column(
                    children: [
                      _buildStyledLocationInput(
                        hint: 'Mi ubicación actual',
                        dotColor: const Color(0xFF0EA5E9),
                        icon: Icons.my_location,
                        trailing: GestureDetector(
                          onTap: _locateUser,
                          child: _isLocating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xFF0EA5E9)),
                                )
                              : const Icon(Icons.gps_fixed,
                                  size: 18, color: Color(0xFF0EA5E9)),
                        ),
                        onChanged: (v) => setState(() => _originText = v),
                      ),
                      const SizedBox(height: 12),
                      _buildStyledLocationInput(
                        hint: '¿A dónde quieres ir?',
                        dotColor: const Color(0xFFEC4899),
                        icon: Icons.place,
                        onChanged: (v) => setState(() => _destinationText = v),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTransportModeSelector(),
              const SizedBox(height: 16),
              // Search button
              GestureDetector(
                onTap: _searchRoute,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF1E293B).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Calcular Ruta',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInteractiveMap(),
        const SizedBox(height: 16),
        _buildQuickDestinations(),
      ],
    );
  }

  // ── Styled location input ──────────────────────────────────────────────────
  Widget _buildStyledLocationInput({
    required String hint,
    required Color dotColor,
    required IconData icon,
    required ValueChanged<String> onChanged,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2.5),
          ),
          child: Icon(icon, size: 14, color: dotColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      isDense: true,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Transport mode selector ────────────────────────────────────────────────
  Widget _buildTransportModeSelector() {
    final modes = [
      {
        'id': 'metro',
        'icon': '🚇',
        'label': 'Metro',
        'time': '~12 min',
        'color': const Color(0xFF6366F1)
      },
      {
        'id': 'bus',
        'icon': '🚌',
        'label': 'Bus',
        'time': '~18 min',
        'color': const Color(0xFF10B981)
      },
      {
        'id': 'walk',
        'icon': '🚶',
        'label': 'A pie',
        'time': '~35 min',
        'color': const Color(0xFFF59E0B)
      },
      {
        'id': 'bike',
        'icon': '🚲',
        'label': 'Bicing',
        'time': '~20 min',
        'color': const Color(0xFFEF4444)
      },
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modo de transporte',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Row(
          children: modes.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isSelected = _selectedMode == m['id'];
            final color = m['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedMode = m['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i < modes.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.12)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(m['icon'] as String,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 3),
                      Text(m['label'] as String,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? color
                                  : const Color(0xFF64748B))),
                      Text(m['time'] as String,
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? color.withOpacity(0.7)
                                  : const Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Interactive Map ────────────────────────────────────────────────────────
  Widget _buildInteractiveMap() {
    const defaultCenter = LatLng(41.3851, 2.1734);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: _mapExpanded ? 420 : 270,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userLocation ?? defaultCenter,
                initialZoom: 14.5,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.all),
                onTap: (tapPosition, point) {
                  setState(() => _destinationLocation = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.example.barcelonatransport',
                  retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                ),
                // Route polyline
                if (_userLocation != null && _destinationLocation != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _buildRoutePath(
                            _userLocation!, _destinationLocation!),
                        color: const Color(0xFF6366F1),
                        strokeWidth: 4.5,
                      ),
                    ],
                  ),
                // Markers
                MarkerLayer(
                  markers: [
                    ..._buildMetroMarkers(),
                    if (_userLocation != null) _buildUserMarker(),
                    if (_destinationLocation != null) _buildDestinationMarker(),
                  ],
                ),
              ],
            ),
          ),

          // Expand/collapse + zoom controls (top-right)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _buildMapControlBtn(
                  icon: _mapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                  onTap: () => setState(() => _mapExpanded = !_mapExpanded),
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.add,
                  onTap: () => _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom + 1),
                ),
                const SizedBox(height: 4),
                _buildMapControlBtn(
                  icon: Icons.remove,
                  onTap: () => _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom - 1),
                ),
                const SizedBox(height: 8),
                _buildMapControlBtn(
                  icon: Icons.my_location,
                  onTap: _locateUser,
                  iconColor: const Color(0xFF0EA5E9),
                ),
              ],
            ),
          ),

          // "Tap to set destination" hint (top-left)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08), blurRadius: 6)
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 12, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text('Toca el mapa para marcar destino',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569))),
                ],
              ),
            ),
          ),

          // Layer toggle pills (bottom-left)
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildMapLayerPills(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn(
      {required IconData icon, required VoidCallback onTap, Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child:
            Icon(icon, size: 18, color: iconColor ?? const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _buildMapLayerPills() {
    final layers = [
      {'label': '🚇 Metro', 'active': true},
      {'label': '🚌 Bus', 'active': false},
      {'label': '🚲 Bicing', 'active': false},
    ];
    return Row(
      children: layers.map((l) {
        final active = l['active'] as bool;
        return Container(
          margin: const EdgeInsets.only(right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF1E293B)
                : Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)
            ],
          ),
          child: Text(
            l['label'] as String,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : const Color(0xFF475569),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Quick destination chips ────────────────────────────────────────────────
  Widget _buildQuickDestinations() {
    final dests = [
      {'name': 'Sagrada Família', 'emoji': '⛪', 'lat': 41.4036, 'lng': 2.1744},
      {'name': 'Park Güell', 'emoji': '🌿', 'lat': 41.4145, 'lng': 2.1527},
      {'name': 'Barceloneta', 'emoji': '🏖️', 'lat': 41.3793, 'lng': 2.1899},
      {'name': 'Camp Nou', 'emoji': '🏟️', 'lat': 41.3809, 'lng': 2.1228},
      {'name': 'La Boqueria', 'emoji': '🛒', 'lat': 41.3820, 'lng': 2.1726},
      {'name': 'Montjuïc', 'emoji': '🏰', 'lat': 41.3643, 'lng': 2.1595},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text('Destinos rápidos',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dests.map((d) {
              return GestureDetector(
                onTap: () {
                  final loc = LatLng(d['lat'] as double, d['lng'] as double);
                  setState(() => _destinationLocation = loc);
                  _mapController.move(loc, 14);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(d['emoji'] as String,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(d['name'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Nearby stops sub-tab ───────────────────────────────────────────────────
  Widget _buildNearbyStops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini map
        Container(
          height: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation ?? const LatLng(41.3851, 2.1734),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.barcelonatransport',
              ),
              MarkerLayer(markers: _buildMetroMarkers()),
              if (_userLocation != null)
                MarkerLayer(markers: [_buildUserMarker()]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Paradas cercanas',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B))),
            const Spacer(),
            GestureDetector(
              onTap: _locateUser,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _isLocating
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF0EA5E9)),
                          )
                        : const Icon(Icons.refresh,
                            size: 14, color: Color(0xFF0EA5E9)),
                    const SizedBox(width: 4),
                    const Text('Actualizar',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0EA5E9))),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._nearbyStops.map((stop) => _buildNearbyStopCard(stop)),
      ],
    );
  }

  Widget _buildNearbyStopCard(Map<String, dynamic> stop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(stop['emoji'] as String,
                    style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop['name'] as String,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: (stop['lines'] as List<String>).map((l) {
                    final c = _lineColors[l] ?? const Color(0xFF6366F1);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: c.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(l,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: c)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(stop['dist'] as String,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A))),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _destinationLocation =
                        LatLng(stop['lat'] as double, stop['lng'] as double);
                    _routeTabIndex = 0;
                  });
                },
                child: const Text('Ir →',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF6366F1))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Saved routes sub-tab ───────────────────────────────────────────────────
  Widget _buildSavedRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_savedRoutes.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            ),
            child: const Center(
              child: Column(children: [
                Text('⭐', style: TextStyle(fontSize: 36)),
                SizedBox(height: 12),
                Text('Sin rutas guardadas',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF1E293B))),
                SizedBox(height: 4),
                Text('Busca una ruta y guárdala aquí.',
                    style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ]),
            ),
          )
        else ...[
          const Text('Rutas guardadas',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          ..._savedRoutes.map((r) => _buildSavedRouteCard(r)),
        ],
      ],
    );
  }

  Widget _buildSavedRouteCard(Map<String, dynamic> route) {
    final modeColors = {
      'metro': const Color(0xFF6366F1),
      'bus': const Color(0xFF10B981),
      'walk': const Color(0xFFF59E0B),
      'bike': const Color(0xFFEF4444),
    };
    final color =
        modeColors[route['mode'] as String] ?? const Color(0xFF6366F1);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Text(route['emoji'] as String, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(route['from'] as String,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward,
                          size: 12, color: Color(0xFF94A3B8)),
                    ),
                    Flexible(
                      child: Text(route['to'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(route['mode'] as String,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: color)),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.timer_outlined,
                        size: 12, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 3),
                    Text(route['time'] as String,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _destinationLocation = LatLng(
                    route['destLat'] as double, route['destLng'] as double);
                _routeTabIndex = 0;
              });
              _mapController.move(
                  LatLng(
                      route['destLat'] as double, route['destLng'] as double),
                  14);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(12)),
              child: const Text('Ir →',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  TICKETS TAB
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildTicketsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecommenderBanner(),
        const SizedBox(height: 20),
        _buildCategoryPicker(),
        const SizedBox(height: 20),
        if (_comparisonIds.isNotEmpty) ...[
          _buildComparisonBar(),
          const SizedBox(height: 12),
        ],
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
        ..._currentTickets.map((ticket) => _buildExpandedTicketCard(ticket)),
        const SizedBox(height: 24),
        _buildPriceGuide(),
        const SizedBox(height: 20),
        _buildWhereToBuy(),
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
          const Row(children: [
            Text('🤔', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Not sure which ticket?',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.white)),
          ]),
          const SizedBox(height: 8),
          const Text('Quick rule of thumb:',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFF94A3B8))),
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
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600)),
                  TextSpan(
                      text: '→ $answer',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900)),
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
      children: categories.asMap().entries.map((entry) {
        final i = entry.key;
        final cat = entry.value;
        final isActive = _ticketCategory == cat['id'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _ticketCategory = cat['id']!;
              _comparisonIds.clear();
            }),
            child: Container(
              margin: EdgeInsets.only(right: i < categories.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  width: 2,
                ),
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
                                color: (t['color'] as Color).withOpacity(0.15),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                          color: (ticket['color'] as Color).withOpacity(0.25),
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
          // Features
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
          // Savings
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
          // Action row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleComparison(ticket['id']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: inComparison
                            ? (ticket['color'] as Color).withOpacity(0.12)
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
                                          .withOpacity(0.3),
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
                                  : Colors.white),
                        ),
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

  Widget _buildPriceGuide() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('💶', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Price at a Glance',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B))),
          ]),
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
          ),
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

  Widget _buildWhereToBuy() {
    final places = [
      {
        'icon': '🏧',
        'name': 'Station Machines',
        'desc': 'Red machines at every metro entrance. Accept card & cash.',
        'color': const Color(0xFFEF4444)
      },
      {
        'icon': '📱',
        'name': 'TMB App',
        'desc': 'Buy and store digital tickets. Works offline on metro.',
        'color': const Color(0xFF0EA5E9)
      },
      {
        'icon': '🖥️',
        'name': 'TMB Website',
        'desc': 'tmb.cat — order in advance and collect at machines.',
        'color': const Color(0xFF6366F1)
      },
      {
        'icon': '🏪',
        'name': 'Tobacco Shops',
        'desc': 'Estancs / quioscos often sell T-Casual and single tickets.',
        'color': const Color(0xFF10B981)
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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('🛍️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Where to Buy',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B))),
          ]),
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
                          color: (p['color'] as Color).withOpacity(0.12),
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

  Widget _buildFAQ() {
    final faqs = [
      {
        'q': 'Can I share a T-Casual between two people?',
        'a':
            'No — the T-Casual is personal and non-transferable. The Hola BCN passes are also personal.'
      },
      {
        'q': 'Does Hola Barcelona cover the airport?',
        'a':
            'Yes! All Hola Barcelona passes include the Metro L9 Sud to airport T1 and T2 — no extra charge.'
      },
      {
        'q': 'Is the Aerobus included in the Hola BCN pass?',
        'a':
            'No. The Aerobus is a private service and requires a separate ticket, even with a Hola BCN pass.'
      },
      {
        'q': 'Can I use contactless payment on the metro gates?',
        'a':
            'Yes — you can tap your bank card or phone directly at the gate for a single trip at 2.55€.'
      },
      {
        'q': "What happens if my T-Casual runs out mid-journey?",
        'a':
            "You'll need to buy a new ticket. The gate won't let you through with 0 trips remaining."
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
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Text('❓', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('FAQ',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B))),
          ]),
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

  // ════════════════════════════════════════════════════════════════════════════
  //  COMPARISON SCREEN
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildComparisonScreen() {
    final allTickets = [
      ..._touristTickets,
      ..._standardTickets,
      ..._specialTickets
    ];
    final selected =
        allTickets.where((t) => _comparisonIds.contains(t['id'])).toList();
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
                  ...List.generate(
                      4,
                      (fi) => _buildComparisonRow(
                            'Feature ${fi + 1}',
                            selected.map((t) {
                              final feats = t['features'] as List<String>;
                              return fi < feats.length ? feats[fi] : '—';
                            }).toList(),
                          )),
                  const SizedBox(height: 20),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8))
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
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Center(
                      child: Text(_selectedTicket!['icon'] ?? '🎟️',
                          style: const TextStyle(fontSize: 30))),
                ),
                const SizedBox(height: 12),
                Text(_selectedTicket!['name'],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E293B)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(_selectedTicket!['desc'],
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                // Quantity
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0))),
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
                                  borderRadius: BorderRadius.circular(10)),
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
                                  borderRadius: BorderRadius.circular(10)),
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
                      border: Border.all(color: const Color(0xFFE2E8F0))),
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
                        onPressed: () => setState(() {
                          _isBuying = false;
                          _selectedTicket = null;
                          _ticketQuantity = 1;
                        }),
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
                                    '¡$_ticketQuantity billete(s) comprado(s)! Disponibles en tu perfil.')),
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
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
  //  GUIDE TAB
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
        _buildGuideStep(
          step: '1',
          bgColor: const Color(0xFFFEE2E2),
          numColor: const Color(0xFFDC2626),
          title: 'Comprar en las Máquinas',
          body:
              'Encontrarás máquinas rojas en todas las estaciones de metro. Puedes cambiar el idioma a inglés o francés en la pantalla inicial.',
          checks: const [
            'Aceptan tarjeta (contactless) y efectivo.',
            'Los billetes turísticos (Hola BCN) son la mejor opción.',
          ],
        ),
        const SizedBox(height: 16),
        _buildGuideStep(
          step: '2',
          bgColor: const Color(0xFFDBEAFE),
          numColor: const Color(0xFF2563EB),
          title: 'Los Tornos (Pasadores)',
          body:
              'Para entrar al metro o tren, debes validar tu billete. En el bus, la validadora está justo al subir.',
        ),
        const SizedBox(height: 16),
        _buildGuideStep(
          step: '3',
          bgColor: const Color(0xFFD1FAE5),
          numColor: const Color(0xFF059669),
          title: 'Transbordos Gratuitos',
          richBody: const [
            TextSpan(text: 'Con billetes como la T-Casual, tienes '),
            TextSpan(
                text: '1 hora y 15 minutos',
                style: TextStyle(fontWeight: FontWeight.w900)),
            TextSpan(
                text:
                    ' para cambiar de medio de transporte sin coste adicional.'),
          ],
          footer:
              '⚠️ No puedes salir del metro y volver a entrar con el mismo viaje.',
        ),
        const SizedBox(height: 16),
        _buildGuideStep(
          step: '4',
          bgColor: const Color(0xFFE9D5FF),
          numColor: const Color(0xFF9333EA),
          title: 'Conoce tus opciones',
          body:
              'Use the Medios tab to explore all transport options in detail.',
        ),
      ],
    );
  }

  Widget _buildGuideStep({
    required String step,
    required Color bgColor,
    required Color numColor,
    required String title,
    String? body,
    List<InlineSpan>? richBody,
    List<String>? checks,
    String? footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: bgColor, borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: Text(step,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: numColor))),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B)))),
            ],
          ),
          const SizedBox(height: 12),
          if (richBody != null)
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.5),
                children: richBody,
              ),
            )
          else if (body != null)
            Text(body,
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.5)),
          if (checks != null) ...[
            const SizedBox(height: 16),
            ...checks.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(c,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B)))),
                    ],
                  ),
                )),
          ],
          if (footer != null) ...[
            const SizedBox(height: 12),
            Text(footer,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569))),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  INFO TAB
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
        // Search field
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
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
                          color: Color(0xFF94A3B8), size: 18))
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        // Popular destinations carousel
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(dest['emoji'],
                      style: const TextStyle(fontSize: 18))),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
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
                        color: Color(0xFF64748B)))),
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
                        color: Color(0xFF94A3B8)))),
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
    const extraDetails = {
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
          Color(0xFFE3000B),
          Color(0xFF7B1FA2),
          Color(0xFF007F41),
          Color(0xFFFFD700),
          Color(0xFF003F8A),
          Color(0xFFE87722),
          Color(0xFFE87722),
          Color(0xFF009FE3),
          Color(0xFF009FE3),
          Color(0xFF009FE3),
        ],
        'hours':
            'Mon–Thu & Sun: 5am–12am\nFri: 5am–2am\nSat & eves of holidays: 24h',
        'frequency': 'Every 3–6 min (peak) / 6–10 min (off-peak)',
        'zones': 'Zone 1 covers all of Barcelona city',
      },
      'bus': {
        'lines': ['H6', 'H10', 'H16', 'V7', 'V13', 'V17', '24', 'N4'],
        'lineColors': [
          Color(0xFF10B981),
          Color(0xFF10B981),
          Color(0xFF10B981),
          Color(0xFF0EA5E9),
          Color(0xFF0EA5E9),
          Color(0xFF0EA5E9),
          Color(0xFF6366F1),
          Color(0xFF1E293B),
        ],
        'hours': 'Most lines: 5am–11pm\nNit Bus (N lines): 10:30pm–5am',
        'frequency': 'Every 6–12 min on main routes',
        'zones': 'Same zone system as metro — T-Casual valid',
      },
      'fgc': {
        'lines': ['S1', 'S2', 'S5', 'S55', 'L6', 'L7', 'R5', 'R6'],
        'lineColors': [
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
          Color(0xFF8B5CF6),
          Color(0xFFEC4899),
          Color(0xFFEC4899),
        ],
        'hours': 'Mon–Thu: 5am–12am\nFri–Sat: 5am–2am\nSun: 6am–12am',
        'frequency': 'Every 6–15 min depending on line',
        'zones': 'Connects to Zone 2+ suburbs (Tibidabo, Montserrat)',
      },
      'rodalies': {
        'lines': ['R1', 'R2', 'R3', 'R4', 'R7', 'R10', 'R11', 'R12'],
        'lineColors': [
          Color(0xFFE3000B),
          Color(0xFF007F41),
          Color(0xFFFFD700),
          Color(0xFF003F8A),
          Color(0xFF6366F1),
          Color(0xFF0EA5E9),
          Color(0xFFEC4899),
          Color(0xFF10B981),
        ],
        'hours': 'Approx. 5am–11:30pm (varies by line)',
        'frequency': 'Every 15–30 min',
        'zones': 'Multi-zone — check before boarding',
      },
    };

    final extra = extraDetails[opt.id];

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
                  children:
                      List.generate((extra['lines']! as List).length, (i) {
                    final c = (extra['lineColors']! as List<Color>)[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: c.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: c.withOpacity(0.4))),
                      child: Text((extra['lines']! as List)[i],
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: c)),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _buildInfoBox(
                    icon: Icons.access_time,
                    color: const Color(0xFF6366F1),
                    label: 'Horario',
                    value: extra['hours'] as String,
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildInfoBox(
                    icon: Icons.speed,
                    color: const Color(0xFF10B981),
                    label: 'Frecuencia',
                    value: extra['frequency'] as String,
                  )),
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
                        child: Text(extra['zones'] as String,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D4ED8)))),
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

  Widget _buildInfoBox({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900, color: color)),
        ]),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
                height: 1.5)),
      ]),
    );
  }
}
