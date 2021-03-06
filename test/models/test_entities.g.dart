// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entities.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

class TestMoorEntityProxy extends TestMoorEntity
    with ProxyMixin<TestMoorEntity>, SyncableMixin, SerializableMixin {
  TestMoorEntityProxy({
    bool shouldSync,
    String uuid,
    int id,
    String name,
    DateTime created,
  }) : super(
          shouldSync: shouldSync,
          uuid: uuid,
          id: id,
          name: name,
          created: created,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync,
      'uuid': uuid,
      'id': id,
      'name': name,
      'created': created,
      'hashCode': hashCode,
    };
  }

  @override
  TestMoorEntityProxy copyFromMap(Map<String, dynamic> data) {
    return TestMoorEntityProxy(
      shouldSync: data['shouldSync'],
      uuid: data['uuid'],
      id: data['id'],
      name: data['name'],
      created: data['created'],
    );
  }

  final keyField = IntegerField('id', source: 'id');
  final remoteKeyField = StringField('remote_uuid', source: 'remote_uuid');
  final flagField = null;
  TestMoorEntityProxy.fromEntity(TestMoorEntity instance)
      : super(
          shouldSync: instance.shouldSync,
          uuid: instance.uuid,
          id: instance.id,
          name: instance.name,
          created: instance.created,
        );
}

class TestMoorEntitySerializer extends Serializer<TestMoorEntityProxy> {
  TestMoorEntitySerializer(
      {Map<String, dynamic> data,
      TestMoorEntityProxy instance,
      String prefix = ''})
      : super(data: data, instance: instance, prefix: prefix);

  @override
  final fields = [
    StringField('uuid', source: 'uuid'),
    IntegerField('id', source: 'id'),
    StringField('name', source: 'name'),
    DateTimeField('created', source: 'created'),
  ];
  String validateUuid(String value) {
    return value;
  }

  int validateId(int value) {
    return value;
  }

  String validateName(String value) {
    return value;
  }

  DateTime validateCreated(DateTime value) {
    return value;
  }

  @override
  Map toMap() {
    return {
      'validateUuid': validateUuid,
      'validateId': validateId,
      'validateName': validateName,
      'validateCreated': validateCreated,
    };
  }

  @override
  TestMoorEntityProxy createInstance(Map<String, dynamic> data) {
    return TestMoorEntityProxy(
      uuid: data['uuid'],
      id: data['id'],
      name: data['name'],
      created: data['created'],
      shouldSync: false,
    );
  }
}

class TestMoorEntityProxyFactory
    extends ProxyFactory<TestMoorEntityProxy, TestMoorEntity> {
  @override
  TestMoorEntityProxy fromInstance(TestMoorEntity instance) {
    return TestMoorEntityProxy.fromEntity(instance);
  }
}

class $_TestMoorEntitySync {}
