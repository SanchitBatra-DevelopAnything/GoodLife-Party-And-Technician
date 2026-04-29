import 'package:flutter/material.dart';
import '../models/area_model.dart';
import '../services/area_service.dart';

class AreaProvider extends ChangeNotifier {
  final AreaService areaService = AreaService();

  List<AreaModel> areas = [];
  bool isLoading = false;
  String? error;

  Future<void> loadAreas() async {
    try {
      isLoading = true;
      notifyListeners();

      areas = await areaService.fetchAreas();

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}