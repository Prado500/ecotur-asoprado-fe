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

// Import domain and state management services
import 'package:ecotur_app/services/catalog_service.dart';
import 'package:ecotur_app/services/auth_service.dart';
import 'package:ecotur_app/services/session_service.dart';
import 'package:ecotur_app/services/tourist_service.dart';

import 'ui_render_test.mocks.dart';

// Inject TouristService into the Mock generator
@GenerateMocks([CatalogService, AuthService, SessionService, TouristService])
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
      expect(find.text('ECOTUR ASOPRADO'), findsOneWidget); // Default Tourist AppBar title
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
      final mockTouristService = MockTouristService();

      // Stubbing the profile hydration response
      when(mockTouristService.fetchMyProfile()).thenAnswer((_) async => {
        'success': true,
        'data': {'first_name': 'Admin'}
      });

      await tester.pumpWidget(MaterialApp(
        home: AdminDashboardScreen(touristService: mockTouristService),
      ));
      await tester.pumpAndSettle();

      // Validate UI Structure
      expect(find.text('¿Qué haremos hoy?'), findsOneWidget);
      expect(find.text('Administrar\npaquetes'), findsOneWidget);
      expect(find.text('Administrar\nusuarios'), findsOneWidget);

      // Verify hydration logic executed
      verify(mockTouristService.fetchMyProfile()).called(1);
    });

    // --- TEST 5: ADMIN KANBAN SCREEN ---
    testWidgets('Should render Admin Kanban Screen with its respective 4 columns', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();

      // Stub concurrent API calls
      when(mockCatalogService.fetchServices()).thenAnswer((_) async => []);
      when(mockCatalogService.fetchInactiveServices()).thenAnswer((_) async => []);
      when(mockCatalogService.fetchDeletedServices()).thenAnswer((_) async => []);

      await tester.pumpWidget(MaterialApp(
        home: AdminKanbanScreen(entityType: 'paquetes', catalogService: mockCatalogService),
      ));
      await tester.pumpAndSettle();

      // Validate Kanban Columns exist
      expect(find.text('GESTIÓN DE PAQUETES'), findsOneWidget);
      expect(find.text('Auditar'), findsOneWidget);
      expect(find.text('Eliminados'), findsOneWidget);
      expect(find.text('Por Activar'), findsOneWidget);
      expect(find.text('Activos'), findsOneWidget);
    });

    // --- TEST 6: ADMIN CREATE PACKAGE SCREEN (BIMODAL) ---
    testWidgets('Should render Admin Create Package Form with Fail Fast Constraints', (WidgetTester tester) async {
      final mockCatalogService = MockCatalogService();

      await tester.pumpWidget(MaterialApp(
        home: AdminCreatePackageScreen(catalogService: mockCatalogService),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CREAR NUEVO PAQUETE'), findsOneWidget);
      expect(find.text('NOMBRE DEL PAQUETE'), findsOneWidget);
      expect(find.text('PRECIO BASE (COP)'), findsOneWidget);
      expect(find.text('GUARDAR'), findsOneWidget);
    });
  });
}