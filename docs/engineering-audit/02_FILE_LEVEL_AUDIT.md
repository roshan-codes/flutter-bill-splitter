# 02 — File-by-File Code Quality Audit

This audit evaluates all source files in `lib/` and categorizes them by engineering quality, architectural purity, and maintainability.

---

## 1. File Classification Categories

### A. Good Files (Follows Solid Engineering Principles)
Files that demonstrate single responsibility, high cohesion, clean error handling, and testability:
- `lib/core/theme/app_colors.dart`: Clean, centralized design tokens for dark/light neumorphic palettes.
- `lib/core/theme/app_radius.dart`: Well-defined layout curves and squircle tokens.
- `lib/core/theme/app_spacing.dart`: Grid unit consistency tokens.
- `lib/core/animations/app_motion.dart`: Clean duration and curve encapsulation.
- `lib/core/utils/currency_formatter.dart`: Standalone, pure, unit-tested monetary formatter.
- `lib/core/utils/date_formatter.dart`: Pure utility for formatting dates without state side effects.
- `lib/shared/widgets/squircle_avatar.dart`: Isolated, reusable, highly styled avatar component.
- `lib/features/activity/domain/models/activity_display_item.dart`: Clean typed DTO for UI representation.
- `lib/features/home/domain/models/recent_expense.dart`: Concise, immutable presentation model.
- `lib/features/expenses/domain/models/settlement_transaction.dart`: Immutable value object for settlement pairs.

---

### B. Files That Need Improvement
Files containing moderate technical debt (coupling, long methods, duplicate logic, or missing abstractions):
- `lib/core/services/storage_service.dart`: Synchronous in-memory caching wrapper around `SharedPreferences`. Good performance, but lacks reactive change streams and atomic key prefixing.
- `lib/core/services/invite_service.dart`: Generates deep-link tokens and web URLs. Clean, but hardcodes URL fallback hosts and lacks cryptographic signing of invitation tokens.
- `lib/shared/widgets/app_avatar.dart`: Handles memo images, network profile URLs, and fallback initials. High utility, but contains duplicate user identity resolution logic and complex fallback cascading.
- `lib/features/friends/data/repositories/friends_repository.dart`: Simple repository, but persists raw contact books in local unencrypted storage with no server backup.
- `lib/features/home/presentation/screens/home_tab.dart`: Clean layout, but performs duplicate in-memory story filtering that belongs in `StoryRepository`.
- `lib/features/activity/data/repositories/activity_repository.dart`: Emits `ChangeNotifier` updates, but lacks pagination, fetching the entire activity table on every sync.

---

### C. Files That Must Be Refactored or Split (Critical Debt)
These files violate the Single Responsibility Principle and represent the primary maintenance hazards of the codebase:

#### 1. `lib/features/expenses/presentation/screens/split_detail_screen.dart` (5,756 LoC)
- **Problem:** Catastrophic "God Object" anti-pattern. Combines:
  1. Primary scaffold and custom segmented tab controllers (Overview, Expenses, Members).
  2. Supabase Realtime channel setup, WebSocket message decoding, and app lifecycle state observers.
  3. Form validation, tag suggestion frequency tracking, and quick tag builders.
  4. 7 full modal sheets: Add Expense, Edit Expense, View Expense Details, Add Member, Edit Member, Member Options, and Share Story Invite.
  5. Direct calls to `StoryRepository`, `ActivityRepository`, and `SupabaseService`.
  6. Custom avatar, currency, and name formatting helpers.
- **Refactoring Strategy:** Split into 8 distinct files:
  - `story_detail_screen.dart` (Scaffold, AppBar, Segmented Bar ~ 250 LoC)
  - `story_overview_tab.dart` (Balance card, member rows, recent expenses ~ 300 LoC)
  - `story_expenses_tab.dart` (Expense list, category grouping, search ~ 250 LoC)
  - `story_members_tab.dart` (Member cards, balance status, options ~ 250 LoC)
  - `add_expense_bottom_sheet.dart` (Form, advance mode, tag chips ~ 400 LoC)
  - `expense_detail_bottom_sheet.dart` (Details view, edit/delete actions ~ 250 LoC)
  - `story_member_management_sheet.dart` (Add/Edit/Remove member flows ~ 300 LoC)
  - `story_detail_controller.dart` (State management, Realtime lifecycle ~ 250 LoC)

#### 2. `lib/features/stories/domain/models/story.dart` (1,381 LoC)
- **Problem:** Data model contains heavy domain logic and business rule execution. Contains `_buildCalculatedStory`, `deduplicateMembers`, `deduplicateBalances`, JSON serializations for 6 nested classes, and hardcoded sample trip JSON.
- **Refactoring Strategy:** Separate domain entities from business calculators:
  - `story.dart`: Clean immutable data model with copyWith and JSON serializers.
  - `story_member.dart`, `story_expense.dart`, `story_settlement.dart`: Independent model files.
  - `story_calculation_engine.dart`: Pure service handling debt calculation, reimbursements, and settlements.
  - `member_deduplication_service.dart`: Dedicated deduplication logic.

#### 3. `lib/features/expenses/presentation/screens/split_summary_screen.dart` (1,233 LoC)
- **Problem:** Combines settlement plan rendering, member balance table, settlement execution, activity recording, and bottom sheet presentation logic in one monolithic widget.
- **Refactoring Strategy:** Split into `settlement_plan_card.dart`, `member_breakdown_table.dart`, and `settlement_controller.dart`.

