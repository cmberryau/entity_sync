enum EntitySyncErrorType { PUSH }

class EntitySyncError implements Exception {
  final EntitySyncErrorType type;
  final String message;

  EntitySyncError(this.type, this.message);

  @override
  String toString() {
    return 'EntitySyncError [$type]: $message';
  }
}
