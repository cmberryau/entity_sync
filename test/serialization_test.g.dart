// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serialization_test.dart';

// **************************************************************************
// IsSerializerGenerator
// **************************************************************************

abstract class $_TestEntitySerializer extends Serializer<TestEntityProxy> {
  $_TestEntitySerializer({Map<String, dynamic> data, TestEntityProxy instance})
      : super(data: data, instance: instance);

  @override
  final fields = [
    IntegerField('id'),
    StringField('name'),
    DateTimeField('created'),
  ];
  int validateId(int value);
  String validateName(String value);
  DateTime validateCreated(DateTime value);
  @override
  Map toMap() {
    return {
      'validateId': validateId,
      'validateName': validateName,
      'validateCreated': validateCreated,
    };
  }
}

// **************************************************************************
// UseSerializationGenerator
// **************************************************************************

class $_TestEntityProxy extends TestEntity with SerializableMixin {
  $_TestEntityProxy(
    int id,
    String name,
    DateTime created, {
    bool shouldSync,
  }) : super(
          id,
          name,
          created,
          shouldSync: shouldSync,
        );
  @override
  Map toMap() {
    return {
      'id': id,
      'name': name,
      'created': created,
      'shouldSync': shouldSync,
    };
  }
}
