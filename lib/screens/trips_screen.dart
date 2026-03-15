import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum TripTab { trips, routes }

enum TripView { list, createTrip, addPersons, expenses, details, addExpense, settleDebts }

class TripItem {
  final int id;
  final String title;
  final String dates;
  final int members;
  final bool isPublic;
  final List<DayItem> days;

  TripItem({
    required this.id,
    required this.title,
    required this.dates,
    required this.members,
    required this.isPublic,
    required this.days,
  });
}

class DayItem {
  final int day;
  final String time;
  final String activity;

  DayItem({required this.day, required this.time, required this.activity});
}

class MapRoute {
  final int id;
  final String title;
  final String duration;
  final int stops;
  final String googleMapsLink;
  final String colorClass;

  MapRoute({
    required this.id,
    required this.title,
    required this.duration,
    required this.stops,
    required this.googleMapsLink,
    required this.colorClass,
  });
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  TripTab _activeTab = TripTab.trips;
  TripView _activeView = TripView.list;
  TripItem? _selectedTrip;

  final List<TripItem> _mockTrips = [
    TripItem(
      id: 1,
      title: 'Weekend en Barcelona',
      dates: '24-26 Feb 2026',
      members: 3,
      isPublic: false,
      days: [
        DayItem(day: 1, time: '10:00', activity: 'Visita a la Sagrada Familia'),
        DayItem(day: 1, time: '16:00', activity: 'Paseo por el Barrio Gótico'),
        DayItem(day: 2, time: '11:00', activity: 'Park Güell y mirador'),
      ],
    ),
    TripItem(
      id: 2,
      title: 'Semana Cultural',
      dates: '1-7 Mar 2026',
      members: 5,
      isPublic: true,
      days: [
        DayItem(day: 1, time: '09:00', activity: 'Tour de Gaudí'),
        DayItem(day: 2, time: '10:30', activity: 'Museos y arte'),
        DayItem(day: 3, time: '14:00', activity: 'Playas de Barcelona'),
      ],
    ),
  ];

  final List<MapRoute> _mapRoutes = [
    MapRoute(id: 1, title: 'Ruta Gaudí Completa', duration: '4-5h', stops: 6, googleMapsLink: 'https://maps.google.com', colorClass: 'amber'),
    MapRoute(id: 2, title: 'Barcelona Marítima', duration: '3h', stops: 4, googleMapsLink: 'https://maps.google.com', colorClass: 'blue'),
    MapRoute(id: 3, title: 'Barrio Gótico', duration: '2-3h', stops: 8, googleMapsLink: 'https://maps.google.com', colorClass: 'purple'),
    MapRoute(id: 4, title: 'Montjuïc al Completo', duration: '5-6h', stops: 7, googleMapsLink: 'https://maps.google.com', colorClass: 'emerald'),
  ];

  Color _getRouteColor(String colorClass) {
    switch (colorClass) {
      case 'amber':
        return const Color(0xFFFBBF24);
      case 'blue':
        return const Color(0xFF60A5FA);
      case 'purple':
        return const Color(0xFFA78BFA);
      case 'emerald':
        return const Color(0xFF34D399);
      default:
        return const Color(0xFF6EE7B7);
    }
  }

