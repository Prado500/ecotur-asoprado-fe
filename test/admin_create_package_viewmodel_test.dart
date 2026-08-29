import 'package:flutter_test/flutter_test.dart';
import 'package:ecotur_app/view_models/admin_create_package_viewmodel.dart';
import 'package:ecotur_app/models/tourist_service_model.dart';
import 'ui_render_test.mocks.dart';

void main() {
  late MockCatalogService mockCatalogService;
  late AdminCreatePackageViewModel viewModel;

  setUp(() {
    mockCatalogService = MockCatalogService();
  });

  group('AdminCreatePackageViewModel Logic Tests', () {
    test('Should initialize in Creation Mode correctly', () {
      viewModel = AdminCreatePackageViewModel(mockCatalogService);

      expect(viewModel.isEditMode, isFalse);
      // Evaluates the new unified URL array
      expect(viewModel.selectedImagesUrls.isEmpty, isTrue);
    });

    test('Should initialize in Edition Mode and hydrate text fields and URLs', () {
      final dummyService = TouristService(
          id: 1,
          name: 'Test Package',
          description: 'Test Desc',
          category: 'agroturismo',
          basePrice: 50000,
          maxCapacity: 15,
          isAvailable: true,
          imageUrls: ['https://ecoturasopradocdn2026.blob.core.windows.net/ecotur-images/1.jpg']
      );

      viewModel = AdminCreatePackageViewModel(mockCatalogService, serviceToEdit: dummyService);

      expect(viewModel.isEditMode, isTrue);
      expect(viewModel.nameController.text, 'Test Package');
      expect(viewModel.selectedCategory, 'agroturismo');

      // Eager Uploading Paradigm: The unified String list must be hydrated with permanent CDN URLs
      expect(viewModel.selectedImagesUrls.isNotEmpty, isTrue);
      expect(viewModel.selectedImagesUrls.first, 'https://ecoturasopradocdn2026.blob.core.windows.net/ecotur-images/1.jpg');

      // Assert local metadata hydration (In-Memory URL-to-Filename dictionary)
      expect(viewModel.imageNamesMap.isNotEmpty, isTrue);
      expect(viewModel.imageNamesMap.containsKey('https://ecoturasopradocdn2026.blob.core.windows.net/ecotur-images/1.jpg'), isTrue);
      expect(viewModel.imageNamesMap['https://ecoturasopradocdn2026.blob.core.windows.net/ecotur-images/1.jpg'], '1.jpg');
    });

    test('savePackage should halt execution and set error if no images are selected', () async {
      viewModel = AdminCreatePackageViewModel(mockCatalogService);

      // Attempt to trigger the save workflow with an empty string array
      await viewModel.savePackage();

      // Assert that the ViewModel traps the error before hitting the Domain Layer
      expect(viewModel.errorMessage, 'Debes seleccionar al menos una imagen (la portada) para el paquete.');
      expect(viewModel.isLoading, isFalse);
    });
  });
}