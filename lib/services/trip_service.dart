import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart';

/// Service for handling all trip and route-related operations
/// 
/// This singleton service manages:
/// - Creating and managing trips
/// - Adding participants to trips
/// - Managing trip expenses and debt calculations
/// - Creating and managing public routes
/// - Polling for trip updates
class TripService {
  // Singleton pattern
  static final TripService _instance = TripService._internal();
  factory TripService() => _instance;
  TripService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers for real-time updates
  final _tripsController = StreamController<List<Trip>>.broadcast();
  final _routesController = StreamController<List<Route>>.broadcast();

  // Polling timers
  Timer? _tripsTimer;
  Timer? _routesTimer;

  // Cache
  List<Trip>? _tripsCache;
  List<Route>? _routesCache;

  // Getters for streams
  Stream<List<Trip>> get tripsStream => _tripsController.stream;
  Stream<List<Route>> get routesStream => _routesController.stream;

  // ============================================================================
  // TRIP METHODS
  // ============================================================================

  /// Create a new trip
  Future<String?> createTrip({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    bool isPublic = false,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final docRef = _firestore.collection('trips').doc();
      
      final trip = Trip(
        id: docRef.id,
        title: title,
        startDate: startDate,
        endDate: endDate,
        creatorId: userId,
        participantIds: [userId], // Creator is automatically a participant
        isPublic: isPublic,
        createdAt: DateTime.now(),
        days: [],
        expenses: [],
      );

      await docRef.set(trip.toMap());
      
      // Refresh trips
      await _fetchTrips();
      
      return docRef.id;
    } catch (e) {
      print('Error creating trip: $e');
      return null;
    }
  }

  /// Get all trips for current user with polling
  Future<void> startTripsPolling({Duration interval = const Duration(seconds: 10)}) async {
    // Initial load
    await _fetchTrips();
    
    // Start polling
    _tripsTimer?.cancel();
    _tripsTimer = Timer.periodic(interval, (_) async {
      await _fetchTrips();
    });
  }

  /// Stop polling for trips
  void stopTripsPolling() {
    _tripsTimer?.cancel();
    _tripsTimer = null;
  }

  /// Fetch trips from Firestore
  Future<void> _fetchTrips() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('trips')
          .where('participantIds', arrayContains: userId)
          .get();

