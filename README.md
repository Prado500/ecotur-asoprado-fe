
#  Ecotur-ASOPRADO App - Frontend Architecture (v0.2.0)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Clean-4B32C3?style=for-the-badge)
![Mockito](https://img.shields.io/badge/Testing-Mockito-success?style=for-the-badge)

---

##  Project Context

This repository houses the frontend client for **Ecotur-ASOPRADO**. The application is strictly engineered using the **Model-View-ViewModel (MVVM)** architectural pattern combined with **Domain-Driven Design (DDD)** principles, ensuring high UI rendering performance (60 FPS), strict memory leak prevention, and absolute separation of concerns.

###  Sprint 4 Scope: Enterprise Architecture, Cloud CDN & Data Governance (v0.2.0)
This major release marks the transition from the base MVP to a robust, enterprise-grade mobile and web application. It introduces native binary handling, advanced state management paradigms, and strict data validation boundaries.

* **Asynchronous Media Staging & Eager Uploading (HU-12):** Eradicated legacy "Lazy Uploading". The UI now inherently delegates binary chunks (`multipart/form-data`) to the Azure CDN the exact moment they are selected. This unifies package creation and edition workflows around a single declarative array of CDN URLs, unlocking interactive Drag & Drop (`ReorderableListView`) capabilities.
* **Ephemeral RAM Metadata Mapping:** Engineered an in-memory dictionary mapping within the ViewModel to retain original local file names for UX clarity. This satisfies administrative requirements without contaminating the backend's strict JSON persistence contracts.
* **Data Governance & Audit Trail UI (HU-11):** Engineered a highly optimized, infinite-scrolling paginated interface (`AuditLogScreen`) to visualize administrative mutations. It features forensic inspection capabilities via a native BottomSheet overlay rendering pretty-printed JSONB delta payloads.
* **Zero-Trust Onboarding & Fail-Fast Validation (HU-10):** Synchronized client-side form validations to symmetrically mirror the strict backend Pydantic schemas (e.g., Regex for National IDs and Colombian phone standards). Includes a bimodal user provisioning form dynamically rendering Role-Based Access Control (RBAC) options exclusively for Superadmins.
* **Hardware-Accelerated UX:** Implemented `HoverZoomWrapper` components offloading animations directly to the GPU, aiming for fluid, 60 FPS scale transformations for web/desktop interactions without triggering expensive main-thread `setState` loops.

###  Previous Milestones: Core MVP & Refactoring (v0.1.0 - v0.1.1)
* **Technical Enablers:** Eradication of the `ApiService` God-Object, isolating network abstractions (`ApiClient`), and implementing surgical UI repaints via `ListenableBuilder`. Containerization (Docker), Azure provisioning, and CI/CD pipelines.
* **Core Functionality:** User Authentication (JWT App-Wide Session State), Tourist Catalog Visualization, and dynamic form routing.

---

##  Directory Structure (MVVM & DDD)

The codebase strictly segregates responsibilities across layers, ensuring UI components remain "dumb" and business logic remains highly testable:

```text
📦 ECOTUR-ASOPRADO-FRONTEND
 ┣ 📂 lib/               # Main application source code
 ┃ ┣ 📂 abstractions/    # Low-level infrastructure (e.g., ApiClient, Interceptors)
 ┃ ┣ 📂 models/          # Data Transfer Objects (DTOs) and Domain Entities
 ┃ ┣ 📂 screens/         # "Dumb Views" - Strictly UI painting and state observation
 ┃ ┣ 📂 services/        # Domain Services (Stateless) & App-Wide State (Session)
 ┃ ┣ 📂 utils/           # Global helpers (e.g., UIHelpers, CurrencyFormatters)
 ┃ ┣ 📂 view_models/     # Presentation State Managers (ChangeNotifier)
 ┃ ┣ 📂 widgets/         # Reusable, modular UI components (Admin, Catalog, Common)
 ┃ ┗ 📜 main.dart        # Application entry point and Theme configuration
 ┣ 📂 test/              # Automated QA testing suite
 ┃ ┣ 📜 admin_create_package_viewmodel_test.dart  # State hydration & logic testing
 ┃ ┣ 📜 ui_render_test.dart                       # Widget rendering & RBAC testing
 ┃ ┗ 📜 ui_render_test.mocks.dart                 # Auto-generated Mockito stubs
 ┣ 📜 .env.example       # Template for secure environment variables (API URLs)
 ┣ 📜 pubspec.yaml       # Dart package manager and asset declarations
 ┗ 📜 README.md          # Centralized repository documentation

```

---

##  System Overview

A cross-platform reactive application built with Flutter. It utilizes `ChangeNotifier` for localized state management and `SharedPreferences` for secure session persistence, communicating entirely via RESTful JSON payloads and `multipart/form-data` streams.

**Core Architectural Features:**

* **Network Abstraction:** The `ApiClient` implicitly handles dynamic environment URL resolution and automatic JWT injection for authenticated routes. It incorporates a dual-layer error parser intelligently intercepting both standard HTTP Exceptions and custom Pydantic Validation errors.
* **Dumb Views & Surgical Rendering:** Usage of `ListenableBuilder` nodes prevents costly full-tree repaints (`setState`), selectively mutating only the required pixels (e.g., toggling a loading spinner or hydrating a Kanban column).
* **Memory Safety:** Strict override of `dispose()` cascades within ViewModels prevents dangling `TextEditingController` memory leaks during fast navigation.
* **Symmetrical Testing:** Complete Mockito integration allowing UI rendering tests and logic gates to pass in CI/CD pipelines without accessing local storage or executing real cloud network calls.

---

##  Tech Stack

* **Language:** Dart (Null-Safe)
* **Framework:** Flutter (Cross-platform UI Toolkit)
* **Architecture:** MVVM (Model-View-ViewModel) + Clean Architecture
* **State Management:** Reactive Listenables (ChangeNotifier)
* **Networking:** `http` package with centralized abstraction + `cross_file`
* **QA & Testing:** `flutter_test`, `mockito`, `build_runner`

---

##  Local Setup & Execution

**1. Clone the repository**

```bash
git clone [https://github.com/Prado500/ecotur-asoprado-frontend](https://github.com/Prado500/ecotur-asoprado-frontend)
cd ecotur-asoprado-frontend/ecotur_app

```

**2. Environment Variables**
Create a `.env` file in the root directory based on `.env.example`. This file dictates where the ApiClient routes HTTP requests.

```env
API_URL=http://localhost:8000

```

**3. Fetch Dependencies**

```bash
flutter pub get

```

**4. Generate Testing Mocks (Crucial for QA)**
Whenever a Domain Service is added or modified, regenerate the mock stubs to keep the testing suite synchronized and green:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

```

**5. Run the Application**
Execute the app on your connected device, emulator, or web browser:

```bash
flutter run

```

**6. Execute the Test Suite**
Verify architectural integrity, UI rendering gates, and state management operations:

```bash
flutter test

```



