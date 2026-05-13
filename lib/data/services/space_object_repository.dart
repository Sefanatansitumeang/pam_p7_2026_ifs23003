import 'dart:io';
import 'dart:typed_data';
import '../models/space_object_model.dart';
import '../models/api_response_model.dart';
import 'space_object_service.dart';

class SpaceObjectRepository {
  SpaceObjectRepository({SpaceObjectService? service})
      : _service = service ?? SpaceObjectService();

  final SpaceObjectService _service;

  Future<ApiResponse<List<SpaceObjectModel>>> getSpaceObjects({
    String search = '',
    String tipe = '',
  }) async {
    try {
      return await _service.getSpaceObjects(search: search, tipe: tipe);
    } catch (e) {
      return ApiResponse(success: false, message: 'Kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<SpaceObjectModel>> getSpaceObjectById(String id) async {
    try {
      return await _service.getSpaceObjectById(id);
    } catch (e) {
      return ApiResponse(success: false, message: 'Kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<String>> createSpaceObject({
    required String nama, required String tipe,
    required String deskripsi, required String jarakDariBumi,
    required String fakta,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.createSpaceObject(
        nama: nama, tipe: tipe, deskripsi: deskripsi,
        jarakDariBumi: jarakDariBumi, fakta: fakta,
        imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<void>> updateSpaceObject({
    required String id, required String nama, required String tipe,
    required String deskripsi, required String jarakDariBumi,
    required String fakta,
    File? imageFile, Uint8List? imageBytes, String imageFilename = 'image.jpg',
  }) async {
    try {
      return await _service.updateSpaceObject(
        id: id, nama: nama, tipe: tipe, deskripsi: deskripsi,
        jarakDariBumi: jarakDariBumi, fakta: fakta,
        imageFile: imageFile, imageBytes: imageBytes, imageFilename: imageFilename,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Kesalahan jaringan: $e');
    }
  }

  Future<ApiResponse<void>> deleteSpaceObject(String id) async {
    try {
      return await _service.deleteSpaceObject(id);
    } catch (e) {
      return ApiResponse(success: false, message: 'Kesalahan jaringan: $e');
    }
  }
}