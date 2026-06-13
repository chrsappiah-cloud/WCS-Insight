# WCS Insight

Apple-native implementation scaffold for the World Class Scholars spatial care and learning app family.

This repository is organized as a monorepo with a shared Swift package and staged app surfaces:

- `Packages/WCSCore` — shared design system, domain models, API contracts, repository interfaces, media upload, CloudKit sync boundaries, and feature flags.
- `Apps/MemoryAtlas` — first iPhone/iPad MVP for dementia-care reminiscence sessions.
- `Apps/ScholarSphereStudio` — iPad-first authoring surface for immersive therapeutic and educational modules.
- `Apps/PresencePlayVision` — visionOS-first shared narrative/co-therapy prototype.
- `Apps/PresencePlayCompanion` — iPhone/iPad companion for invitations, scheduling, onboarding, and summaries.
- `supabase/migrations` — Supabase/Postgres schema and starter RLS.
- `Docs` — product architecture, API contract, rollout plan, and display prompts.

## Implementation priority

1. Build `WCSCore`.
2. Ship `MemoryAtlas` iPhone/iPad shell.
3. Add WidgetKit + ActivityKit engagement loops.
4. Add CloudKit private sync for personal continuity.
5. Expand into visionOS spatial scenes and shared experiences.

## Xcode setup

Create `WCSApps.xcworkspace`, add `Packages/WCSCore`, then create app targets from the folders in `Apps/`. Each app target should depend on the local `WCSCore` Swift package.
