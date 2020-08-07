import 'dart:mirrors';

import 'serialization.dart';


/// Represents an endpoint for syncing, such as a restful api
abstract class SyncEndpoint<TSyncable extends SyncableMixin,
                            TSerializer extends Serializer<TSyncable>> {
  /// Syncs the syncable entity with the endpoint
  Future<SyncResult> sync(TSyncable syncable);
}

/// Represents a restful api endpoint for syncing
class RestfulApiSyncEndpoint<TSyncable extends SyncableMixin,
                             TSerializer extends Serializer<TSyncable>>
                             extends SyncEndpoint {
  @override
  Future<SyncResult> sync(syncable) {
    // TODO: implement sync
    throw UnimplementedError();
  }
}

/// Represents the result of syncing
class SyncResult {

}

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// Syncs the entity with an endpoint
  Future<SyncResult> sync(SyncEndpoint endpoint) async {
    return await endpoint.sync(this);
  }

  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return reflect(this).getField(Symbol('keyField')).reflectee;
  }

  /// Gets the flag field of the entity
  BoolField getFlagField() {
    return reflect(this).getField(Symbol('flagField')).reflectee;
  }

  /// Gets the key value of the entity
  dynamic getKeyValue(SerializableField keyField) {
    return reflect(this).getField(Symbol(keyField.name)).reflectee;
  }

  /// Gets the flag value of the entity
  bool getFlagValue(BoolField flagField) {
    return reflect(this).getField(Symbol(flagField.name)).reflectee;
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