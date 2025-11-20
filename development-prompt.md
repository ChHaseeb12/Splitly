# Splitly - Production-Ready Flutter App Development Prompt

## Project Overview

**Application:** Splitly - A Splitwise clone built with Flutter for collaborative expense management
**Platforms:** Android & iOS (with optional web/desktop support)
**Backend:** Firebase (Auth + Firestore)
**Status:** Starting from existing Flutter app with Firebase already configured
**Target:** Production-ready with advanced features, offline capability, and multi-language/multi-currency support

---

## Existing Infrastructure

- ✅ Flutter project initialized
- ✅ Firebase configured (Auth & Firestore)
- ✅ Email & Google authentication enabled
- ✅ Firestore database created with development write rules
- ✅ Custom UI components available (MyTextfield, MyButton, SquareTile)
- ✅ Design system: Light theme, grey tones, rounded corners, modern aesthetic

---

## Phase 1: Foundation & Authentication Enhancement

### Objectives
Strengthen authentication flows and establish core app structure.

### Tasks

**1.1 Enhanced Authentication**
- Implement email/password registration with validation (6+ chars, special chars optional)
- Add password reset flow with Firebase email verification
- Implement Google Sign-In with profile data auto-population
- Add logout functionality with session cleanup
- Create auth state management (use Provider/Riverpod for state management)
- Handle auth persistence across app sessions
- Add loading states and error handling for all auth flows
- Implement rate limiting for login/registration attempts

**1.2 User Profile Setup**
- Create user profile model with fields: uid, displayName, email, profilePicture, phone, currency (default), language (default)
- Design onboarding flow post-registration
- Allow users to set default currency and language preferences
- Implement profile picture upload to Firebase Storage
- Create profile editing screen
- Add display name customization

**1.3 App Navigation Structure**
- Implement bottom navigation with main sections: Dashboard, Friends, Groups, Activity, Profile
- Create nested routing for sub-screens
- Add splash screen with app branding
- Implement deep linking preparation for future use

**1.4 Data Models & Firestore Schema**
- Design Firestore collection structure:
  - `users/{userId}` - User profiles
  - `groups/{groupId}` - Group data
  - `expenses/{expenseId}` - Expense records
  - `settlements/{settlementId}` - Debt settlements
- Create Dart models for all entities with proper serialization
- Add timestamp tracking (createdAt, updatedAt) to all documents

---

## Phase 2: Core Expense & Debt Management

### Objectives
Build the fundamental expense splitting logic and debt calculation engine.

### Tasks

**2.1 Expense Model & Service**
- Create comprehensive Expense model:
  - expenseId, groupId, payerId, amount, currency, category
  - description, date, participants (list with split amounts)
  - splitType (EQUAL, UNEQUAL, PERCENTAGE, SHARES)
  - status (PENDING, SETTLED, ARCHIVED)
- Implement ExpenseService with CRUD operations:
  - Add expense with automatic split calculation
  - Edit/delete expense with balance recalculation
  - Retrieve expenses by group/user/date range
  - Filter expenses by category

