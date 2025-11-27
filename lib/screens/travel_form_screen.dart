import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/travel.dart';
import '../models/vehicle.dart';
import '../models/driver.dart';
import '../models/location.dart';
import '../services/travel_service.dart';
import '../services/vehicle_service.dart';
import '../services/driver_service.dart';
import '../services/location_service.dart';

class TravelFormScreen extends StatefulWidget {
  final Travel? travel;

  const TravelFormScreen({super.key, this.travel});

  @override
  State<TravelFormScreen> createState() => _TravelFormScreenState();
}

class _TravelFormScreenState extends State<TravelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TravelService _travelService = TravelService();
  final VehicleService _vehicleService = VehicleService();
  final DriverService _driverService = DriverService();
  final LocationService _locationService = LocationService();

  late TextEditingController _routeNameController;
  late TextEditingController _priceController;

  Location? _selectedOrigin;
  Location? _selectedDestination;
  DateTime? _departureDate;
  TimeOfDay? _departureTime;
  DateTime? _arrivalDate;
  TimeOfDay? _arrivalTime;

  int? _selectedVehicleId;
  int? _selectedDriverId;
  int _totalSeats = 0;
  String _status = 'scheduled';

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  List<Location> _locations = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _routeNameController = TextEditingController(
      text: widget.travel?.routeName ?? '',
    );
    _priceController = TextEditingController(
      text: widget.travel?.price.toString() ?? '',
    );

    if (widget.travel != null) {
      _selectedVehicleId = widget.travel!.vehicleId;
      _selectedDriverId = widget.travel!.driverId;
      _totalSeats = widget.travel!.totalSeats;
      _status = widget.travel!.status;

      // Parse departure date & time
      if (widget.travel!.departureTime != null) {
        _departureDate = DateTime(
          widget.travel!.departureTime!.year,
          widget.travel!.departureTime!.month,
          widget.travel!.departureTime!.day,
        );
        _departureTime = TimeOfDay.fromDateTime(widget.travel!.departureTime!);
      }

      // Parse arrival date & time
      if (widget.travel!.arrivalTime != null) {
        _arrivalDate = DateTime(
          widget.travel!.arrivalTime!.year,
          widget.travel!.arrivalTime!.month,
          widget.travel!.arrivalTime!.day,
        );
        _arrivalTime = TimeOfDay.fromDateTime(widget.travel!.arrivalTime!);
      }
    }

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      final drivers = await _driverService.getDrivers();
      final locations = await _locationService.getLocations();

      print('Loaded ${vehicles.length} vehicles');
      print('Loaded ${drivers.length} drivers');
      print('Loaded ${locations.length} locations');

      setState(() {
        _vehicles = vehicles;
        _drivers = drivers;
        _locations = locations;
        _isLoadingData = false;
      });
    } catch (e) {
      print('Error in _loadData: $e');
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _updateRouteName() {
    if (_selectedOrigin != null && _selectedDestination != null) {
      setState(() {
        _routeNameController.text =
            '${_selectedOrigin!.name} - ${_selectedDestination!.name}';
      });
    }
  }

  void _updateSeats() {
    if (_selectedVehicleId != null) {
      final vehicle = _vehicles.firstWhere((v) => v.id == _selectedVehicleId);
      setState(() {
        _totalSeats = vehicle.seatCapacity;
      });
    }
  }

  void _estimateArrivalTime() {
    if (_selectedOrigin != null &&
        _selectedDestination != null &&
        _departureDate != null &&
        _departureTime != null) {
      final duration = _locationService.estimateTravelTime(
        _selectedOrigin!,
        _selectedDestination!,
      );

      final departureDateTime = DateTime(
        _departureDate!.year,
        _departureDate!.month,
        _departureDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );

      final arrivalDateTime = departureDateTime.add(duration);

      setState(() {
        _arrivalDate = DateTime(
          arrivalDateTime.year,
          arrivalDateTime.month,
          arrivalDateTime.day,
        );
        _arrivalTime = TimeOfDay.fromDateTime(arrivalDateTime);
      });
    }
  }

  Future<bool> _checkScheduleConflict() async {
    if (_selectedVehicleId == null ||
        _departureDate == null ||
        _departureTime == null) {
      return false;
    }

    final departureDateTime = DateTime(
      _departureDate!.year,
      _departureDate!.month,
      _departureDate!.day,
      _departureTime!.hour,
      _departureTime!.minute,
    );

    try {
      final travels = await _travelService.getTravels();

      for (var travel in travels) {
        // Skip current travel if editing
        if (widget.travel != null && travel.id == widget.travel!.id) {
          continue;
        }

        // Check same vehicle
        if (travel.vehicleId == _selectedVehicleId) {
          // Check if departure time is within 4 hours
          final timeDiff = departureDateTime
              .difference(travel.departureTime)
              .inHours
              .abs();
          if (timeDiff < 4) {
            return true; // Conflict found
          }
        }
      }
      return false; // No conflict
    } catch (e) {
      print('Error checking schedule conflict: $e');
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isDeparture
          ? (_departureDate ?? DateTime.now())
          : (_arrivalDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isDeparture) {
          _departureDate = pickedDate;
        } else {
          _arrivalDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isDeparture
          ? (_departureTime ?? TimeOfDay.now())
          : (_arrivalTime ?? TimeOfDay.now()),
    );

    if (pickedTime != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = pickedTime;
          // Auto estimate arrival time when departure time is set
          _estimateArrivalTime();
        } else {
          _arrivalTime = pickedTime;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validation checks
    if (_selectedOrigin == null || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih lokasi asal dan tujuan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kendaraan terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih driver terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_departureDate == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan jam keberangkatan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check schedule conflict
    final hasConflict = await _checkScheduleConflict();
    if (hasConflict) {
      if (mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Peringatan Jadwal'),
              ],
            ),
            content: const Text(
              'Kendaraan ini sudah memiliki jadwal di waktu yang berdekatan (dalam 4 jam). '
              'Yakin ingin melanjutkan?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        );

        if (confirm != true) return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final departureDateTime = DateTime(
        _departureDate!.year,
        _departureDate!.month,
        _departureDate!.day,
        _departureTime!.hour,
        _departureTime!.minute,
      );

      DateTime? arrivalDateTime;
      if (_arrivalDate != null && _arrivalTime != null) {
        arrivalDateTime = DateTime(
          _arrivalDate!.year,
          _arrivalDate!.month,
          _arrivalDate!.day,
          _arrivalTime!.hour,
          _arrivalTime!.minute,
        );
      }

      final travelData = {
        'vehicle_id': _selectedVehicleId,
        'driver_id': _selectedDriverId,
        'route_name': _routeNameController.text.trim(),
        'origin': _selectedOrigin!.name,
        'destination': _selectedDestination!.name,
        'departure_time': departureDateTime.toIso8601String(),
        'arrival_time': arrivalDateTime?.toIso8601String(),
        'price': double.parse(_priceController.text.trim()),
        'total_seats': _totalSeats,
        'status': _status,
      };

      if (widget.travel == null) {
        await _travelService.createTravel(travelData);
      } else {
        await _travelService.updateTravel(widget.travel!.id, travelData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.travel == null
                  ? '✓ Perjalanan berhasil ditambahkan'
                  : '✓ Perjalanan berhasil diupdate',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.travel == null ? 'Tambah Perjalanan' : 'Edit Perjalanan',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Route Info
            _buildSectionCard(
              title: 'Informasi Rute',
              icon: Icons.route,
              children: [
                _buildLocationAutocomplete(
                  label: 'Asal',
                  icon: Icons.location_on,
                  selectedLocation: _selectedOrigin,
                  onSelected: (location) {
                    setState(() {
                      _selectedOrigin = location;
                      _updateRouteName();
                      if (_selectedDestination != null &&
                          _departureTime != null) {
                        _estimateArrivalTime();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildLocationAutocomplete(
                  label: 'Tujuan',
                  icon: Icons.flag,
                  selectedLocation: _selectedDestination,
                  onSelected: (location) {
                    setState(() {
                      _selectedDestination = location;
                      _updateRouteName();
                      if (_selectedOrigin != null && _departureTime != null) {
                        _estimateArrivalTime();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Rute (Otomatis)',
                    hintText: 'Pilih asal dan tujuan',
                    prefixIcon: const Icon(Icons.label, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  readOnly: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vehicle & Driver
            _buildSectionCard(
              title: 'Kendaraan & Driver',
              icon: Icons.directions_car,
              children: [
                _buildVehicleDropdown(),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event_seat, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Kapasitas: $_totalSeats kursi',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDriverDropdown(),
              ],
            ),
            const SizedBox(height: 16),

            // Schedule
            _buildSectionCard(
              title: 'Jadwal',
              icon: Icons.schedule,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Tanggal Berangkat',
                        date: _departureDate,
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeField(
                        label: 'Jam Berangkat',
                        time: _departureTime,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context, true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Tanggal Tiba (Estimasi)',
                        date: _arrivalDate,
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeField(
                        label: 'Jam Tiba (Estimasi)',
                        time: _arrivalTime,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price
            _buildSectionCard(
              title: 'Harga Tiket',
              icon: Icons.attach_money,
              children: [
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Harga per Kursi',
                    hintText: '50000',
                    prefixIcon: const Icon(Icons.money, size: 20),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga harus diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAutocomplete({
    required String label,
    required IconData icon,
    required Location? selectedLocation,
    required Function(Location) onSelected,
  }) {
    return Autocomplete<Location>(
      initialValue: TextEditingValue(text: selectedLocation?.displayName ?? ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _locations.where((loc) => loc.isPopular).take(10);
        }
        final searchText = textEditingValue.text.toLowerCase();
        return _locations
            .where((location) {
              return location.name.toLowerCase().contains(searchText) ||
                  (location.parentName?.toLowerCase().contains(searchText) ??
                      false);
            })
            .take(20);
      },
      displayStringForOption: (Location option) => option.displayName,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (selectedLocation != null &&
                textEditingController.text.isEmpty) {
              textEditingController.text = selectedLocation.displayName;
            }
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, size: 20),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          textEditingController.clear();
                        },
                      )
                    : const Icon(Icons.arrow_drop_down, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Ketik untuk mencari...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Wajib diisi';
                }
                final exists = _locations.any(
                  (loc) => loc.displayName.toLowerCase() == value.toLowerCase(),
                );
                if (!exists) {
                  return 'Pilih lokasi dari daftar';
                }
                return null;
              },
            );
          },
      onSelected: (Location selection) {
        onSelected(selection);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final location = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      location.type == 'city'
                          ? Icons.location_city
                          : Icons.place,
                      size: 18,
                      color: location.isPopular ? Colors.orange : Colors.grey,
                    ),
                    title: Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: location.parentName != null
                        ? Text(
                            location.parentName!,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    onTap: () => onSelected(location),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedVehicleId,
      decoration: InputDecoration(
        labelText: 'Kendaraan',
        prefixIcon: const Icon(Icons.directions_car, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _vehicles.map((vehicle) {
        return DropdownMenuItem<int>(
          value: vehicle.id,
          child: Text(
            '${vehicle.brand} ${vehicle.model} - ${vehicle.plateNumber} (${vehicle.seatCapacity} kursi)',
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVehicleId = value;
          _updateSeats();
        });
      },
      validator: (value) {
        if (value == null) return 'Pilih kendaraan';
        return null;
      },
    );
  }

  Widget _buildDriverDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedDriverId,
      decoration: InputDecoration(
        labelText: 'Driver',
        prefixIcon: const Icon(Icons.person, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _drivers.map((driver) {
        return DropdownMenuItem<int>(
          value: driver.id,
          child: Text('${driver.name} - ${driver.licenseType}'),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDriverId = value),
      validator: (value) {
        if (value == null) return 'Driver harus dipilih';
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          date != null
              ? DateFormat('dd MMM yyyy').format(date)
              : 'Pilih tanggal',
          style: TextStyle(color: date != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          time != null ? time.format(context) : 'Pilih jam',
          style: TextStyle(color: time != null ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.travel == null
                        ? 'Tambah Perjalanan'
                        : 'Update Perjalanan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
