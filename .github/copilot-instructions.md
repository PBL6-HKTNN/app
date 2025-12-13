# Copilot Instructions for codemy_app

## Project Overview

This is a Flutter application named `codemy_app`, built with Flutter SDK ^3.8.1. It uses state management with `flutter_riverpod`, routing with `go_router`, UI components from `shadcn_flutter`, and Google Sign-In for authentication.

## Code Structure

- **lib/**: Main application code.
  - **core/**: Core utilities, configurations, networks, and constants.
  - **features/**: Feature-specific modules (e.g., auth with models, providers, screens, widgets).
  - **presentation/**: UI-related code, including layouts, screens, and widgets.
- Follow the modular structure with index.dart files for exports.
- Use Riverpod for state management.
- Implement routing with GoRouter.

## Dependencies and Usage

- **shadcn_flutter**: Use for UI components like buttons, cards, dialogs, etc. Refer to `flutter_shadcn_docs` for component documentation.
- **google_sign_in**: For authentication flows.
- **go_router**: For navigation; define routes in `router/app_router.dart`.
- **flutter_riverpod**: Use providers for state management in features.

## Coding Guidelines

- Write clean, modular Dart code.
- Use Flutter best practices: stateless widgets where possible, proper key usage.
- Handle exceptions via `core/networks/exception.dart`.
- Log using `core/utils/logger.dart`.
- For auth, follow the structure in `features/auth/`.
- Ensure responsive design using utilities from `shadcn_flutter`.
- Avoid hardcoded strings; use constants from `core/constants/`.

## File Naming and Organization

- Use snake_case for file names (e.g., `login_screen.dart`).
- Export modules via index.dart files.
- Place new features under `features/` with subfolders for models, providers, screens, widgets.

## Testing and Linting

- Use `flutter_lints` for code quality.
- Write tests in `test/` directory if needed.

## Additional Notes

- Refer to `pubspec.yaml` for dependencies.
- Consult `flutter_shadcn_docs` for component usage examples.
- Keep code DRY and maintainable.
