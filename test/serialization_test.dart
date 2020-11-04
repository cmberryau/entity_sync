import 'package:test/test.dart';

import 'package:entity_sync/entity_sync.dart';

class TestEntity with SerializableMixin, SyncableMixin {
  final int id;
  final String name;
  final DateTime created;
  final bool shouldSync;

  /// The unique syncable key of the entity
  final keyField = IntegerField('id');

  /// The flag to indicate the entity needs to be synced
  final flagField = BoolField('shouldSync');

  TestEntity({this.id, this.name, this.created, this.shouldSync});

  @override
  SerializableMixin copyFromMap(Map<String, dynamic> mapData) {
    return TestEntity(
      id: mapData['id'],
      name: mapData['name'],
      created: mapData['created'],
      shouldSync: mapData['shouldSync'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created': created,
      'shouldSync': shouldSync,
    };
  }
}

class TestEntitySerializer extends Serializer<TestEntity> {
  TestEntitySerializer(
      {Map<String, dynamic> data, TestEntity instance})
      : super(data: data, instance: instance);

  @override
  final fields = [
    IntegerField('id', source: 'id'),
    StringField('name', source: 'name'),
    DateTimeField('created', source: 'created'),
  ];

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
  TestEntity createInstance(Map<String, dynamic> validatedData) {
    return TestEntity(
      id: validatedData['id'],
      name: validatedData['name'],
      created: validatedData['created'],
      shouldSync: false,
    );
  }

  @override
  Map toMap() {
    return {
      'validateId': validateId,
      'validateName': validateName,
      'validateCreated': validateCreated,
    };
  }
}

void main() {
  group('Test Serializer', () {
    setUp(() {});

    test('Test TestEntitySerializer.isValid method with valid entity', () {
      final entity = TestEntity(id: 0, name: 'TestName', created: DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isTrue);
    });

    test('Test TestEntitySerializer.isValid method with invalid entity', () {
      var entity = TestEntity(id: 0, name: null, created: DateTime.now());
      var serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(id: 0, name: '', created: DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(id: -1, name: 'TestName', created: DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(id: 0, name: 'TestName', created: null);
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);
    });

    test('Test TestEntitySerializer.toJson method with valid entity', () {
      final entity = TestEntity(id: 0, name: 'TestName', created: DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      final repr = serializer.toRepresentationString();

      // expect(repr, isNotNull);
      expect(repr, isNotEmpty);
    });
  });
}
