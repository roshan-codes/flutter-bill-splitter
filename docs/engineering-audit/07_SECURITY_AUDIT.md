# 07 — Security, Privacy & Vulnerability Audit

## 1. Threat Modeling & Attack Surface Overview

```mermaid
graph TD
    Attacker[Malicious Actor with Public Anon Key] -->|1. Direct REST Request| SupabaseREST[Supabase PostgREST API]
    SupabaseREST -->|2. RLS Disabled / Missing| DB[(PostgreSQL Database)]
    DB -->|3. Dumps all rows| Attacker
    
    subgraph Compromised Data
        AllStories[All Private Group Names & Locations]
        AllMembers[Names, Phone Numbers, User IDs]
        AllExpenses[Amounts, Receipts, Payment Habits]
    end
    Attacker --> CompromisedData
```

The application's attack surface consists of:
1. Client-to-Supabase REST API (PostgREST over HTTPS).
2. Supabase Realtime WebSocket channels.
3. Supabase Cloud Storage bucket (`app_data`).
4. Universal Deep Linking / Dynamic Links (`https://flutter-bill-splitter.onrender.com/invite?...`).
5. Client Local Storage (`SharedPreferences` on Android/iOS/Web).

---

## 2. Security Vulnerability Register

| ID | Vulnerability | Severity | CVSS v3.1 | Affected Component | Impact | Status |
| :---: | :--- | :---: | :---: | :--- | :--- | :---: |
| **SEC-01** | Missing Row-Level Security on `stories` Table | **Critical** | **8.5** | Supabase DB / `supabase_service.dart:508` | Complete cross-tenant information disclosure; any client can read all groups. | **Unpatched** |
| **SEC-02** | Missing RLS & Mutation Authorization on `stories` Table | **High** | **7.8** | Supabase DB / `supabase_service.dart:363` | Malicious client can overwrite or delete arbitrary group stories using public anon key. | **Unpatched** |
| **SEC-03** | Missing Server-Side Settlement Authorization | **High** | **7.4** | `split_summary_screen.dart` / `StorySettlement` | Any member can mark debts owed to *other* members as "Paid" without cryptographic verification. | **Unpatched** |
| **SEC-04** | Unencrypted Storage of Device Contacts & User Data | **Medium** | **5.3** | `FriendsRepository` / `SharedPreferences` | Physical access to rooted device exposes imported user phonebooks. | **Architectural** |
| **SEC-05** | Public Read Access to Cloud Storage Bucket (`app_data`) | **Medium** | **5.5** | Supabase Storage `app_data` | Storage paths `stories/$userId/$storyId.json` may be enumerated if bucket is public. | **Needs Audit** |
| **SEC-06** | Hardcoded Default Anon Key in Git Repository | **Low** | **3.8** | `lib/core/config/app_config.dart:14` | Anon key is public by design in Supabase, but exposes database if RLS is disabled. | **Tolerated if RLS Enabled** |

---

## 3. Deep Dive into Critical Vulnerabilities

### SEC-01 & SEC-02: Unrestricted Cross-Tenant Data Access
- **Mechanism:**  
  The anon key (`sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez`) is packaged inside the compiled client binary. Because PostgreSQL Row-Level Security policies are missing on `public.stories`, the PostgREST layer treats the request as authorized for full table read/write:
  ```bash
  # Any external client can execute this without authenticating:
  curl 'https://hqfdwqrhtertpvlmwvsk.supabase.co/rest/v1/stories?select=*' \
    -H 'apikey: sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez' \
    -H 'Authorization: Bearer sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez'
  ```
- **Consequence:**  
  This returns every trip, party, and roommate expense group created by every user of the platform.
- **Remediation:**  
  Execute the RLS policy defined in [`docs/engineering-audit/05_DATABASE_AND_API_AUDIT.md`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/docs/engineering-audit/05_DATABASE_AND_API_AUDIT.md#L115) immediately on Supabase.

---

### SEC-03: Client-Side Settlement Spoofing
- **Mechanism:**  
  In `SplitSummaryScreen` ([`split_summary_screen.dart#L1040`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/features/expenses/presentation/screens/split_summary_screen.dart#L1040)), tapping "Mark as Paid" sets `settlement.status = 'completed'` and immediately persists the updated story to Supabase.
- **Flaw:**  
  There is no two-party handshake (e.g. Debtor claims "I sent payment via UPI ref #12345"; Creditor verifies "Payment received"). Currently, any member of the group can mark someone else's ₹5,000 debt as paid.
- **Remediation:**  
  Implement a two-step settlement state machine:
  $$\text{Pending} \xrightarrow{\text{Debtor Marks Paid}} \text{Payment Proposed} \xrightarrow{\text{Creditor Confirms}} \text{Completed}$$

---

## 4. Secret Management & Compilation Environment

In [`lib/core/config/app_config.dart`](file:///Users/roshanbadwaik/Developer/flutter-bill-splitter/lib/core/config/app_config.dart):
```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://hqfdwqrhtertpvlmwvsk.supabase.co',
);
static const String supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_E55yVbk-WsMaVFFi6BP50g_VCIXQOez',
);
```
- **Assessment:**  
  In Supabase architecture, the `anon` / `publishable` key is intended to be public in browser and mobile clients. **However, it is ONLY secure when Row-Level Security (RLS) is enabled and strictly enforced in PostgreSQL.**
  Without RLS, having default keys embedded in the repository grants administrative read/write access to the entire database.
- **Recommendation:**  
  1. Remove hardcoded default values in production release workflows; supply `--dart-define=SUPABASE_ANON_KEY=...` during CI/CD build.
  2. Rotate the Supabase publishable key after enabling RLS.
