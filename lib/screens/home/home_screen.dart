import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitly/providers/auth_provider.dart';
import 'package:splitly/providers/locale_provider.dart';
import 'package:splitly/providers/sync_provider.dart';
import 'package:splitly/widgets/sync_status_indicator.dart';
import '../friends/friend_list_screen.dart';
import '../groups/group_list_screen.dart';
import '../settings/currency_settings_screen.dart';
import '../settings/language_settings_screen.dart';
import '../settings/sync_settings_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    DashboardScreen(onNavigate: _onItemTapped),
    const FriendListScreen(),
    const GroupListScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Dashboard Screen (Placeholder)
class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          const SyncStatusIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return GestureDetector(
                    onTap: () => _showLogoutConfirmation(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          authProvider.userProfile?.displayName ?? 'User',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Analytics',
                    Icons.analytics,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalyticsDashboardScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Add Expense',
                    Icons.add_circle,
                    Colors.green,
                    () {
                      // Navigate to add expense
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Balances',
                    Icons.account_balance_wallet,
                    Colors.orange,
                    () {
                      // Navigate to balances
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    'Settings',
                    Icons.settings,
                    Colors.purple,
                    () {
                      if (onNavigate != null) onNavigate!(4);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Activity Screen (Placeholder)
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Activity Feed',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in Phase 12',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      userProfile?.displayName.substring(0, 1).toUpperCase() ??
                          'U',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile?.email ?? '',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Settings Section
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Currency Settings
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency Settings'),
              subtitle: Text('Default: ${userProfile?.currency ?? 'USD'}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CurrencySettingsScreen(),
                  ),
                );
              },
            ),
          ),

          // Language Settings
          Card(
            child: Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Language Settings'),
                  subtitle: Text(
                    'Default: ${localeProvider.getLanguageName(userProfile?.language ?? 'en')}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Sync & Offline Settings
          Card(
            child: Consumer<SyncProvider>(
              builder: (context, syncProvider, _) {
                return ListTile(
                  leading: Icon(
                    syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: syncProvider.isOnline ? Colors.green : Colors.grey,
                  ),
                  title: const Text('Sync & Offline'),
                  subtitle: Text(
                    syncProvider.isOnline
                        ? 'Last synced: ${syncProvider.getTimeSinceLastSync()}'
                        : 'Offline mode',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SyncSettingsScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Logout Button
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _showLogoutConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
