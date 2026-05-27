import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Importa tus pantallas y servicios
import 'package:ecotur_app/screens/login_screen.dart';
import 'package:ecotur_app/screens/catalog_screen.dart';
import 'package:ecotur_app/services/api_service.dart';

// Importa el archivo autogenerado de Mocks (marcará error hasta correr build_runner)
import 'ui_render_test.mocks.dart';

// Le decimos a Mockito que necesitamos un clon (Mock) de ApiService
@GenerateMocks([ApiService])
void main() {

  setUpAll(() {
    dotenv.loadFromString(envString: '''
API_URL=http://localhost:8000
    ''');
  });

  group('Compuerta de Calidad Visual (UI Rendering)', () {

    // --- PRUEBA 1: LOGIN ---
    testWidgets('Debe renderizar la pantalla de Login con sus campos críticos', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LoginScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('INICIAR SESIÓN'), findsOneWidget);
      expect(find.text('CORREO ELECTRÓNICO'), findsOneWidget);
      expect(find.text('CONTRASEÑA'), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);
    });

    // --- PRUEBA 2: CATÁLOGO CON MOCKITO ---
    testWidgets('Debe renderizar el Catálogo usando un ApiService simulado', (WidgetTester tester) async {

      // 1. Instanciamos el servicio falso (Mock)
      final mockApiService = MockApiService();

      // 2. STUBBING (Programar el clon):
      // Le decimos que cuando la pantalla llame a fetchServices(),
      // devuelva inmediatamente una lista vacía en lugar de intentar ir a internet.
      when(mockApiService.fetchServices()).thenAnswer((_) async => []);

      // 3. Inflamos el catálogo inyectando nuestro clon
      await tester.pumpWidget(MaterialApp(
        home: CatalogScreen(apiService: mockApiService),
      ));

      // 4. Dejamos que los frames avancen y se procese el FutureBuilder
      await tester.pumpAndSettle();

      // 5. Validamos que la pantalla no explotó y renderizó su estructura principal
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('SERVICIOS TURÍSTICOS'), findsOneWidget);

      // 6. Verificamos que la pantalla efectivamente intentó usar nuestro servicio falso
      verify(mockApiService.fetchServices()).called(1);
    });
  });
}