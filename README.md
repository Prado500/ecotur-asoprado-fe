
---
# 🍃 Ecotur-ASOPRADO App - Frontend Architecture (v0.1.1)


![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Clean-4B32C3?style=for-the-badge)
![Mockito](https://img.shields.io/badge/Testing-Mockito-success?style=for-the-badge)

---

##  Project Context (Contexto del Proyecto)



This repository houses the frontend client for **Ecotur-ASOPRADO**. The application is strictly engineered using the **Model-View-ViewModel (MVVM)** architectural pattern combined with **Domain-Driven Design (DDD)** principles, ensuring high UI rendering performance (60 FPS), strict memory leak prevention, and absolute separation of concerns.

###  Sprint 4 Scope:  Architecture Refactoring + Data Governance & Soft Deletion + Entity-Update Operations    (v0.1.1)
This sprint focuses on fully implementing U+D operations (update + soft deletion) for domain model entities User and TouristService, while strengthening data governance, preparing cloud-based storage infrastructure, and researching upcoming transactional integration.

* **Technical Enabler (v0.1.1):**  Resolves technical debt decoupling UI rendering from business logic to prepare the client for upcoming integrations. It includes comprehensive migration to strict MVVM, eradication of the `ApiService` God-Object, isolating network abstractions, and implementing surgical UI repaints via `ListenableBuilder`.

* HU-10 & HU-11: U+D Operations and Data governance. Update operations and  state mutation via soft deletion. Implementation of national ID (Cédula) verification.

* HU-12: Multimedia Cloud Infrastructure. Transitioning from plaintext URL storage to binary file uploads (multipart/form-data) and seamless integration with CDNs/Object Storage.

* Spike (Research): Proof of Concept (POC) for transactional integration and Webhooks processing with Bancolombia's Wompi API.




###  Sprint 1 Scope: Core MVP (v0.1.0)
The baseline release encompassing the Minimum Viable Product:
* **Technical Enabler (v0.1.0) :** Containerization (Docker), cloud infrastructure creation + configuration (Azure), and full deployment under CI/CD automated pipelines to 3 different cloud environments (Develop, Staging and Main).
* **HU-01:** Tourist Registration UI (Form validation and network delegation).
* **HU-02:** User Authentication (JWT interception and App-Wide Session State).
* **HU-03:** Tourist Catalog Visualization (Dynamic Image Carousels and Grid Rendering).
* **HU-08:** Administrative Package Creation (Dynamic form field generation for image URLs).

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
 ┃ ┣ 📂 utils/           # Global helpers (e.g., UIHelpers for SnackBars)
 ┃ ┣ 📂 view_models/     # Presentation State Managers (ChangeNotifier)
 ┃ ┣ 📂 widgets/         # Reusable, modular UI components (Cards, Inputs, Painters)
 ┃ ┗ 📜 main.dart        # Application entry point and Theme configuration
 ┣ 📂 test/              # Automated QA testing suite
 ┃ ┣ 📜 ui_render_test.dart       # Widget rendering tests
 ┃ ┗ 📜 ui_render_test.mocks.dart # Auto-generated Mockito stubs (DO NOT EDIT)
 ┣ 📜 .env.example       # Template for secure environment variables (API URLs)
 ┣ 📜 pubspec.yaml       # Dart package manager and asset declarations
 ┗ 📜 README.md          # Centralized repository documentation
```

---

##  System Overview
A cross-platform reactive application built with Flutter. It utilizes `ChangeNotifier` for localized state management and `SharedPreferences` for secure session persistence, communicating entirely via RESTful JSON payloads.

Core Architectural Features

* **Network Abstraction:** The `ApiClient` implicitly handles dynamic environment URL resolution and automatic JWT injection for authenticated routes, eliminating boilerplate.

* **Dumb Views & Surgical Rendering:** Usage of `ListenableBuilder` nodes prevents costly full-tree repaints (`setState`), selectively mutating only the required pixels (e.g., toggling a loading spinner).

* **Memory Safety:** Strict override of `dispose()` cascades within ViewModels prevents dangling `TextEditingController` memory leaks during fast navigation.

* **Symmetrical Testing:** Complete Mockito integration allowing UI rendering tests to pass in CI/CD pipelines without accessing local storage or executing real network calls.

##  Tech Stack

---

* **Language:** Dart (Null-Safe)

* **Framework:** Flutter (Cross-platform UI Toolkit)

* **Architecture:** MVVM (Model-View-ViewModel)

* **State Management:** Reactive Listenables (ChangeNotifier)

* **Networking:** http package with centralized abstraction

* **QA & Testing:** flutter_test, mockito, build_runner

---

##  Local Setup & Execution
1. Clone the repository

```Code snippet
git clone [https://github.com/Prado500/ecotur-asoprado-frontend](https://github.com/Prado500/ecotur-asoprado-frontend)
cd ecotur-asoprado-frontend/ecotur_app
```
2. Environment Variables

Create a `.env` file in the root directory based on `.env.example`. This file dictates where the ApiClient sends HTTP requests.

```Code snippet
API_URL=http://localhost:8000
```
3. Fetch Dependencies

```Code snippet
flutter pub get
```
4. Generate Testing Mocks (Crucial for QA)

Whenever a Domain Service is added or modified, regenerate the mock stubs to keep the testing suite green:

```Code snippet
flutter pub run build_runner build --delete-conflicting-outputs
```
5. Run the Application

Execute the app on your connected device or emulator:

```Code snippet
flutter run
```
6. Execute the Test Suite

Verify architectural integrity and UI rendering gates:

```Code snippet
flutter test
```