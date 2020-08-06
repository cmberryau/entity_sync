import 'dart:mirrors';


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
  dynamic getFieldValue(String fieldName) {
    return reflect(this).getField(Symbol(fieldName)).reflectee;
  }
}

class ValidationException implements Exception {
  String cause;
  ValidationException(this.cause);
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
        value = instance.getFieldValue(field.name);
      } else if (data != null) {
        value = data[field.name];
      } else {
        return false;
      }

      try {
        validateField(field.name, value);
      } on ValidationException catch(e) {
        exceptions.add(e);
      }
    }

    return exceptions.isEmpty;
  }

  dynamic validateField(String fieldName, dynamic value) {
    /// Get a mirror for the concrete instance and class
    final instanceMirror = reflect(this);
    final classMirror = instanceMirror.type;

    /// The validation method naming expectation is 'validateFieldName'
    final methodName = 'validate${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
    final methodSymbol = Symbol(methodName);

    /// Find out if the concrete class has a validation method for the field
    if (classMirror.instanceMembers.containsKey(methodSymbol)) {
      /// Call the validation method
      final methodMirror = classMirror.instanceMembers[methodSymbol];
      instanceMirror.invoke(methodMirror.simpleName, [value]);
    }
  }
}
