import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/stat_card.dart';
import 'vehicles_screen.dart';
import 'drivers_screen.dart';
import 'travels_screen.dart';
import 'bookings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardHome(),
    const VehiclesScreen(),
    const DriversScreen(),
    const TravelsScreen(),
    const BookingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final po = authProvider.currentPO;
    final isDesktop = AppBreakpoints.isDesktop(context);

    if (isDesktop) {
      // Desktop layout with side navigation
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              extended: true,
              labelType: NavigationRailLabelType.none,
              leading: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      size: 40,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      po?.name ?? 'PO Partner',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.directions_bus),
                  label: Text('Kendaraan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Driver'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.schedule),
                  label: Text('Jadwal'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long),
                  label: Text('Booking'),
                ),
              ],
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => _handleLogout(context),
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        appBar: AppBar(
          title: Text(po?.name ?? 'PO Partner'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.directions_bus),
              label: 'Kendaraan',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Driver'),
            NavigationDestination(icon: Icon(Icons.schedule), label: 'Jadwal'),
            NavigationDestination(
              icon: Icon(Icons.receipt_long),
              label: 'Booking',
            ),
          ],
        ),
      );
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final po = authProvider.currentPO;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            'Selamat Datang, ${po?.name ?? "Partner"}!',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${_getStatusLabel(po?.status)}',
            style: AppTextStyles.body2.copyWith(
              color: _getStatusColor(po?.status),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final crossAxisCount = isDesktop ? 4 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Total Kendaraan',
                    value: '12',
                    icon: Icons.directions_bus,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'Total Driver',
                    value: '18',
                    icon: Icons.person,
                    color: AppColors.success,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'Booking Hari Ini',
                    value: '24',
                    icon: Icons.receipt_long,
                    color: AppColors.warning,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'Pendapatan Bulan Ini',
                    value: 'Rp 45 Jt',
                    icon: Icons.payments,
                    color: AppColors.info,
                    onTap: () {},
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // Quick Actions
          Text('Menu Cepat', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickAction(
                context,
                icon: Icons.add_circle,
                label: 'Tambah Kendaraan',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.person_add,
                label: 'Tambah Driver',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.event,
                label: 'Buat Jadwal',
                onTap: () {},
              ),
              _buildQuickAction(
                context,
                icon: Icons.assessment,
                label: 'Lihat Laporan',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'approved':
        return '✓ Disetujui';
      case 'pending':
        return '⏳ Menunggu Verifikasi';
      case 'rejected':
        return '✗ Ditolak';
      case 'suspended':
        return '⚠ Ditangguhkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'suspended':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}
