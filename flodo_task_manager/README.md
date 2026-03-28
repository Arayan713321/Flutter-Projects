# Flodo Tasks — Mobile Specialist Performance

> Take-Home Assignment Submission | **Track B: Mobile Specialist**

---

## 📽️ Demo Video
[▶️ Watch 60-second Demo](YOUR_GOOGLE_DRIVE_LINK_HERE)
*Note: View access granted to nilay@flodo.ai*

---

## 🛠️ Setup Instructions

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Isar Database Schema (Crucial step)
dart run build_runner build --delete-conflicting-outputs

# 3. Generate Launcher Icons (Optional)
dart run flutter_launcher_icons

# 4. Run the app
flutter run
```

---

## 🎯 Track Details & Implementation

**Chosen Track: Track B — Mobile Specialist**
- **Architecture**: Riverpod (AsyncNotifier) for robust, testable state management.
- **Local Database**: **Isar** — chosen for its performance, type-safety, and ability to handle complex queries locally.
- **Persistence**: `shared_preferences` used specifically for the **Drafts** feature to ensure zero data loss during interruptions.

### 🧩 Stretch Goals Implemented
1.  **Debounced Search + Inline Highlighting**:
    - Implemented a 300ms timer to prevent database-thrashing during typing.
    - Used `RichText` and `TextSpan` to dynamically bold and highlight matching substrings in the search results.
2.  **Persistent Drag-and-Drop (Reordering)**:
    - Integrated `SliverReorderableList`. The `sortOrder` is persisted to Isar so your custom priority survives app restarts.

---

## 🤖 AI Usage Report

### Prompts that worked best:
- *"Create a Flutter design system in a constants.dart file with a 'Premium Modern' aesthetic, using HSL-based palettes (Indigo/Violet) and 18.0 radius for cards."*
- *"Implement an Isar-based CRUD provider using Riverpod AsyncNotifier that handles a 2-second artificial latency for 'Create' and 'Update' actions."*

### Where AI Got It Wrong (and how I fixed it):
- **Missing Widget Definitions**: During the final Polish phase, the AI scaffolded calls to helper widgets (`_SourceButton` and `_ImageAttachmentPicker`) but failed to generate the actual classes. This resulted in a build failure.
  - **Fix**: I manually identified the missing signatures and implemented the custom widgets with proper `Stack` and `DecoratedBox` implementations.
- **Vulkan Driver Ambiguity**: The AI correctly identified that Recent Flutter (3.32+) uses Impeller/Vulkan on Windows/Android, which sometimes logs errors if the build fails. I had to manually clarify that the "no hot reload" issue was a **compilation error**, not a driver issue.

---

## ✅ Requirements Checklist

| Feature | Status |
|---|---|
| Task Model (Title, Desc, Date, Status, BlockedBy) | ✅ Complete |
| Visual "Blocked" State Logic | ✅ Complete |
| Full CRUD (Create, Read, Update, Delete) | ✅ Complete |
| Persistent Drafts (Survives app restart) | ✅ Complete |
| Status-based Filtering | ✅ Complete |
| 2-Second Save Latency + Loading States | ✅ Complete |
| **Stretch**: Debounced Search + Highlighting | ✅ Complete |
| **Stretch**: Persistent Drag-and-Drop Reordering | ✅ Complete |

---

## 💡 Technical Decision Highlight
I'm particularly proud of the **Cascading Block Logic**. In the `TaskProvider`, when a task is deleted, the app automatically scans for any other tasks that were "Blocked By" it and clears those dependencies. This prevents the database from entering an orphaned state where a task remains "Greyed Out" forever because its blocker no longer exists.
