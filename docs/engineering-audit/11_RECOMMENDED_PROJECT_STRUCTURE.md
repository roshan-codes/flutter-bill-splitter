# 11 — Recommended Project Structure

This structure balances **Feature-First Domain-Driven Design (DDD)** with Flutter conventions, ensuring high cohesion, modularity, and rapid navigation without over-engineering.

---

## 1. Proposed Directory Topology

```
lib/
├── app/                             # Top-level application bootstrap & global configuration
│   ├── app.dart                     # MaterialApp, Theme configuration, Global Route Guards
│   └── app_bootstrap.dart           # Service initialization sequence (Supabase, Storage, Logging)
├── core/                            # Cross-cutting foundational utilities (Framework-level only)
│   ├── animations/                  # AppMotion curves and transitions
│   ├── constants/                   # Static constants, supported currencies, category enums
│   ├── errors/                      # Typed domain exceptions (NetworkException, AuthException)
│   ├── formatting/                  # CurrencyFormatter, DateFormatter, StringUtils
│   ├── network/                     # SupabaseClient wrapper, HTTP retry interceptors
│   ├── storage/                     # SecureStorage, LocalCache contracts
│   └── theme/                       # Neumorphic palette, typography tokens, squircle borders
├── features/                        # Business domain modules (Vertical slices)
│   ├── activity/                    # Activity feed & event timeline
│   │   ├── data/                    # ActivityRepository, SupabaseActivityDataSource
│   │   ├── domain/                  # SplitActivity model, ActivityType enum
│   │   └── presentation/            # ActivityTab, ActivityCard, ActivityDetailSheet
│   ├── auth/                        # User authentication, Google OAuth, session state
│   │   ├── data/                    # AuthRepository, SupabaseAuthDataSource
│   │   ├── domain/                  # UserProfile model, AuthSession
│   │   └── presentation/            # OnboardingScreen, SplashScreen, GoogleSignInButton
│   ├── friends/                     # Contacts & peer directory
│   │   ├── data/                    # FriendsRepository, ContactsDeviceService
│   │   ├── domain/                  # Friend model, ContactEntry
│   │   └── presentation/            # FriendsTab, ImportContactsSheet, AddFriendDialog
│   ├── profile/                     # User preferences & account management
│   │   ├── data/                    # ProfileRepository
│   │   ├── domain/                  # UserSettings, MemoAvatar
│   │   └── presentation/            # ProfileTab, MemoAvatarPickerSheet
│   └── stories/                     # Primary Core Domain (Trips, Groups, Splits, Settlements)
│       ├── data/
│       │   ├── datasources/         # SupabaseStoryDataSource, LocalStoryCache
│       │   ├── models/              # StoryDto, ExpenseDto (JSON serializers)
│       │   └── repositories/        # StoryRepository implementation
│       ├── domain/
│       │   ├── entities/            # Story, StoryMember, StoryExpense, Settlement
│       │   ├── services/            # DebtSimplificationEngine, BalanceCalculator, DeduplicationService
│       │   └── value_objects/       # Money (integer paise), SplitShare
│       └── presentation/
│           ├── controllers/         # StoryDetailController, AddExpenseController
│           ├── screens/             # StoryDetailScreen, CreateStoryScreen, JoinStoryScreen
│           ├── tabs/                # StoryOverviewTab, StoryExpensesTab, StoryMembersTab
│           ├── sheets/              # AddExpenseSheet, EditExpenseSheet, SettlementPlanSheet
│           └── widgets/             # MemberBalanceRow, ExpenseItemRow, SettlementCard
└── shared/                          # Universal UI components shared across 2+ features
    └── widgets/                     # AppAvatar, SquircleAvatar, EmptyStateView, PlatformAdaptive
```

---

## 2. File Migration Mapping Table

| Existing Location | Proposed Location | Architectural Justification |
| :--- | :--- | :--- |
| `lib/features/expenses/presentation/screens/split_detail_screen.dart` | `lib/features/stories/presentation/screens/story_detail_screen.dart` + tabs/ + sheets/ | Deconstruct 5,756 LoC god screen into modular tabs and sheets under the Stories feature. |
| `lib/features/expenses/presentation/screens/split_summary_screen.dart` | `lib/features/stories/presentation/sheets/settlement_plan_sheet.dart` | Moves settlement modal into the story domain where it belongs. |
| `lib/features/stories/domain/models/story.dart` (Calculations) | `lib/features/stories/domain/services/balance_calculator.dart` | Separates immutable data models from financial calculation logic. |
| `lib/features/expenses/domain/services/expense_calculator.dart` | `lib/features/stories/domain/services/debt_simplification_engine.dart` | Eliminates duplicated debt settlement minimization algorithms. |
| `lib/core/services/supabase_service.dart` (Story Queries) | `lib/features/stories/data/datasources/supabase_story_datasource.dart` | Enforces layer boundaries: feature data sources handle table queries. |
| `lib/core/services/supabase_service.dart` (Auth) | `lib/features/auth/data/datasources/supabase_auth_datasource.dart` | Isolates auth lifecycle from group data queries. |
| `lib/core/routing/app_auth_gate.dart` | `lib/features/auth/presentation/guards/auth_gate.dart` | Auth routing belongs in the auth feature. |
| `lib/shared/widgets/google_sign_in_button.dart` | `lib/features/auth/presentation/widgets/google_sign_in_button.dart` | Feature-specific auth component. |

---

## 3. Directory Governance Rules

### Rule 1: No Feature-to-Feature Horizontal Dependencies
A feature module (`features/activity`) must **never directly import another feature's presentation layer** (`features/stories/presentation/...`). Features communicate exclusively via **Domain Entities** or **Shared Event Streams**.

### Rule 2: Domain Purity
Nothing in `domain/` may import `package:flutter/material.dart`, `package:supabase_flutter`, or `package:shared_preferences`. The domain represents pure business logic capable of running in a headless Dart VM CLI or server environment.

### Rule 3: Single-Screen Responsibility
A Screen file must not exceed **400 lines of code**. If a screen requires bottom sheets or complex sub-views, they must be extracted into dedicated files in `presentation/sheets/` or `presentation/widgets/`.
