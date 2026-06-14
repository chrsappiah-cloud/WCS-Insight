# Memory Atlas API contract v1

Base URL example: `https://api.myworldclass.org/api/v1`

Common headers:

```http
Authorization: Bearer <supabase_access_token>
X-App-Version: 1.0.0
X-App-Platform: ios
Accept: application/json
Content-Type: application/json
```

Error envelope:

```json
{
  "error": {
    "code": "not_found",
    "message": "Profile not found"
  }
}
```

## Profiles

- `GET /profiles`
- `POST /profiles`
- `GET /profiles/{profile_id}`
- `PATCH /profiles/{profile_id}`
- `DELETE /profiles/{profile_id}`

Create/update body:

```json
{
  "full_name": "John Doe",
  "preferred_name": "Dad",
  "birth_year": 1942,
  "primary_language": "en"
}
```

## Memory artifacts

- `GET /profiles/{profile_id}/artifacts?kind=photo&tag=family`
- `POST /profiles/{profile_id}/artifacts`
- `GET /artifacts/{artifact_id}`
- `PATCH /artifacts/{artifact_id}`
- `DELETE /artifacts/{artifact_id}`
- `GET /artifacts/{artifact_id}/prompts`
- `POST /artifacts/{artifact_id}/prompts`

Artifact body:

```json
{
  "title": "Wedding Day",
  "kind": "photo",
  "description": "At the church",
  "source_url": "storage/path/or/url",
  "thumbnail_url": "storage/path/or/url",
  "captured_at": "2022-05-01T02:00:00Z",
  "tags": ["wedding", "family"]
}
```

## Guided sessions

- `GET /profiles/{profile_id}/sessions`
- `POST /profiles/{profile_id}/sessions`
- `GET /sessions/{session_id}`
- `PUT /sessions/{session_id}/steps`

## Session runs

- `POST /sessions/{session_id}/runs`
- `PATCH /session-runs/{run_id}`
- `POST /session-runs/{run_id}/events`
- `GET /profiles/{profile_id}/session-runs`

## Reminders

- `GET /profiles/{profile_id}/reminders`
- `POST /profiles/{profile_id}/reminders`

## Media upload

The app should not upload arbitrary paths directly. Use:

- `POST /media/upload-url`

Typical response:

```json
{
  "artifact_id": "uuid",
  "upload_url": "signed-put-url",
  "thumb_upload_url": "signed-put-url",
  "source_path": "memory-artifacts/account/profile/artifact/original",
  "thumbnail_path": "memory-artifacts/account/profile/artifact/thumb"
}
```
