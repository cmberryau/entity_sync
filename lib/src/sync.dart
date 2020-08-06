import 'dart:mirrors';

import 'serialization.dart';


/// Represents an endpoint for syncing, such as a restful api
class SyncEndpoint {

}

/// Represents a restful api endpoint for syncing
class RestfulApiSyncEndpoint {

}

/// Represents the result of syncing
class SyncResult {

}

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// Syncs the entity with an endpoint
  Future<SyncResult> sync(SyncEndpoint endpoint) async {

  }

  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return reflect(this).getField(Symbol('syncableKey')).reflectee;
  }

  /// Gets the key value of the entity
  dynamic getKeyValue(SerializableField keyField) {
    return reflect(this).getField(Symbol(keyField.name)).reflectee;
  }

  /// Gets the representation of the key of the entity
  dynamic getKeyRepresentation() {
    final keyField = getKeyField();
    final keyValue = getKeyValue(keyField);

    return keyField.toRepresentation(keyValue);
  }

  @override
  dynamic getFieldValue(String fieldName);
}