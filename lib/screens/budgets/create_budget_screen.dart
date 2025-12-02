import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/budget_model.dart';
import '../../utils/design_system.dart';
import '../../widgets/my_button.dart';
import '../../widgets/my_textfield.dart';

class CreateBudgetScreen extends StatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  State<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends State<CreateBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _selectedPeriod = BudgetPeriod.MONTHLY;
  String? _selectedCategory;

  final List<String> _categories = [
    'FOOD',
    'ENTERTAINMENT',
    'UTILITIES',
    'TRANSPORTATION',
    'SHOPPING',
    'TRAVEL',
    'PERSONAL',
    'HEALTH',
    'SUBSCRIPTION',
    'OTHER',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Budget')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.paddingMD,
          children: [
            // Name
            MyTextfield(
              controller: _nameController,
              hintText: 'Budget Name',
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget name';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Amount
            MyTextfield(
              controller: _amountController,
              hintText: 'Budget Amount',
              obscureText: false,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),

            // Period
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Period',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<BudgetPeriod>(
                      value: _selectedPeriod,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: BudgetPeriod.values.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(_getPeriodText(period)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPeriod = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Category (Optional)
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category (Optional)',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      hint: const Text('All Categories'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

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
                          'About Budgets',
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Budgets help you track your spending over a specific period. '
                      'You\'ll receive alerts when you\'re approaching or exceeding your budget limit. '
                      'You can create budgets for specific categories or for all expenses.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Create Button
            MyButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (authProvider.currentUser == null) return;

                  final budget = BudgetModel(
                    id: FirebaseFirestore.instance
                        .collection('budgets')
                        .doc()
                        .id,
                    userId: authProvider.currentUser!.uid,
                    name: _nameController.text.trim(),
                    amount: double.parse(_amountController.text),
                    currency: 'USD', // TODO: Use user's default currency
                    period: _selectedPeriod,
                    category: _selectedCategory,
                    startDate: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  await budgetProvider.createBudget(budget);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Budget created successfully'),
                      ),
                    );
                  }
                }
              },
              text: 'Create Budget',
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.DAILY:
        return 'Daily';
      case BudgetPeriod.WEEKLY:
        return 'Weekly';
      case BudgetPeriod.MONTHLY:
        return 'Monthly';
      case BudgetPeriod.QUARTERLY:
        return 'Quarterly';
      case BudgetPeriod.YEARLY:
        return 'Yearly';
      case BudgetPeriod.CUSTOM:
        return 'Custom';
    }
  }
}
