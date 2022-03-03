import 'package:entity_sync/entity_sync.dart';

class UseEntitySync {
  final Type baseClass;
  final Type dataClass;
  final List<SerializableField> fields;
  final SerializableField? keyField;
  final SerializableField? flagField;
  final SerializableField? remoteKeyField;

  const UseEntitySync(
    this.dataClass,
    this.baseClass, {
    this.fields = const [],
    this.keyField,
    this.flagField,
    this.remoteKeyField,
  });
}
