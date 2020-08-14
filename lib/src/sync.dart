import 'dart:mirrors';

import 'package:entity_sync/src/endpoints.dart';

import 'serialization.dart';
import 'storage.dart';

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
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

/// Represents the result of a sync operation
class SyncResult<TSyncable extends SyncableMixin> {
  final bool successful;
  final List<EndpointResult<TSyncable>> endpointResults;

  SyncResult(this.successful, this.endpointResults);
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

    var successful = true;
    final endpointResults = <EndpointResult<TSyncable>>[];

    /// push to endpoint
    for (var instanceToPush in toSyncInstances) {
      /// push the instance as json to get around types
      final pushToEndpoint = await endpoint.push(instanceToPush);

      /// save the endpoint results for the sync result
      endpointResults.add(pushToEndpoint);
      successful &= pushToEndpoint.successful;

      if (pushToEndpoint.successful) {
        if (pushToEndpoint.instances.isNotEmpty) {
          if (pushToEndpoint.instances.length > 1) {
            /// TODO Warn if more than one returned
            throw UnimplementedError();
          }

          final returnedInstance = pushToEndpoint.instances[0];
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

    /// pull all from endpoint since last sync
    final endpointPullAll = await endpoint.pullAllSince(since);
    final endpointInstances = endpointPullAll.instances;

    /// Insert all into local db
    for (var instance in endpointInstances) {
      await storage.upsertInstance(instance);
    }

    return SyncResult<TSyncable>(successful, endpointResults);
  }
}
