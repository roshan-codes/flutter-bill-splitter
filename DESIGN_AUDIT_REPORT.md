# Design Audit Report: Flutter Bill Splitter
**Evaluated against:** Apple Human Interface Guidelines (HIG 2026), Apple Craft Principles & Cross-Platform Mobile Standards.  
**Audited Artifacts:** Full Flutter codebase (`lib/`, 35 unit/widget tests, design screenshots, theme system).

---

## 1. Executive Summary

| Category | Assessment | Score |
| :--- | :--- | :--- |
| **Overall Rating** | **Good (High Craft, Needs Accessibility & Interaction Refinements)** | **8.4 / 10** |
| **Design Thesis** | Tactile Neumorphic personal finance utility balancing soft extrusion with a frosted glass navigation layer. | Strong Identity |
| **Signature Element** | Squircle badge hierarchy + electric lime primary accents (`#86E829`) on monochromatic canvas. | Distinct & Memorable |

The app excels in visual discipline: it respects the two-layer material separation (translucent glass reserved exclusively for the floating navigation bar; soft extruded neumorphism for content cards) and avoids generic AI template tropes. However, to meet Apple App Store review and iOS platform standards, it requires remediation in **tap target sizes (minimum 44 pt)**, **screen reader semantics**, **destructive action confirmations**, and **system haptic feedback**.

---

## 2. Critical Findings (Must Fix)

