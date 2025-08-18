import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio) {
    dio.options.baseUrl = ApiEndpoints.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
  }

  Future<Response> get(String path) async => dio.get(path);
  Future<Response> post(String path, {dynamic data}) async =>
      dio.post(path, data: data);
}
