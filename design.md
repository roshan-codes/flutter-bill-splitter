# BillSplit — UI/UX Design Guidelines

**Document type:** Product Design System  
**Version:** 1.0  
**Platform:** Mobile app (iOS and Android)  
**Visual direction:** CRED-inspired, premium, minimal fintech  
**Product:** Group expense stories, bill splitting, contribution tracking, and settlements  

---

## 1. Product Design Principles

BillSplit should make shared expenses feel simple, transparent, and trustworthy.

### Core Principles
1. **Clarity first:** Users should understand total spending, their contribution, and what they owe at a glance.
2. **Minimal by default:** Show essential information first; keep secondary details one tap away.
3. **Numbers are the hero:** Expense totals, balances, and settlement amounts should have strong visual hierarchy.
4. **Trust through transparency:** Every balance must be explainable through individual transactions and split details.
5. **Fast interactions:** Adding an expense or creating a story should require as few steps as practical.
6. **Consistent patterns:** Reuse the same cards, buttons, spacing, and interaction patterns throughout the app.

> **Note on Visual Inspiration:** Do not copy CRED branding, logos, illustrations, or proprietary assets. Use its broad visual inspiration — strong typography, restrained colors, generous whitespace, and polished surfaces — to create a distinct BillSplit identity.

---

## 2. Visual Identity

### Design Personality
- Premium
- Minimal
- Confident
- Friendly
- Financially clear
- Calm, not overly playful

### Color Palette

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `background` | `#F7F7F5` | Main app background |
| `surface` | `#FFFFFF` | Cards, sheets, input surfaces |
| `surface-subtle` | `#F1F1EF` | Secondary surfaces and chips |
| `text-primary` | `#111111` | Headings and primary content |
| `text-secondary` | `#777777` | Supporting text |
| `text-tertiary` | `#A0A0A0` | Hints and low-emphasis labels |
| `border` | `#EAEAE7` | Dividers and subtle outlines |
| `primary` | `#111111` | Primary buttons and selected controls |
| `success` | `#247A45` | Positive balances and settled states |
| `success-soft` | `#E7F4E9` | Positive balance backgrounds |
| `danger` | `#C74747` | Amounts owed and error states |
| `danger-soft` | `#FBEAEA` | Negative balance backgrounds |
| `warning` | `#A66A16` | Pending or attention states |
| `warning-soft` | `#FFF3DC` | Warning backgrounds |

### Color Rules
- Use off-white (`#F7F7F5`) for the overall background and white (`#FFFFFF`) for primary cards.
- Use near-black (`#111111`) for primary actions and important text.
- Reserve green (`#247A45`) for money to receive, successful actions, and settled states.
- Reserve red (`#C74747`) for money owed and destructive/error states.
- Never communicate financial status by color alone; always include an explicit label or sign (`+`, `-`).
- Avoid using multiple bright accent colors on the same screen.

---

## 3. Typography

**Recommended Typeface:** `Manrope`  
Use Manrope consistently across the app. It is a practical, modern sans-serif choice for a premium fintech interface.

### Typography Hierarchy

| Style | Size | Weight | Typical Usage |
| :--- | :--- | :--- | :--- |
| **Display** | 32 px | ExtraBold (800) | Major expense total |
| **Screen title** | 28 px | Bold (700) | Page headings |
| **Section title** | 20 px | Bold (700) | Group summary, transactions |
| **Card title** | 17 px | SemiBold (600) | Story and expense names |
| **Body** | 15 px | Regular (400) | Main descriptions |
| **Body emphasis** | 15 px | SemiBold (600) | Important values |
| **Supporting** | 13 px | Regular (400) | Dates and metadata |
| **Caption** | 11–12 px | Medium (500) | Small labels |

### Typography Rules
- Use sentence case, not all caps, for most headings.
- Use tabular figures for currency and financial totals where supported.
- Keep line lengths comfortable and avoid dense paragraphs.
- Use bold weights to establish hierarchy, not to emphasize every label.
- Display currency symbols consistently, e.g. `₹20,000`.
- Do not shrink important totals to fit; allow wrapping or adjust layout.

---

## 4. Spacing and Layout

Use an **8-point spacing system**.

### Spacing Tokens

| Token | Value |
| :--- | :--- |
| `space-1` | 4 px |
| `space-2` | 8 px |
| `space-3` | 12 px |
| `space-4` | 16 px |
| `space-5` | 20 px |
| `space-6` | 24 px |
| `space-8` | 32 px |
| `space-10` | 40 px |
| `space-12` | 48 px |

