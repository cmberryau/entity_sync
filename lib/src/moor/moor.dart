import 'package:entity_sync/entity_sync.dart';
import 'package:moor/moor.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'moor_storage.dart';

/// Responsible for creating proxies
abstract class ProxyFactory<TProxy extends ProxyMixin<DataClass>,
    TEntity extends DataClass> {
  /// Creates a proxy from a moor instance
  TProxy fromInstance(TEntity instance);
}

/// Provides all the functionality to act as a proxy
abstract class ProxyMixin<TEntity extends DataClass>
    implements
        UpdateCompanion<TEntity>,
        Insertable<TEntity>,
        SyncableMixin,
        SerializableMixin {
  @override
  final flagField = BoolField('shouldSync', source: 'shouldSync');
}

abstract class SyncableTable extends Table {
  /// Indicates if the entity should be synced
  BoolColumn get shouldSync => boolean().clientDefault(() => true)();

  /// The column for local key storage
  Column localKeyColumn();

  /// The column for remote key storage
  Column remoteKeyColumn();

  /// The actual table
  SyncableTable actualTable();
}
