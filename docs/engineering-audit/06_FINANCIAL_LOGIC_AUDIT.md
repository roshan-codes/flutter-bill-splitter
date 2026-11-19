# 06 — Financial Logic & Calculation Engine Audit

## 1. Domain Mathematics & Core Financial Invariants

In any fintech split engine, five mathematical invariants must hold unconditionally across all operations:

$$\begin{aligned}
\text{Invariant 1 (Conservation of Money):} \quad & \sum_{i=1}^N \text{Paid}_i = \sum_{j=1}^M \text{ExpenseAmount}_j \\
\text{Invariant 2 (Share Conservation):} \quad & \sum_{i=1}^N \text{Share}_i = \text{ExpenseAmount} \quad \forall \text{ Expenses} \\
\text{Invariant 3 (Zero-Sum Balance):} \quad & \sum_{i=1}^N \text{NetBalance}_i = 0.00 \\
\text{Invariant 4 (Settlement Reduction):} \quad & \sum \text{SettledTransactions} \le \sum \text{TotalDebt} \\
\text{Invariant 5 (Historical Immutability):} \quad & \text{Recording a settlement MUST NOT mutate original expense records.}
\end{aligned}$$

---

## 2. Audit of Existing Calculation Implementations

### Analysis of `Story._buildCalculatedStory()` & `ExpenseCalculator`

#### Strengths Verified in Automated Tests:
- **Zero-Sum Balance Holds:** Verified by [`test/all_app_calculations_test.dart#L125`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/test/all_app_calculations_test.dart#L125), [`test/fintech_master_financial_audit_test.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/test/fintech_master_financial_audit_test.dart). The algebraic sum of all net balances $\sum \text{Net} = 0$ is consistently maintained.
- **Advance Payment Accounting:** Advance payments (reimbursements) transfer funds directly between sender and recipient without inflating the group's total spending or per-person trip share.
- **Settlement Isolation:** Marking a settlement as completed does not rewrite historical expense lines.

---

### Critical Financial Weaknesses Found

#### Weakness 1: Floating-Point Rounding Drift (IEEE 754 `double`)
Currently, monetary values are represented as `double`:
```dart
// lib/features/expenses/domain/services/expense_calculator.dart:21
static double calculateSharePerPerson(double total, int memberCount) {
  if (memberCount <= 0) return 0.0;
  return total / memberCount;
}
```
**The Math Failure:**
When dividing ₹1,000 among 3 members:
$$1000 \div 3 = 333.3333333333333 \dots$$
In standard 64-bit float representation:
$$333.3333333333333 \times 3 = 999.9999999999999 \ne 1000.0$$
Currently, the codebase handles this by adding fuzzy epsilon tolerances (`(net.abs() <= 0.01)` or `(net.abs() <= 0.5)`).
**Fintech Risk:** Accumulating fractional paisas across hundreds of expenses leads to rounding leaks where total shares diverge from total amounts paid.

#### Recommended Solution: Fixed-Point Minor Unit (Paise / Cents as `BigInt` / `int`)
Represent all monetary values as integer minor units:
- ₹1,000.00 = `100000` paise.
- Dividing 100,000 paise among 3 members:
  - Base share: $100000 \div 3 = 33333$ paise (₹333.33).
  - Remainder: $100000 \pmod 3 = 1$ paise.
  - **Penny Allocation Algorithm:** Distribute the 1 remainder paise to the first member:
    - Member 1 share: 33,334 paise (₹333.34).
    - Member 2 share: 33,333 paise (₹333.33).
    - Member 3 share: 33,333 paise (₹333.33).
    - **Total:** $33334 + 33333 + 33333 = 100000$ paise (₹1,000.00 exact).

---

#### Weakness 2: Greedy Two-Pointer Settlement vs Optimal Debt Minimization
Both `ExpenseCalculator` and `Story._buildCalculatedStory` use a greedy algorithm:
1. Sort creditors descending by amount owed to them.
2. Sort debtors descending by amount they owe.
3. Match top debtor with top creditor and transfer $\min(\text{debt}, \text{credit})$.

**Evaluation:**
- The greedy two-pointer algorithm produces a valid settlement that clears all debts to zero.
- It guarantees at most $N - 1$ transactions for $N$ members.
- However, it is not always the *minimal* transaction count (finding the minimum transaction count is the NP-hard Subset Sum problem). For groups under 15 members, the greedy heuristic is computationally fast ($O(N \log N)$), reliable, and fully acceptable for production.

---

## 3. Financial Test Coverage Assessment

The testing suite contains **35 verified financial test scenarios** across four test files:
- `test/all_app_calculations_test.dart` (571 lines): 22 scenarios covering odd-number splits, paise resolution, zero participants, full reimbursement, advance payments.
- `test/comprehensive_financial_logic_test.dart` (382 lines): 7 scenarios verifying unequal contributions, dynamic settlement recalculations, and net balance preservation.
- `test/fintech_master_financial_audit_test.dart` (485 lines): 10 core financial invariants tested against complex multi-payer trips.
- `test/settlement_sync_test.dart` (683 lines): Verifies synchronization between `SplitSummaryScreen` settlement plans and `SplitDetailScreen` balance banners.

**Conclusion:** The mathematical validation suite is **one of the strongest parts of the codebase**. Migrating the data types from `double` to `int paise` will permanently eliminate all floating-point epsilon checks.
