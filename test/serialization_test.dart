import 'package:entity_sync/entity_sync.dart';
import 'package:test/test.dart';

part 'serialization_test.g.dart';

class TestEntity {
  final int id;
  final String name;
  final DateTime created;
  final bool shouldSync;

  TestEntity({this.id, this.name, this.created, this.shouldSync});
}

@UseEntitySync(
  TestEntity,
  fields: [
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ],
  keyField: IntegerField('id'),
  flagField: BoolField('shouldSync'),
  remoteKeyField: null,
)
class TestEntityEntitySync extends $_TestEntityEntitySync {}

class CustomTestEntitySerializer extends TestEntitySerializer {
  CustomTestEntitySerializer(
      {Map<String, dynamic> data, TestEntityProxy instance})
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
}

void main() {
  group('Test Serializer', () {
    setUp(() {});

    test('Test TestEntitySerializer.isValid method with valid entity', () {
      final entity =
          TestEntityProxy(id: 0, name: 'TestName', created: DateTime.now());
      final serializer = CustomTestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isTrue);
    });

    test('Test TestEntitySerializer.isValid method with invalid entity', () {
      var entity = TestEntityProxy(id: 0, name: null, created: DateTime.now());
      var serializer = CustomTestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntityProxy(id: 0, name: '', created: DateTime.now());
      serializer = CustomTestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity =
          TestEntityProxy(id: -1, name: 'TestName', created: DateTime.now());
      serializer = CustomTestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);

      entity = TestEntityProxy(id: 0, name: 'TestName', created: null);
      serializer = CustomTestEntitySerializer(instance: entity);

      expect(serializer.isValid(), isFalse);
    });

    test('Test TestEntitySerializer.toJson method with valid entity', () {
      final entity =
          TestEntityProxy(id: 0, name: 'TestName', created: DateTime.now());
      final serializer = CustomTestEntitySerializer(instance: entity);

      final repr = serializer.toRepresentationString();

      expect(repr, isNotNull);
      expect(repr, isNotEmpty);
    });
  });
}
