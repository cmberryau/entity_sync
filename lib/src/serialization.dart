import 'dart:convert';

/// Represents a field which may be serialized
abstract class SerializableField {
  /// The name of the field
  final String name;

  const SerializableField(this.name);

  /// Evaluates if the passed value is valid
  dynamic isValid(dynamic value);

  /// Outputs the passed value to a representation
  dynamic toRepresentation(dynamic value);

  /// Gets the value of the field for the instance
  dynamic getValue(SerializableMixin instance) {
    return instance.getFieldValue(name);
  }

  /// Evaluates if two values are equal
  bool areEqual(dynamic a, dynamic b) {
    return a == b;
  }
}

/// Represents an integer field which may be serialized
class IntegerField extends SerializableField {
  const IntegerField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value as int;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }
}

/// Represents an string field which may be serialized
class StringField extends SerializableField {
  const StringField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value as String;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }
}

/// Represents an datetime field which may be serialized
class DateTimeField extends SerializableField {
  const DateTimeField(String name) : super(name);

  @override
  dynamic isValid(value) {
    if (value.runtimeType == String) {
      value = DateTime.parse(value);
    } else if (value.runtimeType == int) {
      value = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value.runtimeType != DateTime) {
      throw ValidationException('Must be formatted String or DateTime');
    }

    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return (value as DateTime).toUtc().toIso8601String();
  }
}

class DateField extends SerializableField {
  const DateField(String name) : super(name);

  @override
  dynamic isValid(value) {
    if (value.runtimeType == String) {
      value = DateTime.parse(value);
    } else if (value.runtimeType == int) {
      value = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value.runtimeType != DateTime) {
      throw ValidationException('Must be formatted String or DateTime');
    }

    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return (value as DateTime).toIso8601String().split("T")[0];
  }
}

/// Represents a boolean field which may be serialized
class BoolField extends SerializableField {
  const BoolField(String name) : super(name);

  @override
  dynamic isValid(value) {
    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return json.encode(value);
  }
}

/// Added to a class to support serialization
abstract class SerializableMixin {
  dynamic getFieldValue(String fieldName) {
    return toMap()[fieldName];
  }

  Map toMap();
}

/// An exception which represents a failed validation
class ValidationException implements Exception {
  String cause;
  ValidationException(this.cause);
}

/// Performs serialization
abstract class Serializer<TSerializable extends SerializableMixin> {
  List<SerializableField> fields = [];
  TSerializable instance;
  Map<String, dynamic> data;
  Map<String, dynamic> _validatedData;
  final exceptions = <ValidationException>[];

  Serializer({this.data, this.instance}) {
    if (getFields() == null) {
      throw AbstractClassInstantiationError((Serializer).toString());
    }

    data = {};
    _validatedData = {};
  }

  /// Gets all fields for serialization
  List<SerializableField> getFields() {
    return fields;
  }

  /// Determines if the serializer is valid
  bool isValid() {
    exceptions.clear();
    _validatedData.clear();

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
        _validatedData[field.name] = validateField(field, value);
      } on ValidationException catch (e) {
        exceptions.add(e);
      }
    }

    return exceptions.isEmpty;
  }

  /// Validate a field
  dynamic validateField(SerializableField field, dynamic value) {
    /// Do basic field validation
    value = field.isValid(value);

    /// Do any additional concrete validation
    return isValidConcrete(field.name, value);
  }

  /// Use reflection to find any additional validation methods
  dynamic isValidConcrete(String fieldName, dynamic value) {
    /// The validation method naming expectation is 'validateFieldName'
    final methodName =
        'validate${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
    return toMap()[methodName](value);
  }

  /// Returns the serializable representation
  dynamic toRepresentation({bool skipValidation = false}) {
    final fields = getFields();
    final representationMap = <String, dynamic>{};

    /// Validate the data first
    if (!skipValidation && !isValid()) {
      return null;
    }

    for (final field in fields) {
      /// Fill the representation map with the validated field value representation
      representationMap[field.name] =
          field.toRepresentation(_validatedData[field.name]);
    }

    return representationMap;
  }

  /// Returns the serializable representation string
  dynamic toRepresentationString({bool skipValidation = false}) {
    return json.encode(toRepresentation(skipValidation: skipValidation));
  }

  /// Returns an instance from the serializer
  TSerializable toInstance() {
    if (isValid()) {
      return createInstance(_validatedData);
    }
    return null;
  }

  /// Evaluates if the serialized fields are equal
  bool areEqual(TSerializable a, TSerializable b) {
    final fields = getFields();

    final aAttrs = a.toMap();
    final bAttrs = b.toMap();

    for (var field in fields) {
      final aFieldValue = aAttrs[field.name];
      final bFieldValue = bAttrs[field.name];

      if (!field.areEqual(aFieldValue, bFieldValue)) {
        return false;
      }
    }

    return true;
  }

  /// Creates an instance from validated data
  TSerializable createInstance(Map<String, dynamic> validatedData);

  Map toMap();
}