### Layout Rules
- Standard horizontal screen padding: `20–24 px`.
- Keep at least `16 px` between related content groups.
- Use `24–32 px` between major sections.
- Align card edges, headings, and primary actions consistently.
- Respect device safe areas and system status/navigation bars.
- Avoid placing important actions too close to the screen edge.
- Use a scrollable content area when the screen cannot fit comfortably.

### Corner Radius

| Component | Radius |
| :--- | :--- |
| **Large feature card** | 24 px |
| **Standard card** | 20 px |
| **Input field** | 14–16 px |
| **Primary button** | 16–18 px |
| **Chips and pills** | 999 px (fully rounded) |
| **Small icon container** | 12–14 px |

---

## 5. Surfaces, Cards, and Elevation

### Cards
- Use white surfaces on the off-white background.
- Prefer subtle borders (`1 px solid #EAEAE7`) over heavy shadows.
- Group information by purpose: trip summary, member balances, and transactions.
- Keep card content aligned and consistently padded.
- Avoid nesting many cards inside other cards.

### Elevation
Use restrained elevation only when it helps establish hierarchy:
- **Main content cards:** Subtle shadow (`0 2px 8px rgba(0,0,0,0.04)`) or a 1 px border.
- **Bottom sheets:** Slightly stronger shadow (`0 -4px 16px rgba(0,0,0,0.08)`).
- **Floating navigation or overlays:** Enough elevation to clearly distinguish from content.
- **Rule:** Avoid heavy neumorphism, strong glows, and large blurred shadows.

---

## 6. Buttons and Actions

### Primary Button
Use for the most important action on a screen, such as *Create story*, *Save expense*, or *Confirm settlement*.

| Property | Specification |
| :--- | :--- |
| **Height** | 54–56 px |
| **Background** | `#111111` |
| **Text** | `#FFFFFF` |
| **Font** | Manrope SemiBold, 15–16 px |
| **Radius** | 16–18 px |
| **Elevation** | None (flat, crisp) |
| **Horizontal padding** | 20–24 px |

*Primary buttons should generally span the available content width.*

### Secondary Button
- **Height:** 48–52 px.
- **Background:** `#F1F1EF` or white with a subtle border (`#EAEAE7`).
- **Text:** `#111111`.
- **Radius:** 14–16 px.
- Use for actions that are useful but not the main action.

### Tertiary Action
Use text buttons or icon buttons for low-emphasis actions such as *Edit*, *View all*, or *Cancel*.

### Destructive Action
Use red text (`#C74747`) or a restrained red-tinted surface (`#FBEAEA`). Always ask for confirmation before irreversible actions such as deleting a story or removing an expense.

### Button States
Define default, pressed, disabled, loading, and focused states. A disabled button must remain legible and must not look like an active action.

---

## 7. Inputs and Forms

### Input Fields
- **Minimum height:** 52–56 px.
- Use a clear label above or inside the field.
- Use a subtle border (`#EAEAE7`) and white background (`#FFFFFF`).
- Show validation errors close to the relevant field.
- Keep labels visible when the user enters a value.
- Use the correct keyboard for the field: numeric for amounts, text for names, and date picker for dates.

### Form Behavior
- Preserve entered data if the user navigates back from a picker or secondary modal.
- Clearly mark optional fields.
- Disable submission until required information is valid.
- Show a loading spinner during submission.
- Prevent accidental duplicate submissions with debounce / submission locking.
- Provide clear success and error feedback.

---

## 8. Iconography and Imagery

### Icons
- Use one consistent outline icon family, such as **Material Symbols Rounded**.
- Prefer simple monochrome icons.
- Standard icon sizes: `20–24 px`.
- Keep stroke weight and visual density consistent across all screens.
- Use icons with text labels for important or unfamiliar actions.

### Avatars
- Use circular member avatars.
- Keep avatar sizes consistent within each context (e.g. 36 px in lists, 48 px in headers).
- Provide initials or a neutral fallback icon when no profile image exists.
- Do not rely on avatar color alone to communicate balances or status.

### Illustrations
- Use illustrations sparingly, mainly for empty states or onboarding.
- Avoid decorative imagery that competes with financial information.

---

## 9. Navigation and Information Architecture

### Recommended Primary Navigation
1. **Stories:** All trips and shared expense groups.
2. **Activity:** Recent expense and settlement activity across stories.
3. **Profile:** Account and preferences.

### Within a Story
Use clear sections or tabs:
- **Overview**
- **Expenses**
- **Members**

Keep **Add expense** prominent within the story. Keep **Settle up** visible when there are outstanding balances. Do not overload the main navigation with actions that belong inside a story.

---

## 10. Screen Design Specifications

