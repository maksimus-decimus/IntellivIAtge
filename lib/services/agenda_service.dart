import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart';

/// Service to manage trip agenda and activities
class AgendaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Add an activity to a specific trip day
  Future<void> addActivityToTrip(
    String tripId,
    int dayNumber,
    Activity activity,
  ) async {
    try {
      final tripRef = _firestore.collection('trips').doc(tripId);
      final tripData = await tripRef.get();
      final trip = Trip.fromMap(tripData.data() ?? {});

      // Find or create the TripDay
      final dayIndex =
          trip.days.indexWhere((day) => day.day == dayNumber);
      List<TripDay> updatedDays = List.from(trip.days);

      if (dayIndex >= 0) {
        // Update existing day
        final existingDay = updatedDays[dayIndex];
        updatedDays[dayIndex] = TripDay(
          day: existingDay.day,
          activities: [...existingDay.activities, activity],
        );
      } else {
        // Create new day
        updatedDays.add(TripDay(
          day: dayNumber,
          activities: [activity],
        ));
        // Sort by day number
        updatedDays.sort((a, b) => a.day.compareTo(b.day));
      }

      // Update trip in Firestore
      await tripRef.update({
        'days': updatedDays.map((d) => d.toMap()).toList(),
      });
    } catch (e) {
      print('Error adding activity to trip: $e');
      rethrow;
    }
  }

  /// Remove an activity from a trip day
  Future<void> removeActivityFromTrip(
    String tripId,
    int dayNumber,
    int activityIndex,
  ) async {
    try {
      final tripRef = _firestore.collection('trips').doc(tripId);
      final tripData = await tripRef.get();
      final trip = Trip.fromMap(tripData.data() ?? {});

      // Find the day and remove activity
      final dayIndex =
          trip.days.indexWhere((day) => day.day == dayNumber);
      if (dayIndex >= 0) {
        final day = trip.days[dayIndex];
        if (activityIndex < day.activities.length) {
          final updatedActivities = List<Activity>.from(day.activities);
          updatedActivities.removeAt(activityIndex);

          List<TripDay> updatedDays = List.from(trip.days);
          updatedDays[dayIndex] = TripDay(
            day: day.day,
            activities: updatedActivities,
          );

          await tripRef.update({
            'days': updatedDays.map((d) => d.toMap()).toList(),
          });
        }
      }
    } catch (e) {
      print('Error removing activity from trip: $e');
      rethrow;
    }
  }

  /// Add an attraction to the trip agenda
  Future<void> addAttractionToAgenda({
    required String tripId,
    required int dayNumber,
    required String time,
    required Attraction attraction,
  }) async {
    final activity = Activity(
      time: time,
      description: attraction.name,
      type: 'attraction',
      itemId: attraction.id,
      name: attraction.name,
      image: attraction.image,
      category: attraction.category,
    );

    await addActivityToTrip(tripId, dayNumber, activity);
  }

  /// Add a restaurant to the trip agenda
  Future<void> addRestaurantToAgenda({
    required String tripId,
    required int dayNumber,
    required String time,
    required Restaurant restaurant,
  }) async {
    final activity = Activity(
      time: time,
      description: restaurant.name,
      type: 'restaurant',
      itemId: restaurant.id,
      name: restaurant.name,
      image: restaurant.image,
      category: restaurant.type,
    );

    await addActivityToTrip(tripId, dayNumber, activity);
  }

  /// Get all trips (for the activity modal)
  Future<List<Trip>> getAllTrips(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('trips')
          .where('participantIds', arrayContains: userId)
          .get();

      return snapshot.docs
          .map((doc) => Trip.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting trips: $e');
      return [];
    }
  }

  /// Calculate the number of days in a trip
  int calculateTripDays(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Update an activity
  Future<void> updateActivityInTrip(
    String tripId,
    int dayNumber,
    int activityIndex,
    Activity updatedActivity,
  ) async {
    try {
      final tripRef = _firestore.collection('trips').doc(tripId);
      final tripData = await tripRef.get();
      final trip = Trip.fromMap(tripData.data() ?? {});

      // Find the day and update activity
      final dayIndex =
          trip.days.indexWhere((day) => day.day == dayNumber);
      if (dayIndex >= 0) {
        final day = trip.days[dayIndex];
        if (activityIndex < day.activities.length) {
          final updatedActivities = List<Activity>.from(day.activities);
          updatedActivities[activityIndex] = updatedActivity;

          List<TripDay> updatedDays = List.from(trip.days);
          updatedDays[dayIndex] = TripDay(
            day: day.day,
            activities: updatedActivities,
          );

          await tripRef.update({
            'days': updatedDays.map((d) => d.toMap()).toList(),
          });
        }
      }
    } catch (e) {
      print('Error updating activity: $e');
      rethrow;
    }
  }
}
