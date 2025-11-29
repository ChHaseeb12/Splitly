import 'app_localizations.dart';

/// English translations
class AppLocalizationsEn extends AppLocalizations {
  // Common
  @override
  String get appName => 'Splitly';
  @override
  String get ok => 'OK';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get add => 'Add';
  @override
  String get search => 'Search';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get success => 'Success';
  @override
  String get retry => 'Retry';
  @override
  String get close => 'Close';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';

  // Navigation
  @override
  String get dashboard => 'Dashboard';
  @override
  String get friends => 'Friends';
  @override
  String get groups => 'Groups';
  @override
  String get activity => 'Activity';
  @override
  String get profile => 'Profile';

  // Authentication
  @override
  String get login => 'Login';
  @override
  String get register => 'Register';
  @override
  String get logout => 'Logout';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get resetPassword => 'Reset Password';
  @override
  String get signInWithGoogle => 'Sign in with Google';
  @override
  String get dontHaveAccount => "Don't have an account?";
  @override
  String get alreadyHaveAccount => 'Already have an account?';
  @override
  String get createAccount => 'Create Account';
  @override
  String get passwordResetSent => 'Password reset email sent';
  @override
  String get loginSuccess => 'Login successful';
  @override
  String get registerSuccess => 'Registration successful';
  @override
  String get logoutSuccess => 'Logout successful';

  // Validation
  @override
  String get emailRequired => 'Email is required';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get invalidEmail => 'Invalid email address';

  // Profile
  @override
  String get displayName => 'Display Name';
  @override
  String get phoneNumber => 'Phone Number';
  @override
  String get defaultCurrency => 'Default Currency';
  @override
  String get defaultLanguage => 'Default Language';
  @override
  String get profilePicture => 'Profile Picture';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get settings => 'Settings';
  @override
  String get currencySettings => 'Currency Settings';
  @override
  String get languageSettings => 'Language Settings';

  // Expenses
  @override
  String get expenses => 'Expenses';
  @override
  String get addExpense => 'Add Expense';
  @override
  String get editExpense => 'Edit Expense';
  @override
  String get deleteExpense => 'Delete Expense';
  @override
  String get expenseDetails => 'Expense Details';
  @override
  String get amount => 'Amount';
  @override
  String get description => 'Description';
  @override
  String get category => 'Category';
  @override
  String get date => 'Date';
  @override
  String get paidBy => 'Paid By';
  @override
  String get splitType => 'Split Type';
  @override
  String get participants => 'Participants';
  @override
  String get attachReceipt => 'Attach Receipt';
  @override
  String get notes => 'Notes';
  @override
  String get expenseAdded => 'Expense added successfully';
  @override
  String get expenseUpdated => 'Expense updated successfully';
  @override
  String get expenseDeleted => 'Expense deleted successfully';

  // Split Types
  @override
  String get equalSplit => 'Equal Split';
  @override
  String get unequalSplit => 'Unequal Split';
  @override
  String get percentageSplit => 'Percentage Split';
  @override
  String get sharesSplit => 'Shares Split';
  @override
  String get splitEqually => 'Split Equally';
  @override
  String get splitByAmount => 'Split by Amount';
  @override
  String get splitByPercentage => 'Split by Percentage';
  @override
  String get splitByShares => 'Split by Shares';

  // Categories
  @override
  String get food => 'Food';
  @override
  String get entertainment => 'Entertainment';
  @override
  String get utilities => 'Utilities';
  @override
  String get transportation => 'Transportation';
  @override
  String get shopping => 'Shopping';
  @override
  String get travel => 'Travel';
  @override
  String get personal => 'Personal';
  @override
  String get health => 'Health';
  @override
  String get subscription => 'Subscription';
  @override
  String get other => 'Other';

  // Balances
  @override
  String get balances => 'Balances';
  @override
  String get youOwe => 'You Owe';
  @override
  String get owesYou => 'Owes You';
  @override
  String get settleUp => 'Settle Up';
  @override
  String get settled => 'Settled';
  @override
  String get simplifyDebts => 'Simplify Debts';
  @override
  String get detailedView => 'Detailed View';
  @override
  String get simplifiedView => 'Simplified View';
  @override
  String get settlementHistory => 'Settlement History';
  @override
  String get noBalances => 'No balances to show';

