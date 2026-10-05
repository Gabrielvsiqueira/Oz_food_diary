import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/food.dart';
import '../repositories/food_repository.dart';

enum FoodSearchStatus { loading, success, error }

class FoodSearchController extends ChangeNotifier {
  FoodSearchController(
    this._repository, {
    this.debounce = const Duration(milliseconds: 300),
  }) {
    _load();
  }

  final FoodRepository _repository;
  final Duration debounce;

  Timer? _debounceTimer;
  int _requestId = 0;
  bool _disposed = false;

  String _query = '';
  List<Food> _results = const [];
  FoodSearchStatus _status = FoodSearchStatus.loading;

  String get query => _query;
  List<Food> get results => _results;
  FoodSearchStatus get status => _status;

  void onQueryChanged(String query) {
    if (query.trim() == _query) return;
    _query = query.trim();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, _load);
  }

  void retry() => _load();

  Future<void> _load() async {
    final requestId = ++_requestId;
    _status = FoodSearchStatus.loading;
    notifyListeners();
    try {
      final results = await _repository.search(_query);
      if (_disposed || requestId != _requestId) return;
      _results = results;
      _status = FoodSearchStatus.success;
    } catch (_) {
      if (_disposed || requestId != _requestId) return;
      _results = const [];
      _status = FoodSearchStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounceTimer?.cancel();
    super.dispose();
  }
}