### C-1: Navigation Back Button Tap Targets Below 44 pt
- **Location:**  
  - [`add_expense_screen.dart#L142`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/add_expense_screen.dart#L142)  
  - [`split_detail_screen.dart#L167`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_detail_screen.dart#L167)  
  - [`split_summary_screen.dart#L62`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_summary_screen.dart#L62)
- **What:** The circular neumorphic back button container is hardcoded to `width: 38, height: 38` inside `AppBar.leading`.
- **Why (*accessibility.md › Controls*):**  
  > *"Give controls a hit target of at least 44x44 pt on mobile (48x48 dp on Android)... Spacing between controls matters as much as size."*  
  At 38 × 38 pt, the button falls below Apple's mandated target size, risking missed taps in one-handed navigation.
- **Fix:** Expand the touch area to at least 44 × 44 pt by wrapping the container in `SizedBox(width: 44, height: 44)` or increasing the padding inside `InkWell`.

---

### C-2: Missing Accessibility Labels on Custom Neumorphic Checkboxes and Controls
- **Location:**  
  - [`friend_selection_tile.dart#L78-95`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/widgets/friend_selection_tile.dart#L78-L95)  
  - [`home_header.dart#L52-65`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/home/presentation/widgets/home_header.dart#L52-L65)  
  - Back buttons across all three expense screens.
- **What:** Custom squircle checkboxes and icon-only buttons do not declare semantic roles or checked states to assistive technologies.
- **Why (*accessibility.md › Screen readers* & *buttons.md › Content*):**  
  > *"Every icon-only control has a text label for screen readers... Supply a clear label and announce state changes."*  
  VoiceOver reads the custom checkbox as an uninformative "button" rather than announcing "Selected" / "Unselected" or "Checked".
- **Fix:** Wrap `FriendSelectionTile` in:
  ```dart
  Semantics(
    label: friend.name,
    checked: isSelected,
    role: SemanticsRole.checkbox,
    child: ...
  )
  ```
  and provide `tooltip: 'Back'` or `Semantics(label: 'Back', button: true)` on top navigation icons.

---

## 3. Improvements (Should Fix)

### I-1: Instant Irreversible Deletion in Friends and Groups List (Severity: High)
- **Location:**  
  - [`friends_tab.dart#L219`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/friends/presentation/screens/friends_tab.dart#L219)  
  - [`friend_list_item.dart#L71-78`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/friends/presentation/widgets/friend_list_item.dart#L71-L78)
- **What:** Tapping the red trash icon instantly deletes the friend or group from storage without warning, confirmation dialog, or undo snackbar.
- **Why (*alerts.md › Destructive actions* & *modality.md › Action sheets*):**  
  > *"Destructive, irreversible actions get a warning and a Cancel. Undo covers the rest."*
- **Fix:** When deleting a friend or group, present an iOS confirmation action sheet (`CupertinoActionSheet`) or provide a floating SnackBar with an `Undo` action. Alternatively, adopt the native iOS swipe-to-delete idiom using Flutter's `Dismissible`.

---

### I-2: Onboarding Page Indicator Disconnected from Swipe Controller (Severity: Medium)
- **Location:**  
  - [`onboarding_screen.dart#L77-80`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/onboarding/presentation/screens/onboarding_screen.dart#L77-L80)
- **What:** The onboarding screen renders a 3-dot `OnboardingPageIndicator(totalPages: 3, currentPage: 0)` with no `PageView` or swipeable slides.
- **Why (*page-controls.md › Guidelines*):**  
  > *"Always pair a page control with a view that allows people to navigate between pages sequentially, such as a scroll view or paging collection view."*  
  Displaying pagination dots that cannot be paged confuses users who attempt to swipe left.
- **Fix:** Embed the header visual, title, and subtitle into a `PageView.builder` so users can horizontally swipe through 3 onboarding benefit slides.

---

### I-3: Total Absence of System Haptic Feedback (Severity: Medium)
- **Location:** Throughout all interactive widgets in `lib/`.
- **What:** Zero occurrences of `HapticFeedback` exist in the codebase.
- **Why (*playing-haptics.md › Use haptics purposefully*):**  
  > *"Use haptics to enhance the physical feel of digital interactions. Light impacts provide subtle confirmation when changing selections, medium impacts confirm significant actions like saving or settling."*  
  Neumorphic UI is inherently tactile; without haptics, the app feels visually physical but physically lifeless on real devices.
- **Fix:**
  - `HapticFeedback.selectionClick()` when selecting/deselecting friends or toggling tabs.
  - `HapticFeedback.lightImpact()` when pressing quick action tiles and buttons.
  - `HapticFeedback.mediumImpact()` when tapping "Save & Track Settlement".

---

### I-4: Dead Clicks on Default Mock Activities (Severity: Low)
- **Location:**  
  - [`activity_item_row.dart#L30-36`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/activity/presentation/widgets/activity_item_row.dart#L30-L36)
- **What:** Default mock items ("Dinner at Sakali", "Goa Trip Fuel") display active tap ripples (`InkWell`), but tapping them does nothing because their `splitActivity` property is null.
- **Why (*feedback.md › Responsiveness*):**  
  > *"Every interactive element must provide feedback or open detail sheets. Never offer an apparent touch target that fails to respond."*
- **Fix:** Seed default mock activities with pre-built `SplitActivity` objects so tapping them opens the `ActivityDetailSheet`.

---

## 4. Craft Notes & Aesthetic Evaluation

- **Point of View & Aesthetic Identity**:  
  The app avoids the common AI template traps (such as generic flat purple gradients or sterile monochrome wireframes). The soft tactile relief (`depth: 5`, `#D1D9E6` dark shadow and `#FFFFFF` specular highlight) paired with the electric lime (`#86E829`) gives it a distinct neo-fintech identity.
- **Restraint**:  
  The color budget is well-disciplined. Screens maintain a strict one-prominent-action rule:
  - Add & Split: Single prominent "Continue →" button.
  - Split Detail: Single prominent "Confirm Split →" button.
  - Split Summary: Single prominent "Save & Track Settlement" button.
- **Two-Layer Material Purity**:  
  The codebase strictly prevents Liquid Glass leakage into content cards, adhering to the standard Apple material hierarchy.

---

## 5. What Works (Notable Strengths)

1. **Clear Typographic Hierarchy**:  
   Bold display titles (`FontWeight.w800` to `w900`), high contrast dark charcoal `#111713` against `#F4F6F8` background (> 12:1 contrast ratio, far exceeding the 4.5:1 requirement).
2. **Indian Rupee Formatting**:  
   Clean integer display (`₹549`, `₹2,800`) avoiding annoying superfluous decimals (`.00`).
3. **Mathematical Transparency**:  
   `MemberBreakdownTable` and `SettlementCard` clearly compute who paid what, their fair share, and the exact minimum transaction sequence to settle debt.
4. **Bottom Padding & Floating Bar Avoidance**:  
   Scrollable views correctly utilize `padding: EdgeInsets.fromLTRB(20, 16, 20, 110)` ensuring content is never stuck under the floating glass navigation bar.

---

## 6. Recommended Action Plan

| Step | Action Item | Target File(s) | Priority |
| :---: | :--- | :--- | :---: |
| **1** | Increase all circular back navigation tap targets to >= 44x44 pt. | `add_expense_screen.dart`, `split_detail_screen.dart`, `split_summary_screen.dart` | **Critical** |
| **2** | Add `Semantics` labels and traits to custom checkboxes, bell icon, and back buttons. | `friend_selection_tile.dart`, `home_header.dart` | **Critical** |
| **3** | Add iOS-style confirmation / swipe-to-delete on friend & group removal. | `friends_tab.dart`, `friend_list_item.dart` | **High** |
| **4** | Integrate iOS `HapticFeedback` across taps, selection, and split saves. | `split_summary_screen.dart`, `friend_selection_tile.dart`, `main_screen.dart` | **Medium** |
| **5** | Connect Onboarding page dots to a swipeable `PageView`. | `onboarding_screen.dart` | **Medium** |
| **6** | Enable `ActivityDetailSheet` for default mock activities. | `activity_tab.dart`, `activity_item_row.dart` | **Low** |

