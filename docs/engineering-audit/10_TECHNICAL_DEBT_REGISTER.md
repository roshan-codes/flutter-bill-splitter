# 10 — Technical Debt Register

This register catalogues all verified technical debt items in the TTMM Club codebase, classified by engineering severity and operational impact.

---

## 1. Technical Debt Register Table

| Debt ID | Category | Severity | Affected Files | Operational Impact | Estimated Effort |
| :---: | :--- | :---: | :--- | :--- | :---: |
| **DEBT-01** | **Architecture** | **Critical** | `split_detail_screen.dart` (5,756 LoC) | Extreme maintenance friction; bug fixes introduce regressions; impossible to test in isolation. | **Large (L)** |
| **DEBT-02** | **Security / DB** | **Critical** | `supabase_service.dart:508`, Supabase DB | Unbounded table scan leaks private group data across tenants; breaks at scale. | **Small (S)** |
| **DEBT-03** | **Data Integrity** | **Critical** | `stories` table / `story.dart` | Monolithic JSON document storage causes lost updates under concurrent member edits. | **Medium (M)** |
| **DEBT-04** | **Financial Engine**| **High** | `expense_calculator.dart`, `story.dart` | IEEE 754 floating point arithmetic introduces fractional paisa rounding errors across split shares. | **Medium (M)** |
| **DEBT-05** | **Architecture** | **High** | `story.dart` (1,381 LoC) | Domain entity contains heavy calculation algorithms and sample mock JSON; violates SRP. | **Medium (M)** |
| **DEBT-06** | **State Mgmt** | **High** | `StoryRepository`, `split_detail_screen.dart` | Ad-hoc `setState` and global mutable singletons cause state divergence between tabs. | **Medium (M)** |
| **DEBT-07** | **Code Duplication**| **High** | `split_summary_screen.dart`, `split_detail_screen.dart` | Two separate implementations of user identity detection ("You") causing display inconsistencies. | **Small (S)** |
| **DEBT-08** | **Error Handling** | **Medium** | `supabase_service.dart`, `storage_service.dart` | Silent exception swallowing (`catch (e) { debugPrint(e); }`) hides cloud failures in production. | **Small (S)** |
| **DEBT-09** | **Dependencies** | **Medium** | `packages/google_fonts/`, `pubspec.yaml` | In-tree vendor fork of `google_fonts` prevents clean upstream package updates. | **Small (S)** |
| **DEBT-10** | **Testing** | **Medium** | `test/` | No automated tests for concurrency collisions, database constraints, or offline queue retries. | **Medium (M)** |
| **DEBT-11** | **UI Performance**| **Low** | `split_detail_screen.dart`, `AppAvatar` | Whole-page rebuild cascades on minor state updates; unconstrained avatar image decoding. | **Small (S)** |
| **DEBT-12** | **Dead Code** | **Low** | `friends_groups_toggle.dart`, `app_constants.dart` | Unused legacy widgets cluttering the feature directory. | **Trivial (XS)** |

---

## 2. Debt Analysis & Remediation Strategy

### DEBT-01: The 5,756-Line God Screen
- **Current State:** A single stateful class handles trip summary, balance pills, quick expense tags, 7 modal bottom sheets, Supabase Realtime listeners, avatar image resolution, and delete confirmations.
- **Remediation Strategy:** Deconstruct into feature-sliced widgets:
  1. `lib/features/stories/presentation/screens/story_detail_screen.dart` (Scaffold only).
  2. `lib/features/stories/presentation/controllers/story_detail_controller.dart` (State & Realtime).
  3. `lib/features/stories/presentation/tabs/` (Overview, Expenses, Members tabs).
  4. `lib/features/expenses/presentation/sheets/` (Add Expense, Edit Expense sheets).

---

### DEBT-02 & DEBT-03: Unbounded JSON Storage & Missing RLS
- **Current State:** Cloud persistence writes the entire group structure as an unnormalized JSON string. All stories are fetched via `SELECT *` without server filtering.
- **Remediation Strategy:**
  1. Apply PostgreSQL schema migrations ([`05_DATABASE_AND_API_AUDIT.md`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/docs/engineering-audit/05_DATABASE_AND_API_AUDIT.md#L90)) normalizing stories, members, expenses, and settlements into separate tables.
  2. Enable PostgreSQL Row-Level Security on all public tables with strict tenant isolation policies.
  3. Update queries to request only active stories belonging to the authenticated `auth.uid()`.

---

### DEBT-04: Floating-Point Arithmetic
- **Current State:** `double` is used throughout `StoryExpense.amount`, `StoryMemberBalance.netBalance`, and `ExpenseShare.amount`.
- **Remediation Strategy:**
  1. Introduce a domain type `Money`:
     ```dart
     @immutable
     class Money {
       final int paise; // e.g. ₹50.25 = 5025
       const Money(this.paise);
       factory Money.fromRupees(num val) => Money((val * 100).round());
       double get inRupees => paise / 100.0;
     }
     ```
  2. Update calculations to perform integer division and penny-allocation of remainders.
