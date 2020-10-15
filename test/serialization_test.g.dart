// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serialization_test.dart';

// **************************************************************************
// UseEntitySyncGenerator
// **************************************************************************

class TestEntityProxy extends TestEntity with SyncableMixin, SerializableMixin {
  TestEntityProxy({
    int id,
    String name,
    DateTime created,
    bool shouldSync,
  }) : super(
          id: id,
          name: name,
          created: created,
          shouldSync: shouldSync,
        );
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created': created,
      'shouldSync': shouldSync,
    };
  }

  @override
  TestEntityProxy copyFromMap(Map<String, dynamic> data) {
    return TestEntityProxy(
      id: data['id'],
      name: data['name'],
      created: data['created'],
      shouldSync: data['shouldSync'],
    );
  }

  final keyField = IntegerField('id', source: 'id');
  final remoteKeyField = null;
  final flagField = BoolField('shouldSync', source: 'shouldSync');
  TestEntityProxy.fromEntity(TestEntity instance)
      : super(
          id: instance.id,
          name: instance.name,
          created: instance.created,
          shouldSync: instance.shouldSync,
        );
}

class TestEntitySerializer extends Serializer<TestEntityProxy> {
  TestEntitySerializer(
      {Map<String, dynamic> data, TestEntityProxy instance, String prefix = ''})
      : super(data: data, instance: instance, prefix: prefix);

  @override
  final fields = [
    IntegerField('id', source: 'id'),
    StringField('name', source: 'name'),
    DateTimeField('created', source: 'created'),
  ];
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
      'validateId': validateId,
      'validateName': validateName,
      'validateCreated': validateCreated,
    };
  }

  @override
  TestEntityProxy createInstance(Map<String, dynamic> data) {
    return TestEntityProxy(
      id: data['id'],
      name: data['name'],
      created: data['created'],
      shouldSync: false,
    );
  }
}

class $_TestEntityEntitySync {}
