import 'dart:mirrors';

import 'serialization.dart';

/// Represents the result of an operation with an endpoint
class EndpointResult<TSyncable extends SyncableMixin> {
  bool successful;
}

/// Represents the result of syncing
class SyncResult<TSyncable extends SyncableMixin>
    extends EndpointResult {

}

/// Represents an endpoint, such as a restful api
abstract class Endpoint<TSyncable extends SyncableMixin,
                        TSerializer extends Serializer<TSyncable>> {
  /// Syncs a single syncable entity with the endpoint
  Future<SyncResult<TSyncable>> sync(TSyncable syncable) async {
    /// do push, get result of push and pull
  }

  /// Pushes a single entity and returns any updates
  Future<EndpointResult<TSyncable>> push(TSyncable syncable);

  /// Pulls and returns a single entity
  Future<EndpointResult<TSyncable>> pull(TSyncable syncable);
}

/// Represents a restful api endpoint for syncing
class RestfulApiSyncEndpoint<TSyncable extends SyncableMixin,
                             TSerializer extends Serializer<TSyncable>>
                             extends Endpoint {
  @override
  Future<EndpointResult<SyncableMixin>> push(syncable) {
    // TODO: implement push
    throw UnimplementedError();
  }

  @override
  Future<EndpointResult<SyncableMixin>> pull(syncable) {
    // TODO: implement pull
    throw UnimplementedError();
  }
}

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// Syncs the entity with an endpoint
  Future<SyncResult> sync(Endpoint endpoint) async {
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