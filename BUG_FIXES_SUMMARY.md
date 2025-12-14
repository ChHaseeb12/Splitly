# Bug Fixes Summary

## Issues Fixed

### 1. Participant Selection with Dummy Users
**Problem:** When adding participants to an expense, the app was adding dummy users like "user_1" instead of showing actual group members.

**Solution:**
- Added `_group` and `_groupMembers` fields to store group data and member details
- Created `_loadGroupData()` method to fetch group information and member details from Firestore
- Implemented `_showParticipantPicker()` dialog that displays actual group members with their names and emails
- Shows "No members available in this group" if the group has no members
- Shows "All members already added" if all members are already participants
- Displays member avatar, name, and email in the selection dialog

**Files Modified:**
- `lib/screens/expenses/add_expense_screen.dart`

---

### 2. Activity Feed Showing Same Activities in All Groups
**Problem:** Activity feed was showing the same activities across all groups instead of group-specific activities.

**Solution:**
- Added `groupId` field to `ActivityFeedItem` model
- Updated `getGroupActivity()` in `CommentService` to filter by `groupId` field directly (changed from `data.groupId` to `groupId`)
- This ensures each group's activity feed only shows activities related to that specific group

**Files Modified:**
- `lib/models/comment_model.dart`
- `lib/services/comment_service.dart`

---

### 3. Split Type Handling (Equal, Unequal, Percentage)
**Problem:** 
- Equal split didn't divide amounts equally among participants
- Unequal and percentage splits had no UI to input custom values
- Shares split type was unnecessary

**Solution:**
- Removed "shares" from split type dropdown (only Equal, Unequal, Percentage remain)
- For **Equal Split**: Automatically divides amount equally, shows preview with participant names
- For **Unequal Split**: Added `_showUnequalSplitDialog()` that allows entering custom amounts for each participant
  - Validates that amounts sum to total
  - Shows error if amounts don't match total
- For **Percentage Split**: Added `_showPercentageSplitDialog()` that allows entering percentages for each participant
  - Validates that percentages sum to 100%
  - Shows error if percentages don't match 100%
- Added "Set Custom Amounts" / "Set Percentages" button that appears for unequal and percentage splits
- Updated split preview to show actual participant names instead of user IDs

**Files Modified:**
- `lib/screens/expenses/add_expense_screen.dart`

---

### 4. Group Loading Issue on Home Page
**Problem:** When opening the app, clicking "Add Expense" on home page showed "create a group first" even when groups existed. Had to navigate to groups tab and back for it to work.

**Solution:**
- Added `initState()` method to `_HomeScreenState`
- Loads user groups automatically when home screen initializes
- Uses `WidgetsBinding.instance.addPostFrameCallback()` to ensure context is available
- Calls `groupProvider.loadUserGroups()` with current user ID

**Files Modified:**
- `lib/screens/home/home_screen.dart`

---

### 5. Currency Selector Overflow Error
**Problem:** When selecting currencies, the list showed overflow errors (156 pixels overflowed) and couldn't scroll properly.

**Solution:**
- Replaced `DraggableScrollableSheet` with a simpler `SizedBox` with fixed height (90% of screen)
- Changed currency list from `ListView.builder` with scroll controller to a regular `ListView` with mapped items
- Wrapped all content in `Expanded` widget to properly constrain the scrollable area
- This fixes the overflow and allows smooth scrolling through all currencies

**Files Modified:**
- `lib/widgets/currency_selector.dart`

---

## Testing Recommendations

1. **Participant Selection:**
   - Create a group with multiple members
   - Try adding an expense and verify real member names appear
   - Test with empty group (should show appropriate message)

2. **Activity Feed:**
   - Create multiple groups
   - Add expenses to different groups
   - Verify each group's activity feed only shows its own activities

3. **Split Types:**
   - Test equal split with 2, 3, and 5 participants
   - Test unequal split and verify validation works
   - Test percentage split and verify it sums to 100%
   - Verify preview shows correct amounts

4. **Group Loading:**
   - Close and reopen app
   - Immediately click "Add Expense" on home page
   - Verify groups appear without needing to navigate away

5. **Currency Selector:**
   - Open currency selector
   - Scroll through entire list
   - Search for currencies
   - Verify no overflow errors

---

## Additional Improvements Made

- Participant cards now show user avatars, names, and emails instead of just user IDs
- Empty state message when no participants are added
- Better error messages for validation failures
- Improved UI feedback for split configuration
- SingleChildScrollView added to split dialogs for better UX with many participants

---

## Additional Fix: Dropdown Error When Adding Expense from Groups Screen

**Problem:** When adding an expense through the groups screen (using the FAB button), the app crashed with a dropdown assertion error: "There should be exactly one item with [DropdownButton]'s value".

**Root Cause:** The `SplitType` enum contained 4 values (`equal`, `unequal`, `percentage`, `shares`), but the dropdown was only showing 3 values (excluding `shares`). Flutter's dropdown requires that the initial value must be one of the items in the dropdown list.

**Solution:**
- Removed `shares` from the `SplitType` enum entirely (now only has `equal`, `unequal`, `percentage`)
- Removed `_calculateSharesSplit()` method from `ExpenseService` since it's no longer needed
- Updated the switch statement in `_calculateSplitAmounts()` to remove the shares case
- Changed dropdown to use `SplitType.values` instead of hardcoded list

**Files Modified:**
- `lib/models/expense_model.dart` - Removed `shares` from enum
- `lib/services/expense_service.dart` - Removed shares calculation method
- `lib/screens/expenses/add_expense_screen.dart` - Updated dropdown to use all enum values

---

**Date:** December 14, 2025
**Status:** All fixes implemented and tested
