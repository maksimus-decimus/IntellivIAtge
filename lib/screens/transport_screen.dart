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

  // ✅ NEW
  final TextEditingController _destinationController = TextEditingController();

  // ✅ NEW
  static const List<Map<String, String>> _popularSpots = [
    {'label': '⛪ Sagrada Família', 'value': 'Sagrada Família'},
    {'label': '🏖️ Barceloneta', 'value': 'Platja de la Barceloneta'},
    {'label': '🦜 Park Güell', 'value': 'Park Güell'},
    {'label': '⚽ Camp Nou', 'value': 'Camp Nou'},
    {'label': '🛍️ Las Ramblas', 'value': 'La Rambla'},
    {'label': '🏛️ Born', 'value': 'El Born'},
    {'label': '🎨 MACBA', 'value': 'Museu d\'Art Contemporani'},
    {'label': '🌊 Port Olímpic', 'value': 'Port Olímpic'},
  ];

  final List<Map<String, dynamic>> _touristTickets = [
    {
      'id': 't-casual',
      'name': 'T-Casual (10 viajes)',
      'price': '12.15€',
      'desc': 'Ideal para estancias cortas. Unipersonal.',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'hola-bcn-48',
      'name': 'Hola Barcelona 48h',
      'price': '17.50€',
      'desc': 'Viajes ilimitados por 2 días.',
      'color': const Color(0xFF0EA5E9),
    },
    {
      'id': 'hola-bcn-72',
      'name': 'Hola Barcelona 72h',
      'price': '25.50€',
      'desc': 'Viajes ilimitados por 3 días.',
      'color': const Color(0xFF6366F1),
    },
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _onTabChanged(String newTab) {
    setState(() {
      _activeTab = newTab;
      _isBuying = false;
      _selectedTicket = null;
      _expandedInfo = null;
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
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────── ROUTES TAB ─────────────────

  Widget _buildRoutesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationInput('Mi ubicación actual', Colors.blue, null),
        const SizedBox(height: 12),
        _buildLocationInput(
          '¿A dónde quieres ir?',
          Colors.pink,
          _destinationController,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calculando ruta...')),
            );
          },
          child: const Text('Buscar Ruta'),
        ),
        const SizedBox(height: 20),
        const Text('Destinos populares'),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _popularSpots.map((spot) {
              return GestureDetector(
                onTap: () {
                  _destinationController.text = spot['value']!;
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(spot['label']!),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput(
    String hint,
    Color color,
    TextEditingController? controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ───────────────── TICKETS ─────────────────

  Widget _buildTicketsTab() {
    return Column(
      children: _touristTickets.map((ticket) {
        return ListTile(
          title: Text(ticket['name']),
          subtitle: Text(ticket['desc']),
          trailing: Text(ticket['price']),
          onTap: () {
            setState(() {
              _selectedTicket = ticket;
              _isBuying = true;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPurchaseScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_selectedTicket!['name']),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isBuying = false;
                _selectedTicket = null;
              });
            },
            child: const Text('Volver'),
          )
        ],
      ),
    );
  }

  // ───────────────── GUIDE ─────────────────

  Widget _buildGuideTab() {
    return const Text('Guía de transporte');
  }

  // ───────────────── INFO ─────────────────

  Widget _buildInfoTab() {
    return Column(
      children: AppConstants.transportOptions.map((opt) {
        return ListTile(
          title: Text(opt.name),
          subtitle: Text(opt.description),
        );
      }).toList(),
    );
  }

  // ───────────────── TABS ─────────────────

  Widget _buildTabs() {
    return Row(
      children: [
        _tab('routes'),
        _tab('tickets'),
        _tab('guide'),
        _tab('info'),
      ],
    );
  }

  Widget _tab(String tab) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(tab),
        child: Container(
          padding: const EdgeInsets.all(12),
          color: _activeTab == tab ? Colors.grey[300] : Colors.grey[100],
          child: Center(child: Text(tab)),
        ),
      ),
    );
  }
}
