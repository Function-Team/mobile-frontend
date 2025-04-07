# 📱 Function Mobile App

Internal team documentation for the Function mobile application that handles venue booking and management.

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK ^3.29.0
- Dart SDK ^3.7.0
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
  cached_network_image: ^3.3.0
  shared_preferences: ^2.5.2
  http: ^1.3.0
  intl: ^0.20.2
  shimmer: ^3.0.0
  skeletonizer: ^1.4.3
```

## 🏗️ Project Structure

```
lib/
├── common/
│   ├── bindings/
│   ├── routes/           # Routes
│   ├── theme/            # App theming
│   └── widgets/          # Reusable UI widgets
│       ├── buttons/      # Button variants
│       ├── images/       # Images custom widgets
│       ├── inputs/       # Form inputs
│       └── views/        # Widgets preview
├── modules/              # Feature modules
│   ├── auth/             # Authentication
│   ├── booking/          # Booking feature
│   ├── chat/             # Chat feature
│   ├── home/             # Home screen
│   ├── legal/            # Legal pages
│   ├── navigation/       # Navigation
│   ├── profile/          # Profile pages
│   ├── settings/         # Setting pages
│   └── venue/            # Venue pages
└── services/
```

## 🎨 Global UI Components

### Buttons
- `PrimaryButton`: Main CTA button
- `SecondaryButton`: Alternative action button
- `OutlineButton`: Bordered button with optional icon support
- `FavoriteButton`: Favorite button 
- `CustomTextButton`: Custom text button 

### Input Fields
- `NetworkImageWithLoader`: Image with async functionality

### Input Fields
- `AuthTextField`: Authentication inputs with password toggle
- `PrimaryTextField`: Main TextField
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

- [API Documentation](https://github.com/Function-Team/documentations.git)
- [Project Board](https://github.com/orgs/Function-Team/projects/3)
- [ERD](https://lucid.app/lucidchart/eff2f4c7-f952-4583-93c9-6217d1776af8/edit?invitationId=inv_9756da76-4d36-4ea7-91c5-6a37497b87bb&page=0_0#)
- [Figma](https://www.figma.com/files/team/1388007983776109612/project/314675642/Function?fuid=1388007979167327514)

