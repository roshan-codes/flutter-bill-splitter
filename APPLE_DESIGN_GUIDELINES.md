# Apple Design Guidelines & Review System
> Grounded in Apple's Human Interface Guidelines (HIG), Craft Principles, and Modern Flutter Architecture.

This document serves as the design manual and architectural standard for the **Flutter Bill Splitter** application. Every screen, component, animation, and interaction in this codebase must adhere to these guidelines to ensure an authentic, polished, and delightful user experience that feels natively at home on iOS while maintaining a distinctive brand identity.

---

## 1. Apple's Core Design Principles (2026 Edition)

When evaluating or designing any feature in this app, filter the work through Apple's eight foundational design principles:

| Principle | Apple's Guideline | Application to Bill Splitter |
| :--- | :--- | :--- |
| **Purpose** | *Make something meaningful* | Every screen has exactly one primary objective: effortlessly split bills and track debt settlements without friction. |
| **Agency** | *Let people do things their own way* | Allow users to split equally or customize amounts per member; provide quick dismissals, easy back navigation, and mistake recovery. |
| **Responsibility** | *Act in people's best interest* | Show transparent mathematical breakdowns (`ExpenseCalculator`), accurate rounding, and immediate visual settlement confirmation. |
| **Familiarity** | *Build on what people know* | Employ standard iOS idioms: bottom navigation bar for top-level destinations, modal sheets for creation tasks, and push transitions for multi-step flows. |
| **Flexibility** | *Adapt to diverse contexts and needs* | Support Dynamic Type scaling, accessibility screen readers, light/dark contrast, and varied device safe areas. |
| **Simplicity** | *Be clear and direct* | Remove visual clutter. Every badge, line, and container must justify its presence. |
| **Craft** | *Care about every detail* | Precise typographic hierarchy, soft neumorphic depth, pixel-aligned 44pt tap targets, and subtle tactile haptic responses. |
| **Delight** | *Make it human* | Tactile squircle badges, subtle specular glass reflections, and smooth spring physics. Never substitute decorative clutter for true delight. |

---

## 2. Two-Layer Material Architecture

Apple's design architecture establishes a strict separation between content and controls:

```text
┌─────────────────────────────────────────────────────────────────┐
│ FUNCTIONAL LAYER (Floating Glass / Overlays)                    │
│ • Neumorphic Glass Navigation Bar (Frosted glass + specular)    │
│ • Bottom Sheets & Modal Dialogs                                 │
│ • Fixed Floating Bottom Action Bars                             │
├─────────────────────────────────────────────────────────────────┤
│ CONTENT LAYER (Neumorphic Surfaces & Data)                      │
│ • Soft concave / convex Neumorphic Cards                        │
│ • Member Breakdown Tables & Friend Lists                        │
│ • Form Inputs, Quick Actions, and Activity Feeds                │
└─────────────────────────────────────────────────────────────────┘
```

### Rules of Material Discipline
1. **Never use Glass in the Content Layer**:
   - Liquid Glass and glassmorphic blurs belong exclusively to the **functional layer** (the floating navbar and transient overlays).
   - Cards, list tiles, and tables in the content layer must use soft extruded **Neumorphic styles** (`NeumorphicStyles.card`), never raw transparent blurs.
2. **Restraint Over Decoration**:
   - Glass stacked on glass blurs hierarchy. Keep the background clean (`#F4F6F8`) so the floating navbar has something crisp to blur.
3. **Scroll Edge Effect**:
   - Always provide adequate bottom padding (`EdgeInsets.fromLTRB(20, 16, 20, 110)`) on scrollable screens so content scrolls cleanly beneath the glass navbar without being permanently obscured.

---

## 3. Visual Design, Craft & Color Budget

### Typography (SF Pro / System Scale)
- **Large Title / Display**: `28–32 pt`, `FontWeight.w800`, letter spacing `-0.5`. (e.g. Welcome headers).
- **Screen Title**: `18–22 pt`, `FontWeight.w800`, letter spacing `-0.3`. (e.g. "Add & Split Expense", "Split Summary").
- **Section Headers**: `16–17 pt`, `FontWeight.w800`, letter spacing `-0.2`. (e.g. "Who Pays Whom", "Recent Expenses").
- **Body Text**: `14–16 pt`, `FontWeight.w500` or `w600`.
- **Captions & Metadata**: `12–13 pt`, `FontWeight.w500`, muted slate `#6B7280`.
- **Dynamic Type**: All text widgets must scale properly with user accessibility settings (`MediaQuery.textScalerOf(context)`).

### Color Palette & Semantic Roles
| Role | Color Hex | Usage |
| :--- | :--- | :--- |
| **Background** | `#F4F6F8` | Canvas surface for soft neumorphic light/shadow relief. |
| **Surface Card** | `#FFFFFF` | Neumorphic extruded elements (`lightShadow: #FFFFFF`, `darkShadow: #D1D9E6`). |
| **Primary Accent** | `#86E829` / `#A3E635` | Vibrant electric lime reserved for primary action buttons and prominent badges. |
| **Positive / Credit** | `#16A34A` | "You get ₹..." or settled green indicators. |
| **Negative / Debit** | `#DC2626` | "You owe ₹..." debt indicators. |
| **Text Primary** | `#111713` | High-contrast dark charcoal/black for maximum legibility. |
| **Text Secondary** | `#6B7280` | Muted neutral for subtitles, hints, and timestamps. |

