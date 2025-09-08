# app

A new Flutter project.

## Structure overview (scalable)

Feature-first with a core layer:

- `lib/app/core/`
	- `constants/` brand colors and typography
	- `network/` endpoints and ApiClient
	- `theme/` AppTheme (light/dark)
- `lib/app/<feature>/` each feature has `controllers/`, `models/`, `views/`, `widgets/`
- `lib/app/routes/` navigation setup

Backward compatibility: legacy `app/constants/*` re-export the new core constants to avoid breaking imports while you gradually migrate feature code to `app/core/*` imports.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