**2.2 Split Calculation Engine**
- Implement equal split logic (amount ÷ number of people)
- Implement unequal split logic (custom amounts per person)
- Implement percentage split logic (validate percentages sum to 100%)
- Implement shares split logic (custom shares with proportional distribution)
- Add validation for all split types (prevent negative amounts, ensure sum accuracy)
- Create split preview UI before expense confirmation
- Handle rounding edge cases (use banker's rounding)

**2.3 Debt Tracking & Balances**
- Create Debt model: debtId, fromUserId, toUserId, amount, currency, expenseIds (related expenses)
- Implement balance calculation logic (sum all debts between two users)
- Create settlement tracking system
- Build settlement history
- Implement BalanceService:
  - Calculate net balance between any two users
  - Get all debts for a user
  - Get all debts for a group
  - Get summary balances (who owes what)

**2.4 Debt Simplification Algorithm**
- Implement greedy debt simplification algorithm:
  - Analyze all debts in a group/among users
  - Minimize number of transactions needed to settle all debts
  - Return optimal settlement transactions
- Add option to enable/disable simplification per group
- Display simplified vs. detailed views
- Show potential settlement suggestions to users

**2.5 Currency Handling (Phase 2 Foundation)**
- Implement currency field in Expense model
- Store all transactions in original currency
- Prepare for multi-currency support
- Add basic currency validation

---

## Phase 3: Friend & Group Management

### Objectives
Enable users to organize expenses with friends and groups.

### Tasks

**3.1 Friends Management**
- Create Friend model: friendId, userId1, userId2, status (PENDING, ACCEPTED, BLOCKED), createdAt
- Implement friend request system:
  - Send friend request (search by email or display name)
  - Accept/decline friend requests
  - Remove friends
  - Block functionality
- Create Friends Service with CRUD operations
- Display list of friends with quick action buttons
- Show friend status (mutual, pending, incoming request)
- Quick access to settle debts with specific friends

**3.2 Group Management**
- Create Group model:
  - groupId, name, description, createdBy, members (list with joinDate)
  - currency, settings (simplification enabled, notifications)
  - profileImage, createdAt, updatedAt
- Implement GroupService:
  - Create group (creator automatically admin)
  - Add members to group (search users)
  - Remove members
  - Edit group details
  - Delete group (admin only, cascade cleanup)
  - Leave group
  - Transfer admin rights

**3.3 Group Roles & Permissions**
- Implement role system: ADMIN, MEMBER
- Admin can: edit group, add/remove members, delete group, change settings
- Member can: add expenses, view expenses, settle debts
- Implement permission checks before operations

**3.4 Group Screens**
- Group list screen with creation option
- Group detail screen showing members and recent activities
- Add member dialog/screen
- Group settings screen

**3.5 Friend Screens**
- Friend list screen with status indicators
- Add friend screen with search
- Friend detail screen showing shared expenses and balance
- Incoming/pending friend requests screen

---

## Phase 4: Advanced Expense Features

### Objectives
Add sophisticated expense management capabilities.

### Tasks

**4.1 Recurring Expenses**
- Create RecurringExpense model:
  - recurringId, baseExpenseId, frequency (DAILY, WEEKLY, MONTHLY, YEARLY)
  - startDate, endDate, nextDueDate, isActive
  - autoCreate (boolean to auto-generate instances)
- Implement RecurringExpenseService:
  - Create recurring expense
  - Auto-generate instances based on frequency
  - Pause/resume recurring expenses
  - Edit recurring template
  - Delete with option to remove all or future instances
- Add background task/cron job for auto-creating recurring expenses
- Create recurring expense management screen
- Show upcoming recurring expenses on dashboard

**4.2 Expense Categories**
- Define expense categories: FOOD, ENTERTAINMENT, UTILITIES, TRANSPORTATION, SHOPPING, TRAVEL, PERSONAL, HEALTH, SUBSCRIPTION, OTHER
- Implement category selection in add expense flow
- Add category icons and colors
- Filter expenses by category
- Display category breakdown in spending totals

**4.3 Expense Search & Filters**
- Implement comprehensive search:
  - Search by description/note
  - Filter by date range
  - Filter by category
  - Filter by amount range
  - Filter by participant
  - Filter by expense status
  - Combine multiple filters
- Create search UI with filter chips
- Display search results with relevance sorting
- Save frequently used filter combinations (optional)

**4.4 Expense Attachments & Notes**
- Allow users to attach receipts (images) to expenses
- Implement image upload to Firebase Storage
- Add detailed notes/description field
- Display attachments in expense detail view
- Image preview functionality

**4.5 Default Split Presets**
- Create SavedSplit model: savedSplitId, userId, name, splitType, participants, percentages/amounts/shares
- Allow users to save frequently used split configurations
- Quick-apply saved splits when adding expenses
- Manage saved splits (edit, delete)
- Share split presets within groups (optional)

---

## Phase 5: Multi-Currency & Real-Time Rates

### Objectives
Support global expense management with accurate currency conversion.

### Tasks

**5.1 Currency Support**
- Implement currency data: ISO 4217 codes, symbols, decimal places for 100+ currencies
- Store currency list in app (local JSON or fetch from API)
- User preference: default currency at profile level
- Group preference: group base currency
- Transaction currency: original currency of each expense

**5.2 Exchange Rate Integration**
- Integrate with exchange rate API (OpenExchangeRates, Fixer.io, or similar)
- Implement rate caching (update daily or on demand)
- Create CurrencyService:
  - Get current exchange rate between two currencies
  - Convert amount from one currency to another
  - Get historical rates for past transactions (optional)
- Handle API failures with cached rates fallback
- Add rate last-updated timestamp

**5.3 Multi-Currency Display**
- Display amounts in original currency in expense lists
- Show conversion to user's default currency with exchange rate notation
- Allow users to toggle between original currency and default currency views
- Implement currency symbols and formatting based on locale
- Show exchange rates used in transaction details

**5.4 Multi-Currency Balance Calculation**
- Convert all debts to group currency for balance calculation
- Display balances in multiple formats:
  - Original currency (per transaction)
  - Group currency (aggregated)
  - User's default currency (for personal view)
- Handle mixed-currency groups elegantly
- Add exchange rate disclaimers where appropriate

---

## Phase 6: Multi-Language Support

### Objectives
Enable app usage in 7+ languages with proper localization.

### Tasks

**6.1 Localization Framework**
- Integrate Flutter localization (intl package)
- Implement language switching without app restart
- Store user language preference in Firestore
- Support languages: English, Spanish, French, German, Portuguese, Chinese (Simplified), Hindi (minimum 7)

**6.2 Translation Structure**
- Create translation files (JSON/YAML or ARB format) for all supported languages
- Translate all UI strings:
  - Navigation labels
  - Button labels
  - Form labels and placeholders
  - Error messages
  - Success messages
  - Dialog content
  - Settings options
  - Category names
  - Frequency labels

**6.3 Locale-Specific Formatting**
- Implement locale-aware date formatting (dd/mm/yyyy vs mm/dd/yyyy)
- Locale-aware time formatting (12-hour vs 24-hour)
- Locale-aware number formatting (comma vs period for decimals)
- Locale-aware currency symbol placement
- Right-to-left (RTL) language support (if including Arabic/Hebrew)

**6.4 Language Selection UI**
- Create language selection screen in onboarding
- Add language picker in settings
- Display current language with option to change
- Ensure smooth language switching throughout app

---

## Phase 7: Offline Capability & Sync

### Objectives
Enable app functionality without internet connection with automatic sync.

### Tasks

**7.1 Local Database Setup**
- Integrate Hive or SQLite for local data storage
- Create local mirrors of:
  - User profile
  - Friends list
  - Groups list
  - Expenses
  - Recurring expenses
  - Debts/settlements
  - Cached exchange rates
  - Cached translations

**7.2 Offline-First Architecture**
- Implement all read operations from local database first
- Queue write operations when offline
- Show clear indicator of sync status (syncing, synced, error)
- Implement sync queue with timestamp tracking
- Add conflict resolution strategy (last-write-wins or more sophisticated)

**7.3 Sync Engine**
- Create SyncService:
  - Background sync when connection restored
  - Sync priority queue (critical operations first)
  - Handle sync conflicts gracefully
  - Retry failed syncs with exponential backoff
  - Notify user of sync completion/errors
- Implement Firestore offline persistence configuration
- Add manual sync option in UI

**7.4 Offline Limitations & UX**
- Disable features requiring real-time data when offline
- Show clear messaging about offline state
- Queue notifications for when connection restored
- Cache images and profile pictures for offline viewing
- Implement graceful degradation for currency conversion offline

**7.5 Data Refresh & Pull-to-Refresh**
- Implement pull-to-refresh on main screens
- Add refresh button for manual data reload
- Show "last synced" timestamp
- Implement background data refresh (if permission granted)

---

## Phase 8: Analytics & Visualizations

### Objectives
Provide users with spending insights through charts and analytics.

### Tasks

**8.1 Spending Dashboard**
- Total spending (this month, this year, all time) - per group and personal
- Spending by category (pie chart or bar chart)
- Spending over time (line chart, configurable period)
- Top categories by spending
- Top expense categories in each group
- Breakdown by participant (who spends most)

**8.2 Debt Analytics**
- Total amount owed (to you and by you)
- Debt trend over time
- Debt breakdown by person/group
- Settlement status (settled vs unsettled)
- Average expense amount

**8.3 Chart Implementation**
- Integrate chart library (fl_chart, syncfusion_flutter_charts, or similar)
- Implement chart types:
  - Pie charts (category distribution)
  - Bar charts (comparisons)
  - Line charts (trends over time)
  - Donut charts (hierarchical data)
- Add chart customization:
  - Date range selection
  - Filter by category/group/person
  - Export as image
  - Toggle between different chart types

**8.4 Analytics Screens**
- Dashboard with key metrics and charts
- Detailed analytics screen by group
- Personal spending analytics
- Category analysis
- Trend analysis (spending patterns)

**8.5 Spending Insights**
- Monthly spending summary report
- Year-over-year comparison
- Category spending trends
- Friend/group spending patterns
- Budget planning suggestions (optional)

---

## Phase 9: UI/UX Polish & Custom Components

### Objectives
Create a cohesive, modern user interface with custom components.

### Tasks

**9.1 Custom Components**
- Ensure consistent use of existing components: MyTextfield, MyButton, SquareTile
- Create additional custom components:
  - ExpenseCard (display expense with split info)
  - DebtCard (show balance between two people)
  - GroupCard (group overview with member count, balance)
  - CategoryChip (filterable category selector)
  - CurrencySelector (dropdown with flag icons)
  - SplitPreview (visual representation of split)
  - EmptyState (consistent empty view with illustration)
  - LoadingState (loading indicators)
  - ErrorState (error messages with retry)

**9.2 Design System**
- Establish color palette:
  - Primary: Define primary color (maintain grey tones theme)
  - Accents: Secondary colors for success, warning, error
  - Text colors: Primary, secondary, tertiary
  - Background and surface colors
- Typography: Define font sizes and weights for consistency
- Spacing/Padding: Standardized spacing scale
- Border radius: Consistent rounded corners (8px, 12px, 16px)
- Shadows: Elevation system for depth
- Icons: Use consistent icon library (material_design_icons or similar)

**9.3 Screen Polish**
- Add smooth transitions between screens
- Implement proper spacing and padding
- Add loading skeletons for better perceived performance
- Create empty states for all list screens
- Add helpful error messages and retry options
- Implement proper keyboard handling in forms
- Add input validation with real-time feedback
- Create consistent app bar styling

**9.4 Dark Mode Support (Optional)**
- Design dark theme variants
- Implement theme switching
- Use themeProvider for dynamic theming
- Ensure accessibility in both themes

**9.5 Accessibility**
- Implement proper semantic labels for screen readers
- Ensure sufficient color contrast (WCAG AA compliance)
- Add touch target sizing (minimum 48x48 dp)
- Implement keyboard navigation
- Add focus indicators
- Localize for RTL languages if applicable

---

## Phase 10: Testing & Quality Assurance

### Objectives
Ensure app reliability and quality before production release.

### Tasks

**10.1 Unit Testing**
- Test all business logic:
  - Split calculation engine (all split types)
  - Debt calculation and simplification
  - Currency conversion
  - Balance calculations
- Test data models and serialization
- Test authentication logic
- Aim for >80% code coverage in business logic

**10.2 Widget Testing**
- Test custom components (MyButton, MyTextfield, SquareTile)
- Test form validation
- Test navigation flows
- Test state management
- Test error handling UI

**10.3 Integration Testing**
- Test Firebase integration:
  - Authentication flows
  - Firestore read/write operations
  - Data synchronization
  - Error handling
- Test complete user flows:
  - Sign up → Create group → Add expense → Settle debt
  - Add friend → Record expense → View balance
  - Recurring expense creation and auto-generation

**10.4 Manual QA**
- Full device testing (Android and iOS)
- Test on multiple screen sizes
- Test network connectivity (wifi, 4G, offline)
- Test with real Firebase (staging environment)
- Performance testing with large datasets
- Load testing (many expenses, large groups)
- Battery/data usage monitoring

**10.5 Security Testing**
- Verify Firebase security rules (read-only access to own data)
- Test input validation and sanitization
- Check for data exposure vulnerabilities
- Test payment data handling (if applicable)
- Verify authentication token handling
- Test API key security

---

## Phase 11: Deployment & Release

### Objectives
Prepare app for production release on app stores.

### Tasks

**11.1 Firebase Production Configuration**
- Update Firestore security rules for production:
  - Users can only access their own data
  - Users can only read shared group/friend data
  - Users cannot delete/modify others' data
  - Implement role-based access control
- Configure Firebase storage rules for images
- Set up rate limiting on sensitive operations
- Enable backup policies
- Configure analytics and crash reporting

**11.2 App Signing & Build Configuration**
- Generate Android signing key
- Generate iOS certificates and provisioning profiles
- Configure build flavors (dev, staging, production)
- Implement feature flags for gradual rollout
- Set up app versioning and build numbers

**11.3 Play Store & App Store Submission**
- Create app store listings:
  - App name and subtitle
  - Description and keywords
  - Screenshots and previews
  - Privacy policy and terms of service
  - Contact information
- Configure app signing requirements
- Add app icons and launch screens
- Set age ratings and content restrictions
- Configure pricing (if applicable)

**11.4 Release Management**
- Create release notes
- Implement auto-update checking
- Set up beta testing program (TestFlight, Google Play Beta)
- Plan phased rollout
- Set up crash reporting and monitoring (Firebase Crashlytics)
- Configure analytics dashboards

**11.5 Post-Launch Support**
- Monitor crash reports and fix critical bugs
- Respond to user reviews and ratings
- Collect user feedback
- Plan updates and feature releases
- Monitor performance metrics
- Track user retention and engagement

---

## Phase 12: Advanced Features (Post-MVP)

### Objectives
Add premium and advanced functionality after core release.

### Tasks

**12.1 Payment Integration**
- Integrate payment gateway (Stripe, Razorpay)
- Implement in-app payment recording:
  - Record when user paid through app
  - Settlement confirmation
  - Payment notifications
- Add payment method storage (secure)
- Implement payment history

**12.2 Notifications**
- Implement push notifications:
  - New expense added to group
  - You owe money/someone owes you
  - Friend request received
  - Payment received/sent
  - Recurring expense created
- Create notification preferences screen
- Implement local notifications for offline scenarios
- Set up Firebase Cloud Messaging (FCM)

**12.3 Social Features (Optional)**
- Share expenses via link
- Activity feed showing group transactions
- Comments on expenses
- Expense reactions/emojis
- Notifications for all activity

**12.4 Advanced Budgeting**
- Set budgets per category per group
- Budget alerts when approaching limit
- Budget analytics and comparisons
- Monthly budget reviews
- Spending predictions

**12.5 Receipt Scanning (Optional)**
- Integrate OCR for receipt image processing
- Auto-extract amount, date, merchant, items
- Pre-populate expense form from receipt
- Item-level splitting for group purchases

**12.6 Premium Features**
- Define premium tier features
- Implement subscription management
- Add paywall screens
- Set pricing (monthly, yearly, one-time)
- Integrate payment processing
- License key management

---

## Phase 13: Performance & Optimization

### Objectives
Ensure app performs smoothly at scale.

### Tasks

**13.1 Performance Monitoring**
- Implement Firebase Performance Monitoring
- Track screen render times
- Monitor API response times
- Identify bottlenecks
- Set performance budgets

**13.2 Code Optimization**
- Implement lazy loading for lists
- Use pagination for large datasets
- Optimize image loading and caching
- Implement image compression
- Minimize rebuild frequency with Provider/Riverpod
- Profile and optimize hot paths

**13.3 Memory Management**
- Monitor memory usage
- Implement proper resource cleanup
- Handle image memory efficiently
- Avoid memory leaks in listeners
- Test on low-memory devices

**13.4 Network Optimization**
- Implement request batching
- Add request debouncing
- Cache frequently accessed data
- Minimize payload sizes
- Implement compression

**13.5 Battery & Data Optimization**
- Minimize background sync frequency
- Optimize location services (if any)
- Reduce push notification frequency
- Compress images before upload
- Implement efficient database queries

---

## Phase 14: Documentation & Handoff

### Objectives
Create comprehensive documentation for maintenance and future development.

### Tasks

**14.1 Code Documentation**
- Document all public APIs
- Add inline comments for complex logic
- Create architecture documentation
- Document state management flow
- Create data model documentation
- Document Firebase schema and rules

**14.2 Deployment Guide**
- Step-by-step deployment instructions
- Environment setup guide
- Firebase configuration guide
- API key management
- Release process documentation
- Rollback procedures

**14.3 User Documentation**
- User guide/help articles
- FAQ section
- Troubleshooting guide
- Video tutorials (optional)
- Feature walkthroughs

**14.4 Developer Guide**
- Setup guide for new developers
- Architecture overview
- Coding standards and conventions
- Testing guidelines
- Git workflow
- Issue tracking and PR process

---

## Quality Checklist (End-to-End)

Before considering the project complete, verify:

- [ ] All 14 core features implemented and tested
- [ ] Offline mode fully functional with sync
- [ ] 7+ languages supported and properly localized
- [ ] 100+ currencies supported with live conversion
- [ ] All split types working correctly (equal, unequal, %, shares)
- [ ] Debt simplification algorithm proven correct
- [ ] Recurring expenses auto-generating properly
- [ ] Charts and analytics displaying correctly
- [ ] Search and filters working comprehensively
- [ ] Custom components consistent throughout
- [ ] Firebase security rules production-ready
- [ ] No crash reports in staging
- [ ] Performance acceptable on low-end devices
- [ ] Accessibility compliance verified
- [ ] Authentication flows secure and smooth
- [ ] Sync conflicts handled gracefully
- [ ] API rate limiting implemented
- [ ] Data encryption for sensitive fields
- [ ] Documentation complete
- [ ] App store submissions prepared

---

## Technical Stack Summary

- **Framework:** Flutter (latest stable)
- **Backend:** Firebase (Authentication + Firestore)
- **State Management:** Provider or Riverpod
- **Local Storage:** Hive or SQLite
- **Charts:** fl_chart or similar
- **Localization:** intl package
- **Testing:** flutter_test, Mockito
- **CI/CD:** GitHub Actions (recommended)
- **Crash Reporting:** Firebase Crashlytics
- **Analytics:** Firebase Analytics

---

## Success Metrics

- **Functionality:** All 14 core features fully implemented and working
- **Performance:** App loads in <2s, smooth 60fps UI interactions
- **Reliability:** <0.1% crash rate, 99%+ success rate for Firestore operations
- **User Retention:** Target >70% day-1 retention in beta
- **Accessibility:** WCAG AA compliance achieved
- **Offline:** 100% core functionality available offline with sync
- **Scalability:** Handles 1000+ expenses, 100+ friends, 50+ groups per user

---

## Timeline Estimate

- **Phase 1-3:** 2-3 weeks (foundation + auth + friends/groups)
- **Phase 4:** 1 week (advanced expenses)
- **Phase 5-6:** 1-2 weeks (currency + localization)
- **Phase 7:** 1 week (offline + sync)
- **Phase 8:** 1 week (analytics)
- **Phase 9:** 1-2 weeks (UI polish)
- **Phase 10:** 1-2 weeks (testing)
- **Phase 11:** 1 week (deployment)
- **Phase 12-14:** 2-3 weeks (advanced features + optimization + docs)

**Total Estimated Timeline:** 12-17 weeks for production-ready MVP + advanced features

---

## Next Steps

1. Review and validate this development prompt
2. Prioritize phases based on business goals
3. Set up development environment and Firebase staging project
4. Begin Phase 1 implementation
5. Establish testing strategy early
6. Regular code reviews and quality gates
7. Plan user testing and beta feedback incorporation