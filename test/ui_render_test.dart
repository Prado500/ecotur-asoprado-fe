import 'package:ecotur_app/models/tourist_service_model.dart';
import 'package:ecotur_app/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import application screens
import 'package:ecotur_app/screens/login_screen.dart';
import 'package:ecotur_app/screens/catalog_screen.dart';
import 'package:ecotur_app/screens/admin_dashboard_screen.dart';
import 'package:ecotur_app/screens/admin_kanban_screen.dart';
import 'package:ecotur_app/screens/admin_create_package_screen.dart';
import 'package:ecotur_app/screens/admin_user_form_screen.dart'; // <-- Nuevo import

// Import domain and state management services
import 'package:ecotur_app/services/catalog_service.dart';
import 'package:ecotur_app/services/auth_service.dart';
import 'package:ecotur_app/services/session_service.dart';
import 'package:ecotur_app/services/user_service.dart'; // <-- Import corregido

import 'ui_render_test.mocks.dart';

// Inject UserService into the Mock generator
@GenerateMocks([CatalogService, AuthService, SessionService, UserService])
void main() {

  setUpAll(() {
    dotenv.loadFromString(envString: '''
API_URL=http://localhost:8000
    ''');
  });

  group('UI Rendering Quality Gate', () {

    // --- TEST 1: LOGIN SCREEN ---
    testWidgets('Should render the Login screen with its critical input fields', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();
      final mockSessionService = MockSessionService();

      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(authService: mockAuthService, sessionService: mockSessionService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('CORREO ELECTRÓNICO'), findsOneWidget);
      expect(find.text('CONTRASEÑA'), findsOneWidget);
    });

    // --- TEST 2: CATALOG SCREEN (TOURIST VIEW) ---
    testWidgets('Should render the Catalog screen for Tourists with BottomNav', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();
      final mockSessionService = MockSessionService();

      when(mockCatalogService.fetchServices()).thenAnswer((_) async => []);
      when(mockSessionService.checkExistingSession()).thenAnswer((_) async => false);
      when(mockSessionService.userRole).thenReturn('tourist');

      await tester.pumpWidget(MaterialApp(
        home: CatalogScreen(catalogService: mockCatalogService, sessionService: mockSessionService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('SERVICIOS TURÍSTICOS'), findsOneWidget);
      expect(find.text('ECOTUR ASOPRADO'), findsOneWidget);
      verify(mockCatalogService.fetchServices()).called(1);
    });

    // --- TEST 3: VERIFICATION SCREEN ---
    testWidgets('Should render the Verification screen and its initial state', (WidgetTester tester) async {
      final mockAuthService = MockAuthService();

      await tester.pumpWidget(MaterialApp(
        home: VerificationScreen(token: "dummy_jwt_token", authService: mockAuthService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('VERIFICACIÓN DE SEGURIDAD'), findsOneWidget);
      expect(find.text('Verificar mi Cuenta'), findsOneWidget);
    });

    // --- TEST 4: ADMIN DASHBOARD HUB ---
    testWidgets('Should render Admin Action Hub and hydrate profile', (WidgetTester tester) async {
      final mockUserService = MockUserService(); // <-- Cambiado a UserService

      // Stubbing the profile hydration response
      when(mockUserService.fetchMyProfile()).thenAnswer((_) async => {
        'success': true,
        'data': {'first_name': 'Admin'}
      });

      await tester.pumpWidget(MaterialApp(
        home: AdminDashboardScreen(userService: mockUserService),
      ));
      await tester.pumpAndSettle();

      // Validate UI Structure
      expect(find.text('¿Qué haremos hoy?'), findsOneWidget);
      expect(find.text('Administrar\npaquetes'), findsOneWidget);
      expect(find.text('Administrar\nusuarios'), findsOneWidget);

      // Verify hydration logic executed
      verify(mockUserService.fetchMyProfile()).called(1);
    });

    // --- TEST 5: ADMIN KANBAN SCREEN (PACKAGES) ---
    testWidgets('Should render Admin Kanban Screen for Packages', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();
      final mockUserService = MockUserService();

      // Stub concurrent API calls
      when(mockCatalogService.fetchServices()).thenAnswer((_) async => []);
      when(mockCatalogService.fetchInactiveServices()).thenAnswer((_) async => []);
      when(mockCatalogService.fetchDeletedServices()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: AdminKanbanScreen(
          entityType: 'paquetes',
          catalogService: mockCatalogService,
          userService: mockUserService,
        ),
      ));
      await tester.pumpAndSettle();

      // Validate Kanban Columns exist
      expect(find.text('GESTIÓN DE PAQUETES'), findsOneWidget);
      expect(find.text('Auditar'), findsOneWidget);
      expect(find.text('Eliminados'), findsOneWidget);
      expect(find.text('Por Activar'), findsOneWidget);
      expect(find.text('Activos'), findsOneWidget);
    });

    // --- TEST 6: ADMIN KANBAN SCREEN (USERS) ---
    testWidgets('Should render Admin Kanban Screen for Users', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();
      final mockUserService = MockUserService();

      // Stub concurrent API calls specifically for users
      when(mockUserService.fetchUsers()).thenAnswer((_) async => []);
      when(mockUserService.fetchDeletedUsers()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: AdminKanbanScreen(
          entityType: 'usuarios',
          catalogService: mockCatalogService,
          userService: mockUserService,
        ),
      ));
      await tester.pumpAndSettle();

      // Validate User Kanban Columns exist
      expect(find.text('GESTIÓN DE USUARIOS'), findsOneWidget);
      expect(find.text('Auditar'), findsOneWidget);
      expect(find.text('Eliminados'), findsOneWidget);
      expect(find.text('Por Activar'), findsOneWidget);
      expect(find.text('Activos'), findsOneWidget);
    });

    // --- TEST 7: ADMIN USER FORM SCREEN (BIMODAL) ---
    testWidgets('Should render Admin User Form with Creation Constraints and RBAC Dropdown', (WidgetTester tester) async {
      final mockUserService = MockUserService();
      final mockSessionService = MockSessionService();

      // Simulate Superadmin hierarchical claims
      when(mockSessionService.userRole).thenReturn('superadmin');
      when(mockSessionService.checkExistingSession()).thenAnswer((_) async => true);

      await tester.pumpWidget(MaterialApp(
        home: AdminUserFormScreen(
            userService: mockUserService,
            sessionService: mockSessionService
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('NUEVO USUARIO'), findsOneWidget);
      expect(find.text('CÉDULA DE CIUDADANÍA'), findsOneWidget);
      expect(find.text('CONTRASEÑA TEMPORAL'), findsOneWidget);

      // Asserts that the Superadmin exclusive role selector was successfully rendered
      expect(find.text('ROL DEL USUARIO (Exclusivo Superadmin)'), findsOneWidget);

      expect(find.text('CREAR CUENTA'), findsOneWidget);
    });

    // --- TEST 8: ADMIN CREATE PACKAGE SCREEN (CREATION MODE) ---
    testWidgets('Should render Admin Package Form in Creation Mode with upload button', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();

      await tester.pumpWidget(MaterialApp(
        home: AdminCreatePackageScreen(catalogService: mockCatalogService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CREAR NUEVO PAQUETE'), findsOneWidget);
      expect(find.text('SELECCIONAR IMÁGENES LOCALES'), findsOneWidget);
      expect(find.text('GUARDAR'), findsOneWidget);
    });

    // --- TEST 9: ADMIN CREATE PACKAGE SCREEN (EDITION MODE) ---
    testWidgets('Should render Admin Package Form in Edition Mode with Read-Only UI', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();

      // Stubbing an existing service to trigger Edition Mode
      final dummyService = TouristService(
        id: 1,
        name: 'Paquete de Prueba en Nube',
        description: 'Descripción',
        category: 'recreacional',
        basePrice: 50000,
        maxCapacity: 10,
        isAvailable: true,
        imageUrls: ['https://azure.com/img1.jpg'],
      );

      await tester.pumpWidget(MaterialApp(
        home: AdminCreatePackageScreen(
          catalogService: mockCatalogService,
          serviceToEdit: dummyService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('EDITAR PAQUETE'), findsOneWidget);
      // Validates the presence of the Read-Only disclaimer
      expect(find.text('Las imágenes están alojadas de forma segura en la nube (CDN).'), findsOneWidget);
      expect(find.text('ACTUALIZAR'), findsOneWidget);
      // Strictly asserts that the upload button is NOT rendered in edit mode
      expect(find.text('SELECCIONAR IMÁGENES LOCALES'), findsNothing);
    });

  });
}