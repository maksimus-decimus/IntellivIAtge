import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/trip_service.dart';
import '../services/user_service.dart';
import '../models/types.dart' as types;

enum TripTab { trips, routes }

enum TripView { list, createTrip, addPersons, expenses, details, addExpense, settleDebts }

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  TripTab _activeTab = TripTab.trips;
  TripView _activeView = TripView.list;
  types.Trip? _selectedTrip;
  
  // Services
  final TripService _tripService = TripService();
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // State
  List<types.Trip> _trips = [];
  List<types.Route> _routes = [];
  bool _isLoadingTrips = true;
  bool _isLoadingRoutes = true;
  
  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // Initialize date formatting for Spanish locale
    await initializeDateFormatting('es', null);
    
    // Start polling for trips
    await _tripService.startTripsPolling();
    
    // Listen to trips stream
    _tripService.tripsStream.listen((trips) {
      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoadingTrips = false;
        });
      }
    });
    
    // Start polling for routes
    await _tripService.startRoutesPolling();
    
    // Listen to routes stream
    _tripService.routesStream.listen((routes) {
      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoadingRoutes = false;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tripService.stopTripsPolling();
    _tripService.stopRoutesPolling();
    _tripNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _friendSearchController.dispose();
    _expenseAmountController.dispose();
    _expenseConceptController.dispose();
    super.dispose();
  }
  
  String _formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('d MMM', 'es');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }
  
  // Form controllers and state
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _friendSearchController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _expenseConceptController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPublicTrip = false;
  List<types.UserProfile> _friends = [];
  List<types.UserProfile> _filteredFriends = [];
  bool _isLoadingFriends = false;
  String? _addingParticipantId;
  List<types.TripExpense> _expenses = [];
  Map<String, Map<String, double>> _debts = {};
  bool _isLoadingExpenses = false;
  String? _expensePaidBy;
  List<String> _expenseSharedWith = [];
  
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        // If end date is before start date, reset it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
          _endDateController.clear();
        }
      });
    }
  }
  
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  
  Future<void> _createTrip() async {
    // Validate inputs
    if (_tripNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre para el viaje'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona las fechas del viaje'), backgroundColor: Colors.red),
      );
      return;
    }
    
    // Create trip
    final tripId = await _tripService.createTrip(
      title: _tripNameController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      isPublic: _isPublicTrip,
    );
    
    if (tripId != null) {
      // Clear form
      _tripNameController.clear();
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
      _isPublicTrip = false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u00a1Viaje creado con \u00e9xito!'), backgroundColor: Colors.cyan),
      );
      setState(() => _activeView = TripView.list);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el viaje'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    try {
      final friends = await _userService.getFriends();
      setState(() {
        _friends = friends;
        _filteredFriends = friends;
        _isLoadingFriends = false;
      });
    } catch (e) {
      print('Error loading friends: $e');
      setState(() => _isLoadingFriends = false);
    }
  }
  
  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends.where((friend) {
          final nameLower = friend.name.toLowerCase();
          final emailLower = friend.email.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) || emailLower.contains(queryLower);
        }).toList();
      }
    });
  }
  
  Future<void> _addParticipant(String friendId) async {
    if (_selectedTrip == null) return;
    
    // Prevent double-tap
    if (_addingParticipantId == friendId) return;
    
    // Check if already a participant
    if (_selectedTrip!.participantIds.contains(friendId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esta persona ya está en el viaje'), backgroundColor: Colors.orange),
        );
      }
      return;
    }
    
    setState(() => _addingParticipantId = friendId);
    
    final success = await _tripService.addParticipant(
      tripId: _selectedTrip!.id,
      userId: friendId,
    );
    
    if (mounted) {
      setState(() => _addingParticipantId = null);
    }
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Persona añadida al viaje!'), backgroundColor: Colors.cyan),
      );
      // Reload trip details
      final updatedTrip = await _tripService.getTripDetails(_selectedTrip!.id);
      if (updatedTrip != null && mounted) {
        setState(() => _selectedTrip = updatedTrip);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al añadir persona'), backgroundColor: Colors.red),
      );
    }
  }
  
  Widget _buildUserAvatar(String? photoUrl, {double size = 40}) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      // Check if it's a local asset or network image
      final isLocalAsset = !photoUrl.startsWith('http://') && 
                          !photoUrl.startsWith('https://');
      
      if (isLocalAsset) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: Image.asset(
            'assets/$photoUrl',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.cyan[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.cyan, size: size * 0.6),
              );
            },
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size),
          child: Image.network(
            photoUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.cyan[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.cyan, size: size * 0.6),
              );
            },
          ),
        );
      }
    }
    
    // Default avatar
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.cyan[100],
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.cyan, size: size * 0.6),
    );
  }
  
  Future<void> _loadExpenses() async {
    if (_selectedTrip == null) return;
    
    setState(() => _isLoadingExpenses = true);
    try {
      final expenses = await _tripService.getExpenses(_selectedTrip!.id);
      final debts = await _tripService.calculateDebts(_selectedTrip!.id);
      setState(() {
        _expenses = expenses;
        _debts = debts;
        _isLoadingExpenses = false;
      });
    } catch (e) {
      print('Error loading expenses: $e');
      setState(() => _isLoadingExpenses = false);
    }
  }
  
  Future<void> _addExpense() async {
    if (_selectedTrip == null) return;
    
    // Validate inputs
    final amount = double.tryParse(_expenseAmountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto v\u00e1lido'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_expenseConceptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un concepto'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_expensePaidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona qui\u00e9n pag\u00f3'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_expenseSharedWith.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona con qui\u00e9n se comparte'), backgroundColor: Colors.red),
      );
      return;
    }
    
    final success = await _tripService.addExpense(
      tripId: _selectedTrip!.id,
      amount: amount,
      concept: _expenseConceptController.text.trim(),
      paidBy: _expensePaidBy!,
      sharedWith: _expenseSharedWith,
    );
    
    if (success) {
      _expenseAmountController.clear();
      _expenseConceptController.clear();
      _expensePaidBy = null;
      _expenseSharedWith = [];
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u00a1Gasto a\u00f1adido con \u00e9xito!'), backgroundColor: Colors.cyan),
      );
      
      setState(() => _activeView = TripView.expenses);
      _loadExpenses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al a\u00f1adir gasto'), backgroundColor: Colors.red),
      );
    }
  }
  
  Future<void> _settleExpense(String expenseId) async {
    if (_selectedTrip == null) return;
    
    final success = await _tripService.settleExpense(
      tripId: _selectedTrip!.id,
      expenseId: expenseId,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u00a1Gasto marcado como pagado!'), backgroundColor: Colors.cyan),
      );
      _loadExpenses();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al marcar gasto'), backgroundColor: Colors.red),
      );
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
                    controller: _tripNameController,
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
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectStartDate(context),
                              decoration: const InputDecoration(
                                hintText: 'Toca para seleccionar',
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
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectEndDate(context),
                              decoration: const InputDecoration(
                                hintText: 'Toca para seleccionar',
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
                    underline: const SizedBox.shrink(),
                    value: _isPublicTrip ? 'Público (Comunidad)' : 'Privado (Solo invitados)',
                    items: const [
                      DropdownMenuItem(value: 'Privado (Solo invitados)', child: Text('Privado (Solo invitados)')),
                      DropdownMenuItem(value: 'Público (Comunidad)', child: Text('Público (Comunidad)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _isPublicTrip = value == 'Público (Comunidad)';
                      });
                    },
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _createTrip,
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
    // Load friends when entering this view
    if (_friends.isEmpty && !_isLoadingFriends) {
      _loadFriends();
    }
    
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
                    controller: _friendSearchController,
                    onChanged: _filterFriends,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o email...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Loading state
                if (_isLoadingFriends)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  )
                // Empty state
                else if (_filteredFriends.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            _friends.isEmpty ? 'No tienes amigos a\u00f1adidos' : 'No se encontraron amigos',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                // Friends list
                else ...[
                  const Text('Amigos', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                  const SizedBox(height: 12),
                  ..._filteredFriends.map((friend) {
                    final isParticipant = _selectedTrip?.participantIds.contains(friend.id) ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isParticipant ? Colors.cyan : Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          _buildUserAvatar(friend.photoUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(friend.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(friend.email, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          if (isParticipant)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('✓ Añadido', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                            )
                          else if (_addingParticipantId == friend.id)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.cyan[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const SizedBox(
                                width: 50,
                                height: 20,
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyan),
                                  ),
                                ),
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => _addParticipant(friend.id),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.cyan[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Invitar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.cyan)),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
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
    // Load expenses when entering this view
    if (_expenses.isEmpty && !_isLoadingExpenses) {
      _loadExpenses();
    }
    
    // Calculate total expense
    final totalExpense = _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
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
                      Text('\u20ac${totalExpense.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
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
                
                // Loading state
                if (_isLoadingExpenses)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  )
                // Empty state
                else if (_expenses.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 8),
                          Text(
                            'No hay gastos registrados',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                // Expenses list
                else
                  ..._expenses.map((expense) {
                    final paidByName = expense.paidBy == _auth.currentUser?.uid ? 'ti' : 'otro';
                    return _buildExpenseCard(
                      Icons.receipt,
                      expense.concept,
                      'Pagado por $paidByName',
                      '\u20ac${expense.amount.toStringAsFixed(2)}',
                      expense.settled ? Colors.green : const Color(0xFFFB923C),
                    );
                  }).toList(),
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
                              controller: _expenseAmountController,
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
                  child: TextField(
                    controller: _expenseConceptController,
                    decoration: const InputDecoration(
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
                    underline: const SizedBox.shrink(),
                    value: _expensePaidBy ?? _auth.currentUser?.uid,
                    hint: const Text('Selecciona qui\u00e9n pag\u00f3'),
                    items: _selectedTrip?.participantIds.map((participantId) {
                      final isCurrentUser = participantId == _auth.currentUser?.uid;
                      return DropdownMenuItem(
                        value: participantId,
                        child: Text(isCurrentUser ? 'T\u00fa' : 'Participante'),
                      );
                    }).toList() ?? [],
                    onChanged: (value) {
                      setState(() => _expensePaidBy = value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Compartido con', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                  child: Column(
                    children: _selectedTrip?.participantIds.map((participantId) {
                      final isCurrentUser = participantId == _auth.currentUser?.uid;
                      final isSelected = _expenseSharedWith.contains(participantId);
                      return CheckboxListTile(
                        title: Text(isCurrentUser ? 'T\u00fa' : 'Participante'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _expenseSharedWith.add(participantId);
                            } else {
                              _expenseSharedWith.remove(participantId);
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: Colors.cyan,
                      );
                    }).toList() ?? [],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _addExpense,
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
                // Loading state
                if (_isLoadingExpenses)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: Colors.cyan),
                    ),
                  )
                // Empty state
                else if (_debts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: Colors.green[300]),
                          const SizedBox(height: 8),
                          Text(
                            '\u00a1No hay deudas pendientes!',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                // Debts list
                else
                  ..._debts.entries.expand((entry) {
                    final debtorId = entry.key;
                    final creditors = entry.value;
                    return creditors.entries.map((creditorEntry) {
                      final amount = creditorEntry.value;
                      final currentUserId = _auth.currentUser?.uid ?? '';
                      
                      // Determine if current user is the debtor or creditor
                      final isCurrentUserDebtor = debtorId == currentUserId;
                      final title = isCurrentUserDebtor 
                          ? 'Debes a...' 
                          : '...te debe';
                      final amountColor = isCurrentUserDebtor ? Colors.red : Colors.green;
                      
                      return _buildDebtCard(
                        null, // We don't have avatar info here
                        title,
                        'Del viaje compartido',
                        '\u20ac${amount.toStringAsFixed(2)}',
                        amountColor,
                        isCurrentUserDebtor ? 'Marcar pagado' : 'Recibido',
                      );
                    });
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(String? avatar, String title, String subtitle, String amount, Color amountColor, String buttonText) {
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
          avatar != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(avatar, width: 40, height: 40, fit: BoxFit.cover),
                )
              : _buildUserAvatar(null, size: 40),
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
                              _selectedTrip != null ? _formatDateRange(_selectedTrip!.startDate, _selectedTrip!.endDate) : '',
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
                              '${_selectedTrip?.participantIds.length ?? 1} personas en este viaje',
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
                            ...(_selectedTrip?.days.expand((day) {
                                  return day.activities.map((activity) {
                                    final isLast = day == _selectedTrip!.days.last && activity == day.activities.last;
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
                                              if (!isLast)
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
                                                    'Día ${day.day} • ${activity.time}',
                                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.cyan),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(activity.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
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

              // Loading state
              if (_isLoadingTrips && _activeTab == TripTab.trips)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Colors.cyan),
                  ),
                ),

              // Empty state for trips
              if (!_isLoadingTrips && _trips.isEmpty && _activeTab == TripTab.trips)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.luggage, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          '¡Crea tu primer viaje!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organiza tus aventuras y compártelas con amigos',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Trips List
              if (_activeTab == TripTab.trips)
                ..._trips.map((trip) {
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
                                    Text(_formatDateRange(trip.startDate, trip.endDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people, size: 16, color: Colors.cyan[100]),
                                    const SizedBox(width: 4),
                                    Text('${trip.participantIds.length} personas', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
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
                            // Timeline - flatten all activities from all days
                            ...trip.days.expand((day) {
                              return day.activities.map((activity) {
                                final isLast = day == trip.days.last && 
                                              activity == day.activities.last;
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
                                          if (!isLast)
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
                                                'Día ${day.day} • ${activity.time}',
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.cyan),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(activity.description, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
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
              
              // Loading state for routes
              if (_isLoadingRoutes && _activeTab == TripTab.routes)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: Colors.cyan),
                  ),
                ),

              // Empty state for routes
              if (!_isLoadingRoutes && _routes.isEmpty && _activeTab == TripTab.routes)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No hay rutas disponibles',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé el primero en crear una ruta',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              
              if (_activeTab == TripTab.routes)
                ..._routes.map((route) {
                return GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(route.googleMapsUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        bottom: BorderSide(color: Colors.cyan, width: 4),
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
