import 'package:test/test.dart';

import 'package:entity_sync/entity_sync.dart';

part 'serialization_test.g.dart';

class TestEntity {
  final int id;
  final String name;
  final DateTime created;
  final bool shouldSync;

  TestEntity(this.id, this.name, this.created, {this.shouldSync});
}

/// An entity which is serializable via SerializableMixin
@UseSerialization(TestEntity)
class TestEntityProxy extends $_TestEntityProxy with SyncableMixin {
  @override
  SerializableField keyField = IntegerField('id');

  @override
  SerializableField flagField = BoolField('shouldSync');

  TestEntityProxy(int id, String name, DateTime created,
      {bool shouldSync = false})
      : super(id, name, created, shouldSync: shouldSync);
}

/// A serializer for TestEntity
@IsSerializer(TestEntityProxy, fields: [
  IntegerField('id'),
  StringField('name'),
  DateTimeField('created'),
])
class TestEntitySerializer extends $_TestEntitySerializer {
  TestEntitySerializer({Map<String, dynamic> data, TestEntityProxy instance})
      : super(data: data, instance: instance);

  @override
  int validateId(int value) {
    if (value < 0) {
      throw ValidationException('id must be positive value');
    }

    return value;
  }

  @override
  String validateName(String value) {
    if (value == null) {
      throw ValidationException('name must not be null');
    }

    if (value.isEmpty) {
      throw ValidationException('name must not be empty');
    }

    return value;
  }

  @override
  DateTime validateCreated(DateTime value) {
    if (value == null) {
      throw ValidationException('created must not be null');
    }

    return value;
  }

  @override
  TestEntityProxy createInstance(validatedData) {
    return TestEntityProxy(
        validatedData['id'], validatedData['name'], validatedData['created']);
  }
}

void main() {
  group('Test Serializer', () {
    setUp(() {});

    test('Test TestEntitySerializer.isValid method with valid entity', () {
      final entity = TestEntityProxy(0, 'TestName', DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isTrue);
    });

    test('Test TestEntitySerializer.isValid method with invalid entity', () {
      var entity = TestEntityProxy(0, null, DateTime.now());
      var serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntityProxy(0, '', DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntityProxy(-1, 'TestName', DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntityProxy(0, 'TestName', null);
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);
    });

    test('Test TestEntitySerializer.toJson method with valid entity', () {
      final entity = TestEntityProxy(0, 'TestName', DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      final repr = serializer.toRepresentationString();

      expect(repr, isNotNull);
      expect(repr, isNotEmpty);
    });
  });
}
