import 'package:moor/moor.dart';

import 'package:entity_sync/entity_sync.dart';

import 'database.dart';

@DataClassName('TestMoorEntity')
class TestMoorEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 3, max: 100)();
  DateTimeColumn get created => dateTime()();
  BoolColumn get shouldSync => boolean().clientDefault(() => true)();
}

class TestMoorEntityProxy extends TestMoorEntity with SerializableMixin, SyncableMixin {
  /// The unique syncable key of the entity
  final keyField = IntegerField('id');
  /// The flag to indicate the entity needs to be synced
  final flagField = BoolField('shouldSync');
}