### 10.1 Stories Home
- **Purpose:** Let users find existing groups and create a new story.
- **Recommended Hierarchy:**
  1. App header and profile action.
  2. Screen title: `"Your stories"`.
  3. Short supporting line.
  4. Story cards.
  5. Primary `"Create story"` action.
- **Story Card Content:**
  - Story title and optional icon/cover.
  - Date range.
  - Member count and avatar stack.
  - Total expenses.
  - Active or archived status indicator.
  - Tap affordance to open the story.
- **Empty State:**
  - Explain that no stories exist yet.
  - Show one clear `"Create your first story"` action.

### 10.2 Create Story
- **Purpose:** Create an expense group for a trip or event.
- **Fields:**
  - Story title (required).
  - Description (optional).
  - Start date and end date (optional).
  - Currency (default to INR `₹` for an India-first experience).
  - Friends/members to add.
- **Interaction Rules:**
  - Make the story title the most prominent field.
  - Show selected friends as removable chips or compact member tiles.
  - Provide a clear add-friends action.
  - Prevent duplicate members.
  - Make it clear whether the creator is automatically included.
  - Keep the Create story button fixed near the bottom when appropriate, while respecting safe areas.
  - Explain what happens after creation.

### 10.3 Story Overview
- **Purpose:** Give users an immediate understanding of group spending and balances.
- **Recommended Hierarchy:**
  1. Story name, dates, and member count.
  2. Total group expenses.
  3. Per-person share (when an equal split is appropriate).
  4. Current user's net balance.
  5. Member contribution and balance list.
  6. Recent transactions.
  7. Add expense and Settle up actions.
- **Member Balance Details:**
  - **Paid:** Amount the member actually paid.
  - **Share:** Amount allocated to that member.
  - **Net balance:** Paid minus share, adjusted for recorded settlements.
- **Rule:** Use explicit labels such as *"Gets back"*, *"Owes"*, and *"Settled"*. Do not show a positive contribution as automatically meaning that a person is owed money.

### 10.4 Expenses List
- Each transaction row should show:
  - Expense icon or category badge.
  - Expense title.
  - Who paid.
  - Date.
  - Amount.
- Provide filters or grouping only when they help users find expenses. Tapping a row opens its detail view.

### 10.5 Add Expense
- **Fields:**
  - Expense title.
  - Amount.
  - Paid by.
  - Split between selected members.
  - Split type: equal or custom.
  - Optional date, category, note, and receipt.
- **Behavior:**
  - Show a live split preview before saving.
  - Make selected participants obvious.
  - For equal splits, show each person's exact amount.
  - For custom splits, validate that allocations add up exactly to the expense total.
  - Make it clear that the payer can be included or excluded from the split.
  - Do not assume every expense is shared by every member.

### 10.6 Expense Details
- **Content:**
  - Expense title and total amount.
  - Payer and date.
  - Participants included in the split.
  - Each participant's allocated share.
  - Notes or receipt image, if available.
  - Edit or delete actions according to permissions.

### 10.7 Settle Up
- **Purpose:** Help members clear outstanding balances.
- **Content:**
  - Who pays whom.
  - Amount for each suggested transfer.
  - Total amount remaining to settle.
  - Settlement status.
- **Post-Settlement Updates:**
  - Update relevant balances immediately.
  - Add a settlement entry to the activity/transaction history.
  - Show visual confirmation.
  - Keep a record of who marked it as paid and when.
- **Note:** A *"Mark as paid"* action records the settlement in the app; it does not itself transfer money unless an external payment integration is implemented.

---

## 11. Financial Logic and Content Rules

Financial clarity is a core product requirement.

### Definitions
- **Total expenses:** Sum of recorded group expenses.
- **Paid / Contribution:** Amount a member paid toward recorded expenses.
- **Share:** Amount allocated to a member across expenses.
- **Net balance:** Contributions minus allocated shares, adjusted for recorded settlements.
  - *Positive net balance:* The member should receive money (`Gets back`).
  - *Negative net balance:* The member owes money (`Owes`).

### Important Calculation Rules
- Calculate each expense split using its actual selected participants.
- Support unequal/custom splits alongside equal splits.
- Account for partial participation.
- Account for recorded settlements when calculating outstanding balances.
- Handle rounding consistently; the sum of individual shares must equal the expense total.
- Do not label total expenses divided by member count as everyone's share unless all expenses are equally shared by all members.
- Make every calculation traceable from the member balance back to underlying expenses and settlements.

### Language & Microcopy
**Prefer:**
- `"Total expenses"`
- `"You paid"`
- `"Your share"`
- `"You get back"`
- `"You owe"`
- `"Settled"`
- `"Pending settlement"`

