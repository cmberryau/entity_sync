// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_test.dart';

// **************************************************************************
// IsSerializerGenerator
// **************************************************************************

abstract class $_TestMoorEntitySerializer
    extends Serializer<TestMoorEntityProxy> {
  $_TestMoorEntitySerializer(
      {Map<String, dynamic> data, TestMoorEntityProxy instance})
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
