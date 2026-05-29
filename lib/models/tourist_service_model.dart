class TouristService {
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final int maxCapacity;
  final bool isAvailable;
  final List<String> imageUrls;

  TouristService({
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.maxCapacity,
    required this.isAvailable,
    required this.imageUrls,
  });

  /// Fabrica una instancia de [TouristService] a partir de un mapa JSON.
  /// Maneja de forma segura los nulos y la conversión de tipos provenientes del backend (FastAPI).
  factory TouristService.fromJson(Map<String, dynamic> json) {
    List<String> extractedUrls = [];

    if (json['images'] != null && json['images'] is List) {
      extractedUrls = (json['images'] as List)
          .map((img) => img['image_url'].toString())
          .toList();
    }

    return TouristService(
      name: json['name'] ?? 'Servicio sin nombre',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      maxCapacity: json['max_capacity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      imageUrls: extractedUrls,
    );
  }

  /// Retorna la primera URL de la lista de imágenes, o una cadena vacía si no hay imágenes.
  /// Ideal para ser consumida como portada por la UI.
  String get primaryImageUrl {
    return imageUrls.isNotEmpty ? imageUrls.first : '';
  }
}