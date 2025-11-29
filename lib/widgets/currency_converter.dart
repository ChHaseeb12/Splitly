import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class CurrencyConverter extends StatefulWidget {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final bool showRate;

  const CurrencyConverter({
    super.key,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    this.showRate = true,
  });

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  double? _convertedAmount;
  double? _exchangeRate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _convertCurrency();
  }

  @override
  void didUpdateWidget(CurrencyConverter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.fromCurrency != widget.fromCurrency ||
        oldWidget.toCurrency != widget.toCurrency) {
      _convertCurrency();
    }
  }

  Future<void> _convertCurrency() async {
    if (widget.fromCurrency == widget.toCurrency) {
      setState(() {
        _convertedAmount = widget.amount;
        _exchangeRate = 1.0;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currencyProvider = context.read<CurrencyProvider>();

    final rate = await currencyProvider.getExchangeRate(
      widget.fromCurrency,
      widget.toCurrency,
    );

    if (rate != null) {
      setState(() {
        _exchangeRate = rate;
        _convertedAmount = widget.amount * rate;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();

    if (_isLoading) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Converting...', style: TextStyle(fontSize: 12)),
        ],
      );
    }

    if (_convertedAmount == null) {
      return const Text(
        'Conversion unavailable',
        style: TextStyle(fontSize: 12, color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          currencyProvider.formatAmount(_convertedAmount!, widget.toCurrency),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (widget.showRate && _exchangeRate != null) ...[
          const SizedBox(height: 4),
          Text(
            '1 ${widget.fromCurrency} = ${_exchangeRate!.toStringAsFixed(4)} ${widget.toCurrency}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          if (currencyProvider.lastUpdated != null) ...[
            const SizedBox(height: 2),
            Text(
              'Updated: ${_formatDate(currencyProvider.lastUpdated!)}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
