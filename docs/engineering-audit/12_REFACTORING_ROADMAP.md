# 12 — Prioritized Refactoring Roadmap

This roadmap establishes an orderly, non-breaking execution sequence to transition TTMM Club into an enterprise-grade, maintainable fintech application.

---

## Phase 0: Critical Security & Data Integrity (P0 — Immediate)

### Task 0.1: Enforce Database Row-Level Security (RLS)
- **Affected Files:** Supabase PostgreSQL Database, [`lib/core/services/supabase_service.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/core/services/supabase_service.dart#L508).
- **Impact:** Eliminates critical cross-tenant data leakage where any client can download all groups in the database.
- **Solution:** Apply the SQL migration script from `05_DATABASE_AND_API_AUDIT.md`. Enable RLS on `stories`, `story_members`, `activities`. Update `fetchStories()` to filter server-side.
- **Complexity:** **Small (S)**.
- **Dependencies:** None.
- **Acceptance Criteria:** Unauthenticated or unauthorized queries to `stories` return `401 Unauthorized` or empty result sets.

---

### Task 0.2: Implement Lost-Update Prevention (Optimistic Locking)
- **Affected Files:** `stories` table, [`lib/features/stories/domain/models/story.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/stories/domain/models/story.dart), `supabase_service.dart`.
- **Impact:** Prevents silent loss of expenses when two members edit a group simultaneously.
- **Solution:** Add integer `version` column to `stories`. Client submits `WHERE story_id = id AND version = current_version`. If conflict occurs, reload and merge changes.
- **Complexity:** **Medium (M)**.
- **Dependencies:** Task 0.1.
- **Acceptance Criteria:** Simultaneous writes from two clients reject the second write with a concurrency exception rather than silently overwriting.

---

## Phase 1: High-Priority Architecture & Monolith Deconstruction (P1)

### Task 1.1: Deconstruct `split_detail_screen.dart` God Screen
- **Affected Files:** [`lib/features/expenses/presentation/screens/split_detail_screen.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_detail_screen.dart) (5,756 LoC).
- **Impact:** Drastically reduces bug regression risks and compilation latency; enables isolated widget testing.
- **Solution:** Extract into 8 modular files:
  1. `story_detail_screen.dart` (Scaffold shell).
  2. `story_overview_tab.dart`, `story_expenses_tab.dart`, `story_members_tab.dart`.
  3. `add_expense_sheet.dart`, `edit_expense_sheet.dart`, `expense_detail_sheet.dart`.
  4. `story_detail_controller.dart`.
- **Complexity:** **Large (L)**.
- **Dependencies:** None (can be performed incrementally).
- **Acceptance Criteria:** `story_detail_screen.dart` contains < 300 LoC. All 33 existing tests continue to pass.

---

### Task 1.2: Unify Financial Calculation Engine into Integer Paise
- **Affected Files:** [`lib/features/expenses/domain/services/expense_calculator.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/domain/services/expense_calculator.dart), [`lib/features/stories/domain/models/story.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/stories/domain/models/story.dart).
- **Impact:** Eliminates floating-point rounding errors and duplicate greedy settlement algorithms.
- **Solution:** Create `Money` value object (integer paise). Merge settlement logic into a single `DebtSimplificationEngine` with penny-allocation remainder distribution.
- **Complexity:** **Medium (M)**.
- **Dependencies:** None.
- **Acceptance Criteria:** $\sum \text{Member Shares} \equiv \text{Total Expense}$ without epsilon tolerance checks.

---

## Phase 2: Medium-Priority State & Model Modernization (P2)

### Task 2.1: Migrate State Management to Scoped Riverpod Providers
- **Affected Files:** `StoryRepository`, `ActivityRepository`, `split_detail_screen.dart`.
- **Impact:** Eliminates global mutable singletons and ensures clean disposal of Supabase Realtime WebSocket listeners.
- **Solution:** Replace `ChangeNotifier` singletons with `@riverpod` AsyncNotifiers.
- **Complexity:** **Medium (M)**.
- **Dependencies:** Task 1.1.
- **Acceptance Criteria:** Leaving a story automatically closes its WebSocket channel.

---

### Task 2.2: Normalized Relational Database Migration
- **Affected Files:** Supabase PostgreSQL Schema, `SupabaseService`.
- **Impact:** Transitions from monolithic JSON document to ACID tables (`expenses`, `expense_shares`, `settlements`).
- **Solution:** Write a Python/Dart data migration script to read existing `stories.data` JSON blobs, unpack them, and insert normalized rows into the new relational tables.
- **Complexity:** **Large (L)**.
- **Dependencies:** Task 0.1, Task 0.2.
- **Acceptance Criteria:** Stories load via normalized foreign-key joins. Incremental expense inserts only write single rows.

---

## Phase 3: Low-Priority Cleanup & Developer Experience (P3)

### Task 3.1: Clean Up Dead Code & Unused Widgets
- **Affected Files:** `friends_groups_toggle.dart`, `friend_selection_tile.dart`, `app_constants.dart`.
- **Impact:** Reduces repository noise.
- **Solution:** Deprecate and delete unreferenced widgets after reference verification.
- **Complexity:** **Small (S)**.
- **Dependencies:** None.
- **Acceptance Criteria:** Codebase compiles with zero warnings under `flutter_lints`.

---

### Task 3.2: Upstream `google_fonts` Resolution
- **Affected Files:** `packages/google_fonts/`, `pubspec.yaml`, `render-build.sh`.
- **Impact:** Removes in-tree vendor package directory and shell patching hacks.
- **Solution:** Update `google_fonts: ^6.2.1` in `pubspec.yaml` and verify Dart 3.7+ builds cleanly without overrides.
- **Complexity:** **Small (S)**.
- **Dependencies:** None.
- **Acceptance Criteria:** `render-build.sh` builds cleanly without Python AST patching script.
