import 'dart:io';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/src/endpoints.dart';
import 'package:entity_sync/src/serialization.dart';
import 'package:entity_sync/src/storage.dart';

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// The unique syncable key of the entity
  SerializableField keyField;

  /// The flag to indicate the entity needs to be synced
  SerializableField flagField;

  /// The unique remote syncable key of the entity
  SerializableField remoteKeyField = StringField('uuid');

  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return keyField;
  }

  /// Gets the remote key field of the entity
  SerializableField getRemoteKeyField() {
    return remoteKeyField;
  }

  /// Gets the flag field of the entity
  BoolField getFlagField() {
    return flagField;
  }

  /// Gets the key value of the entity
  dynamic getKeyValue(SerializableField keyField) {
    return toMap()[keyField.name];
  }

  // Gets the local key value
  dynamic getLocalKey() {
    return getKeyValue(keyField);
  }

  // Gets the remote key value
  dynamic getRemoteKey() {
    return getKeyValue(remoteKeyField);
  }

  /// Gets the flag value of the entity
  bool getFlagValue(BoolField flagField) {
    return toMap()[flagField.name];
  }

  /// Gets the representation of the key of the entity
  dynamic getKeyRepresentation() {
    final keyField = getKeyField();
    final keyValue = getKeyValue(keyField);

    return keyField.toRepresentation(keyValue);
  }

  /// Evaluates syncable entity is equal to another
  bool isDataEqualTo<TSyncable extends SyncableMixin>(TSyncable other) {
    final aMap = toMap();
    final bMap = other.toMap();

    // remove the hashcodes
    aMap.remove('hashCode');
    bMap.remove('hashCode');

    final aKeyField = getKeyField();
    final bKeyField = other.getKeyField();

    // remove the key fields
    if (aKeyField != null) {
      aMap.remove(aKeyField.name);
    }

    if (bKeyField != null) {
      bMap.remove(bKeyField.name);
    }

    final aFlagField = getFlagField();
    final bFlagField = other.getFlagField();

    // remove the flag fields
    if (aFlagField != null) {
      aMap.remove(aFlagField.name);
    }

    if (bFlagField != null) {
      bMap.remove(bFlagField.name);
    }

    final equal = aMap == bMap;
    return equal;
  }

  @override
  dynamic getFieldValue(String fieldName);
}

/// Represents the result of a sync operation
class SyncResult<TSyncable extends SyncableMixin> {
  final List<EndpointResult<TSyncable>> pushResults;
  final EndpointResult<TSyncable> pullResults;

  SyncResult(this.pushResults, this.pullResults);
}

/// Responsible for controlling the syncing of entities
class SyncController<TSyncable extends SyncableMixin> {
  /// The endpoint for syncing
  final Endpoint<TSyncable> endpoint;

  /// The storage for syncing
  final Storage<TSyncable> storage;

  SyncController(this.endpoint, this.storage);

  Future<SyncResult<TSyncable>> sync([DateTime since]) async {
    /// get all instances to sync
    final toSyncInstances = await storage.getInstancesToSync();

    /// push all instances to sync to endpoint
    final endpointResults = await push(toSyncInstances);

    /// pull all from endpoint since last sync
    final endpointPullAll = await endpoint.pullAll(since: since);

    /// Insert all into local db
    for (final instance in endpointPullAll.instances) {
      /// Check if local storage has the instance
      final localInstance =
          await storage.get(remoteKey: instance.getRemoteKey());

      /// New instance, insert it
      if (localInstance == null) {
        await storage.insert(
          instance,
        );
      } else if (!localInstance.isDataEqualTo(instance)) {
        /// Existing instance, update it if it differs
        await storage.update(instance, remoteKey: instance.getRemoteKey());
      }
    }

    return SyncResult<TSyncable>(endpointResults, endpointPullAll);
  }

  Future<List<EndpointResult<TSyncable>>> push(
    Iterable<TSyncable> instances,
  ) async {
    final results = <EndpointResult<TSyncable>>[];

    /// push to endpoint
    for (final instanceToPush in instances) {
      final endpointResult = endpoint.readOnly
          ? await endpoint.pull(instanceToPush)
          : await endpoint.push(instanceToPush);

      /// save the endpoint results for the sync result
      results.add(endpointResult);
      if (endpointResult.successful) {
        if (endpointResult.instances.isNotEmpty) {
          if (endpointResult.instances.length > 1) {
            endpointResult.addError(HttpException(
              'Push result of an entity should only return only one entity.',
            ));
          }

          final returnedInstance = endpointResult.instances[0];
          print(returnedInstance);
          /// Compare data equality, ignoring local keys
          if (!instanceToPush.isDataEqualTo(returnedInstance)) {
            /// We have a local key because we pushed
            await storage.update(
              returnedInstance,
              localKey: instanceToPush.getLocalKey(),
            );
          }
        } else {
          endpointResult.addError(HttpException('Push result is null.'));
        }
      } else {
        endpointResult.addError(HttpException('Push is unsuccessful.'));
      }
    }

    return results;
  }
}
