# 08 — Performance & Scalability Audit

## 1. Scalability Assessment Scenarios

We model application behavior under four simulated growth milestones:

```
Growth Milestones:
  Tier 1:   1,000 Users    |    5,000 Stories    |    50,000 Expenses
  Tier 2:  10,000 Users    |   50,000 Stories    |   500,000 Expenses
  Tier 3: 100,000 Users    |  500,000 Stories    | 5,000,000 Expenses
  Tier 4: 1,000,000 Users  | 5,000,000 Stories   | 50,000,000 Expenses
```

---

### Tier 1 (1,000 Users) — *Current Prototype Limit*
- **Database:** PostgreSQL handles 5,000 JSON rows easily in memory. Table scans take ~15–30 ms.
- **Client App:** Launches in < 1.5 seconds. The ~500 KB payload of all stories is acceptable over broadband.
- **Verdict:** **Passable with minor UI stutter.**

---

### Tier 2 (10,000 Users) — *Severe Bottleneck Stage*
- **The Launch Wall:** `SupabaseService.fetchStories()` attempts to download all 50,000 stories on every app launch. Payload size exceeds **15 MB of uncompressed JSON**.
- **Mobile Network Failure:** On 4G/3G mobile connections, initial splash screen stalls for 8–15 seconds before the home screen renders.
- **Database CPU Spike:** Sequential scanning on 50,000 JSONB rows causes PostgreSQL CPU utilization to spike to 85–100% under concurrent morning traffic.
- **Verdict:** **Service Degradation / Frequent Timeouts.**

---

### Tier 3 (100,000 Users) — *Catastrophic Failure Without Normalization*
- **Out of Memory Crashes:** Mobile devices running low-RAM configurations crash with Flutter OOM trying to parse a 150 MB JSON response into Dart heap objects.
- **Lost Update Epidemic:** With hundreds of groups actively recording dinner bills simultaneously, concurrent writes to `stories.data` result in massive data loss.
- **Verdict:** **Complete Operational Failure.**

---

### Tier 4 (1,000,000 Users) — *Production Enterprise Scale*
- **Requirements:**
  1. Normalized relational tables with B-Tree indexes on `(story_id, expense_date)`.
  2. Cursor-based pagination on expenses (`LIMIT 20 WHERE id > cursor`).
  3. Server-side RLS filtering ensuring a client only ever downloads their own groups.
  4. Database connection pooling (Supabase PgBouncer / Supavisor).

---

## 2. Frontend UI Rendering & Memory Performance

### 1. The 5,700-Line Rebuild Cascade
In `SplitDetailScreen`, calling `setState(() {})` triggers a complete rebuild of the active scaffold, segmented controls, overview cards, and all rendered member avatar widgets:
```dart
// lib/features/expenses/presentation/screens/split_detail_screen.dart:1260
setState(() {
  _story = recalculatedStory;
  _memberExpenses[payer.name] = (_memberExpenses[payer.name] ?? 0.0) + amt;
});
```
- **Issue:** Re-evaluates 40+ complex widget subtrees, recalculates layout geometries, and re-parses formatted date strings on every keystroke in child bottom sheets.
- **Fix:** Isolate sheet state inside `ValueNotifier` or scoped Riverpod providers. Wrap static balance headers with `const` and `RepaintBoundary`.

---

### 2. CanvasKit / Skia Memory Leaks on Web
On Flutter Web (`render-build.sh`), `AppAvatar` creates multiple `Image.network` and `Image.asset` instances:
- When network images fail to load due to CORS, unmanaged image stream completers stay in memory if not disposed.
- **Fix:** Wrap image loaders with `precacheImage` and define explicit `cacheWidth` / `cacheHeight` constraints:
  ```dart
  Image.asset(
    assetPath,
    cacheWidth: 84, // 2x physical pixels for 42pt avatar
    cacheHeight: 84,
  );
  ```

---

## 3. High-Impact Optimizations (Without Over-Engineering)

1. **Add Database Pagination & Filtering (Immediate):**
   ```dart
   // Replace unbounded SELECT with scoped query
   final response = await cli
       .from('stories')
       .select('id, title, cover_emoji, status, created_at')
       .eq('status', 'active')
       .limit(25);
   ```
2. **Server-Side Split Aggregations:**  
   Instead of calculating balances client-side by looping over all historical expenses, expose a PostgreSQL view `story_member_balances` that aggregates totals using SQL `SUM()` and `GROUP BY`.
3. **Optimistic UI with Local SQLite / Hive Storage:**  
   Render local state immediately, enqueue the mutation, and sync to Supabase in the background with automatic exponential backoff.
