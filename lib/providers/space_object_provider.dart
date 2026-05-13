import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../data/models/space_object_model.dart';
import '../data/services/space_object_repository.dart';

enum SpaceStatus { initial, loading, success, error }

class SpaceObjectProvider extends ChangeNotifier {
  SpaceObjectProvider({SpaceObjectRepository? repository})
      : _repository = repository ?? SpaceObjectRepository();

  final SpaceObjectRepository _repository;

  SpaceStatus _status = SpaceStatus.initial;
  List<SpaceObjectModel> _objects = [];
  SpaceObjectModel? _selected;
  String _errorMessage = '';
  String _searchQuery = '';
  String _filterTipe  = '';

  SpaceStatus get status       => _status;
  SpaceObjectModel? get selected => _selected;
  String get errorMessage      => _errorMessage;
  String get searchQuery       => _searchQuery;
  String get filterTipe        => _filterTipe;

  List<SpaceObjectModel> get objects {
    var list = List<SpaceObjectModel>.from(_objects);
    if (_filterTipe.isNotEmpty) {
      list = list.where((o) => o.tipe.toLowerCase() == _filterTipe.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((o) => o.nama.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  Future<void> loadSpaceObjects() async {
    _setStatus(SpaceStatus.loading);
    final result = await _repository.getSpaceObjects();
    if (result.success && result.data != null) {
      _objects = result.data!;
      _setStatus(SpaceStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(SpaceStatus.error);
    }
  }

  Future<void> loadSpaceObjectById(String id) async {
    _setStatus(SpaceStatus.loading);
    final result = await _repository.getSpaceObjectById(id);
    if (result.success && result.data != null) {
      _selected = result.data;
      _setStatus(SpaceStatus.success);
    } else {
      _errorMessage = result.message;
      _setStatus(SpaceStatus.error);
    }
  }

  Future<bool> addSpaceObject({
    required String nama, required String tipe,
    required String deskripsi, required String jarakDariBumi,
    required String fakta,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(SpaceStatus.loading);
    final result = await _repository.createSpaceObject(
      nama: nama, tipe: tipe, deskripsi: deskripsi,
      jarakDariBumi: jarakDariBumi, fakta: fakta,
      imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadSpaceObjects(); return true; }
    _errorMessage = result.message;
    _setStatus(SpaceStatus.error);
    return false;
  }

  Future<bool> editSpaceObject({
    required String id, required String nama, required String tipe,
    required String deskripsi, required String jarakDariBumi,
    required String fakta,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    _setStatus(SpaceStatus.loading);
    final result = await _repository.updateSpaceObject(
      id: id, nama: nama, tipe: tipe, deskripsi: deskripsi,
      jarakDariBumi: jarakDariBumi, fakta: fakta,
      imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
    );
    if (result.success) { await loadSpaceObjectById(id); return true; }
    _errorMessage = result.message;
    _setStatus(SpaceStatus.error);
    return false;
  }

  Future<bool> removeSpaceObject(String id) async {
    _setStatus(SpaceStatus.loading);
    final result = await _repository.deleteSpaceObject(id);
    if (result.success) {
      _objects.removeWhere((o) => o.id == id);
      _setStatus(SpaceStatus.success);
      return true;
    }
    _errorMessage = result.message;
    _setStatus(SpaceStatus.error);
    return false;
  }

  void updateSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
  void updateFilterTipe(String t)  { _filterTipe  = t; notifyListeners(); }
  void clearSelected()             { _selected = null; notifyListeners(); }

  void _setStatus(SpaceStatus s) { _status = s; notifyListeners(); }
}