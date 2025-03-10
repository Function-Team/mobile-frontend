# 📱 Function Mobile App

Internal team documentation for the Function mobile application that handles venue booking and management.

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK ^3.6.1
- Dart SDK ^3.6.1
- Android Studio / VS Code
- Git
- FVM (its optional but u need it to manage flutter version)

### Dependencies
```yaml
dependencies:
  flutter_sdk: ^3.6.1
  badges: ^3.1.2
  flutter_rating_bar: ^4.0.1
  get: ^4.7.2
  shared_preferences: ^2.5.2
  font_awesome_flutter: ^10.8.0
```

## 🏗️ Project Structure

```
lib/
├── components/          # Reusable UI components
│   ├── buttons/        # Button variants
│   ├── cards/         # Card components
│   ├── inputs/        # Form inputs
│   └── views/         # Component previews
├── modules/            # Feature modules
│   ├── auth/          # Authentication
│   ├── home/          # Home screen
│   └── legal/         # Legal pages
├── routes/            # Navigation
└── theme/             # App theming
```

## 🎨 UI Components

### Buttons
- `PrimaryButton`: Main CTA button
- `SecondaryButton`: Alternative action button
- `OutlineButton`: Bordered button with optional icon support

### Input Fields
- `AuthTextField`: Authentication inputs with password toggle
- `SearchTextField`: Search input with icon

## 📱 Features

### Authentication Module
- Email/Password login & registration
- Password visibility toggle
- Form validation
- Session management using `shared_preferences`
- Google Sign-in (planned)

### Home Module
- Venue listing
- Search functionality
- Booking management
- User reviews & ratings

## 🔧 Development Guidelines

### State Management
- Using GetX for state management
- Controllers handle business logic
- Services manage API communication
- Models define data structures

### Code Style
- Follow Flutter's style guide
- Use meaningful variable names
- Comment complex logic
- Keep files focused and single-responsibility

### Git Workflow
1. Create feature branch from `develop`
2. Follow commit message convention:
   - feat: New feature
   - fix: Bug fix
   - docs: Documentation
   - style: Formatting
   - refactor: Code restructure
3. Submit PR for review

## 🚀 Running the Project

1. Clone and install dependencies:
```bash
git clone <repository-url>
cd function-mobile
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## 🔍 Testing

```bash
flutter test
```

## 📝 Team Contacts

- Project Manager, UI UX Designer: [Royyan AZ](mailto:kasehitoworks@gmail.com)

## 🔗 Additional Resources

- [API Documentation](link-to-api-docs)
- [Design System](link-to-design-system)
- [Project Board](link-to-project-board)