### Color Budget Rules
- **One Signature Action**: Only **one** primary prominent button per view (e.g., "Confirm Split →", "Save & Track Settlement").
- **Monochrome Control Base**: Keep standard icons and labels monochrome (`#111713`); reserve the brand lime accent for active states and primary actions.

---

## 4. Accessibility & Touch Targets (Lens 1)

Accessibility is non-negotiable. An interface that is not accessible fails Apple review.

1. **Hit Targets**:
   - Every tappable control (buttons, icons, checkboxes, avatar pills, tabs) must have a minimum interactive bounding box of **44 × 44 pt** (`kMinInteractiveDimensionCupertino`).
   - Add adequate padding or wrap compact icons in `SizedBox(width: 44, height: 44)`.
2. **Contrast Ratios**:
   - Regular text (< 18 pt): **Minimum 4.5:1** contrast ratio against its background.
   - Large or bold text (>= 18 pt or bold >= 14 pt): **Minimum 3:1** contrast ratio.
   - Active green badge (`#86E829`) must use dark charcoal text (`#10210A`) to maintain a > 7:1 contrast ratio.
3. **Color Independence**:
   - Never communicate critical information through color alone. Pair red/green debt figures with explicit text ("You get ₹...", "You owe ₹...").
4. **Screen Reader Semantics**:
   - Provide `Semantics(label: "...", button: true)` for custom neumorphic gesture detectors and icon-only buttons (such as back arrows, notifications, and settlement arrows).

---

## 5. Navigation & Interaction Patterns (Lens 2 & 4)

### Navigation Architecture
- **Bottom Navigation Bar**:
  - Exactly 4 primary destinations: **Home**, **Friends**, **Activity**, **Profile**.
  - Tabs navigate between top-level states; they never trigger immediate destructive or create actions.
  - Active tabs use filled squircle badges with vibrant brand tinting; inactive tabs use clean outlines.
- **Modality & Flow**:
  - **Bottom Sheets (`showModalBottomSheet`)**: Reserved for short, single-task creation dialogs (e.g. "Add New Friend", "Create New Group", "Add Member"). Must include a drag grabber, clear title, and easy cancel/dismiss gesture.
  - **Push Navigation (`Navigator.push`)**: Used for sequential wizard journeys (e.g. Add Expense → Split with Members → Split Summary). Always provides a tactile back button (`<`) in the top-left corner.
  - **Keyboard Handling**: Form views must include `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` and avoid bottom overflow using `SafeArea` and scroll containers.

### Tactile Feedback (Haptics)
Incorporate iOS system haptics at pivotal user touchpoints:
```dart
// Light impact on selecting members, toggling tabs, or tapping pills
HapticFeedback.lightImpact();

// Selection click on checkbox / radio updates
HapticFeedback.selectionClick();

// Medium impact on completing an expense split or settling debt
HapticFeedback.mediumImpact();
```

---

## 6. Content, Copy & Micro-Typography (Lens 5)

1. **Action-Oriented Verbs**:
   - Buttons must clearly declare their consequence: "Confirm Split →", "Save & Track Settlement", "Add Friend", not vague labels like "OK" or "Submit".
2. **Indian Currency Formatting**:
   - Format currency cleanly with the Rupee symbol: `₹549`, `₹2,800`.
   - Never show redundant decimals when the amount is a whole number (display `₹183`, not `₹183.00`).
3. **Consistent Capitalization**:
   - Use **Title Case** for screen headers, button labels, and section titles ("Add & Split Expense", "Who Pays Whom", "Member Breakdown").
   - Use **Sentence case** for helper hints and empty state descriptions ("All settled up! Everyone paid equally.").
4. **Empty State Hospitality**:
   - When no activities or friends exist, render an `EmptyStateView` with a welcoming neumorphic squircle icon, clear title, explanatory paragraph, and an immediate action button.

---

## 7. The 5-Lens Apple HIG Audit Checklist

Before merging any UI pull request or adding new screens, run this audit checklist:

- [ ] **Lens 1: Accessibility**:
  - Are all touch targets >= 44x44 pt?
  - Does text pass 4.5:1 contrast against the background?
  - Does the screen survive Dynamic Type scaling without clipping?
- [ ] **Lens 2: Platform Conventions**:
  - Does content respect the top status bar and bottom home indicator safe areas?
  - Are modal sheets dismissible via swipe down?
  - Does back navigation smoothly return to the previous view?
- [ ] **Lens 3: Visual Design & Craft**:
  - Is the two-layer architecture respected (Glass on navbar; Neumorphism in content)?
  - Is there only one primary prominent button on screen?
  - Are corners consistently radiused (`20–24 pt` for cards, `12–16 pt` for pills)?
- [ ] **Lens 4: Interaction**:
  - Does the screen provide immediate visual and haptic feedback on tap?
  - Are calculations instantaneous with zero UI blocking?
- [ ] **Lens 5: Copywriting**:
  - Are buttons labeled with specific, action-oriented verbs?
  - Are numbers formatted with `₹` and proper thousands separators?
