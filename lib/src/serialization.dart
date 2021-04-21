import 'dart:convert';

/// Represents a field which may be serialized
abstract class SerializableField {
  /// The name of the field
  final String name;

  /// The prefix of the field
  final String? prefix;

  /// The source of the field
  final String? source;

  const SerializableField(
    this.name, {
    this.prefix,
    this.source,
  });

  /// Evaluates if the passed value is valid
  dynamic isValid(dynamic value);

  /// Outputs the passed value to a representation
  dynamic toRepresentation(dynamic value);

  /// Gets the value of the field for the instance
  dynamic getValue(SerializableMixin instance) {
    final source = this.source;
    if (source == null) {
      return instance.getFieldValue(name);
    }
    return instance.getFieldValue(source);
  }

  /// Evaluates if two values are equal
  bool areEqual(dynamic a, dynamic b) {
    return a == b;
  }

  @override
  String toString() {
    return 'SerializableField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Represents an integer field which may be serialized
class IntegerField extends SerializableField {
  const IntegerField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    return value as int;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }

  @override
  String toString() {
    return 'IntegerField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Represents a double field which may be serialized
class DoubleField extends SerializableField {
  const DoubleField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    if (value == null) {
      return null;
    } else if (value is int) {
      return value.toDouble();
    }
    return value as double;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }

  @override
  String toString() {
    return 'DoubleField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Represents an string field which may be serialized
class StringField extends SerializableField {
  const StringField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    if (value == null) {
      return null;
    }
    return value as String;
  }

  @override
  dynamic toRepresentation(value) {
    return value;
  }

  @override
  String toString() {
    return 'StringField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Represents an datetime field which may be serialized
class DateTimeField extends SerializableField {
  const DateTimeField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    if (value == null) {
      return null;
    } else if (value.runtimeType == String) {
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

  @override
  String toString() {
    return 'DateTimeField(name: $name, prefix: $prefix, source: $source)';
  }
}

class DateField extends SerializableField {
  const DateField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    if (value == null) {
      return null;
    } else if (value.runtimeType == String) {
      value = DateTime.parse(value);
      value = DateTime(value.year, value.month, value.day, 12, 00, 00);
    } else if (value.runtimeType == int) {
      value = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value.runtimeType != DateTime) {
      throw ValidationException('Must be formatted String or DateTime');
    }

    return value;
  }

  @override
  dynamic toRepresentation(value) {
    return (value as DateTime).toIso8601String().split('T')[0];
  }

  @override
  String toString() {
    return 'DateField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Represents a boolean field which may be serialized
class BoolField extends SerializableField {
  const BoolField(
    String name, {
    String? prefix,
    String? source,
  }) : super(name, prefix: prefix, source: source);

  @override
  dynamic isValid(value) {
    if (value == null) {
      return null;
    }

    return value as bool;
  }

  @override
  dynamic toRepresentation(value) {
    return json.encode(value);
  }

  @override
  String toString() {
    return 'BoolField(name: $name, prefix: $prefix, source: $source)';
  }
}

/// Added to a class to support serialization
abstract class SerializableMixin {
  dynamic getFieldValue(String fieldName) {
    return toMap()[fieldName];
  }

  Map<String, dynamic> toMap();

  SerializableMixin copyFromMap(Map<String, dynamic> mapData);
}

/// An exception which represents a failed validation
class ValidationException implements Exception {
  String cause;

  ValidationException(this.cause);

  @override
  String toString() {
    return 'ValidationException($cause)';
  }
}

/// Performs serialization
abstract class Serializer<TSerializable extends SerializableMixin> {
  List<SerializableField> fields = [];
  TSerializable? instance;
  Map<String, dynamic>? data = {};
  final Map<String, dynamic> _validatedData = {};
  final exceptions = <ValidationException>[];
  final prefix;

  Serializer({this.data, this.instance, this.prefix = ''});

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
      final instance = this.instance;
      final data = this.data;
      if (instance != null) {
        final source = field.source;
        if (source != null) {
          value = instance.getFieldValue(source);
        } else {
          value = instance.getFieldValue(field.name);
        }
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

    // prepend the prefix to value
    if (field.prefix != null && value is String) {
      final completePrefix = '$prefix${field.prefix}';

      // if the field is already has the prefix, remove it, else prepend to it
      if (value.startsWith(prefix)) {
        value = value.replaceFirst(completePrefix, '');

        if (value.endsWith('/')) {
          value = value.substring(0, value.length - 1);
        }
      } else {
        value = '$completePrefix$value/';
      }
    }

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
  TSerializable? toInstance() {
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

  @override
  String toString() {
    return 'Serializer(data: $data, instance: $instance, prefix: $prefix)';
  }
}
