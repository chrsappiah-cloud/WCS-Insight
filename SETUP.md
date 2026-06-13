# WCS Insight GitHub setup

This repo is prepared for the WCS Insight iOS Xcode project.

## Push the local Xcode source

From your Mac:

```bash
cd "/Applications/WCS-Insight/WCS-Insight"
git init
git remote add origin git@github.com:chrsappiah-cloud/WCS-Insight.git
git add .
git commit -m "Initial WCS Insight Xcode project"
git branch -M main
git push -u origin main
```

If the remote already exists locally, use:

```bash
git remote set-url origin git@github.com:chrsappiah-cloud/WCS-Insight.git
git push -u origin main
```

## CI/CD

- `CI` builds and tests the app on GitHub Actions.
- `CD` creates an unsigned `.xcarchive` artifact on tags like `v1.0.0` or manual runs.
- Signed App Store/TestFlight export needs Apple signing secrets added later.

Expected Xcode names:

- project or workspace: `WCS-Insight.xcodeproj` / `WCS-Insight.xcworkspace`
- scheme: `WCS-Insight`

If your local scheme name differs, update `SCHEME_NAME` in `.github/workflows/ci.yml` and `.github/workflows/cd.yml`.
