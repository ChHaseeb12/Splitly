import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/currency_selector.dart';
import '../../services/auth_service.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
  }

  Future<void> _loadCurrentCurrency() async {
    final userProfile = context.read<AuthProvider>().userProfile;
    if (userProfile != null) {
      setState(() {
        _selectedCurrency = userProfile.currency;
      });
    }
  }

  Future<void> _updateDefaultCurrency(String currency) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      if (currentUser != null) {
        await _authService.updateUserProfile(
          uid: currentUser.uid,
          currency: currency,
        );

        // Update local state
        context.read<CurrencyProvider>().setDefaultCurrency(currency);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Default currency updated')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRates() async {
    final currencyProvider = context.read<CurrencyProvider>();
    await currencyProvider.refreshRates(_selectedCurrency ?? 'USD');

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exchange rates refreshed')));
    }
  }

  Future<void> _clearCache() async {
    final currencyProvider = context.read<CurrencyProvider>();
    await currencyProvider.clearCache();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Currency Settings'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Default Currency Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Default Currency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This currency will be used for displaying balances and converting amounts.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_selectedCurrency != null)
                          CurrencySelector(
                            selectedCurrency: _selectedCurrency!,
                            onCurrencySelected: (currency) {
                              setState(() {
                                _selectedCurrency = currency;
                              });
                              _updateDefaultCurrency(currency);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Exchange Rates Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Exchange Rates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Exchange rates are updated daily and cached for offline use.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (currencyProvider.lastUpdated != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Last updated: ${_formatDateTime(currencyProvider.lastUpdated!)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: currencyProvider.isLoading
                                    ? null
                                    : _refreshRates,
                                icon: currencyProvider.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh),
                                label: const Text('Refresh Rates'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearCache,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Clear Cache'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Information Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Currency Conversion',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.info_outline,
                          'Exchange rates are provided by exchangerate.host',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.update,
                          'Rates are cached for 24 hours to reduce API calls',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.offline_bolt,
                          'Cached rates are available offline',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.warning_amber,
                          'Rates may vary from actual bank rates',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Supported Currencies
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Supported Currencies',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${currencyProvider.getAllCurrencies().length} currencies supported',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: currencyProvider.getPopularCurrencies().map(
                            (code) {
                              final currency = currencyProvider.getCurrency(
                                code,
                              );
                              if (currency == null)
                                return const SizedBox.shrink();
                              return Chip(
                                avatar: Text(currency.flag),
                                label: Text(currency.code),
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
