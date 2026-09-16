import 'package:flutter/material.dart';
import '../models/tourist_service_model.dart';

/// ViewModel responsible for managing the Package Details screen.
/// Prepares the presentation layer for future transactional operations (e.g., Booking).
class DetailsViewModel extends ChangeNotifier {
  final TouristService service;

  bool _isProcessing = false;

  /// Injects the domain model strictly for display and future transaction mapping.
  DetailsViewModel(this.service);

  bool get isProcessing => _isProcessing;

  /// Placeholder for the future booking operation (Sprint 5).
  Future<void> initiateBooking() async {
    _isProcessing = true;
    notifyListeners();

    // TODO: Implement Wompi API interaction here.
    await Future.delayed(const Duration(seconds: 2));

    _isProcessing = false;
    notifyListeners();
  }
}