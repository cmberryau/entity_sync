import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:moor/moor.dart';

import 'database.dart';

part 'test_entities.g.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends SyncableTable {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();

  @override
  Table actualTable() => this;

  @override
  Column localKeyColumn() => id;

  @override
  Column remoteKeyColumn() => null;
}

@UseEntitySync(TestMoorEntity,
    fields: [
      IntegerField('id'),
      StringField('name'),
      DateTimeField('created'),
    ],
    keyField: StringField('id'),
    remoteKeyField: null,
    flagField: null)
class TestMoorEntitySync extends $_TestMoorEntitySync {}
