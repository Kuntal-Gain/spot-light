class ServerException implements Exception {
  final String message;

  ServerException({this.message = "Something went wrong"});

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException({this.message = "Something went wrong"});

  @override
  String toString() => 'CacheException: $message';
}
