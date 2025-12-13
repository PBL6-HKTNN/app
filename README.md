# codemy_app

A Flutter application featuring shadcn-inspired UI components and a structured architecture for building modern mobile apps.

## Project Structure

### Documentation (`flutter_shadcn_docs/`)
- `docs/`: General documentation including index, packages, submission guide, and typography.
- `Components/`: Detailed docs for UI components like accordion, alert, avatar, badge, button, calendar, card, checkbox, context-menu, date-picker, dialog, form, icon-button, input-otp, input, menubar, popover, progress, radio-group, resizable, select, separator, sheet, slider, sonner, switch, table, tabs, textarea, time-picker, toast, and tooltip.
- `Theme/`: Theme-related data.
- `Utils/`: Utility docs for decorator and responsive design.

### Source Code (`lib/`)
- `main.dart`: Application entry point.
- `router/`: App routing configuration.
- `src/`: Core application logic.
    - `core/`: Configuration, constants, networks, and utilities.
    - `features/`: Feature modules including auth (with models, providers, screens, and widgets) and example.
    - `presentation/`: UI layer with layouts, providers, screens (home, not found, settings), and widgets.

## Getting Started

1. Ensure Flutter is installed: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install).
2. Clone the repository and navigate to the project directory.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` to start the app on a connected device or emulator.

For more on Flutter development, see the [official documentation](https://docs.flutter.dev/).

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
