import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:moor/moor.dart';

import 'database.dart';

part 'test_entities.g.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends SyncableTable {
  TextColumn get uuid => text().withLength(min: 36, max:36).nullable()();
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();

  @override
  Table actualTable() => this;

  @override
  Column localKeyColumn() => id;

  @override
  Column remoteKeyColumn() => uuid;
}

@UseEntitySync(TestMoorEntity,
    fields: [
      StringField('uuid'),
      IntegerField('id'),
      StringField('name'),
      DateTimeField('created'),
    ],
    remoteKeyField: StringField('remote_uuid'),
    keyField: IntegerField('id'),
    flagField: null)
class TestMoorEntitySync extends $_TestMoorEntitySync {}
