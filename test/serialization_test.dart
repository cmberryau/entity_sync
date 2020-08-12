import 'package:test/test.dart';

import 'package:entity_sync/entity_sync.dart';


/// An entity which is serializable via SerializableMixin
class TestEntity with SerializableMixin, SyncableMixin {
  int id;
  String name;
  DateTime created;
  bool shouldSync;

  /// The unique syncable key of the entity
  final keyField = IntegerField('id');
  /// The flag to indicate the entity needs to be synced
  final flagField = BoolField('shouldSync');

  TestEntity(this.id, this.name, this.created);
}

/// A serializer for TestEntity
class TestEntitySerializer extends Serializer<TestEntity> {
  final fields = <SerializableField>[
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ];

  TestEntitySerializer({Map<String, dynamic>data, TestEntity instance})
      : super(data: data, instance: instance);

  int validateId(int value) {
    if (value < 0) {
      throw ValidationException('id must be positive value');
    }

    return value;
  }

  String validateName(String value) {
    if (value == null) {
      throw ValidationException('name must not be null');
    }

    if (value.isEmpty) {
      throw ValidationException('name must not be empty');
    }

    return value;
  }

  DateTime validateCreated(DateTime value) {
    if (value == null) {
      throw ValidationException('created must not be null');
    }

    return value;
  }

  @override
  TestEntity createInstance(validatedData) {
    return TestEntity(validatedData['id'],
                      validatedData['name'],
                      validatedData['created']);
  }
}

void main() {
  group('Test Serializer', () {
    setUp(() {

    });

    test('Test TestEntitySerializer.isValid method with valid entity', () {
      final entity = TestEntity(0, 'TestName', DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isTrue);
    });

    test('Test TestEntitySerializer.isValid method with invalid entity', () {
      var entity = TestEntity(0, null, DateTime.now());
      var serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(0, '', DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(-1, 'TestName', DateTime.now());
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntity(0, 'TestName', null);
      serializer = TestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);
    });

    test('Test TestEntitySerializer.toJson method with valid entity', () {
      final entity = TestEntity(0, 'TestName', DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      final repr = serializer.toRepresentationString();

      expect(serializer.toRepresentationString(), isNotNull);
      expect(serializer.toRepresentationString(), isNotEmpty);
    });
  });
}
