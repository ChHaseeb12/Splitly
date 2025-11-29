import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../models/currency_model.dart';

class CurrencySelector extends StatefulWidget {
  final String selectedCurrency;
  final Function(String) onCurrencySelected;
  final bool showPopular;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    this.showPopular = true,
  });

  @override
  State<CurrencySelector> createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyModel> _filteredCurrencies = [];

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = context.read<CurrencyProvider>().getAllCurrencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies(String query) {
    setState(() {
      _filteredCurrencies = context.read<CurrencyProvider>().searchCurrencies(
        query,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final selectedCurrencyModel = currencyProvider.getCurrency(
      widget.selectedCurrency,
    );

    return GestureDetector(
      onTap: () => _showCurrencyPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCurrencyModel != null) ...[
              Text(
                selectedCurrencyModel.flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                selectedCurrencyModel.code,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                selectedCurrencyModel.symbol,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ] else ...[
              Text(
                widget.selectedCurrency,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Currency',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search currency...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _filterCurrencies,
                    ),
                  ],
                ),
              ),

              // Popular currencies (if enabled)
              if (widget.showPopular && _searchController.text.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Popular Currencies',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                ...context.read<CurrencyProvider>().getPopularCurrencies().map((
                  code,
                ) {
                  final currency = context.read<CurrencyProvider>().getCurrency(
                    code,
                  );
                  if (currency == null) return const SizedBox.shrink();
                  return _buildCurrencyTile(currency, isPopular: true);
                }),
                Divider(color: Colors.grey.shade200, thickness: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Currencies',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],

              // Currency list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    return _buildCurrencyTile(_filteredCurrencies[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrencyTile(CurrencyModel currency, {bool isPopular = false}) {
    final isSelected = currency.code == widget.selectedCurrency;

    return ListTile(
      leading: Text(currency.flag, style: const TextStyle(fontSize: 32)),
      title: Text(
        currency.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text('${currency.code} • ${currency.symbol}'),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : null,
      onTap: () {
        widget.onCurrencySelected(currency.code);
        Navigator.pop(context);
      },
    );
  }
}
