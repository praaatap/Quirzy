# Project Structure & Contribution Guidelines

## 📂 Project Structure

The project follows a **Feature-First Architecture**, ensuring modularity, scalability, and ease of maintenance.

### Root Directory
- **`lib/`**: Main source code.
- **`assets/`**: Images, icons, and configuration files.
- **`test/`**: Unit/Widget tests.

### Source Code (`lib/`)

The `lib` folder is organized as follows:

```
lib/
├── config/             # App-wide configuration (Env, Themes, API endpoints)
├── core/               # Shared logic, widgets, and utilities used across the app
│   ├── constants/      # App constants
│   ├── services/       # Core services (Storage, API clients)
│   ├── theme/          # App theme definitions
│   ├── utils/          # Helper functions
│   └── widgets/        # Reusable global widgets
├── features/           # Feature-specific code (The core of the app)
│   ├── auth/           # Authentication (Login, Signup)
│   ├── home/           # Home screen and dashboard
│   ├── quiz/           # Quiz logic and UI
│   ├── flashcards/     # Flashcards feature
│   ├── history/        # Quiz history
│   ├── profile/        # User profile
│   └── settings/       # App settings
├── di/                 # Dependency Injection setup
├── models/             # Shared data models
├── providers/          # Global Riverpod providers
├── routes/             # App navigation routing (GoRouter)
├── app.dart            # Helper for App entry point (MaterialApp)
└── main.dart           # App entry point
```

## 🤝 Contribution Guidelines

We welcome contributions! Please follow these steps to ensure smooth collaboration.

### 🚀 Getting Started
1. **Clone the repository**:
   ```bash
   git clone <repo-url>
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

### 🛠 Development Workflow
1. **Branching**:
   - Create a new branch for each feature or bug fix.
   - Naming convention: `feature/your-feature-name` or `fix/bug-description`.
   - Example: `feature/dark-mode` or `fix/login-error`.

2. **Coding Standards**:
   - Follow **Dart Analysis** rules. Ensure no warnings or errors exist.
   - Use **Riverpod** for state management.
   - Keep widgets small and reusable.
   - Place feature-specific logic inside `lib/features/<feature_name>`.

3. **Commit Messages**:
   - Use strict conventional commits:
     - `feat: Add new quiz mode`
     - `fix: Resolve crash on startup`
     - `docs: Update project structure`
     - `refactor: Optimize image loading`

4. **Pull Requests (PR)**:
   - Push your branch: `git push origin feature/your-feature-name`.
   - Open a PR to the `main` branch.
   - Provide a clear description of changes.

### 🧪 Testing
- Run tests before pushing:
  ```bash
  flutter test
  ```
- Ensure new features have accompanying tests.

---
**Happy Coding! 🚀**