#### 4. `lib/core/services/supabase_service.dart` (694 LoC)
- **Problem:** Static service combining Auth management, Profile storage, Story table queries, Story Cloud Storage JSON downloads, Activity tracking, and file uploads.
- **Refactoring Strategy:** Deconstruct into `SupabaseAuthClient`, `SupabaseStoryDataSource`, `SupabaseActivityDataSource`, and `SupabaseStorageClient`.

---

### D. Files That May Be Unnecessary or Potentially Redundant
- `lib/features/expenses/presentation/widgets/friends_groups_toggle.dart` (64 LoC): Re-implements Cupertino segmented control with zero external usage outside an abandoned draft screen.
- `lib/features/expenses/presentation/widgets/friend_selection_tile.dart` (96 LoC): Duplicates `friend_list_item.dart` with minor styling discrepancies.
- `lib/features/expenses/presentation/widgets/group_selection_tile.dart` (102 LoC): Duplicates `group_list_item.dart`.
- `lib/core/constants/app_constants.dart`: Empty/bare file containing placeholder strings unused in production logic.
- `packages/google_fonts/`: In-tree vendor copy required solely for a 1-line Dart 3.7 compatibility patch; should be replaced by upgrading `google_fonts` to `^6.2.1` with proper dependency pinning.

---

## 2. File-Level Audit Register

| File | Current Responsibility | Quality | Problem | Recommendation | Priority |
| :--- | :--- | :---: | :--- | :--- | :---: |
| `lib/features/expenses/presentation/screens/split_detail_screen.dart` | Primary group details, expenses, members, modals | **Poor** | 5,756 LoC God Widget, tight coupling, mixed UI & network | Split into 8 focused widgets and 1 controller | **P0** |
| `lib/core/services/supabase_service.dart` | Central BaaS integration client | **Poor** | Unbounded full-table queries, mixed layer responsibilities | Extract data sources; enforce RLS policies | **P0** |
| `lib/features/stories/domain/models/story.dart` | Story data structures & financial calculations | **Poor** | 1,381 LoC, domain model executes balance algorithms | Extract `StoryCalculationEngine` & split models | **P1** |
| `lib/features/expenses/presentation/screens/split_summary_screen.dart` | Settlement plan & balance table | **Needs Improvement** | 1,233 LoC, duplicate member name resolution | Decompose into settlement card & breakdown widget | **P1** |
| `lib/features/stories/presentation/screens/create_story_screen.dart` | Multi-step trip creation wizard | **Needs Improvement** | 1,189 LoC, embedded contact picker & emoji selector | Extract emoji selector and member wrap widgets | **P1** |
| `lib/features/profile/presentation/screens/profile_tab.dart` | User profile, avatar picker, logout | **Needs Improvement** | 1,060 LoC, inline edit dialogs & avatar kit logic | Extract `ProfileHeader`, `AccountSettings` widgets | **P2** |
| `lib/features/expenses/domain/services/expense_calculator.dart` | Settlement minimization algorithms | **Needs Improvement** | Uses IEEE 754 `double`, duplicates story settlement math | Unify with `StoryCalculationEngine` using integer paise | **P1** |
| `lib/features/stories/data/repositories/story_repository.dart` | Story lifecycle, storage & sync | **Good** | In-memory cache is robust, but lacks offline transaction queue | Add offline mutation queue with retry worker | **P2** |
| `lib/features/friends/presentation/widgets/import_contacts_sheet.dart` | Device contacts reader & search | **Needs Improvement** | 626 LoC, embedded search filter and permission UI | Extract contact permission banner and search bar | **P2** |
| `lib/shared/widgets/app_avatar.dart` | Universal user/member avatar | **Good** | Complex fallback chains; white-on-white text bug | Retain recent fallback fix; extract identity resolver | **P2** |
| `lib/shared/widgets/platform_adaptive.dart` | Multi-platform Cupertino/Material adapters | **Good** | 456 LoC, useful adaptive wrappers | Keep, ensure tree-shaking on web | **P3** |
| `lib/core/routing/app_auth_gate.dart` | Auth listener & routing guard | **Good** | Clean transition between onboarding & main screen | Keep as primary routing entry point | **P3** |
| `lib/core/theme/app_colors.dart` | Neumorphic color tokens | **Excellent** | Clean, centralized, constant | Keep as foundation of design system | **P3** |
| `lib/core/theme/app_radius.dart` | Squircle & radius tokens | **Excellent** | Consistent Apple HIG border radii | Keep | **P3** |
| `lib/core/utils/currency_formatter.dart` | Monetary string formatting | **Excellent** | Pure, isolated, unit-tested | Keep | **P3** |
| `lib/core/utils/date_formatter.dart` | Date & timestamp formatting | **Excellent** | Pure formatting utility | Keep | **P3** |
| `lib/features/expenses/presentation/widgets/friends_groups_toggle.dart` | Unused segmented control | **Unused** | Zero references across application | Deprecate and remove | **P3** |
| `lib/features/expenses/presentation/widgets/friend_selection_tile.dart` | Friend picker tile | **Potentially Redundant** | Duplicates `friend_list_item.dart` | Consolidate into single reusable component | **P3** |
