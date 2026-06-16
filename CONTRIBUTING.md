# Contributing to A11yContractKit

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Run `swift build` and `swift test`
4. Create a branch from `develop` (see [Branching model](#branching-model))

## Branching model

We use a **Git Flow–style** workflow. Nothing in `CODE_OF_CONDUCT.md` or `SECURITY.md` replaces this — branching rules live here.

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code. Releases and tags (`v*`) only. **No direct pushes.** |
| `develop` | Integration branch. Day-to-day work merges here first. |
| `feat/<short-name>` | New features (branch from `develop`) |
| `fix/<short-name>` | Bug fixes (branch from `develop`) |
| `hotfix/<short-name>` | Urgent fixes on `main` (branch from `main`, merge back to `main` and `develop`) |
| `release/<version>` | Release preparation (optional; branch from `develop`) |

### Typical flow

```text
feat/add-rule-x  ──PR──►  develop  ──PR──►  main  ──tag──►  v1.2.0
```

1. `git checkout develop && git pull`
2. `git checkout -b feat/my-change`
3. Commit, push, open PR **into `develop`**
4. After integration, maintainers merge `develop` → `main` for a release

### Rules

- **Do not push directly to `main`** (use a PR from `develop` or `hotfix/*`)
- Prefer **small, focused PRs** with tests and docs
- Delete feature branches after merge

### Branch protection (maintainers)

Enforcement is configured on **GitHub**, not in this repo’s files. Recommended settings:

**`main`**

- Require a pull request before merging
- Do not allow bypassing the above settings (including admins)
- Optional: require status checks (`swift test`, `mkdocs build`)

**`develop`**

- Require a pull request before merging (recommended)

Enable under: **Repository → Settings → Branches → Branch protection rules**

Or with GitHub CLI (example for `main`):

```bash
gh api repos/{owner}/{repo}/branches/main/protection -X PUT \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

If the `develop` branch does not exist yet, create it from `main` and push:

```bash
git checkout main && git pull
git checkout -b develop && git push -u origin develop
```

## Development

```bash
swift build
swift test
swift build -c release
.build/release/a11y-contract scan --project .
```

For UIKit integration tests, use an iOS Simulator destination:

```bash
xcodebuild test \
  -scheme A11yContractKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -quiet
```

## Documentation

Docs live in `Docs/{en,pt,es}/`. When changing documentation, update all three languages.

Preview locally:

```bash
pip install -r requirements-docs.txt
mkdocs serve
```

Build (same as CI):

```bash
mkdocs build --strict
```

Published at GitHub Pages: `/` (English), `/pt/`, `/es/`.

## Pull Requests

- Target **`develop`** for features and fixes (`feat/*`, `fix/*`)
- Target **`main`** only for `hotfix/*` or release merges (`develop` → `main`)
- Keep changes focused and well-tested
- Update documentation when changing public APIs
- Follow existing code style and module boundaries
- Do not claim automatic WCAG compliance in user-facing text

## Code of Conduct

Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
