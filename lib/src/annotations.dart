import 'package:entity_sync/entity_sync.dart';

class UseSerialization {
  final Type baseClass;

  const UseSerialization(this.baseClass) : assert(baseClass != null);
}

class IsSerializer {
  final Type proxyClass;
  final List<SerializableField> fields;

  const IsSerializer(this.proxyClass, {this.fields = const []})
      : assert(proxyClass != null),
        assert(fields != null);
}