  // Friends
  @override
  String get addFriend => 'Add Friend';
  @override
  String get removeFriend => 'Remove Friend';
  @override
  String get friendRequests => 'Friend Requests';
  @override
  String get sendRequest => 'Send Request';
  @override
  String get acceptRequest => 'Accept';
  @override
  String get declineRequest => 'Decline';
  @override
  String get pending => 'Pending';
  @override
  String get accepted => 'Accepted';
  @override
  String get blocked => 'Blocked';
  @override
  String get noFriends => 'No friends yet';
  @override
  String get friendAdded => 'Friend added successfully';
  @override
  String get friendRemoved => 'Friend removed successfully';
  @override
  String get requestSent => 'Friend request sent';
  @override
  String get requestAccepted => 'Friend request accepted';
  @override
  String get requestDeclined => 'Friend request declined';

  // Groups
  @override
  String get createGroup => 'Create Group';
  @override
  String get editGroup => 'Edit Group';
  @override
  String get deleteGroup => 'Delete Group';
  @override
  String get leaveGroup => 'Leave Group';
  @override
  String get groupName => 'Group Name';
  @override
  String get groupDescription => 'Group Description';
  @override
  String get members => 'Members';
  @override
  String get addMember => 'Add Member';
  @override
  String get removeMember => 'Remove Member';
  @override
  String get admin => 'Admin';
  @override
  String get member => 'Member';
  @override
  String get transferAdmin => 'Transfer Admin';
  @override
  String get groupSettings => 'Group Settings';
  @override
  String get noGroups => 'No groups yet';
  @override
  String get groupCreated => 'Group created successfully';
  @override
  String get groupUpdated => 'Group updated successfully';
  @override
  String get groupDeleted => 'Group deleted successfully';
  @override
  String get memberAdded => 'Member added successfully';
  @override
  String get memberRemoved => 'Member removed successfully';

  // Recurring Expenses
  @override
  String get recurringExpenses => 'Recurring Expenses';
  @override
  String get createRecurring => 'Create Recurring';
  @override
  String get frequency => 'Frequency';
  @override
  String get daily => 'Daily';
  @override
  String get weekly => 'Weekly';
  @override
  String get monthly => 'Monthly';
  @override
  String get yearly => 'Yearly';
  @override
  String get startDate => 'Start Date';
  @override
  String get endDate => 'End Date';
  @override
  String get nextDue => 'Next Due';
  @override
  String get pause => 'Pause';
  @override
  String get resume => 'Resume';
  @override
  String get active => 'Active';
  @override
  String get paused => 'Paused';
  @override
  String get upcomingExpenses => 'Upcoming Expenses';

  // Saved Splits
  @override
  String get savedSplits => 'Saved Splits';
  @override
  String get createSavedSplit => 'Create Saved Split';
  @override
  String get splitName => 'Split Name';
  @override
  String get applySplit => 'Apply Split';
  @override
  String get noSavedSplits => 'No saved splits yet';

  // Currency
  @override
  String get currency => 'Currency';
  @override
  String get exchangeRate => 'Exchange Rate';
  @override
  String get convertedAmount => 'Converted Amount';
  @override
  String get lastUpdated => 'Last Updated';
  @override
  String get refreshRates => 'Refresh Rates';
  @override
  String get clearCache => 'Clear Cache';
  @override
  String get supportedCurrencies => 'Supported Currencies';
  @override
  String get popularCurrencies => 'Popular Currencies';
  @override
  String get allCurrencies => 'All Currencies';

  // Language
  @override
  String get language => 'Language';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get languageChanged => 'Language changed successfully';

  // Date & Time
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';
  @override
  String get tomorrow => 'Tomorrow';
  @override
  String get thisWeek => 'This Week';
  @override
  String get thisMonth => 'This Month';
  @override
  String get thisYear => 'This Year';

  // Errors
  @override
  String get errorOccurred => 'An error occurred';
  @override
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get authError => 'Authentication error';
  @override
  String get permissionDenied => 'Permission denied';
  @override
  String get notFound => 'Not found';
  @override
  String get tryAgain => 'Try again';

  // Empty States
  @override
  String get noExpenses => 'No expenses yet';
  @override
  String get noActivity => 'No activity yet';
  @override
  String get noResults => 'No results found';

  // Filters
  @override
  String get filterBy => 'Filter By';
  @override
  String get dateRange => 'Date Range';
  @override
  String get allCategories => 'All Categories';
  @override
  String get allMembers => 'All Members';

  // Notifications
  @override
  String get notifications => 'Notifications';
  @override
  String get newExpense => 'New Expense';
  @override
  String get newFriendRequest => 'New Friend Request';
  @override
  String get paymentReceived => 'Payment Received';

  // Misc
  @override
  String get total => 'Total';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get perPerson => 'Per Person';
  @override
  String get share => 'Share';
  @override
  String get percentage => 'Percentage';
  @override
  String get shares => 'Shares';
  @override
  String get viewDetails => 'View Details';
  @override
  String get confirm => 'Confirm';
  @override
  String get back => 'Back';
}
