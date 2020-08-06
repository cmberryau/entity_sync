import 'package:entity_sync/entity_sync.dart';
import 'package:test/test.dart';

class TestEntity with SerializableMixin{
  int id;
  String name;
  DateTime created;

  TestEntity(this.id, this.name, this.created);

  @override
  Future getFieldValue(String fieldName) async {
    if (fieldName == 'id') {
      return id;
    }

    if (fieldName == 'name') {
      return name;
    }

    if (fieldName == 'created') {
      return created;
    }
  }
}

class TestEntitySerializer extends Serializer {
  final fields = <SerializableField>[
    SerializableField('id', int),
    SerializableField('name', String),
    SerializableField('created', DateTime),
  ];

  TestEntitySerializer({Map<String, dynamic>data, SerializableMixin instance})
      : super(data: data, instance: instance);

  @override
  Future<List<SerializableField>> getFields() async {
    return fields;
  }

  @override
  Future<bool> isFieldValid(String fieldName, value) async {
    if(fieldName == 'id') {
      return isIdValid(value);
    }

    if(fieldName == 'name') {
      return isNameValid(value);
    }

    if(fieldName == 'created') {
      return isCreatedValid(value);
    }

    throw ArgumentError('No matching field found');
  }

  Future<bool> isIdValid(int value) async {
    return value > -1;
  }

  Future<bool> isNameValid(String value) async {
    return value != null && value.isNotEmpty;
  }

  Future<bool> isCreatedValid(DateTime value) async {
    return value != null;
  }
}

void main() {
  group('TestEntitySerializer tests', () {
    setUp(() {

    });

    test('Test TestEntitySerializer.isValid method', () async {
      final entity = TestEntity(0, 'TestName', DateTime.now());
      final serializer = TestEntitySerializer(instance: entity);

      expect(await serializer.isValid(), isTrue);
    });
  });
}
