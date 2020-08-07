import 'dart:mirrors';
import 'dart:convert';

/// Represents a field which may be serialized
abstract class SerializableField {
  /// The name of the field
  String name;

  SerializableField(this.name);

  /// Evaluates if the passed value is valid
  dynamic isValid(dynamic value);

  /// Outputs the passed value to a representation
  dynamic toRepresentation(dynamic value);

  /// Gets the value of the field for the instance
  dynamic getValue(SerializableMixin instance) {
    return instance.getFieldValue(name);
  }
}

/// Represents an integer field which may be serialized
class IntegerField extends SerializableField {
  IntegerField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }
}

/// Represents an string field which may be serialized
class StringField extends SerializableField {
  StringField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }
}

/// Represents an datetime field which may be serialized
class DateTimeField extends SerializableField {
  DateTimeField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return (value as DateTime).toIso8601String();
  }
}

/// Represents a boolean field which may be serialized
class BoolField extends SerializableField {
  BoolField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return json.encode(value);
  }}

/// Added to a class to support serialization
abstract class SerializableMixin {
  dynamic getFieldValue(String fieldName) {
    return reflect(this).getField(Symbol(fieldName)).reflectee;
  }
}

/// An exception which represents a failed validation
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
  List<SerializableField> getFields() {
    return reflect(this).getField(Symbol('fields')).reflectee;
  }

  /// Determines if the serializer is valid
  bool isValid() {
    final exceptions = <ValidationException>[];

    final fields = getFields();
    for (final field in fields) {
      dynamic value;

      /// The data could be coming from an instance or raw data
      if (instance != null) {
        value = instance.getFieldValue(field.name);
      } else if (data != null) {
        value = data[field.name];
      } else {
        return false;
      }

      /// Validate the field and collect any exceptions
      try {
        validateField(field.name, value);
      } on ValidationException catch(e) {
        exceptions.add(e);
      }
    }

    return exceptions.isEmpty;
  }

  /// Validates a field, using reflection to find any additional validation methods
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

  /// Returns the serializable representation
  dynamic toRepresentation() {
    final fields = getFields();
    final representationMap = <String, dynamic>{};

    for (final field in fields) {
      dynamic value;

      /// The data could be coming from an instance or raw data
      if (instance != null) {
        value = instance.getFieldValue(field.name);
      } else if (data != null) {
        value = data[field.name];
      } else {
        return null;
      }

      /// Fill the representation map with the field representation
      representationMap[field.name] = field.toRepresentation(value);
    }

    return json.encode(representationMap);
  }
}
