A entity sync library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

```dart
import 'package:entity_sync/entity_sync.dart';

class TestEntity with SerializableMixin{
  int id;
  String name;
  DateTime created;

  TestEntity(this.id, this.name, this.created);
}
class TestEntitySerializer extends Serializer {
  final fields = <SerializableField>[
    SerializableField('id', int),
    SerializableField('name', String),
    SerializableField('created', DateTime),
  ];

  TestEntitySerializer({Map<String, dynamic>data, SerializableMixin instance})
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
}


main() {
  final entity = TestEntity(0, 'TestName', DateTime.now());
  final serializer = TestEntitySerializer(instance: entity);

  final valid = serializer.isValid();
  final json = serializer.toJson();
}
```
