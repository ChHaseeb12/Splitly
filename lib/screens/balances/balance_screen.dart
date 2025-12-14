import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/balance_provider.dart';
import '../../providers/auth_provider.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadBalances();
  }

  Future<void> _loadBalances() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final balanceProvider = Provider.of<BalanceProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await balanceProvider.loadDebtsForUser(authProvider.currentUser!.uid);
      print('Loaded ${balanceProvider.debts.length} debts');
      print('Summary balances: ${balanceProvider.summaryBalances}');
    }
  }

  Future<String> _getUserName(String userId) async {
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final name = doc.data()?['displayName'] as String? ?? 'Unknown User';
        _userNames[userId] = name;
        return name;
      }
    } catch (e) {
      // Ignore error and return fallback
    }

    _userNames[userId] = 'Unknown User';
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    final balanceProvider = Provider.of<BalanceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances'),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            icon: Icon(
              balanceProvider.simplificationEnabled
                  ? Icons.compress
                  : Icons.expand,
            ),
            onPressed: () {
              balanceProvider.toggleSimplification();
            },
            tooltip: balanceProvider.simplificationEnabled
                ? 'Show Detailed View'
                : 'Show Simplified View',
          ),
        ],
      ),
      body: balanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : balanceProvider.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading balances',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      balanceProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBalances,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadBalances(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      _buildSummaryCard(
                        balanceProvider,
                        authProvider.currentUser!.uid,
                      ),
                      const SizedBox(height: 24),

                      // Simplification Toggle Info
                      if (balanceProvider.simplificationEnabled)
                        _buildSimplificationInfo(balanceProvider),

                      const SizedBox(height: 16),

                      // Balances List
                      if (balanceProvider.simplificationEnabled)
                        _buildSimplifiedView(
                          balanceProvider,
                          authProvider.currentUser!.uid,
                        )
                      else
                        _buildDetailedView(
                          balanceProvider,
                          authProvider.currentUser!.uid,
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard(BalanceProvider balanceProvider, String userId) {
    double totalOwed = 0;
    double totalOwing = 0;

    for (var entry in balanceProvider.summaryBalances.entries) {
      if (entry.value > 0) {
        totalOwed += entry.value;
      } else {
        totalOwing += entry.value.abs();
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Your Balance Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '\$${totalOwed.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('You are owed'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '\$${totalOwing.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text('You owe'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 8),
            Text(
              'Net Balance: \$${(totalOwed - totalOwing).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: (totalOwed - totalOwing) >= 0
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplificationInfo(BalanceProvider balanceProvider) {
    final savings = balanceProvider.getSimplificationSavings();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debt Simplification Active',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Reduced from ${savings['originalTransactions']} to ${savings['simplifiedTransactions']} transactions (${savings['savingsPercentage']}% savings)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimplifiedView(BalanceProvider balanceProvider, String userId) {
    final suggestions = balanceProvider.getSettlementSuggestions(
      forUserId: userId,
    );

    if (suggestions.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'All settled up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'No outstanding balances',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              'Add expenses in a group to see balances here',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settlement Suggestions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...suggestions.map((transaction) {
          final isUserPaying = transaction.fromUserId == userId;
          final otherUserId = isUserPaying
              ? transaction.toUserId
              : transaction.fromUserId;

          return FutureBuilder<String>(
            future: _getUserName(otherUserId),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? 'Loading...';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUserPaying ? Colors.red : Colors.green,
                    child: Icon(
                      isUserPaying ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    isUserPaying ? 'Pay $userName' : '$userName pays you',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(transaction.currency),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUserPaying ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _showSettleDialog(transaction, userId, userName),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDetailedView(BalanceProvider balanceProvider, String userId) {
    if (balanceProvider.debts.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[300]),
            const SizedBox(height: 16),
            const Text(
              'No debts to show',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'All balances are settled',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              'Add expenses in a group to track balances',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Debts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...balanceProvider.debts.map((debt) {
          final isUserOwing = debt.fromUserId == userId;
          final otherUserId = isUserOwing ? debt.toUserId : debt.fromUserId;

          return FutureBuilder<String>(
            future: _getUserName(otherUserId),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? 'Loading...';

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isUserOwing ? Colors.red : Colors.green,
                    child: Icon(
                      isUserOwing ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    isUserOwing ? 'You owe $userName' : '$userName owes you',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${debt.expenseIds.length} expenses'),
                  trailing: Text(
                    '\$${debt.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isUserOwing ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showSettleDialog(dynamic transaction, String userId, String userName) {
    final isUserPaying = transaction.fromUserId == userId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settle Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUserPaying ? 'Pay $userName' : 'Record payment from $userName',
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final balanceProvider = Provider.of<BalanceProvider>(
                context,
                listen: false,
              );

              // Get both user names
              final fromUserName = await _getUserName(transaction.fromUserId);
              final toUserName = await _getUserName(transaction.toUserId);

              final success = await balanceProvider.settleDebt(
                fromUserId: transaction.fromUserId,
                toUserId: transaction.toUserId,
                amount: transaction.amount,
                currency: transaction.currency,
                fromUserName: fromUserName,
                toUserName: toUserName,
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debt settled successfully')),
                  );
                  _loadBalances();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        balanceProvider.errorMessage ?? 'Failed to settle debt',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Settle'),
          ),
        ],
      ),
    );
  }
}
