# Contributing to A11yContractKit

Thank you for your interest in contributing!

## Getting Started

1. Fork the repository
2. Clone your fork
3. Run `swift build` and `swift test`
4. Create a feature branch

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

- Keep changes focused and well-tested
- Update documentation when changing public APIs
- Follow existing code style and module boundaries
- Do not claim automatic WCAG compliance in user-facing text

## Code of Conduct

Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
