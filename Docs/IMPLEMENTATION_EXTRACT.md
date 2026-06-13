# Extracted implementation instructions

Source: Google Doc `pdf_download_6352BE58-76D5-4530-9DDD-CC93E0CB197C`.

## Product portfolio

Build three Apple-native WCS apps as one coordinated product family:

1. **Memory Atlas** — therapeutic reminiscence app for people living with dementia, families, carers, and clinicians. First launch target: iPhone/iPad. Later premium layer: Vision Pro spatial scenes and guided memory rooms.
2. **ScholarSphere Studio** — iPad-first creator and publishing platform for immersive education, therapy modules, spatial scenes, videos, quizzes, and analytics.
3. **Presence Play** — visionOS-first shared spatial storytelling and therapeutic co-experience app, with iPhone/iPad companion surfaces.

## Shared architecture

Use a modular SwiftUI architecture:

- Presentation: SwiftUI views, navigation, widgets, Live Activities, visionOS surfaces.
- Domain: profiles, artifacts, sessions, lessons, narrative scenes, participants.
- Data: Supabase, CloudKit, local cache, file storage.
- Services: AVFoundation, Speech, RealityKit, WidgetKit, ActivityKit, UserNotifications, SharePlay-ready collaboration boundaries.

## Backend strategy

- Supabase is the system of record for multi-user collaboration, role management, analytics, publishing, reminders, and audit logs.
- Supabase Storage holds originals and thumbnails in a private `memory-artifacts` bucket, accessed through signed upload/download URLs.
- CloudKit mirrors a carefully selected private subset for Apple-native continuity and fast startup.
- Supabase remains authoritative; CloudKit acts as cache and personal mirror.

## Immediate build target

Start with:

1. `WCSCore` Swift package.
2. `MemoryAtlas` iPhone/iPad app shell.
3. Widget + Live Activity extension boundary.
4. CloudKit backup/sync boundary.
5. visionOS spatial expansion boundary.

## Key implementation rules

- Keep RealityKit isolated behind a spatial feature boundary.
- Keep APMP / immersive export support behind a media export service boundary.
- For offline sync, use Supabase-first writes; only mirror to CloudKit after Supabase confirms the write.
- Use versioned REST endpoints with `X-App-Version` and `X-App-Platform` headers.
- Use private media storage and signed URLs for sensitive memory artifacts.
