// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_entities.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
class TestMoorEntityProxy extends TestMoorEntitiesCompanion
    with ProxyMixin<TestMoorEntity>, SyncableMixin, SerializableMixin {
  TestMoorEntityProxy({
    Value<bool> shouldSync = const Value.absent(),
    Value<String?> uuid = const Value.absent(),
    Value<int> id = const Value.absent(),
    Value<String> name = const Value.absent(),
    Value<DateTime> created = const Value.absent(),
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
      'shouldSync': shouldSync.value,
      'uuid': uuid.value,
      'id': id.value,
      'name': name.value,
      'created': created.value,
    };
  }

  @override
  TestMoorEntityProxy copyFromMap(Map<String, dynamic> data) {
    return TestMoorEntityProxy(
      shouldSync: Value<bool>(data['shouldSync']),
      uuid: Value<String?>(data['uuid']),
      id: Value<int>(data['id']),
      name: Value<String>(data['name']),
      created: Value<DateTime>(data['created']),
    );
  }

  @override
  final keyField = IntegerField('id', source: 'id');
  @override
  final remoteKeyField = StringField('remote_uuid', source: 'remote_uuid');
  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');
  factory TestMoorEntityProxy.fromEntity(TestMoorEntity instance) {
    return TestMoorEntityProxy(
      shouldSync: Value<bool>(instance.shouldSync),
      uuid: Value<String?>(instance.uuid),
      id: Value<int>(instance.id),
      name: Value<String>(instance.name),
      created: Value<DateTime>(instance.created),
    );
  }
}

class BaseTestMoorEntitySerializer extends Serializer<TestMoorEntityProxy> {
  BaseTestMoorEntitySerializer(
      {Map<String, dynamic>? data,
      TestMoorEntityProxy? instance,
      String prefix = ''})
      : super(data: data, instance: instance, prefix: prefix);

  @override
  final fields = [
    StringField('uuid', source: 'uuid'),
    IntegerField('id', source: 'id'),
    StringField('name', source: 'name'),
    DateTimeField('created', source: 'created'),
  ];
  String? validateUuid(String? value) {
    return value;
  }

  int? validateId(int? value) {
    return value;
  }

  String? validateName(String? value) {
    return value;
  }

  DateTime? validateCreated(DateTime? value) {
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
      uuid: Value<String?>(data['uuid']),
      id: Value<int>(data['id']),
      name: Value<String>(data['name']),
      created: Value<DateTime>(data['created']),
      shouldSync: Value<bool>(false),
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
