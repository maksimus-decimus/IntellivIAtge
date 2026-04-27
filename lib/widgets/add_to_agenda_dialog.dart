import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/types.dart';
import '../services/agenda_service.dart';

/// Dialog to add an attraction or restaurant to a trip agenda
class AddToAgendaDialog extends StatefulWidget {
  final String itemName;
  final String itemType; // 'attraction' or 'restaurant'
  final Attraction? attraction;
  final Restaurant? restaurant;
  final VoidCallback onSuccess;

  const AddToAgendaDialog({
    super.key,
    required this.itemName,
    required this.itemType,
    this.attraction,
    this.restaurant,
    required this.onSuccess,
  });

  @override
  State<AddToAgendaDialog> createState() => _AddToAgendaDialogState();
}

class _AddToAgendaDialogState extends State<AddToAgendaDialog> {
  final AgendaService _agendaService = AgendaService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Trip> _trips = [];
  Trip? _selectedTrip;
  int? _selectedDay;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  bool _loadingTrips = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      final trips = await _agendaService.getAllTrips(userId);
      setState(() {
        _trips = trips.where((trip) {
          // Only show future or ongoing trips
          return trip.endDate.isAfter(DateTime.now());
        }).toList();
        _loadingTrips = false;
      });
    } catch (e) {
      print('Error loading trips: $e');
      setState(() {
        _loadingTrips = false;
      });
    }
  }

  Future<void> _addToAgenda() async {
    if (_selectedTrip == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un viaje y un día'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      if (widget.itemType == 'attraction' && widget.attraction != null) {
        await _agendaService.addAttractionToAgenda(
          tripId: _selectedTrip!.id,
          dayNumber: _selectedDay!,
          time: timeString,
          attraction: widget.attraction!,
        );
      } else if (widget.itemType == 'restaurant' && widget.restaurant != null) {
        await _agendaService.addRestaurantToAgenda(
          tripId: _selectedTrip!.id,
          dayNumber: _selectedDay!,
          time: timeString,
          restaurant: widget.restaurant!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.itemName} añadido a la agenda ✓'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error adding to agenda: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al añadir a la agenda: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    widget.itemType == 'attraction'
                        ? Icons.location_on
                        : Icons.restaurant,
                    color: const Color(0xFF0066CC),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Añadir a la Agenda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          widget.itemName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Trip Selection
              const Text(
                'Selecciona un viaje',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingTrips)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                )
              else if (_trips.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'No hay viajes disponibles. Crea uno primero.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<Trip>(
                    value: _selectedTrip,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Selecciona un viaje...'),
                    ),
                    items: _trips.map((trip) {
                      return DropdownMenuItem<Trip>(
                        value: trip,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(trip.title),
                        ),
                      );
                    }).toList(),
                    onChanged: (trip) {
                      setState(() {
                        _selectedTrip = trip;
                        _selectedDay = null; // Reset day selection
                      });
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Day Selection
              if (_selectedTrip != null) ...[
                const Text(
                  'Selecciona un día',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedDay,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Selecciona un día...'),
                    ),
                    items: List.generate(
                      _agendaService.calculateTripDays(
                        _selectedTrip!.startDate,
                        _selectedTrip!.endDate,
                      ),
                      (index) => index + 1,
                    ).map((dayNum) {
                      final dayDate = _selectedTrip!.startDate
                          .add(Duration(days: dayNum - 1));
                      final formatter = dayDate.day % 10 == 1 &&
                              dayDate.day != 11
                          ? 'de'
                          : 'de';
                      return DropdownMenuItem<int>(
                        value: dayNum,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            'Día $dayNum - ${_formatDate(dayDate)}',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Time Selection
                const Text(
                  'Selecciona una hora',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Icon(
                          Icons.access_time,
                          color: Color(0xFF0066CC),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ||
                              _selectedTrip == null ||
                              _selectedDay == null
                          ? null
                          : _addToAgenda,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Añadir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
