import 'package:entity_sync/entity_sync.dart';
import 'package:entity_sync/moor_sync.dart';
import 'package:moor/moor.dart';

import 'database.dart';

part 'related_entities.g.dart';

@DataClassName('FirstRelatedEntity')
class FirstRelatedEntities extends SyncableTable {
  TextColumn get uuid => text()();

  IntColumn get id => integer().autoIncrement()();

  TextColumn get relatedEntity => text()();

  @override
  SyncableTable actualTable() => this;

  @override
  Column localKeyColumn() => id;

  @override
  Column remoteKeyColumn() => uuid;
}

@DataClassName('SecondRelatedEntity')
class SecondRelatedEntities extends SyncableTable {
  TextColumn get uuid => text()();

  IntColumn get id => integer().autoIncrement()();

  @override
  SyncableTable actualTable() => this;

  @override
  Column localKeyColumn() => id;

  @override
  Column remoteKeyColumn() => uuid;
}

@UseEntitySync(
  FirstRelatedEntity,
  fields: [
    StringField('uuid'),
    IntegerField('id'),
    StringField('relatedEntity'),
  ],
  remoteKeyField: StringField('uuid'),
  keyField: IntegerField('id'),
  flagField: BoolField('shouldSync'),
)
class FirstRelatedEntitySync extends $_FirstRelatedEntitySync {}

@UseEntitySync(
  SecondRelatedEntity,
  fields: [
    StringField('uuid'),
    IntegerField('id'),
  ],
  remoteKeyField: StringField('uuid'),
  keyField: IntegerField('id'),
  flagField: BoolField('shouldSync'),
)
class SecondRelatedEntitySync extends $_SecondRelatedEntitySync {}
