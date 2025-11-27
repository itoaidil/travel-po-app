import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/driver.dart';
import '../services/driver_service.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;

  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DriverService _driverService = DriverService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _addressController;
  DateTime? _dateOfBirth;
  DateTime? _licenseExpiry;
  String _licenseType = 'B1';
  String _status = 'active';
  bool _isLoading = false;

  final List<Map<String, String>> _licenseTypes = [
    {'value': 'A', 'label': 'SIM A - Motor'},
    {'value': 'B1', 'label': 'SIM B1 - Mobil Pribadi'},
    {'value': 'B2', 'label': 'SIM B2 - Bus & Truk'},
    {'value': 'C', 'label': 'SIM C - Kendaraan Khusus'},
  ];

  final List<Map<String, dynamic>> _statuses = [
    {'value': 'active', 'label': 'Aktif', 'color': Colors.green},
    {'value': 'on_leave', 'label': 'Cuti', 'color': Colors.orange},
    {'value': 'suspended', 'label': 'Suspend', 'color': Colors.red},
    {'value': 'inactive', 'label': 'Tidak Aktif', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phone ?? '');
    _licenseNumberController = TextEditingController(
      text: widget.driver?.licenseNumber ?? '',
    );
    _emergencyContactController = TextEditingController(
      text: widget.driver?.emergencyContact ?? '',
    );
    _addressController = TextEditingController(
      text: widget.driver?.address ?? '',
    );

    if (widget.driver != null) {
      _dateOfBirth = widget.driver!.dateOfBirth;
      _licenseExpiry = widget.driver!.licenseExpiry;
      _licenseType = widget.driver!.licenseType ?? 'B1';
      _status = widget.driver!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenseNumberController.dispose();
    _emergencyContactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth
          ? (_dateOfBirth ?? DateTime(1990))
          : (_licenseExpiry ?? DateTime.now()),
      firstDate: isDateOfBirth ? DateTime(1950) : DateTime.now(),
      lastDate: isDateOfBirth ? DateTime.now() : DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _licenseExpiry = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final driverData = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'license_number': _licenseNumberController.text.trim(),
        'license_type': _licenseType,
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'date_of_birth': _dateOfBirth?.toIso8601String().split('T')[0],
      };

      print('Sending driver data: $driverData');

      if (widget.driver == null) {
        await _driverService.createDriver(driverData);
      } else {
        await _driverService.updateDriver(widget.driver!.id, driverData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.driver == null
                  ? '✓ Driver berhasil ditambahkan'
                  : '✓ Driver berhasil diupdate',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Driver submit error: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.driver == null ? 'Tambah Driver' : 'Edit Driver',
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
            // Personal Information Card
            _buildSectionCard(
              title: 'Informasi Pribadi',
              icon: Icons.person,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap driver',
                  icon: Icons.badge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'Tanggal Lahir',
                  date: _dateOfBirth,
                  icon: Icons.cake,
                  onTap: () => _selectDate(context, true),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Information Card
            _buildSectionCard(
              title: 'Informasi Kontak',
              icon: Icons.contact_phone,
              children: [
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hint: '08123456789',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor telepon harus diisi';
                    }
                    if (value.length < 10) {
                      return 'Nomor telepon tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emergencyContactController,
                  label: 'Kontak Darurat',
                  hint: '08123456789',
                  icon: Icons.emergency,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Alamat',
                  hint: 'Masukkan alamat lengkap',
                  icon: Icons.home,
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // License Information Card
            _buildSectionCard(
              title: 'Informasi SIM',
              icon: Icons.credit_card,
              children: [
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'Nomor SIM',
                  hint: '1234567890123456',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor SIM harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildLicenseTypeField(),
              ],
            ),
            const SizedBox(height: 16),

            // Status Card
            _buildSectionCard(
              title: 'Status Driver',
              icon: Icons.info_outline,
              children: [_buildStatusField()],
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
    int maxLines = 1,
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
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
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
        child: Text(
          date != null
              ? DateFormat('dd MMMM yyyy').format(date)
              : 'Pilih tanggal',
          style: TextStyle(
            color: date != null ? Colors.black87 : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseTypeField() {
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
                Icon(Icons.credit_card, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Jenis SIM',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ...(_licenseTypes.map((license) {
            return RadioListTile<String>(
              value: license['value']!,
              groupValue: _licenseType,
              title: Text(
                license['label']!,
                style: const TextStyle(fontSize: 15),
              ),
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() => _licenseType = value!);
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildStatusField() {
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
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ...(_statuses.map((status) {
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
                    widget.driver == null ? Icons.add : Icons.save,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.driver == null
                        ? 'Tambah Driver'
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
