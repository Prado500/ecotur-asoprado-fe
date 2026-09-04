class TouristService {
  final int id;
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final int maxCapacity;
  final bool isAvailable;
  final List<String> imageUrls;

  TouristService({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.maxCapacity,
    required this.isAvailable,
    required this.imageUrls,
  });

  /// Fabricates a [TouristService] instance from a JSON map.
  /// Safely handles nulls, type conversions, and extracts the unique ID from FastAPI.
  factory TouristService.fromJson(Map<String, dynamic> json) {
    List<String> extractedUrls = [];

    if (json['images'] != null && json['images'] is List) {
      extractedUrls = (json['images'] as List)
          .map((img) => img['image_url'].toString())
          .toList();
    }

    return TouristService(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Servicio sin nombre',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      basePrice: double.tryParse(json['base_price'].toString()) ?? 0.0,
      maxCapacity: json['max_capacity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      imageUrls: extractedUrls,
    );
  }

  /// Returns the first URL from the image list, or an empty string if there are no images.
  /// Ideal to be consumed as a cover image by the UI.
  String get primaryImageUrl {
    return imageUrls.isNotEmpty ? imageUrls.first : '';
  }
}