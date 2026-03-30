## 🏗️ Design System & UX
This submission prioritizes **high-fidelity aesthetics** and **smooth performance**, as expected for Track B.
- **Premium Modern UI**: Custom design system using HSL-based palettes (Indigo/Violet), glassmorphism-inspired inputs, and translucency.
- **High-Fidelity Interaction**: Replaced native dialogs with **Searchable Bottom Sheets** and premium confirmation patterns.
- **Micro-Animations**: Staggered list entrance animations, FAB scale effects, and animated count-up statistics.
- **Informative Empty States**: Purpose-built illustrations and guidance for empty lists and search.
- **Consistency**: Centralized `AppColors`, `AppTextStyles`, and `AppDimens` tokens in `lib/utils/constants.dart`.

---

## 📽️ 1-Minute Demo
[▶️ Watch Demo Video](YOUR_GOOGLE_DRIVE_LINK_HERE)
> *View access granted to nilay@flodo.ai*

---

## 🧩 Stretch Goals Implemented
I chose to implement **two** stretch goals to demonstrate advanced state management and persistence skills:

### 1. Debounced Search + Inline Highlighting
- **Debounce**: 300ms delay after the user stops typing (using `dart:async` Timer) to prevent redundant queries.
- **Highlighting**: Uses `RichText` and `TextSpan` to dynamically bold and color matching substrings in the search results.

### 2. Persistent Drag-and-Drop (Priority Reordering)
- Integrated `SliverReorderableList`. The `sortOrder` is persisted to **Isar** within a background transaction, ensuring the custom priority survives app restarts.

---

## 🛠️ Tech Stack
- **Framework**: Flutter 3.x (Track B Mobile Specialist)
- **State Management**: **Riverpod (AsyncNotifier)** for clean separation of concerns and robust async handling.
- **Database**: **Isar** — high-performance, type-safe local NoSQL database.
- **Local Persistence**: `shared_preferences` used specifically for **Drafts** to ensure zero data loss.
- **Code Generation**: `build_runner` for Isar schema generation.

---

## ⚙️ Setup Instructions
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Isar models (creates task.g.dart)
dart run build_runner build --delete-conflicting-outputs

# 3. Run the application
flutter run
```

---

## 🤖 AI Usage Report

### Prompts that worked best
- *"Create a Flutter design system in constants.dart with a 'Premium Modern' aesthetic, using HSL-based palettes and 18.0 radius for cards."*
- *"Implement an Isar-based CRUD provider using Riverpod AsyncNotifier that handles a 2-second artificial latency with loading states."*

### Where the AI got it wrong
- **NDK Version Mismatch**: The AI originally specified NDK `27.0.x` in the Gradle config, which resulted in a permanent build hang on the target device environment.
  - **Fix**: I manually downgraded the `ndkVersion` to `26.1.10909125` to ensure environment compatibility.
- **Missing Widget Signatures**: During a UI refactor, the AI scaffolded `_StatCard` and `_FilterRow` calls but failed to generate the trailing class definitions.
  - **Fix**: I identified the missing widgets and implemented them using custom `AnimatedContainer` and `TweenAnimationBuilder` logic.

### Technical Decision I'm Proud Of
**Cascading Dependency Cleanup**: When a task is deleted, the app automatically identifies all downstream tasks that were "blocked" by it and clears their `blockedById` fields within the same Isar transaction. This prevents "orphan" block states and maintains referential integrity in a schema-less local DB.

---

## ✅ Requirements Checklist
- [x] Task model with 5+ fields
- [x] Full CRUD operations (Isar)
- [x] Persistent Drafts (SharedPreferences)
- [x] Blocked logic (Visual 🔒 indicators)
- [x] 2-second simulated delay + Loading states
- [x] Search (Debounced + Highlighting)
- [x] Persistent Reordering (Drag-and-Drop)
- [x] Responsive Premium UI/UX
- [x] README + AI Report + Demo Setup

