// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entities.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

class TestMoorEntityProxy extends TestMoorEntity
    with ProxyMixin<TestMoorEntity>, SyncableMixin, SerializableMixin {
  TestMoorEntityProxy({
    bool shouldSync,
    String remote_uuid,
    int id,
    String name,
    DateTime created,
  }) : super(
          shouldSync: shouldSync,
          remote_uuid: remote_uuid,
          id: id,
          name: name,
          created: created,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'shouldSync': shouldSync,
      'remote_uuid': remote_uuid,
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
      remote_uuid: data['remote_uuid'],
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
          remote_uuid: instance.remote_uuid,
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
    StringField('remote_uuid', source: 'remote_uuid'),
    IntegerField('id', source: 'id'),
    StringField('name', source: 'name'),
    DateTimeField('created', source: 'created'),
  ];
  String validateRemote_uuid(String value) {
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
      'validateRemote_uuid': validateRemote_uuid,
      'validateId': validateId,
      'validateName': validateName,
      'validateCreated': validateCreated,
    };
  }

  @override
  TestMoorEntityProxy createInstance(Map<String, dynamic> data) {
    return TestMoorEntityProxy(
      remote_uuid: data['remote_uuid'],
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
