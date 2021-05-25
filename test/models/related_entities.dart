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
//
// class Something extends FirstRelatedEntitiesCompanion
//     with ProxyMixin<FirstRelatedEntity>, SyncableMixin, SerializableMixin {
//   Something({
//     shouldSync = const Value.absent(),
//     uuid = const Value.absent(),
//     id = const Value.absent(),
//     relatedEntity = const Value.absent(),
//   }) : super(
//           shouldSync: shouldSync,
//           uuid: uuid,
//           id: id,
//           relatedEntity: relatedEntity,
//         );
//
//   @override
//   final keyField = IntegerField('id', source: 'id');
//
//   @override
//   final remoteKeyField = StringField('uuid', source: 'uuid');
//
//   @override
//   final flagField = BoolField('shouldSync', source: 'shouldSync');
//
//   @override
//   SerializableMixin copyFromMap(Map<String, dynamic> mapData) {
//     // TODO: implement copyFromMap
//     throw UnimplementedError();
//   }
//
//   @override
//   Map<String, dynamic> toJson({ValueSerializer? serializer}) {
//     // TODO: implement toJson
//     throw UnimplementedError();
//   }
//
//   @override
//   String toJsonString({ValueSerializer? serializer}) {
//     // TODO: implement toJsonString
//     throw UnimplementedError();
//   }
//
//   @override
//   Map<String, dynamic> toMap() {
//     // TODO: implement toMap
//     throw UnimplementedError();
//   }
//  
//   Something.fromEntity()
// }