  // --- CREATE TRIP VIEW ---
  Widget _buildCreateTripView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => setState(() => _activeView = TripView.list),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Nuevo Viaje',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Name
                const Text(
                  'Nombre del viaje',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Ej. Escapada a Barcelona',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha inicio',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!, width: 2),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'DD/MM/YYYY',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha fin',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!, width: 2),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'DD/MM/YYYY',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                                prefixIcon: Icon(Icons.calendar_today, size: 18),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Privacy
                const Text(
                  'Privacidad',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    value: 'Privado (Solo invitados)',
                    items: [
                      DropdownMenuItem(value: 'Privado (Solo invitados)', child: Text('Privado (Solo invitados)')),
                      DropdownMenuItem(value: 'Público (Comunidad)', child: Text('Público (Comunidad)')),
                    ],
                    onChanged: null,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Viaje guardado!'), backgroundColor: Colors.cyan),
                    );
                    setState(() => _activeView = TripView.list);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Guardar Viaje', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ADD PERSONS VIEW ---
  Widget _buildAddPersonsView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                    onPressed: () => setState(() => _activeView = TripView.list),
                  ),
                  const SizedBox(width: 8),
                  const Text('Añadir Personas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyan[100]!),
                  ),
                  child: Text(
                    'Estás invitando a amigos al viaje: ${_selectedTrip?.title ?? ''}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0E7490)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Sugerencias', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                const SizedBox(height: 12),
                ...List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            'https://picsum.photos/40/40?random=${i + 50}',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Amigo ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('@amigo${i + 1}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.cyan[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Invitar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyan)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Compartir enlace de invitación'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- EXPENSES VIEW ---
  Widget _buildExpensesView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                    onPressed: () => setState(() => _activeView = TripView.list),
                  ),
                  const SizedBox(width: 8),
                  const Text('Repartir Gastos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('Gasto Total del Viaje', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[100])),
                      const SizedBox(height: 8),
                      const Text('€450.00', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          _selectedTrip?.title ?? '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeView = TripView.addExpense),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!, width: 2),
                          ),
                          child: const Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD1FAE5),
                                child: Icon(Icons.add, color: Color(0xFF10B981)),
                              ),
                              SizedBox(height: 8),
                              Text('Añadir Gasto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeView = TripView.settleDebts),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!, width: 2),
                          ),
                          child: const Column(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFFD1FAE5),
                                child: Icon(Icons.swap_horiz, color: Color(0xFF10B981)),
                              ),
                              SizedBox(height: 8),
                              Text('Saldar Deudas', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Gastos Recientes', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                const SizedBox(height: 12),
                _buildExpenseCard(Icons.receipt, 'Cena Tapas', 'Pagado por ti', '€85.50', const Color(0xFFFB923C)),
                _buildExpenseCard(Icons.credit_card, 'Entradas Museo', 'Pagado por Ana', '€40.00', const Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(IconData icon, String title, String subtitle, String amount, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  // --- ADD EXPENSE VIEW ---
  Widget _buildAddExpenseView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                    onPressed: () => setState(() => _activeView = TripView.expenses),
                  ),
                  const SizedBox(width: 8),
                  const Text('Añadir Gasto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.green[100]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text('Importe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green[800])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('€', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.green[600])),
                          Container(
                            width: 128,
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.green[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Conpto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Ej. Cena en la playa',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pagado por', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    value: 'Tú',
                    items: [
                      DropdownMenuItem(value: 'Tú', child: Text('Tú')),
                      DropdownMenuItem(value: 'Ana', child: Text('Ana')),
                      DropdownMenuItem(value: 'Carlos', child: Text('Carlos')),
                    ],
                    onChanged: null,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Gasto guardado!'), backgroundColor: Colors.green),
                    );
                    setState(() => _activeView = TripView.expenses);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Guardar Gasto', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SETTLE DEBTS VIEW ---
  Widget _buildSettleDebtsView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 28, color: Colors.grey[600]),
                    onPressed: () => setState(() => _activeView = TripView.expenses),
                  ),
                  const SizedBox(width: 8),
                  const Text('Saldar Deudas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDebtCard(
                  'https://picsum.photos/40/40?random=51',
                  'Ana te debe',
                  'De: Entradas Museo',
                  '€20.00',
                  Colors.green,
                  'Marcar pagado',
                ),
                _buildDebtCard(
                  'https://picsum.photos/40/40?random=52',
                  'Debes a Carlos',
                  'De: Taxis',
                  '€15.50',
                  Colors.red,
                  'Pagar ahora',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(String avatar, String title, String subtitle, String amount, Color amountColor, String buttonText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(avatar, width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.w900, color: amountColor)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(buttonText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: amountColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DETAILS VIEW ---
  Widget _buildDetailsView() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.cyan,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28, color: Colors.white),
                    onPressed: () => setState(() => _activeView = TripView.list),
                  ),
                  const SizedBox(width: 8),
                  const Text('Detalles del Viaje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  child: Column(
                    children: [
                      Text(
                        _selectedTrip?.title ?? '',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 20, color: Colors.cyan[200]),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTrip?.dates ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 20, color: Colors.cyan[200]),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedTrip?.members ?? 1} personas en este viaje',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[100]!),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Itinerario Completo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                            const SizedBox(height: 16),
                            ...(_selectedTrip?.days.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.cyan[400],
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 4),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                                                ],
                                              ),
                                            ),
                                            if ((_selectedTrip?.days.indexOf(item) ?? 0) < (_selectedTrip?.days.length ?? 0) - 1)
                                              Container(
                                                width: 4,
                                                height: 60,
                                                color: Colors.cyan[100],
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.cyan[50],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Día ${item.day} • ${item.time}',
                                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.cyan),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(item.activity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Detalles adicionales de la actividad irían aquí.',
                                                style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }) ??
                                []),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[100]!),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.public, size: 24, color: Color(0xFF64748B)),
                                  const SizedBox(height: 8),
                                  const Text('Hacer Público', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[100]!),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.delete, size: 24, color: Color(0xFF64748B)),
                                  const SizedBox(height: 8),
                                  const Text('Eliminar Viaje', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle specific views
    if (_activeView == TripView.createTrip) {
      return _buildCreateTripView();
    }
    if (_activeView == TripView.addPersons) {
      return _buildAddPersonsView();
    }
    if (_activeView == TripView.expenses) {
      return _buildExpensesView();
    }
    if (_activeView == TripView.addExpense) {
      return _buildAddExpenseView();
    }
    if (_activeView == TripView.settleDebts) {
      return _buildSettleDebtsView();
    }
    if (_activeView == TripView.details) {
      return _buildDetailsView();
    }

    // Main list view with tabs
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // Tabs
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = TripTab.trips),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == TripTab.trips ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeTab == TripTab.trips
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Mis Viajes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == TripTab.trips ? Colors.cyan : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = TripTab.routes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTab == TripTab.routes ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _activeTab == TripTab.routes
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Rutas Sugeridas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _activeTab == TripTab.routes ? Colors.cyan : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Content based on tab
            if (_activeTab == TripTab.trips) ...[
              // Create Trip Button
              GestureDetector(
                onTap: () => setState(() => _activeView = TripView.createTrip),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.cyan[100],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.cyan[200]!, width: 2, strokeAlign: BorderSide.strokeAlignInside, style: BorderStyle.solid),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 24, color: Colors.cyan),
                      SizedBox(width: 8),
                      Text('Crear Nuevo Viaje', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.cyan)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Trips List
              ..._mockTrips.map((trip) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[100]!, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    trip.title,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        trip.isPublic ? Icons.public : Icons.lock,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        trip.isPublic ? 'Pública' : 'Privada',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.cyan[100]),
                                    const SizedBox(width: 4),
                                    Text(trip.dates, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people, size: 16, color: Colors.cyan[100]),
                                    const SizedBox(width: 4),
                                    Text('${trip.members} personas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Timeline
                            ...trip.days.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.cyan[400],
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 4),
                                            boxShadow: [
                                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                                            ],
                                          ),
                                        ),
                                        if (trip.days.indexOf(item) < trip.days.length - 1)
                                          Container(
                                            width: 4,
                                            height: 40,
                                            color: Colors.cyan[100],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.cyan[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Día ${item.day} • ${item.time}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.cyan),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(item.activity, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border(top: BorderSide(color: Colors.grey[100]!)),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            bottomRight: Radius.circular(22),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedTrip = trip;
                                        _activeView = TripView.addPersons;
                                      });
                                    },
                                    icon: const Icon(Icons.people, size: 16),
                                    label: const Text('Añadir personas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      side: BorderSide(color: Colors.grey[200]!, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedTrip = trip;
                                        _activeView = TripView.expenses;
                                      });
                                    },
                                    icon: const Icon(Icons.receipt, size: 16),
                                    label: const Text('Repartir gastos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      side: BorderSide(color: Colors.grey[200]!, width: 2),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTrip = trip;
                                  _activeView = TripView.details;
                                });
                              },
                              child: const Text('Ver detalles completos del viaje', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyan)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              // Routes Tab
              Container(
                height: 256,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green[200]!, width: 2),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Map_of_Barcelona_districts.svg/1200px-Map_of_Barcelona_districts.svg.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.green[100]);
                            },
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🗺️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text('Explora Barcelona', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                          const SizedBox(height: 4),
                          Text('Selecciona una ruta abajo para abrir GPS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green[700])),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.navigation, size: 24, color: Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Rutas Recomendadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 12),
              ..._mapRoutes.map((route) {
                return GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(route.googleMapsLink);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getRouteColor(route.colorClass).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(color: _getRouteColor(route.colorClass), width: 4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(route.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('⏱️ ${route.duration}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                  const SizedBox(width: 16),
                                  Text('📍 ${route.stops} paradas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.open_in_new, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
