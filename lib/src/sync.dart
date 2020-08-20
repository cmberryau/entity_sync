import 'dart:mirrors';

import 'package:entity_sync/src/endpoints.dart';

import 'serialization.dart';
import 'storage.dart';

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return reflectClass(runtimeType).getField(Symbol('keyField')).reflectee;
  }

  /// Gets the flag field of the entity
  BoolField getFlagField() {
    return reflectClass(runtimeType).getField(Symbol('flagField')).reflectee;
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

/// Represents the result of a sync operation
class SyncResult<TSyncable extends SyncableMixin> {
  final List<EndpointResult<TSyncable>> endpointResults;

  SyncResult(this.endpointResults);
}

/// Responsible for controlling the syncing of entities
class SyncController<TSyncable extends SyncableMixin> {
  /// The endpoint for syncing
  final Endpoint<TSyncable> endpoint;
  /// The storage for syncing
  final Storage<TSyncable> storage;

  SyncController(this.endpoint, this.storage);

  @override
  Future<SyncResult<TSyncable>> sync([DateTime since]) async {
    /// get all instances to sync
    final toSyncInstances = await storage.getInstancesToSync();

    /// push all instances to sync to endpoint
    final endpointResults = await push(toSyncInstances);

    /// pull all from endpoint since last sync
    final endpointPullAll = await endpoint.pullAllSince(since);

    /// Insert all into local db
    for (var instance in endpointPullAll.instances) {
      await storage.upsertInstance(instance);
    }

    return SyncResult<TSyncable>(endpointResults);
  }

  Future<List<EndpointResult<TSyncable>>> push(Iterable<TSyncable> instances) async {
    final results = <EndpointResult<TSyncable>>[];

    /// push to endpoint
    for (var instanceToPush in instances) {
      final endpointResult = endpoint.readOnly ? await endpoint
          .pull(instanceToPush) : await endpoint.push(instanceToPush);

      /// save the endpoint results for the sync result
      results.add(endpointResult);

      if (endpointResult.successful) {
        if (endpointResult.instances.isNotEmpty) {
          if (endpointResult.instances.length > 1) {
            /// TODO Warn if more than one returned
            throw UnimplementedError();
          }

          final returnedInstance = endpointResult.instances[0];
          /// Compare and write any changes to table
          if(!endpoint.serializer.areEqual(instanceToPush, returnedInstance)) {
            await storage.upsertInstance(returnedInstance);
          }
        } else {
          /// TODO Warn if none returned
          throw UnimplementedError();
        }
      } else {
        /// TODO Warn if not successful
        throw UnimplementedError();
      }
    }

    return results;
  }
}
