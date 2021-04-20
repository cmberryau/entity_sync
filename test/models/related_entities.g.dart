// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'related_entities.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
class FirstRelatedEntityProxy extends FirstRelatedEntity
    with ProxyMixin<FirstRelatedEntity>, SyncableMixin, SerializableMixin {
  FirstRelatedEntityProxy({
    required bool shouldSync,
    required String uuid,
    required int id,
    required String relatedEntity,
  }) : super(
          shouldSync: shouldSync,
          uuid: uuid,
          id: id,
          relatedEntity: relatedEntity,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync,
      'uuid': uuid,
      'id': id,
      'relatedEntity': relatedEntity,
    };
  }

  @override
  FirstRelatedEntityProxy copyFromMap(Map<String, dynamic> data) {
    return FirstRelatedEntityProxy(
      shouldSync: data['shouldSync'],
      uuid: data['uuid'],
      id: data['id'],
      relatedEntity: data['relatedEntity'],
    );
  }

  @override
  final keyField = IntegerField('id', source: 'id');

  @override
  final remoteKeyField = StringField('uuid', source: 'uuid');

  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');

  FirstRelatedEntityProxy.fromEntity(FirstRelatedEntity instance)
      : super(
          shouldSync: instance.shouldSync,
          uuid: instance.uuid,
          id: instance.id,
          relatedEntity: instance.relatedEntity,
        );
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
      uuid: data['uuid'],
      id: data['id'],
      relatedEntity: data['relatedEntity'],
      shouldSync: false,
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
class SecondRelatedEntityProxy extends SecondRelatedEntity
    with ProxyMixin<SecondRelatedEntity>, SyncableMixin, SerializableMixin {
  SecondRelatedEntityProxy({
    required bool shouldSync,
    required String uuid,
    required int id,
  }) : super(
          shouldSync: shouldSync,
          uuid: uuid,
          id: id,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync,
      'uuid': uuid,
      'id': id,
    };
  }

  @override
  SecondRelatedEntityProxy copyFromMap(Map<String, dynamic> data) {
    return SecondRelatedEntityProxy(
      shouldSync: data['shouldSync'],
      uuid: data['uuid'],
      id: data['id'],
    );
  }

  @override
  final keyField = IntegerField('id', source: 'id');

  @override
  final remoteKeyField = StringField('uuid', source: 'uuid');

  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');

  SecondRelatedEntityProxy.fromEntity(SecondRelatedEntity instance)
      : super(
          shouldSync: instance.shouldSync,
          uuid: instance.uuid,
          id: instance.id,
        );
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
      uuid: data['uuid'],
      id: data['id'],
      shouldSync: false,
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
