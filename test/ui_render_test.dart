import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Import application screens
import 'package:ecotur_app/screens/login_screen.dart';
import 'package:ecotur_app/screens/catalog_screen.dart';

// Import domain and state management services
import 'package:ecotur_app/services/catalog_service.dart';
import 'package:ecotur_app/services/auth_service.dart';
import 'package:ecotur_app/services/session_service.dart';

// Import the auto-generated Mocks file.
// NOTE: This will show a red error in your IDE until you execute the build_runner command.
import 'ui_render_test.mocks.dart';

// Instruct Mockito to generate mock classes for these specific services.
@GenerateMocks([CatalogService, AuthService, SessionService])
void main() {

  setUpAll(() {
    // Inject environment variables to prevent the internal ApiClient from crashing during tests.
    dotenv.loadFromString(envString: '''
API_URL=http://localhost:8000
    ''');
  });

  group('UI Rendering Quality Gate', () {

    // --- TEST 1: LOGIN SCREEN ---
    testWidgets('Should render the Login screen with its critical input fields', (WidgetTester tester) async {
      // Instantiate the mock services to bypass network and SharedPreferences exceptions.
      final mockAuthService = MockAuthService();
      final mockSessionService = MockSessionService();

      // Pump the login widget injecting the mock dependencies.
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(
          authService: mockAuthService,
          sessionService: mockSessionService,
        ),
      ));

      await tester.pumpAndSettle();

      // Validate that the critical UI components are painted on the screen.
      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('CORREO ELECTRÓNICO'), findsOneWidget);
      expect(find.text('CONTRASEÑA'), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    // --- TEST 2: CATALOG SCREEN ---
    testWidgets('Should render the Catalog screen using a mocked CatalogService', (WidgetTester tester) async {

      // 1. Instantiate the mock domain specialist.
      final mockCatalogService = MockCatalogService();

      // 2. STUBBING (Program the mock's behavior):
      // Simulate the backend returning an empty list of tourist packages.
      when(mockCatalogService.fetchServices()).thenAnswer((_) async => []);

      // 3. Pump the catalog widget injecting the mock dependency.
      await tester.pumpWidget(MaterialApp(
        home: CatalogScreen(catalogService: mockCatalogService),
      ));

      // 4. Advance the frames to allow the ViewModel's Future to resolve.
      await tester.pumpAndSettle();

      // 5. Validate that the screen did not crash and rendered its main structure.
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('SERVICIOS TURÍSTICOS'), findsOneWidget);

      // 6. Verify that the view effectively commanded the ViewModel to fetch data from the service.
      verify(mockCatalogService.fetchServices()).called(1);
    });
  });
}