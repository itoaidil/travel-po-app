import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final VehicleService _vehicleService = VehicleService();

  late TextEditingController _vehicleNumberController;
  late TextEditingController _plateNumberController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _capacityController;

  String _status = 'available';
  bool _isLoading = false;

  // Daftar tipe kendaraan di Indonesia
  final List<String> _vehicleTypes = [
    'Bus Besar',
    'Bus Medium',
    'Bus Pariwisata',
    'Minibus',
    'Microbus',
    'Van',
    'Elf',
    'Hiace',
    'Travel',
    'MPV',
    'SUV',
    'Mobil Sedan',
  ];

  // Daftar merek kendaraan populer di Indonesia
  final List<String> _vehicleBrands = [
    // Merek Jepang
    'Toyota',
    'Honda',
    'Suzuki',
    'Mitsubishi',
    'Nissan',
    'Daihatsu',
    'Mazda',
    'Isuzu',
    'Lexus',
    'Infiniti',
    // Merek Korea
    'Hyundai',
    'Kia',
    // Merek China
    'Wuling',
    'DFSK',
    'Chery',
    'Haval',
    'ORA',
    'BYD',
    'Neta',
    'Seres',
    // Merek Eropa - Jerman
    'Mercedes-Benz',
    'BMW',
    'Audi',
    'Volkswagen',
    'Porsche',
    'Mini',
    // Merek Eropa - Inggris
    'Land Rover',
    'Range Rover',
    'Jaguar',
    'Rolls Royce',
    'Bentley',
    // Merek Eropa - Italia
    'Fiat',
    'Alfa Romeo',
    'Ferrari',
    'Lamborghini',
    'Maserati',
    // Merek Eropa - Prancis
    'Renault',
    'Peugeot',
    'Citroën',
    // Merek Amerika
    'Ford',
    'Chevrolet',
    'Tesla',
    // Merek Bus/Truck
    'Hino',
    'Scania',
    'Volvo',
    'MAN',
  ];

  // Daftar model kendaraan populer
  final List<String> _vehicleModels = [
    // Toyota
    'Hiace',
    'Hiace Commuter',
    'Fortuner',
    'Innova',
    'Innova Reborn',
    'Avanza',
    'Rush',
    'Alphard',
    'Vellfire',
    'Camry',
    'Corolla',
    // Mercedes-Benz
    'OH 1526',
    'OH 1836',
    'OF 917',
    'Sprinter',
    // Hino
    'RK8',
    'RN285',
    'FC9J',
    'Dutro',
    // Isuzu
    'Elf',
    'Elf Long',
    'Giga',
    'NMR 71',
    'NKR 55',
    // Mitsubishi
    'Fuso',
    'Colt Diesel',
    'L300',
    'Pajero',
    'Xpander',
    'Triton',
    // Suzuki
    'APV',
    'Ertiga',
    'Carry',
    // Daihatsu
    'Gran Max',
    'Luxio',
    'Terios',
    'Xenia',
    // Hyundai
    'H1',
    'Starex',
    'Universe',
    // Nissan
    'Evalia',
    'Serena',
    'Elgrand',
    // Lainnya
    'Bus Pariwisata',
    'Medium Bus',
  ];

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController(
      text: widget.vehicle?.vehicleNumber ?? '',
    );
    _plateNumberController = TextEditingController(
      text: widget.vehicle?.plateNumber ?? '',
    );
    _vehicleTypeController = TextEditingController(
      text: widget.vehicle?.vehicleType ?? '',
    );
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
      text: widget.vehicle?.year.toString() ?? '',
    );
    _capacityController = TextEditingController(
      text: widget.vehicle?.capacity.toString() ?? '',
    );

    if (widget.vehicle != null) {
      _status = widget.vehicle!.status;
    }
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _plateNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua field yang wajib diisi'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Additional validation for fields that might be empty
    final vehicleNumber = _vehicleNumberController.text.trim();
    final plateNumber = _plateNumberController.text.trim();
    final vehicleType = _vehicleTypeController.text.trim();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final yearText = _yearController.text.trim();
    final capacityText = _capacityController.text.trim();

    // Check if any required field is empty
    if (vehicleNumber.isEmpty) {
      _showError('Nomor kendaraan harus diisi');
      return;
    }
    if (plateNumber.isEmpty) {
      _showError('Plat nomor harus diisi');
      return;
    }
    if (vehicleType.isEmpty) {
      _showError('Tipe kendaraan harus diisi');
      return;
    }
    if (brand.isEmpty) {
      _showError('Merek harus diisi');
      return;
    }
    if (model.isEmpty) {
      _showError('Model harus diisi');
      return;
    }
    if (yearText.isEmpty) {
      _showError('Tahun harus diisi');
      return;
    }
    if (capacityText.isEmpty) {
      _showError('Kapasitas harus dipilih');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Ensure all string fields have values (not null)
      final vehicleData = {
        'vehicle_number': vehicleNumber.isNotEmpty ? vehicleNumber : '',
        'plate_number': plateNumber.isNotEmpty ? plateNumber.toUpperCase() : '',
        'vehicle_type': vehicleType.isNotEmpty ? vehicleType : '',
        'brand': brand.isNotEmpty ? brand : '',
        'model': model.isNotEmpty ? model : '',
        'year': int.tryParse(yearText) ?? 0,
        'capacity': int.tryParse(capacityText) ?? 0,
        'status': _status,
        'is_active': 1,
      };

      if (widget.vehicle == null) {
        await _vehicleService.createVehicle(vehicleData);
      } else {
        await _vehicleService.updateVehicle(widget.vehicle!.id, vehicleData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.vehicle == null
                  ? '✓ Kendaraan berhasil ditambahkan'
                  : '✓ Kendaraan berhasil diupdate',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.vehicle == null ? 'Tambah Kendaraan' : 'Edit Kendaraan',
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
            // Identitas Kendaraan Section
            _buildSectionCard(
              title: 'Identitas Kendaraan',
              icon: Icons.badge,
              children: [
                _buildTextField(
                  controller: _vehicleNumberController,
                  label: 'Nomor Kendaraan',
                  hint: 'V001, V002, dll',
                  icon: Icons.numbers,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor kendaraan harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _plateNumberController,
                  label: 'Plat Nomor',
                  hint: 'B 1234 ABC',
                  icon: Icons.credit_card,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Plat nomor harus diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Spesifikasi Kendaraan Section
            _buildSectionCard(
              title: 'Spesifikasi Kendaraan',
              icon: Icons.directions_car,
              children: [
                _buildTextField(
                  controller: _vehicleTypeController,
                  label: 'Tipe Kendaraan',
                  hint: 'Bus, Mini Bus, MPV, SUV, Van, dll',
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tipe kendaraan harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _brandController,
                  label: 'Merek',
                  hint: 'Toyota, Mitsubishi, Isuzu, dll',
                  icon: Icons.branding_watermark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Merek harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  hint: 'Avanza, Innova, Ertiga, dll',
                  icon: Icons.model_training,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Model harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _yearController,
                  label: 'Tahun Pembuatan',
                  hint: '2023',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tahun harus diisi';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1990 || year > 2030) {
                      return 'Tahun tidak valid (1990-2030)';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kapasitas & Status Section
            _buildSectionCard(
              title: 'Kapasitas & Status',
              icon: Icons.settings,
              children: [
                _buildCapacityDropdown(),
                const SizedBox(height: 16),
                _buildStatusField(),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
    );
  }

  Widget _buildAutocompleteField({
    required String label,
    required String hint,
    required IconData icon,
    required String initialValue,
    required List<String> options,
    required Function(String) onSelected,
    String? Function(String?)? validator,
  }) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return options;
        }
        return options.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
          onChanged: (value) => onSelected(value),
        );
      },
    );
  }

  Widget _buildCapacityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: DropdownButtonFormField<int>(
        value: _capacityController.text.isEmpty
            ? null
            : int.tryParse(_capacityController.text),
        decoration: InputDecoration(
          labelText: 'Kapasitas Penumpang',
          hintText: 'Pilih jumlah kursi',
          prefixIcon: const Icon(Icons.event_seat, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: List.generate(100, (index) => index + 1).map((capacity) {
          return DropdownMenuItem(
            value: capacity,
            child: Text('$capacity kursi'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _capacityController.text = value.toString();
            });
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Kapasitas harus dipilih';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildStatusField() {
    final List<Map<String, dynamic>> statuses = [
      {'value': 'available', 'label': 'Tersedia', 'color': Colors.green},
      {'value': 'maintenance', 'label': 'Maintenance', 'color': Colors.orange},
      {'value': 'inactive', 'label': 'Tidak Aktif', 'color': Colors.grey},
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Status Kendaraan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ...(statuses.map((status) {
            return RadioListTile<String>(
              value: status['value']!,
              groupValue: _status,
              title: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: status['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(status['label']!, style: const TextStyle(fontSize: 15)),
                ],
              ),
              activeColor: status['color'],
              onChanged: (value) {
                setState(() => _status = value!);
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.vehicle == null ? Icons.add : Icons.save,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.vehicle == null
                        ? 'Tambah Kendaraan'
                        : 'Simpan Perubahan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
