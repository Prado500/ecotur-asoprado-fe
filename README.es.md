
---
#  Ecotur-ASOPRADO App - Arquitectura Frontend (v0.2.0)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Clean-4B32C3?style=for-the-badge)
![Mockito](https://img.shields.io/badge/Testing-Mockito-success?style=for-the-badge)

---

##  Contexto del Proyecto

Este repositorio aloja el cliente frontend para **Ecotur-ASOPRADO**. La aplicación está estrictamente diseñada utilizando el patrón arquitectónico **Model-View-ViewModel (MVVM)** combinado con principios de **Domain-Driven Design (DDD)**, garantizando un alto rendimiento de renderizado en la interfaz de usuario (60 FPS), prevención estricta de fugas de memoria y absoluta separación de responsabilidades.

###  Alcance del Sprint 4: Arquitectura Empresarial, Cloud CDN y Gobernanza de Datos (v0.2.0)
Este *release* mayor marca la transición desde el MVP base hacia una aplicación web y móvil robusta y de grado empresarial. Introduce el manejo nativo de binarios, paradigmas avanzados de gestión de estado y fronteras estrictas de validación de datos.

* **Asynchronous Media Staging & Eager Uploading (HU-12):** Se erradicó la "Subida Perezosa" (*Lazy Uploading*) heredada. La UI ahora delega inherentemente los fragmentos binarios (`multipart/form-data`) al CDN de Azure en el momento exacto en que son seleccionados. Esto unifica los flujos de creación y edición de paquetes en torno a un único arreglo declarativo de URLs del CDN, desbloqueando capacidades interactivas de Drag & Drop (`ReorderableListView`).
* **Mapeo Efímero de Metadatos en RAM:** Se diseñó un diccionario de mapeo en memoria dentro del ViewModel para retener los nombres de los archivos locales originales para mayor claridad en la UX. Esto satisface los requisitos administrativos sin contaminar los estrictos contratos de persistencia JSON del backend.
* **Gobernanza de Datos y UI de Auditoría (HU-11):** Se construyó una interfaz paginada altamente optimizada con *scroll* infinito (`AuditLogScreen`) para visualizar mutaciones administrativas. Cuenta con capacidades de inspección forense a través de un *overlay* nativo `BottomSheet` que renderiza los *payloads* delta de JSONB con un formato estructurado y amigable.
* **Onboarding Zero-Trust y Validación Fail-Fast (HU-10):** Las validaciones de formularios en el cliente se sincronizaron para reflejar simétricamente los estrictos esquemas Pydantic del backend (ej. Regex para Cédulas de Ciudadanía y estándares de telefonía colombiana). Incluye un formulario bimodal de aprovisionamiento de usuarios que renderiza dinámicamente opciones de Control de Acceso Basado en Roles (RBAC) exclusivamente para Superadministradores.
* **UX Acelerada por Hardware:** Se implementaron componentes `HoverZoomWrapper` descargando las animaciones directamente a la GPU, apuntando a transformaciones de escala fluidas a 60 FPS para interacciones web/escritorio sin desencadenar costosos bucles `setState` en el hilo principal.

###  Hitos Anteriores: MVP Base y Refactorización (v0.1.0 - v0.1.1)
* **Habilitadores Técnicos:** Erradicación del "God-Object" `ApiService`, aislando las abstracciones de red (`ApiClient`) e implementando repintados quirúrgicos de la UI a través de `ListenableBuilder`. Contenerización (Docker), aprovisionamiento en Azure y pipelines CI/CD.
* **Funcionalidad Core:** Autenticación de usuarios (Estado de sesión JWT a nivel global), visualización del catálogo turístico y enrutamiento dinámico de formularios.

---

##  Estructura de Directorios (MVVM & DDD)

El código base segrega estrictamente las responsabilidades a través de capas, asegurando que los componentes de la UI se mantengan como "vistas tontas" (*dumb views*) y la lógica de negocio siga siendo altamente testeable:

```text
📦 ECOTUR-ASOPRADO-FRONTEND
 ┣ 📂 lib/               # Código fuente principal de la aplicación
 ┃ ┣ 📂 abstractions/    # Infraestructura de bajo nivel (ej. ApiClient, Interceptors)
 ┃ ┣ 📂 models/          # Objetos de Transferencia de Datos (DTOs) y Entidades de Dominio
 ┃ ┣ 📂 screens/         # "Vistas Tontas" - Estrictamente pintado de UI y observación de estado
 ┃ ┣ 📂 services/        # Servicios de Dominio (Sin estado) y Estado Global de la App (Sesión)
 ┃ ┣ 📂 utils/           # Helpers globales (ej. UIHelpers, CurrencyFormatters)
 ┃ ┣ 📂 view_models/     # Gestores de Estado de Presentación (ChangeNotifier)
 ┃ ┣ 📂 widgets/         # Componentes de UI modulares y reutilizables (Admin, Catalog, Common)
 ┃ ┗ 📜 main.dart        # Punto de entrada de la aplicación y configuración del Tema
 ┣ 📂 test/              # Suite de pruebas automatizadas QA
 ┃ ┣ 📜 admin_create_package_viewmodel_test.dart  # Pruebas de lógica e hidratación de estado
 ┃ ┣ 📜 ui_render_test.dart                       # Pruebas de renderizado de widgets y RBAC
 ┃ ┗ 📜 ui_render_test.mocks.dart                 # Stubs autogenerados por Mockito
 ┣ 📜 .env.example       # Plantilla para variables de entorno seguras (URLs de API)
 ┣ 📜 pubspec.yaml       # Gestor de paquetes de Dart y declaración de assets
 ┗ 📜 README.md          # Documentación centralizada del repositorio

```

---

##  Resumen del Sistema

Una aplicación reactiva multiplataforma construida con Flutter. Utiliza `ChangeNotifier` para la gestión de estado localizada y `SharedPreferences` para la persistencia segura de sesiones, comunicándose íntegramente mediante *payloads* JSON RESTful y flujos `multipart/form-data`.

**Características Arquitectónicas Principales:**

* **Abstracción de Red:** El `ApiClient` maneja implícitamente la resolución dinámica de la URL del entorno y la inyección automática del JWT para rutas autenticadas. Incorpora un analizador de errores (*parser*) de doble capa que intercepta inteligentemente tanto excepciones HTTP estándar como errores de validación personalizados de Pydantic.
* **Vistas Tontas y Renderizado Quirúrgico:** El uso de nodos `ListenableBuilder` evita los costosos repintados del árbol completo (`setState`), mutando selectivamente solo los píxeles necesarios (ej. alternar un *spinner* de carga o hidratar una columna Kanban).
* **Seguridad de Memoria:** La sobreescritura estricta del método `dispose()` en cascada dentro de los ViewModels previene fugas de memoria causadas por `TextEditingController` huérfanos durante la navegación rápida.
* **Pruebas Simétricas:** Integración completa con Mockito, lo que permite que las pruebas de renderizado de UI y las compuertas lógicas se ejecuten exitosamente en los pipelines CI/CD sin necesidad de acceder al almacenamiento local ni ejecutar llamadas reales de red en la nube.

---

##  Stack Tecnológico

* **Lenguaje:** Dart (Null-Safe)
* **Framework:** Flutter (Toolkit UI Multiplataforma)
* **Arquitectura:** MVVM (Model-View-ViewModel) + Clean Architecture
* **Gestión de Estado:** Listenables Reactivos (ChangeNotifier)
* **Redes (Networking):** paquete `http` con abstracción centralizada + `cross_file`
* **QA & Testing:** `flutter_test`, `mockito`, `build_runner`

---

##  Instalación y Ejecución Local

**1. Clonar el repositorio**

```bash
git clone [https://github.com/Prado500/ecotur-asoprado-frontend](https://github.com/Prado500/ecotur-asoprado-frontend)
cd ecotur-asoprado-frontend/ecotur_app

```

**2. Variables de Entorno**
Cree un archivo `.env` en el directorio raíz basándose en `.env.example`. Este archivo dicta a dónde envía el ApiClient las peticiones HTTP.

```env
API_URL=http://localhost:8000

```

**3. Obtener Dependencias**

```bash
flutter pub get

```

**4. Generar Mocks de Pruebas (Crucial para QA)**
Siempre que se añada o modifique un Servicio de Dominio, regenere los stubs mockeados para mantener la suite de pruebas sincronizada y en verde:

```bash
flutter pub run build_runner build --delete-conflicting-outputs

```

**5. Ejecutar la Aplicación**
Ejecute la app en su dispositivo conectado, emulador o navegador web:

```bash
flutter run

```

**6. Ejecutar la Suite de Pruebas**
Verifique la integridad arquitectónica, las compuertas de renderizado de UI y las operaciones de gestión de estado:

```bash
flutter test

```

