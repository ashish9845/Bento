class ServerException implements Exception {
  final String message;
  const new(this.message);
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const new(this.message);
  @override
  String toString() => 'CacheException: $message';
}

class PermissionException implements Exception {
  final String message;
  const new(this.message);
  @override
  String toString() => 'PermissionException: $message';
}
