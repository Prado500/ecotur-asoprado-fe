---

# 🍃 Ecotur-ASOPRADO App - Arquitectura Frontend (v0.1.1)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![MVVM](https://img.shields.io/badge/Architecture-MVVM%20%7C%20Clean-4B32C3?style=for-the-badge)
![Mockito](https://img.shields.io/badge/Testing-Mockito-success?style=for-the-badge)

---

## Contexto del Proyecto

Este repositorio aloja el cliente frontend para **Ecotur-ASOPRADO**. La aplicación está estrictamente diseñada utilizando el patrón arquitectónico **Model-View-ViewModel (MVVM)** combinado con principios de **Domain-Driven Design (DDD)**, garantizando un alto rendimiento de renderizado en la interfaz de usuario (60 FPS), prevención estricta de fugas de memoria y absoluta separación de responsabilidades (*separation of concerns*).

### Alcance del Sprint 4: Refactorización Arquitectónica + Gobernanza de Datos y Borrado Lógico + Operaciones de Actualización de Entidades (v0.1.1)

Este sprint se enfoca en implementar completamente las operaciones U+D (actualización + borrado lógico) para las entidades del modelo de dominio User y TouristService, a la vez que fortalece la gobernanza de datos, prepara la infraestructura de almacenamiento en la nube e investiga la próxima integración transaccional.

* **Habilitador Técnico (v0.1.1):** Resuelve la deuda técnica desacoplando el renderizado de la UI de la lógica de negocio para preparar el cliente para futuras integraciones. Incluye una migración exhaustiva a un MVVM estricto, la erradicación del "God-Object" `ApiService`, el aislamiento de las abstracciones de red y la implementación de repintados quirúrgicos en la UI mediante `ListenableBuilder`.
* HU-10 & HU-11: Operaciones U+D y Gobernanza de Datos. Operaciones de actualización y mutación de estados mediante borrado lógico. Implementación de verificación de identidad (Cédula).
* HU-12: Infraestructura Cloud Multimedia. Transición del almacenamiento de URLs en texto plano a la subida de archivos binarios (multipart/form-data) y la integración perfecta con CDNs/Object Storage.
* Spike (Investigación): Prueba de Concepto (POC) para la integración transaccional y el procesamiento de Webhooks con la API Wompi de Bancolombia.

### Alcance del Sprint 1: MVP Base (v0.1.0)

El lanzamiento base que abarca el Producto Mínimo Viable:

* **Habilitador Técnico (v0.1.0):** Contenerización (Docker), creación y configuración de infraestructura en la nube (Azure), y despliegue completo bajo pipelines automatizados de CI/CD en 3 entornos de nube diferentes (Develop, Staging y Main).
* **HU-01:** UI de Registro de Turistas (Validación de formularios y delegación de red).
* **HU-02:** Autenticación de Usuarios (Intercepción de JWT y Estado de Sesión Global de la App).
* **HU-03:** Visualización del Catálogo de Turistas (Carruseles de imágenes dinámicos y renderizado en grilla).
* **HU-08:** Creación Administrativa de Paquetes (Generación dinámica de campos de formulario para URLs de imágenes).

---

## Estructura de Directorios (MVVM & DDD)

El código base segrega estrictamente las responsabilidades a través de capas, asegurando que los componentes de la UI se mantengan "tontos" (*dumb views*) y la lógica de negocio siga siendo altamente testeable:

```text
📦 ECOTUR-ASOPRADO-FRONTEND
 ┣ 📂 lib/               # Código fuente principal de la aplicación
 ┃ ┣ 📂 abstractions/    # Infraestructura de bajo nivel (ej. ApiClient, Interceptors)
 ┃ ┣ 📂 models/          # Objetos de Transferencia de Datos (DTOs) y Entidades de Dominio
 ┃ ┣ 📂 screens/         # "Vistas Tontas" - Estrictamente pintado de UI y observación de estado
 ┃ ┣ 📂 services/        # Servicios de Dominio (Sin estado) y Estado Global de la App (Sesión)
 ┃ ┣ 📂 utils/           # Helpers globales (ej. UIHelpers para SnackBars)
 ┃ ┣ 📂 view_models/     # Gestores de Estado de Presentación (ChangeNotifier)
 ┃ ┣ 📂 widgets/         # Componentes de UI modulares y reutilizables (Cards, Inputs, Painters)
 ┃ ┗ 📜 main.dart        # Punto de entrada de la aplicación y configuración del Tema
 ┣ 📂 test/              # Suite de pruebas automatizadas QA
 ┃ ┣ 📜 ui_render_test.dart       # Pruebas de renderizado de widgets
 ┃ ┗ 📜 ui_render_test.mocks.dart # Stubs autogenerados por Mockito (NO EDITAR)
 ┣ 📜 .env.example       # Plantilla para variables de entorno seguras (URLs de API)
 ┣ 📜 pubspec.yaml       # Gestor de paquetes de Dart y declaración de assets
 ┗ 📜 README.md          # Documentación centralizada del repositorio

```

---

## Resumen del Sistema

Una aplicación reactiva multiplataforma construida con Flutter. Utiliza `ChangeNotifier` para la gestión de estado localizado y `SharedPreferences` para la persistencia segura de la sesión, comunicándose completamente a través de payloads JSON RESTful.

Características Arquitectónicas Principales

* **Abstracción de Red:** El `ApiClient` maneja implícitamente la resolución dinámica de URLs de entorno y la inyección automática de JWT para rutas autenticadas, eliminando el código repetitivo (*boilerplate*).
* **Vistas Tontas y Renderizado Quirúrgico:** El uso de nodos `ListenableBuilder` evita repintados costosos de todo el árbol (`setState`), mutando selectivamente solo los píxeles requeridos (ej. alternar un spinner de carga).
* **Seguridad de Memoria:** La sobreescritura estricta en cascada del método `dispose()` dentro de los ViewModels previene fugas de memoria por `TextEditingController` huérfanos durante la navegación rápida.
* **Pruebas Simétricas:** Integración completa con Mockito que permite que las pruebas de renderizado de UI pasen en los pipelines CI/CD sin acceder al almacenamiento local ni ejecutar llamadas de red reales.

---

## Stack Tecnológico

* **Lenguaje:** Dart (Null-Safe)
* **Framework:** Flutter (Toolkit de UI multiplataforma)
* **Arquitectura:** MVVM (Model-View-ViewModel)
* **Gestión de Estado:** Listenables Reactivos (ChangeNotifier)
* **Redes (Networking):** paquete http con abstracción centralizada
* **QA y Pruebas:** flutter_test, mockito, build_runner

---

## Instalación y Ejecución Local

1. Clonar el repositorio

```Code snippet
git clone https://github.com/Prado500/ecotur-asoprado-frontend
cd ecotur-asoprado-frontend/ecotur_app

```

2. Variables de Entorno

Cree un archivo `.env` en el directorio raíz basándose en `.env.example`. Este archivo dicta a dónde envía el ApiClient las peticiones HTTP.

```Code snippet
API_URL=http://localhost:8000

```

3. Obtener Dependencias

```Code snippet
flutter pub get

```

4. Generar Mocks de Pruebas (Crucial para QA)

Siempre que se añada o modifique un Servicio de Dominio, regenere los stubs mockeados para mantener la suite de pruebas en verde:

```Code snippet
flutter pub run build_runner build --delete-conflicting-outputs

```

5. Ejecutar la Aplicación

Ejecute la aplicación en su dispositivo conectado o emulador:

```Code snippet
flutter run

```

6. Ejecutar la Suite de Pruebas

Verifique la integridad arquitectónica y las compuertas de renderizado de UI:

```Code snippet
flutter test

```