**Avoid:**
- Ambiguous labels such as `"Your amount"` or `"Balance"` without context.

---

## 12. Interaction and Motion

- Use subtle transitions between screens.
- Use short haptic press feedback on buttons and selectable chips.
- Animate balance changes only when it helps users understand an update.
- Use bottom sheets for compact selections, such as choosing a payer or currency.
- Avoid decorative animations that delay common tasks.
- Respect reduced-motion accessibility settings.
- **Motion Principle:** Motion should feel quick, calm, and purposeful, not theatrical.

---

## 13. Responsive Design and Accessibility

- Design for common mobile screen widths and adapt seamlessly to smaller devices (e.g. 320–360 pt widths).
- Use a minimum touch target of approximately **44 × 44 pt / px**.
- Maintain readable contrast ratios (WCAG AA: at least 4.5:1 for body text, 3:1 for large headings).
- Do not communicate status using color alone.
- Support dynamic text scaling where practical.
- Ensure forms and bottom sheets remain usable and scrollable when the virtual keyboard is open.
- Respect iOS and Android safe areas (notch, home indicator, system gesture bars).
- Provide meaningful accessibility labels (`Semantics`) for icon-only buttons.
- Test with long names, large currency amounts (`₹1,00,00,000+`), and diverse screen densities.

---

## 14. Flutter Implementation Guidance

### Suggested Foundations
- Centralize colors, typography, spacing, and radii in dedicated theme/token files.
- Build reusable widgets for buttons, cards, inputs, avatars, amount labels, and member rows.
- Use a centralized app theme rather than styling each screen independently.
- Keep business calculations outside presentation widgets (e.g. dedicated domain services).
- Format currency through a shared utility that respects selected currency and locale.
- Model expense splits and settlements explicitly; do not derive financial truth from UI-only values.

### Suggested Design-Token File Structure

```
lib/
  core/
    theme/
      app_colors.dart
      app_text_styles.dart
      app_spacing.dart
      app_radius.dart
      app_theme.dart
    utils/
      currency_formatter.dart
  shared/
    widgets/
      primary_button.dart
      secondary_button.dart
      app_card.dart
      amount_text.dart
      member_avatar.dart
      member_balance_tile.dart
      app_text_field.dart
```

### Typography Example
```dart
GoogleFonts.manrope(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: AppColors.textPrimary,
)
```

### Primary Button Example
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF111111),
    foregroundColor: const Color(0xFFFFFFFF),
    minimumSize: const Size(double.infinity, 56),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  ),
  onPressed: onPressed,
  child: Text(
    'Create story',
    style: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  ),
)
```

---

## 15. Do and Don't

### Do
- Use generous whitespace.
- Make important amounts easy to scan.
- Use consistent Manrope typography.
- Prefer clean white cards and subtle dividers.
- Keep primary actions visually obvious.
- Explain who owes whom and why.
- Show a live preview before saving a split.
- Keep transaction history completely transparent.

### Don't
- Use too many accent colors on one screen.
- Put multiple competing primary buttons on one screen.
- Use heavy gradients, glows, or strong blurred shadows everywhere.
- Hide important financial labels behind cryptic icons.
- Treat every expense as an equal split by default.
- Confuse the amount paid with the amount owed.
- Imply that recording a settlement transfers real bank money.
- Use tiny text for dates, amounts, or member names.

---

## 16. Definition of Done — UI Review Checklist

Before approving any screen or feature, verify:
- [ ] Follows shared color, typography, spacing, and radius tokens.
- [ ] Primary action is immediately obvious.
- [ ] Text and controls satisfy accessibility contrast standards.
- [ ] Touch targets are at least 44 × 44 pt.
- [ ] Amounts and currency formatting are consistent.
- [ ] Loading, empty, error, disabled, and success states are handled.
- [ ] Long names and large amounts do not break or overflow the layout.
- [ ] Keyboard opening and device safe-area insets are respected.
- [ ] Financial values have explicit, unambiguous labels.
- [ ] Tested and verified on smaller supported devices.
- [ ] No decorative element competes with the user's financial task.

---

## 17. Product Design North Star

> **BillSplit should make group money effortless to understand.**

Every important screen should answer one clear question:
- **Stories Home:** *"Which group do I want to open?"*
- **Create Story:** *"Who is part of this trip or event?"*
- **Story Overview:** *"How much have we spent, and where do I stand?"*
- **Expenses:** *"What was paid, and by whom?"*
- **Add Expense:** *"How should this bill be shared?"*
- **Settle Up:** *"Who needs to pay whom, and how much?"*

*If an element does not help answer the screen's main question or complete the user's task, reconsider whether it belongs on that screen.*
