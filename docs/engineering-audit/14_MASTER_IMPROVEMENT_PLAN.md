# 14 — Master Engineering Improvement Plan

This document contains the complete engineering transformation roadmap for TTMM Club to achieve a clean, modular, scalable, and secure architecture.

*(Refer to the complete artifact version at [`recommended_engineering_improvement_plan.md`](file:///Users/roshanbadwaik/.gemini/antigravity/brain/26b53132-f971-4d51-8cc7-978c35ae5940/recommended_engineering_improvement_plan.md) for full interactive diagrams and task checklists).*

---

## Executive Phase Summary

| Phase | Milestone | Priority | Focus |
| :---: | :--- | :---: | :--- |
| **Phase 0** | **RLS Security & Concurrency Guard** | **P0** | Enforce PostgreSQL Row-Level Security and add optimistic locking `version` to eliminate lost updates. |
| **Phase 1** | **God Screen Deconstruction** | **P1** | Break `split_detail_screen.dart` (5,756 LoC) into 8 focused single-responsibility files (< 400 LoC each). |
| **Phase 2** | **Domain Engine & Integer Paise Math** | **P1** | Extract `StoryCalculationEngine` and `Money` (integer paise) to permanently eliminate floating-point drift. |
| **Phase 3** | **Code Cleanliness & Deduplication** | **P2** | Unify `UserIdentityResolver`, extract reusable bottom sheet shells, and add structured error tracking. |
| **Phase 4** | **Database Schema Normalization** | **P2** | Transition from monolithic `data` JSONB to relational tables (`expenses`, `shares`, `settlements`). |
| **Phase 5** | **Production Verification Gates** | **P3** | Enforce CI/CD quality gates, zero linter warnings, and all 33 test suites passing. |
