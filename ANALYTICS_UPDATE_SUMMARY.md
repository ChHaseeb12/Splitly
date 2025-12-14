# Analytics Update Summary

## Overview
Updated the analytics system to properly handle group deletions and show accurate spending summaries with current debt balances.

## Changes Made

### 1. Updated `SpendingSummary` Model
**File:** `lib/models/analytics_models.dart`

Added new field:
- `expensesCreated` - Number of expenses created by the user (where they were the payer)

### 2. Updated `AnalyticsService`
**File:** `lib/services/analytics_service.dart`

#### `getSpendingSummary()` Method
- **Filter Deleted Groups**: Now checks if groups still exist before including their expenses in calculations
- **Accurate Debt Balances**: Uses current debt balances from the `debts` collection instead of calculating from expenses
  - `totalOwed` - Current amount user owes (from debts collection)
  - `totalLent` - Current amount user is owed (from debts collection)
  - `totalSpent` - Total amount user actually paid (sum of expenses where user was payer)
  - `expensesCreated` - Count of expenses created by user
- **Automatic Subtraction**: When a group is deleted, its expenses are removed from Firestore, so they won't be counted

#### `getCategorySpending()` Method
- Added filtering to exclude expenses from deleted groups
- Now properly counts expenses per category

#### `getSpendingTrend()` Method
- Added filtering to exclude expenses from deleted groups
- Ensures trend charts only show data from existing groups

### 3. Updated `SpendingSummaryCard` Widget
**File:** `lib/widgets/spending_summary_card.dart`

Enhanced display to show:
- **Total Spent** - Amount user paid (changed icon to wallet)
- **You Owe** - Current debt balance (what user owes to others)
- **You Are Owed** - Current debt balance (what others owe to user)
- **Net Balance** - Difference between owed and lent
- **Total Expenses** - Count of all expenses user participated in
- **Expenses Created** - Count of expenses user created (new field, only shown if > 0)

## How It Works

### Group Deletion Flow
1. When a group is deleted via `GroupService.deleteGroup()`:
   - All expenses in the group are deleted from Firestore
   - The group document is deleted from Firestore

2. When analytics are calculated:
   - The service queries all expenses for the user
   - It checks which groups still exist in Firestore
   - Expenses from deleted groups are filtered out
   - Only expenses from existing groups are included in calculations

### Debt Balance Accuracy
Instead of calculating debt from expenses (which can be inaccurate after settlements or group deletions), the system now:
1. Queries the `debts` collection for current balances
2. Shows actual amounts owed and lent
3. Automatically reflects changes when:
   - Groups are deleted (debts are cleaned up)
   - Settlements are made (debts are updated)
   - Expenses are added/removed (debts are recalculated)

## Benefits

1. **Accurate After Group Deletion**: When you delete a group, the spending summary automatically subtracts:
   - Expenses from that group
   - Amounts spent in that group
   - Debts from that group

2. **Real-Time Debt Balances**: Shows current debt status, not historical calculations

3. **Better Insights**: 
   - See how much you actually spent (paid)
   - See how many expenses you created
   - Understand your net financial position

4. **Consistent Data**: All analytics (summary, categories, trends) use the same filtering logic

## Example Scenario

**Before Update:**
- User creates 10 expenses in Group A, spending $500
- User deletes Group A
- Analytics still showed $500 spent and 10 expenses

**After Update:**
- User creates 10 expenses in Group A, spending $500
- User deletes Group A
- Analytics now shows $0 spent and 0 expenses
- "You Owe" and "You Are Owed" reflect current debt balances only

## Technical Details

### Filtering Logic
```dart
// Get all group IDs from expenses
final groupIds = expenses
    .where((e) => e.groupId != null)
    .map((e) => e.groupId!)
    .toSet()
    .toList();

// Check which groups still exist
final existingGroupIds = <String>{};
if (groupIds.isNotEmpty) {
  final groupDocs = await _firestore
      .collection('groups')
      .where(FieldPath.documentId, whereIn: groupIds)
      .get();
  existingGroupIds.addAll(groupDocs.docs.map((doc) => doc.id));
}

// Filter expenses
final validExpenses = expenses.where((expense) {
  if (expense.groupId == null) return true; // Personal expenses
  return existingGroupIds.contains(expense.groupId); // Group expenses
}).toList();
```

### Debt Balance Query
```dart
// Get current debts
final owedDebts = await _firestore
    .collection('debts')
    .where('fromUserId', isEqualTo: userId)
    .get();

final lentDebts = await _firestore
    .collection('debts')
    .where('toUserId', isEqualTo: userId)
    .get();

// Calculate current balances
double currentOwed = owedDebts.docs
    .map((doc) => DebtModel.fromJson({...doc.data(), 'debtId': doc.id}))
    .fold(0.0, (sum, debt) => sum + debt.amount);

double currentLent = lentDebts.docs
    .map((doc) => DebtModel.fromJson({...doc.data(), 'debtId': doc.id}))
    .fold(0.0, (sum, debt) => sum + debt.amount);
```

## Files Modified

1. `lib/models/analytics_models.dart` - Added `expensesCreated` field
2. `lib/services/analytics_service.dart` - Updated all analytics methods
3. `lib/widgets/spending_summary_card.dart` - Enhanced display

## Testing

The changes maintain backward compatibility:
- Existing analytics queries still work
- New field `expensesCreated` defaults to 0 if not provided
- All existing tests should pass

## Future Enhancements

Potential improvements:
1. Add "Settled Debts" tracking
2. Show deleted group history (optional)
3. Add date range comparison
4. Export analytics reports
5. Budget vs actual spending comparison

---

**Status:** ✅ Complete  
**Date:** December 14, 2025  
**Impact:** High - Fixes critical analytics accuracy issue
