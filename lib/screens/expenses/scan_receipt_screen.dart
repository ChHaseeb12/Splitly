import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/receipt_scanner_service.dart';
import '../../utils/design_system.dart';
import '../../widgets/my_button.dart';
import '../../widgets/loading_state.dart';

class ScanReceiptScreen extends StatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  State<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends State<ScanReceiptScreen> {
  final ReceiptScannerService _scannerService = ReceiptScannerService();
  ReceiptData? _receiptData;
  bool _isScanning = false;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _scanFromCamera() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final data = await _scannerService.scanFromCamera();
      setState(() {
        _receiptData = data;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning receipt: $e')));
      }
    }
  }

  Future<void> _scanFromGallery() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final data = await _scannerService.scanFromGallery();
      setState(() {
        _receiptData = data;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error scanning receipt: $e')));
      }
    }
  }

  void _useReceiptData() {
    if (_receiptData != null) {
      Navigator.pop(context, _receiptData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: _isScanning
          ? const LoadingState(message: 'Scanning receipt...')
          : _receiptData == null
          ? _buildScanOptions()
          : _buildReceiptPreview(),
    );
  }

  Widget _buildScanOptions() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 120,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Scan Receipt',
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Take a photo or select an image of your receipt to automatically extract expense details',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            MyButton(onPressed: _scanFromCamera, text: 'Take Photo'),
            SizedBox(height: AppSpacing.md),
            MyButton(onPressed: _scanFromGallery, text: 'Choose from Gallery'),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptPreview() {
    return ListView(
      padding: AppSpacing.paddingMD,
      children: [
        // Receipt Image
        if (_receiptData!.imagePath.isNotEmpty)
          Card(
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              File(_receiptData!.imagePath),
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: AppSpacing.md),

        // Extracted Data
        Card(
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Extracted Information', style: AppTypography.h4),
                SizedBox(height: AppSpacing.md),

                // Amount
                if (_receiptData!.amount != null) ...[
                  _buildDataRow(
                    'Amount',
                    '\$${_receiptData!.amount!.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  const Divider(),
                ],

                // Date
                if (_receiptData!.date != null) ...[
                  _buildDataRow(
                    'Date',
                    '${_receiptData!.date!.day}/${_receiptData!.date!.month}/${_receiptData!.date!.year}',
                    Icons.calendar_today,
                  ),
                  const Divider(),
                ],

                // Merchant
                if (_receiptData!.merchant != null) ...[
                  _buildDataRow(
                    'Merchant',
                    _receiptData!.merchant!,
                    Icons.store,
                  ),
                  const Divider(),
                ],

                // Items
                if (_receiptData!.items.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Items (${_receiptData!.items.length})',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ..._receiptData!.items.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // Information
        Card(
          color: AppColors.info.withValues(alpha: 0.1),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Note',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'The extracted information may not be 100% accurate. '
                  'Please review and edit the details before creating the expense.',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _receiptData = null;
                  });
                },
                child: const Text('Scan Again'),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: MyButton(onPressed: _useReceiptData, text: 'Use Data'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
