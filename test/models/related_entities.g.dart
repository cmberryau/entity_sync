// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_entities.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
class FirstRelatedEntityProxy extends FirstRelatedEntitiesCompanion
    with ProxyMixin<FirstRelatedEntity>, SyncableMixin, SerializableMixin {
  FirstRelatedEntityProxy({
    Value<bool> shouldSync = const Value.absent(),
    Value<String> uuid = const Value.absent(),
    Value<int> id = const Value.absent(),
    Value<String> relatedEntity = const Value.absent(),
  }) : super(
          shouldSync: shouldSync,
          uuid: uuid,
          id: id,
          relatedEntity: relatedEntity,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync.value,
      'uuid': uuid.value,
      'id': id.value,
      'relatedEntity': relatedEntity.value,
    };
  }

  @override
  FirstRelatedEntityProxy copyFromMap(Map<String, dynamic> data) {
    return FirstRelatedEntityProxy(
      shouldSync: Value<bool>(data['shouldSync']),
      uuid: Value<String>(data['uuid']),
      id: Value<int>(data['id']),
      relatedEntity: Value<String>(data['relatedEntity']),
    );
  }

  @override
  final keyField = IntegerField('id', source: 'id');
  @override
  final remoteKeyField = StringField('uuid', source: 'uuid');
  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');
  factory FirstRelatedEntityProxy.fromEntity(FirstRelatedEntity instance) {
    return FirstRelatedEntityProxy(
      shouldSync: Value<bool>(instance.shouldSync),
      uuid: Value<String>(instance.uuid),
      id: Value<int>(instance.id),
      relatedEntity: Value<String>(instance.relatedEntity),
    );
  }
}

class BaseFirstRelatedEntitySerializer
    extends Serializer<FirstRelatedEntityProxy> {
  BaseFirstRelatedEntitySerializer(
      {Map<String, dynamic>? data,
      FirstRelatedEntityProxy? instance,
      String prefix = ''})
      : super(data: data, instance: instance, prefix: prefix);

  @override
  final fields = [
    StringField('uuid', source: 'uuid'),
    IntegerField('id', source: 'id'),
    StringField('relatedEntity', source: 'relatedEntity'),
  ];
  String? validateUuid(String? value) {
    return value;
  }

  int? validateId(int? value) {
    return value;
  }

  String? validateRelatedEntity(String? value) {
    return value;
  }

  @override
  Map toMap() {
    return {
      'validateUuid': validateUuid,
      'validateId': validateId,
      'validateRelatedEntity': validateRelatedEntity,
    };
  }

  @override
  FirstRelatedEntityProxy createInstance(Map<String, dynamic> data) {
    return FirstRelatedEntityProxy(
      uuid: Value<String>(data['uuid']),
      id: Value<int>(data['id']),
      relatedEntity: Value<String>(data['relatedEntity']),
      shouldSync: Value<bool>(false),
    );
  }
}

class FirstRelatedEntityProxyFactory
    extends ProxyFactory<FirstRelatedEntityProxy, FirstRelatedEntity> {
  @override
  FirstRelatedEntityProxy fromInstance(FirstRelatedEntity instance) {
    return FirstRelatedEntityProxy.fromEntity(instance);
  }
}

class $_FirstRelatedEntitySync {}

// ignore_for_file: non_constant_identifier_names
class SecondRelatedEntityProxy extends SecondRelatedEntitiesCompanion
    with ProxyMixin<SecondRelatedEntity>, SyncableMixin, SerializableMixin {
  SecondRelatedEntityProxy({
    Value<bool> shouldSync = const Value.absent(),
    Value<String> uuid = const Value.absent(),
    Value<int> id = const Value.absent(),
  }) : super(
          shouldSync: shouldSync,
          uuid: uuid,
          id: id,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync.value,
      'uuid': uuid.value,
      'id': id.value,
    };
  }

  @override
  SecondRelatedEntityProxy copyFromMap(Map<String, dynamic> data) {
    return SecondRelatedEntityProxy(
      shouldSync: Value<bool>(data['shouldSync']),
      uuid: Value<String>(data['uuid']),
      id: Value<int>(data['id']),
    );
  }

  @override
  final keyField = IntegerField('id', source: 'id');
  @override
  final remoteKeyField = StringField('uuid', source: 'uuid');
  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');
  factory SecondRelatedEntityProxy.fromEntity(SecondRelatedEntity instance) {
    return SecondRelatedEntityProxy(
      shouldSync: Value<bool>(instance.shouldSync),
      uuid: Value<String>(instance.uuid),
      id: Value<int>(instance.id),
    );
  }
}

class BaseSecondRelatedEntitySerializer
    extends Serializer<SecondRelatedEntityProxy> {
  BaseSecondRelatedEntitySerializer(
      {Map<String, dynamic>? data,
      SecondRelatedEntityProxy? instance,
      String prefix = ''})
      : super(data: data, instance: instance, prefix: prefix);

  @override
  final fields = [
    StringField('uuid', source: 'uuid'),
    IntegerField('id', source: 'id'),
  ];
  String? validateUuid(String? value) {
    return value;
  }

  int? validateId(int? value) {
    return value;
  }

  @override
  Map toMap() {
    return {
      'validateUuid': validateUuid,
      'validateId': validateId,
    };
  }

  @override
  SecondRelatedEntityProxy createInstance(Map<String, dynamic> data) {
    return SecondRelatedEntityProxy(
      uuid: Value<String>(data['uuid']),
      id: Value<int>(data['id']),
      shouldSync: Value<bool>(false),
    );
  }
}

class SecondRelatedEntityProxyFactory
    extends ProxyFactory<SecondRelatedEntityProxy, SecondRelatedEntity> {
  @override
  SecondRelatedEntityProxy fromInstance(SecondRelatedEntity instance) {
    return SecondRelatedEntityProxy.fromEntity(instance);
  }
}

class $_SecondRelatedEntitySync {}
