import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/space_object_model.dart';
import '../models/api_response_model.dart';
import '../../core/constants/api_constants.dart';

class SpaceObjectService {
  SpaceObjectService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<List<SpaceObjectModel>>> getSpaceObjects({
    String search = '',
    String tipe = '',
  }) async {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (tipe.isNotEmpty) params['tipe'] = tipe;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.spaceObjects}')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      final list    = (dataMap['spaceObjects'] as List<dynamic>)
          .map((e) => SpaceObjectModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil.',
        data: list,
      );
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<SpaceObjectModel>> getSpaceObjectById(String id) async {
    final uri      = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.spaceObjectById(id)}');
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil.',
        data: SpaceObjectModel.fromJson(dataMap['spaceObject'] as Map<String, dynamic>),
      );
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<String>> createSpaceObject({
    required String nama,
    required String tipe,
    required String deskripsi,
    required String jarakDariBumi,
    required String fakta,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri     = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.spaceObjects}');
    final request = http.MultipartRequest('POST', uri)
      ..fields['nama']          = nama
      ..fields['tipe']          = tipe
      ..fields['deskripsi']     = deskripsi
      ..fields['jarakDariBumi'] = jarakDariBumi
      ..fields['fakta']         = fakta;

    await _attachImageAsync(request, imageFile, imageBytes, imageFilename);

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final dataMap = body['data'] as Map<String, dynamic>;
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil ditambahkan.',
        data: dataMap['spaceObjectId'] as String,
      );
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> updateSpaceObject({
    required String id,
    required String nama,
    required String tipe,
    required String deskripsi,
    required String jarakDariBumi,
    required String fakta,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFilename = 'image.jpg',
  }) async {
    final uri     = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.spaceObjectById(id)}');
    final request = http.MultipartRequest('PUT', uri)
      ..fields['nama']          = nama
      ..fields['tipe']          = tipe
      ..fields['deskripsi']     = deskripsi
      ..fields['jarakDariBumi'] = jarakDariBumi
      ..fields['fakta']         = fakta;

    await _attachImageAsync(request, imageFile, imageBytes, imageFilename);

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        success: true,
        message: body['message'] as String? ?? 'Berhasil diperbarui.',
      );
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  Future<ApiResponse<void>> deleteSpaceObject(String id) async {
    final uri      = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.spaceObjectById(id)}');
    final response = await _client.delete(uri);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return const ApiResponse(success: true, message: 'Berhasil dihapus.');
    }
    return ApiResponse(success: false, message: _parseError(response));
  }

  // ─────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────

  Future<void> _attachImageAsync(
      http.MultipartRequest request,
      File? imageFile,
      Uint8List? imageBytes,
      String imageFilename,
      ) async {
    if (kIsWeb && imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', imageBytes, filename: imageFilename),
      );
    } else if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }
  }

  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ?? 'Gagal. Kode: ${response.statusCode}';
    } catch (_) {
      return 'Gagal. Kode: ${response.statusCode}';
    }
  }

  void dispose() => _client.close();
}