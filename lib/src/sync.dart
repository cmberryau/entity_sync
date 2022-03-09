import 'dart:io';

import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/src/endpoints.dart';
import 'package:entity_sync/src/serialization.dart';
import 'package:entity_sync/src/storage.dart';

/// Added to a class to support syncing
/// Syncable classes also must be serializable
abstract class SyncableMixin implements SerializableMixin {
  /// The unique syncable key of the entity
  late SerializableField keyField;

  /// The flag to indicate the entity needs to be synced
  late BoolField flagField;

  /// The unique remote syncable key of the entity
  late SerializableField remoteKeyField = StringField('uuid', source: 'uuid');

  /// Gets the key field of the entity
  SerializableField getKeyField() {
    return keyField;
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
    aMap.remove(aKeyField.name);

    bMap.remove(bKeyField.name);

    final aFlagField = flagField;
    final bFlagField = other.flagField;

    // remove the flag fields
    aMap.remove(aFlagField.name);
    bMap.remove(bFlagField.name);

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

  @override
  String toString() {
    return 'SyncResult(pushResults: $pushResults, pullResults: $pullResults)';
  }
}

/// Responsible for controlling the syncing of entities
class SyncController<TSyncable extends SyncableMixin> {
  /// The endpoint for syncing
  final Endpoint<TSyncable> endpoint;

  /// The storage for syncing
  final Storage<TSyncable> storage;

  final List<SyncControllerRelation> relations;

  /// The default instances when there are no instances or errors from the server
  final List<TSyncable> defaultInstances;

  SyncController(
    this.endpoint,
    this.storage, {
    this.relations = const [],
    this.defaultInstances = const [],
  });

  Future<SyncResult<TSyncable>> sync([DateTime? since]) async {
    /// get all instances to sync
    final toSyncInstances = await storage.getInstancesToSync();

    /// push all instances to sync to endpoint
    final endpointResults = await push(toSyncInstances);

    /// pull all from endpoint since last sync
    final endpointPullAll = await endpoint.pullAll(since: since);

    if (defaultInstances.isNotEmpty) {
      // sub in the default instances if the storage is empty and no data on the response
      if (endpointPullAll.instances.isEmpty && await storage.isEmpty()) {
        for (final instance in defaultInstances) {
          await storage.insert(instance);
        }
      }
      // remove the default instances
      else if (endpointPullAll.instances.isNotEmpty &&
          !(await storage.isEmpty()) &&
          (await storage.containsOnlyInstances(defaultInstances))) {
        await storage.clear();
      }
    }

    /// Insert all into local db
    for (final instance in endpointPullAll.instances) {
      /// Check if local storage has the instance
      final localInstance = await storage.get(
        remoteKey: instance.getRemoteKey(),
      );

      var isChanged = false;

      /// New instance, insert it
      if (localInstance == null) {
        await storage.insert(
          instance,
        );

        isChanged = true;
      } else if (!localInstance.isDataEqualTo(instance)) {
        /// Existing instance, update it if it differs
        await storage.update(instance, remoteKey: instance.getRemoteKey());
        isChanged = true;
      }

      // if the entity is changed then update all of its relation
      if (isChanged) {
        for (final relation in relations) {
          // get the uuid of the missing related instance
          var remoteKey = await relation.relation.needToSyncInstance(instance);

          // if the related instance is missing then sync it
          if (remoteKey != null) {
            // pull down the related instance
            final endpointResult = await relation.endpoint.pullByRemoteKey(
              remoteKey: remoteKey,
            );

            // insert the related instance to the storage
            if (endpointResult.instances.isNotEmpty) {
              await relation.storage.insert(endpointResult.instances.first);
            }
          }
        }
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

/// Relation between sync controller
class SyncControllerRelation {
  /// The relationship to other sync controller
  final Relation relation;

  /// The endpoint of the other controller
  final Endpoint endpoint;

  /// The storage of other controller
  final Storage storage;

  SyncControllerRelation(this.relation, this.endpoint, this.storage);

  @override
  String toString() {
    return 'SyncControllerRelation(relation: $relation, endpoint: $endpoint, storage: $storage';
  }
}
