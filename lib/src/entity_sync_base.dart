/// Represents a syncable endpoint
abstract class Endpoint {

}

/// Represents a django rest framework api as a syncable endpoint
class DjangoRestFrameworkApi extends Endpoint {
  String url;

  DjangoRestFrameworkApi(String url);
}

/// Represents a field which may be serialized
class SerializableField {
  /// The name of the field
  String name;
  /// The type of the field
  Type type;

  SerializableField(this.name, this.type);

  /// Evaluates if the passed value is valid
  bool isValid(dynamic value) {
    return true;
  }
}

/// Added to a class to support serialization
abstract class SerializableMixin {
  // TODO: replace getFieldValue with reflection
  Future<dynamic> getFieldValue(String fieldName);
}

mixin ValidationException implements Exception {

}

/// Performs serialization
abstract class Serializer {
  SerializableMixin instance;
  Map<String, dynamic> data;

  Serializer({this.data, this.instance}) {
    if(getFields() == null) {
      throw AbstractClassInstantiationError((Serializer).toString());
    }
  }

  /// Gets all fields for serialization
  Future<List<SerializableField>> getFields();

  /// Determines if the serializer is valid
  Future<bool> isValid() async {
    final exceptions = <ValidationException>[];

    final fields = await getFields();
    for (final field in fields) {
      dynamic value;

      if (instance != null) {
        value = await instance.getFieldValue(field.name);
      } else if (data != null) {
        value = data[field.name];
      } else {
        return false;
      }

      try {
        await isFieldValid(field.name, value);
      } on ValidationException catch(e) {
        exceptions.add(e);
      }
    }

    return exceptions.isEmpty;
  }

  /// Determines if a single field is valid
  // TODO: replace getFieldValue with reflection
  Future<bool> isFieldValid(String fieldName, dynamic value);
}
