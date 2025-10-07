import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../utils/storage_helper.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await StorageHelper.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .get(Uri.parse('${AppConstants.baseUrl}$endpoint'), headers: headers)
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .post(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .put(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await _client
          .delete(
            Uri.parse('${AppConstants.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    Map<String, dynamic>? responseData;

    try {
      responseData = json.decode(response.body);
    } catch (e) {
      responseData = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        data: responseData,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: responseData?['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
        data: responseData,
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'Server error occurred';
    } else {
      return 'An unexpected error occurred';
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, message: $message, statusCode: $statusCode}';
  }
}
