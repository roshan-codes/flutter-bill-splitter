# 03 — Code Quality & Maintainability Audit

## 1. Code Cleanliness & Readability

The overall stylistic discipline of TTMM Club is polished in its visual representation, but reveals significant maintainability challenges at the source code level:

1. **Extreme Method Lengths:**  
   Multiple widget build methods exceed 400 lines without sub-component breakdown.  
   *Examples:*
   - `_openAddExpenseSheet()` in [`split_detail_screen.dart#L505-L1300`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_detail_screen.dart#L505-L1300) spans **795 lines** in a single function body.
   - `_buildOverviewTab()` in [`split_detail_screen.dart#L2820-L2999`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_detail_screen.dart#L2820-L2999) spans **180 lines**.
   - `_buildExpensesTab()` in [`split_detail_screen.dart#L3610-L3775`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_detail_screen.dart#L3610-L3775) spans **165 lines**.

2. **Excessive Nesting & Anonymous Lambdas:**  
   Deep indentation pyramids (nesting levels reaching 12–15 brackets) occur frequently inside modal sheets, where `StatefulBuilder`, `SingleChildScrollView`, `Column`, `Padding`, `Row`, `GestureDetector`, and `Container` are stacked without sub-widget extraction.

---

## 2. Major Code Duplication Register

| Duplicated Logic | Location A | Location B | Impact | Recommended Solution |
| :--- | :--- | :--- | :--- | :--- |
| **Current User Identity Resolution** | `split_detail_screen.dart#L3319-L3368` | `split_summary_screen.dart#L1091-L1100` | Inconsistent name display ("You" vs Real Name); fragile string matching | Extract `UserIdentityResolver` domain service |
| **Settlement Debt Minimization** | `expense_calculator.dart#L50-L105` | `story.dart#L955-L986` | Two distinct debt algorithms; potential divergence in transaction proposals | Unify into single `DebtSimplificationService` |
| **Member Deduplication by Name/ID** | `story.dart#L400-L539` | `create_story_screen.dart#L158-L175` | Divergent rules for merging names, guests, and IDs | Consolidate in `MemberDeduplicationService` |
| **Story Persistence & Backup** | `story_repository.dart#L130-L155` | `split_detail_screen.dart#L1175-L1195` | UI directly triggering low-level Supabase update calls alongside repository calls | Route all state mutations strictly through `StoryRepository` |
| **Activity Generation from Expense** | `split_detail_screen.dart#L278-L292` | `split_detail_screen.dart#L1178-L1195` | Redundant construction of `SplitActivity` objects with manually mapped friend lists | Domain model factory: `SplitActivity.fromExpense(expense, story)` |

### Detailed Duplication Breakdown

#### Case 1: Settlement Greedy Optimization Engine
- **Location 1:** `ExpenseCalculator.calculateSettlementsFromNetBalances()` ([`expense_calculator.dart#L51-L105`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/domain/services/expense_calculator.dart#L51-L105)) operates on `List<Friend>` and returns `List<SettlementTransaction>`.
- **Location 2:** `Story._buildCalculatedStory()` ([`story.dart#L955-L986`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/stories/domain/models/story.dart#L955-L986)) operates on `List<MapEntry<String, double>>` user IDs and returns `List<StorySettlement>`.
- **Problem:** Both algorithms execute an identical two-pointer greedy minimization, but use completely different data types. Changes or bugfixes in settlement calculation must be written and tested twice.

---

## 3. Error Handling & Exception Patterns

### Anti-Pattern 1: Silent Catch Blocks (`catch (_) { }`)
Throughout `supabase_service.dart` and `storage_service.dart`, exceptions are swallowed or relegated to `debugPrint`:
```dart
// lib/core/services/supabase_service.dart:380
try {
  await cli.from('stories').upsert(...);
} catch (e) {
  debugPrint('Supabase table upsert note: $e'); // Silent failure in production!
}
```
**Risk:** When network failure, RLS permission denial, or schema validation fails in production release builds (where `debugPrint` is stripped or ignored), the user is given no indication that their expense failed to save to the cloud.

### Anti-Pattern 2: Missing Typed Error Hierarchy
Exceptions are thrown as bare strings or caught as generic `Object`/`Exception`:
```dart
// lib/core/services/supabase_service.dart:183
} catch (e) {
  debugPrint('Sync user data note: $e');
  return false;
}
```
**Recommendation:** Implement domain-specific exception types inheriting from `AppException`:
- `NetworkUnavailableException`
- `UnauthorizedStoryAccessException`
- `ConcurrentStoryModificationException`
- `StoryNotFoundException`

---

## 4. Cyclomatic Complexity Hotspots

```
1. Story._buildCalculatedStory()          Cyclomatic Complexity: 34  (Extremely High)
2. SplitDetailScreen._openAddExpenseSheet() Cyclomatic Complexity: 28  (High)
3. Story.deduplicateMembers()              Cyclomatic Complexity: 24  (High)
4. SplitDetailScreen._isCurrentUser()       Cyclomatic Complexity: 19  (Moderate)
5. SupabaseService.fetchStories()          Cyclomatic Complexity: 18  (Moderate)
```

### Remediating `Story._buildCalculatedStory`
`_buildCalculatedStory` currently performs:
1. Expense type classification (actual expenses vs transfers/advances).
2. Payer resolution via string fuzzy matching.
3. Share allocation (equal vs custom share parsing).
4. Advance/reimbursement transfer direction inference from title string (`"to <name>"` / `"by <name>"`).
5. Net balance derivation.
6. Debtor and creditor queue creation.
7. Two-pointer settlement pairing.
8. Status resolution.

**Recommendation:** Apply the **Pipeline Pattern**, breaking this 250-line method into five pure, single-purpose functions:
`categorizeExpenses()` $\rightarrow$ `aggregatePaidAndShares()` $\rightarrow$ `applyTransfers()` $\rightarrow$ `computeNetBalances()` $\rightarrow$ `minimizeSettlements()`.