      final trips = snapshot.docs
          .map((doc) => Trip.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort by start date descending (most recent first)
      trips.sort((a, b) => b.startDate.compareTo(a.startDate));

      _tripsCache = trips;
      _tripsController.add(trips);
    } catch (e) {
      print('Error fetching trips: $e');
    }
  }

  /// Get trips synchronously from cache
  List<Trip> getTrips() {
    return _tripsCache ?? [];
  }

  /// Get a specific trip by ID
  Future<Trip?> getTripDetails(String tripId) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return null;
      
      return Trip.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting trip details: $e');
      return null;
    }
  }

  /// Update trip basic information
  Future<bool> updateTrip({
    required String tripId,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    bool? isPublic,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (startDate != null) updates['startDate'] = startDate.millisecondsSinceEpoch;
      if (endDate != null) updates['endDate'] = endDate.millisecondsSinceEpoch;
      if (isPublic != null) updates['isPublic'] = isPublic;

      if (updates.isEmpty) return false;

      await _firestore.collection('trips').doc(tripId).update(updates);
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error updating trip: $e');
      return false;
    }
  }

  /// Delete a trip (only creator can delete)
  Future<bool> deleteTrip(String tripId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Verify user is the creator
      final trip = await getTripDetails(tripId);
      if (trip == null || trip.creatorId != userId) {
        print('User is not the creator of this trip');
        return false;
      }

      await _firestore.collection('trips').doc(tripId).delete();
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    }
  }

  // ============================================================================
  // PARTICIPANT METHODS
  // ============================================================================

  /// Add a participant to a trip
  Future<bool> addParticipant({
    required String tripId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return false;

      final trip = Trip.fromMap({...doc.data()!, 'id': doc.id});
      
      // Check if user is already a participant
      if (trip.participantIds.contains(userId)) {
        return true; // Already added
      }

      // Add user to participants
      await _firestore.collection('trips').doc(tripId).update({
        'participantIds': FieldValue.arrayUnion([userId])
      });
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error adding participant: $e');
      return false;
    }
  }

  /// Remove a participant from a trip
  Future<bool> removeParticipant({
    required String tripId,
    required String userId,
  }) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return false;

      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return false;

      final trip = Trip.fromMap({...doc.data()!, 'id': doc.id});
      
      // Can't remove the creator
      if (trip.creatorId == userId) {
        print('Cannot remove the trip creator');
        return false;
      }

      // Remove user from participants
      await _firestore.collection('trips').doc(tripId).update({
        'participantIds': FieldValue.arrayRemove([userId])
      });
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error removing participant: $e');
      return false;
    }
  }

  // ============================================================================
  // DAY & ACTIVITY METHODS
  // ============================================================================

  /// Add an activity to a specific day in the trip
  Future<bool> addDayActivity({
    required String tripId,
    required int day,
    required String time,
    required String description,
  }) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return false;

      final trip = Trip.fromMap({...doc.data()!, 'id': doc.id});
      
      // Find or create the day
      final dayIndex = trip.days.indexWhere((d) => d.day == day);
      
      List<TripDay> updatedDays = List.from(trip.days);
      
      final newActivity = Activity(time: time, description: description);
      
      if (dayIndex >= 0) {
        // Day exists, add activity
        final existingDay = updatedDays[dayIndex];
        updatedDays[dayIndex] = TripDay(
          day: day,
          activities: [...existingDay.activities, newActivity],
        );
      } else {
        // Create new day with activity
        updatedDays.add(TripDay(
          day: day,
          activities: [newActivity],
        ));
      }

      // Sort days by day number
      updatedDays.sort((a, b) => a.day.compareTo(b.day));

      await _firestore.collection('trips').doc(tripId).update({
        'days': updatedDays.map((d) => d.toMap()).toList(),
      });
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error adding day activity: $e');
      return false;
    }
  }

  // ============================================================================
  // EXPENSE METHODS
  // ============================================================================

  /// Add an expense to a trip
  Future<bool> addExpense({
    required String tripId,
    required double amount,
    required String concept,
    required String paidBy,
    required List<String> sharedWith,
  }) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return false;

      final trip = Trip.fromMap({...doc.data()!, 'id': doc.id});
      
      // Generate expense ID
      final expenseId = '${tripId}_${DateTime.now().millisecondsSinceEpoch}';
      
      final expense = TripExpense(
        id: expenseId,
        tripId: tripId,
        amount: amount,
        concept: concept,
        paidBy: paidBy,
        sharedWith: sharedWith,
        timestamp: DateTime.now(),
        settled: false,
      );

      final updatedExpenses = [...trip.expenses, expense];

      await _firestore.collection('trips').doc(tripId).update({
        'expenses': updatedExpenses.map((e) => e.toMap()).toList(),
      });
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  /// Get all expenses for a trip
  List<TripExpense> getExpenses(String tripId) {
    final trip = _tripsCache?.firstWhere(
      (t) => t.id == tripId,
      orElse: () => Trip(
        id: '',
        title: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        creatorId: '',
        participantIds: [],
        createdAt: DateTime.now(),
      ),
    );
    
    return trip?.expenses ?? [];
  }

  /// Mark an expense as settled
  Future<bool> settleExpense({
    required String tripId,
    required String expenseId,
  }) async {
    try {
      final doc = await _firestore.collection('trips').doc(tripId).get();
      if (!doc.exists) return false;

      final trip = Trip.fromMap({...doc.data()!, 'id': doc.id});
      
      final updatedExpenses = trip.expenses.map((e) {
        if (e.id == expenseId) {
          return e.copyWith(settled: true);
        }
        return e;
      }).toList();

      await _firestore.collection('trips').doc(tripId).update({
        'expenses': updatedExpenses.map((e) => e.toMap()).toList(),
      });
      
      // Refresh trips
      await _fetchTrips();
      
      return true;
    } catch (e) {
      print('Error settling expense: $e');
      return false;
    }
  }

  /// Calculate who owes whom in a trip
  Map<String, Map<String, double>> calculateDebts(String tripId) {
    final expenses = getExpenses(tripId);
    
    // Filter only unsettled expenses
    final unsettledExpenses = expenses.where((e) => !e.settled).toList();
    
    if (unsettledExpenses.isEmpty) {
      return {};
    }

    // Calculate how much each person paid and how much they should pay
    final Map<String, double> totalPaid = {};
    final Map<String, double> totalOwed = {};
    
    for (final expense in unsettledExpenses) {
      // Track who paid
      totalPaid[expense.paidBy] = (totalPaid[expense.paidBy] ?? 0) + expense.amount;
      
      // Calculate share per person
      final sharePerPerson = expense.amount / expense.sharedWith.length;
      
      // Track who owes
      for (final userId in expense.sharedWith) {
        totalOwed[userId] = (totalOwed[userId] ?? 0) + sharePerPerson;
      }
    }

    // Calculate net balance (paid - owed)
    final Map<String, double> balance = {};
    final allUsers = {...totalPaid.keys, ...totalOwed.keys};
    
    for (final userId in allUsers) {
      final paid = totalPaid[userId] ?? 0;
      final owed = totalOwed[userId] ?? 0;
      balance[userId] = paid - owed;
    }

    // Create debts map: who owes whom
    final Map<String, Map<String, double>> debts = {};
    
    // Separate creditors (positive balance) and debtors (negative balance)
    final creditors = balance.entries.where((e) => e.value > 0.01).map((e) => MapEntry(e.key, e.value)).toList();
    final debtors = balance.entries.where((e) => e.value < -0.01).toList();
    
    // Track remaining credit for each creditor
    final remainingCredit = Map<String, double>.from(creditors.fold<Map<String, double>>({}, (map, entry) {
      map[entry.key] = entry.value;
      return map;
    }));
    
    // Match debtors with creditors
    for (final debtor in debtors) {
      final debtorId = debtor.key;
      var remainingDebt = -debtor.value; // Make it positive
      
      for (final creditor in creditors) {
        if (remainingDebt <= 0.01) break;
        
        final creditorId = creditor.key;
        var availableCredit = remainingCredit[creditorId] ?? 0;
        
        if (availableCredit <= 0.01) continue;
        
        final payment = remainingDebt < availableCredit ? remainingDebt : availableCredit;
        
        // Add debt
        if (!debts.containsKey(debtorId)) {
          debts[debtorId] = {};
        }
        debts[debtorId]![creditorId] = payment;
        
        // Update balances
        remainingDebt -= payment;
        remainingCredit[creditorId] = availableCredit - payment;
      }
    }

    return debts;
  }

  // ============================================================================
  // ROUTE METHODS
  // ============================================================================

  /// Create a new public route
  Future<String?> createRoute({
    required String title,
    required String description,
    required String duration,
    required List<RouteLocation> locations,
    bool isPublic = true,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final docRef = _firestore.collection('routes').doc();
      
      // Generate Google Maps URL with all locations
      final googleMapsUrl = _generateGoogleMapsUrl(locations);
      
      final route = Route(
        id: docRef.id,
        title: title,
        description: description,
        duration: duration,
        stops: locations.length,
        locations: locations,
        googleMapsUrl: googleMapsUrl,
        creatorId: userId,
        isPublic: isPublic,
        createdAt: DateTime.now(),
      );

      await docRef.set(route.toMap());
      
      // Refresh routes
      await _fetchRoutes();
      
      return docRef.id;
    } catch (e) {
      print('Error creating route: $e');
      return null;
    }
  }

  /// Get all public routes with polling
  Future<void> startRoutesPolling({Duration interval = const Duration(seconds: 10)}) async {
    // Initial load
    await _fetchRoutes();
    
    // Start polling
    _routesTimer?.cancel();
    _routesTimer = Timer.periodic(interval, (_) async {
      await _fetchRoutes();
    });
  }

  /// Stop polling for routes
  void stopRoutesPolling() {
    _routesTimer?.cancel();
    _routesTimer = null;
  }

  /// Fetch public routes from Firestore
  Future<void> _fetchRoutes() async {
    try {
      final snapshot = await _firestore
          .collection('routes')
          .where('isPublic', isEqualTo: true)
          .get();

      final routes = snapshot.docs
          .map((doc) => Route.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort by creation date descending
      routes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _routesCache = routes;
      _routesController.add(routes);
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  /// Get routes synchronously from cache
  List<Route> getRoutes() {
    return _routesCache ?? [];
  }

  /// Get user's own routes
  Future<List<Route>> getMyRoutes() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('routes')
          .where('creatorId', isEqualTo: userId)
          .get();

      final routes = snapshot.docs
          .map((doc) => Route.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Sort by creation date descending
      routes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return routes;
    } catch (e) {
      print('Error fetching my routes: $e');
      return [];
    }
  }

  /// Delete a route (only creator can delete)
  Future<bool> deleteRoute(String routeId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Verify user is the creator
      final doc = await _firestore.collection('routes').doc(routeId).get();
      if (!doc.exists) return false;
      
      final route = Route.fromMap({...doc.data()!, 'id': doc.id});
      if (route.creatorId != userId) {
        print('User is not the creator of this route');
        return false;
      }

      await _firestore.collection('routes').doc(routeId).delete();
      
      // Refresh routes
      await _fetchRoutes();
      
      return true;
    } catch (e) {
      print('Error deleting route: $e');
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Generate Google Maps URL with multiple waypoints
  String _generateGoogleMapsUrl(List<RouteLocation> locations) {
    if (locations.isEmpty) return '';
    
    if (locations.length == 1) {
      final loc = locations[0];
      return 'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}';
    }

    // For multiple locations, use directions with waypoints
    final origin = locations.first;
    final destination = locations.last;
    final waypoints = locations.sublist(1, locations.length - 1);

    var url = 'https://www.google.com/maps/dir/?api=1';
    url += '&origin=${origin.latitude},${origin.longitude}';
    url += '&destination=${destination.latitude},${destination.longitude}';
    
    if (waypoints.isNotEmpty) {
      final waypointsStr = waypoints
          .map((loc) => '${loc.latitude},${loc.longitude}')
          .join('|');
      url += '&waypoints=$waypointsStr';
    }
    
    return url;
  }

  /// Dispose all resources
  void dispose() {
    stopTripsPolling();
    stopRoutesPolling();
    _tripsController.close();
    _routesController.close();
  }
}
