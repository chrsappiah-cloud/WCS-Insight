# Supabase + CloudKit sync policy

## Source of truth

Supabase is authoritative for:

- auth, accounts, organizations, organization members
- caregiver links and access control
- memory profiles, artifact metadata, session definitions and histories
- reminders, analytics, audit logs
- storage paths and signed URL generation

CloudKit mirrors a private subset for:

- profile summaries
- lightweight artifact metadata
- local session state
- pinned / last-used continuity
- optional thumbnail CKAssets

## Conflict rule

Use last-write-wins for mirrored fields, but only after Supabase confirmation.

1. App writes to Supabase.
2. If Supabase succeeds, app writes mirrored subset to CloudKit with `updatedAt`.
3. On launch/foreground, fetch Supabase updates and reconcile CloudKit.
4. If offline changes exist, queue locally; push to Supabase when online; mirror after confirmation.

CloudKit never becomes the origin of truth for multi-user semantics.

## CloudKit record mapping

`CKPersonProfile`

- `recordID.recordName` = Supabase `person_profiles.id`
- `fullName`
- `preferredName`
- `birthYear`
- `preferredTopics`
- `serverID`
- `updatedAt`

`CKMemoryArtifact`

- `recordID.recordName` = Supabase `memory_artifacts.id`
- `profileRef` → `CKPersonProfile`
- `title`
- `kind`
- `notes`
- `capturedAt`
- `tags`
- `serverID`
- `updatedAt`
- optional `asset`

`CKGuidedSessionLocalState`

- `sessionServerID`
- `profileRef`
- `lastStepIndex`
- `lastRunAt`
- `pinned`
